{{ config(materialized='table') }}
select hash(a.assessment_hk) assessment_key, hash(j.master_client_hk) client_key,
       a.assessment_hk, j.master_client_hk,
       to_number(to_char(a.assessment_at::date,'YYYYMMDD')) assessment_date_key,
       a.assessment_at, a.assessment_type, a.accepted_for_treatment, 1 assessment_count
from {{ ref('bv_assessment_current') }} a
join {{ ref('bridge_client_journey') }} j on a.assessment_hk=j.assessment_hk
