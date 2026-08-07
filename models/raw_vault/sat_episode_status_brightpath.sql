{{ config(materialized='incremental', unique_key='episode_status_satellite_pk', incremental_strategy='merge') }}
select
 sha2(episode_hk||'|'||source_episode_status_id||'|'||coalesce(status_ts::varchar,''),256) as episode_status_satellite_pk,
 episode_hk, episode_status_hashdiff as hashdiff, current_timestamp()::timestamp_ntz as load_datetime,
 record_source, source_created_at, source_updated_at, status_ts, episode_state, reason
from {{ ref('stg_brightpath__episode_status_history') }}
{% if is_incremental() %}
where sha2(episode_hk||'|'||source_episode_status_id||'|'||coalesce(status_ts::varchar,''),256)
 not in (select episode_status_satellite_pk from {{ this }})
{% endif %}
