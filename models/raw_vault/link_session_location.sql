{{ config(materialized='incremental', unique_key='session_location_lk', incremental_strategy='merge') }}
with source_data as (
    select session_location_lk, session_hk, location_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__sessions') }}
), deduped as (
 select * from source_data where session_location_lk is not null and session_hk is not null and location_hk is not null
 qualify row_number() over(partition by session_location_lk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where session_location_lk not in (select session_location_lk from {{ this }})
{% endif %}
