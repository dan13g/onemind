{{ config(materialized='incremental', unique_key='referral_service_lk', incremental_strategy='merge') }}
with source_data as (
    select referral_service_lk, referral_hk, service_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__referrals') }}
    union all
select referral_service_lk, referral_hk, service_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__referrals') }}
), deduped as (
 select * from source_data where referral_service_lk is not null and referral_hk is not null and service_hk is not null
 qualify row_number() over(partition by referral_service_lk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where referral_service_lk not in (select referral_service_lk from {{ this }})
{% endif %}
