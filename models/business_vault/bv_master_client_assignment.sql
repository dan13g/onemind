with all_source_clients as (

    select
        client_hk,
        record_source
    from {{ ref('bv_source_client_latest') }}

),

accepted_matches as (

    select *
    from {{ ref('bv_client_match') }}
    where match_status = 'AUTO_MATCHED'

),

assigned as (

    -- OneMind members of matched pairs.
    select
        sha2(
            'MASTER|' || onemind_client_hk || '|' || brightpath_client_hk,
            256
        )                                                        as master_client_hk,
        onemind_client_hk                                        as client_hk,
        'MATCHED_PAIR'                                           as assignment_type
    from accepted_matches

    union all

    -- BrightPath members of matched pairs.
    select
        sha2(
            'MASTER|' || onemind_client_hk || '|' || brightpath_client_hk,
            256
        )                                                        as master_client_hk,
        brightpath_client_hk                                     as client_hk,
        'MATCHED_PAIR'                                           as assignment_type
    from accepted_matches

),

unmatched as (

    select
        sha2('MASTER|' || source.client_hk, 256)                 as master_client_hk,
        source.client_hk,
        'SINGLE_SOURCE'                                          as assignment_type
    from all_source_clients source
    left join assigned
        on source.client_hk = assigned.client_hk
    where assigned.client_hk is null

)

select * from assigned
union all
select * from unmatched
