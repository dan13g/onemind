with onemind as (

    select *
    from {{ ref('bv_source_client_latest') }}
    where record_source = 'ONEMIND'

),

brightpath as (

    select *
    from {{ ref('bv_source_client_latest') }}
    where record_source = 'BRIGHTPATH'

),

candidate_matches as (

    select
        o.client_hk                                              as onemind_client_hk,
        b.client_hk                                              as brightpath_client_hk,

        case
            when o.nhs_number_normalised is not null
             and b.nhs_number_normalised is not null
             and o.nhs_number_normalised = b.nhs_number_normalised
                then 'NHS_NUMBER_EXACT'

            when o.email_normalised is not null
             and b.email_normalised is not null
             and o.email_normalised = b.email_normalised
             and o.date_of_birth = b.date_of_birth
                then 'EMAIL_DOB_EXACT'

            when o.phone_normalised is not null
             and b.phone_normalised is not null
             and o.phone_normalised = b.phone_normalised
             and o.date_of_birth = b.date_of_birth
                then 'PHONE_DOB_EXACT'

            when o.last_name_normalised is not null
             and b.last_name_normalised is not null
             and o.last_name_normalised = b.last_name_normalised
             and o.date_of_birth = b.date_of_birth
             and o.postcode_normalised is not null
             and b.postcode_normalised is not null
             and o.postcode_normalised = b.postcode_normalised
                then 'SURNAME_DOB_POSTCODE_EXACT'
        end                                                       as match_rule,

        case
            when o.nhs_number_normalised is not null
             and b.nhs_number_normalised is not null
             and o.nhs_number_normalised = b.nhs_number_normalised
                then 100

            when o.email_normalised is not null
             and b.email_normalised is not null
             and o.email_normalised = b.email_normalised
             and o.date_of_birth = b.date_of_birth
                then 90

            when o.phone_normalised is not null
             and b.phone_normalised is not null
             and o.phone_normalised = b.phone_normalised
             and o.date_of_birth = b.date_of_birth
                then 85

            when o.last_name_normalised is not null
             and b.last_name_normalised is not null
             and o.last_name_normalised = b.last_name_normalised
             and o.date_of_birth = b.date_of_birth
             and o.postcode_normalised is not null
             and b.postcode_normalised is not null
             and o.postcode_normalised = b.postcode_normalised
                then 80
        end                                                       as match_score

    from onemind o
    inner join brightpath b
        on (
               (
                   o.nhs_number_normalised is not null
                   and b.nhs_number_normalised is not null
                   and o.nhs_number_normalised = b.nhs_number_normalised
               )
            or (
                   o.email_normalised is not null
                   and b.email_normalised is not null
                   and o.email_normalised = b.email_normalised
                   and o.date_of_birth = b.date_of_birth
               )
            or (
                   o.phone_normalised is not null
                   and b.phone_normalised is not null
                   and o.phone_normalised = b.phone_normalised
                   and o.date_of_birth = b.date_of_birth
               )
            or (
                   o.last_name_normalised is not null
                   and b.last_name_normalised is not null
                   and o.last_name_normalised = b.last_name_normalised
                   and o.date_of_birth = b.date_of_birth
                   and o.postcode_normalised is not null
                   and b.postcode_normalised is not null
                   and o.postcode_normalised = b.postcode_normalised
               )
        )

),

ranked as (

    select
        *,
        row_number() over (
            partition by onemind_client_hk
            order by match_score desc, brightpath_client_hk
        ) as onemind_match_rank,

        row_number() over (
            partition by brightpath_client_hk
            order by match_score desc, onemind_client_hk
        ) as brightpath_match_rank

    from candidate_matches
    where match_rule is not null

)

select
    onemind_client_hk,
    brightpath_client_hk,
    match_rule,
    match_score,
    'AUTO_MATCHED'                                               as match_status,
    current_timestamp()::timestamp_ntz                           as matched_at
from ranked
where onemind_match_rank = 1
  and brightpath_match_rank = 1
