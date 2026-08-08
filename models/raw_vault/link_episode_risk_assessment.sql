{{ config(materialized='incremental', unique_key='episode_risk_assessment_lk', incremental_strategy='merge') }}
with source_data as (
    select episode_risk_assessment_lk, episode_hk, risk_assessment_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__risk_assessments') }}
    union all
select episode_risk_assessment_lk, episode_hk, risk_assessment_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__risk_assessments') }}
), deduped as (
 select * from source_data where episode_risk_assessment_lk is not null and episode_hk is not null and risk_assessment_hk is not null
 qualify row_number() over(partition by episode_risk_assessment_lk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where episode_risk_assessment_lk not in (select episode_risk_assessment_lk from {{ this }})
{% endif %}
