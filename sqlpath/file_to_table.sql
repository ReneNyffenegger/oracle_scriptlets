.
set feedback off
set termout off
save c:\temp\file_to_table.sqlplus_buffer replace
-- The two previous commands save the 'current' or
--'up to now' content of the SQL buffer because we will need
-- it later.
-- The comment is AFTER the commands so that it doesn't
-- get saved along with the current SQL buffer.
--
-- This script's purpose is to "convert" a file within
-- SQL*Plus into a table, so that it can be used like
-- for example so:
--
--  
--   begin
-- 
--     for r in ( 
--         @@file_to_table.sql <filename>
--     ) loop
-- 
--       dbms_output.put_line(r.linetext);
--
--     end loop;
--   end;
--
--
--
-- --------------------------------------------------
--
-- Unfortunately, this script only works when called from within
-- another script.
--
-- Es muss die SQL*Plus Variable "UTILITY_DIR" definiert werden, deren Wert auf
-- das Verzeichnis zeigt, worin dieses und ds file_to_table.bat File liegen.
-- 
-- Mehr auf dem Wiki unter http://wiki.prod.zkb.ch/wiki/AMDS:Utility_file_to_table.sql
--
--
-- Delete the .out file:
$@del  c:\temp\file_to_table.out > nul
$@echo set define off >> c:\temp\file_to_table.out
$@echo set feedback off >> c:\temp\file_to_table.out
$@echo truncate table tmp_file_to_table^; >> c:\temp\file_to_table.out
-- rem $@FOR /F " usebackq delims==" %i IN (`type &1`) DO   @echo insert into tmp_file_to_table values (%zeilen_nummer, q'!%i!')^;  >> c:\temp\file_to_table.out  && set /a zeilen_nummer + 1
$%SQLPATH%\file_to_table.bat &1
--$file_to_table.bat &1
$@echo set define ^& >> c:\temp\file_to_table.out
@@c:\temp\file_to_table.out
set feedback on
-- Now that the tmp_file_to_table is filled, the previously
-- saved buffer can be retrieved again:
set termout on
get c:\temp\file_to_table.sqlplus_buffer nolist
-- -- and add a string for the select statement:
select linenumber, linetext from tmp_file_to_table
