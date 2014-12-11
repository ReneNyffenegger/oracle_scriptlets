--
--   Where is an object referenced?
--
--   See also -> find_unreferenced_objects.sql and -> dep.sql
--

select type, name from dba_dependencies where lower(referenced_name) = lower('&1');
