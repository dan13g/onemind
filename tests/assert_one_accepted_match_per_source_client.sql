with all_members as (

    select onemind_client_hk as client_hk
    from {{ ref('bv_client_match') }}

    union all

    select brightpath_client_hk as client_hk
    from {{ ref('bv_client_match') }}

)

select
    client_hk,
    count(*) as accepted_match_count
from all_members
group by client_hk
having count(*) > 1
