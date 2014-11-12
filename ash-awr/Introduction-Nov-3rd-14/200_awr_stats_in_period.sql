--
--   https://raw.githubusercontent.com/ReneNyffenegger/oracle_scriptlets/master/ash-awr/stats_in_period.sql
--
select
   stat.sql_id                                                                            sql_id,
   replace (cast (dbms_lob.substr (text.sql_text, 100) as varchar (100)), chr (10), '')   sql_text,
   --
   executions                                                                             executions,
   --
   round(elapsed_time                                / 1000000  , 3)                      seconds_elapsed,
   round(cpu_time                                    / 1000000  , 3)                      seconds_cpu_elapsed,
   --
   round(elapsed_time / executions                   / 1000000  , 3)                      seconds_elapsed_per_exec,
   round(cpu_time     / executions                   / 1000000  , 3)                      seconds_cpu_elapsed_per_exec,
   round(iowait_time  / executions                   / 1000000  , 3)                      seconds_iowait_ela_per_exec,
   --
   disk_reads                                                                             disk_reads,
   buffer_gets                                                                            buffer_gets,
   writes                                                                                 writes,
   parses                                                                                 parses,
   sorts                                                                                  sorts
from
    ( select  --- {
               stat.sql_id                     sql_id,
          sum (stat.executions_delta    )      executions,
          sum (stat.elapsed_time_delta  )      elapsed_time,
          sum (stat.cpu_time_delta      )      cpu_time,
          sum (stat.iowait_delta        )      iowait_time,
          sum (stat.disk_reads_delta    )      disk_reads,
          sum (stat.buffer_gets_delta   )      buffer_gets,
          sum (stat.direct_writes_delta )      writes,
          sum (stat.parse_calls_delta   )      parses,
          sum (stat.sorts_delta         )      sorts
      from
          dba_hist_sqlstat   stat where snap_id in (
                                        ------------- See script find_snap_ids.sql
                                           select snap_id from dba_hist_ash_snapshot
                                           where
                                             end_interval_time   > sysdate - 3/24 and    -- first snap
                                             begin_interval_time < sysdate               -- last snap
                                        -------------
                                  )
      group by
          stat.sql_id
    )                       stat  --- }
    join dba_hist_sqltext   text on stat.sql_id = text.sql_id
where
    executions > 0
order by
    seconds_elapsed desc;
