--
--     Display path to the trace file for the current session
--
--     Compare with -> find_trace_file.sql
--
select value trace_file
  from v$diag_info
 where name = 'Default Trace File';
