create or replace package debugger as

/* 
   Package debugger (spec.plsql and body.plsql)

   Copyright (C) René Nyffenegger

   This source code is provided 'as-is', without any express or implied
   warranty. In no event will the author be held liable for any damages
   arising from the use of this software.

   Permission is granted to anyone to use this software for any purpose,
   including commercial applications, and to alter it and redistribute it
   freely, subject to the following restrictions:

   1. The origin of this source code must not be misrepresented; you must not
      claim that you wrote the original source code. If you use this source code
      in a product, an acknowledgment in the product documentation would be
      appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
      misrepresented as being the original source code.

   3. This notice may not be removed or altered from any source distribution.

   René Nyffenegger rene.nyffenegger@adp-gmbh.ch

*/

  procedure abort;   

  procedure backtrace;

  -- highly expermiental
  procedure current_prg;

  procedure breakpoints;

  procedure continue_(break_flags in number);
 
  procedure continue;

  procedure delete_bp(breakpoint in binary_integer);

  procedure print_var(name in varchar2);

  procedure start_debugger(debug_session_id in varchar2);

--function  start_debugee return varchar2;
 
  procedure print_proginfo(prginfo dbms_debug.program_info);
 
  procedure print_runtime_info(runinfo dbms_debug.runtime_info);

  procedure print_source(
    runinfo       dbms_debug.runtime_info,
    lines_before  number default 0,
    lines_after   number default 0
  );


  procedure print_runtime_info_with_source(
                 runinfo        dbms_debug.runtime_info 
                 --v_lines_before in number, 
                 --v_lines_after  in number,
                -- v_lines_width  in number
                 );
 
  procedure self_check;

  procedure set_breakpoint(p_line in number, p_name in varchar2 default null, p_owner in varchar2 default null,
    p_cursor   in boolean default false,
    p_toplevel in boolean default false,
    p_body     in boolean default false,
    p_trigger  in boolean default false);

  procedure step;
 
  procedure step_into;

  procedure step_out;

  function  str_for_namespace(nsp in binary_integer) return varchar2;

  function  str_for_reason_in_runtime_info(rsn in binary_integer) return varchar2;

  procedure wait_until_running;

  procedure is_running;

  procedure version;

  procedure detach;

  function  libunittype_as_string(lut binary_integer) return varchar2;

  function  bp_status_as_string(bps binary_integer) return varchar2;

  function  general_error(e in binary_integer) return varchar2;

  -- the following vars are used whenever continue returnes and shows
  -- the lines arount line
  cont_lines_before_ number;
  cont_lines_after_  number;
--cont_lines_width_  number;

--Store the current line of execution
  cur_line_ dbms_debug.runtime_info;

end debugger;
/
