# End-to-End-Marketing-Funnel-Analysis

## 🧠 Project Summary

This project demonstrates how SQL can be used to monitor and optimize a full B2B marketing funnel — from the moment a lead is captured to deal close. It covers the five analytical pillars most relevant to Marketing Analyst roles:

| # | Analysis Area | File |
|---|--------------|------|
| 1 | Schema & Sample Data |
| 2 | Funnel Stage Conversion |
| 3 | Email Campaign Performance |
| 4 | Lead Velocity & Time-in-Stage |
| 5 | Cohort Analysis |
| 6 | Channel Attribution & ROI |

---

## 🗂️ Project Structure

```
marketing-funnel-analysis/
├── README.md
├── data/
│   ├── leads.csv                    # Raw lead records
│   ├── funnel_events.csv            # Stage progression events
│   └── email_campaigns.csv          # Campaign send + engagement data
├── sql/
│   ├── 01_schema_and_data.sql       # Table creation + data inserts
│   ├── 02_funnel_stage_analysis.sql # Funnel conversion queries
│   ├── 03_email_campaign_performance.sql
│   ├── 04_lead_velocity_and_time_in_stage.sql
│   ├── 05_cohort_analysis.sql
│   └── 06_channel_attribution_and_roi.sql
└── insights/
    └── key_insights.md              # Business findings & recommendations
```

---

## 📐 Data Model

```
leads
------
lead_id (PK)
created_date
source             -- organic_search | paid_search | email | social_media | referral
campaign_id        -- FK to email_campaigns
country
industry

funnel_events
-------------
event_id (PK)
lead_id (FK → leads)
event_type         -- mql | sql | opportunity | closed_won | closed_lost
event_date
notes

email_campaigns
---------------
campaign_id
campaign_name
send_date
segment
emails_sent / emails_delivered / opens / clicks / unsubscribes / bounces
```

---

## 📈 Key SQL Techniques Used

| Technique | Where Used |
|-----------|-----------|
| **CTEs** (`WITH` clauses) | All analysis files — layered logic, readable structure |
| **Conditional Aggregation** | Funnel counts using `CASE WHEN event_type = 'x' THEN lead_id END` |
| **Window Functions** | `FIRST_VALUE() OVER (PARTITION BY ... ORDER BY ...)` in campaign wave comparison |
| **Date Arithmetic** | `JULIANDAY()` for stage velocity and sales cycle duration |
| **NULLIF** | Safe division throughout — avoids divide-by-zero errors |
| **LEFT JOIN** | Preserves all leads even if they haven't progressed through funnel |
| **Subqueries / Derived Tables** | Cohort and attribution analyses |

---

## 📊 Business Metrics Covered

- **Lead-to-MQL Rate** — Marketing qualification efficiency
- **MQL-to-SQL Rate** — Sales acceptance quality
- **SQL-to-Win Rate** — Revenue conversion
- **Email Open Rate / CTR / CTOR / Bounce Rate / Unsubscribe Rate**
- **Average Sales Cycle Duration** (by stage transition)
- **Stalled Lead Detection** — Leads with no activity > 14 days
- **Cohort Win Rates** — Monthly cohort tracking
- **Channel Attribution** — Source × Campaign win rate analysis

---

## 💡 Key Business Findings

- **Referral leads** convert at 2× the rate of organic search leads
- Biggest funnel drop-off is at **MQL → SQL** (46% of MQLs are not sales-qualified)
- **FinTech segment** has the highest email engagement despite smallest send volume
- **SaaS nurture email waves** show engagement decay — content refresh recommended
- Several open opportunities are **stalled > 14 days** — flagged for re-engagement

---

## 👤 About

Built by **Ajith_Settu** — Marketing Analytics professional with 7+ years of experience in lead generation, campaign analytics, customer segmentation, A/B testing, and SQL-driven insights across B2B marketing environments.

**Tools:** SQL (MySQL,Oracle) · Excel · Power BI
