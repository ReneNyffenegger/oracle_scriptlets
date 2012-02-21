--
--     See ../plscope and ./ps_upwards.sql
--
define complete_name_from=&1
define complete_name_to=&2
column signature_from new_value signature_from
column signature_to   new_value signature_to
select signature signature_from from plscope_callable where lower(complete_name) = lower('&complete_name_from');
select signature signature_to   from plscope_callable where lower(complete_name) = lower('&complete_name_to'  );
@spool c:\temp\ps_find_call_path.dot
exec plscope.find_call_path('&signature_from', '&signature_to');
spool off
@dot c:\temp\ps_find_call_path

