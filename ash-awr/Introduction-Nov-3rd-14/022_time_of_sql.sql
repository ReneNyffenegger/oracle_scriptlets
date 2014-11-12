--
--  SQL Statements are cached in v$sqlarea.
--  -> executions is incremented when SQL executed
--  -> cpu_time and elapsed_time are cumulative in micro-secs
--     hence / 1e6
--
select
  executions           executions,
  cpu_time     / 1e6   cpu_time,
  elapsed_time / 1e6   elapsed_time
from
  v$sqlarea
where
  sql_id = '&1';
