--
--    :set efm=%f-%l-%c-%m
--    :cf unused_functions.ef
--
@spool unused_functions.ef

select
    lower(object_name) || 
      case object_type 
           when 'PACKAGE BODY' then '.pkb' 
           when 'PACKAGE'      then '.pks'
           when 'TYPE BODY'    then '.tyb' 
           when 'TYPE'         then '.tys'
      end || '-' ||
    line                         || '-' ||
    col                          || '-' ||
    name   t
from (
  select distinct
    x.object_name,
    x.object_type,
    x.line,
    x.col,
    x.name
  from (
     select 
       distinct signature 
     from 
       all_identifiers 
     where 
       usage       in ('DEFINITION' ,   'DECLARATION'                   )     and 
       type        in ('FUNCTION', 'PROCEDURE' /*,'CURSOR' ,'VARIABLE'*/)     and 
       object_type in ('PACKAGE', 'PACKAGE BODY')                             and
       owner = user
     minus
     select 
       signature
     from 
       all_identifiers
     where 
--     (usage = 'DECLARATION' and object_type = 'PACKAGE') or -- << Only functions that are declared in package body
--                                                            --    Comment, if all unreferenced functions are desired.
       (usage not in ('DECLARATION', 'DEFINITION'))
  ) o, 
    all_identifiers x 
  where 
    o.signature = x.signature
)
  order by 
    object_name,
    object_type,
    line,
    col;

spool off
