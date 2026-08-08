{{ config(materialized='incremental', unique_key='assessment_clinician_lk', incremental_strategy='merge') }}
with source_data as (
    select assessment_clinician_lk, assessment_hk, clinician_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__assessments') }}
), deduped as (
 select * from source_data where assessment_clinician_lk is not null and assessment_hk is not null and clinician_hk is not null
 qualify row_number() over(partition by assessment_clinician_lk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where assessment_clinician_lk not in (select assessment_clinician_lk from {{ this }})
{% endif %}
