--
--   How many seconds is spent for each SQL statement
--
select
  top.sql_id,
  top.cnt,
  top.pct,
  replace(cast(substr(sql.sql_fulltext, 1, 100) as varchar2(100)), chr(10), '') text
from (
  select
    sql_id,
    count(*) cnt,
    to_char(ratio_to_report(count(*)) over () * 100, '90.99') pct,
    row_number() over (order by count(*) desc) r
  from
    v$active_session_history
  where
    session_type <> 'BACKGROUND'  and
    sample_time   > sysdate - 20/24/60 -- Last twenty minutes
  group by
    sql_id
  order by
    count(*) desc
) top left join
v$sqlarea sql on top.sql_id = sql.sql_id
where
  top.r < 50 
order by
  top.cnt desc
;
