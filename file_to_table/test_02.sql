--
--    If invoked with one apetales (@): path is relative to
--    current directory.
--
--    Compare test_02.sql
begin
                                      
  for r in ( 

      @file_to_table.sql test_02.sql

  ) loop
                                      
    dbms_output.put_line(r.linetext);
                                      
  end loop;
end;
/
