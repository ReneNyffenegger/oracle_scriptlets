--
-- Start from Shell (currently: cmd.exe) with
--   
--    sqlplus rene/rene @neato_from_shell
--

set serveroutput on size 100000 format wrapped
set feedback off
set pagesize 0
set trimspool on
set termout off
spool c:\temp\neato_created.neato
set termout on

begin
  schema_to_neato.create_neato(
    schema_to_neato.tables_t(
        'ERD_PARENT', 
        'ERD_CHILD_1',
        'ERD_CHILD_2',
        'ERD_OTHER',
        'ERD_CHILD_2_X_ERD_OTHER'
      )
  );
end;
/

spool off


$neato -Tpng -oc:\temp\erd.png c:\temp\neato_created.neato
$c:\temp\erd.png

exit
