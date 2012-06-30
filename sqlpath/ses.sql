--
--
--                   Display sessions along with their currently running sql statement.
--
with ses_sql as (
  select 
    ses.sid,
    ses.serial#,
    ses.username,
    sql.sql_text,
    sql.piece,
    (sysdate - ses.sql_exec_start) * 60 * 60 * 24 sql_running_since,
    case when ses.saddr = lag(ses.saddr) over (order by ses.saddr, sql.piece) then 0 else 1 end new_session
  from
    v$session ses left join
    v$sqltext sql on ses.sql_address = sql.address and ses.sql_hash_value = sql.hash_value
)
select
  case when new_session = 1 then sid               end sid,
  case when new_session = 1 then serial#           end serial#,
  case when new_session = 1 then username          end username,
  sql_text,
  case when new_session = 1 then sql_running_since end sql_run
from 
  ses_sql;
