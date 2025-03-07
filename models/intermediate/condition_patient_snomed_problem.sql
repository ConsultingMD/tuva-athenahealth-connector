select
      cast(psp.contextid as {{ dbt.type_string() }} ) || '.pat_sno_prob.' || cast(psp.patientsnomedproblemid as {{ dbt.type_string() }} ) as condition_id --event id?
    , cast(psp.contextid as {{ dbt.type_string() }} ) || '.' || cast(c.enterpriseid as {{ dbt.type_string() }} ) as person_id
    , cast(psp.contextid as {{ dbt.type_string() }} ) || '.' || cast(c.enterpriseid as {{ dbt.type_string() }} ) as patient_id
    , cast(null as {{ dbt.type_string() }} ) as encounter_id
    , cast(null as {{ dbt.type_string() }} ) as claim_id
    , cast(psp.createddatetime as date) as recorded_date
    , cast(psp.startdatedatetime as date) as onset_date
    , cast(psp.enddatedatetime as date) as resolved_date
    , cast(psp.status as {{ dbt.type_string() }} ) as status
    , cast('problem' as {{ dbt.type_string() }} ) as condition_type
    , cast('snomed-ct' as {{ dbt.type_string() }} ) as source_code_type
    , cast(psp.snomedcode as {{ dbt.type_string() }} ) as source_code
    , cast(null as {{ dbt.type_string() }} ) as source_description
    , cast(null as {{ dbt.type_string() }} ) as normalized_code_type
    , cast(null as {{ dbt.type_string() }} ) as normalized_code
    , cast(null as {{ dbt.type_string() }} ) as normalized_description
    , cast(null as {{ dbt.type_int() }} ) as condition_rank
    , cast(null as {{ dbt.type_string() }} ) as present_on_admit_code
    , cast(null as {{ dbt.type_string() }} ) as present_on_admit_description
    , cast('athena.' || psp.contextname  as {{ dbt.type_string() }} ) as data_source
    , cast(null as {{ dbt.type_string() }} ) as file_name
    , cast(null as {{ dbt.type_timestamp() }} ) as ingest_datetime
--select top 100 *
from {{source('athena','dataview_imports__patientsnomedproblem__v1')}} psp
left join {{source('athena','dataview_imports__chart__v1')}} c
    on psp.chartid = c.chartid and psp.contextid = c.contextid
where psp.deleteddatetime is null and psp.deletedby is null
