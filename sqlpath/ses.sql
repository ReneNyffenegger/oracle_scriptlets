--
--
--                   Display sessions along with their currently running sql statement.
--
--                   This statement may return multiple records per session because
--                   v$sqltext splits the sql text into pieces. Use -> ses_wide.sql
--                   to display one record per session.
--
with ses_sql as (
  select 
    ses.sid,
    ses.serial#,
    ses.username,
    ses.osuser,
    ses.logon_time,
    sql.sql_text,
    sql.sql_id,
    sql.piece,
    (sysdate - ses.sql_exec_start) * 60 * 60 * 24 sql_running_since,
    case when ses.sid = lag(ses.sid) over (order by ses.sid, sql.piece) then 0 else 1 end new_session
  from
    v$session ses                                                  join
    v$process prc on ses.paddr = prc.addr                     left join
    v$sqltext sql on ses.sql_address    = sql.address    and
                     ses.sql_hash_value = sql.hash_value
  where
    ses.sid != sys_context('USERENV','SID') and
    prc.pname is null  -- Only show one v$session record for statements executed in parallel
)
select
  case when new_session = 1 then sid               end sid_,
  case when new_session = 1 then serial#           end serial#,
  case when new_session = 1 then username          end username,
  case when new_session = 1 then osuser            end osuser,
  case when new_session = 1 then logon_time        end logon_time_,
  case when new_session = 1 then sql_id            end sql_id,        -- In order to see sql text with newlines, use this ID in combination with -> sqlid.sql
  sql_text,
  case when new_session = 1 then sql_running_since end sql_run
from 
  ses_sql
order by
  logon_time,
  sid,
  piece;
