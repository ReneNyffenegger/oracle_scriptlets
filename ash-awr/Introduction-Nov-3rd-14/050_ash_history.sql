--
--   One sample per second IF there is activity (note
--   the gaps in a session).
--
select * from (
--
   select
     to_char(hist.sample_time, 'hh24:mi:ss') || '| ' sample_time,
     replace(cast(sql.sql_fulltext as varchar2(100)), chr(10), ' '),
     '|' || hist.sql_id "SQL Id",
     '|' || to_char(hist.sql_exec_start, 'hh24:mi:ss') "Start",
     hist.is_awr_sample  -- <== Note particularly this column!
--   hist.session_id, -- {
--   hist.session_serial#, -- }
--   delta_time / 1e6      delta_s, {
--   hist.tm_delta_time,
--   hist.tm_delta_cpu_time,
--   hist.tm_delta_db_time,
   --hist.event ,
     /*,
     hist.p1text,
     hist.p1,
     hist.p2text,
     hist.p2,
     hist.p3text,
     hist.p3, */
     --
   --hist.current_obj#,
   --hist.current_file#,
   --hist.current_block#,
     --
   --hist.time_waited -- }
   , time_waited
   from
     v$active_session_history hist left join
     -- Join with sqlarea to get sql text.
     v$sqlarea                sql on hist.sql_id = sql.sql_id
   where
     session_id      = &1 and -- <== Indicate session_id and
     session_serial# = &2     -- <== serial#
   order by
     sample_time desc
--
)
where
  rownum < 5000
order by
  sample_time
;
