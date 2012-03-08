define complete_name=&1
column signature new_value signature
select signature from plscope_callable where lower(complete_name) = lower('&complete_name');
@spool c:\temp\ps_downwards.dot
exec plscope.print_downwards_graph('&signature', 'dot');
spool off
@dot c:\temp\ps_downwards
