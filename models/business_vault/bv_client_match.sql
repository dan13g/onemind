select
    onemind_client_hk,
    brightpath_client_hk,
    match_rule,
    match_score,
    'DETERMINISTIC' as match_method,
    'AUTO_MATCHED' as match_status,
    matched_at
from {{ ref('bv_client_deterministic_match') }}
