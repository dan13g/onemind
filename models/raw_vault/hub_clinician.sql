{{ config(materialized='incremental', unique_key='clinician_hk', incremental_strategy='merge') }}
with source_data as (
    select clinician_hk, clinician_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__clinicians') }}
    union all
select clinician_hk, clinician_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__clinicians') }}
), deduped as (
 select * from source_data where clinician_hk is not null and clinician_bk is not null
 qualify row_number() over(partition by clinician_hk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where clinician_hk not in (select clinician_hk from {{ this }})
{% endif %}
