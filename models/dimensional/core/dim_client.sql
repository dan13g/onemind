{{
    config(
        materialized='table'
    )
}}

with mastered as (

    select *
    from {{ ref('bv_master_client_current') }}

),

with_age as (

    select
        master_client_hk,
        first_name,
        last_name,
        date_of_birth,

        case
            when date_of_birth is null then null
            else datediff('year', date_of_birth, current_date())
              - iff(
                    dateadd(
                        'year',
                        datediff('year', date_of_birth, current_date()),
                        date_of_birth
                    ) > current_date(),
                    1,
                    0
                )
        end                                                       as age_years,

        gender,
        email_normalised,
        phone_normalised,
        postcode,
        postcode_normalised,
        nhs_number_normalised,
        first_seen_at,
        most_recent_source_update_at,
        source_system_count,
        has_onemind_record,
        has_brightpath_record,
        assignment_type

    from mastered

),

dimension as (

    select
        hash(master_client_hk)                                   as client_key,
        master_client_hk,

        first_name,
        last_name,
        trim(coalesce(first_name, '') || ' ' || coalesce(last_name, ''))
                                                                    as client_full_name,
        date_of_birth,
        age_years,

        case
            when age_years is null then 'UNKNOWN'
            when age_years < 18 then 'UNDER 18'
            when age_years between 18 and 24 then '18-24'
            when age_years between 25 and 34 then '25-34'
            when age_years between 35 and 44 then '35-44'
            when age_years between 45 and 54 then '45-54'
            when age_years between 55 and 64 then '55-64'
            else '65+'
        end                                                       as age_band,

        gender,
        email_normalised                                         as email_address,
        phone_normalised                                         as phone_number,
        postcode,
        case
            when postcode_normalised is null then null
            when length(postcode_normalised) <= 3 then postcode_normalised
            else left(postcode_normalised, length(postcode_normalised) - 3)
        end                                                       as postcode_outward_code,
        nhs_number_normalised                                    as nhs_number,

        first_seen_at,
        most_recent_source_update_at,
        source_system_count,
        has_onemind_record,
        has_brightpath_record,
        assignment_type,

        current_timestamp()::timestamp_ntz                       as dw_loaded_at

    from with_age

)

select *
from dimension
