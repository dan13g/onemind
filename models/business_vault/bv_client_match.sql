with deterministic as (

    select
        onemind_client_hk,
        brightpath_client_hk,
        match_rule,
        match_score,
        match_status,
        'DETERMINISTIC'                                          as match_method,
        matched_at,
        cast(null as integer)                                    as first_name_similarity,
        cast(null as integer)                                    as last_name_similarity,
        cast(null as integer)                                    as first_name_edit_distance,
        cast(null as integer)                                    as last_name_edit_distance,
        cast(null as integer)                                    as email_similarity,
        cast(null as boolean)                                    as phone_last_7_match,
        cast(null as boolean)                                    as postcode_exact_match
    from {{ ref('bv_client_deterministic_match') }}

),

fuzzy as (

    select
        onemind_client_hk,
        brightpath_client_hk,
        match_rule,
        match_score,
        match_status,
        match_method,
        matched_at,
        first_name_similarity,
        last_name_similarity,
        first_name_edit_distance,
        last_name_edit_distance,
        email_similarity,
        phone_last_7_match,
        postcode_exact_match
    from {{ ref('bv_client_fuzzy_auto_match') }}

)

select * from deterministic
union all
select * from fuzzy
