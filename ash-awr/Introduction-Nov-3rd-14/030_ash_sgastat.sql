--
--  Wouldn't it be nice if all this were automated...
--
--  ASH = Active Session History
--
--  2MB memory per CPU reserved for collected data

select
  pool,
  bytes/1024/1024 "Size in MB"
from
  v$sgastat
where
  name = 'ASH buffers';

-- Compare
--   select cpu_count_current from v$license;
