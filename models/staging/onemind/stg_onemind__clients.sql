with source as (

    select *
    from {{ source('onemind_raw', 'onemind_clients') }}

),

standardised as (

    select
        client_id::varchar                                        as source_client_id,
        'ONEMIND|' || client_id::varchar                          as source_client_business_key,

        nullif(regexp_replace(trim(nhs_number), '[^0-9]', ''), '') as nhs_number_normalised,
        local_client_ref::varchar                                 as local_client_reference,
        nullif(trim(title), '')                                   as title,
        nullif(trim(first_name), '')                              as first_name,
        nullif(trim(last_name), '')                               as last_name,
        upper(nullif(trim(first_name), ''))                       as first_name_normalised,
        upper(nullif(trim(last_name), ''))                        as last_name_normalised,
        date_of_birth::date                                       as date_of_birth,
        upper(nullif(trim(gender), ''))                           as gender,

        lower(nullif(trim(email_address), ''))                    as email_normalised,
        nullif(regexp_replace(trim(mobile_phone), '[^0-9]', ''), '') as phone_normalised,

        nullif(trim(address_line_1), '')                           as address_line_1,
        nullif(trim(town_city), '')                               as town_city,
        upper(nullif(trim(postcode), ''))                         as postcode,
        upper(nullif(regexp_replace(trim(postcode), '[^A-Za-z0-9]', ''), ''))
                                                                    as postcode_normalised,
        upper(nullif(trim(ethnicity), ''))                        as ethnicity,

        registered_gp_org_id::varchar                             as registered_gp_org_id,
        employer_org_id::varchar                                  as employer_org_id,
        consent_to_contact::boolean                               as consent_to_contact,
        deceased_flag::boolean                                    as deceased_flag,

        created_at::timestamp_ntz                                 as source_created_at,
        updated_at::timestamp_ntz                                 as source_updated_at,

        'ONEMIND'                                                 as record_source,
        current_timestamp()::timestamp_ntz                        as dbt_loaded_at,

        sha2('ONEMIND|' || client_id::varchar, 256)               as client_hk,

        sha2(
            concat_ws(
                '|',
                coalesce(regexp_replace(trim(nhs_number), '[^0-9]', ''), ''),
                coalesce(upper(trim(first_name)), ''),
                coalesce(upper(trim(last_name)), ''),
                coalesce(date_of_birth::varchar, ''),
                coalesce(upper(trim(gender)), ''),
                coalesce(lower(trim(email_address)), ''),
                coalesce(regexp_replace(trim(mobile_phone), '[^0-9]', ''), ''),
                coalesce(upper(regexp_replace(trim(postcode), '[^A-Za-z0-9]', '')), ''),
                coalesce(consent_to_contact::varchar, ''),
                coalesce(deceased_flag::varchar, '')
            ),
            256
        )                                                         as client_hashdiff

    from source

)

select *
from standardised
