{{ config(materialized='incremental', unique_key='location_satellite_pk', incremental_strategy='merge') }}
with source_data as (
 select sha2(location_hk||'|'||location_hashdiff||'|'||coalesce(source_updated_at::varchar,''),256) as location_satellite_pk,
        location_hk, location_hashdiff as hashdiff, current_timestamp()::timestamp_ntz as load_datetime, record_source, source_created_at, source_updated_at,
        location_code,
        location_name,
        location_type,
        town_city,
        postcode,
        region
 from {{ ref('stg_onemind__locations') }}
), current_satellite as (
 {% if is_incremental() %} select location_hk, hashdiff from {{ this }} qualify row_number() over(partition by location_hk order by load_datetime desc)=1 {% else %} select null location_hk, null hashdiff where 1=0 {% endif %}
)
select s.* from source_data s left join current_satellite c on s.location_hk=c.location_hk
where c.location_hk is null or s.hashdiff<>c.hashdiff
