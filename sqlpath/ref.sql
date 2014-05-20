--
--   Where is an object referenced?
--

select type, name from dba_dependencies where lower(referenced_name) = lower('&1');
