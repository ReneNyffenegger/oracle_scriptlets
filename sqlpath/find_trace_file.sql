-- http://www.adp-gmbh.ch/ora/misc/find_trace_file.html
select 
  u_dump.value   || '/'     || 
  db_name.value  || '_ora_' || 
  v$process.spid || 
  nvl2(v$process.traceid,  '_' || v$process.traceid, null ) || 
  '.trc'  "Trace File"
from 
             v$parameter u_dump 
  cross join v$parameter db_name
  cross join v$process 
        join v$session 
          on v$process.addr = v$session.paddr
where 
 u_dump.name   = 'user_dump_dest' and 
 db_name.name  = 'db_name'        and
 v$session.audsid=sys_context('userenv','sessionid');
