{{ config(materialized='incremental', unique_key='client_hk', incremental_strategy='merge') }}
with source_data as (
    select client_hk, source_client_business_key, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__clients') }}
    union all
select client_hk, source_client_business_key, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__clients') }}
), deduped as (
 select * from source_data where client_hk is not null and source_client_business_key is not null
 qualify row_number() over(partition by client_hk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where client_hk not in (select client_hk from {{ this }})
{% endif %}
