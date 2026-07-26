-- Run after dbt build to inspect the complete client lineage.

select 'HUB_CLIENT' as object_name, count(*) as row_count
from {{ ref('hub_client') }}
union all
select 'BV_SOURCE_CLIENT_LATEST', count(*)
from {{ ref('bv_source_client_latest') }}
union all
select 'BV_MASTER_CLIENT_ASSIGNMENT', count(*)
from {{ ref('bv_master_client_assignment') }}
union all
select 'HUB_MASTER_CLIENT', count(*)
from {{ ref('hub_master_client') }}
union all
select 'LINK_MASTER_CLIENT_SOURCE_CLIENT', count(*)
from {{ ref('link_master_client_source_client') }}
union all
select 'BV_MASTER_CLIENT_CURRENT', count(*)
from {{ ref('bv_master_client_current') }}
union all
select 'DIM_CLIENT', count(*)
from {{ ref('dim_client') }};

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
order by master.master_client_hk, source.record_source;
