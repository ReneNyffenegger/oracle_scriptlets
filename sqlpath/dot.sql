--  Create a dotfile 
--  
--    The parameter given to this script is
--    the path to the dot file without (.dot)
--    suffix.
--
--    Creates a file whose type can be specified
--    with dot_output_format in the same directory
--    as the dot file.
--
--    See also spool.sql
--
define dot_output_format=pdf
$dot &1..dot -T&dot_output_format -o&1..&dot_output_format
$&1..&dot_output_format
