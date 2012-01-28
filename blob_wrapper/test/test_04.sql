set serveroutput on size 1000000 format wrapped
set lines 410
set trimspool on

spool c:\temp\circle_spooled.txt
declare
  blob_ blob;
begin
  for r in (select id, blb from blob_wrapper_test_03) loop
--  TODO: gives an error 
--  dbms_output.put_line(r.id || ': ' || utl_raw.cast_to_varchar2(r.blb));
    blob_wrapper.to_file('LOB_TEST_DIR', 'circle_from_table.txt', r.blb);
  end loop;
end;
/
spool off
