create or replace package ipc as

    -- $Id: ipc.sps 16460 2014-11-19 09:27:54Z tq84 $

    function exec_plsql_in_other_session(plsql in varchar2, maxwait_seconds in number := 1) return varchar2;

end ipc;
/
