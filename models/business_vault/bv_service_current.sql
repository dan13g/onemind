select * exclude(rn) from (
select service_hk, record_source, service_code, service_name, row_number() over(partition by service_hk order by source_updated_at desc, load_datetime desc) rn from {{ ref('sat_service_onemind') }}
union all
select service_hk, record_source, service_code, service_name, row_number() over(partition by service_hk order by source_updated_at desc, load_datetime desc) rn from {{ ref('sat_service_brightpath') }}
) where rn=1
