{{ config(materialized='table') }}
select h.episode_hk,
       max(s.load_datetime) as latest_episode_satellite_load_datetime,
       current_timestamp()::timestamp_ntz as snapshot_datetime
from {{ ref('hub_episode') }} h
left join (
 select episode_hk,load_datetime from {{ ref('sat_episode_onemind') }}
 union all select episode_hk,load_datetime from {{ ref('sat_episode_brightpath') }}
) s on h.episode_hk=s.episode_hk
group by h.episode_hk
