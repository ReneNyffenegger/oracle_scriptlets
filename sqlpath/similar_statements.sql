__
-- Searches for SQL statements in v$sql
-- that look similar and could potentially make
-- use of bind variables.
--
-- where col_number = 42
--   is replaced by
-- where col_number =  #
--
-- where col_text = 'foo bar baz'
--   is replaced by
-- where col_text = $
--
-- This is of course only a rudimentary approach...
--
select 
  count(*),
  regexp_replace(regexp_replace (
      sql_text, 
      '= *[0123456789.]+', '= #'),
      '= *''[^'']*'''    , '= $')
from
  v$sql
group by
  regexp_replace(regexp_replace (
       sql_text ,
      '= *[0123456789.]+', '= #'),
      '= *''[^'']*'''    , '= $')
order by 
  count(*) desc;
