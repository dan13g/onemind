/*
    Reconstructs the current source-client record from the Raw Vault.

    The hub is the authoritative list of source-qualified client identities.
    Descriptive attributes are obtained from the latest row in the appropriate
    source satellite. This prevents downstream Business Vault models from
    bypassing HUB_CLIENT.
*/

with client_hub as (

    select
        client_hk,
        source_client_business_key,
        record_source,
        load_datetime as hub_load_datetime
    from {{ ref('hub_client') }}

),

onemind_latest_satellite as (

    select *
    from {{ ref('sat_client_onemind') }}
    qualify row_number() over (
        partition by client_hk
        order by load_datetime desc, source_updated_at desc nulls last
    ) = 1

),

brightpath_latest_satellite as (

    select *
    from {{ ref('sat_client_brightpath') }}
    qualify row_number() over (
        partition by client_hk
        order by load_datetime desc, source_updated_at desc nulls last
    ) = 1

),

latest_satellite as (

    select * from onemind_latest_satellite
    union all
    select * from brightpath_latest_satellite

)

select
    hub.client_hk,
    hub.source_client_business_key,
    hub.record_source,
    hub.hub_load_datetime,

    sat.client_satellite_pk,
    sat.hashdiff,
    sat.load_datetime as satellite_load_datetime,
    sat.source_created_at,
    sat.source_updated_at,

    sat.nhs_number_normalised,
    sat.local_client_reference,
    sat.title,
    sat.first_name,
    sat.last_name,
    sat.first_name_normalised,
    sat.last_name_normalised,
    sat.date_of_birth,
    sat.gender,
    sat.email_normalised,
    sat.phone_normalised,
    sat.address_line_1,
    sat.town_city,
    sat.postcode,
    sat.postcode_normalised,
    sat.ethnicity,
    sat.registered_gp_org_id,
    sat.employer_org_id,
    sat.consent_to_contact,
    sat.deceased_flag

from client_hub hub
inner join latest_satellite sat
    on hub.client_hk = sat.client_hk
   and hub.record_source = sat.record_source
