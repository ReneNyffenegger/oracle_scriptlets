select decode(
          dbms_profiler.stop_profiler, 
          '0', 'Profiler Stopped', 
          'Could not stop profiler') 
from dual;

exec dbms_profiler.flush_data;

select 
  unit_number, 
  unit_type, 
  unit_name, 
--unit_timestamp, 
  total_time 
from 
  plsql_profiler_units 
where 
  runid = (select runid from plsql_profiler_runs where run_comment = '&&run_comment');


select 
  name,
  line,
  text,
  total_time_100th_sec,
  total_occur
from (
  select
    s.name,
    s.line,
    substr(s.text, 1, 110) text,
    to_char((d.total_time/10000000), '999990.00') total_time_100th_sec,
    d.total_occur,
    row_number() over (order by d.total_time desc) ranking
  from   plsql_profiler_runs  r 
    join plsql_profiler_data  d on r.runid       = d.runid                                 
    join plsql_profiler_units u on d.unit_number = u.unit_number and u.runid = r.runid
    join user_source          s on d.line# = s.line and
                              u.unit_name = s.name and
                              u.unit_type = s.type
  where r.run_comment = '&&run_comment'
)
where ranking < 20;
