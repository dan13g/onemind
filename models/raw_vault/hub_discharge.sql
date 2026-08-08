{{ config(materialized='incremental', unique_key='discharge_hk', incremental_strategy='merge') }}
with source_data as (
    select discharge_hk, discharge_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__discharges') }}
), deduped as (
 select * from source_data where discharge_hk is not null and discharge_bk is not null
 qualify row_number() over(partition by discharge_hk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where discharge_hk not in (select discharge_hk from {{ this }})
{% endif %}
