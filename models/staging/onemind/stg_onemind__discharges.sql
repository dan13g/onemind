with source as (

    select
        "discharge_id" as discharge_id,
        "episode_id" as episode_id,
        "discharged_at" as discharged_at,
        "discharge_reason" as discharge_reason,
        "onward_referral_flag" as onward_referral_flag,
        "onward_referral_to" as onward_referral_to,
        "discharge_notes" as discharge_notes,
        "created_at" as created_at,
        "updated_at" as updated_at
    from {{ source('onemind_raw', 'onemind_discharges') }}

)

select
    discharge_id::varchar as source_discharge_id,
    'ONEMIND|' || discharge_id::varchar as discharge_bk,
    sha2('ONEMIND|' || discharge_id::varchar,256) as discharge_hk,
    sha2('ONEMIND|' || episode_id::varchar,256) as episode_hk,
    episode_id::varchar as episode_id,
    discharged_at,
    discharge_reason,
    onward_referral_flag,
    onward_referral_to,
    discharge_notes,
    created_at::timestamp_ntz as source_created_at,
    updated_at::timestamp_ntz as source_updated_at,
    'ONEMIND' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(discharged_at::varchar,''),coalesce(discharge_reason::varchar,''),coalesce(onward_referral_flag::varchar,''),coalesce(onward_referral_to::varchar,''),coalesce(discharge_notes::varchar,'')),256) as discharge_hashdiff,
    sha2(concat_ws('|',sha2('ONEMIND|' || episode_id::varchar,256),sha2('ONEMIND|' || discharge_id::varchar,256)),256) as episode_discharge_lk
from source
