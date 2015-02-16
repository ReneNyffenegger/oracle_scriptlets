--
--   Show Objects thare are not enabled or valid
--
--   Not the same thing as DBA_INVALID_OBJECTS.
--


select  object_type         , owner, object_name    , status from dba_objects     where owner not in ('SYS', 'SYSTEM')          and status != 'VALID'   union all
select 'CONSTRAINT'         , owner, constraint_name, status from dba_constraints where owner not in ('SYS', 'SYSTEM')          and status != 'ENABLED' union all
select 'TRIGGER'            , owner, trigger_name   , status from dba_triggers    where owner not in ('SYS', 'SYSTEM', 'WMSYS') and status != 'ENABLED' union all
select 'INDEX'              , owner, index_name     , status from dba_indexes     where owner not in ('SYS', 'SYSTEM', 'XDB')   and status != 'VALID'   union all
select 'CONSTRAINT'         , owner, constraint_name, status from dba_constraints where owner not in ('SYS', 'SYSTEM')          and status != 'ENABLED';
