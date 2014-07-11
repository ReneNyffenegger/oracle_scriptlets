--
--     Executue an SQL-query (select statement) that is stored in 
--     the file with the name passed as the first argument (sqlFile)
--     and store the result as csv (with ; as seperators)
--
--     Additionally, create a header line with the column names of the
--     result set.
--
--     TODO: Currently, the SQL statement must not have an ending /
--
define sqlFile=&1
define csvFile=&2

set   trimspool on
set   lines 5000
@spool &csvFile

declare

   sql_stmt varchar2(32000) :=
q'{
@&sqlFile
}';


  cur     number;
  cntCols number;
  cols    dbms_sql.desc_tab;

  header  varchar2(32000);

  selected_columns varchar2(32000);

  result  sys_refcursor;

  v       varchar2(5000);
  

begin

--Remove possible trailing semicolon «;» in sqlFile.
  sql_stmt := regexp_replace(sql_stmt, ';\s*$', '');

  cur := dbms_sql.open_cursor;
  dbms_sql.parse(cur, sql_stmt, dbms_sql.native);
  dbms_sql.describe_columns(cur, cntCols, cols);

  for col in 1 .. cntCols loop

      if selected_columns is not null then 
         selected_columns := selected_columns || '||'';''||';
         header := header || ';';
      end if;

      header           := header                  || cols(col).col_name;
      selected_columns := selected_columns || '"' || cols(col).col_name || '"';

  end loop;

  dbms_sql.close_cursor(cur);

  dbms_output.put_line(header);

  open result for 'select ' || selected_columns || ' v from (' || sql_stmt || ')';

  loop
      fetch result into v;
      exit when result%notfound;
      dbms_output.put_line(v);
  end loop;

  close result;

end;
/

@spool_off
