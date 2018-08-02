--
--  See also
--    -> mypid.sql
--    -> who-am-i.sql
--
select sys_context('USERENV','SID') from dual;
