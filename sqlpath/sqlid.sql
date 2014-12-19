--
--      Shows the text of an SQL statement if its sql_id is known.
--
set     verify off

select  listagg(sql_text, '') within group (order by piece)
from    v$sqltext_with_newlines
where   sql_id = '&1';
