--
--  Show schemas/users that don't come with an Oracle Installation
--
select * from all_users
 where username not in (
 'SYS', 'SYSTEM', 'OUTLN', 'DIP', 'ORACLE_OCM', 'DBSNMP', 'APPQOSSYS', 'WMSYS',
'EXFSYS', 'CTXSYS', 'XDB', 'ANONYMOUS', 'XS$NULL', 'ORDDATA', 'ORDPLUGINS',
'SI_INFORMTN_SCHEMA', 'MDSYS', 'ORDSYS', 'OLAPSYS', 'MDDATA',
'SPATIAL_WFS_ADMIN_USR', 'SPATIAL_CSW_ADMIN_USR', 'SYSMAN', 'MGMT_VIEW',
'FLOWS_FILES', 'APEX_PUBLIC_USER', 'APEX_030200', 'OWBSYS_AUDIT', 'OWBSYS',
'SCOTT');
