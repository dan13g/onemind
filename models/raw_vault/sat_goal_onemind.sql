{{ config(materialized='incremental', unique_key='goal_satellite_pk', incremental_strategy='merge') }}
with source_data as (
 select sha2(goal_hk||'|'||goal_hashdiff||'|'||coalesce(source_updated_at::varchar,''),256) as goal_satellite_pk,
        goal_hk, goal_hashdiff as hashdiff, current_timestamp()::timestamp_ntz as load_datetime, record_source, source_created_at, source_updated_at,
        goal_description,
        goal_status,
        target_date,
        review_date
 from {{ ref('stg_onemind__care_plan_goals') }}
), current_satellite as (
 {% if is_incremental() %} select goal_hk, hashdiff from {{ this }} qualify row_number() over(partition by goal_hk order by load_datetime desc)=1 {% else %} select null goal_hk, null hashdiff where 1=0 {% endif %}
)
select s.* from source_data s left join current_satellite c on s.goal_hk=c.goal_hk
where c.goal_hk is null or s.hashdiff<>c.hashdiff
