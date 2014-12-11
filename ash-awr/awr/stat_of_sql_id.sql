--
--   The stats for a specific SQL statement (identified by
--   sql_id) for each snapshot.
--
select
  snap.snap_id,
  to_char(snap.begin_interval_time, 'hh24:mi:ss dd.mm.yyyy') snap_begin,
  stat.executions_delta,
  round(stat.elapsed_time_delta/1e6) ela_time_secs,
  round(stat.elapsed_time_delta/stat.executions_delta/1e6,2) secs_per_stmt,
  round(stat.cpu_time_delta/1e6) cpu_secs,
  round(stat.iowait_delta/1e6)   iowait_secs,
  stat.disk_reads_delta,
  stat.buffer_gets_delta,
  stat.parse_calls_delta,
  stat.sorts_delta
from
  dba_hist_sqlstat  stat join
  dba_hist_snapshot snap on stat.snap_id = snap.snap_id
where
  stat.sql_id = '&sql_id'
order by
  snap.begin_interval_time desc;
