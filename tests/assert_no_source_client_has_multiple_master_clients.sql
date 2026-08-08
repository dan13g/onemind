select client_hk from {{ ref('bv_master_client_assignment') }} group by client_hk having count(distinct master_client_hk)>1
