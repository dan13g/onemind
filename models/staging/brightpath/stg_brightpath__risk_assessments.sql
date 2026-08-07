select
    risk_assessment_key::varchar as source_risk_assessment_id,
    'BRIGHTPATH|' || risk_assessment_key::varchar as risk_assessment_bk,
    sha2('BRIGHTPATH|' || risk_assessment_key::varchar,256) as risk_assessment_hk,
    sha2('BRIGHTPATH|' || episode_key::varchar,256) as episode_hk,
    episode_key::varchar as episode_id,
    flagged_ts as assessed_at,
    risk_domain,
    risk_level,
    escalation_required,
    created_ts::timestamp_ntz as source_created_at,
    modified_ts::timestamp_ntz as source_updated_at,
    'BRIGHTPATH' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(flagged_ts::varchar,''),coalesce(risk_domain::varchar,''),coalesce(risk_level::varchar,''),coalesce(escalation_required::varchar,'')),256) as risk_assessment_hashdiff,
    sha2(concat_ws('|',sha2('BRIGHTPATH|' || episode_key::varchar,256),sha2('BRIGHTPATH|' || risk_assessment_key::varchar,256)),256) as episode_risk_assessment_lk
from {{ source('brightpath_raw', 'brightpath_risk_assessments') }}
