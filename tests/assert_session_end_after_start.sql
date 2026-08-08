select * from {{ ref('fact_session') }} where session_end_at<=session_start_at
