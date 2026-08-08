{{ config(materialized='incremental', unique_key='referral_satellite_pk', incremental_strategy='merge') }}
with source_data as (
 select sha2(referral_hk||'|'||referral_hashdiff||'|'||coalesce(source_updated_at::varchar,''),256) as referral_satellite_pk,
        referral_hk, referral_hashdiff as hashdiff, current_timestamp()::timestamp_ntz as load_datetime, record_source, source_created_at, source_updated_at,
        referral_received_at,
        referral_source,
        presenting_problem,
        initial_severity,
        urgent_flag,
        referral_status
 from {{ ref('stg_brightpath__referrals') }}
), current_satellite as (
 {% if is_incremental() %} select referral_hk, hashdiff from {{ this }} qualify row_number() over(partition by referral_hk order by load_datetime desc)=1 {% else %} select null referral_hk, null hashdiff where 1=0 {% endif %}
)
select s.* from source_data s left join current_satellite c on s.referral_hk=c.referral_hk
where c.referral_hk is null or s.hashdiff<>c.hashdiff
