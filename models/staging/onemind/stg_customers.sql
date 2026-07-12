with source as (
    select *
    from {{ source('onemind', 'customers') }}
),

renamed as (
    select
        "id" as customer_id,
        "name" as customer_name,
        "created_at" as created_at,
        "ctid_fivetran_id" as customer_record_id,
        "_fivetran_deleted" as is_deleted,
        "_fivetran_synced" as fivetran_synced_at
    from source
)

select *
from renamed
