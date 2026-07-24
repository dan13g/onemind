with source as (

    select
        "client_key" as client_key,
        "nhs_no_raw" as nhs_no_raw,
        "external_client_id" as external_client_id,
        "given_name" as given_name,
        "family_name" as family_name,
        "dob" as dob,
        "sex" as sex,
        "email" as email,
        "phone" as phone,
        "postcode_raw" as postcode_raw,
        "organisation_key" as organisation_key,
        "marketing_opt_in" as marketing_opt_in,
        "created_ts" as created_ts,
        "modified_ts" as modified_ts
    from {{ source('brightpath_raw', 'brightpath_clients') }}

),

standardised as (

    select
        client_key::varchar                                       as source_client_id,
        'BRIGHTPATH|' || client_key::varchar                      as source_client_business_key,

        nullif(regexp_replace(trim(nhs_no_raw), '[^0-9]', ''), '') as nhs_number_normalised,
        external_client_id::varchar                               as local_client_reference,
        cast(null as varchar)                                     as title,
        nullif(trim(given_name), '')                              as first_name,
        nullif(trim(family_name), '')                             as last_name,
        upper(nullif(trim(given_name), ''))                       as first_name_normalised,
        upper(nullif(trim(family_name), ''))                      as last_name_normalised,
        dob::date                                                 as date_of_birth,
        upper(nullif(trim(sex), ''))                              as gender,

        lower(nullif(trim(email), ''))                            as email_normalised,
        nullif(regexp_replace(trim(phone), '[^0-9]', ''), '')     as phone_normalised,

        cast(null as varchar)                                     as address_line_1,
        cast(null as varchar)                                     as town_city,
        upper(nullif(trim(postcode_raw), ''))                     as postcode,
        upper(nullif(regexp_replace(trim(postcode_raw), '[^A-Za-z0-9]', ''), ''))
                                                                    as postcode_normalised,
        cast(null as varchar)                                     as ethnicity,

        cast(null as varchar)                                     as registered_gp_org_id,
        organisation_key::varchar                                as employer_org_id,
        marketing_opt_in::boolean                                as consent_to_contact,
        false::boolean                                            as deceased_flag,

        created_ts::timestamp_ntz                                as source_created_at,
        modified_ts::timestamp_ntz                               as source_updated_at,

        'BRIGHTPATH'                                              as record_source,
        current_timestamp()::timestamp_ntz                       as dbt_loaded_at,

        sha2('BRIGHTPATH|' || client_key::varchar, 256)          as client_hk,

        sha2(
            concat_ws(
                '|',
                coalesce(regexp_replace(trim(nhs_no_raw), '[^0-9]', ''), ''),
                coalesce(upper(trim(given_name)), ''),
                coalesce(upper(trim(family_name)), ''),
                coalesce(dob::varchar, ''),
                coalesce(upper(trim(sex)), ''),
                coalesce(lower(trim(email)), ''),
                coalesce(regexp_replace(trim(phone), '[^0-9]', ''), ''),
                coalesce(upper(regexp_replace(trim(postcode_raw), '[^A-Za-z0-9]', '')), ''),
                coalesce(marketing_opt_in::varchar, ''),
                'false'
            ),
            256
        )                                                         as client_hashdiff

    from source

)

select *
from standardised
