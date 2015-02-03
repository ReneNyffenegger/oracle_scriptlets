set verify off
declare
--
--    Drop a schema (user) if it exists.
--
--    To drop an object, use
--      drop_if_exists.sql
--

  schema_name   varchar2(30) := '&1';

begin

  execute immediate 'drop user ' || schema_name || ' cascade';

exception when others then

  if sqlcode = -1918 then -- user '...' does not exist

     null; -- Ignore, nothing to do.

  else
    dbms_output.put_line('drop_schema_if_exists');
    dbms_output.put_line('  ' || sqlcode);
    dbms_output.put_line('  ' || sqlerrm);
  end if;

end;
/
