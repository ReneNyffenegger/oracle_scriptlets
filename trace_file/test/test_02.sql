--drop table trace_c;
--drop table trace_p;
--
--create table trace_p (
--  id  number primary key,
--  txt varchar2(10)
--);
--
--create table trace_c (
--  pid not null references trace_p,
--  txt varchar2(10)
--);

insert into trace_p values (1, '!!!');
insert into trace_p values (2, 'ZZZ');

insert into trace_c values (1, 'one');
insert into trace_c values (2, 'two');
insert into trace_c values (2, 'TWO');

--exec trace_file.start_('alter session set sql_trace=true');
  exec trace_file.start_(q'!alter session set events '10046 trace name context forever, level 12'!');
--exec trace_file.start_('dbms_support.start_trace(binds=>true, waits=>true)');

select max(created) from dba_objects;


--exec trace_file.stop__('alter session set sql_trace=false');
  exec trace_file.stop__(q'!alter session set events '10046 trace name context off'!');
--exec trace_file.stop__('dbms_support.stop_trace');

set serveroutput on size 1000000

declare
  line varchar2(32767);
begin

  while trace_file.next_line(line) loop
    dbms_output.put_line(to_char(trace_file.cur_line#, '9999') || ': ' || line);
  end loop;

end;
/

