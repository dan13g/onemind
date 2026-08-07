{{ config(materialized='incremental', unique_key='session_satellite_pk', incremental_strategy='merge') }}
with source_data as (
 select sha2(session_hk||'|'||session_hashdiff||'|'||coalesce(source_updated_at::varchar,''),256) as session_satellite_pk,
        session_hk, session_hashdiff as hashdiff, current_timestamp()::timestamp_ntz as load_datetime, record_source, source_created_at, source_updated_at,
        session_start_at,
        session_end_at,
        duration_minutes,
        session_type,
        delivery_channel,
        attendance_status,
        cancellation_reason,
        clinical_notes_entered
 from {{ ref('stg_onemind__sessions') }}
), current_satellite as (
 {% if is_incremental() %} select session_hk, hashdiff from {{ this }} qualify row_number() over(partition by session_hk order by load_datetime desc)=1 {% else %} select null session_hk, null hashdiff where 1=0 {% endif %}
)
select s.* from source_data s left join current_satellite c on s.session_hk=c.session_hk
where c.session_hk is null or s.hashdiff<>c.hashdiff
