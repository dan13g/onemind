with source as (

    select
        "service_key" as service_key,
        "service_code" as service_code,
        "service_name" as service_name,
        "care_type" as care_type,
        "max_sessions" as max_sessions,
        "channel_default" as channel_default,
        "created_ts" as created_ts,
        "modified_ts" as modified_ts
    from {{ source('brightpath_raw', 'brightpath_services') }}

)

select
    service_key::varchar as source_service_id,
    'BRIGHTPATH|' || service_key::varchar as service_bk,
    sha2('BRIGHTPATH|' || service_key::varchar,256) as service_hk,
    service_code,
    service_name,
    care_type,
    max_sessions,
    channel_default,
    created_ts::timestamp_ntz as source_created_at,
    modified_ts::timestamp_ntz as source_updated_at,
    'BRIGHTPATH' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(service_code::varchar,''),coalesce(service_name::varchar,''),coalesce(care_type::varchar,''),coalesce(max_sessions::varchar,''),coalesce(channel_default::varchar,'')),256) as service_hashdiff
from source
