-- ============================================================
-- FILE: sql/06_channel_attribution_and_roi.sql
-- PROJECT: End-to-End Marketing Funnel Analysis
-- AUTHOR: Ajith
-- DESCRIPTION: Channel attribution — links email campaign
--              engagement back to funnel outcomes.
--              Identifies best-performing campaign-to-win paths.
-- ============================================================

-- ------------------------------------------------------------
-- QUERY 1: Campaign-Attributed Lead Count
-- How many leads came from each campaign?
-- ------------------------------------------------------------
SELECT
    ec.campaign_id,
    ec.campaign_name,
    ec.segment,
    COUNT(DISTINCT l.lead_id)       AS leads_attributed,
    ec.emails_sent,
    ROUND(100.0 * COUNT(DISTINCT l.lead_id) / NULLIF(ec.emails_sent, 0), 2) AS lead_gen_rate_pct
FROM email_campaigns ec
LEFT JOIN leads l ON l.campaign_id = ec.campaign_id
GROUP BY ec.campaign_id, ec.campaign_name, ec.segment, ec.emails_sent
ORDER BY leads_attributed DESC;

-- ------------------------------------------------------------
-- QUERY 2: Campaign → Funnel Outcome Linkage
-- Which campaigns produced the most MQLs, SQLs, and wins?
-- ------------------------------------------------------------
SELECT
    ec.campaign_id,
    ec.campaign_name,
    COUNT(DISTINCT l.lead_id)                                                AS total_leads,
    COUNT(DISTINCT CASE WHEN fe.event_type = 'mql'        THEN fe.lead_id END) AS mql_count,
    COUNT(DISTINCT CASE WHEN fe.event_type = 'sql'        THEN fe.lead_id END) AS sql_count,
    COUNT(DISTINCT CASE WHEN fe.event_type = 'closed_won' THEN fe.lead_id END) AS won_count,
    ROUND(100.0 *
        COUNT(DISTINCT CASE WHEN fe.event_type = 'closed_won' THEN fe.lead_id END)
        / NULLIF(COUNT(DISTINCT l.lead_id), 0), 1)                          AS win_rate_pct
FROM email_campaigns ec
LEFT JOIN leads l         ON l.campaign_id  = ec.campaign_id
LEFT JOIN funnel_events fe ON fe.lead_id    = l.lead_id
GROUP BY ec.campaign_id, ec.campaign_name
ORDER BY won_count DESC;

-- ------------------------------------------------------------
-- QUERY 3: Best Performing Source + Campaign Combination
-- Find the highest-converting channel × campaign pairings
-- ------------------------------------------------------------
SELECT
    l.source,
    l.campaign_id,
    COUNT(DISTINCT l.lead_id)                                                AS total_leads,
    COUNT(DISTINCT CASE WHEN fe.event_type = 'closed_won' THEN fe.lead_id END) AS won_count,
    ROUND(100.0 *
        COUNT(DISTINCT CASE WHEN fe.event_type = 'closed_won' THEN fe.lead_id END)
        / NULLIF(COUNT(DISTINCT l.lead_id), 0), 1)                          AS win_rate_pct
FROM leads l
LEFT JOIN funnel_events fe ON fe.lead_id = l.lead_id
GROUP BY l.source, l.campaign_id
HAVING COUNT(DISTINCT l.lead_id) > 1    -- Minimum volume filter
ORDER BY win_rate_pct DESC;

-- ------------------------------------------------------------
-- QUERY 4: Email Engagement vs Funnel Conversion Correlation
-- Do campaigns with higher CTR produce better MQL rates?
-- (Joins aggregated campaign metrics with lead outcomes)
-- ------------------------------------------------------------
WITH campaign_email_kpi AS (
    SELECT
        campaign_id,
        ROUND(100.0 * SUM(clicks) / NULLIF(SUM(emails_delivered), 0), 2) AS avg_ctr_pct
    FROM email_campaigns
    GROUP BY campaign_id
),
campaign_funnel_kpi AS (
    SELECT
        l.campaign_id,
        COUNT(DISTINCT l.lead_id)                                                   AS total_leads,
        COUNT(DISTINCT CASE WHEN fe.event_type = 'mql' THEN fe.lead_id END)        AS mql_count,
        ROUND(100.0 *
            COUNT(DISTINCT CASE WHEN fe.event_type = 'mql' THEN fe.lead_id END)
            / NULLIF(COUNT(DISTINCT l.lead_id), 0), 1)                             AS mql_rate_pct
    FROM leads l
    LEFT JOIN funnel_events fe ON fe.lead_id = l.lead_id
    GROUP BY l.campaign_id
)
SELECT
    ek.campaign_id,
    ek.avg_ctr_pct,
    fk.total_leads,
    fk.mql_count,
    fk.mql_rate_pct
FROM campaign_email_kpi ek
JOIN campaign_funnel_kpi fk ON ek.campaign_id = fk.campaign_id
ORDER BY ek.avg_ctr_pct DESC;
