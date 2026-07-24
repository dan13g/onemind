with assigned_clients as (

    select
        assignment.master_client_hk,
        assignment.assignment_type,
        latest.*
    from {{ ref('bv_master_client_assignment') }} assignment
    inner join {{ ref('bv_source_client_latest') }} latest
        on assignment.client_hk = latest.client_hk

),

mastered as (

    select
        master_client_hk,

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

        max(assignment_type)                                     as assignment_type

    from assigned_clients
    group by master_client_hk

)

select *
from mastered
