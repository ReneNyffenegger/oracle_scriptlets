--
--       Select objects that are in
--       an invalid state.
--
select
  object_name, owner, object_type, status
from
  all_objects
where
  status != 'VALID';

select
  index_name, owner, 'INDEX', status
from
  all_indexes
where
  status != 'VALID';
