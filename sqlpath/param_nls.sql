--
--   Compare with -> nls.sql
--
select
  substrb(name , 1, 25) name,
  substrb(value, 1, 35) value
from
  v$parameter
where
  name like 'nls%'
order by
  name;
