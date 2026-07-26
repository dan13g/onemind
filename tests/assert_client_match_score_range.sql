select *
from {{ ref('bv_client_match') }}
where match_score < 0
   or match_score > 110
