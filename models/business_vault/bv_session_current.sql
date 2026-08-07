select * exclude(rn) from (
select session_hk, record_source, session_start_at, session_end_at, duration_minutes, session_type, delivery_channel, attendance_status, row_number() over(partition by session_hk order by source_updated_at desc, load_datetime desc) rn from {{ ref('sat_session_onemind') }}
union all
select session_hk, record_source, session_start_at, session_end_at, duration_minutes, session_type, delivery_channel, attendance_status, row_number() over(partition by session_hk order by source_updated_at desc, load_datetime desc) rn from {{ ref('sat_session_brightpath') }}
) where rn=1
