{{ config(materialized='incremental', unique_key='session_hk', incremental_strategy='merge') }}
with source_data as (
    select session_hk, session_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__sessions') }}
    union all
select session_hk, session_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__sessions') }}
), deduped as (
 select * from source_data where session_hk is not null and session_bk is not null
 qualify row_number() over(partition by session_hk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where session_hk not in (select session_hk from {{ this }})
{% endif %}
