{{ config(materialized='table') }}
select hash(service_hk) as service_key, service_hk, service_code, service_name, record_source,
       current_timestamp()::timestamp_ntz dw_loaded_at
from {{ ref('bv_service_current') }}
