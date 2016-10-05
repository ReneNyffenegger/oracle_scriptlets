create or replace package plan2html as

  procedure write_out(html varchar2);
  procedure explained_stmt_to_table(stmt_id varchar2);

end plan2html;
/
