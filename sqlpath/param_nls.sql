select
  substr(name , 1, 25) name,
  substr(value, 1, 35) value
from
  v$parameter
where
  name like 'nls%'
order by
  name;
