--
--  This script needs the package desc_table, found in ..\desc_table\spec.plsql and ..\desc_table\body.plsql
--
set verify off

declare
  description desc_table.description;
  cols        desc_table.cols_t;
  cur_col_no  number;
  i           number;

begin

  description := desc_table.describe('&1');
  cols        := description.cols;

  dbms_output.new_line;
  dbms_output.put_line(' Describing ' || description.tab.own || '.' || description.tab.nam);
  dbms_output.put_line(' Type:      ' || description.tab_type);
  dbms_output.put_line(' Comment:   ' || description.tab_comment);

  dbms_output.put_line(' ------------------------------------------------------------');
  dbms_output.put_line(' Name                           Null?    Type              PK');
  dbms_output.put_line(' ------------------------------ -------- ----------------- --');

  cur_col_no := cols.first;
  while cur_col_no is not null loop/*{*/
    dbms_output.put(' ');

    dbms_output.put(rpad(cols(cur_col_no).name,30));

    dbms_output.put(' ');

    if (cols(cur_col_no).nullable) then
      dbms_output.put('         ');        
    else
      dbms_output.put('NOT NULL ');
    end if;

    dbms_output.put(rpad(cols(cur_col_no).datatype, 17));

    if description.pks.exists(cols(cur_col_no).name) then
      dbms_output.put(lpad(to_char(description.pks(cols(cur_col_no).name)),3)); 
    else
      dbms_output.put('   ');
    end if;
   
    dbms_output.new_line();
    cur_col_no:=cols.next(cur_col_no);
  end loop;/*}*/

  if description.parents.count > 0 then/*{*/
    dbms_output.new_line;
    dbms_output.put_line(' Parents: ');

    for parent_no in 1 .. description.parents.count loop
      dbms_output.put_line('  ' || description.parents(parent_no).own || '.' || description.parents(parent_no).nam);
    end loop;

    dbms_output.new_line;
  end if;/*}*/

  if description.children.count > 0 then/*{*/
    dbms_output.new_line;
    dbms_output.put_line(' Children: ');

    for child_no in 1 .. description.children.count loop
      dbms_output.put_line('  ' || description.children(child_no).own || '.' || description.children(child_no).nam);
    end loop;

    dbms_output.new_line;
  end if;/*}*/

  if description.col_comments.count > 0 then/*{*/
    dbms_output.new_line;
    dbms_output.put_line(' Column comments:');
    dbms_output.put_line(' ---------------');
    dbms_output.new_line;
  
    for cur_col_idx /* not pos ! */ in 1 .. description.col_comments.count loop
      dbms_output.put(' ');
  
      dbms_output.put_line(cols(description.col_comments(cur_col_idx).pos).name || ': ' || description.col_comments(cur_col_idx).comment);
      dbms_output.new_line;
     
      cur_col_no:=cols.next(cur_col_no);
    end loop;
  end if;/*}*/

  exception/*{*/
    when desc_table.table_does_not_exist then
      dbms_output.put_line('no such table: &1');

    when others then
      dbms_output.put_line('unknown exception, ' || sqlerrm || '(' || sqlcode || ')');
/*}*/
end;
/
