{{ config(materialized='incremental', unique_key='referral_hk', incremental_strategy='merge') }}
with source_data as (
    select referral_hk, referral_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__referrals') }}
    union all
select referral_hk, referral_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__referrals') }}
), deduped as (
 select * from source_data where referral_hk is not null and referral_bk is not null
 qualify row_number() over(partition by referral_hk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where referral_hk not in (select referral_hk from {{ this }})
{% endif %}
