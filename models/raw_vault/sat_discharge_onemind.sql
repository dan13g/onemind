{{ config(materialized='incremental', unique_key='discharge_satellite_pk', incremental_strategy='merge') }}
with source_data as (
 select sha2(discharge_hk||'|'||discharge_hashdiff||'|'||coalesce(source_updated_at::varchar,''),256) as discharge_satellite_pk,
        discharge_hk, discharge_hashdiff as hashdiff, current_timestamp()::timestamp_ntz as load_datetime, record_source, source_created_at, source_updated_at,
        discharged_at,
        discharge_reason,
        onward_referral_flag,
        onward_referral_to,
        discharge_notes
 from {{ ref('stg_onemind__discharges') }}
), current_satellite as (
 {% if is_incremental() %} select discharge_hk, hashdiff from {{ this }} qualify row_number() over(partition by discharge_hk order by load_datetime desc)=1 {% else %} select null discharge_hk, null hashdiff where 1=0 {% endif %}
)
select s.* from source_data s left join current_satellite c on s.discharge_hk=c.discharge_hk
where c.discharge_hk is null or s.hashdiff<>c.hashdiff
