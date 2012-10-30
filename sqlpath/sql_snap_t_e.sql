--
--    This script «ends» (hence the 'e') an
--    SQL snap. The snap is started with
--    sql_snap_t_s.sql.
--
--   These two script offer the same functionality
--   as sqlsnaps.sql/sqlsnape.sql, but without the
--   ../sql_snap package.

select 
  rpad(sql_text, 130) sql_text,
  executions,
  elapsed_time,
  cpu_time,
  disk_reads,
  buffer_gets
from (
  select
    e.sql_text,
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
