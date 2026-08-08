{{ config(materialized='incremental', unique_key='assessment_satellite_pk', incremental_strategy='merge') }}
with source_data as (
 select sha2(assessment_hk||'|'||assessment_hashdiff||'|'||coalesce(source_updated_at::varchar,''),256) as assessment_satellite_pk,
        assessment_hk, assessment_hashdiff as hashdiff, current_timestamp()::timestamp_ntz as load_datetime, record_source, source_created_at, source_updated_at,
        assessment_at,
        assessment_type,
        clinical_summary,
        accepted_for_treatment
 from {{ ref('stg_onemind__assessments') }}
), current_satellite as (
 {% if is_incremental() %} select assessment_hk, hashdiff from {{ this }} qualify row_number() over(partition by assessment_hk order by load_datetime desc)=1 {% else %} select null assessment_hk, null hashdiff where 1=0 {% endif %}
)
select s.* from source_data s left join current_satellite c on s.assessment_hk=c.assessment_hk
where c.assessment_hk is null or s.hashdiff<>c.hashdiff
