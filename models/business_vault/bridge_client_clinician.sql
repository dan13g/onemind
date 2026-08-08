{{ config(materialized='table') }}
select distinct j.master_client_hk, j.session_hk, sc.clinician_hk
from {{ ref('bridge_client_journey') }} j
join {{ ref('link_session_clinician') }} sc on j.session_hk=sc.session_hk
