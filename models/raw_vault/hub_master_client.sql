{{
    config(
        materialized='incremental',
        unique_key='master_client_hk',
        incremental_strategy='merge'
    )
}}

with source_data as (

    select distinct
        master_client_hk,
        master_client_hk                                        as master_client_business_key,
        current_timestamp()::timestamp_ntz                      as load_datetime,
        'BUSINESS_VAULT_CLIENT_MATCHING'                         as record_source
    from {{ ref('bv_master_client_assignment') }}

)

select *
from source_data

{% if is_incremental() %}
where master_client_hk not in (
    select master_client_hk
    from {{ this }}
)
{% endif %}
