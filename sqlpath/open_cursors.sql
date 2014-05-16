--
--   Don't use v$open_cursor...
--
select 
  stat.value
from
  v$mystat   stat join
  v$statname name on stat.statistic# = name.statistic#
where 
  name.name = 'opened cursors current';
