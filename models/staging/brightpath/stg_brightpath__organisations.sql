with source as (

    select
        "organisation_key" as organisation_key,
        "organisation_name" as organisation_name,
        "sector" as sector,
        "contract_start_date" as contract_start_date,
        "contract_end_date" as contract_end_date,
        "account_manager" as account_manager,
        "active" as active,
        "created_ts" as created_ts,
        "modified_ts" as modified_ts
    from {{ source('brightpath_raw', 'brightpath_organisations') }}

)

select
    organisation_key::varchar as source_organisation_id,
    'BRIGHTPATH|' || organisation_key::varchar as organisation_bk,
    sha2('BRIGHTPATH|' || organisation_key::varchar,256) as organisation_hk,
    organisation_name,
    sector,
    contract_start_date,
    contract_end_date,
    account_manager,
    active,
    created_ts::timestamp_ntz as source_created_at,
    modified_ts::timestamp_ntz as source_updated_at,
    'BRIGHTPATH' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(organisation_name::varchar,''),coalesce(sector::varchar,''),coalesce(contract_start_date::varchar,''),coalesce(contract_end_date::varchar,''),coalesce(account_manager::varchar,''),coalesce(active::varchar,'')),256) as organisation_hashdiff
from source
