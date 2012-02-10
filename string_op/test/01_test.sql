declare

  none         varchar2(50) := '';
   one         varchar2(50) := 'one';

   hello_world varchar2(50) := 'hello,world';

   foo_bar_baz varchar2(50) := 'foo,,bar,,baz,';

  procedure split_on_comma (t in varchar2) is/*{*/
  begin

      dbms_output.put_line('* ' || t);

      for r in (
        select rownum, column_value 
          from table(string_op.strtok(t, ','))
      )
      loop 
        dbms_output.put_line('    ' || r.rownum || ': ' || r.column_value || '<');
      end loop;

  end split_on_comma;/*}*/

begin

  split_on_comma( none);
  split_on_comma(  one);
  split_on_comma(  hello_world);
  split_on_comma(  foo_bar_baz);

end;
/
