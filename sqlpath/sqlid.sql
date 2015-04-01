--
--      Shows the text of an SQL statement if its sql_id is known.
--
set     verify off

--  Old Version: Could not cope with statement longer the 4K...
--
--      select listagg(sql_text, '') within group (order by piece)
--      from   v$sqltext_with_newlines
--      where  sql_id = '&1';

declare
  l    varchar2(4000);
  c    char(1);
begin

  for s in (select sql_text
              from v$sqltext_with_newlines
             where sql_id = '&1'
             order by piece)     loop

    for i in 1 .. length(s.sql_text) loop

        c := substr(s.sql_text, i, 1);

        if c = chr(10) then

           dbms_output.put_line(l);
           l := '';

        else

           l := l || c;

        end if;

    end loop;
  end loop;

  dbms_output.put_line(l);

end;
/
