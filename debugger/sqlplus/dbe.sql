alter session set plsql_debug=true;

-- Starting the debugee (The target session).
variable debug_session_id varchar2(20)

exec :debug_session_id := dbms_debug.initialize;
print debug_session_id

exec dbms_debug.debug_on;

--exec :debug_session_id := debugger.start_debugee;

--begin
--  dbms_output.put_line(debugger.start_debugee);
--end;
--/


-- TODO:
--     alter session set plsql_debug = true;
