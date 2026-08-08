select * from {{ ref('fact_session') }} where completed_session_count=1 and clinician_key is null
