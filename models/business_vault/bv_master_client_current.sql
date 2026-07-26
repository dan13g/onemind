/*
    Produces the current golden/mastered client record by traversing the
    persisted Data Vault structures:

        HUB_MASTER_CLIENT
          -> LINK_MASTER_CLIENT_SOURCE_CLIENT
          -> HUB_CLIENT
          -> BV_SOURCE_CLIENT_LATEST (hub + latest satellites)

    This makes both hubs and the mastering link part of the actual downstream
    lineage used by DIM_CLIENT.
*/

with master_hub as (

    select
        master_client_hk,
        master_client_business_key,
        load_datetime as master_hub_load_datetime,
        record_source as master_record_source
    from {{ ref('hub_master_client') }}

),

master_source_link as (

    select
        master_client_source_client_lk,
        master_client_hk,
        client_hk,
        load_datetime as link_load_datetime,
        record_source as link_record_source
    from {{ ref('link_master_client_source_client') }}

),

source_hub as (

    select
        client_hk,
        source_client_business_key,
        record_source,
        load_datetime as source_hub_load_datetime
    from {{ ref('hub_client') }}

),

latest_source_attributes as (

    select *
    from {{ ref('bv_source_client_latest') }}

),

assignment_metadata as (

    select
        master_client_hk,
        client_hk,
        assignment_type,
        match_rule,
        match_score,
        match_method,
        assignment_datetime
    from {{ ref('bv_master_client_assignment') }}

),

master_members as (

    select
        master.master_client_hk,
        master.master_client_business_key,
        link.master_client_source_client_lk,
        source.client_hk,
        source.source_client_business_key,
        source.record_source,
        attributes.* exclude (client_hk, source_client_business_key, record_source),
        assignment.assignment_type,
        assignment.match_rule,
        assignment.match_score,
        assignment.match_method,
        assignment.assignment_datetime
    from master_hub master
    inner join master_source_link link
        on master.master_client_hk = link.master_client_hk
    inner join source_hub source
        on link.client_hk = source.client_hk
    inner join latest_source_attributes attributes
        on source.client_hk = attributes.client_hk
    left join assignment_metadata assignment
        on master.master_client_hk = assignment.master_client_hk
       and source.client_hk = assignment.client_hk

),

mastered as (

    select
        master_client_hk,
        max(master_client_business_key)                          as master_client_business_key,

        coalesce(
            max(case when record_source = 'ONEMIND' then first_name end),
            max(case when record_source = 'BRIGHTPATH' then first_name end)
        )                                                        as first_name,

        coalesce(
            max(case when record_source = 'ONEMIND' then last_name end),
            max(case when record_source = 'BRIGHTPATH' then last_name end)
        )                                                        as last_name,

        coalesce(
            max(case when record_source = 'ONEMIND' then date_of_birth end),
            max(case when record_source = 'BRIGHTPATH' then date_of_birth end)
        )                                                        as date_of_birth,

        coalesce(
            max(case when record_source = 'ONEMIND' then gender end),
            max(case when record_source = 'BRIGHTPATH' then gender end)
        )                                                        as gender,

        coalesce(
            max(case when record_source = 'ONEMIND' then email_normalised end),
            max(case when record_source = 'BRIGHTPATH' then email_normalised end)
        )                                                        as email_normalised,

        coalesce(
            max(case when record_source = 'ONEMIND' then phone_normalised end),
            max(case when record_source = 'BRIGHTPATH' then phone_normalised end)
        )                                                        as phone_normalised,

        coalesce(
            max(case when record_source = 'ONEMIND' then postcode end),
            max(case when record_source = 'BRIGHTPATH' then postcode end)
        )                                                        as postcode,

        coalesce(
            max(case when record_source = 'ONEMIND' then postcode_normalised end),
            max(case when record_source = 'BRIGHTPATH' then postcode_normalised end)
        )                                                        as postcode_normalised,

        coalesce(
            max(case when record_source = 'ONEMIND' then nhs_number_normalised end),
            max(case when record_source = 'BRIGHTPATH' then nhs_number_normalised end)
        )                                                        as nhs_number_normalised,

        min(source_created_at)                                   as first_seen_at,
        max(source_updated_at)                                   as most_recent_source_update_at,

        count(distinct record_source)                            as source_system_count,
        count_if(record_source = 'ONEMIND') > 0                 as has_onemind_record,
        count_if(record_source = 'BRIGHTPATH') > 0              as has_brightpath_record,

        max(assignment_type)                                     as assignment_type,
        max(match_rule)                                          as match_rule,
        max(match_score)                                         as match_score,
        max(match_method)                                        as match_method,
        max(assignment_datetime)                                 as assignment_datetime

    from master_members
    group by master_client_hk

)

select *
from mastered
