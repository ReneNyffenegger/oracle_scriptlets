@spool table_defs_get_ddl.sql

select '@spool table_defs/'                         || table_name || '.sql'                          || chr(10) || 
       'select dbms_metadata.get_ddl(''TABLE'', ''' || table_name || ''', user) || '';'' from dual;' || chr(10) ||
       '@spool_off'
from
  user_tables 
where
  table_name not like 'TQ84%';

@spool_off
