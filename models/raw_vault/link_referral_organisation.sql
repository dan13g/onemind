{{ config(materialized='incremental', unique_key='referral_organisation_lk', incremental_strategy='merge') }}
with source_data as (
    select referral_organisation_lk, referral_hk, referring_organisation_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__referrals') }}
), deduped as (
 select * from source_data where referral_organisation_lk is not null and referral_hk is not null and referring_organisation_hk is not null
 qualify row_number() over(partition by referral_organisation_lk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where referral_organisation_lk not in (select referral_organisation_lk from {{ this }})
{% endif %}
