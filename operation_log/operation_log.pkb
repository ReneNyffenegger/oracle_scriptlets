create or replace package body operation_log as

  type num_t is table of number;
  parent_ids num_t := num_t();

  procedure log_insert( -- {
    p_txt          varchar2,
    p_is_exception varchar2 :='N',
    p_back_trace   varchar2 := null,
    p_clob         clob     := null
  ) is

    pragma autonomous_transaction;

    v_back_trace   varchar2(4000);
    v_caller call_stack.who_am_i_r := call_stack.who_am_i(2);

    v_parent_id number;

  begin

    if parent_ids.count > 0 then
       v_parent_id := parent_ids(parent_ids.count);
    end if;

    insert into operation_log_table values (operation_log_seq.nextval, sysdate, p_txt,
      v_caller.type_,
      substr(v_caller.name_, 1, 30), -- TODO 2016-11-22: This substr is necessarey because of »0X459AF82320        40  ANONYMOUS BLOCK«
      v_caller.pkg_name,
      v_caller.line,
      v_caller.owner,
      p_is_exception, v_parent_id, p_back_trace,
      p_clob
      );

    commit;

  end log_insert; -- }

  procedure log_(txt varchar2, is_exception boolean := false, clob_ clob := null) is -- {

    v_is_exception varchar2(1) := 'N';
    v_back_trace   varchar2(4000);
  begin

    if is_exception then
       v_is_exception := 'Y';

       v_back_trace := dbms_utility.format_error_backtrace;
    end if;

    log_insert(txt, p_is_exception => v_is_exception, p_back_trace => v_back_trace, p_clob => clob_);

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

  procedure exc(txt varchar2 := null) is -- {
  begin

    if sqlcode = c_ex_num then
       dedent(txt);
    else
       log_(sqlerrm, is_exception => true);
       dedent(txt);
    end if;

    raise_application_error(c_ex_num, sqlerrm);

  end exc; -- }

  procedure print_id_recursively(p_id number, p_level number := 0, p_curly_braces boolean := false) is -- {
    v_first   boolean := true;
    v_tm      varchar2(21);
    v_txt     varchar2(4000);

    v_caller_type      operation_log_table.caller_type      %type;
    v_caller_name      operation_log_table.caller_name      %type;
    v_caller_pkg_name  operation_log_table.caller_pkg_name  %type;
    v_caller_line      operation_log_table.caller_line      %type;
    v_caller_owner     operation_log_table.caller_owner     %type;

    v_cnt_children          number;
    c_txt_width    constant number  := 120;
    c_caller_width constant number  := 150;
    v_clob                  char(8);

  begin

    select to_char(tm, 'yyyy-mm-dd hh24:mi:ss'), txt,  caller_type,  caller_name,  caller_pkg_name,  caller_line,  caller_owner,case when clob_ is not null then ' -clob- ' else ' ' end
      into       v_tm                         ,v_txt,v_caller_type,v_caller_name,v_caller_pkg_name,v_caller_line,v_caller_owner,v_clob
      from operation_log_table
     where id = p_id;

    select count(*) into v_cnt_children from operation_log_table where id_parent = p_id;

    dbms_output.put( substr(rpad( 
                                lpad(' ', p_level * 2) || replace(v_txt, chr(10), ' '),
                                c_caller_width), 
                                1, c_txt_width)   || ' ' ||
                                v_clob            ||
                                v_tm              || ' ' || 
                                v_caller_name     ||
                                v_caller_pkg_name ||
                                v_caller_line     ||
                                v_caller_owner 
                              );

    if p_curly_braces and v_cnt_children > 0 then 
       dbms_output.put_line(' ' || chr(123));
    else
       dbms_output.put_line('');
    end if;


    for r in (select id from operation_log_table where id_parent = p_id        order by id) loop
        print_id_recursively(r.id, p_level + 1, p_curly_braces => p_curly_braces);
    end loop;

    if p_curly_braces then
       if v_cnt_children > 0  then
          dbms_output.put_line(lpad(' ', (p_level) * 2) || chr(125));
       end if;
    end if;

  end print_id_recursively; -- }

  procedure find_last_root_ids(p_count number := 20) is -- {
  begin

    for r in (

      select id, tm from (

        select id, tm, row_number() over (order by id desc) r
          from operation_log_table
         where id_parent is null
         order by id desc

      )
      where r <= p_count

    ) loop

      dbms_output.put_line(to_char(r.id, '9999999') || ': ' || to_char(r.tm, 'dd.mm.yyyy hh24:mi:ss'));

    end loop;

  end find_last_root_ids; -- }

end operation_log;
/
show errors
