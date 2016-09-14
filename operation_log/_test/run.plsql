truncate table operation_log_table;
drop   sequence operation_log_seq;
create sequence operation_log_seq start with 1;
alter package operation_log compile;

create table operation_log_table_expected (
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
   is_exception             varchar2(1),
   id_parent                number,
   error_backtrace          varchar2(4000)
);


--                                             (        ID   TXT                     CALLER_TYPE        CALLER_NAME       CALLER_PKG_NAME      CALLER_LINE  CALLER_OWNER     I     ID_PARENT   ERROR_BACKTRACE
--                                             (----------,  ---------------------,  ----------------,  ---------------,  --------------------,-----------, -------------,  '-' , ----------,  ---------------
insert into operation_log_table_expected values(         1, 'Foo Bar Baz'         , 'PROCEDURE'      , 'PROC_A'        , 'OPERATION_LOG_TEST' ,          6, user         ,  'N' ,       null,  null);  
insert into operation_log_table_expected values(         2, 'Iterating i 1 .. 3'  , 'PROCEDURE'      , 'PROC_A'        , 'OPERATION_LOG_TEST' ,          8, user         ,  'N' ,       null,  null);
insert into operation_log_table_expected values(         3, 'i: 1'                , 'PROCEDURE'      , 'PROC_A'        , 'OPERATION_LOG_TEST' ,         12, user         ,  'N' ,          2,  null);
insert into operation_log_table_expected values(         4, 'Iterating j 1 .. 1'  , 'PROCEDURE'      , 'PROC_A'        , 'OPERATION_LOG_TEST' ,         14, user         ,  'N' ,          2,  null);
insert into operation_log_table_expected values(         5, 'j: 1'                , 'PROCEDURE'      , 'PROC_A'        , 'OPERATION_LOG_TEST' ,         17, user         ,  'N' ,          4,  null);
insert into operation_log_table_expected values(         6, 'finished'            , 'PROCEDURE'      , 'PROC_A'        , 'OPERATION_LOG_TEST' ,         20, user         ,  'N' ,          2,  null);
insert into operation_log_table_expected values(         7, 'i: 2'                , 'PROCEDURE'      , 'PROC_A'        , 'OPERATION_LOG_TEST' ,         12, user         ,  'N' ,          2,  null);
insert into operation_log_table_expected values(         8, 'Iterating j 1 .. 2'  , 'PROCEDURE'      , 'PROC_A'        , 'OPERATION_LOG_TEST' ,         14, user         ,  'N' ,          2,  null);
insert into operation_log_table_expected values(         9, 'j: 1'                , 'PROCEDURE'      , 'PROC_A'        , 'OPERATION_LOG_TEST' ,         17, user         ,  'N' ,          8,  null);
insert into operation_log_table_expected values(        10, 'j: 2'                , 'PROCEDURE'      , 'PROC_A'        , 'OPERATION_LOG_TEST' ,         17, user         ,  'N' ,          8,  null);
insert into operation_log_table_expected values(        11, 'finished'            , 'PROCEDURE'      , 'PROC_A'        , 'OPERATION_LOG_TEST' ,         20, user         ,  'N' ,          2,  null);
insert into operation_log_table_expected values(        12, 'i: 3'                , 'PROCEDURE'      , 'PROC_A'        , 'OPERATION_LOG_TEST' ,         12, user         ,  'N' ,          2,  null);
insert into operation_log_table_expected values(        13, 'Iterating j 1 .. 3'  , 'PROCEDURE'      , 'PROC_A'        , 'OPERATION_LOG_TEST' ,         14, user         ,  'N' ,          2,  null);
insert into operation_log_table_expected values(        14, 'j: 1'                , 'PROCEDURE'      , 'PROC_A'        , 'OPERATION_LOG_TEST' ,         17, user         ,  'N' ,         13,  null);
insert into operation_log_table_expected values(        15, 'j: 2'                , 'PROCEDURE'      , 'PROC_A'        , 'OPERATION_LOG_TEST' ,         17, user         ,  'N' ,         13,  null);
insert into operation_log_table_expected values(        16, 'j: 3'                , 'PROCEDURE'      , 'PROC_A'        , 'OPERATION_LOG_TEST' ,         17, user         ,  'N' ,         13,  null);
insert into operation_log_table_expected values(        17, 'finished'            , 'PROCEDURE'      , 'PROC_A'        , 'OPERATION_LOG_TEST' ,         20, user         ,  'N' ,          2,  null);

create or replace package operation_log_test as

    procedure proc_a;

end operation_log_test;
/

create or replace package body operation_log_test as

    procedure proc_a is
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

        operation_log.dedent;

    end proc_a;

end operation_log_test;
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
  error_backtrace
from
  operation_log_table
;


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
