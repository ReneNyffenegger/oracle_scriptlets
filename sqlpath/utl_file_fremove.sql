--
--     Wrap the call of utl_file.fremove into an
--     anonymous block so that exception handling
--     can be used.
--
set verify off
declare
  dir_  varchar2(4000) := '&1';
  file_ varchar2(4000) := '&2';
begin
  utl_file.fremove(dir_, file_);
exception when others then

  if    sqlcode = -29283 then

        dbms_output.put_line('Could not delete file ' || file_ || '!');

  elsif sqlcode = -29280 then

        dbms_output.put_line('Invalid directory ' || dir_);
  
  else  raise;
  end   if;
        
end;
/
