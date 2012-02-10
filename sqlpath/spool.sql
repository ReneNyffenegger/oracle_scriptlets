--  Change settings so that output printed to
--  SQL*Plus (via dbms_output.put_line) can
--  be spooled into a file without heaers
--  or other distracting features.
--
--  developed to be used along with dot.sql
--
set feedback off
set echo off
set trimspool on
set termout off
set lines 500
set pages 0
spool &1

