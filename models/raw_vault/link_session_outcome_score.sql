{{ config(materialized='incremental', unique_key='session_outcome_score_lk', incremental_strategy='merge') }}
with source_data as (
    select session_outcome_score_lk, session_hk, outcome_score_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_onemind__outcome_scores') }}
    union all
select session_outcome_score_lk, session_hk, outcome_score_hk, record_source, dbt_loaded_at as load_datetime from {{ ref('stg_brightpath__outcome_scores') }}
), deduped as (
 select * from source_data where session_outcome_score_lk is not null and session_hk is not null and outcome_score_hk is not null
 qualify row_number() over(partition by session_outcome_score_lk order by load_datetime)=1
)
select * from deduped
{% if is_incremental() %}
where session_outcome_score_lk not in (select session_outcome_score_lk from {{ this }})
{% endif %}
