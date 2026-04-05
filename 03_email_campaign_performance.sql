-- ============================================================
-- FILE: sql/03_email_campaign_performance.sql
-- PROJECT: End-to-End Marketing Funnel Analysis
-- AUTHOR: Ajith
-- DESCRIPTION: Email campaign KPIs — deliverability, open rate,
--              CTR, bounce rate, unsubscribe rate
-- ============================================================

-- ------------------------------------------------------------
-- QUERY 1: Campaign-Level KPI Summary
-- Core email metrics per campaign send
-- ------------------------------------------------------------
SELECT
    campaign_id,
    campaign_name,
    send_date,
    segment,
    emails_sent,
    emails_delivered,
    opens,
    clicks,

    -- Deliverability Rate
    ROUND(100.0 * emails_delivered / NULLIF(emails_sent, 0), 2)   AS deliverability_rate_pct,

    -- Open Rate (opens / delivered)
    ROUND(100.0 * opens / NULLIF(emails_delivered, 0), 2)          AS open_rate_pct,

    -- Click-Through Rate (clicks / delivered)
    ROUND(100.0 * clicks / NULLIF(emails_delivered, 0), 2)         AS ctr_pct,

    -- Click-to-Open Rate (clicks / opens)
    ROUND(100.0 * clicks / NULLIF(opens, 0), 2)                    AS ctor_pct,

    -- Bounce Rate (bounces / sent)
    ROUND(100.0 * bounces / NULLIF(emails_sent, 0), 2)             AS bounce_rate_pct,

    -- Unsubscribe Rate (unsubscribes / delivered)
    ROUND(100.0 * unsubscribes / NULLIF(emails_delivered, 0), 2)   AS unsub_rate_pct

FROM email_campaigns
ORDER BY send_date;

-- ------------------------------------------------------------
-- QUERY 2: Campaign Performance by Segment
-- Aggregate KPIs rolled up by audience segment
-- ------------------------------------------------------------
SELECT
    segment,
    COUNT(*)                                                        AS total_sends,
    SUM(emails_sent)                                                AS total_sent,
    SUM(emails_delivered)                                           AS total_delivered,
    SUM(opens)                                                      AS total_opens,
    SUM(clicks)                                                     AS total_clicks,
    ROUND(100.0 * SUM(opens)   / NULLIF(SUM(emails_delivered), 0), 2) AS avg_open_rate_pct,
    ROUND(100.0 * SUM(clicks)  / NULLIF(SUM(emails_delivered), 0), 2) AS avg_ctr_pct,
    ROUND(100.0 * SUM(bounces) / NULLIF(SUM(emails_sent),      0), 2) AS avg_bounce_rate_pct
FROM email_campaigns
GROUP BY segment
ORDER BY avg_ctr_pct DESC;

-- ------------------------------------------------------------
-- QUERY 3: Campaign Trend Over Time
-- Month-over-month email engagement trends
-- ------------------------------------------------------------
SELECT
    strftime('%Y-%m', send_date)                                         AS send_month,
    SUM(emails_sent)                                                     AS total_sent,
    ROUND(100.0 * SUM(opens)  / NULLIF(SUM(emails_delivered), 0), 2)   AS monthly_open_rate_pct,
    ROUND(100.0 * SUM(clicks) / NULLIF(SUM(emails_delivered), 0), 2)   AS monthly_ctr_pct
FROM email_campaigns
GROUP BY send_month
ORDER BY send_month;

-- ------------------------------------------------------------
-- QUERY 4: A/B Wave Comparison for SaaS Campaign (C001)
-- Compare performance across campaign waves for same audience
-- ------------------------------------------------------------
SELECT
    campaign_name,
    send_date,
    emails_sent,
    ROUND(100.0 * opens  / NULLIF(emails_delivered, 0), 2) AS open_rate_pct,
    ROUND(100.0 * clicks / NULLIF(emails_delivered, 0), 2) AS ctr_pct,

    -- Compare each wave's CTR vs the first wave (baseline)
    ROUND(
        100.0 * clicks / NULLIF(emails_delivered, 0)
        - FIRST_VALUE(100.0 * clicks / NULLIF(emails_delivered, 0))
            OVER (PARTITION BY campaign_id ORDER BY send_date)
    , 2) AS ctr_delta_vs_first_wave_pct

FROM email_campaigns
WHERE campaign_id = 'C001'
ORDER BY send_date;
