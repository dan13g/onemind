{{ config(materialized='incremental', unique_key='clinician_location_lk', incremental_strategy='merge') }}
with source_data as (
    select clinician_location_lk, clinician_hk, base_location_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__clinicians') }}
), deduped as (
 select * from source_data where clinician_location_lk is not null and clinician_hk is not null and base_location_hk is not null
 qualify row_number() over(partition by clinician_location_lk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where clinician_location_lk not in (select clinician_location_lk from {{ this }})
{% endif %}
