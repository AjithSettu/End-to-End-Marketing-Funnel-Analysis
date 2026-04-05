-- ============================================================
-- FILE: sql/04_lead_velocity_and_time_in_stage.sql
-- PROJECT: End-to-End Marketing Funnel Analysis
-- AUTHOR: Ajith
-- DESCRIPTION: How fast leads move through the funnel.
--              Measures average days between each stage transition.
-- ============================================================

-- ------------------------------------------------------------
-- QUERY 1: Days from Lead Creation to MQL
-- Measures how quickly marketing qualifies incoming leads
-- ------------------------------------------------------------
SELECT
    l.lead_id,
    l.source,
    l.industry,
    l.created_date                                              AS lead_date,
    mql.event_date                                             AS mql_date,
    JULIANDAY(mql.event_date) - JULIANDAY(l.created_date)     AS days_to_mql
FROM leads l
JOIN funnel_events mql
    ON l.lead_id = mql.lead_id
    AND mql.event_type = 'mql'
ORDER BY days_to_mql;

-- ------------------------------------------------------------
-- QUERY 2: Average Time Between Each Funnel Stage
-- Identifies bottlenecks in the sales process
-- ------------------------------------------------------------
WITH stage_dates AS (
    SELECT
        lead_id,
        MAX(CASE WHEN event_type = 'mql'         THEN event_date END) AS mql_date,
        MAX(CASE WHEN event_type = 'sql'         THEN event_date END) AS sql_date,
        MAX(CASE WHEN event_type = 'opportunity' THEN event_date END) AS opp_date,
        MAX(CASE WHEN event_type IN ('closed_won','closed_lost') THEN event_date END) AS close_date
    FROM funnel_events
    GROUP BY lead_id
)
SELECT
    ROUND(AVG(JULIANDAY(sql_date) - JULIANDAY(mql_date)), 1)  AS avg_days_mql_to_sql,
    ROUND(AVG(JULIANDAY(opp_date) - JULIANDAY(sql_date)), 1)  AS avg_days_sql_to_opp,
    ROUND(AVG(JULIANDAY(close_date)- JULIANDAY(opp_date)), 1) AS avg_days_opp_to_close,
    ROUND(AVG(JULIANDAY(close_date)- JULIANDAY(mql_date)), 1) AS avg_total_sales_cycle_days
FROM stage_dates
WHERE sql_date IS NOT NULL;  -- Only leads that progressed past MQL

-- ------------------------------------------------------------
-- QUERY 3: Time-in-Stage by Lead Source
-- Does channel affect how fast leads move through the funnel?
-- ------------------------------------------------------------
WITH stage_dates AS (
    SELECT
        fe.lead_id,
        l.source,
        MAX(CASE WHEN fe.event_type = 'mql'         THEN fe.event_date END) AS mql_date,
        MAX(CASE WHEN fe.event_type = 'sql'         THEN fe.event_date END) AS sql_date,
        MAX(CASE WHEN fe.event_type = 'opportunity' THEN fe.event_date END) AS opp_date,
        MAX(CASE WHEN fe.event_type IN ('closed_won','closed_lost') THEN fe.event_date END) AS close_date
    FROM funnel_events fe
    JOIN leads l ON fe.lead_id = l.lead_id
    GROUP BY fe.lead_id, l.source
)
SELECT
    source,
    COUNT(*)                                                                   AS leads_progressed,
    ROUND(AVG(JULIANDAY(sql_date)   - JULIANDAY(mql_date)),   1)             AS avg_days_mql_to_sql,
    ROUND(AVG(JULIANDAY(close_date) - JULIANDAY(mql_date)),   1)             AS avg_total_cycle_days
FROM stage_dates
WHERE sql_date IS NOT NULL
GROUP BY source
ORDER BY avg_total_cycle_days;

-- ------------------------------------------------------------
-- QUERY 4: Leads Stalled in Pipeline (No Activity > 14 Days)
-- Flags leads that may need re-engagement
-- Based on latest event date vs today's date
-- ------------------------------------------------------------
WITH latest_stage AS (
    SELECT
        lead_id,
        MAX(event_type)   AS latest_stage,
        MAX(event_date)   AS last_activity_date
    FROM funnel_events
    GROUP BY lead_id
)
SELECT
    l.lead_id,
    l.source,
    l.industry,
    ls.latest_stage,
    ls.last_activity_date,
    CAST(JULIANDAY('now') - JULIANDAY(ls.last_activity_date) AS INTEGER) AS days_since_last_activity
FROM leads l
JOIN latest_stage ls ON l.lead_id = ls.lead_id
WHERE ls.latest_stage NOT IN ('closed_won', 'closed_lost')
  AND JULIANDAY('now') - JULIANDAY(ls.last_activity_date) > 14
ORDER BY days_since_last_activity DESC;
