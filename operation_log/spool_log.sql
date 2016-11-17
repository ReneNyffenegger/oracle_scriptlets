define root_id=&2

@spool c:\temp\log.txt

exec operation_log.print_id_recursively(p_id => &root_id, p_curly_braces => true)

@spool_off
