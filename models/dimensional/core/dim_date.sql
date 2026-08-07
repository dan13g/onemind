{{ config(materialized='table') }}
with d as (
 select dateadd(day,seq4(),'2020-01-01'::date) date_day from table(generator(rowcount=>7305))
)
select to_number(to_char(date_day,'YYYYMMDD')) date_key, date_day,
       year(date_day) calendar_year, quarter(date_day) calendar_quarter,
       month(date_day) month_number, monthname(date_day) month_name,
       dayofweekiso(date_day) day_of_week_number, dayname(date_day) day_name,
       iff(dayofweekiso(date_day) in (6,7),true,false) is_weekend
from d
