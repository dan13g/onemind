with source as (

    select
        "episode_status_history_key" as episode_status_history_key,
        "episode_key" as episode_key,
        "status_ts" as status_ts,
        "episode_state" as episode_state,
        "reason" as reason,
        "created_ts" as created_ts,
        "modified_ts" as modified_ts
    from {{ source('brightpath_raw', 'brightpath_episode_status_history') }}

)

select
    episode_status_history_key::varchar as source_episode_status_id,
    sha2('BRIGHTPATH|' || episode_key::varchar,256) as episode_hk,
    episode_key::varchar as episode_id,
    status_ts,
    episode_state,
    reason,
    created_ts::timestamp_ntz as source_created_at,
    modified_ts::timestamp_ntz as source_updated_at,
    'BRIGHTPATH' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(status_ts::varchar,''),coalesce(episode_state::varchar,''),coalesce(reason::varchar,'')),256) as episode_status_hashdiff
from source
