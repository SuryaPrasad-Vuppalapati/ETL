select 
    *
from
    {{ ref('fct_orders') }}
where total_discount_amount > 0
order by order_date