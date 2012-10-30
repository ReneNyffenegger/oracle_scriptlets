--   This script goes along with ./sqlsnape.sql and ../sql_snap
--
--   Ends an SQL snap that started with ./sqlsnaps.sql
--
--   The same functionality, but without ../sql_snap package
--   is offered by sql_snap_t_s.sql/sql_snap_t_e.sql.
--
set  tab off
exec sql_snap.end___;
