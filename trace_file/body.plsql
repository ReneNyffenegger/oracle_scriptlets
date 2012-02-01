create or replace package body trace_file as

-- Needs
--
--     grant  
--           alter  session       ,
--           create session       ,
--           create procedure     ,
--           create sequence      ,
--           create any directory ,
--           create table         ,
--           create trigger       ,
--           drop   any directory ,
--           create public synonym
--     to <user>;
--     
--     grant select on v_$process   to <user>;
--     grant select on v_$session   to <user>;
--     grant select on v_$parameter to <user>;
--     grant select on dba_users    to <user>;
--     
--     grant execute on utl_file    to <user>;
--
-------------------------------------------------------

  trace_file_dir  varchar2(250);
  trace_file_name varchar2( 50);
  trace_file      utl_file.file_type;

  chars_read      number;
 
  procedure start_(sql_stmt in varchar2, remove_file in boolean := true) is begin/*{*/
    cur_line#  := 0;
    chars_read := 0;

    begin   -- try to create directory 'TRACE_DIR'.
    execute immediate 'create directory trace_dir as ''' || trace_file_dir || '''';
    exception when others then -- Check if directory already existed.
      if sqlcode != -955 then raise; end if;
    end;

    if remove_file then
    -- Try to remove a possibly already existing trace file.
       begin
       utl_file.fremove('TRACE_DIR', trace_file_name);
       exception when utl_file.invalid_operation then
       -- If no such file existed, utl_file will throw
       -- invalid_operation (and we need to do nothing):
          null;
       end;
    end if;

    execute immediate sql_stmt;
  end start_;/*}*/

  procedure stop__(sql_stmt in varchar2) is begin/*{*/
    execute immediate sql_stmt;

--  Print directory and name of trace file
--  dbms_output.put_line('Dir:  ' || trace_file_dir);
--  dbms_output.put_line('Name: ' || trace_file_name);

    trace_file := utl_file.fopen('TRACE_DIR', trace_file_name, 'R', max_line_len);
  end stop__;/*}*/

  function next_line(line out varchar2) return boolean is /*{*/
    -- size of newline, might be 1 on some systems
    size_nl constant number := 2;
  begin
    utl_file.get_line(trace_file, line, max_line_len);

    cur_line#  := cur_line#  + 1;
    chars_read := chars_read + nvl(length(line),0) + size_nl;

    return true;

  exception when no_data_found then 

    execute immediate 'drop directory trace_dir';
    return false;

  when others then 

    raise_application_error(-20000, 
      'Error at line: ' || cur_line#       || 
      ' for file: '     || trace_file_name ||
      ' directory: '    || trace_file_dir  ||
      ' chars read: '   || chars_read      ||
      ' message: '      || sqlerrm);

  end next_line;/*}*/

  procedure dump_block(file_no in number, block_no in number) is/*{*/
  begin
  --  http://www.adp-gmbh.ch/ora/misc/dump_block.html
    
      start_('alter system dump datafile ' || file_no || ' block ' || block_no);
      stop__('alter session set sql_trace=false');

  end dump_block;/*}*/

  procedure dump_block(row_id  in rowid) is/*{*/
  begin

      dump_block(
        file_no  => dbms_rowid.rowid_relative_fno(row_id),
        block_no => dbms_rowid.rowid_block_number(row_id)
      );

  end dump_block;/*}*/

  begin/*{*/

    select 
      u_dump .value  ,
      lower(db_name.value)  || '_ora_' ||
      proc   .spid   || 
      nvl2(proc.traceid,  '_' || proc.traceid, null) || '.trc'

    into trace_file_dir,
         trace_file_name

    from 
                 v$parameter u_dump 
      cross join v$parameter db_name
      cross join v$process   proc
            join v$session   sess
              on proc.addr = sess.paddr
    where 
     u_dump .name   = 'user_dump_dest' and 
     db_name.name   = 'db_name'        and
     sess   .audsid = sys_context('userenv','sessionid');
   /*}*/

end trace_file;
/
