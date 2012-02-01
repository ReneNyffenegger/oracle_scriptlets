create table dump_block_test (
   c   number,
   txt varchar2(200)
);

declare
  row_id rowid;
  line   varchar2(32767);
begin
 
  for c in ascii('a') .. ascii('z') loop
      insert into dump_block_test values (c, lpad(chr(c), c, chr(c)));
  end loop;

  for c in ascii('A') .. ascii('Z') loop
      insert into dump_block_test values (c, lpad(chr(c), c, chr(c)));
  end loop;

  commit;

--Make sure datafile is written to file:
  execute immediate 'alter system checkpoint';

  select rowid into row_id
    from dump_block_test
   where c = ascii('Q');

  trace_file.dump_block(row_id);

  while trace_file.next_line(line) loop
    dbms_output.put_line(to_char(trace_file.cur_line#, '9999') || ': ' || line);
  end loop;

end;
/

--select * from dump_block_test;

drop table dump_block_test;
