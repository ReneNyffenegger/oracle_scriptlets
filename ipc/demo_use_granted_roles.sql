connect / as sysdba

create user ipc_user identified by ipc_user;

grant
  create procedure,
  create session,
  select_catalog_role
to
  ipc_user;

-- Don't directly grant:
--
-- grant select  on v_$process to ipc_user;
-- grant select  on v_$session to ipc_user;


connect ipc_user/ipc_user


-- User ipc_user may select from v$process
select count(*) from v$process;


create or replace function tq84_proc_memory return varchar2 as
   v_result varchar2(200);
begin

    select
     'Used: '     || round(pga_used_mem    /1024/1024)||', '||
     'Alloc: '    || round(pga_alloc_mem   /1024/1024)||', '||
     'Freeable: ' || round(pga_freeable_mem/1024/1024)||', '||
     'PGA Max: '  || round(pga_max_mem     /1024/1024)
    into  
      v_result
    from
      v$process
    where
      addr = (select paddr from v$session where sid = 
      sys_context('USERENV','SID'));

    return v_result;

end tq84_proc_memory;
/

-- function tq84_proc_memory does not compile:

show errors
-- LINE/COL ERROR
-- -------- -----------------------------------------------------------------
-- 5/5      PL/SQL: SQL Statement ignored
-- 15/33    PL/SQL: ORA-00942: table or view does not exist

-- It would compile, if grants on v$* were directly given:
--    grant select on v_$process to ipc_user /
--    grant select on v_$session to ipc_user.

connect / as sysdba

grant execute on dbms_job  to ipc_user;
grant execute on dbms_pipe to ipc_user;
grant create job to ipc_user;

connect ipc_user/ipc_user

@IPC.pks
@IPC.pkb

create or replace function tq84_proc_memory return varchar2 as

  v_proc varchar2(32000);

begin

  v_proc := q'!
   declare
     x varchar2(200);
   begin
    select
     'Used: '     || round(pga_used_mem    /1048576)||', '||
     'Alloc: '    || round(pga_alloc_mem   /1048576)||', '||
     'Freeable: ' || round(pga_freeable_mem/1048576)||', '||
     'PGA Max: '  || round(pga_max_mem     /1048576)
    into  
      x
    from
      v$process
    where
     addr = (select paddr from v$session where sid = !' || 
             sys_context('USERENV','SID') || q'!);
    :result := x;
  end;!';

    return ipc.exec_plsql_in_other_session(v_proc);

end tq84_proc_memory;
/

show errors

select tq84_proc_memory from dual;

select ipc.exec_plsql_in_other_session('begin :result := user; end;') from dual;

connect / as sysdba
drop user ipc_user cascade;
