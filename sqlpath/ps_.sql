--
--     Used by ps_upwards.sql and ps_downwards.sql
--
define complete_name=&1
define proc=&2
set    verify off
@spool c:\temp\ps_.dot
declare
  signature varchar2(32);
begin

     if length('&complete_name') = 32 and instr('&complete_name', '.') = 0 then

        -- complete_name seems to be a signature.
        signature := '&complete_name';

     else
        -- complete name seems to be in the 'package.procedure' form:

        select signature into signature
          from plscope_callable 
         where lower(complete_name) = lower('&complete_name');
 
     end if;

     plscope.&proc(signature, 'dot');
end;
/

spool off
@dot c:\temp\ps_

