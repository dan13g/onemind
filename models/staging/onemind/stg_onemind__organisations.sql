select
    organisation_id::varchar as source_organisation_id,
    'ONEMIND|' || organisation_id::varchar as organisation_bk,
    sha2('ONEMIND|' || organisation_id::varchar,256) as organisation_hk,
    organisation_type,
    organisation_code,
    organisation_name,
    postcode,
    region,
    active_flag,
    created_at::timestamp_ntz as source_created_at,
    updated_at::timestamp_ntz as source_updated_at,
    'ONEMIND' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(organisation_type::varchar,''),coalesce(organisation_code::varchar,''),coalesce(organisation_name::varchar,''),coalesce(postcode::varchar,''),coalesce(region::varchar,''),coalesce(active_flag::varchar,'')),256) as organisation_hashdiff
from {{ source('onemind_raw', 'onemind_organisations') }}
