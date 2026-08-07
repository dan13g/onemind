{{ config(materialized='incremental', unique_key='referral_waitlist_event_lk', incremental_strategy='merge') }}
with source_data as (
    select referral_waitlist_event_lk, referral_hk, waitlist_event_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__waitlist_events') }}
), deduped as (
 select * from source_data where referral_waitlist_event_lk is not null and referral_hk is not null and waitlist_event_hk is not null
 qualify row_number() over(partition by referral_waitlist_event_lk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where referral_waitlist_event_lk not in (select referral_waitlist_event_lk from {{ this }})
{% endif %}
