
-- ------------------------------------------------------------
-- Drop tables if re-running (safe teardown)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS funnel_events;
DROP TABLE IF EXISTS email_campaigns;
DROP TABLE IF EXISTS leads;

-- ------------------------------------------------------------
-- Table 1: leads
-- Tracks every incoming lead with source and metadata
-- ------------------------------------------------------------
CREATE TABLE leads (
    lead_id       INTEGER PRIMARY KEY,
    created_date  DATE NOT NULL,
    source        VARCHAR(50),        -- organic_search, paid_search, email, social_media, referral
    campaign_id   VARCHAR(10),
    country       VARCHAR(50),
    industry      VARCHAR(50)
);

-- ------------------------------------------------------------
-- Table 2: funnel_events
-- Tracks each lead's progression through the funnel stages:
-- lead → mql → sql → opportunity → closed_won / closed_lost
-- ------------------------------------------------------------
CREATE TABLE funnel_events (
    event_id    INTEGER PRIMARY KEY,
    lead_id     INTEGER REFERENCES leads(lead_id),
    event_type  VARCHAR(20),   -- mql, sql, opportunity, closed_won, closed_lost
    event_date  DATE NOT NULL,
    notes       TEXT
);

-- ------------------------------------------------------------
-- Table 3: email_campaigns
-- Tracks email campaign-level performance metrics
-- ------------------------------------------------------------
CREATE TABLE email_campaigns (
    campaign_id    VARCHAR(10),
    campaign_name  VARCHAR(100),
    send_date      DATE,
    segment        VARCHAR(50),
    emails_sent    INTEGER,
    emails_delivered INTEGER,
    opens          INTEGER,
    clicks         INTEGER,
    unsubscribes   INTEGER,
    bounces        INTEGER
);

-- ------------------------------------------------------------
-- Sample Data: leads
-- ------------------------------------------------------------
INSERT INTO leads VALUES
(1,'2024-01-03','organic_search','C001','India','SaaS'),
(2,'2024-01-05','paid_search','C002','India','Ecommerce'),
(3,'2024-01-06','email','C003','USA','SaaS'),
(4,'2024-01-07','social_media','C001','India','FinTech'),
(5,'2024-01-08','organic_search','C002','India','SaaS'),
(6,'2024-01-09','referral','C003','UK','Ecommerce'),
(7,'2024-01-10','paid_search','C001','India','SaaS'),
(8,'2024-01-11','email','C002','India','FinTech'),
(9,'2024-01-12','social_media','C003','USA','SaaS'),
(10,'2024-01-13','organic_search','C001','India','Ecommerce'),
(11,'2024-01-15','paid_search','C002','India','SaaS'),
(12,'2024-01-16','email','C003','India','SaaS'),
(13,'2024-01-17','referral','C001','UK','FinTech'),
(14,'2024-01-18','organic_search','C002','India','Ecommerce'),
(15,'2024-01-20','social_media','C003','India','SaaS'),
(16,'2024-02-01','paid_search','C001','India','SaaS'),
(17,'2024-02-03','email','C002','India','Ecommerce'),
(18,'2024-02-04','organic_search','C003','USA','FinTech'),
(19,'2024-02-06','social_media','C001','India','SaaS'),
(20,'2024-02-07','referral','C002','India','Ecommerce'),
(21,'2024-02-08','paid_search','C003','India','SaaS'),
(22,'2024-02-10','email','C001','UK','FinTech'),
(23,'2024-02-11','organic_search','C002','India','SaaS'),
(24,'2024-02-12','social_media','C003','India','Ecommerce'),
(25,'2024-02-14','referral','C001','India','SaaS'),
(26,'2024-03-01','paid_search','C002','India','SaaS'),
(27,'2024-03-03','email','C003','India','Ecommerce'),
(28,'2024-03-05','organic_search','C001','USA','SaaS'),
(29,'2024-03-06','social_media','C002','India','FinTech'),
(30,'2024-03-08','referral','C003','India','SaaS');

