with candidates as (

    select *
    from {{ ref('bv_client_fuzzy_candidates') }}

),

scored_components as (

    select
        *,

        30                                                        as dob_points,

        case
            when last_name_similarity >= 97 then 25
            when last_name_similarity >= 92 then 22
            when last_name_similarity >= 87 then 18
            when last_name_similarity >= 82 then 12
            else 0
        end                                                       as last_name_points,

        case
            when first_name_similarity >= 97 then 20
            when first_name_similarity >= 92 then 17
            when first_name_similarity >= 87 then 13
            when first_name_similarity >= 82 then 8
            else 0
        end                                                       as first_name_points,

        case
            when onemind_postcode is not null
             and brightpath_postcode is not null
             and onemind_postcode = brightpath_postcode
                then 15
            when onemind_postcode_outward is not null
             and brightpath_postcode_outward is not null
             and onemind_postcode_outward = brightpath_postcode_outward
                then 8
            else 0
        end                                                       as postcode_points,

        case
            when onemind_last_name_soundex = brightpath_last_name_soundex then 5
            else 0
        end                                                       as surname_soundex_points,

        case
            when onemind_first_name_soundex = brightpath_first_name_soundex then 3
            else 0
        end                                                       as first_name_soundex_points,

        case
            when email_similarity >= 97 then 7
            when email_similarity >= 92 then 4
            else 0
        end                                                       as email_points,

        case
            when phone_last_7_match then 5
            else 0
        end                                                       as phone_points

    from candidates

),

scored as (

    select
        *,
        dob_points
          + last_name_points
          + first_name_points
          + postcode_points
          + surname_soundex_points
          + first_name_soundex_points
          + email_points
          + phone_points                                        as fuzzy_match_score,

        (
               onemind_postcode = brightpath_postcode
            or phone_last_7_match
            or email_similarity >= 97
        )                                                         as has_strong_supporting_identifier

    from scored_components

),

decided as (

    select
        *,
        case
            when fuzzy_match_score >= 85
             and last_name_similarity >= 90
             and first_name_similarity >= 85
             and has_strong_supporting_identifier
                then 'AUTO_MATCH'

            when fuzzy_match_score >= 65
                then 'MANUAL_REVIEW'

            else 'NO_MATCH'
        end                                                       as fuzzy_match_decision
    from scored

)

select *
from decided
