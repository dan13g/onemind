{{ config(materialized='table') }}
select hash(s.session_hk) session_key, hash(j.master_client_hk) client_key,
       hash(sc.clinician_hk) clinician_key,
       s.session_hk, j.master_client_hk,
       to_number(to_char(s.session_start_at::date,'YYYYMMDD')) session_date_key,
       s.session_start_at, s.session_end_at, s.duration_minutes, s.session_type, s.delivery_channel, s.attendance_status,
       iff(upper(s.attendance_status) in ('ATTENDED','COMPLETE'),1,0) completed_session_count,
       iff(upper(s.attendance_status) in ('DNA','NO_SHOW'),1,0) dna_session_count,
       iff(upper(s.attendance_status) like '%CANCEL%' or upper(s.attendance_status) in ('CLIENT_CANCEL','PROVIDER_CANCEL'),1,0) cancelled_session_count
from {{ ref('bv_session_current') }} s
join {{ ref('bridge_client_journey') }} j on s.session_hk=j.session_hk
left join {{ ref('link_session_clinician') }} sc on s.session_hk=sc.session_hk
