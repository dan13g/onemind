with source as (

    select
        "waitlist_event_id" as waitlist_event_id,
        "referral_id" as referral_id,
        "event_at" as event_at,
        "event_type" as event_type,
        "waitlist_category" as waitlist_category,
        "reason" as reason,
        "created_at" as created_at,
        "updated_at" as updated_at
    from {{ source('onemind_raw', 'onemind_waitlist_events') }}

)

select
    waitlist_event_id::varchar as source_waitlist_event_id,
    'ONEMIND|' || waitlist_event_id::varchar as waitlist_event_bk,
    sha2('ONEMIND|' || waitlist_event_id::varchar,256) as waitlist_event_hk,
    sha2('ONEMIND|' || referral_id::varchar,256) as referral_hk,
    referral_id::varchar as referral_id,
    event_at,
    event_type,
    waitlist_category,
    reason,
    created_at::timestamp_ntz as source_created_at,
    updated_at::timestamp_ntz as source_updated_at,
    'ONEMIND' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(event_at::varchar,''),coalesce(event_type::varchar,''),coalesce(waitlist_category::varchar,''),coalesce(reason::varchar,'')),256) as waitlist_event_hashdiff,
    sha2(concat_ws('|',sha2('ONEMIND|' || referral_id::varchar,256),sha2('ONEMIND|' || waitlist_event_id::varchar,256)),256) as referral_waitlist_event_lk
from source
