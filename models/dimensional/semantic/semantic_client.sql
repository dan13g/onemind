{{
    config(
        materialized='view',
        alias='CLIENT',
        secure=true
    )
}}

select
    client_key,
    date_of_birth,
    age_years,
    age_band,
    gender,
    postcode_outward_code,
    first_seen_at,
    most_recent_source_update_at,
    source_system_count,
    has_onemind_record,
    has_brightpath_record,
    assignment_type
from {{ ref('dim_client') }}
