with source as (

    select
        "episode_id" as episode_id,
        "referral_id" as referral_id,
        "episode_start_date" as episode_start_date,
        "episode_end_date" as episode_end_date,
        "primary_problem" as primary_problem,
        "provisional_diagnosis" as provisional_diagnosis,
        "care_pathway" as care_pathway,
        "discharge_reason" as discharge_reason,
        "outcome_status" as outcome_status,
        "created_at" as created_at,
        "updated_at" as updated_at
    from {{ source('onemind_raw', 'onemind_episodes') }}

)

select
    episode_id::varchar as source_episode_id,
    'ONEMIND|' || episode_id::varchar as episode_bk,
    sha2('ONEMIND|' || episode_id::varchar,256) as episode_hk,
    sha2('ONEMIND|' || referral_id::varchar,256) as referral_hk,
    referral_id::varchar as referral_id,
    episode_start_date,
    episode_end_date,
    primary_problem,
    provisional_diagnosis,
    care_pathway,
    discharge_reason,
    outcome_status,
    created_at::timestamp_ntz as source_created_at,
    updated_at::timestamp_ntz as source_updated_at,
    'ONEMIND' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(episode_start_date::varchar,''),coalesce(episode_end_date::varchar,''),coalesce(primary_problem::varchar,''),coalesce(provisional_diagnosis::varchar,''),coalesce(care_pathway::varchar,''),coalesce(discharge_reason::varchar,''),coalesce(outcome_status::varchar,'')),256) as episode_hashdiff,
    sha2(concat_ws('|',sha2('ONEMIND|' || referral_id::varchar,256),sha2('ONEMIND|' || episode_id::varchar,256)),256) as referral_episode_lk
from source
