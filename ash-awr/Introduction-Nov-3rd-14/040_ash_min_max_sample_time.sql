--
--   Find oldest and most recent timestamp of
--   such gathered statements.
--
--   Oldest records are purged from memory when
--   SQL activity writes new records.
--
select
  to_char(min(sample_time), 'dd.mm.yyyy hh24:mi:ss') min_time,
  to_char(max(sample_time), 'dd.mm.yyyy hh24:mi:ss') max_time,
  count(*)                                           cnt
from
  v$active_session_history;
