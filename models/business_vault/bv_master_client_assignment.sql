/*
    Assigns every source-client hub identity to one mastered client identity.

    Accepted deterministic/fuzzy pairs share a MASTER_CLIENT_HK. Any source
    client not present in an accepted pair receives its own stable master key.
    HUB_CLIENT, rather than a satellite-derived view, is the authoritative
    population of source clients.
*/

with all_source_clients as (

    select
        client_hk,
        source_client_business_key,
        record_source
    from {{ ref('hub_client') }}

),

accepted_matches as (

    select
        onemind_client_hk,
        brightpath_client_hk,
        match_rule,
        match_score,
        match_method,
        matched_at
    from {{ ref('bv_client_match') }}
    where match_status = 'AUTO_MATCHED'

),

matched_assignments as (

    select
        sha2(
            'MASTER|' || onemind_client_hk || '|' || brightpath_client_hk,
            256
        )                                                        as master_client_hk,
        onemind_client_hk                                        as client_hk,
        'MATCHED_PAIR'                                           as assignment_type,
        match_rule,
        match_score,
        match_method,
        matched_at as assignment_datetime
    from accepted_matches

    union all

    select
        sha2(
            'MASTER|' || onemind_client_hk || '|' || brightpath_client_hk,
            256
        )                                                        as master_client_hk,
        brightpath_client_hk                                     as client_hk,
        'MATCHED_PAIR'                                           as assignment_type,
        match_rule,
        match_score,
        match_method,
        matched_at as assignment_datetime
    from accepted_matches

),

unmatched_assignments as (

    select
        sha2('MASTER|' || source.client_hk, 256)                 as master_client_hk,
        source.client_hk,
        'SINGLE_SOURCE'                                          as assignment_type,
        'NO_ACCEPTED_CROSS_SOURCE_MATCH'                          as match_rule,
        0                                                        as match_score,
        'UNMATCHED'                                              as match_method,
        current_timestamp()::timestamp_ntz                       as assignment_datetime
    from all_source_clients source
    left join matched_assignments matched
        on source.client_hk = matched.client_hk
    where matched.client_hk is null

)

select * from matched_assignments
union all
select * from unmatched_assignments
