--
--   ses_wide.sql is basically the same thing as ses.sql but
--   uses listagg() to concatenate the sql pieces so that
--   the statement returns one row per session.
--
select 
  ses.sid,
  ses.serial#,
  ses.username,
  ses.osuser,
  ses.logon_time,
  listagg(sql.sql_text, '') within group (order by sql.piece) sql_text,
  (sysdate - ses.sql_exec_start) * 60 * 60 * 24 sql_running_since
from
  v$session ses left join
  v$sqltext sql on ses.sql_address = sql.address and ses.sql_hash_value = sql.hash_value
where
  ses.sid != sys_context('USERENV','SID') and
  ses.osuser != 'oracle'
group by
  ses.sid,
  ses.serial#,
  ses.username,
  ses.osuser,
  ses.logon_time,
  (sysdate - ses.sql_exec_start) * 60 * 60 * 24
order by
  (sysdate - ses.sql_exec_start) * 60 * 60 * 24 desc nulls last;
