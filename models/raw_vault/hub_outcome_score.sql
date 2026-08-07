{{ config(materialized='incremental', unique_key='outcome_score_hk', incremental_strategy='merge') }}
with source_data as (
    select outcome_score_hk, outcome_score_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__outcome_scores') }}
    union all
select outcome_score_hk, outcome_score_bk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__outcome_scores') }}
), deduped as (
 select * from source_data where outcome_score_hk is not null and outcome_score_bk is not null
 qualify row_number() over(partition by outcome_score_hk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where outcome_score_hk not in (select outcome_score_hk from {{ this }})
{% endif %}
