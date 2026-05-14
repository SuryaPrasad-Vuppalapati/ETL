select 
    order_key,
    sum(extended_price) as total_extended_price,
    sum(items_discount_amount) as total_discount_amount,
    sum(extended_price - items_discount_amount) as gross_items_sales_amount

from {{ ref('int_orders_items') }}
group by order_key