select * exclude(rn) from (
select referral_hk, record_source, referral_received_at, referral_source, presenting_problem, referral_status, row_number() over(partition by referral_hk order by source_updated_at desc, load_datetime desc) rn from {{ ref('sat_referral_onemind') }}
union all
select referral_hk, record_source, referral_received_at, referral_source, presenting_problem, referral_status, row_number() over(partition by referral_hk order by source_updated_at desc, load_datetime desc) rn from {{ ref('sat_referral_brightpath') }}
) where rn=1
