{{ config(materialized='incremental', unique_key='risk_assessment_hk', incremental_strategy='merge') }}
with source_data as (
    select risk_assessment_hk, risk_assessment_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__risk_assessments') }}
    union all
select risk_assessment_hk, risk_assessment_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__risk_assessments') }}
), deduped as (
 select * from source_data where risk_assessment_hk is not null and risk_assessment_bk is not null
 qualify row_number() over(partition by risk_assessment_hk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where risk_assessment_hk not in (select risk_assessment_hk from {{ this }})
{% endif %}
