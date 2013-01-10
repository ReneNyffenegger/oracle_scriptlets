--
--   Displays the hierarchical relationship of identifiers
--   in a package that has been compiled with PL/Scope enabled.
--
--      alter session set plscope_settings='IDENTIFIERS:ALL'
--
--      alter package ... compile;
--
----------------

with package_identifier_hier 
  (line, col, identifier, type, usage, usage_id, usage_context_id, object_name, object_type, owner, indent)
as (
  select line, 
         col, 
         name identifier, 
         type,
         usage,
         usage_id,
         usage_context_id,
         object_name,
         object_type,
         owner,
         0 indent
    from all_identifiers 
   where owner       = user         and 
         object_name = '&OBJECT_NAME' and 
         object_type = 'PACKAGE BODY' and
         usage_context_id    =  0
      UNION ALL  
  select iteration.line, 
         iteration.col, 
         iteration.name identifier, 
         iteration.type,
         iteration.usage,
         iteration.usage_id,
         iteration.usage_context_id,
         iteration.object_name,
         iteration.object_type,
         iteration.owner,
         predecessor.indent + 1 indent
    from all_identifiers         iteration   join
         package_identifier_hier predecessor on
         predecessor.owner            = iteration.owner       and
         predecessor.object_name      = iteration.object_name and
         predecessor.object_type      = iteration.object_type and
         predecessor.usage_id         = iteration.usage_context_id
  )
select    lpad (' ', 2 * indent) || 
              identifier || ' ' || 
              lower(type) || ' (' || lower(usage) || ')'
              identifier_hierarchy
  from package_identifier_hier
order by line, col;
