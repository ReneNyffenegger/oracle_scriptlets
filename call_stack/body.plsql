create or replace package body call_stack as

  function who_am_i(p_lvl in number := 0) return who_am_i_r is
  -- return the full ORACLE name of your object including schema and package names
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

    ret              who_am_i_r;
    type_and_name    source_code.type_and_name;
    

  begin

  
    v_stack := substr(v_stack,instr(v_stack,chr(10),instr(v_stack,'.CALL_STACK'||chr(10)))+1) || 'ORACLE'; -- skip myself
  
    for v_pos2 in 1 .. p_lvl loop  -- advance to the input level
        v_pos1 := instr(v_stack, chr(10));
        v_stack := substr(v_stack, instr(v_stack, chr(10)) + 1);
    end loop;
  
    v_pos1 := instr(v_stack, chr(10));
    if v_pos1 = 0 then
       return ret;
    end if;
  
    v_stack  :=           substr(v_stack, 1, v_pos1 - 1              );  -- get only current level
    v_stack  :=      trim(substr(v_stack,    instr(v_stack, ' '))    );  -- cut object handle
    ret.line := to_number(substr(v_stack, 1, instr(v_stack, ' ') - 1));  -- get line number
    v_stack  :=      trim(substr(v_stack,    instr(v_stack, ' '))    );  -- cut line number

    v_pos1 := instr(v_stack, ' BODY');

    if v_pos1  = 0 then
       return ret;
    end if;
  
    v_pos1    := instr (v_stack, ' ', v_pos1 + 2);  -- find end of object type

    ret.type_ := substr(v_stack, 1  , v_pos1 - 1);

    v_stack   := trim(substr(v_stack, v_pos1 + 1));  -- get package name
    v_pos1    := instr(v_stack, '.');

    ret.owner := substr(v_stack, 1, v_pos1 - 1);
    ret.pkg_name := substr(v_stack, v_pos1 + 1);

    type_and_name := source_code.name_from_line(ret.pkg_name, ret.type_, ret.line, ret.owner);

    ret.name_ := type_and_name.name_;
    ret.type_ := type_and_name.type_;

    return ret;
  
  
  end who_am_i;

end call_stack;
/
show errors
