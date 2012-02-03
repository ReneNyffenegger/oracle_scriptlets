--
-- Start from Shell (currently: cmd.exe) with
--   
--    sqlplus rene/rene @neato_from_shell
--

create table erd_parent (
  id  number primary key,
  txt varchar2(10)
);

create table erd_child_1 (
  id  number primary key,
  id_p references erd_parent,
  txt varchar2(10)
);

create table erd_child_2 (
  id  number primary key,
  id_p references erd_parent,
  txt varchar2(10)
);

create table erd_other (
  id number primary key,
  txt varchar2(10)
);

create table erd_child_2_x_erd_other (
  id_child_2 references erd_child_2,
  id_other   references erd_other,
  txt        varchar2(10)
);


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

drop table erd_child_2_x_erd_other purge;
drop table erd_other               purge;
drop table erd_child_2             purge;
drop table erd_child_1             purge;
drop table erd_parent              purge;

$neato -Tpng -oc:\temp\erd.png c:\temp\neato_created.neato
$c:\temp\erd.png

exit
