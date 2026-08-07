select
    clinician_key::varchar as source_clinician_id,
    'BRIGHTPATH|' || clinician_key::varchar as clinician_bk,
    sha2('BRIGHTPATH|' || clinician_key::varchar,256) as clinician_hk,
    clinician_ref as staff_number,
    full_name,
    split_part(full_name,' ',1) as first_name,
    regexp_replace(full_name,'^[^ ]+ ','') as last_name,
    role_title as professional_role,
    registration_body,
    registration_no as registration_number,
    city,
    status,
    created_ts::timestamp_ntz as source_created_at,
    modified_ts::timestamp_ntz as source_updated_at,
    'BRIGHTPATH' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(full_name::varchar,''),coalesce(role_title::varchar,''),coalesce(registration_body::varchar,''),coalesce(registration_no::varchar,''),coalesce(city::varchar,''),coalesce(status::varchar,'')),256) as clinician_hashdiff
from {{ source('brightpath_raw', 'brightpath_clinicians') }}
