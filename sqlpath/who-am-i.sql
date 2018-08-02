--
-- Who am I?
--
-- See also
--   -> mypid.sql
--   -> mysid.sql
--
select
  substr(sys_context('USERENV', 'CURRENT_SCHEMA'), 1, 30) current_schema,
  substr(sys_context('USERENV', 'SESSION_USER'  ), 1, 30) session_user
from
  dual;
