select
    episode_key::varchar as source_episode_id,
    'BRIGHTPATH|' || episode_key::varchar as episode_bk,
    sha2('BRIGHTPATH|' || episode_key::varchar,256) as episode_hk,
    sha2('BRIGHTPATH|' || intake_key::varchar,256) as referral_hk,
    intake_key::varchar as referral_id,
    episode_open_date as episode_start_date,
    episode_close_date as episode_end_date,
    main_condition_text as primary_problem,
    icd10_code,
    close_reason as discharge_reason,
    clinical_outcome as outcome_status,
    created_ts::timestamp_ntz as source_created_at,
    modified_ts::timestamp_ntz as source_updated_at,
    'BRIGHTPATH' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(episode_open_date::varchar,''),coalesce(episode_close_date::varchar,''),coalesce(main_condition_text::varchar,''),coalesce(icd10_code::varchar,''),coalesce(close_reason::varchar,''),coalesce(clinical_outcome::varchar,'')),256) as episode_hashdiff,
    sha2(concat_ws('|',sha2('BRIGHTPATH|' || intake_key::varchar,256),sha2('BRIGHTPATH|' || episode_key::varchar,256)),256) as referral_episode_lk
from {{ source('brightpath_raw', 'brightpath_episodes') }}
