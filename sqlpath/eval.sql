--
--   Quickly evaluate an SQL expression
--
--   If the expression contains spaces, it must be embedded within quotes.
--
--   @expr "7 * 6"
--   @expr  length('foo')
--   @expr "length('one two three')"
--
set verify off
select &1 expr from dual;
