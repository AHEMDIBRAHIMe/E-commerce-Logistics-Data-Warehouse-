-- 1. ما هي أكثر المناطق تأخراً في التوصيل (متوسط وقت التوصيل وتجاوزات الـ SLA)؟
SELECT 
    c.region,
    COUNT(f.delivery_id) as total_deliveries,
    AVG(f.total_delivery_time_mins) as avg_delivery_time_mins,
    SUM(CASE WHEN f.is_met_sla = false THEN 1 ELSE 0 END) as missed_sla_count,
    ROUND(SUM(CASE WHEN f.is_met_sla = false THEN 1 ELSE 0 END) * 100.0 / COUNT(f.delivery_id), 2) as missed_sla_percentage
FROM fct_deliveries f
JOIN fct_orders o ON f.order_id = o.order_id
JOIN dim_customers c ON o.customer_id = c.customer_id
WHERE f.order_status = 'Delivered'
GROUP BY 1
ORDER BY missed_sla_percentage DESC;

-- =========================================================================

-- 2. تحليل أوقات الذروة للطلبات وتأثيرها على وقت التوصيل (Peak Hours Analysis)
SELECT 
    o.order_hour_of_day,
    COUNT(o.order_id) as total_orders,
    AVG(f.wait_for_courier_mins) as avg_courier_wait_time,
    AVG(f.transit_time_mins) as avg_transit_time,
    AVG(f.total_delivery_time_mins) as avg_total_time
FROM fct_orders o
LEFT JOIN fct_deliveries f ON o.order_id = f.order_id
WHERE o.status = 'Delivered'
GROUP BY 1
ORDER BY o.order_hour_of_day;

-- =========================================================================

-- 3. أفضل وأسوأ المناديب أداءً بناءً على تقييم العملاء ونسبة نجاح التوصيل
WITH courier_stats AS (
    SELECT 
        c.name as courier_name,
        COUNT(f.delivery_id) as total_assigned,
        SUM(CASE WHEN f.order_status = 'Delivered' THEN 1 ELSE 0 END) as successful_deliveries,
        AVG(f.customer_rating) as avg_rating,
        AVG(f.total_delivery_time_mins) as avg_delivery_time
    FROM fct_deliveries f
    JOIN dim_couriers c ON f.courier_id = c.courier_id
    GROUP BY 1
    HAVING COUNT(f.delivery_id) > 50 -- لضمان وجود بيانات كافية للتقييم
)
SELECT 
    courier_name,
    total_assigned,
    ROUND(successful_deliveries * 100.0 / total_assigned, 2) as success_rate_pct,
    ROUND(avg_rating, 2) as avg_rating,
    ROUND(avg_delivery_time, 2) as avg_delivery_time
FROM courier_stats
ORDER BY avg_rating DESC, success_rate_pct DESC
LIMIT 10; -- الـ 10 الأوائل (Best 10)

-- =========================================================================

-- 4. تحديد الاختناقات اللوجستية (Bottlenecks) في العملية
-- هل التأخير من المطعم (التحضير) أم من المندوب (الانتظار والانتقال)؟
SELECT
    DATE_TRUNC('month', f.order_created_at) as delivery_month,
    AVG(f.preparation_time_mins) as avg_prep_time,
    AVG(f.wait_for_courier_mins) as avg_wait_time,
    AVG(f.transit_time_mins) as avg_transit_time
FROM fct_deliveries f
WHERE f.order_status = 'Delivered'
GROUP BY 1
ORDER BY 1;
