--
--    Display «other» session's currently running
--    SQL statement.
--
select
  sql.sql_id,
  sql.executions,
  sql.cpu_time      / 1e6 cpu_time,
  sql.elapsed_time  / 1e6 elapsed_time,
  substr(sql.sql_text, 1, 100) text
from
  v$session ses left join
  v$sqlarea sql on ses.sql_address    = sql.address and
                   ses.sql_hash_value = sql.hash_value
where
  ses.sid = &1;
