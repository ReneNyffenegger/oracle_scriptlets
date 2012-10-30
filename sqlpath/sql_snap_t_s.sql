--
--   This script «starts» (hence the 's') an
--   SQL snap. The snap is ended with
--   sql_snap_t_e.sql.
--
--   These two script offer the same functionality
--   as sqlsnaps.sql/sqlsnape.sql, but without the
--   ../sql_snap package.
--
drop table tq84_sql_snap;

create table tq84_sql_snap as
      select 
--           sql_text,
             executions,
             elapsed_time,
             cpu_time,
             disk_reads,
             buffer_gets,
             address,
             hash_value
      from sys.v_$sqlarea;
