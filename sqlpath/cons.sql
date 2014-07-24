declare

-- Show information about a constraint.
--
-- Parameter: name of constraint
--
-- Currently: only PK, FK, unique and check constraints supported.
---           NOT NULL constraints not yet supported.

   r_constraint    dba_constraints%rowtype;
   r_constraint_pk dba_constraints%rowtype;
   r_index         dba_indexes%rowtype;

   owner_           varchar2(30);
   constraint_name_ varchar2(30);
   dot_pos          number;

 
begin

   dbms_output.new_line;

   dot_pos  := instr('&1', '.');

   if dot_pos > 0 then
      owner_           := upper(substr('&1', 1, dot_pos-1));
      constraint_name_ := upper(substr('&1', dot_pos + 1 ));
   else
      constraint_name_ := upper('&1');
   end if;
 
   dbms_output.put_line('Owner:  ' || owner_);
   dbms_output.put_line('constraint name  ' || constraint_name_ );

   begin
     select * into r_constraint from dba_constraints 
      where 
        constraint_name = constraint_name_ and
        nvl(owner_, owner) = owner;

dbms_output.put_line('type: ' || r_constraint.constraint_type);

   exception when no_data_found then

     -- Maybe it's a unique constraint in an index-disguise...

     select * into r_index from dba_indexes 
      where 
        index_name         = constraint_name_   and
        nvl(owner_, owner) = owner              and 
        uniqueness         ='UNIQUE';

     dbms_output.put_line(' Unique key constraint [defined as index]');
     dbms_output.new_line;
     dbms_output.put_line(' Table: ' || r_index.table_name);
     dbms_output.new_line;

     for cols in (
            
            select column_name
              from dba_ind_columns
             where 
               index_name               = constraint_name_    and
               nvl(owner_, index_owner) = index_owner
             order by column_position

     ) loop

        dbms_output.put_line(' ' || cols.column_name);

     end loop;

   end;
 
   if    r_constraint.constraint_type =   'R'       then -- {
 
         select * into r_constraint_pk from dba_constraints 
           where 
             constraint_name    = r_constraint.r_constraint_name and
             owner              = r_constraint.r_owner;
 
         dbms_output.put_line('  Foreign Key constraint');
         dbms_output.new_line;
         dbms_output.put_line('    ' || rpad(r_constraint.owner     , 30) || '    ' || r_constraint_pk.owner);
         dbms_output.put_line('    ' || rpad(r_constraint.table_name, 30) || ' -> ' || r_constraint_pk.table_name);
         dbms_output.put_line('    ' || rpad('-', 30, '-')                || '    ' || rpad('-', 30, '-'));
 
         for cols in (
 
             select
               fk_col.column_name  column_name_fk,
               pk_col.column_name  column_name_pk
             from
               dba_cons_columns   fk_col,
               dba_cons_columns   pk_col
             where
               fk_col.constraint_name = r_constraint   .constraint_name and
               pk_col.constraint_name = r_constraint_pk.constraint_name and
               fk_col.position        = pk_col.position
             order by
               fk_col.position
                
         ) loop
 
           dbms_output.put_line('    ' || rpad(cols.column_name_fk, 30) || '    ' || cols.column_name_pk);
 
         end loop;
   -- }
   elsif r_constraint.constraint_type in ('P', 'U') then -- {

         if r_constraint.constraint_type = 'P' then
            dbms_output.put_line('  Primary Key constraint');
         else
            dbms_output.put_line('  Unique key constraint');
         end if;
         dbms_output.new_line;
         dbms_output.put_line('     Table: ' || r_constraint.table_name);
         dbms_output.new_line;

         for cols in (

             select column_name
               from dba_cons_columns
              where 
                constraint_name = r_constraint.constraint_name and
                nvl(owner_, owner) = owner
              order by position

         ) loop
              
           dbms_output.put_line('            ' || cols.column_name);

         end loop;
 
   -- }
   elsif r_constraint.constraint_type =   'C'       then -- {

         dbms_output.put_line('  Check constraint');
         dbms_output.new_line;
         dbms_output.put_line('     Condition: ' || r_constraint.search_condition);
         dbms_output.new_line;
         dbms_output.put_line('     Table:     ' || r_constraint.table_name);
         dbms_output.put     ('     Columns:   ');

         for cols in (

             select /* position, */  -- Seems to be null for check constraints...
                    row_number() over (order by position) row_,
                    column_name
               from dba_cons_columns
              where 
                constraint_name = r_constraint.constraint_name and
                owner           = r_constraint.owner
              order by position

         ) loop
           
           if cols.row_ = 1 then
              dbms_output.put_line(cols.column_name);
           else
              dbms_output.put_line('                ' || cols.column_name);
           end if;

         end loop;

         dbms_output.new_line;
 
   end if; -- }

end;
/
