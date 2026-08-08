{{ config(materialized='incremental', unique_key='clinician_satellite_pk', incremental_strategy='merge') }}
with source_data as (
 select sha2(clinician_hk||'|'||clinician_hashdiff||'|'||coalesce(source_updated_at::varchar,''),256) as clinician_satellite_pk,
        clinician_hk, clinician_hashdiff as hashdiff, current_timestamp()::timestamp_ntz as load_datetime, record_source, source_created_at, source_updated_at,
        staff_number,
        first_name,
        last_name,
        professional_role,
        registration_body,
        registration_number,
        employment_type,
        start_date,
        leaving_date
 from {{ ref('stg_onemind__clinicians') }}
), current_satellite as (
 {% if is_incremental() %} select clinician_hk, hashdiff from {{ this }} qualify row_number() over(partition by clinician_hk order by load_datetime desc)=1 {% else %} select null clinician_hk, null hashdiff where 1=0 {% endif %}
)
select s.* from source_data s left join current_satellite c on s.clinician_hk=c.clinician_hk
where c.clinician_hk is null or s.hashdiff<>c.hashdiff
