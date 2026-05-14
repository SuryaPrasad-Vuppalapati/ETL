select
    orders.*,
    order_summary.gross_items_sales_amount,
    order_summary.total_discount_amount,
from
    {{ ref('stg_tpch_orders') }} as orders
join {{ ref('int_order_summary') }} as order_summary
    on orders.order_key = order_summary.order_key
order by orders.order_date