--
--  Find Objects that are not referenced by other objects.
--
--  See also -> dep.sql and -> ref.sql
--
select owner, lower(object_name), object_name, object_type from (
  select
    owner,
    object_name
  from
    dba_objects 
  where 
    owner = '&owner' and
    object_type not in ('INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION', 'TABLE PARTITION', 'LOB', 'LOB PARTITION', 'TRIGGER', 'JOB', 'SYNONYM')
minus
select
  referenced_owner, referenced_name 
  from
    dba_dependencies
  where type not in ('SYNONYM')
) join
user_objects using (object_name)
where 
   object_type not in ('VIEW', 'TABLE') and
   object_type != 'SEQUENCE' and
   object_type = 'TYPE'
order by object_name
;
