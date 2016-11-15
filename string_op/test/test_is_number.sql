declare

  procedure test_str(str varchar2, expected boolean) is
  begin

    if &tq84_prefix.string_op.is_number(str) != expected then
       dbms_output.put_line('Wrong expectation for >' || str || '<');
    end if;

  end test_str;

begin

-- numbers
   test_str( '42'    , true);
   test_str( '42.42' , true);
   test_str('-42'    , true);
   test_str('-42.42' , true);
   test_str('4.249E6', true);

-- leading spaces:
   test_str('     42'     , true);
   test_str('     42.42'  , true);
   test_str('    -42'     , true);
   test_str('    -42.42'  , true);
   test_str('  4.249E6'   , true);

-- leading + trailing spaces:
   test_str('     42     ', true);
   test_str('     42.42  ', true);
   test_str('    -42     ', true);
   test_str('    -42.42  ', true);
   test_str('  4.249E6   ', true);

end;
/
