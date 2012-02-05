declare
  v_result integer;
begin
  v_result := debugged_package.tst_1(4);
  dbms_output.put_line('v_result: ' || v_result);
end;
/
