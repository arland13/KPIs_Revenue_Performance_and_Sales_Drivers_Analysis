# KPIs Revenue Performance and Sales Drivers Analysis
Dataset: Google BigQuery – The Look E-commerce
Role: Data Analyst
Tools: Google BigQuery (SQL), Looker Studio (Visualization – (next commit))

## Project Overview

This project analyzes revenue performance and sales drivers in an e-commerce business using Google BigQuery’s public The Look E-commerce dataset.

The goal is to:
- Validate data integrity before analysis
- Build reliable revenue KPIs
- Identify revenue trends, top products, categories, and customer value
- Demonstrate real-world SQL practices used by professional data analysts

The full SQL cleaning script is available in:
- data validation -> `ecommerce_data_validation.sql`
- KPIs analysis -> `KPIs analysis.sql`

Visual Dashboard is available in:
https://lookerstudio.google.com/reporting/7d503508-5f28-4728-9163-90c4da84e002

## Dataset Description

The analysis uses the following tables from
bigquery-public-data.thelook_ecommerce:
- orders — order-level transactions and statuses
- order_items — item-level sales and pricing
- products — product attributes (category, brand, cost, price)

Only completed orders are considered revenue-generating events.

## Data Validation & Quality Checks

Before calculating KPIs, multiple data validation checks were performed to ensure accuracy and analytical reliability:

### Key Validation Steps

- Order status distribution check (to justify filtering status = 'Complete')
- Null checks on created_at (time-series integrity)
- Invalid pricing detection (NULL or negative sale_price)
- Orders without order items (should be zero)
- Product primary key uniqueness validation
- Business logic validation (retail_price < cost)
- Join coverage check between order_items and products

These checks confirm that:
- Revenue calculations are based on valid transactions
- Time-based aggregations are reliable
- Table relationships are intact

Defensive filters are still applied in KPI queries as a best practice, even after validation.

## Key Performance Indicators (KPIs)

### 1. Monthly Revenue & MoM Growth

Purpose:
Track overall business performance and growth trends over time.

Metrics:
- Total orders
- Total items sold
- Monthly revenue
- Month-over-Month (MoM) revenue growth %
Note: The first month has NULL MoM growth by design due to the absence of a prior period.

### 2. Average Order Value (AOV)
Purpose:
Measure customer spending behavior per transaction.

Methodology:
- Calculate revenue at the order level
- Aggregate monthly averages to avoid distorted results

### 3. Average Items per Order
Purpose:
Understand purchasing patterns and basket size.

Metrics:
- Total items sold
- Average items per order (monthly)

### 4. Customer-Level KPIs (LTV Lite)
Purpose:
Analyze customer value and engagement over time.

Metrics:
- Total orders per customer
- Lifetime revenue
- Average order value
- Average items per order
- First & last order dates
- Customer lifespan (days)
- This provides a simplified Lifetime Value (LTV) perspective suitable for exploratory analysis.

### 5. Top Products by Revenue
Purpose:
Identify best-performing products and revenue drivers.

Metrics:
- Total orders per product
- Total items sold
- Total revenue

Grouped by:
- Product
- Category
- Brand
- Department

### 6. Category Revenue Analysis
Purpose:
Understand which product categories contribute most to revenue.

### 7. Pareto Analysis (80/20 Rule)
Purpose:
Determine which product categories generate the majority of revenue.

Method:
- Rank categories by revenue
- Calculate cumulative revenue contribution
- Segment into:
    - Top 80% revenue contributors
    - Bottom 20%

This helps prioritize categories with the highest business impact.

## Key Insights (Summary)
- Revenue is concentrated in a limited number of product categories (Pareto effect observed)
- Customer spending behavior varies significantly across time
- A small set of products and categories drive a disproportionate share of total revenue
- Average order value and basket size provide meaningful context beyond raw revenue

(Detailed insights and recommendations can be added alongside dashboards -> (next commit).)

## Tools & Skills Demonstrated
- Advanced SQL (CTEs, window functions, defensive filtering)
- Data validation & integrity checks
- Revenue and customer analytics
- Business-oriented KPI design
- Analytical thinking aligned with real-world scenarios

## Visualization
This project can be visualized using Looker Studio on the next commit to present:
- Revenue trend & MoM growth
- Top products and categories
- Pareto (80/20) revenue chart
- AOV and basket size trends

## Conclusion
This project demonstrates an end-to-end analytical workflow:
- Validate raw data
- Build reliable KPIs
- Analyze revenue performance
- Extract business-relevant insights

The approach reflects industry best practices used by data analysts in real business environments.
