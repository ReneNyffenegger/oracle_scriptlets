create or replace package body debugger as

  procedure abort is/*{*/
    runinfo dbms_debug.runtime_info;
    ret     binary_integer;
  begin
    continue_(dbms_debug.abort_execution);
  end abort;/*}*/

  procedure backtrace is/*{*/
    pkgs dbms_debug.backtrace_table;
    i    number;
  begin
    dbms_debug.print_backtrace(pkgs);
    i := pkgs.first();
    dbms_output.put_line('backtrace');
    while i is not null loop
      dbms_output.put_line('  ' || i || ': ' || pkgs(i).name || ' (' || pkgs(i).line# ||')');
      i := pkgs.next(i);
    end loop;
   exception
    when others then
     dbms_output.put_line('  backtrace exception: ' || sqlcode);
     dbms_output.put_line('                       ' || sqlerrm(sqlcode));
  end backtrace;/*}*/
  
  procedure breakpoints is/*{*/
    brkpts dbms_debug.breakpoint_table;
    i      number;
    v_line number;
  begin
    dbms_debug.show_breakpoints(brkpts); 
    i := brkpts.first();
    dbms_output.put_line('');
    while i is not null loop
      if v_line is not null then
      dbms_output.put( to_char(v_line , '99999'));
      null;
      else
      dbms_output.put('      ');
      end if;

      dbms_output.put( ' ');

      dbms_output.put(to_char(i,'999') || ': ');
      dbms_output.put(rpad(coalesce(brkpts(i).name, ' '), 31));

      dbms_output.put(rpad(coalesce(brkpts(i).owner,' '), 31));

      v_line:=brkpts(i).line#;


      dbms_output.put( ' ');
      dbms_output.put(libunittype_as_string(brkpts(i).libunittype));
      dbms_output.put( ' ');
      dbms_output.put(bp_status_as_string  (brkpts(i).status     ));
     
      dbms_output.put_line('');
      i := brkpts.next(i);
    end loop;
  end breakpoints;/*}*/

  function libunittype_as_string(lut binary_integer) /*{*/
  /* 

      dbms_debug.continue can be called with the following breakflags:
       o  break_next_line       ( Break at next source line (step over calls) ) 
       o  break_any_call        ( Break at next source line (step into calls) )
       o  break_any_return    
       o  break_return        
       o  break_exception     
       o  break_handler       
       o  abort_execution     

       As the user of debugger might want to use continue with variying breakflags, continue_ (with the
       underscore) is the generic wrapper. (I hope this makes sense)

  */
  return varchar2 is
  begin

    if lut = dbms_debug.libunitType_cursor         then return 'Cursor'; end if;
    if lut = dbms_debug.libunitType_procedure      then return 'Proc'  ; end if;
    if lut = dbms_debug.libunitType_function       then return 'Func'  ; end if;
    if lut = dbms_debug.libunitType_function       then return 'Func'  ; end if;
    if lut = dbms_debug.libunitType_package        then return 'Pkg'   ; end if;
    if lut = dbms_debug.libunitType_package_body   then return 'Pkg Bd'; end if;
    if lut = dbms_debug.libunitType_trigger        then return 'Trig'  ; end if;
    if lut = dbms_debug.libunitType_unknown        then return 'Unk'   ; end if;

    return '???';

  end libunittype_as_string;/*}*/

  function  bp_status_as_string(bps binary_integer) return varchar2 is/*{*/
  -- "User friendly" name for breakpoint_status_*
  begin
   
    if bps = dbms_debug.breakpoint_status_unused   then return 'unused'  ; end if;
    if bps = dbms_debug.breakpoint_status_active   then return 'active'  ; end if;
    if bps = dbms_debug.breakpoint_status_disabled then return 'disabled'; end if;
    if bps = dbms_debug.breakpoint_status_remote   then return 'remote'  ; end if;
    
    return '???';

  end bp_status_as_string;/*}*/

  procedure continue_(break_flags in number) is/*{*/
    ret     binary_integer;
    v_err   varchar2(100);
  begin
    dbms_output.put_line('');

    ret := dbms_debug.continue(
      cur_line_,
        break_flags,
       0             +
       dbms_debug.info_getlineinfo   +
       dbms_debug.info_getbreakpoint +
       dbms_debug.info_getstackdepth +
       dbms_debug.info_getoerinfo    +
       0);
  
     if ret = dbms_debug.success then
       dbms_output.put_line('  reason for break: ' ||   str_for_reason_in_runtime_info(cur_line_.reason));
       if cur_line_.reason  = dbms_debug.reason_knl_exit then
         return;
       end if;
       if cur_line_.reason  = dbms_debug.reason_exit then
         return;
       end if;
       --print_runtime_info_with_source(cur_line_,cont_lines_before_, cont_lines_after_,cont_lines_width_);
       print_source(cur_line_, cont_lines_before_, cont_lines_after_);
     elsif ret = dbms_debug.error_timeout then 
       dbms_output.put_line('  continue: error_timeout');
     elsif ret = dbms_debug.error_communication then
       dbms_output.put_line('  continue: error_communication');
     else
       v_err := general_error(ret);
       dbms_output.put_line('  continue: general error' || v_err);
     end if;
  end continue_;/*}*/

  procedure detach is/*{*/
  begin
    dbms_debug.detach_session;
  end detach;/*}*/

  procedure continue is/*{*/
  /*
      continue (calling continue_ with break_flags = 0 ) will run until
      the program hits a breakpoint
  */
  begin
      continue_(0);
  end continue;/*}*/

  procedure delete_bp(breakpoint in binary_integer) is/*{*/
    ret binary_integer;
  begin
    ret := dbms_debug.delete_breakpoint(breakpoint);


    if    ret = dbms_debug.success                then dbms_output.put_line('  breakpoint deleted');
    elsif ret = dbms_debug.error_no_such_breakpt  then dbms_output.put_line('  No such breakpoint exists');
    elsif ret = dbms_debug.error_idle_breakpt     then dbms_output.put_line('  Cannot delete an unused breakpoint');
    elsif ret = dbms_debug.error_stale_breakpt    then dbms_output.put_line('  The program unit was redefined since the breakpoint was set');
    else                                               dbms_output.put_line('  Unknown error');
    end if;
  end delete_bp;/*}*/

  procedure print_var(name in varchar2) is/*{*/
    ret   binary_integer;
    val   varchar2(4000);
    frame number;
  begin

    frame := 0;

    ret := dbms_debug.get_value(
      name,
      frame,
      val,
      null);


    if    ret = dbms_debug.success              then dbms_output.put_line('  ' || name || ' = ' || val);
    elsif ret = dbms_debug.error_bogus_frame    then dbms_output.put_line('  print_var: frame does not exist');
    elsif ret = dbms_debug.error_no_debug_info  then dbms_output.put_line('  print_var: Entrypoint has no debug info');
    elsif ret = dbms_debug.error_no_such_object then dbms_output.put_line('  print_var: variable ' || name || ' does not exist in in frame ' || frame);
    elsif ret = dbms_debug.error_unknown_type   then dbms_output.put_line('  print_var: The type information in the debug information is illegible');
    elsif ret = dbms_debug.error_nullvalue      then dbms_output.put_line('  ' || name || ' = NULL');
    elsif ret = dbms_debug.error_indexed_table  then dbms_output.put_line('  print_var: The object is a table, but no index was provided.');
    else                                             dbms_output.put_line('  print_var: unknown error');
    end if;
 
  end print_var;/*}*/

  procedure start_debugger(debug_session_id in varchar2) is/*{*/
  /*

     This is the first call the debugging session must make. It, in turn, calls
     dbms_debug.attach_session.

     After attaching to the session, it waits for the first event (wait_until_running), which is interpreter starting.

  */
  begin
    dbms_debug.attach_session(debug_session_id);
    --cont_lines_before_ :=   5;
    --cont_lines_after_  :=   5;
    --cont_lines_width_  := 100;

    wait_until_running;
  end start_debugger;/*}*/

--function  start_debugee return varchar2 as/*{*/
--/* This is the first call the debugged session must make. 
--
--   The return value must be passed to the debugging session and used in start_debugger
--*/
--  debug_session_id varchar2(20); 
--begin
--  --select dbms_debug.initialize into debug_session_id from dual;
--  debug_session_id := dbms_debug.initialize;
--  dbms_debug.debug_on;
--  return debug_session_id;
--end start_debugee;/*}*/

  procedure print_proginfo(prginfo dbms_debug.program_info) as/*{*/
  begin
    dbms_output.put_line('  Namespace:  ' || str_for_namespace(prginfo.namespace));
    dbms_output.put_line('  Name:       ' || prginfo.name);
    dbms_output.put_line('  owner:      ' || prginfo.owner);
    dbms_output.put_line('  dblink:     ' || prginfo.dblink);
    dbms_output.put_line('  Line#:      ' || prginfo.Line#);
    dbms_output.put_line('  lib unit:   ' || prginfo.libunittype);
    dbms_output.put_line('  entrypoint: ' || prginfo.entrypointname);
  end print_proginfo;/*}*/

  procedure print_runtime_info(runinfo dbms_debug.runtime_info) as/*{*/
    --rsnt varchar2(40);
  begin
      --rsnt := str_for_reason_in_runtime_info(runinfo.reason);
      dbms_output.put_line('');
      dbms_output.put_line('Runtime Info');
      dbms_output.put_line('Prg Name:      ' || runinfo.program.name);
      dbms_output.put_line('Line:          ' || runinfo.line#);
      dbms_output.put_line('Terminated:    ' || runinfo.terminated);
      dbms_output.put_line('Breakpoint:    ' || runinfo.breakpoint);
      dbms_output.put_line('Stackdepth     ' || runinfo.stackdepth);
      dbms_output.put_line('Interpr depth: ' || runinfo.interpreterdepth);
      --dbms_output.put_line('Reason         ' || rsnt);
      dbms_output.put_line('Reason:        ' || str_for_reason_in_runtime_info(runinfo.reason));
      
      print_proginfo(runinfo.program);
  end print_runtime_info;/*}*/

  procedure print_source (/*{*/
    runinfo       dbms_debug.runtime_info,
    lines_before  number default 0,
    lines_after   number default 0
  ) is
    first_line binary_integer;
    last_line  binary_integer;

    prefix varchar2(  99);
    suffix varchar2(4000);

    --source_lines                 vc2_table;
    source_lines dbms_debug.vc2_table;

    cur_line         binary_integer;
    cur_real_line    number;
  begin

    first_line := greatest(runinfo.line# - cont_lines_before_,1);
    last_line  :=          runinfo.line# + cont_lines_after_    ;

    if first_line is null or last_line is null then
      dbms_output.put_line('first_line or last_line is null');
      print_runtime_info(runinfo);
      return;
    end if;

    if runinfo.program.name is not null and runinfo.program.owner is not null then

      dbms_output.put_line('');
      dbms_output.put_line('  ' || runinfo.program.owner || '.' || runinfo.program.name);

        --select 
        --   cast(multiset(
          for r in (
                select
                  -- 90 is the length in dbms_debug.vc2_table....
                  rownum line,
                  substr(text,1,90) text
                from 
                  all_source 
                where 
                  name   = runinfo.program.name   and
                  owner  = runinfo.program.owner  and
                  type  <> 'PACKAGE'              and
                  line  >= first_line             and 
                  line  <= last_line
                order by 
                  line )-- as vc2_table)
              loop 
--        into
--          source_lines
--        from 
--          dual;
        source_lines(r.line) := r.text;      

      end loop;

    else
     
      dbms_debug.show_source(first_line, last_line, source_lines);

--      select
--        cast(
--          multiset(
--            select culumn_value from 
--              table(
--                cast(source_lines_dbms as dbms_debug.vc2_table)
--              )
--        )as vc2_table)
--      into
--        source_lines
--      from 
--        dual;
    
    end if;

    dbms_output.put_line('');

    cur_line := source_lines.first();
    while cur_line is not null loop
      cur_real_line := cur_line + first_line -1;
    
   -- for r in (select column_value text from table(source_lines)) loop
        prefix := to_char(cur_real_line,'9999');

        if cur_real_line = runinfo.line# then 
           prefix := prefix || ' -> ';
        else
           prefix := prefix || '    ';
        end if;
  
  
        -- TODO, most probably superfluos, 90 is the max width.... (ts, ts)
        --if length(r.text) > v_lines_width then
        --  suffix := substr(r.text,1,v_lines_width);
        --else
        --  suffix := r.text;
        --end if;
  
        suffix := source_lines(cur_line);
        suffix := translate(suffix,chr(10),' ');
        suffix := translate(suffix,chr(13),' ');
        
        --dbms_output.put_line(prefix || suffix);
        dbms_output.put_line(prefix || suffix);
  
    --    line_printed := 'Y';
      
      cur_line := source_lines.next(cur_line);
      --cur_line := cur_line + 1;
    end loop;

    dbms_output.put_line('');

  end print_source;/*}*/

  procedure print_runtime_info_with_source(/*{*/
    runinfo dbms_debug.runtime_info 
    ) is


  begin

    print_runtime_info(runinfo);

    --dbms_output.put_line('line#: ' || runinfo.line#);
    --dbms_output.put_line(' -   : ' || (runinfo.line# - cont_lines_before_));

      --dbms_output.put_line('first_line: ' || first_line);
      --dbms_output.put_line('last_line:  ' || last_line);

    print_source(runinfo);

  end print_runtime_info_with_source;/*}*/

  procedure self_check as/*{*/
    ret binary_integer;
  begin
    dbms_debug.self_check(5);
  exception
    when dbms_debug.pipe_creation_failure  then dbms_output.put_line('  self_check: pipe_creation_failure');
    when dbms_debug.pipe_send_failure      then dbms_output.put_line('  self_check: pipe_send_failure');
    when dbms_debug.pipe_receive_failure   then dbms_output.put_line('  self_check: pipe_receive_failure');
    when dbms_debug.pipe_datatype_mismatch then dbms_output.put_line('  self_check: pipe_datatype_mismatch');
    when dbms_debug.pipe_data_error        then dbms_output.put_line('  self_check: pipe_data_error');
    when others then                            dbms_output.put_line('  self_check: unknown error');
  end self_check;/*}*/

  procedure set_breakpoint(/*{*/
  /* 
     
     Out of the four parameters
       p_cursor, p_toplevel, p_body, p_trigger,
     at most one should be set to zero. They set the
     proginfo.namespace

  */
    p_line     in number, p_name in varchar2 default null, p_owner in varchar2 default null,
    p_cursor   in boolean default false,
    p_toplevel in boolean default false,
    p_body     in boolean default false,
    p_trigger  in boolean default false) 
  as
    proginfo dbms_debug.program_info;
    ret      binary_integer;
    bp       binary_integer;
  begin

    if    p_cursor   then proginfo.namespace := dbms_debug.namespace_cursor;
    elsif p_toplevel then proginfo.namespace := dbms_debug.namespace_pkgspec_or_toplevel;
    elsif p_body     then proginfo.namespace := dbms_debug.namespace_pkg_body;
    elsif p_trigger  then proginfo.namespace := dbms_debug.namespace_trigger;
    else                  proginfo.namespace := null;
    end if;

    proginfo.name           := p_name;
    proginfo.owner          := p_owner;
    proginfo.dblink         := null;
    proginfo.entrypointname := null;
  
    ret := dbms_debug.set_breakpoint(
            proginfo,
            p_line,
            bp);
  
    if    ret = dbms_debug.success            then dbms_output.put_line('  breakpoint set: ' || bp);
    elsif ret = dbms_debug.error_illegal_line then dbms_output.put_line('  set_breakpoint: error_illegal_line');
    elsif ret = dbms_debug.error_bad_handle   then dbms_output.put_line('  set_breakpoint: error_bad_handle');
    else                                           dbms_output.put_line('  set_breakpoint: unknown error (' || ret || ')');
    end if;
  
  end set_breakpoint;/*}*/

  procedure step is/*{*/
  begin
    continue_(dbms_debug.break_next_line);
  end step;/*}*/
 
  procedure step_into is/*{*/
  begin
    continue_(dbms_debug.break_any_call);
  end step_into;/*}*/

  procedure step_out is/*{*/
  begin
    continue_(dbms_debug.break_any_return);
  end step_out; /*}*/
  
  function str_for_namespace(nsp in binary_integer) return varchar2 is/*{*/
    nsps   varchar2(40);
  begin
    if nsp = dbms_debug.Namespace_cursor                 then nsps := 'Cursor (anonymous block)';
    elsif nsp = dbms_debug.Namespace_pkgspec_or_toplevel then nsps := 'package, proc, func or obj type';
    elsif nsp = dbms_debug.Namespace_pkg_body            then nsps := 'package body or type body';
    elsif nsp = dbms_debug.Namespace_trigger             then nsps := 'Triggers';
    else                                                      nsps := 'Unknown namespace';
    end if;

    return nsps;
  end str_for_namespace;/*}*/
  
  function  str_for_reason_in_runtime_info(rsn in binary_integer) return varchar2 is/*{*/
    rsnt varchar2(40);
  begin
    if rsn = dbms_debug.reason_none                    then rsnt := 'none';
    elsif rsn = dbms_debug.reason_interpreter_starting then rsnt := 'Interpreter is starting.';
    elsif rsn = dbms_debug.reason_breakpoint           then rsnt := 'Hit a breakpoint';
    elsif rsn = dbms_debug.reason_enter                then rsnt := 'Procedure entry';
    elsif rsn = dbms_debug.reason_return               then rsnt := 'Procedure is about to return';
    elsif rsn = dbms_debug.reason_finish               then rsnt := 'Procedure is finished';
    elsif rsn = dbms_debug.reason_line                 then rsnt := 'Reached a new line';
    elsif rsn = dbms_debug.reason_interrupt            then rsnt := 'An interrupt occurred';
    elsif rsn = dbms_debug.reason_exception            then rsnt := 'An exception was raised';
    elsif rsn = dbms_debug.reason_exit                 then rsnt := 'Interpreter is exiting (old form)';
    elsif rsn = dbms_debug.reason_knl_exit             then rsnt := 'Kernel is exiting';
    elsif rsn = dbms_debug.reason_handler              then rsnt := 'Start exception-handler';
    elsif rsn = dbms_debug.reason_timeout              then rsnt := 'A timeout occurred';
    elsif rsn = dbms_debug.reason_instantiate          then rsnt := 'Instantiation block';
    elsif rsn = dbms_debug.reason_abort                then rsnt := 'Interpreter is aborting';
    else                                                    rsnt := 'Unknown reason';
    end if;

    return rsnt;
  end str_for_reason_in_runtime_info;/*}*/

  procedure wait_until_running as/*{*/
    runinfo dbms_debug.runtime_info;
    ret     binary_integer;
    v_err   varchar2(100);
  begin
    ret:=dbms_debug.synchronize( runinfo, 0 /*+
      dbms_debug.info_getstackdepth +
      dbms_debug.info_getbreakpoint +
      dbms_debug.info_getlineinfo   +
      dbms_debug.info_getoerinfo    +
      0 */
    );
  
    if ret = dbms_debug.success then 
      print_runtime_info(runinfo);
    elsif ret = dbms_debug.error_timeout then
      dbms_output.put_line('  synchronize: error_timeout');
    elsif ret = dbms_debug.error_communication then
      dbms_output.put_line('  synchronize: error_communication');
    else
       v_err := general_error(ret);
       dbms_output.put_line('  synchronize: general error' || v_err);
      --dbms_output.put_line('  synchronize: unknown error');
    end if;
  
  end wait_until_running;/*}*/

  procedure is_running is/*{*/
  begin
    if dbms_debug.target_program_running then
      dbms_output.put_line('  target (debugee) is running');
    else
      dbms_output.put_line('  target (debugee) is not running');
    end if;
  end is_running;/*}*/

  function  general_error(e in binary_integer) return varchar2 is/*{*/
  begin

    if e = dbms_debug.error_unimplemented then return 'unimplemented'       ; end if;
    if e = dbms_debug.error_deferred      then return 'deferred'            ; end if;
    if e = dbms_debug.error_exception     then return 'probe exception'     ; end if;
    if e = dbms_debug.error_communication then return 'communication error' ; end if;
    if e = dbms_debug.error_unimplemented then return 'unimplemented'       ; end if;
    if e = dbms_debug.error_timeout       then return 'timeout'             ; end if;

    return '???';

  end general_error;/*}*/

  procedure version as/*{*/
    major binary_integer;
    minor binary_integer;
  begin
    dbms_debug.probe_version(major,minor);
    dbms_output.put_line('  probe version is: ' || major || '.' || minor);
  end version;/*}*/

  procedure current_prg is/*{*/
    ri dbms_debug.runtime_info;
    pi dbms_debug.program_info;
    ret binary_integer;
  begin

    ret := dbms_debug.get_runtime_info(
               0             +
               dbms_debug.info_getlineinfo   +
               dbms_debug.info_getbreakpoint +
               dbms_debug.info_getstackdepth +
               dbms_debug.info_getoerinfo    +
               0,
               ri);

     pi := ri.program;

     print_proginfo(pi);
  end current_prg;/*}*/

  begin

    cont_lines_before_ :=   5;
    cont_lines_after_  :=   5;

end debugger;
/
