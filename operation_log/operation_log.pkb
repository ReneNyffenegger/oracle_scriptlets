create or replace package body operation_log as

  procedure log_(txt varchar2, is_exception boolean := false) is -- {{{
    pragma autonomous_transaction;

    v_is_exception varchar2(1) := 'N';
    v_back_trace   varchar2(4000);
    v_caller       varchar2(4000) := who_am_i(1);
  begin

    if is_exception then
       v_is_exception := 'Y';

      v_back_trace := dbms_utility.format_error_backtrace;
    end if;

    insert into operation_log_table values (operation_log_seq.nextval, sysdate, txt, v_caller, v_is_exception, null, v_back_trace);

    commit;

  end log_; -- }}}

end operation_log;
/
show errors
