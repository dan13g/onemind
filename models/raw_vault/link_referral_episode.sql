{{ config(materialized='incremental', unique_key='referral_episode_lk', incremental_strategy='merge') }}
with source_data as (
    select referral_episode_lk, referral_hk, episode_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__episodes') }}
    union all
select referral_episode_lk, referral_hk, episode_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__episodes') }}
), deduped as (
 select * from source_data where referral_episode_lk is not null and referral_hk is not null and episode_hk is not null
 qualify row_number() over(partition by referral_episode_lk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where referral_episode_lk not in (select referral_episode_lk from {{ this }})
{% endif %}
