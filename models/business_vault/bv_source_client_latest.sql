with onemind_latest as (

    select *
    from {{ ref('sat_client_onemind') }}
    qualify row_number() over (
        partition by client_hk
        order by load_datetime desc
    ) = 1

),

brightpath_latest as (

    select *
    from {{ ref('sat_client_brightpath') }}
    qualify row_number() over (
        partition by client_hk
        order by load_datetime desc
    ) = 1

)

select * from onemind_latest
union all
select * from brightpath_latest
