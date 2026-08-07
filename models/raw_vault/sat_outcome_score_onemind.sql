{{ config(materialized='incremental', unique_key='outcome_satellite_pk', incremental_strategy='merge') }}
with source_data as (
 select sha2(outcome_score_hk||'|'||outcome_score_hashdiff||'|'||coalesce(source_updated_at::varchar,''),256) as outcome_satellite_pk,
        outcome_score_hk, outcome_score_hashdiff as hashdiff, current_timestamp()::timestamp_ntz as load_datetime, record_source, source_created_at, source_updated_at,
        measure_name,
        score_value,
        score_date
 from {{ ref('stg_onemind__outcome_scores') }}
), current_satellite as (
 {% if is_incremental() %} select outcome_score_hk, hashdiff from {{ this }} qualify row_number() over(partition by outcome_score_hk order by load_datetime desc)=1 {% else %} select null outcome_score_hk, null hashdiff where 1=0 {% endif %}
)
select s.* from source_data s left join current_satellite c on s.outcome_score_hk=c.outcome_score_hk
where c.outcome_score_hk is null or s.hashdiff<>c.hashdiff
