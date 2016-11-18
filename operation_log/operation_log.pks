create or replace package operation_log as

  exception_ exception;
  pragma exception_init(exception_, -20001); 
        c_ex_num constant number := -20001;

  procedure log_(txt varchar2, is_exception boolean := false, clob_ clob := null);

  procedure indent(txt varchar2);
  procedure dedent(txt varchar2 := null);

  procedure exc(txt varchar2 := null);

  procedure print_id_recursively(p_id number, p_level number := 0, p_curly_braces boolean := false);

  procedure find_last_root_ids(p_count number := 20);

end operation_log;
/
