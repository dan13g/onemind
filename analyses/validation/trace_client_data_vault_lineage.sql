-- Trace source identities through both hubs and the mastering link.
select
    master.master_client_hk,
    source.source_client_business_key,
    source.record_source,
    assignment.assignment_type,
    assignment.match_method,
    assignment.match_rule,
    assignment.match_score
from {{ ref('hub_master_client') }} master
join {{ ref('link_master_client_source_client') }} link
    on master.master_client_hk = link.master_client_hk
join {{ ref('hub_client') }} source
    on link.client_hk = source.client_hk
join {{ ref('bv_master_client_assignment') }} assignment
    on link.master_client_hk = assignment.master_client_hk
   and link.client_hk = assignment.client_hk
order by master.master_client_hk, source.record_source
