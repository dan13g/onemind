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
from {{ source('brightpath_raw', 'brightpath_services') }}
