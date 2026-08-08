select * exclude(rn) from (
select episode_hk, record_source, episode_start_date, episode_end_date, primary_problem, discharge_reason, outcome_status, row_number() over(partition by episode_hk order by source_updated_at desc, load_datetime desc) rn from {{ ref('sat_episode_onemind') }}
union all
select episode_hk, record_source, episode_start_date, episode_end_date, primary_problem, discharge_reason, outcome_status, row_number() over(partition by episode_hk order by source_updated_at desc, load_datetime desc) rn from {{ ref('sat_episode_brightpath') }}
) where rn=1
