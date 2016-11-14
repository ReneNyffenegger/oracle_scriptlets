create or replace package body call_stack as

  function who_am_i(p_lvl in number := 0) return who_am_i_r is -- {
  -- return the full ORACLE name of your object including schema and package names -- {
  -- --
  -- call_stack.who_am_i(0) - returns the name of your object
  -- call_stack.who_am_i(1) - returns the name of calling object
  -- call_stack.who_am_i(2) - returns the name of object, who called calling object
  -- -------------------------------------------------------------------------------------------------
  -- Copyrigth GARBUYA 2010

    v_stack           varchar2(2048) := upper(dbms_utility.format_call_stack);
    v_pkg_name        varchar2(  32);
    v_idx             number := 0;
    v_pos1            number := 0;
    v_line            varchar2(200);

    ret               who_am_i_r;
    type_and_name     source_code.type_and_name;


    function cut_a_line(p_callstack in out varchar2) return varchar2 is -- {
      line   varchar2(200);
      pos_nl number;
    begin

      pos_nl := instr (p_callstack, chr(10));

      if pos_nl = 0 then
         line := p_callstack;
         p_callstack := '';
         return line;
      end if;

      line        := substr(p_callstack, 1, pos_nl - 1);
      p_callstack := substr(p_callstack,    pos_nl + 1);

      return line;

    end cut_a_line; -- }
    
  -- }
  begin

  

    v_line := cut_a_line(v_stack);
    if v_line != '----- PL/SQL CALL STACK -----' then raise_application_error(-20800, 'Wrong assumption, v_line: ' || v_line || '<'); end if;

    v_line := cut_a_line(v_stack);
    if v_line != '  OBJECT      LINE  OBJECT'    then raise_application_error(-20800, 'Wrong assumption, v_line: ' || v_line || '<'); end if;

    v_line := cut_a_line(v_stack);
    if v_line != '  HANDLE    NUMBER  NAME'      then raise_application_error(-20800, 'Wrong assumption, v_line: ' || v_line || '<'); end if;

 -- Remove myself
    v_line := cut_a_line(v_stack);
    if not regexp_like(v_line, '^[0-9A-FX]+        12  PACKAGE BODY .*\.CALL_STACK$') then raise_application_error(-20800, 'Wrong assumption, v_line: ' || v_line || '<'); end if;
  
    for v_pos2 in 0 .. p_lvl loop  -- advance to the input level
        v_line := cut_a_line(v_stack);
    end loop;


    ret.line     := regexp_replace(v_line, '^[0-9A-FX]+ +(\d+).*'              , '\1');
    ret.type_    := regexp_replace(v_line, '^[0-9A-FX]+ +\d+ +(.*) +([^ ]+)$'  , '\1');
    ret.owner    := regexp_replace(v_line, '^[0-9A-FX]+ +\d+ +.* +([^.]+).*$'  , '\1');
    ret.pkg_name := regexp_replace(v_line, '^[0-9A-FX]+ +\d+ +.* +[^.]+\.(.*)$', '\1');


$if false $then
    dbms_output.put_line('ret.line     = ' || ret.line     || '<');
    dbms_output.put_line('ret.type_    = ' || ret.type_    || '<');
    dbms_output.put_line('ret.owner    = ' || ret.owner    || '<');
    dbms_output.put_line('ret.pkg_name = ' || ret.pkg_name || '<');
$end

--
--  v_pos1    := instr (v_stack, ' ', v_pos1 + 2);  -- find end of object type

--  ret.type_ := substr(v_stack, 1  , v_pos1 - 1);

--  v_stack   := trim(substr(v_stack, v_pos1 + 1));  -- get package name
--  v_pos1    := instr(v_stack, '.');

--  ret.owner := substr(v_stack, 1, v_pos1 - 1);
--  ret.pkg_name := substr(v_stack, v_pos1 + 1);

    if ret.type_ not like '%BODY' then
       ret.name_    := ret.pkg_name;
       ret.pkg_name := null;
    else

      type_and_name := source_code.name_from_line(ret.pkg_name, ret.type_, ret.line, ret.owner);

      ret.type_ := type_and_name.type_;
      ret.name_ := type_and_name.name_;

    end if;

$if false $then
    dbms_output.put_line('ret.type_    = ' || ret.type_    || '<');
    dbms_output.put_line('ret.name_    = ' || ret.name_    || '<');
$end

    return ret;
  
  
  end who_am_i; -- }

end call_stack;
