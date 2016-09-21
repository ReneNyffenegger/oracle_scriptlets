set long   32000
set pages      0
set termout  off
set lines   9999
set trimspool on

spool c:\temp\tq84_vw_defs.sql

select
   'spool ' || lower(owner) || '.' || lower(view_name) || '.sql' || chr(10) ||
   'select text from all_views where owner =''' || owner || ''' and view_name = ''' || view_name || ''';' || chr(10) ||
   'spool off' || chr(10)
from
   all_views
where
  owner in ('BI_AT', 'BI');
  
spool off

@c:\temp\tq84_vw_defs.sql
$del c:\temp\tq84_vw_defs.sql
