{{
    config(
        materialized='incremental',
        unique_key='client_satellite_pk',
        incremental_strategy='merge'
    )
}}

with source_data as (

    select
        sha2(
            client_hk || '|' || client_hashdiff || '|' ||
            coalesce(source_updated_at::varchar, ''),
            256
        )                                                       as client_satellite_pk,
        client_hk,
        client_hashdiff                                         as hashdiff,
        current_timestamp()::timestamp_ntz                      as load_datetime,
        record_source,
        source_updated_at,

        nhs_number_normalised,
        local_client_reference,
        title,
        first_name,
        last_name,
        first_name_normalised,
        last_name_normalised,
        date_of_birth,
        gender,
        email_normalised,
        phone_normalised,
        address_line_1,
        town_city,
        postcode,
        postcode_normalised,
        ethnicity,
        registered_gp_org_id,
        employer_org_id,
        consent_to_contact,
        deceased_flag

    from {{ ref('stg_onemind__clients') }}

)

{% if is_incremental() %}

, current_satellite as (

    select
        client_hk,
        hashdiff
    from {{ this }}
    qualify row_number() over (
        partition by client_hk
        order by load_datetime desc
    ) = 1

)

select source_data.*
from source_data
left join current_satellite
    on source_data.client_hk = current_satellite.client_hk
where current_satellite.client_hk is null
   or source_data.hashdiff <> current_satellite.hashdiff

{% else %}

select *
from source_data

{% endif %}
