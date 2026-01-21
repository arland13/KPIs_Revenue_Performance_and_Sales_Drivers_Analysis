-- MoM revenue and growth

WITH monthly_revenue AS (
  SELECT
    DATE_TRUNC(DATE(o.created_at), MONTH) AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(oi.id) AS total_items_sold,
    SUM(oi.sale_price) AS revenue
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status = 'Complete'
    AND o.created_at IS NOT NULL
    AND oi.sale_price IS NOT NULL
    AND oi.sale_price >= 0
  /*o.created_at and oi.sale_price is validated as non-null, and oi.sale_price is validated
    >=0, but we kept is as defensive filter 
  */
  GROUP BY month
)

SELECT
  FORMAT_DATE('%Y-%m', month) AS year_month,
  total_orders,
  total_items_sold,
  ROUND(revenue, 2) AS monthly_revenue,
  ROUND(
    (revenue - LAG(revenue) OVER (ORDER BY month))
    / NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100,
    2
  ) AS mom_growth_percent
FROM monthly_revenue
ORDER BY month;

-- Monthly AOV

WITH order_revenue AS (
SELECT
  o.order_id,
  DATE_TRUNC(DATE(o.created_at), MONTH) AS order_month,
  SUM(oi.sale_price) AS order_revenue
FROM `bigquery-public-data.thelook_ecommerce.orders` o
JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
  ON o.order_id = oi.order_id
WHERE o.status = 'Complete'
  AND o.created_at IS NOT NULL
  AND oi.sale_price IS NOT NULL
  AND oi.sale_price >= 0
/*o.created_at and oi.sale_price is validated as non-null, and oi.sale_price is validated
>=0, but we kept is as defensive filter 
*/
GROUP BY o.order_id, order_month
)

SELECT
  FORMAT_DATE('%Y-%m', order_month) AS year_month,
  COUNT(order_id) AS total_orders,
  ROUND(SUM(order_revenue), 2) AS monthly_revenue,
  ROUND(AVG(order_revenue), 2) AS avg_order_value
FROM order_revenue orv
GROUP BY year_month
ORDER BY year_month;

-- Monthly items per order

WITH order_items_count AS (
  SELECT
    o.order_id,
    DATE_TRUNC(DATE(o.created_at), MONTH) AS order_month,
    COUNT(oi.id) AS items_in_order
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status = 'Complete'
    AND o.created_at IS NOT NULL
  GROUP BY o.order_id, order_month
)

SELECT
  FORMAT_DATE('%Y-%m', order_month) AS year_month,
  COUNT(order_id) AS total_orders,
  SUM(items_in_order) AS total_items_sold,
  ROUND(AVG(items_in_order), 2) AS avg_items_per_order
FROM order_items_count
GROUP BY year_month
ORDER BY year_month;

-- Customer level KPI (LTV Lite)

WITH customer_orders AS (
  SELECT
    o.user_id,
    o.order_id,
    DATE(o.created_at) AS order_date,
    SUM(oi.sale_price) AS order_revenue,
    COUNT(oi.id) AS items_in_order
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status = 'Complete'
    AND o.created_at IS NOT NULL
    AND oi.sale_price IS NOT NULL
    AND oi.sale_price >= 0
  GROUP BY o.user_id, o.order_id, order_date
)

SELECT
  user_id,

  COUNT(order_id) AS total_orders,
  ROUND(SUM(order_revenue), 2) AS lifetime_revenue,
  ROUND(AVG(order_revenue), 2) AS avg_order_value,
  ROUND(AVG(items_in_order), 2) AS avg_items_per_order,

  MIN(order_date) AS first_order_date,
  MAX(order_date) AS last_order_date,
  DATE_DIFF(MAX(order_date), MIN(order_date), DAY) AS customer_lifespan_days

FROM customer_orders
GROUP BY user_id
ORDER BY lifetime_revenue DESC;

-- Top products by revenue

SELECT
  p.id AS product_id,
  p.name AS product_name,
  p.category,
  p.brand,
  p.department,

  COUNT(DISTINCT oi.order_id) AS total_orders,
  COUNT(oi.id) AS total_items_sold,
  ROUND(SUM(oi.sale_price), 2) AS total_revenue

FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.orders` o
  ON oi.order_id = o.order_id
JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.id

WHERE o.status = 'Complete'
  AND oi.sale_price IS NOT NULL
  AND oi.sale_price >= 0

GROUP BY
  product_id,
  product_name,
  category,
  brand,
  department

ORDER BY total_revenue DESC
LIMIT 20;

-- Top category by revenue

SELECT
  p.category,

  COUNT(DISTINCT oi.order_id) AS total_orders,
  COUNT(oi.id) AS total_items_sold,
  ROUND(SUM(oi.sale_price), 2) AS total_revenue

FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.orders` o
  ON oi.order_id = o.order_id
JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.id

WHERE o.status = 'Complete'
  AND oi.sale_price IS NOT NULL
  AND oi.sale_price >= 0
  AND p.category IS NOT NULL

GROUP BY p.category
ORDER BY total_revenue DESC;

-- category pareto

WITH category_revenue AS (
  SELECT
    p.category,
    SUM(oi.sale_price) AS category_revenue
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.orders` o
    ON oi.order_id = o.order_id
  JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON oi.product_id = p.id
  WHERE o.status = 'Complete'
    AND oi.sale_price IS NOT NULL
    AND oi.sale_price >= 0
    AND p.category IS NOT NULL
  GROUP BY p.category
),

pareto AS (
  SELECT
    category,
    category_revenue,
    SUM(category_revenue) OVER () AS total_revenue,
    SUM(category_revenue) OVER (
      ORDER BY category_revenue DESC
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
  FROM category_revenue crv
)

SELECT
  category,
  ROUND(category_revenue, 2) AS category_revenue,
  ROUND(cumulative_revenue, 2) AS cumulative_revenue,
  ROUND(cumulative_revenue / total_revenue * 100, 2) AS cumulative_revenue_pct,
  CASE
    WHEN cumulative_revenue / total_revenue <= 0.8 THEN 'Top 80%'
    ELSE 'Bottom 20%'
  END AS pareto_segment
FROM pareto
ORDER BY category_revenue DESC;













