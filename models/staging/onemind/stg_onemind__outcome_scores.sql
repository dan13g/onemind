select
    outcome_score_id::varchar as source_outcome_score_id,
    'ONEMIND|' || outcome_score_id::varchar as outcome_score_bk,
    sha2('ONEMIND|' || outcome_score_id::varchar,256) as outcome_score_hk,
    sha2('ONEMIND|' || session_id::varchar,256) as session_hk,
    session_id::varchar as session_id,
    measure_name,
    score_value,
    score_date,
    created_at::timestamp_ntz as source_created_at,
    updated_at::timestamp_ntz as source_updated_at,
    'ONEMIND' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(measure_name::varchar,''),coalesce(score_value::varchar,''),coalesce(score_date::varchar,'')),256) as outcome_score_hashdiff,
    sha2(concat_ws('|',sha2('ONEMIND|' || session_id::varchar,256),sha2('ONEMIND|' || outcome_score_id::varchar,256)),256) as session_outcome_score_lk
from {{ source('onemind_raw', 'onemind_outcome_scores') }}
