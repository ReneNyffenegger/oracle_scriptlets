--
--   Compare with -> param_nls.sql
--
select
  parameter,
  substrb(value,1,40)
from
  nls_database_parameters;
