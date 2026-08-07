{{ config(materialized='table') }}
select hash(organisation_hk) as organisation_key, organisation_hk, organisation_name, record_source,
       current_timestamp()::timestamp_ntz dw_loaded_at
from {{ ref('bv_organisation_current') }}
