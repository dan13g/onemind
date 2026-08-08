{{ config(materialized='table') }}
select hash(r.referral_hk) referral_key, hash(a.master_client_hk) client_key,
       r.referral_hk, a.master_client_hk,
       to_number(to_char(r.referral_received_at::date,'YYYYMMDD')) referral_date_key,
       r.referral_received_at, r.referral_source, r.presenting_problem, r.referral_status,
       w.days_to_first_session, 1 referral_count
from {{ ref('link_client_referral') }} l
join {{ ref('link_master_client_source_client') }} a on l.client_hk=a.client_hk
join {{ ref('bv_referral_current') }} r on l.referral_hk=r.referral_hk
left join {{ ref('bv_referral_waiting_time') }} w on r.referral_hk=w.referral_hk
