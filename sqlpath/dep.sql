--
--   Find object dependencies, report them in a «hierarchical» layout.
--
--   See also -> find_unreferenced_objects.sql and -> ref.sql
--
with obj (name, owner, type, level_) as (
   select 
     upper('&object_name'),
     user,
     upper('&object_type'), 
     0
   from
     dual
 union all
   select
     dep.name,
     dep.owner,
     dep.type,
     obj.level_ + 1
   from
     obj  join dba_dependencies
     dep  on obj.name  = dep.referenced_name  and
             obj.owner = dep.referenced_owner and
             obj.type  = dep.referenced_type
)
select
    lpad(' ', level_ * 2) || name || ' [' || owner || ']' || ' {' || type || '}'
from
  obj;
