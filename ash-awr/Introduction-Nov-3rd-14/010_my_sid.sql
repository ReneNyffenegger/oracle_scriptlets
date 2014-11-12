select sid, serial# from v$session where sid = sys_context('USERENV', 'SID');
