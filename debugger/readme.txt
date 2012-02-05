http://www.adp-gmbh.ch/ora/plsql/debug.html

Usage Note, as found on tahiti.oracle.com:
-----------

  Calls to DBMS_DEBUG will succeed only if either the caller or the specified
  debug role carries the DEBUG CONNECT SESSION privilege. Failing that, an
  ORA-1031 error will be raised. Other exceptions are also possible if a
  debug role is specified but the password does not match, or if the calling
  user has not been granted the role, or the role is application-enabled and
  this call does not originate from within the role-enabling package.

  Therefore:

  SQL> grant DEBUG CONNECT SESSION to <user>;
  


---------------------------

TODO:
  What is the connection between sys.dbms_debug and sys.pbsde?

