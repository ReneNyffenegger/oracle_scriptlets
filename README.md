An attempt to place some scripts from my website
[adp-gmbh.ch](http://www.adp-gmbh.ch) under source control.


# blob_wrapper
A small package used to write blobs to a file and read files
into blob.


# bmp
A small package that can create simple bitmaps drawn unto a
blob.


# calendar
A package to find out when certain dates were. Currently
only supporting Easter and dates fixed in their relation to
Easter.


# create_db_from_cmd.exe
A cmd.exe bat file (named go.bat) that creates an oracle
instance and a database and installs the data dictionary.
The idea is to be able to set various settings (such as
instance name or database name in the script and then let
the script use these settings)


# debugger
A package intended to be a wrapper for dbms_debug.


# desc_table
A package to find information about tables.  (Primary keys,
column-comments etc).  This package is used for the script
/sqlpath/desc.sql


# plscope
A package that uses the `all_identifiers` view to trace
function-dependencies in PL/SQL source code.


# schema_to_neato
A package that uses /desc_table to draw ERDs with
graphviz/neato.


# string_op
A package for operations on strings (varchar2).


# sqlpath
The folder sqlpath contains scripts that are supposed to 
be called from SQL*Plus. Therefore, they should go
to a directory that the environement variable SQLPATH
points to. Usually the login.sql script goes there, too.


# sql_snap
A package that 'snaps' v$sqlarea in order to compare it
later with the newer values in v$sqlarea.  Can be used to
find SQL statements with high executions, cpu_elapsed time
or block gets.  The package comes with /sqlpath/sqlsnaps.sql
and /sqlpath/sqlsnape.sql


# trace_file
A package to read previously dumped trace file (such as
those created by the 10046 event)

