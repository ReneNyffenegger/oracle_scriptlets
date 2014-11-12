select
  snap_id,
  dbid,
  instance_number I,
  '|' || to_char(startup_time       , 'dd.mm.yyyy hh24:mi:ss'),
  '|' || to_char(begin_interval_time, 'dd.mm.yyyy hh24:mi:ss'),
  '|' || to_char(end_interval_time  , 'dd.mm.yyyy hh24:mi:ss'),
--snap_level, -- ?
  snap_flag, -- 0: Automatic, 1. Manually, 2: Imported
  flush_elapsed -- How long did it take to take snapshot
from
  dba_hist_snapshot
order by
  begin_interval_time;
