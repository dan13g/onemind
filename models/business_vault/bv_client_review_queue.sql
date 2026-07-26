select
    onemind_client_hk,
    brightpath_client_hk,
    onemind_first_name,
    brightpath_first_name,
    onemind_last_name,
    brightpath_last_name,
    onemind_date_of_birth,
    brightpath_date_of_birth,
    onemind_postcode,
    brightpath_postcode,
    first_name_similarity,
    last_name_similarity,
    first_name_edit_distance,
    last_name_edit_distance,
    email_similarity,
    phone_last_7_match,
    fuzzy_match_score,
    fuzzy_match_decision,
    current_timestamp()::timestamp_ntz                           as queued_at
from {{ ref('bv_client_fuzzy_scored') }}
where fuzzy_match_decision = 'MANUAL_REVIEW'
