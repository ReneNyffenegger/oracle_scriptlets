--
--     See ../plscope and ./ps_find_call_path.sql
--
define complete_name=&1
column signature new_value signature
select signature from plscope_callable where lower(complete_name) = lower('&complete_name');
@spool c:\temp\ps_upwards.dot
exec plscope.print_upwards_graph('&signature', 'dot');
spool off
@dot c:\temp\ps_upwards
