{{ config(materialized='incremental', unique_key='client_referral_lk', incremental_strategy='merge') }}
with source_data as (
    select client_referral_lk, client_hk, referral_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__referrals') }}
    union all
select client_referral_lk, client_hk, referral_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__referrals') }}
), deduped as (
 select * from source_data where client_referral_lk is not null and client_hk is not null and referral_hk is not null
 qualify row_number() over(partition by client_referral_lk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where client_referral_lk not in (select client_referral_lk from {{ this }})
{% endif %}
