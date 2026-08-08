with source as (

    select
        "care_plan_goal_key" as care_plan_goal_key,
        "episode_key" as episode_key,
        "goal_description" as goal_description,
        "progress_rating" as progress_rating,
        "review_ts" as review_ts,
        "created_ts" as created_ts,
        "modified_ts" as modified_ts
    from {{ source('brightpath_raw', 'brightpath_care_plan_goals') }}

)

select
    care_plan_goal_key::varchar as source_goal_id,
    'BRIGHTPATH|' || care_plan_goal_key::varchar as goal_bk,
    sha2('BRIGHTPATH|' || care_plan_goal_key::varchar,256) as goal_hk,
    sha2('BRIGHTPATH|' || episode_key::varchar,256) as episode_hk,
    episode_key::varchar as episode_id,
    goal_description,
    progress_rating,
    review_ts,
    created_ts::timestamp_ntz as source_created_at,
    modified_ts::timestamp_ntz as source_updated_at,
    'BRIGHTPATH' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(goal_description::varchar,''),coalesce(progress_rating::varchar,''),coalesce(review_ts::varchar,'')),256) as goal_hashdiff,
    sha2(concat_ws('|',sha2('BRIGHTPATH|' || episode_key::varchar,256),sha2('BRIGHTPATH|' || care_plan_goal_key::varchar,256)),256) as episode_goal_lk
from source
