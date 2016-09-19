declare
  compile_all boolean := false;
begin
  dbms_utility.compile_schema(user, true);
end;
/
