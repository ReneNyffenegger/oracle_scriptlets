-- http://blog.tanelpoder.com/files/scripts/hint.sql
select
  name,
  version,
  version_outline,
  inverse 
from 
  v$sql_hint 
where lower(name) like lower('%&1%');
