with source as (

    select
        "organisation_id" as organisation_id,
        "organisation_type" as organisation_type,
        "organisation_code" as organisation_code,
        "organisation_name" as organisation_name,
        "postcode" as postcode,
        "region" as region,
        "active_flag" as active_flag,
        "created_at" as created_at,
        "updated_at" as updated_at
    from {{ source('onemind_raw', 'onemind_organisations') }}

)

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
from source
