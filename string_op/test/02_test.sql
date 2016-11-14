declare

  none         varchar2(50) := '';
  abc_num_abc  varchar2(50) := 'one1two2three3forty-two42rest';
      num_abc  varchar2(50) := '  11two2three3forty-two42rest';
  abc_num      varchar2(50) := 'one1two2three3forty-two42'    ;


  procedure test_grep_re_num (item varchar2, t in varchar2, expected &tq84_prefix.varchar2_t) is -- {
    gotten &tq84_prefix.varchar2_t;
  begin

--  dbms_output.put_line('* ' || t);

--  for r in (
--    select rownum, column_value 
--      from table(&tq84_prefix.string_op.grep_re(t, '\d+'))
--  )
--  loop 
--    dbms_output.put_line('    ' || r.rownum || ': ' || r.column_value || '<');
--  end loop;

    -----------------------


    gotten := &tq84_prefix.string_op.grep_re(t, '\d+');


    if gotten.count != expected.count then
       raise_application_error(-20800, 'item: ' || item || ': cnt gotten: ' || gotten.count || ', cnt expected: ' || expected.count);
    end if;

    for i in 1 .. gotten.count loop

       if nvl(gotten(i), chr(1)) != nvl(expected(i), chr(1)) then
          raise_application_error(-20800, 'item: ' || item || ', i=' || i || ', gotten: ' || gotten(i) || ', expected: ' || expected(i));
       end if;
    end loop;


  end test_grep_re_num; -- }

begin

  test_grep_re_num('none'       , none       , &tq84_prefix.varchar2_t(                                           ));
  test_grep_re_num('abc_num_abc', abc_num_abc, &tq84_prefix.varchar2_t( '1', '2', '3', '42'                       ));
  test_grep_re_num(    'num_abc',     num_abc, &tq84_prefix.varchar2_t('11', '2', '3', '42'                       ));
  test_grep_re_num('abc_num'    , abc_num    , &tq84_prefix.varchar2_t( '1', '2', '3', '42'                       ));

end;
/

