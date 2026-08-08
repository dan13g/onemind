{{ config(materialized='table') }}
select h.client_hk,
       max(s.load_datetime) as latest_client_satellite_load_datetime,
       current_timestamp()::timestamp_ntz as snapshot_datetime
from {{ ref('hub_client') }} h
left join (
 select client_hk,load_datetime from {{ ref('sat_client_onemind') }}
 union all select client_hk,load_datetime from {{ ref('sat_client_brightpath') }}
) s on h.client_hk=s.client_hk
group by h.client_hk
