-- Every assignment must be persisted through the master-to-source Data Vault link.
select
    assignment.master_client_hk,
    assignment.client_hk
from {{ ref('bv_master_client_assignment') }} assignment
left join {{ ref('link_master_client_source_client') }} link
    on assignment.master_client_hk = link.master_client_hk
   and assignment.client_hk = link.client_hk
where link.master_client_source_client_lk is null
