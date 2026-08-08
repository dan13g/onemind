{{ config(materialized='incremental', unique_key='session_clinician_lk', incremental_strategy='merge') }}
with source_data as (
    select session_clinician_lk, session_hk, clinician_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__sessions') }}
    union all
select session_clinician_lk, session_hk, clinician_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__sessions') }}
), deduped as (
 select * from source_data where session_clinician_lk is not null and session_hk is not null and clinician_hk is not null
 qualify row_number() over(partition by session_clinician_lk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where session_clinician_lk not in (select session_clinician_lk from {{ this }})
{% endif %}
