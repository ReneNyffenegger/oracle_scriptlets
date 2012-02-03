
create or replace package schema_to_neato
  authid current_user
as 
  -- Don't confuse with desc_table.tables_t
  type tables_t is table of varchar2(61);

  procedure create_neato(tables in tables_t);
end schema_to_neato;
/
