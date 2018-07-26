select
   substrb(object_name, 1, 30) object_name,
   substrb(object_type, 1, 30) object_type,
   substrb(owner      , 1, 30) owner
from
   dba_objects
where
   lower(object_name) like lower('%&1%') and
   object_type not in ('TABLE PARTITION')
order by
   owner,
   object_name;
