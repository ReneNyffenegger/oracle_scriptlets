--
--       Select objects that are in
--       an invalid state.
--
select
  object_name, owner, object_type
from
  dba_objects
where
  status = 'INVALID';
