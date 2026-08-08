{{ config(materialized='incremental', unique_key='team_satellite_pk', incremental_strategy='merge') }}
with source_data as (
 select sha2(team_hk||'|'||team_hashdiff||'|'||coalesce(source_updated_at::varchar,''),256) as team_satellite_pk,
        team_hk, team_hashdiff as hashdiff, current_timestamp()::timestamp_ntz as load_datetime, record_source, source_created_at, source_updated_at,
        team_code,
        team_name,
        region,
        service_line,
        active_flag
 from {{ ref('stg_onemind__teams') }}
), current_satellite as (
 {% if is_incremental() %} select team_hk, hashdiff from {{ this }} qualify row_number() over(partition by team_hk order by load_datetime desc)=1 {% else %} select null team_hk, null hashdiff where 1=0 {% endif %}
)
select s.* from source_data s left join current_satellite c on s.team_hk=c.team_hk
where c.team_hk is null or s.hashdiff<>c.hashdiff
