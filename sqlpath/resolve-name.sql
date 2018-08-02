declare

   procedure resolve_name(name varchar2) is
     schema        varchar2(128);
     part1         varchar2(128);
     part2         varchar2(128);
     dblink        varchar2(128);
     part1_type    number;
     object_number number;
   begin

     for context in (
        select 0 nr, 'table'            type from dual union all
        select 1 nr, 'pl/sql'           type from dual union all
        select 2 nr, 'sequence'         type from dual union all
        select 3 nr, 'trigger'          type from dual union all
        select 4 nr, 'java source'      type from dual union all
        select 5 nr, 'java resource'    type from dual union all
        select 6 nr, 'java class'       type from dual union all
        select 7 nr, 'type'             type from dual union all
        select 8 nr, 'java shared data' type from dual union all
        select 9 nr, 'index'            type from dual
     ) loop
       begin
          dbms_utility.name_resolve (
            name         ,
            context.nr   ,
            schema       ,
            part1        ,
            part2        ,
            dblink       ,
            part1_type   ,
            object_number);

         dbms_output.put_line('');
         dbms_output.put_line('  Type:       ' || context.type);
         dbms_output.put_line('  Schema:     ' || schema);
         dbms_output.put_line('  part1:      ' || part1 );
         if part2 is not null then
            dbms_output.put_line('  part2:      ' || part2 );
         end if;
         dbms_output.put_line('  part1 type: ' || part1_type);

       exception when others then
         if sqlcode = -4047 then -- object specified is incompatible with the flag specified
            null;
         end if;
       end;
     end loop;
   end resolve_name;

begin
   resolve_name('&1');
end;
/
