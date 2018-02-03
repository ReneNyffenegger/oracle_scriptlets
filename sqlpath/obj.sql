select
  substrb(object_name, 1, 30) object_name,
  substrb(object_type, 1, 30) object_type,
  substrb(owner      , 1, 30) owner
from
  all_objects
where
  lower(object_name) like lower('%&1%')
order by
  owner,
  object_name;
