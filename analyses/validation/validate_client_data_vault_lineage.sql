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
from {{ ref('dim_client') }}
