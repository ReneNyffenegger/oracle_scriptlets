create or replace package body ipc as


    function exec_plsql_in_other_session(plsql in varchar2, maxwait_seconds in number := 1) return varchar2 is
    
        v_pipe_name    varchar2(37) := 'pipe-' || sys_guid;
        v_status       number;

        v_proc         varchar2(32000);
        v_result       varchar2(32000);

        pragma autonomous_transaction;

    begin


        v_status := dbms_pipe.create_pipe(v_pipe_name);

        v_proc := 'declare c number; dummy number; status number; res varchar2(4000);' ||
                  'begin c:= dbms_sql.open_cursor;' ||
                        'dbms_sql.parse(c, q''@' || plsql                        || '@'', dbms_sql.native);' ||
                        'dbms_sql.bind_variable(c, ''result'', lpad('' '', 32000));' ||
                        'dummy := dbms_sql.execute(c);' ||
                        'dbms_sql.variable_value(c, ''result'', res);' ||
                        'dbms_sql.close_cursor(c);' ||
                        'dbms_pipe.pack_message(res);' ||
                        'status := dbms_pipe.send_message(''' || v_pipe_name || ''');' ||
                  'exception when others then' ||
                  '  dbms_pipe.pack_message(sqlerrm); ' ||
                  '  status := dbms_pipe.send_message(''' || v_pipe_name || ''');' ||
                  '  raise_application_error(-20800, sqlerrm);' ||
                  'end;';

        dbms_scheduler.create_job (
          job_name        => 'tools_process_memory',
          job_type        => 'PLSQL_BLOCK',
          job_action      =>  v_proc,
          start_date      =>  null,
          repeat_interval =>  null,
          enabled         =>  true
        );

        v_status := dbms_pipe.receive_message(v_pipe_name, maxwait_seconds);

        dbms_pipe.unpack_message(v_result);

        v_status := dbms_pipe.remove_pipe(v_pipe_name);

        commit;

        return v_result;


    exception when others then

        v_status := dbms_pipe.remove_pipe(v_pipe_name);
        rollback;
        return 'IPC.exec_plsql_in_other_session: ' || sqlerrm;

    end exec_plsql_in_other_session;

end ipc;
/
