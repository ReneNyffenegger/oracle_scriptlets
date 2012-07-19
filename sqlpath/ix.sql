-- Displays the name of the table and its columns belonging to an index.
-- The Name of the index is passed as the first and only argument
-- to this script.

select
  'Table: ' || table_name table_name
from
  dba_indexes
where
  upper(index_name) = upper('&1');

select 
  substr(column_name, 1, 30) columns
from
  dba_ind_columns
where
  upper(index_name) = upper('&1');
