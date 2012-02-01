drop type  v$sql_table_t;
drop type  v$sql_line_t;

create type v$sql_line_t is object (
--  sql_text     sys.v_$sqlarea.sql_text     %type,
    executions   number, -- sys.v_$sqlarea.executions   %type,
    elapsed_time number, -- sys.v_$sqlarea.elapsed_time %type,
    cpu_time     number, -- sys.v_$sqlarea.cpu_time     %type,
    disk_reads   number, -- sys.v_$sqlarea.disk_reads   %type,
    buffer_gets  number, -- sys.v_$sqlarea.buffer_gets  %type,
    address      raw(4), -- sys.v_$sqlarea.address      %type,
    hash_value   number  -- sys.v_$sqlarea.hash_value   %type
  )
/

create type v$sql_table_t is table of v$sql_line_t
/

