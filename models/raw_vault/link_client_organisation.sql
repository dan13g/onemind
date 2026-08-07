{{ config(materialized='incremental', unique_key='client_organisation_lk', incremental_strategy='merge') }}
with candidates as (
 select sha2(concat_ws('|',client_hk,sha2('ONEMIND|'||employer_org_id,256),'EMPLOYER'),256) client_organisation_lk,
        client_hk, sha2('ONEMIND|'||employer_org_id,256) organisation_hk, 'EMPLOYER' organisation_role,
        record_source, dbt_loaded_at load_datetime
 from {{ ref('stg_onemind__clients') }} where employer_org_id is not null
 union all
 select sha2(concat_ws('|',client_hk,sha2('ONEMIND|'||registered_gp_org_id,256),'REGISTERED_GP'),256),
        client_hk, sha2('ONEMIND|'||registered_gp_org_id,256), 'REGISTERED_GP', record_source, dbt_loaded_at
 from {{ ref('stg_onemind__clients') }} where registered_gp_org_id is not null
 union all
 select sha2(concat_ws('|',client_hk,sha2('BRIGHTPATH|'||employer_org_id,256),'EMPLOYER'),256),
        client_hk, sha2('BRIGHTPATH|'||employer_org_id,256), 'EMPLOYER', record_source, dbt_loaded_at
 from {{ ref('stg_brightpath__clients') }} where employer_org_id is not null
), d as (select * from candidates qualify row_number() over(partition by client_organisation_lk order by load_datetime)=1)
select * from d
{% if is_incremental() %} where client_organisation_lk not in (select client_organisation_lk from {{ this }}) {% endif %}
