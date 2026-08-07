{{ config(materialized='table') }}
with o as (
 select outcome_score_hk,measure_name,score_value,score_date from {{ ref('sat_outcome_score_onemind') }}
 qualify row_number() over(partition by outcome_score_hk order by source_updated_at desc,load_datetime desc)=1
 union all
 select outcome_score_hk,measure_name,score_value,score_date from {{ ref('sat_outcome_score_brightpath') }}
 qualify row_number() over(partition by outcome_score_hk order by source_updated_at desc,load_datetime desc)=1
)
select hash(o.outcome_score_hk) outcome_key, hash(j.master_client_hk) client_key,
       o.outcome_score_hk, j.master_client_hk, l.session_hk,
       to_number(to_char(o.score_date,'YYYYMMDD')) outcome_date_key,
       o.measure_name,o.score_value,1 outcome_measure_count
from o join {{ ref('link_session_outcome_score') }} l on o.outcome_score_hk=l.outcome_score_hk
join {{ ref('bridge_client_journey') }} j on l.session_hk=j.session_hk
