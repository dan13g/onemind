-- Every source identity in HUB_CLIENT must receive exactly one master assignment.
select hub.client_hk
from {{ ref('hub_client') }} hub
left join {{ ref('bv_master_client_assignment') }} assignment
    on hub.client_hk = assignment.client_hk
group by hub.client_hk
having count(assignment.client_hk) <> 1
