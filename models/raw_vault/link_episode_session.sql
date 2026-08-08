{{ config(materialized='incremental', unique_key='episode_session_lk', incremental_strategy='merge') }}
with source_data as (
    select episode_session_lk, episode_hk, session_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__sessions') }}
    union all
select episode_session_lk, episode_hk, session_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__sessions') }}
), deduped as (
 select * from source_data where episode_session_lk is not null and episode_hk is not null and session_hk is not null
 qualify row_number() over(partition by episode_session_lk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where episode_session_lk not in (select episode_session_lk from {{ this }})
{% endif %}
