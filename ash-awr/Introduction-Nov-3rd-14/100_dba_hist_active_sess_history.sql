--
--  v$active_session_history is flushed every
--  hour or when 66%(?) full.
--
--  Only records where is_awr_sample = 'Y'
--

select
  snap_id,
  to_char(sample_time, 'dd.mm.yyyy hh24:mi:ss') sample_time,
  session_serial#,
  sql_id,
  sql_exec_start,
  time_waited
from
  dba_hist_active_sess_history
where
  session_id      = &1 and
  session_serial# = &2
order by
  sample_time;
