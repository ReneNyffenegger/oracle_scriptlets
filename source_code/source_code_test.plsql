create or replace package source_code_test as

  procedure p;

end source_code_test;
/

create or replace package body source_code_test as

  procedure p2 is

    procedure p3 is
    begin
      null;
    end p3;
  
  begin
    p3;
  end p2;

  /*
  procedure xyz is begin
  -- */
  procedure p1 is begin
    p2;
  end p1;

  function f1 return number is begin
     return 42;
  end f1;

  procedure p is
    n number;
  begin
    if 1 > 10 then
       p1;
    else
      n := f1;
    end if;
  end p;

end source_code_test;
/


declare

  v_line number;
  v_type varchar2(30);

  procedure test(p_type varchar2, p_name varchar2) is
    v_gotten source_code.type_and_name;
  begin
    v_gotten := source_code.name_from_line(p_name => 'SOURCE_CODE_TEST', p_type => v_type, p_line => v_line);

    if v_gotten.type_ != p_type or 
       v_gotten.name_ != p_name then
       raise_application_error(-20800, 'v_line: ' || v_line || ', gotten: ' || v_gotten.type_ || ' / ' || v_gotten.name_);
    end if;

    v_line := v_line + 1;
  end test;

begin

  v_type := 'PACKAGE BODY'; v_line := 1;

  test('?'        , '?'       );-- create or replace package body source_code_test as
  test('?'        , '?'       );-- 
  test('?'        , '?'       );--   procedure p2 is
  test('PROCEDURE', 'P2'      );-- 
  test('PROCEDURE', 'P2'      );--     procedure p3 is
  test('PROCEDURE', 'P3'      );--     begin
  test('PROCEDURE', 'P3'      );--       null;
  test('PROCEDURE', 'P3'      );--     end p3;
  test('PROCEDURE', 'P2'      );--   
  test('PROCEDURE', 'P2'      );--   begin
  test('PROCEDURE', 'P2'      );--     p3;
  test('PROCEDURE', 'P2'      );--   end p2;
  test('?'        , '?'       );-- 
  test('?'        , '?'       );--   /*
  test('?'        , '?'       );--   procedure xyz is begin
  test('?'        , '?'       );--   -- */
  test('?'        , '?'       );--   procedure p1 is begin
  test('PROCEDURE', 'P1'      );--     p2;
  test('PROCEDURE', 'P1'      );--   end p1;
  test('PROCEDURE', 'P1'      );-- 
  test('FUNCTION' , 'F1'      );--   function f1
  test('FUNCTION' , 'F1'      );--   return number
  test('FUNCTION' , 'F1'      );--   is begin return 42; end f1;
  test('FUNCTION' , 'F1'      );-- 
  test('FUNCTION' , 'F1'      );--   procedure p is
  test('PROCEDURE', 'P'       );--     n number;
  test('PROCEDURE', 'P'       );--   begin
  test('PROCEDURE', 'P'       );--     if 1 > 10 then
  test('PROCEDURE', 'P'       );--        p1;
  test('PROCEDURE', 'P'       );--     else
  test('PROCEDURE', 'P'       );--       n := f1;
  test('PROCEDURE', 'P'       );--     end if;
  test('PROCEDURE', 'P'       );--   end p;
  test('PROCEDURE', 'P'       );-- 
  test('PROCEDURE', 'P'       );-- end source_code_test;
  test('PROCEDURE', 'P'       );-- /
  test('PROCEDURE', 'P'       );
  test('PROCEDURE', 'P'       );
  
  

  v_type := 'PACKAGE'; v_line := 1;

  test('?'        , '?'       );
  test('?'        , '?'       );
  test('?'        , '?'       );

  test('PROCEDURE', 'P'       );
  test('PROCEDURE', 'P'       );
  test('PROCEDURE', 'P'       );
  test('PROCEDURE', 'P'       );

end;
/
