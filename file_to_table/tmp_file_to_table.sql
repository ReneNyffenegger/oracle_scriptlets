create global temporary table tmp_file_to_table (
  linenumber    number(7),
  linetext      varchar2(4000)
)
on commit delete rows;

comment on table tmp_file_to_table is 'This table is used in conjunction with the %SQLPATH%/file_to_table.sql and %SQLPATH%/file_to_table.bat files.';
