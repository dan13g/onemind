{{ config(materialized='table') }}
with first_session as (
 select j.referral_hk, min(s.session_start_at) first_session_at
 from {{ ref('bridge_client_journey') }} j
 join {{ ref('bv_session_current') }} s on j.session_hk=s.session_hk
 group by j.referral_hk
)
select r.referral_hk, r.referral_received_at, f.first_session_at,
       datediff('day',r.referral_received_at::date,f.first_session_at::date) as days_to_first_session
from {{ ref('bv_referral_current') }} r left join first_session f on r.referral_hk=f.referral_hk
