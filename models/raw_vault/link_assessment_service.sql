{{ config(materialized='incremental', unique_key='assessment_service_lk', incremental_strategy='merge') }}
with source_data as (
    select assessment_service_lk, assessment_hk, recommended_service_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__assessments') }}
), deduped as (
 select * from source_data where assessment_service_lk is not null and assessment_hk is not null and recommended_service_hk is not null
 qualify row_number() over(partition by assessment_service_lk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where assessment_service_lk not in (select assessment_service_lk from {{ this }})
{% endif %}
