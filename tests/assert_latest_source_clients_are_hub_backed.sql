-- Every Business Vault current source-client row must correspond to HUB_CLIENT.
select latest.client_hk
from {{ ref('bv_source_client_latest') }} latest
left join {{ ref('hub_client') }} hub
    on latest.client_hk = hub.client_hk
where hub.client_hk is null
