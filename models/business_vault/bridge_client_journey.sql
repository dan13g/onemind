{{ config(materialized='table') }}
select
  a.master_client_hk,
  lcr.client_hk,
  lcr.referral_hk,
  lra.assessment_hk,
  lre.episode_hk,
  les.session_hk
from {{ ref('link_master_client_source_client') }} a
join {{ ref('link_client_referral') }} lcr on a.client_hk=lcr.client_hk
left join {{ ref('link_referral_assessment') }} lra on lcr.referral_hk=lra.referral_hk
left join {{ ref('link_referral_episode') }} lre on lcr.referral_hk=lre.referral_hk
left join {{ ref('link_episode_session') }} les on lre.episode_hk=les.episode_hk
