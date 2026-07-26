with auto_candidates as (

    select *
    from {{ ref('bv_client_fuzzy_scored') }}
    where fuzzy_match_decision = 'AUTO_MATCH'

),

ranked as (

    select
        *,
        row_number() over (
            partition by onemind_client_hk
            order by
                fuzzy_match_score desc,
                last_name_similarity desc,
                first_name_similarity desc,
                brightpath_client_hk
        )                                                         as onemind_match_rank,

        row_number() over (
            partition by brightpath_client_hk
            order by
                fuzzy_match_score desc,
                last_name_similarity desc,
                first_name_similarity desc,
                onemind_client_hk
        )                                                         as brightpath_match_rank

    from auto_candidates

)

select
    onemind_client_hk,
    brightpath_client_hk,
    'WEIGHTED_FUZZY_NAME_DOB_IDENTIFIER'                         as match_rule,
    fuzzy_match_score                                            as match_score,
    'AUTO_MATCHED'                                               as match_status,
    'FUZZY'                                                      as match_method,
    current_timestamp()::timestamp_ntz                           as matched_at,
    first_name_similarity,
    last_name_similarity,
    first_name_edit_distance,
    last_name_edit_distance,
    email_similarity,
    phone_last_7_match,
    onemind_postcode = brightpath_postcode                       as postcode_exact_match
from ranked
where onemind_match_rank = 1
  and brightpath_match_rank = 1
