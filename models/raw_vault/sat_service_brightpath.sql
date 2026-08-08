{{ config(materialized='incremental', unique_key='service_satellite_pk', incremental_strategy='merge') }}
with source_data as (
 select sha2(service_hk||'|'||service_hashdiff||'|'||coalesce(source_updated_at::varchar,''),256) as service_satellite_pk,
        service_hk, service_hashdiff as hashdiff, current_timestamp()::timestamp_ntz as load_datetime, record_source, source_created_at, source_updated_at,
        service_code,
        service_name,
        care_type,
        max_sessions,
        channel_default
 from {{ ref('stg_brightpath__services') }}
), current_satellite as (
 {% if is_incremental() %} select service_hk, hashdiff from {{ this }} qualify row_number() over(partition by service_hk order by load_datetime desc)=1 {% else %} select null service_hk, null hashdiff where 1=0 {% endif %}
)
select s.* from source_data s left join current_satellite c on s.service_hk=c.service_hk
where c.service_hk is null or s.hashdiff<>c.hashdiff
