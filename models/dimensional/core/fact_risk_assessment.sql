{{ config(materialized='table') }}
with r as (
 select risk_assessment_hk,assessed_at,risk_domain,risk_level,safety_plan_required as escalation_required from {{ ref('sat_risk_assessment_onemind') }}
 qualify row_number() over(partition by risk_assessment_hk order by source_updated_at desc,load_datetime desc)=1
 union all
 select risk_assessment_hk,assessed_at,risk_domain,risk_level,escalation_required from {{ ref('sat_risk_assessment_brightpath') }}
 qualify row_number() over(partition by risk_assessment_hk order by source_updated_at desc,load_datetime desc)=1
)
select hash(r.risk_assessment_hk) risk_assessment_key, hash(j.master_client_hk) client_key,
 r.*, to_number(to_char(r.assessed_at::date,'YYYYMMDD')) risk_date_key, 1 risk_assessment_count
from r join {{ ref('link_episode_risk_assessment') }} l on r.risk_assessment_hk=l.risk_assessment_hk
join {{ ref('bridge_client_journey') }} j on l.episode_hk=j.episode_hk
