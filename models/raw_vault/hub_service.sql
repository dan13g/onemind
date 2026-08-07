{{ config(materialized='incremental', unique_key='service_hk', incremental_strategy='merge') }}
with source_data as (
    select service_hk, service_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__services') }}
    union all
select service_hk, service_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__services') }}
), deduped as (
 select * from source_data where service_hk is not null and service_bk is not null
 qualify row_number() over(partition by service_hk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where service_hk not in (select service_hk from {{ this }})
{% endif %}
