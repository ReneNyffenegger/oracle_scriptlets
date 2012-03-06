select
  object_name, object_type
from
  all_objects
where
  lower(object_name) like lower('%&1%');
