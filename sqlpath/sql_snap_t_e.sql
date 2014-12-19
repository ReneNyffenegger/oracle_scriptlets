--
--    Show the difference to a started "SQL Snap". (The _e stands for "end")
--
--    Use sql_snap_t_s.sql to start such a snap
--
--    Use sqlid.sql to query the complete SQL test statement.


select 
  rpad(sql_text, 100) sql_text,
--address,
--hash_value,
  sql_id,
  executions,
  elapsed_time,
  cpu_time,
  disk_reads,
  buffer_gets
from (
  select
    e.sql_text,
--  e.address,
--  e.hash_value,
    e.sql_id,
    e.executions             - nvl(s.executions  , 0)                            executions  ,
    to_char( (e.elapsed_time - nvl(s.elapsed_time, 0)) / 1000000, '9999990.00')  elapsed_time,
    to_char( (e.cpu_time     - nvl(s.cpu_time    , 0)) / 1000000, '9999990.00')  cpu_time    ,
    e.disk_reads             - nvl(s.disk_reads  , 0)                            disk_reads  ,
    e.buffer_gets            - nvl(s.buffer_gets , 0)                            buffer_gets 
  from
    sys.v_$sqlarea     e left join
    tq84_sql_snap      s on e.address    = s.address and
                            e.hash_value = s.hash_value
  where
    e.executions   - nvl(s.executions  , 0) > 0
  order by
    e.elapsed_time - nvl(s.elapsed_time, 0) desc
) 
where rownum < 40;
