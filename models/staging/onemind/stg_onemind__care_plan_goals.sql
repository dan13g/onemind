with source as (

    select
        "care_plan_goal_id" as care_plan_goal_id,
        "episode_id" as episode_id,
        "goal_description" as goal_description,
        "goal_status" as goal_status,
        "target_date" as target_date,
        "review_date" as review_date,
        "created_at" as created_at,
        "updated_at" as updated_at
    from {{ source('onemind_raw', 'onemind_care_plan_goals') }}

)

select
    care_plan_goal_id::varchar as source_goal_id,
    'ONEMIND|' || care_plan_goal_id::varchar as goal_bk,
    sha2('ONEMIND|' || care_plan_goal_id::varchar,256) as goal_hk,
    sha2('ONEMIND|' || episode_id::varchar,256) as episode_hk,
    episode_id::varchar as episode_id,
    goal_description,
    goal_status,
    target_date,
    review_date,
    created_at::timestamp_ntz as source_created_at,
    updated_at::timestamp_ntz as source_updated_at,
    'ONEMIND' as record_source,
    current_timestamp()::timestamp_ntz as dbt_loaded_at,
    sha2(concat_ws('|',coalesce(goal_description::varchar,''),coalesce(goal_status::varchar,''),coalesce(target_date::varchar,''),coalesce(review_date::varchar,'')),256) as goal_hashdiff,
    sha2(concat_ws('|',sha2('ONEMIND|' || episode_id::varchar,256),sha2('ONEMIND|' || care_plan_goal_id::varchar,256)),256) as episode_goal_lk
from source
