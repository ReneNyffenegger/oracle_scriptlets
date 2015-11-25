create or replace package body operation_log as

  type num_t is table of number;
  parent_ids num_t := num_t();

  procedure log_insert( -- {
    p_txt          varchar2,
    p_is_exception varchar2 := 'N',
    p_back_trace   varchar2 := null
  ) is

    pragma autonomous_transaction;

    v_back_trace   varchar2(4000);
    v_caller       varchar2(4000) := who_am_i(2);

    v_parent_id number;

  begin

    if parent_ids.count > 0 then
       v_parent_id := parent_ids(parent_ids.count);
    end if;

    insert into operation_log_table values (operation_log_seq.nextval, sysdate, p_txt, v_caller, p_is_exception, v_parent_id, p_back_trace);

    commit;

  end log_insert; -- }

  procedure log_(txt varchar2, is_exception boolean := false) is -- {

    v_is_exception varchar2(1) := 'N';
    v_back_trace   varchar2(4000);
  begin

    if is_exception then
       v_is_exception := 'Y';

       v_back_trace := dbms_utility.format_error_backtrace;
    end if;

    log_insert(txt, p_is_exception => v_is_exception, p_back_trace => v_back_trace);

  end log_; -- }

  procedure indent(txt varchar2) is -- {
  begin

    log_insert(txt);

    parent_ids.extend;
    parent_ids(parent_ids.count) := operation_log_seq.currval;

  end indent; -- }

  procedure dedent(txt varchar2 := null) is -- {
  begin

    if parent_ids.count > 0 then
       parent_ids.trim;
    else
       log_insert('Warning: dedent called but parent_ids.count = 0');
    end if;

    if txt is not null then
       log_insert(txt);
    end if;

  end dedent; -- }

end operation_log;
/
show errors
