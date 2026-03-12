-- models/marts/sales/fct_orders.sql

{{
    config(
        materialized='table'
    )
}}

with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
)

select
    o.order_id,
    c.customer_id,
    c.region,
    o.order_amount,
    o.status,
    o.created_at,
    
    -- Date dimensions for easy filtering
    date(o.created_at) as order_date,
    extract(hour from o.created_at) as order_hour_of_day,
    extract(dayofweek from o.created_at) as order_day_of_week

from orders o
left join customers c on o.customer_id = c.customer_id
