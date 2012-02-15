create or replace package body sql_snap as
--
--   Needs
--     grant select on sys.v_$sqlarea to <user>


  v$sql_table v$sql_table_t;

  procedure start_ is/*{*/
  --    called by ../sqlpath/sqlsnaps.sql 
  begin
      select v$sql_line_t (
--           sql_text,
             executions,
             elapsed_time,
             cpu_time,
             disk_reads,
             buffer_gets,
             address,
             hash_value
      )
      bulk collect into v$sql_table
      from sys.v_$sqlarea;

  end start_;/*}*/

  procedure end___ is/*{*/
  --    called by ../sqlpath/sqlsnape.sql 
  begin
    for line in (
        select 
          rpad(sql_text, 130) sql_text,
          executions,
          elapsed_time,
          cpu_time,
          disk_reads,
          buffer_gets
        from (
          select
            e.sql_text,
            e.executions             - nvl(s.executions  , 0)                            executions  ,
            to_char( (e.elapsed_time - nvl(s.elapsed_time, 0)) / 1000000, '9999990.00')  elapsed_time,
            to_char( (e.cpu_time     - nvl(s.cpu_time    , 0)) / 1000000, '9999990.00')  cpu_time    ,
            e.disk_reads             - nvl(s.disk_reads  , 0)                            disk_reads  ,
            e.buffer_gets            - nvl(s.buffer_gets , 0)                            buffer_gets 
          from
            sys.v_$sqlarea     e left join
            table(v$sql_table) s on e.address    = s.address and
                                    e.hash_value = s.hash_value
          where
            e.executions   - nvl(s.executions  , 0) > 0
          order by
            e.elapsed_time - nvl(s.elapsed_time, 0) desc
        ) 
        where rownum < 40
    ) loop

       dbms_output.put(        line.sql_text                  || '  ');
       dbms_output.put(to_char(line.executions  , '9999999' ) || '  ');
       dbms_output.put(        line.elapsed_time              || '  ');
       dbms_output.put(        line.cpu_time                  || '  ');
       dbms_output.put(to_char(line.disk_reads  , '9999999' ) || '  ');
       dbms_output.put(to_char(line.buffer_gets , '9999999' )        );
       dbms_output.new_line;

    end loop;

  end end___;/*}*/


end sql_snap;
/
