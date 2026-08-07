{{ config(materialized='table') }}
select hash(c.clinician_hk) as clinician_key, c.clinician_hk,
       c.first_name, c.last_name, trim(coalesce(c.first_name,'')||' '||coalesce(c.last_name,'')) clinician_full_name,
       c.professional_role, c.registration_number, c.record_source, current_timestamp()::timestamp_ntz dw_loaded_at
from {{ ref('bv_clinician_current') }} c
