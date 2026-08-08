{{ config(materialized='incremental', unique_key='assessment_hk', incremental_strategy='merge') }}
with source_data as (
    select assessment_hk, assessment_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__assessments') }}
), deduped as (
 select * from source_data where assessment_hk is not null and assessment_bk is not null
 qualify row_number() over(partition by assessment_hk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where assessment_hk not in (select assessment_hk from {{ this }})
{% endif %}
