--  http://www.adp-gmbh.ch/ora/misc/recursively_list_privilege.html
--
--  Compare with «roles_and_privileges_of_user.sql» and «roles_and_users_of_system_privilege.sql»
--
select
  case when level = 1 then own || '.' || obj || ' (' || typ || ')' else
  lpad (' ', 2*(level-1)) || obj || nvl2 (typ, ' (' || typ || ')', null)
  end
from
  (
  /* THE OBJECTS */
    select 
      null          p1, 
      null          p2,
      object_name   obj,
      owner         own,
      object_type   typ
    from 
      dba_objects
    where
       owner not in 
        ('SYS', 'SYSTEM', 'WMSYS', 'SYSMAN','MDSYS','ORDSYS','XDB', 'WKSYS', 'EXFSYS', 
         'OLAPSYS', 'DBSNMP', 'DMSYS','CTXSYS','WK_TEST', 'ORDPLUGINS', 'OUTLN')
      and object_type not in ('SYNONYM', 'INDEX')
  /* THE OBJECT TO PRIVILEGE RELATIONS */ 
  union
    select
      table_name p1,
      owner      p2,
      grantee,
      grantee,
      privilege
    from
      dba_tab_privs
  /* THE ROLES TO ROLES/USERS RELATIONS */ 
  union
    select 
      granted_role  p1,
      granted_role  p2,
      grantee,
      grantee,
      null
    from
      dba_role_privs
  )
start with p1 is null and p2 is null
connect by p1 = prior obj and p2 = prior own;

