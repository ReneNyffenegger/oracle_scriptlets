declare

  none         varchar2(50) := '';
  more         varchar2(50) := 'one1two2three3';


  procedure split_on_regexp (t in varchar2) is/*{*/
  begin

      dbms_output.put_line('* ' || t);

      for r in (
        select rownum, column_value 
          from table(string_op.strtokregexp(t, '\d+'))
      )
      loop 
        dbms_output.put_line('    ' || r.rownum || ': ' || r.column_value || '<');
      end loop;

  end split_on_regexp;/*}*/

begin

  split_on_regexp( none);
  split_on_regexp( more);

end;
/

