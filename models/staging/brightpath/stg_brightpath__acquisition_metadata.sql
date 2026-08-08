select
    "acquisition_id"::varchar as acquisition_id,
    "acquired_company_name" as acquired_company_name,
    "legal_entity_name" as legal_entity_name,
    "acquisition_date" as acquisition_date,
    "source_system_name" as source_system_name,
    "source_system_owner" as source_system_owner,
    "migration_wave" as migration_wave,
    "notes" as notes,
    "created_ts"::timestamp_ntz as source_created_at,
    "modified_ts"::timestamp_ntz as source_updated_at,
    'BRIGHTPATH' as record_source
from {{ source('brightpath_raw', 'brightpath_acquisition_metadata') }}
