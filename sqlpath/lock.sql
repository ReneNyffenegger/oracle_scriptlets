--
--   Who blocks whom
--

with locks as (
  select /*+ materialize */
    l_blocker.sid       blocker_sid,
    l_blocker.lmode     has_mode,
    l_blocker.type      blocker_type,
    l_blockee.sid       blockee_sid,
    l_blockee.request   wants_mode,
    l_blockee.type      blockee_type
  from
    v$lock         l_blocker,
    v$lock         l_blockee
  where 
    l_blocker.block          = 1                   and  -- Identify blocking sessions
    l_blockee.request        > 0                   and  -- Identify blocked sessions
    l_blocker.id1            = l_blockee.id1       and 
    l_blocker.id2            = l_blockee.id2         
)
select 
  locks    .blocker_sid,
  s_blocker.osuser,
  locks    .has_mode,
  locks    .blocker_type,
 'blocks'                  blocks,
  locks    .blockee_sid,
  s_blockee.osuser,
  locks    .wants_mode,
  locks    .blockee_type,
 '|'                       " ",
  obj      .object_name,
  dbms_rowid.rowid_create(1, s_blockee.row_wait_obj#, s_blockee.row_wait_file#, s_blockee.row_wait_block#, s_blockee.row_wait_row#) "rowid"
from 
  locks,
  v$session    s_blockee,
  v$session    s_blocker,
  dba_objects  obj
where
  locks.blockee_sid       = s_blockee.sid and
  locks.blocker_sid       = s_blocker.sid and
  s_blockee.row_wait_obj# = obj.object_id(+)
;
