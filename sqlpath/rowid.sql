--
--  Show information about objects etc. for a rowid.
--
set verify off

declare

  r  rowid := '&1';

  rowid_type    number;
  object_number number;
  relative_fno  number;
  block_number  number;
  row_number    number;

  obj_name      varchar2(30);
  obj_owner     varchar2(30);
  obj_type      varchar2(30);
  obj_sub       varchar2(30);

begin


  dbms_rowid.rowid_info(
    rowid_in      => r            ,
    ------------------------------
    rowid_type    => rowid_type   ,
    object_number => object_number,
    relative_fno  => relative_fno ,
    block_number  => block_number ,
    row_number    => row_number
  );

  select object_name, owner    , object_type, subobject_name
    into obj_name   , obj_owner, obj_type   , obj_sub
    from dba_objects
   where object_id = object_number;

  dbms_output.new_line;
  dbms_output.put_line('Rowid Type:   ' || case rowid_type when dbms_rowid.rowid_type_restricted then 'Restricted' when dbms_rowid.rowid_type_extended then 'Extended' else '?' end);
  dbms_output.put_line('Object:       ' || obj_owner || '.' || obj_name || ' (' || obj_type || ') / ' || object_number);
  if obj_sub is not null then
     dbms_output.put_line('  Sub obj:    ' || obj_sub);
  end if;


  dbms_output.put_line('Rel. Fileno:  ' || relative_fno);
  dbms_output.put_line('Block No:     ' || block_number);
  dbms_output.put_line('Row No:       ' || row_number  );
  dbms_output.new_line;

end;
/
