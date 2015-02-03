set verify off
declare
--
--    TODO: Synonyms can have the same name as a table, view, package etc.
--
--    To drop a user/schema, use
--       drop_schema_if_exists.sql
--

  obj_name  varchar2(30) := '&1';
  obj_owner varchar2(30);
  obj_type  varchar2(30);

begin

  select owner, object_type into obj_owner, obj_type
    from (
      select owner, object_type,
             row_number() over (order by case when owner = user then 1 else 2 end) r
        from all_objects
       where object_name = upper(obj_name) and
             object_type not like '% BODY'
    )
    where r = 1;

  execute immediate
    'drop ' || obj_type || ' ' || obj_name || case when obj_type = 'TABLE' then ' purge' end;

exception
   when no_data_found then
        null;

   when others then
        dbms_output.put_line(obj_name || ' caused ' || sqlerrm);

end;
/
