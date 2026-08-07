{{ config(materialized='incremental', unique_key='episode_discharge_lk', incremental_strategy='merge') }}
with source_data as (
    select episode_discharge_lk, episode_hk, discharge_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__discharges') }}
), deduped as (
 select * from source_data where episode_discharge_lk is not null and episode_hk is not null and discharge_hk is not null
 qualify row_number() over(partition by episode_discharge_lk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where episode_discharge_lk not in (select episode_discharge_lk from {{ this }})
{% endif %}
