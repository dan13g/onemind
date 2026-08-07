{{ config(materialized='table') }}
with g as (
 select goal_hk,goal_description,goal_status,review_date as review_at from {{ ref('sat_goal_onemind') }}
 qualify row_number() over(partition by goal_hk order by source_updated_at desc,load_datetime desc)=1
 union all
 select goal_hk,goal_description,progress_rating::varchar as goal_status,review_ts as review_at from {{ ref('sat_goal_brightpath') }}
 qualify row_number() over(partition by goal_hk order by source_updated_at desc,load_datetime desc)=1
)
select hash(g.goal_hk) goal_key, hash(j.master_client_hk) client_key,g.*,1 goal_count
from g join {{ ref('link_episode_goal') }} l on g.goal_hk=l.goal_hk
join {{ ref('bridge_client_journey') }} j on l.episode_hk=j.episode_hk
