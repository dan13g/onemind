{{ config(materialized='incremental', unique_key='episode_hk', incremental_strategy='merge') }}
with source_data as (
    select episode_hk, episode_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__episodes') }}
    union all
select episode_hk, episode_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__episodes') }}
), deduped as (
 select * from source_data where episode_hk is not null and episode_bk is not null
 qualify row_number() over(partition by episode_hk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where episode_hk not in (select episode_hk from {{ this }})
{% endif %}
