with deterministic_matches as (

    select
        onemind_client_hk,
        brightpath_client_hk
    from {{ ref('bv_client_deterministic_match') }}

),

onemind as (

    select source.*
    from {{ ref('bv_source_client_latest') }} source
    left join deterministic_matches matched
        on source.client_hk = matched.onemind_client_hk
    where source.record_source = 'ONEMIND'
      and matched.onemind_client_hk is null

),

brightpath as (

    select source.*
    from {{ ref('bv_source_client_latest') }} source
    left join deterministic_matches matched
        on source.client_hk = matched.brightpath_client_hk
    where source.record_source = 'BRIGHTPATH'
      and matched.brightpath_client_hk is null

),

candidates as (

    select
        o.client_hk                                              as onemind_client_hk,
        b.client_hk                                              as brightpath_client_hk,

        o.first_name_normalised                                  as onemind_first_name,
        b.first_name_normalised                                  as brightpath_first_name,
        o.last_name_normalised                                   as onemind_last_name,
        b.last_name_normalised                                   as brightpath_last_name,

        o.date_of_birth                                          as onemind_date_of_birth,
        b.date_of_birth                                          as brightpath_date_of_birth,

        o.postcode_normalised                                    as onemind_postcode,
        b.postcode_normalised                                    as brightpath_postcode,
        case
            when o.postcode_normalised is null then null
            when length(o.postcode_normalised) <= 3 then o.postcode_normalised
            else left(o.postcode_normalised, length(o.postcode_normalised) - 3)
        end                                                       as onemind_postcode_outward,
        case
            when b.postcode_normalised is null then null
            when length(b.postcode_normalised) <= 3 then b.postcode_normalised
            else left(b.postcode_normalised, length(b.postcode_normalised) - 3)
        end                                                       as brightpath_postcode_outward,

        o.email_normalised                                       as onemind_email,
        b.email_normalised                                       as brightpath_email,
        o.phone_normalised                                       as onemind_phone,
        b.phone_normalised                                       as brightpath_phone,

        soundex(o.first_name_normalised)                         as onemind_first_name_soundex,
        soundex(b.first_name_normalised)                         as brightpath_first_name_soundex,
        soundex(o.last_name_normalised)                          as onemind_last_name_soundex,
        soundex(b.last_name_normalised)                          as brightpath_last_name_soundex,

        jarowinkler_similarity(
            o.first_name_normalised,
            b.first_name_normalised
        )                                                         as first_name_similarity,

        jarowinkler_similarity(
            o.last_name_normalised,
            b.last_name_normalised
        )                                                         as last_name_similarity,

        editdistance(
            o.first_name_normalised,
            b.first_name_normalised,
            4
        )                                                         as first_name_edit_distance,

        editdistance(
            o.last_name_normalised,
            b.last_name_normalised,
            4
        )                                                         as last_name_edit_distance,

        case
            when o.email_normalised is null or b.email_normalised is null then null
            else jarowinkler_similarity(o.email_normalised, b.email_normalised)
        end                                                       as email_similarity,

        case
            when o.phone_normalised is null or b.phone_normalised is null then false
            when right(o.phone_normalised, 7) = right(b.phone_normalised, 7) then true
            else false
        end                                                       as phone_last_7_match

    from onemind o
    inner join brightpath b
        on o.date_of_birth = b.date_of_birth
       and o.first_name_normalised is not null
       and b.first_name_normalised is not null
       and o.last_name_normalised is not null
       and b.last_name_normalised is not null
       and (
               soundex(o.last_name_normalised) = soundex(b.last_name_normalised)
            or jarowinkler_similarity(o.last_name_normalised, b.last_name_normalised) >= 80
            or (
                   o.postcode_normalised is not null
               and b.postcode_normalised is not null
               and (
                       o.postcode_normalised = b.postcode_normalised
                    or left(o.postcode_normalised, greatest(length(o.postcode_normalised) - 3, 1))
                       = left(b.postcode_normalised, greatest(length(b.postcode_normalised) - 3, 1))
               )
            )
       )

)

select *
from candidates
