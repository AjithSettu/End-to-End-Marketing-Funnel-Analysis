-- ============================================================
-- FILE: sql/02_funnel_stage_analysis.sql
-- PROJECT: End-to-End Marketing Funnel Analysis
-- AUTHOR: Ajith
-- DESCRIPTION: Stage-by-stage funnel conversion rates
-- ============================================================

-- ------------------------------------------------------------
-- QUERY 1: Full Funnel Overview
-- Count leads at each stage and compute drop-off rates
-- ------------------------------------------------------------
WITH stage_counts AS (
    SELECT
        COUNT(DISTINCT l.lead_id)                                         AS total_leads,
        COUNT(DISTINCT CASE WHEN fe.event_type = 'mql'         THEN fe.lead_id END) AS mql_count,
        COUNT(DISTINCT CASE WHEN fe.event_type = 'sql'         THEN fe.lead_id END) AS sql_count,
        COUNT(DISTINCT CASE WHEN fe.event_type = 'opportunity' THEN fe.lead_id END) AS opp_count,
        COUNT(DISTINCT CASE WHEN fe.event_type = 'closed_won'  THEN fe.lead_id END) AS won_count
    FROM leads l
    LEFT JOIN funnel_events fe ON l.lead_id = fe.lead_id
)
SELECT
    total_leads,
    mql_count,
    sql_count,
    opp_count,
    won_count,
    ROUND(100.0 * mql_count / NULLIF(total_leads, 0), 1) AS lead_to_mql_pct,
    ROUND(100.0 * sql_count  / NULLIF(mql_count,   0), 1) AS mql_to_sql_pct,
    ROUND(100.0 * opp_count  / NULLIF(sql_count,   0), 1) AS sql_to_opp_pct,
    ROUND(100.0 * won_count  / NULLIF(opp_count,   0), 1) AS opp_to_won_pct,
    ROUND(100.0 * won_count  / NULLIF(total_leads, 0), 1) AS overall_conversion_pct
FROM stage_counts;

-- ------------------------------------------------------------
-- QUERY 2: Funnel Breakdown by Lead Source
-- Identify which channels drive the best quality leads
-- ------------------------------------------------------------
WITH source_funnel AS (
    SELECT
        l.source,
        COUNT(DISTINCT l.lead_id)                                                   AS total_leads,
        COUNT(DISTINCT CASE WHEN fe.event_type = 'mql'         THEN fe.lead_id END) AS mql_count,
        COUNT(DISTINCT CASE WHEN fe.event_type = 'sql'         THEN fe.lead_id END) AS sql_count,
        COUNT(DISTINCT CASE WHEN fe.event_type = 'closed_won'  THEN fe.lead_id END) AS won_count
    FROM leads l
    LEFT JOIN funnel_events fe ON l.lead_id = fe.lead_id
    GROUP BY l.source
)
SELECT
    source,
    total_leads,
    mql_count,
    sql_count,
    won_count,
    ROUND(100.0 * mql_count / NULLIF(total_leads, 0), 1) AS lead_to_mql_pct,
    ROUND(100.0 * won_count / NULLIF(total_leads, 0), 1) AS lead_to_win_pct
FROM source_funnel
ORDER BY lead_to_win_pct DESC;

-- ------------------------------------------------------------
-- QUERY 3: Funnel Breakdown by Industry
-- Which industries convert best end-to-end?
-- ------------------------------------------------------------
SELECT
    l.industry,
    COUNT(DISTINCT l.lead_id)                                                   AS total_leads,
    COUNT(DISTINCT CASE WHEN fe.event_type = 'mql'        THEN fe.lead_id END) AS mql_count,
    COUNT(DISTINCT CASE WHEN fe.event_type = 'sql'        THEN fe.lead_id END) AS sql_count,
    COUNT(DISTINCT CASE WHEN fe.event_type = 'closed_won' THEN fe.lead_id END) AS won_count,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN fe.event_type = 'closed_won' THEN fe.lead_id END)
        / NULLIF(COUNT(DISTINCT l.lead_id), 0), 1)                             AS win_rate_pct
FROM leads l
LEFT JOIN funnel_events fe ON l.lead_id = fe.lead_id
GROUP BY l.industry
ORDER BY win_rate_pct DESC;

-- ------------------------------------------------------------
-- QUERY 4: Monthly Funnel Trend
-- Track funnel health over time (month-over-month)
-- ------------------------------------------------------------
SELECT
    strftime('%Y-%m', l.created_date)                                              AS cohort_month,
    COUNT(DISTINCT l.lead_id)                                                      AS leads_created,
    COUNT(DISTINCT CASE WHEN fe.event_type = 'mql'        THEN fe.lead_id END)    AS mqls,
    COUNT(DISTINCT CASE WHEN fe.event_type = 'sql'        THEN fe.lead_id END)    AS sqls,
    COUNT(DISTINCT CASE WHEN fe.event_type = 'closed_won' THEN fe.lead_id END)    AS wins,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN fe.event_type = 'mql' THEN fe.lead_id END)
        / NULLIF(COUNT(DISTINCT l.lead_id), 0), 1)                                AS mql_rate_pct
FROM leads l
LEFT JOIN funnel_events fe ON l.lead_id = fe.lead_id
GROUP BY cohort_month
ORDER BY cohort_month;
