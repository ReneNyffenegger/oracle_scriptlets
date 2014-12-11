--
--  Gather some basic information about tablespaces.
--
--  Uses -> ts_.sql
--
--  For datafiles see -> files.sql
--
set verify off

prompt
prompt Permanent Tablespaces
prompt =====================
prompt

define tq84_ts_contents='PERMANENT'
@ts_ 

prompt
prompt Temp Tablespaces
prompt ================
prompt

define tq84_ts_contents='TEMPORARY'
@ts_ 

prompt
prompt Undo Tablespaces
prompt ================
prompt

define tq84_ts_contents='UNDO'
@ts_ 

prompt
