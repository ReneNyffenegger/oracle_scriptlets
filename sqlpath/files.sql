--
--    Show some basic information about datafiles
--
--    For tablespaces, see -> ts.sql
--

column "Cont"      format a4
column "File name" format a70

select
  case when ts.tablespace_name = lag(ts.tablespace_name) over (order by nvl(df.file_name, tf.file_name)) then '' else initcap(substr(ts.contents, 1, 4)) end "Cont",
  case when ts.tablespace_name = lag(ts.tablespace_name) over (order by nvl(df.file_name, tf.file_name)) then '' else ts.tablespace_name                 end "Name",
  round(ts.max_size / 1024 / 1024 / 1024 , 2)                                                                                                                "TS Max GB",
  substr(nvl(df.file_name, tf.file_name), 1, 70)                                                                                                             "File name",
  to_char(nvl(df.bytes, tf.bytes)/1024/1024/1024, '999990.99')                                                                                               "File GB",
  nvl(df.autoextensible, tf.autoextensible)                                                                                                                  "Auto Ext?"
from
  dba_tablespaces ts                                              left join
  dba_data_files  df  on ts.tablespace_name = df.tablespace_name  left join
  dba_temp_files  tf  on ts.tablespace_name = tf.tablespace_name
order by
  ts.tablespace_name,
  nvl(df.file_name, tf.file_name) ;

prompt
prompt "Trace files"
prompt

select
  initcap(substr(name, 1, 4))  what,
  substr(value, 1, 100)        directory
from
  v$parameter
where
  name like '%dump_dest';
