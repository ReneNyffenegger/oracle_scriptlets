-- Must (should?) be run as system.
--
-- Installs the SQL*Plus PRODUCT_USER_PROFILE tables. These
-- tables allow SQL*Plus to disable commands per user. The tables
-- are used only by SQL*Plus and do not affect other client tools
-- that access the database.  Refer to the SQL*Plus manual for table
-- usage information.
-- This script should be run on every database that SQL*Plus connects
-- to, even if the tables are not used to restrict commands.

@?/sqlplus/admin/pupbld.sql
exit
