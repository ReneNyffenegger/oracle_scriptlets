--
--   Who blocks whom
--

select
  l_blocker.sid,
  s_blocker.osuser,
  l_blocker.lmode     has_mode,
  l_blocker.type,
' blocks '            blocks,
  l_blockee.sid,
  s_blockee.osuser,
  l_blockee.request   wants_mode,
  l_blockee.type
from
  v$lock     l_blocker,
  v$lock     l_blockee,
  v$session  s_blocker,
  v$session  s_blockee
 where 
   l_blocker.block   = 1  and 
   l_blockee.request > 0  and 
   l_blocker.id1     = l_blockee.id1 and 
   l_blocker.id2     = l_blockee.id2 and
   s_blocker.sid     = l_blocker.sid and
   s_blockee.sid     = l_blocker.sid;
