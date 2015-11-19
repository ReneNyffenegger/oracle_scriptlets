create or replace package operation_log as

  procedure log_(txt varchar2, is_exception boolean := false);

end operation_log;
/
