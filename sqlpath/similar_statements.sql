-- Searches for similar sql statements in v$sql
-- that look similar and could potentially make
-- use of bind variables.
--
-- where col_number = 42
--   is replaced by
-- where col_number =  #
--
-- ----------------------------
--
-- where col_text = 'foo bar baz'
--   is replaced by
-- where col_text = $
--
-- This is of course only a rudimentary approach...
--
select 
  count(*),
  regexp_replace(
  regexp_replace(
  regexp_replace(
  regexp_replace(sql_text,
       '(''[^'']*'')'           , '$'  ) -- Strings -> $
     , '(=|<|>|\s+)(-?\d+\.\d+)', '\1#') -- 44.4    -> #
     , '(=|<|>|\s+)(-?\.\d+)'   , '\1#') --   .49   -> #
     , '(=|<|>|\s+)(-?\d+)'     , '\1#') --   22    -> #
from
  v$sql
group by
  regexp_replace(
  regexp_replace(
  regexp_replace(
  regexp_replace(sql_text,
       '(''[^'']*'')'           , '$'  ) -- Strings -> $
     , '(=|<|>|\s+)(-?\d+\.\d+)', '\1#') -- 44.4    -> #
     , '(=|<|>|\s+)(-?\.\d+)'   , '\1#') --   .49   -> #
     , '(=|<|>|\s+)(-?\d+)'     , '\1#') --   22    -> #
order by 
  count(*) desc;
