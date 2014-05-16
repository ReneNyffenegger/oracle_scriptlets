drop trigger create_package_trg;
create or replace trigger create_package_trg 
after create on schema

declare
  j number;
begin

   if ora_sysevent != 'CREATE' or ora_dict_obj_type not in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE', 'TYPE', 'TYPE BODY') then
      return;
   end if;

  
-- Execute Insert Statement with dbms_job so that it runs in its own 
-- session and can «see» the new source text.

   dbms_job.submit(j, '
   begin
   insert into source_compilation(schema, name, type, compile_date, svn_revision, svn_date)
       select
         schema,
         name,
         type,
         sysdate,
         svn_revision,
         svn_date
       from
         svn_keywords_in_source 
       where
         type = ''' || ora_dict_obj_type || ''' and
         name = ''' || ora_dict_obj_name || ''';
    end;');

    dbms_output.put_line('j: ' || j);
      
END create_package_trg;
/
