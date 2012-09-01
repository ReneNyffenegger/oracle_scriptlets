--
--    Display some space related information about 
--    objects. Currently of objects in own schema.
--
declare
  total_blocks    number;
  total_bytes     number;
  unused_blocks   number;
  unused_bytes    number;
  last_extf       number;
  last_extb       number;
  last_used_block number;
begin

  for t in (select object_name, object_type, owner
              from dba_objects 
             where object_type in ('TABLE', 'INDEX') and
                   owner       =  user) loop
               

       begin

       -- TODO prevent:
       --   o  ORA-03211: The segment does not exist or is not in a valid state
       --   o  ORA-14107: partition specification is required for a partitioned object
       
          dbms_space.unused_space(user, t.object_name, t.object_type, 
             total_blocks,
             total_bytes,
             unused_blocks,
             unused_bytes,
             last_extf,
             last_extb,
             last_used_block
          );

          dbms_output.put_line(rpad   (t.object_name   ,  30            ) || ' ' ||
                               to_char(total_blocks    , '9999999999999') || ' ' ||
                               to_char(unused_blocks   , '9999999999999') || ' ' ||
                               to_char(last_extf       , '9999'         ) || ' ' ||
                          --   to_char(last_extb       , '999999'       ) || ' ' ||
                               to_char(last_used_block , '9999'         ));

       exception when others then
          dbms_output.put_line(t.object_name || ': ' || sqlerrm);
       end;

  end loop;

end;
/
