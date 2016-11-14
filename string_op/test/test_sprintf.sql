set serveroutput on size 100000 format wrapped

declare
--
--  https://raw.githubusercontent.com/ReneNyffenegger/oracle_scriptlets/master/string_op/test/test_sprintf.sql
--

  procedure cmp(test_no in number, format in varchar2, parms in &tq84_prefix.varchar2_t, expected in varchar2) is -- {
    gotten varchar2(4000);
  begin

    gotten := &tq84_prefix.string_op.sprintf(format, parms);

    if gotten != expected then

       dbms_output.put_line('test ' || test_no || ' failed');
       dbms_output.put_line('    gotten is: ' || gotten    || '<');
       dbms_output.put_line('  expected is: ' || expected  || '<');

    end if;

  end cmp; -- }

begin

  dbms_output.put_line('sprintf test');

  -- Right aligning a string:
  cmp( 1,  'String: %20s', &tq84_prefix.varchar2_t('hello world'), 'String:          hello world');

  -- Left aligning a string                                    12345678901234567890
  cmp( 2, 'String: %-20s', &tq84_prefix.varchar2_t('hello world'), 'String: hello world         ');

  -- A left and a right aligned string                         ... 1234567890 1234567890 ...
  cmp( 3, '... %10s %-10s ...', &tq84_prefix.varchar2_t('hello', 'world'), '...      hello world      ...');

  -- Strings and null                                                     ... 12345 12345 12345 12345 ...
  cmp( 4, '... %5s %5s %-5s %-5s ...', &tq84_prefix.varchar2_t('a', null, 'b', null), '...     a       b           ...');

  -- Numbers
  cmp( 5, 'Numbers: %d,%d,%d'  , &tq84_prefix.varchar2_t(  42,    0, -42), 'Numbers: 42,0,-42');
  cmp( 6, 'Numbers: %d,%d,%d'  , &tq84_prefix.varchar2_t(  42, null, -42), 'Numbers: 42,,-42' );

  -- Right aligning numbers:                                               12345 12345 12345
  cmp( 7, 'Numbers: %5d,%5d,%5d'  , &tq84_prefix.varchar2_t(  42,    0, -42), 'Numbers:    42,    0,  -42');
  cmp( 8, 'Numbers: %5d,%5d,%5d'  , &tq84_prefix.varchar2_t(  42, null, -42), 'Numbers:    42,     ,  -42');

  -- Left aligning numbers:                                                   12345 12345 12345
  cmp( 9, 'Numbers: %-5d,%-5d,%-5d'  , &tq84_prefix.varchar2_t(  42, null, -42), 'Numbers: 42   ,     ,-42  ');

  -- Fractions                                   12.12345
  cmp(10, '1/3: %2.5d',  &tq84_prefix.varchar2_t( 1/3), '1/3:   .33333');
  cmp(11, '1/3: %02.5d', &tq84_prefix.varchar2_t( 1/3), '1/3:  0.33333');
  cmp(12, '1/3: %2.5d',  &tq84_prefix.varchar2_t(-1/3), '1/3:  -.33333');
  cmp(13, '1/3: %02.5d', &tq84_prefix.varchar2_t(-1/3), '1/3: -0.33333');

  -- Fractions with signs                         S12.12345
  cmp(14, '1/3: %+2.5d',  &tq84_prefix.varchar2_t( 1/3), '1/3:   +.33333');
  cmp(15, '1/3: %+02.5d', &tq84_prefix.varchar2_t( 1/3), '1/3:  +0.33333');
  cmp(16, '1/3: %+2.5d',  &tq84_prefix.varchar2_t(-1/3), '1/3:   -.33333');
  cmp(17, '1/3: %+02.5d', &tq84_prefix.varchar2_t(-1/3), '1/3:  -0.33333');

  -- Recognizition of the %
  cmp(18, '%d %% of %d is: %d', &tq84_prefix.varchar2_t(7, 68, 68/100*7), '7 % of 68 is: 4.76');

  -- Number doesn't fit the length
  cmp(19, '... %4d ...', &tq84_prefix.varchar2_t(12345), '... #### ...');

end;
/

