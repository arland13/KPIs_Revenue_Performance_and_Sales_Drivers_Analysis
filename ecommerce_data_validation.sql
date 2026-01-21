-- Check order status distribution
SELECT status, COUNT(*) total_rows
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY status;

-- Check null order dates
SELECT COUNT(*) AS null_created_at
FROM `bigquery-public-data.thelook_ecommerce.orders`
WHERE created_at IS NULL;

-- Check negative or null prices order_items (invalid price)
SELECT COUNT(*) AS invalid_price
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE sale_price IS NULL OR sale_price < 0;

-- Orders without items (should be zero)
SELECT COUNT(*) AS orders_without_items
FROM `bigquery-public-data.thelook_ecommerce.orders` o
LEFT JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;

-- Check product key integrity
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT id) AS total_unique_id
FROM `bigquery-public-data.thelook_ecommerce.products`;

-- Products with bad pricing
SELECT COUNT(*) AS bad_pricing_products 
FROM `bigquery-public-data.thelook_ecommerce.products`
WHERE retail_price < cost;

-- Check join coverage
SELECT 
  COUNT(*) AS order_items,
  COUNT(p.id) AS matched_products
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` p
ON oi.product_id = p.id;



