{{ config(materialized='incremental', unique_key='referral_assessment_lk', incremental_strategy='merge') }}
with source_data as (
    select referral_assessment_lk, referral_hk, assessment_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__assessments') }}
), deduped as (
 select * from source_data where referral_assessment_lk is not null and referral_hk is not null and assessment_hk is not null
 qualify row_number() over(partition by referral_assessment_lk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where referral_assessment_lk not in (select referral_assessment_lk from {{ this }})
{% endif %}
