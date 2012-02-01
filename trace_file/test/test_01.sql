exec trace_file.start_('alter session set sql_trace=true');

select sysdate from dual;

select count(*) from user_tables;

exec trace_file.stop__('alter session set sql_trace=false');

set serveroutput on size 1000000

declare
  line varchar2(32767);
begin

  while trace_file.next_line(line) loop
    dbms_output.put_line(to_char(trace_file.cur_line#, '9999') || ': ' || line);
  end loop;

end;
/
