with source as (

    select
        "service_id" as service_id,
        "service_code" as service_code,
        "service_name" as service_name,
        "modality" as modality,
        "intensity_level" as intensity_level,
        "target_wait_days" as target_wait_days,
        "active_flag" as active_flag,
        "created_at" as created_at,
        "updated_at" as updated_at
    from {{ source('onemind_raw', 'onemind_services') }}

)

select
    service_id::varchar as source_service_id,
    'ONEMIND|' || service_id::varchar as service_bk,
    sha2('ONEMIND|' || service_id::varchar,256) as service_hk,
    service_code,
    service_name,
    modality,
    intensity_level,
    target_wait_days,
    active_flag,
    created_at::timestamp_ntz as source_created_at,
    updated_at::timestamp_ntz as source_updated_at,
    'ONEMIND' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(service_code::varchar,''),coalesce(service_name::varchar,''),coalesce(modality::varchar,''),coalesce(intensity_level::varchar,''),coalesce(target_wait_days::varchar,''),coalesce(active_flag::varchar,'')),256) as service_hashdiff
from source
