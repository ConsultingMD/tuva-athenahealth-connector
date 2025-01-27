with registration_cte as (
select
      cast(patient.contextid as {{ dbt.type_string() }} ) || '.' || cast( patient.enterpriseid as {{ dbt.type_string() }} ) as person_id
    , cast(patient.contextid as {{ dbt.type_string() }} ) || '.' || cast( patient.enterpriseid as {{ dbt.type_string() }} ) as patient_id
    , cast(client.plcfirstname as {{ dbt.type_string() }} ) as first_name
    , cast(client.plclastname as {{ dbt.type_string() }} ) as last_name
    , cast(case client.sex when 'F' then 'female' when 'M' then 'male' else 'unknown' end as {{ dbt.type_string() }} ) as sex
    , cast(lower(patientrace.RACE) as {{ dbt.type_string() }} ) as race
    , cast(client.dobdatetime as date) as birth_date
    , cast(client.deceaseddatedatetime as date) as death_date
    , cast(case when client.DECEASEDDATEDATETIME is not null then '1' end as {{ dbt.type_int() }} ) as death_flag
    , cast(null as {{ dbt.type_string() }} ) as social_security_number
    , cast(patient.address || coalesce(' ' || patient.address2,'') as {{ dbt.type_string() }} ) as address
    , cast(patient.city as {{ dbt.type_string() }} ) as city
    , cast(patient.state as {{ dbt.type_string() }} ) as state
    , cast(patient.zip as {{ dbt.type_string() }} ) as zip_code
    , cast(null as {{ dbt.type_string() }} ) as county
    , cast(null as {{ dbt.type_float() }} ) as latitude
    , cast(null as {{ dbt.type_float() }} ) as longitude
    , cast(patient.patienthomephone as {{ dbt.type_string() }}) as phone
    , cast('athena.' || patient.contextname as {{ dbt.type_string() }} ) as data_source
    , cast(null as {{ dbt.type_string() }} ) as file_name
    , cast(patient.lastupdated as {{ dbt.type_timestamp() }} ) as ingest_datetime
    , row_number() over(partition by patient.contextid, patient.enterpriseid
                    order by patient.registrationdate desc,
                    case when patient.currentdepartmentid = patient.registrationdepartmentid then 0
                        when patient.currentdepartmentid is not null then 1
                        when patient.registrationdepartmentid is not null then 2
                        else 999 end
                     ) as registration_order
-- select *
from {{source('athena','PATIENT')}} as patient
inner join {{source('athena','CLIENT')}} as client
on patient.patientid = client.clientid and patient.contextid = client.contextid
left join {{source('athena','PATIENTRACE')}} as patientrace
    on patient.patientid = patientrace.patientid and patient.contextid = patientrace.contextid
        and patientrace.deleteddatetime is null and patientrace.deletedby is null and patientrace.primaryraceyn = 'Y'
where patient.deletedby is null and patient.deleteddatetime is null
)

select
     person_id
    ,patient_id
    ,first_name
    ,last_name
    ,sex
    ,race
    ,birth_date
    ,death_date
    ,death_flag
    ,social_security_number
    ,address
    ,city
    ,state
    ,zip_code
    ,county
    ,latitude
    ,longitude
    ,phone
    ,data_source
    ,file_name
    ,ingest_datetime
from registration_cte
where registration_order = 1