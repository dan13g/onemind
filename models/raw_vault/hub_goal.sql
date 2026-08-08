{{ config(materialized='incremental', unique_key='goal_hk', incremental_strategy='merge') }}
with source_data as (
    select goal_hk, goal_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__care_plan_goals') }}
    union all
select goal_hk, goal_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__care_plan_goals') }}
), deduped as (
 select * from source_data where goal_hk is not null and goal_bk is not null
 qualify row_number() over(partition by goal_hk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where goal_hk not in (select goal_hk from {{ this }})
{% endif %}
