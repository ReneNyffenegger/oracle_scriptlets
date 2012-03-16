set serveroutput on size 999999 format wrapped
set feedback off
set lines            190
set pages           5000
set long          100000
set longchunksize 100000
set tab              off

define _editor=gvim

alter session set nls_date_format = 'dd.mm.yyyy hh24:mi:ss';
