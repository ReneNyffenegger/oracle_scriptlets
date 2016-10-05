@plan2html.pkb

delete           plan2html_t;
delete from plan_table where statement_id = 'TEST-01';
explain plan               set statement_id='TEST-01' for select * from all_objects where object_name like :1;
exec plan2html.explained_stmt_to_table     ('TEST-01');

$del   c:\temp\expl.html
@spool c:\temp\expl.html

select html from plan2html_t order by seq;
select '<code><pre>' from dual;
select * from table(dbms_xplan.display(statement_id => 'TEST-01'));
select '</pre></code>' from dual;

@spool_off

$\temp\expl.html
