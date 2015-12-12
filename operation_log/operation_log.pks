create or replace package operation_log as

  procedure log_(txt varchar2, is_exception boolean := false);

  procedure indent(txt varchar2);
  procedure dedent(txt varchar2 := null);

  procedure print_id_recursively(p_id number, p_level number := 0);

end operation_log;
/
