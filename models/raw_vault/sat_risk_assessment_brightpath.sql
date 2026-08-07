{{ config(materialized='incremental', unique_key='risk_satellite_pk', incremental_strategy='merge') }}
with source_data as (
 select sha2(risk_assessment_hk||'|'||risk_assessment_hashdiff||'|'||coalesce(source_updated_at::varchar,''),256) as risk_satellite_pk,
        risk_assessment_hk, risk_assessment_hashdiff as hashdiff, current_timestamp()::timestamp_ntz as load_datetime, record_source, source_created_at, source_updated_at,
        assessed_at,
        risk_domain,
        risk_level,
        escalation_required
 from {{ ref('stg_brightpath__risk_assessments') }}
), current_satellite as (
 {% if is_incremental() %} select risk_assessment_hk, hashdiff from {{ this }} qualify row_number() over(partition by risk_assessment_hk order by load_datetime desc)=1 {% else %} select null risk_assessment_hk, null hashdiff where 1=0 {% endif %}
)
select s.* from source_data s left join current_satellite c on s.risk_assessment_hk=c.risk_assessment_hk
where c.risk_assessment_hk is null or s.hashdiff<>c.hashdiff
