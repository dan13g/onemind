{{
    config(
        materialized='incremental',
        unique_key='master_client_source_client_lk',
        incremental_strategy='merge'
    )
}}

with source_data as (

    select
        sha2(master_client_hk || '|' || client_hk, 256)          as master_client_source_client_lk,
        master_client_hk,
        client_hk,
        current_timestamp()::timestamp_ntz                      as load_datetime,
        'BUSINESS_VAULT_CLIENT_MATCHING'                         as record_source
    from {{ ref('bv_master_client_assignment') }}

)

select *
from source_data

{% if is_incremental() %}
where master_client_source_client_lk not in (
    select master_client_source_client_lk
    from {{ this }}
)
{% endif %}
