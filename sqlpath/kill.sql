--
--
--          Kills the session specified with the SID as argument.
--
--                  SQLPLUS> @kill 190
--
--          whereas the required SID can be determined with a
--
--                  SQLPLUS> select SID, .., ... from v$session where ... 
--
declare
  sid_      number := &1;
  serial_   number;

begin

  select serial# into serial_ from v$session where sid = sid_;

--execute immediate 'alter system kill       session ''' || sid_ || ',' || serial_ || ''' immediate';
  execute immediate 'alter system disconnect session ''' || sid_ || ',' || serial_ || ''' immediate';

end;
/
