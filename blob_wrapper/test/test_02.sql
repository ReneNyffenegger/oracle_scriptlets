declare
  b blob;
begin
  b := blob_wrapper.from_file('LOB_TEST_DIR', 'circle.txt');
  dbms_output.put_line('size of circle.txt: ' || dbms_lob.getlength(b) || ' (expected: 161202)');
  blob_wrapper.to_file('LOB_TEST_DIR', 'circle_new.txt', b);
end;
/
