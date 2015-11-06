--
--  Compare content of two tables
--
set verify off

define table_1=&1
define table_2=&2


select * from &table_1 minus
select * from &table_2;

select * from &table_2 minus
select * from &table_1;
