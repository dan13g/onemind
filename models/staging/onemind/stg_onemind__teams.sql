select
    team_id::varchar as source_team_id,
    'ONEMIND|' || team_id::varchar as team_bk,
    sha2('ONEMIND|' || team_id::varchar,256) as team_hk,
    team_code,
    team_name,
    region,
    service_line,
    active_flag,
    created_at::timestamp_ntz as source_created_at,
    updated_at::timestamp_ntz as source_updated_at,
    'ONEMIND' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(team_code::varchar,''),coalesce(team_name::varchar,''),coalesce(region::varchar,''),coalesce(service_line::varchar,''),coalesce(active_flag::varchar,'')),256) as team_hashdiff
from {{ source('onemind_raw', 'onemind_teams') }}
