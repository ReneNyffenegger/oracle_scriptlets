drop   table source_compilation;
create table source_compilation (
  schema       varchar2(30),
  name         varchar2(30),
  type         varchar2(19),
  compile_date date,
  svn_revision number,
  svn_date     date,
  --
  constraint source_compilation_cpk primary key (schema, name, type, compile_date)
) organization index
-- Make storage happy:
pctfree 0 compress
;

create public synonym source_compilation for source_compilation;
