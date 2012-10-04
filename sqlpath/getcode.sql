-- 
--  Found on https://github.com/timwarnock/sqlpath
--
--  Creates a file with the source text of the code
--  passed as first argument. The suffix of the file
--  is .sql
--
--  If the code consists of a spec and a body, the
--  created file will contain both.
--
set feedback off
set heading off
set termout off
set linesize 1000
set trimspool on
set verify off

spool &1..sql

prompt set define off

select decode( type||'-'||to_char(line,'fm99999'),
               'PACKAGE BODY-1', '/'||chr(10),
                null) ||
       decode(line,1,'create or replace ', '' ) ||
       text text
  from user_source
 where name = upper('&&1')
 order by type, line;

prompt /
prompt set define on

spool off
set feedback on
set heading on
set termout on
set linesize 120
