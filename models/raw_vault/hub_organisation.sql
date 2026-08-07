{{ config(materialized='incremental', unique_key='organisation_hk', incremental_strategy='merge') }}
with source_data as (
    select organisation_hk, organisation_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__organisations') }}
    union all
select organisation_hk, organisation_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__organisations') }}
), deduped as (
 select * from source_data where organisation_hk is not null and organisation_bk is not null
 qualify row_number() over(partition by organisation_hk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where organisation_hk not in (select organisation_hk from {{ this }})
{% endif %}
