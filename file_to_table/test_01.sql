--
--    If invoked with two apetales (@@): path is relative to
--    directory where file_to_table.sql resides.
--    Could be %SQLPATH%
--
--    Compare test_02.sql
--
begin

  for r in ( 
      @@file_to_table.sql ..\file_to_table\test_01.sql
  ) loop
                                      
    dbms_output.put_line(r.linetext);
                                      
  end loop;
end;
/
