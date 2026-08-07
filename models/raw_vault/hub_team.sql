{{ config(materialized='incremental', unique_key='team_hk', incremental_strategy='merge') }}
with source_data as (
    select team_hk, team_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__teams') }}
), deduped as (
 select * from source_data where team_hk is not null and team_bk is not null
 qualify row_number() over(partition by team_hk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where team_hk not in (select team_hk from {{ this }})
{% endif %}
