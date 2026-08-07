{{ config(materialized='incremental', unique_key='organisation_satellite_pk', incremental_strategy='merge') }}
with source_data as (
 select sha2(organisation_hk||'|'||organisation_hashdiff||'|'||coalesce(source_updated_at::varchar,''),256) as organisation_satellite_pk,
        organisation_hk, organisation_hashdiff as hashdiff, current_timestamp()::timestamp_ntz as load_datetime, record_source, source_created_at, source_updated_at,
        organisation_type,
        organisation_code,
        organisation_name,
        postcode,
        region,
        active_flag
 from {{ ref('stg_onemind__organisations') }}
), current_satellite as (
 {% if is_incremental() %} select organisation_hk, hashdiff from {{ this }} qualify row_number() over(partition by organisation_hk order by load_datetime desc)=1 {% else %} select null organisation_hk, null hashdiff where 1=0 {% endif %}
)
select s.* from source_data s left join current_satellite c on s.organisation_hk=c.organisation_hk
where c.organisation_hk is null or s.hashdiff<>c.hashdiff
