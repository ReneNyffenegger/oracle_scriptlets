set timing on

select
  count(*)
from
  dba_objects,
  dba_objects
where
  rownum < 40e6;

set timing off
