--
--    :set efm=%f-%l-%c-%m
--    :cf unused_constants.ef
--

@spool unused_constants.ef

select distinct
  lower(x.object_name) || 
    case x.object_type 
         when 'PACKAGE BODY' then '.pkb' 
         when 'PACKAGE'      then '.pks'
    end || '-' ||
  x.line                         || '-' ||
  x.col                          || '-' ||
  x.name   t
from (
   select signature from all_identifiers where usage in ('DECLARATION') and type in ('CONSTANT') and owner = user
   minus
   select signature from all_identifiers where usage in ('REFERENCE') and owner = user
) o, all_identifiers x 
where o.signature = x.signature
order by 
  1
;

@spool_off

