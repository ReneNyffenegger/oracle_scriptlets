create or replace package body desc_table as 

  function describe(table_name in varchar2) return description is /*{*/
    -- used for dbms_utility.name_resolve:
    util_context       number := 2;
    util_schema        varchar2(30);
    util_part1         varchar2(30);
    util_part2         varchar2(30);
    util_dblink        varchar2(128);
    util_part1_type    number;
    util_object_number number;

    tab                table_t;
  begin
    dbms_utility.name_resolve(table_name, util_context, util_schema, util_part1, util_part2, util_dblink, util_part1_type, util_object_number);

    tab.own := util_schema;
    tab.nam := util_part1;

    return describe(tab);

  exception
    when others then 
      case 
        when sqlcode = -6564 then 
        raise table_does_not_exist;
      else
        dbms_output.put_line('exception: ' || sqlerrm || '(' || sqlcode || ')' ); 
    end case;

  end describe;/*}*/

  function describe(tab in table_t) return description is/*{*/
    col_r         col_t;
    ret           description;
    v_table_name  varchar2(30);
    v_table_owner varchar2(30);
    col_pos            number;

  begin

    ret.tab          := tab;

    ret.cols         := cols_t        ();
    ret.col_comments := col_comments_t();
    ret.parents      := tables_t      ();
    ret.children     := tables_t      ();

    select comments,table_type into ret.tab_comment, ret.tab_type from all_tab_comments 
     where table_name = tab.nam and owner = tab.own;

    col_pos := 1;

    for r in (/*{*/
      select
        t.column_name, t.data_type, t.data_length, t.data_precision, t.data_scale, t.nullable, c.comments
      from
        all_tab_cols t join all_col_comments c on 
          t.table_name  = c.table_name  and 
          t.column_name = c.column_name and
          t.owner       = c.owner
      where
        t.table_name = tab.nam and t.owner = tab.own
      order by
        column_id) loop

      col_r.name       := r.column_name;
      col_r.nullable   := case when r.nullable = 'Y' then true else false end;
      col_r.datatype   := r.data_type;
      col_r.checks     := check_t();

      if r.data_length is not null and r.data_precision is null then
        if r.data_type <> 'DATE' then
          col_r.datatype := col_r.datatype || '(' || r.data_length || ')';
        end if;
      end if;

      if r.data_precision is not null then
        col_r.datatype := col_r.datatype || '(' || r.data_precision;

        if r.data_scale is not null and r.data_scale > 0 then
          col_r.datatype := col_r.datatype || ',' || r.data_scale;
        end if;

        col_r.datatype := col_r.datatype || ')';
      end if;

      ret.cols.extend;
      ret.cols(ret.cols.count) := col_r;

      if r.comments is not null then
        ret.col_comments.extend;
        ret.col_comments(ret.col_comments.count).pos     := col_pos; 
        ret.col_comments(ret.col_comments.count).comment := r.comments;
      end if;
      
      col_pos := col_pos+1;
    end loop;/*}*/

    for r in (/*{ Find Constraints */
      select
        r_owner, constraint_name, r_constraint_name, constraint_type, search_condition
      from
        all_constraints
      where
        table_name = tab.nam and owner = tab.own) loop

        if r.constraint_type = 'P' then
          for c in (
            select column_name, table_name, position
              from all_cons_columns
             where constraint_name = r.constraint_name) loop

            ret.pks(c.column_name) := c.position;
          end loop;

          select distinct /* distinct in case a table has two foreign keys to table */
            owner, table_name bulk collect into ret.children
          from
            all_constraints
          where
            r_constraint_name = r.constraint_name and
            owner             = tab.own;

        elsif r.constraint_type = 'R' then -- foreign key

          select owner, table_name into v_table_owner, v_table_name 
            from all_constraints 
           where constraint_name = r.r_constraint_name and owner = r.r_owner;

          ret.parents.extend;
          ret.parents(ret.parents.count).own := v_table_owner;
          ret.parents(ret.parents.count).nam := v_table_name;
        end if;

      end loop;/*}*/

    return ret;

  end describe;/*}*/

end;
/
