-- ============================================================
-- FILE: sql/05_cohort_analysis.sql
-- PROJECT: End-to-End Marketing Funnel Analysis
-- AUTHOR: Ajith
-- DESCRIPTION: Cohort analysis — tracks lead batches by the
--              month they were created and how they progress
--              over subsequent months.
-- ============================================================

-- ------------------------------------------------------------
-- QUERY 1: Lead Cohort Progression Matrix
-- For each monthly cohort: how many reached each funnel stage?
-- ------------------------------------------------------------
WITH lead_cohorts AS (
    SELECT
        l.lead_id,
        strftime('%Y-%m', l.created_date)                                      AS cohort_month,
        MAX(CASE WHEN fe.event_type = 'mql'         THEN 1 ELSE 0 END)        AS became_mql,
        MAX(CASE WHEN fe.event_type = 'sql'         THEN 1 ELSE 0 END)        AS became_sql,
        MAX(CASE WHEN fe.event_type = 'opportunity' THEN 1 ELSE 0 END)        AS became_opp,
        MAX(CASE WHEN fe.event_type = 'closed_won'  THEN 1 ELSE 0 END)        AS became_won
    FROM leads l
    LEFT JOIN funnel_events fe ON l.lead_id = fe.lead_id
    GROUP BY l.lead_id, cohort_month
)
SELECT
    cohort_month,
    COUNT(*)                                AS cohort_size,
    SUM(became_mql)                         AS mql_count,
    SUM(became_sql)                         AS sql_count,
    SUM(became_opp)                         AS opp_count,
    SUM(became_won)                         AS won_count,
    ROUND(100.0 * SUM(became_mql) / COUNT(*), 1)  AS mql_rate_pct,
    ROUND(100.0 * SUM(became_sql) / COUNT(*), 1)  AS sql_rate_pct,
    ROUND(100.0 * SUM(became_won) / COUNT(*), 1)  AS win_rate_pct
FROM lead_cohorts
GROUP BY cohort_month
ORDER BY cohort_month;

-- ------------------------------------------------------------
-- QUERY 2: Source-Level Cohort Win Rates
-- Which acquisition channel has the highest cohort-level ROI?
-- ------------------------------------------------------------
WITH source_cohorts AS (
    SELECT
        l.source,
        strftime('%Y-%m', l.created_date)                                      AS cohort_month,
        l.lead_id,
        MAX(CASE WHEN fe.event_type = 'closed_won' THEN 1 ELSE 0 END)         AS became_won
    FROM leads l
    LEFT JOIN funnel_events fe ON l.lead_id = fe.lead_id
    GROUP BY l.source, cohort_month, l.lead_id
)
SELECT
    source,
    cohort_month,
    COUNT(*)                                        AS cohort_size,
    SUM(became_won)                                 AS wins,
    ROUND(100.0 * SUM(became_won) / COUNT(*), 1)   AS win_rate_pct
FROM source_cohorts
GROUP BY source, cohort_month
ORDER BY source, cohort_month;

-- ------------------------------------------------------------
-- QUERY 3: Cohort Velocity — Time from Lead to Win per Cohort
-- Do newer cohorts convert faster? Tracks sales cycle maturity.
-- ------------------------------------------------------------
WITH wins AS (
    SELECT
        l.lead_id,
        strftime('%Y-%m', l.created_date)       AS cohort_month,
        l.created_date                          AS lead_date,
        fe.event_date                           AS win_date
    FROM leads l
    JOIN funnel_events fe
        ON l.lead_id = fe.lead_id
        AND fe.event_type = 'closed_won'
)
SELECT
    cohort_month,
    COUNT(*)                                                AS wins,
    ROUND(AVG(JULIANDAY(win_date) - JULIANDAY(lead_date)), 0) AS avg_days_lead_to_win
FROM wins
GROUP BY cohort_month
ORDER BY cohort_month;
