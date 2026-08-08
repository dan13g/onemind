{{ config(materialized='incremental', unique_key='episode_satellite_pk', incremental_strategy='merge') }}
with source_data as (
 select sha2(episode_hk||'|'||episode_hashdiff||'|'||coalesce(source_updated_at::varchar,''),256) as episode_satellite_pk,
        episode_hk, episode_hashdiff as hashdiff, current_timestamp()::timestamp_ntz as load_datetime, record_source, source_created_at, source_updated_at,
        episode_start_date,
        episode_end_date,
        primary_problem,
        provisional_diagnosis,
        care_pathway,
        discharge_reason,
        outcome_status
 from {{ ref('stg_onemind__episodes') }}
), current_satellite as (
 {% if is_incremental() %} select episode_hk, hashdiff from {{ this }} qualify row_number() over(partition by episode_hk order by load_datetime desc)=1 {% else %} select null episode_hk, null hashdiff where 1=0 {% endif %}
)
select s.* from source_data s left join current_satellite c on s.episode_hk=c.episode_hk
where c.episode_hk is null or s.hashdiff<>c.hashdiff
