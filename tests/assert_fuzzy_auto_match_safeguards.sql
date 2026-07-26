select *
from {{ ref('bv_client_fuzzy_auto_match') }}
where match_score < 85
   or last_name_similarity < 90
   or first_name_similarity < 85
   or not (
          postcode_exact_match
       or phone_last_7_match
       or email_similarity >= 97
   )
