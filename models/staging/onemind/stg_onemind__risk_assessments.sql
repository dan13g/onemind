with source as (

    select
        "risk_assessment_id" as risk_assessment_id,
        "episode_id" as episode_id,
        "assessed_at" as assessed_at,
        "risk_domain" as risk_domain,
        "risk_level" as risk_level,
        "safety_plan_required" as safety_plan_required,
        "created_at" as created_at,
        "updated_at" as updated_at
    from {{ source('onemind_raw', 'onemind_risk_assessments') }}

)

select
    risk_assessment_id::varchar as source_risk_assessment_id,
    'ONEMIND|' || risk_assessment_id::varchar as risk_assessment_bk,
    sha2('ONEMIND|' || risk_assessment_id::varchar,256) as risk_assessment_hk,
    sha2('ONEMIND|' || episode_id::varchar,256) as episode_hk,
    episode_id::varchar as episode_id,
    assessed_at,
    risk_domain,
    risk_level,
    safety_plan_required,
    created_at::timestamp_ntz as source_created_at,
    updated_at::timestamp_ntz as source_updated_at,
    'ONEMIND' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(assessed_at::varchar,''),coalesce(risk_domain::varchar,''),coalesce(risk_level::varchar,''),coalesce(safety_plan_required::varchar,'')),256) as risk_assessment_hashdiff,
    sha2(concat_ws('|',sha2('ONEMIND|' || episode_id::varchar,256),sha2('ONEMIND|' || risk_assessment_id::varchar,256)),256) as episode_risk_assessment_lk
from source
