{{ config(materialized='incremental', unique_key='location_hk', incremental_strategy='merge') }}
with source_data as (
    select location_hk, location_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__locations') }}
), deduped as (
 select * from source_data where location_hk is not null and location_bk is not null
 qualify row_number() over(partition by location_hk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where location_hk not in (select location_hk from {{ this }})
{% endif %}
