--
--     Find Snap IDs between «one day ago» and «now».
--

select
  snap_id,
  begin_interval_time,
  end_interval_time
from
  dba_hist_snapshot
where
  end_interval_time   > sysdate - 1 and
  begin_interval_time < sysdate
order by
  begin_interval_time;
