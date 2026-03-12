-- models/marts/logistics/fct_deliveries.sql

{{
    config(
        materialized='incremental',
        unique_key='delivery_id'
    )
}}

with deliveries as (
    select * from {{ ref('stg_deliveries') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

couriers as (
    select * from {{ ref('stg_couriers') }}
),

delivery_metrics as (
    select
        d.delivery_id,
        d.order_id,
        d.courier_id,
        o.customer_id,
        
        -- Timestamps
        o.created_at as order_created_at,
        o.prepared_at,
        d.picked_up_at,
        d.delivered_at,
        
        -- Status and Financials
        o.status as order_status,
        d.delivery_fee,
        d.customer_rating,

        -- Calculated Metrics (Time in minutes)
        timestampdiff(minute, o.created_at, o.prepared_at) as preparation_time_mins,
        timestampdiff(minute, o.prepared_at, d.picked_up_at) as wait_for_courier_mins,
        timestampdiff(minute, d.picked_up_at, d.delivered_at) as transit_time_mins,
        timestampdiff(minute, o.created_at, d.delivered_at) as total_delivery_time_mins,
        
        -- SLAs
        case 
            when timestampdiff(minute, o.created_at, d.delivered_at) <= 60 then true 
            else false 
        end as is_met_sla

    from deliveries d
    left join orders o on d.order_id = o.order_id
)

select * from delivery_metrics
