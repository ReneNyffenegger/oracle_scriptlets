declare
--
--  https://raw.githubusercontent.com/ReneNyffenegger/oracle_scriptlets/master/string_op/test/01_test.sql
--

  none         varchar2(50) := '';
   one         varchar2(50) := 'one';

   hello_world varchar2(50) := 'hello,world';

   foo_bar_baz varchar2(50) := 'foo,,bar,,baz,';

  procedure split_on_comma (item varchar2, t in varchar2, expected &tq84_prefix.varchar2_t) is -- {

    gotten &tq84_prefix.varchar2_t;
  begin

    gotten := &tq84_prefix.string_op.strtok(t, ',');

    if gotten.count != expected.count then
       raise_application_error(-20800, 'item: ' || item || ': cnt gotten: ' || gotten.count || ', cnt expected: ' || expected.count);
    end if;

    for i in 1 .. gotten.count loop

       if nvl(gotten(i), chr(1)) != nvl(expected(i), chr(1)) then
          raise_application_error(-20800, 'item: ' || item || ', i=' || i || ', gotten: ' || gotten(i) || ', expected: ' || expected(i));
       end if;
    end loop;

--    dbms_output.put_line('* ' || t);

--    for r in (
--      select rownum, column_value 
--        from table(&tq84_prefix.string_op.strtok(t, ','))
--    )
--    loop 
--      dbms_output.put_line('    ' || r.rownum || ': ' || r.column_value || '<');
--    end loop;

  end split_on_comma; -- }

begin

  split_on_comma('none'       , none       , &tq84_prefix.varchar2_t(                               ));
  split_on_comma('one'        , one        , &tq84_prefix.varchar2_t('one'                          ));
  split_on_comma('hello_world', hello_world, &tq84_prefix.varchar2_t('hello', 'world'               ));
  split_on_comma('foo_bar_baz', foo_bar_baz, &tq84_prefix.varchar2_t('foo', '', 'bar', '', 'baz', ''));

end;
/
