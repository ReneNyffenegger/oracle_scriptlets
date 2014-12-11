--
--  Find Objects that are not referenced by other objects.
--
--  See also -> dep.sql and -> ref.sql
--
  select
    owner,
    object_name
  from
    dba_objects
  where
    owner        = '&1' and
    object_type not in ('INDEX', 'INDEX PARTITION', 'TRIGGER', 'JOB')
minus
  select
    referenced_owner,
    referenced_name
  from
    dba_dependencies
  where type not in ('SYNONYM');
