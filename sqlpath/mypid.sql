--
--   Compare with -> mysid.sql
--
select
  p.pid   oracle_process_id,
  p.spid  os_process_id
from
  v$session s join
  v$process p on   s.paddr = p.addr
where
  s.sid = sys_context('USERENV', 'SID');
