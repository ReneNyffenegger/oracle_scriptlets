select 
  nam.name,
  sta.value
from
  v$sesstat  sta      join
  v$statname nam using (statistic#)
where 
  sta.sid    = &1 and
  sta.value != 0
order by
  nam.class,
  sta.value;
