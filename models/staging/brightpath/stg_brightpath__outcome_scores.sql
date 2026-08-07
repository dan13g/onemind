select
    outcome_score_key::varchar as source_outcome_score_id,
    'BRIGHTPATH|' || outcome_score_key::varchar as outcome_score_bk,
    sha2('BRIGHTPATH|' || outcome_score_key::varchar,256) as outcome_score_hk,
    sha2('BRIGHTPATH|' || session_key::varchar,256) as session_hk,
    session_key::varchar as session_id,
    measure_name,
    score_value,
    score_date,
    created_ts::timestamp_ntz as source_created_at,
    modified_ts::timestamp_ntz as source_updated_at,
    'BRIGHTPATH' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(measure_name::varchar,''),coalesce(score_value::varchar,''),coalesce(score_date::varchar,'')),256) as outcome_score_hashdiff,
    sha2(concat_ws('|',sha2('BRIGHTPATH|' || session_key::varchar,256),sha2('BRIGHTPATH|' || outcome_score_key::varchar,256)),256) as session_outcome_score_lk
from {{ source('brightpath_raw', 'brightpath_outcome_scores') }}
