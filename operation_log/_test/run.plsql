truncate table    operation_log_table;
drop     sequence operation_log_seq;
create   sequence operation_log_seq start with 1;
alter    package  operation_log compile;

create table operation_log_table_expected ( -- {
   id                       number,
-- tm                       date,
   txt                      varchar2(4000),
   --
    caller_type             varchar2(32),
    caller_name             varchar2(30),
    caller_pkg_name         varchar2(30),
    caller_line             number  ( 6),
    caller_owner            varchar2(30),
    --
    is_exception            varchar2(1),
    id_parent               number,
    error_backtrace         varchar2(4000),
    clob_                   varchar2( 200)   -- Note, is a CLOB in the »original« table
) -- }
/

-- {  Expected data
--                                             (        ID   TXT                     CALLER_TYPE        CALLER_NAME              CALLER_PKG_NAME      CALLER_LINE  CALLER_OWNER     I     ID_PARENT   ERROR_BACKTRACE, CLOB_
--                                             (----------,  ---------------------,  ----------------,  --------------------- ,  --------------------,-----------, -------------,  '-' , ----------,  ---------------  -----
insert into operation_log_table_expected values(         1, 'Foo Bar Baz'         , 'PROCEDURE'      , 'PROC_A'               , 'OPERATION_LOG_TEST' ,          6, user         ,  'N' ,       null,  null           , null);  
insert into operation_log_table_expected values(         2, 'Iterating i 1 .. 3'  , 'PROCEDURE'      , 'PROC_A'               , 'OPERATION_LOG_TEST' ,          8, user         ,  'N' ,       null,  null           , null);
insert into operation_log_table_expected values(         3, 'i: 1'                , 'PROCEDURE'      , 'PROC_A'               , 'OPERATION_LOG_TEST' ,         12, user         ,  'N' ,          2,  null           , null);
insert into operation_log_table_expected values(         4, 'Iterating j 1 .. 1'  , 'PROCEDURE'      , 'PROC_A'               , 'OPERATION_LOG_TEST' ,         14, user         ,  'N' ,          2,  null           , null);
insert into operation_log_table_expected values(         5, 'j: 1'                , 'PROCEDURE'      , 'PROC_A'               , 'OPERATION_LOG_TEST' ,         17, user         ,  'N' ,          4,  null           , null);
insert into operation_log_table_expected values(         6, 'finished'            , 'PROCEDURE'      , 'PROC_A'               , 'OPERATION_LOG_TEST' ,         20, user         ,  'N' ,          2,  null           , null);
insert into operation_log_table_expected values(         7, 'i: 2'                , 'PROCEDURE'      , 'PROC_A'               , 'OPERATION_LOG_TEST' ,         12, user         ,  'N' ,          2,  null           , null);
insert into operation_log_table_expected values(         8, 'Iterating j 1 .. 2'  , 'PROCEDURE'      , 'PROC_A'               , 'OPERATION_LOG_TEST' ,         14, user         ,  'N' ,          2,  null           , null);
insert into operation_log_table_expected values(         9, 'j: 1'                , 'PROCEDURE'      , 'PROC_A'               , 'OPERATION_LOG_TEST' ,         17, user         ,  'N' ,          8,  null           , null);
insert into operation_log_table_expected values(        10, 'j: 2'                , 'PROCEDURE'      , 'PROC_A'               , 'OPERATION_LOG_TEST' ,         17, user         ,  'N' ,          8,  null           , null);
insert into operation_log_table_expected values(        11, 'finished'            , 'PROCEDURE'      , 'PROC_A'               , 'OPERATION_LOG_TEST' ,         20, user         ,  'N' ,          2,  null           , null);
insert into operation_log_table_expected values(        12, 'i: 3'                , 'PROCEDURE'      , 'PROC_A'               , 'OPERATION_LOG_TEST' ,         12, user         ,  'N' ,          2,  null           , null);
insert into operation_log_table_expected values(        13, 'Iterating j 1 .. 3'  , 'PROCEDURE'      , 'PROC_A'               , 'OPERATION_LOG_TEST' ,         14, user         ,  'N' ,          2,  null           , null);
insert into operation_log_table_expected values(        14, 'j: 1'                , 'PROCEDURE'      , 'PROC_A'               , 'OPERATION_LOG_TEST' ,         17, user         ,  'N' ,         13,  null           , null);
insert into operation_log_table_expected values(        15, 'j: 2'                , 'PROCEDURE'      , 'PROC_A'               , 'OPERATION_LOG_TEST' ,         17, user         ,  'N' ,         13,  null           , null);
insert into operation_log_table_expected values(        16, 'j: 3'                , 'PROCEDURE'      , 'PROC_A'               , 'OPERATION_LOG_TEST' ,         17, user         ,  'N' ,         13,  null           , null);
insert into operation_log_table_expected values(        17, 'finished'            , 'PROCEDURE'      , 'PROC_A'               , 'OPERATION_LOG_TEST' ,         20, user         ,  'N' ,          2,  null           , null);
insert into operation_log_table_expected values(        18, 'operation_log_test_p', 'PROCEDURE'      , 'OPERATION_LOG_TEST_P' ,  null                ,          4, user         ,  'N' ,          2,  null           , null);
insert into operation_log_table_expected values(        19, 'in op log proc'      , 'PROCEDURE'      , 'OPERATION_LOG_TEST_P' ,  null                ,          6, user         ,  'N' ,         18,  null           , null);
insert into operation_log_table_expected values(        20, 'proc_b'              , 'PROCEDURE'      , 'PROC_B'               , 'OPERATION_LOG_TEST' ,         35, user         ,  'N' ,          2,  null           , null);
insert into operation_log_table_expected values(        21, 'testing a clob'      , 'PROCEDURE'      , 'PROC_B'               , 'OPERATION_LOG_TEST' ,         37, user         ,  'N' ,         20,  null           ,'This is the clob');
 -- }

create or replace package operation_log_test as -- {

    procedure proc_a;
    procedure proc_b;

end operation_log_test; -- }
/

create or replace procedure operation_log_test_p as -- {
begin

    operation_log.indent('operation_log_test_p');

    operation_log.log_('in op log proc');

    operation_log.dedent;

end operation_log_test_p; -- }
/

create or replace package body operation_log_test as -- {

    procedure proc_a is -- {
    begin

        operation_log.log_('Foo Bar Baz');

        operation_log.indent('Iterating i 1 .. 3');

        for i in 1 .. 3 loop -- {

          operation_log.log_('i: ' || i);

          operation_log.indent('Iterating j 1 .. ' || i);

          for j in 1 .. i loop -- {
             operation_log.log_('j: ' || j);
          end loop; -- }

          operation_log.dedent('finished');

        end loop; -- }

        operation_log_test_p;

        proc_b;

        operation_log.dedent;

    end proc_a; -- }

    procedure proc_b is -- {
    begin

      operation_log.indent('proc_b');

      operation_log.log_('testing a clob', clob_ => 'This is the clob');

      operation_log.dedent;

    end proc_b;

end operation_log_test; -- }
/
show errors

exec operation_log_test.proc_a

create table operation_log_table_gotten as select
  id,
  txt,
  --
  caller_type,
  caller_name,
  caller_pkg_name,
  caller_line,
  caller_owner,
  --
  is_exception,
  id_parent,
  error_backtrace,
  cast(clob_ as varchar2(200)) clob_
from
  operation_log_table
;

exec operation_log.print_id_recursively(2)

-- https://github.com/ReneNyffenegger/oracle_scriptlets/blob/master/sqlpath/diff_tables.sql
@diff_tables operation_log_table_gotten operation_log_table_expected


/*
select
  id,
  substr(txt, 1, 20),
  substr(caller, 1, 60),
  is_exception,
  id_parent, 
  substr(error_backtrace, 1, 30)
from
  operation_log_table;
*/

/*
with log_rec (txt, caller, is_exception, id, level_) as (
  select
    substr(txt   , 1, 60) txt,
    substr(caller, 1, 60) caller,
    is_exception,
    id,
    0  level_
  from
    operation_log_table
  where
    id_parent is null 
UNION ALL
  select
    lpad(' ', level_) || substr(operation_log_table.txt, 1, 60),
    substr(operation_log_table.caller, 1, 60),
    operation_log_table.is_exception,
    operation_log_table.id,
    level_ + 1
  from
    log_rec              join
    operation_log_table on log_rec.id = operation_log_table.id_parent
)
select
  substr(lpad(' ', level_*2) || txt, 1, 50),
  substr(caller, 1, 60),
  is_exception
from
  log_rec
order by id;
*/

drop package operation_log_test;
drop table operation_log_table_expected purge;
drop table operation_log_table_gotten   purge;
