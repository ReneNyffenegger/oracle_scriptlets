select
  object_name, object_type, owner
from
  all_objects
where
  lower(object_name) like lower('%&1%');
