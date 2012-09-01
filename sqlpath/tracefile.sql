--
--     Display path to the trace file for the current session
--
select value trace_file
  from v$diag_info
 where name = 'Default Trace File';
