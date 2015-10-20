create or replace package zipper as -- {

--
--  Implementation by Anton Scheffer
--  See https://community.oracle.com/message/4510157#4510157
--
  
  procedure addFile(zip in out blob, filename in varchar2, content in blob);
  procedure finish (zip in out blob);

end zipper; -- }
/
