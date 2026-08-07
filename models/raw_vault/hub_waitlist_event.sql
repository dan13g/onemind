{{ config(materialized='incremental', unique_key='waitlist_event_hk', incremental_strategy='merge') }}
with source_data as (
    select waitlist_event_hk, waitlist_event_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__waitlist_events') }}
), deduped as (
 select * from source_data where waitlist_event_hk is not null and waitlist_event_bk is not null
 qualify row_number() over(partition by waitlist_event_hk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where waitlist_event_hk not in (select waitlist_event_hk from {{ this }})
{% endif %}