-- ------------------------------------------------------------
-- Sample Data: funnel_events
-- ------------------------------------------------------------
INSERT INTO funnel_events VALUES
(1,1,'mql','2024-01-05','Downloaded whitepaper'),
(2,1,'sql','2024-01-10','Sales qualified after demo'),
(3,1,'opportunity','2024-01-15','Proposal sent'),
(4,1,'closed_won','2024-02-01','Deal closed'),
(5,2,'mql','2024-01-08','Signed up for trial'),
(6,2,'sql','2024-01-14','Sales follow-up done'),
(7,2,'opportunity','2024-01-20','In negotiation'),
(8,3,'mql','2024-01-10','Webinar attendee'),
(9,4,'mql','2024-01-12','Clicked email CTA'),
(10,4,'sql','2024-01-18','Qualified by BDR'),
(11,5,'mql','2024-01-14','Downloaded case study'),
(12,6,'mql','2024-01-15','Referral contact'),
(13,6,'sql','2024-01-20','Demo scheduled'),
(14,6,'opportunity','2024-01-28','Proposal sent'),
(15,6,'closed_won','2024-02-15','Deal closed'),
(16,7,'mql','2024-01-16','Paid search signup'),
(17,7,'sql','2024-01-22','Sales called'),
(18,7,'opportunity','2024-01-30','In review'),
(19,7,'closed_lost','2024-02-10','Budget issue'),
(20,8,'mql','2024-01-18','Email campaign click'),
(21,9,'mql','2024-01-20','Free trial started'),
(22,9,'sql','2024-01-26','Upsell opportunity'),
(23,10,'mql','2024-01-22','Organic search landing'),
(24,11,'mql','2024-01-28','Paid ad click'),
(25,11,'sql','2024-02-05','Discovery call done'),
(26,11,'opportunity','2024-02-12','Negotiating contract'),
(27,11,'closed_won','2024-03-01','Deal closed'),
(28,12,'mql','2024-01-30','Email drip response'),
(29,13,'mql','2024-02-02','Referral demo request'),
(30,13,'sql','2024-02-08','Technical evaluation'),
(31,13,'opportunity','2024-02-16','Final proposal'),
(32,14,'mql','2024-02-05','SEO landing page'),
(33,15,'mql','2024-02-08','Social ad click'),
(34,15,'sql','2024-02-14','Interest confirmed'),
(35,16,'mql','2024-02-10','Paid search'),
(36,16,'sql','2024-02-16','Qualified lead'),
(37,16,'opportunity','2024-02-22','Sent pricing'),
(38,16,'closed_won','2024-03-10','Contract signed'),
(39,17,'mql','2024-02-12','Email click'),
(40,18,'mql','2024-02-15','Organic traffic'),
(41,19,'mql','2024-02-16','Social engagement'),
(42,19,'sql','2024-02-22','Sales outreach'),
(43,20,'mql','2024-02-18','Referral signup'),
(44,20,'sql','2024-02-25','Demo completed'),
(45,20,'opportunity','2024-03-02','Evaluation stage'),
(46,21,'mql','2024-02-20','Paid ad signup'),
(47,22,'mql','2024-02-22','Email response'),
(48,23,'mql','2024-02-24','Organic blog'),
(49,24,'mql','2024-02-26','Social media ad'),
(50,25,'mql','2024-02-28','Referral contact'),
(51,25,'sql','2024-03-05','Call scheduled'),
(52,26,'mql','2024-03-05','Paid search'),
(53,27,'mql','2024-03-07','Email campaign'),
(54,28,'mql','2024-03-09','Organic search'),
(55,28,'sql','2024-03-15','Qualified'),
(56,28,'opportunity','2024-03-20','Proposal submitted'),
(57,29,'mql','2024-03-10','Social media'),
(58,30,'mql','2024-03-12','Referral');

-- ------------------------------------------------------------
-- Sample Data: email_campaigns
-- ------------------------------------------------------------
INSERT INTO email_campaigns VALUES
('C001','Q1 SaaS Nurture - Wave 1','2024-01-05','SaaS Leads',1200,1152,345,98,12,48),
('C002','Q1 Ecommerce Promo','2024-01-12','Ecommerce Leads',850,816,220,64,8,34),
('C003','Q1 FinTech Awareness','2024-01-19','FinTech Leads',600,582,189,52,5,18),
('C001','Q1 SaaS Nurture - Wave 2','2024-02-05','SaaS Leads',1100,1067,312,88,10,33),
('C002','Q1 Ecommerce Re-engage','2024-02-12','Ecommerce Leads',780,749,198,55,9,31),
('C003','Q1 FinTech Product Update','2024-02-19','FinTech Leads',550,528,176,48,4,22),
('C001','Q1 SaaS Nurture - Wave 3','2024-03-05','SaaS Leads',980,950,289,80,7,30),
('C002','Q1 Ecommerce Flash Sale','2024-03-12','Ecommerce Leads',920,895,310,110,11,25),
('C003','Q1 FinTech Case Study','2024-03-19','FinTech Leads',480,465,155,42,3,15);
