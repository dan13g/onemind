select * exclude(rn) from (
select organisation_hk, record_source, organisation_name, row_number() over(partition by organisation_hk order by source_updated_at desc, load_datetime desc) rn from {{ ref('sat_organisation_onemind') }}
union all
select organisation_hk, record_source, organisation_name, row_number() over(partition by organisation_hk order by source_updated_at desc, load_datetime desc) rn from {{ ref('sat_organisation_brightpath') }}
) where rn=1
