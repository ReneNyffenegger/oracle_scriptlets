define run_comment=&1
set verify off


delete from plsql_profiler_data   where runid = (select max(runid) from plsql_profiler_runs where run_comment = '&&run_comment');
delete from plsql_profiler_units  where runid = (select max(runid) from plsql_profiler_runs where run_comment = '&&run_comment');
delete from plsql_profiler_runs   where runid = (select max(runid) from plsql_profiler_runs where run_comment = '&&run_comment');


set serveroutput on

declare 
  success binary_integer;
begin
  success := dbms_profiler.start_profiler(run_comment => '&&run_comment');

  if success <> 0 then
    dbms_output.put_line('could not start profiler');
  else
    dbms_output.put_line('Profiler started!');
  end if;
end;
/
