drop table plan_table purge;
@?/rdbms/admin/utlxplan.sql

drop   table plan2html_t purge;
create table plan2html_t (
  seq    number unique,
  html   varchar2(4000)
);

drop   sequence plan2html_seq;
create sequence plan2html_seq;
