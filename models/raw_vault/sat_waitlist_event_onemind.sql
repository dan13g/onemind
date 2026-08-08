{{ config(materialized='incremental', unique_key='waitlist_event_satellite_pk', incremental_strategy='merge') }}
with source_data as (
 select sha2(waitlist_event_hk||'|'||waitlist_event_hashdiff||'|'||coalesce(source_updated_at::varchar,''),256) as waitlist_event_satellite_pk,
        waitlist_event_hk, waitlist_event_hashdiff as hashdiff, current_timestamp()::timestamp_ntz as load_datetime, record_source, source_created_at, source_updated_at,
        event_at,
        event_type,
        waitlist_category,
        reason
 from {{ ref('stg_onemind__waitlist_events') }}
), current_satellite as (
 {% if is_incremental() %} select waitlist_event_hk, hashdiff from {{ this }} qualify row_number() over(partition by waitlist_event_hk order by load_datetime desc)=1 {% else %} select null waitlist_event_hk, null hashdiff where 1=0 {% endif %}
)
select s.* from source_data s left join current_satellite c on s.waitlist_event_hk=c.waitlist_event_hk
where c.waitlist_event_hk is null or s.hashdiff<>c.hashdiff
