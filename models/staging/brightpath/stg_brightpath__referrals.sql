with source as (

    select
        "intake_key" as intake_key,
        "client_key" as client_key,
        "opened_ts" as opened_ts,
        "channel" as channel,
        "referral_reason" as referral_reason,
        "initial_severity" as initial_severity,
        "urgent_flag" as urgent_flag,
        "current_state" as current_state,
        "service_key" as service_key,
        "created_ts" as created_ts,
        "modified_ts" as modified_ts
    from {{ source('brightpath_raw', 'brightpath_referrals') }}

)

select
    intake_key::varchar as source_referral_id,
    'BRIGHTPATH|' || intake_key::varchar as referral_bk,
    sha2('BRIGHTPATH|' || intake_key::varchar,256) as referral_hk,
    sha2('BRIGHTPATH|' || client_key::varchar,256) as client_hk,
    iff(service_key is null, null, sha2('BRIGHTPATH|' || service_key::varchar,256)) as service_hk,
    client_key::varchar as client_id,
    service_key::varchar as service_id,
    opened_ts as referral_received_at,
    channel as referral_source,
    referral_reason as presenting_problem,
    initial_severity,
    urgent_flag,
    current_state as referral_status,
    created_ts::timestamp_ntz as source_created_at,
    modified_ts::timestamp_ntz as source_updated_at,
    'BRIGHTPATH' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(opened_ts::varchar,''),coalesce(channel::varchar,''),coalesce(referral_reason::varchar,''),coalesce(initial_severity::varchar,''),coalesce(urgent_flag::varchar,''),coalesce(current_state::varchar,'')),256) as referral_hashdiff,
    sha2(concat_ws('|',sha2('BRIGHTPATH|' || client_key::varchar,256),sha2('BRIGHTPATH|' || intake_key::varchar,256)),256) as client_referral_lk,
    sha2(concat_ws('|',sha2('BRIGHTPATH|' || intake_key::varchar,256),iff(service_key is null, null, sha2('BRIGHTPATH|' || service_key::varchar,256))),256) as referral_service_lk
from source
