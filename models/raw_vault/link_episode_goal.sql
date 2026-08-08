{{ config(materialized='incremental', unique_key='episode_goal_lk', incremental_strategy='merge') }}
with source_data as (
    select episode_goal_lk, episode_hk, goal_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__care_plan_goals') }}
    union all
select episode_goal_lk, episode_hk, goal_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__care_plan_goals') }}
), deduped as (
 select * from source_data where episode_goal_lk is not null and episode_hk is not null and goal_hk is not null
 qualify row_number() over(partition by episode_goal_lk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where episode_goal_lk not in (select episode_goal_lk from {{ this }})
{% endif %}
