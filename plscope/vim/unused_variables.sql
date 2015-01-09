--
--    :set efm=%f-%l-%c-%m
--    :cf unused_variables.ef
--

@spool unused_variables.ef

select
  lower(object_name) || 
    case object_type 
         when 'PACKAGE BODY' then '.pkb' 
         when 'PACKAGE'      then '.pks'
         when 'TYPE BODY'    then '.tyb' 
         when 'TYPE'         then '.tys'
    end || '-' ||
  x.line                         || '-' ||
  x.col                          || '-' ||
  x.name   t
from (
   select 
     signature from all_identifiers where usage in ( 'DEFINITION', 'DECLARATION') and type in (/*'CURSOR'*/ /*'CONSTANT'?*/ 'VARIABLE') and 
  -- object_type in ('PACKAGE BODY') and
     owner = user
   minus
   select signature from all_identifiers where usage not in ('DEFINITION', 'DECLARATION')
) o, 
  all_identifiers x 
where 
  o.signature = x.signature
order by 
  x.object_name,
  x.line desc;

spool off
