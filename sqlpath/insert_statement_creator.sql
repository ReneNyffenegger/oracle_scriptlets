set tab off
set verify off
@spool c:\temp\insert_statements.sql
declare
--
--     Create SQL statements from real data.
--
table_name varchar2(30)  := ' TABLENAME goes here';
stmt_txt varchar2(32000) := q'!  select * from !' || table_name  ||
                         ' where CONDITION goes here';


  -- Type definitions, record, table etc {


  column_value  varchar2(4000);

  type record_t is table of varchar2(4000);

  --

  type column_t  is record(name varchar2(30), datatype char(1) /* N, D, C */);
  type columns_t is table of column_t;
  column_  column_t;
  columns_  columns_t := columns_t();

  -- }

  column_count integer;

  -- dbms_sql {

  cursor_      integer;
  res_         integer;

  table_desc_  dbms_sql.desc_tab;

  -- }

  procedure column_names_and_types is -- {
  begin

      for c in 1 .. column_count loop -- {

          column_.name         :=  table_desc_(c).col_name;

          column_.datatype     :=  case table_desc_(c).col_type 
                                   when dbms_sql.number_type   then 'N'
                                   when dbms_sql.date_type     then 'D'
                                   when dbms_sql.varchar2_type then 'C'
                                   else '??' -- does not fit into char(1), aborts script!
                                   end;

          columns_.extend;
          columns_(c) := column_;

      end loop; -- }

  end column_names_and_types; -- }

  procedure result_set is -- {
  begin

      loop -- {

          exit when dbms_sql.fetch_rows(cursor_) = 0;

          for c in 1 .. column_count loop

              dbms_output.put('  r.' || lower(columns_(c).name) || ' := ');

              dbms_sql.column_value(cursor_, c, column_value);

              if     column_value is null then

                     dbms_output.put_line('null;');

              else

                     if     columns_(c).datatype = 'D' then
                     
                            dbms_output.put_line('to_date(''' || column_value || ''', ''dd.mm.yyyy hh24:mi:ss'');');

                     elsif  columns_(c).datatype = 'C' then

                            dbms_output.put_line('''' || column_value || ''';');

                     else
                            dbms_output.put_line(column_value || ';');

                     end if;

              end if;

          end loop;

          dbms_output.put_line(' insert into ' || table_name || ' values r;');


      end loop; -- }

  end result_set; -- }

begin

  cursor_  := dbms_sql.open_cursor;
  dbms_sql.parse(cursor_, stmt_txt, dbms_sql.native);

  dbms_sql.describe_columns(/*in*/ cursor_, /*out*/ column_count, /*out*/ table_desc_);

  for c in 1 .. column_count loop -- {

      dbms_sql.define_column(cursor_, c, column_value, 4000);

  end loop; -- }

  res_ := dbms_sql.execute(cursor_);

  column_names_and_types;

  dbms_output.put_line('declare r ' || table_name || '%rowtype; begin');

  result_set;

  dbms_sql.close_cursor(cursor_);

  dbms_output.put_line('end;');
  dbms_output.put_line('/');
  
end;
/
@spool_off
