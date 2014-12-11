--
--   Called by -> ts.sql
--
select
  '  ' " ",
  tablespace_name                                                     "Name",
  cast(round(max_size / 1024/1024/1024, 2) || ' GB' as varchar2(12))  "Max Size",
  status,
  logging,
  extent_management,
  allocation_type,
  retention,
  bigfile,
  encrypted
from
  dba_tablespaces
where
  contents = '&tq84_ts_contents'
order by
  tablespace_name;

