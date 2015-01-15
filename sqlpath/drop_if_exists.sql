set verify off
declare
--
--    TODO: Synonyms can have the same name as a table, view, package etc.
--

  obj_name varchar2(30) := '&1';
  obj_type varchar2(30);

begin

  select object_type into obj_type
    from user_objects
   where object_name = upper(obj_name) and
         object_type not like '% BODY';

  execute immediate 
    'drop ' || obj_type || ' ' || obj_name || case when obj_type = 'TABLE' then ' purge' end;

exception
   when no_data_found then 
        null;

   when others then
        dbms_output.put_line(obj_name || ' caused ' || sqlerrm);

end;
/
