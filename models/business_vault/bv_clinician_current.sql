select * exclude(rn) from (
select clinician_hk, record_source, first_name, last_name, professional_role, registration_number, row_number() over(partition by clinician_hk order by source_updated_at desc, load_datetime desc) rn from {{ ref('sat_clinician_onemind') }}
union all
select clinician_hk, record_source, first_name, last_name, professional_role, registration_number, row_number() over(partition by clinician_hk order by source_updated_at desc, load_datetime desc) rn from {{ ref('sat_clinician_brightpath') }}
) where rn=1
