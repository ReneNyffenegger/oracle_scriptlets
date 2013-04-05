select
  ses.osuser,
  ses.sid,
  ses.serial#,
--trx.addr          trx_addr,
--ses.saddr,
  trx.ses_addr,
  trx.start_time,
  trx.used_ublk,
  trx.used_urec
from
  v$session     ses join
--v$transaction trx on ses.taddr = trx.addr
  v$transaction trx on ses.saddr = trx.ses_addr;

