with source as (

    select
        "location_id" as location_id,
        "location_code" as location_code,
        "location_name" as location_name,
        "location_type" as location_type,
        "town_city" as town_city,
        "postcode" as postcode,
        "region" as region,
        "created_at" as created_at,
        "updated_at" as updated_at
    from {{ source('onemind_raw', 'onemind_locations') }}

)

select
    location_id::varchar as source_location_id,
    'ONEMIND|' || location_id::varchar as location_bk,
    sha2('ONEMIND|' || location_id::varchar,256) as location_hk,
    location_code,
    location_name,
    location_type,
    town_city,
    postcode,
    region,
    created_at::timestamp_ntz as source_created_at,
    updated_at::timestamp_ntz as source_updated_at,
    'ONEMIND' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(location_code::varchar,''),coalesce(location_name::varchar,''),coalesce(location_type::varchar,''),coalesce(town_city::varchar,''),coalesce(postcode::varchar,''),coalesce(region::varchar,'')),256) as location_hashdiff
from source
