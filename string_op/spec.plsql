create or replace package &tq84_prefix.string_op as
-- vi: ft=sql
--
-- https://raw.githubusercontent.com/ReneNyffenegger/oracle_scriptlets/master/string_op/spec.plsql
--

  function strtok (str in varchar2, delimiter    in varchar2) return &tq84_prefix.varchar2_t;
  function grep_re(str in varchar2, regexp       in varchar2) return &tq84_prefix.varchar2_t;

--         see http://www.adp-gmbh.ch/blog/2007/04/14.php
--         see also utl_lms
  function sprintf     (format in varchar2, parms in &tq84_prefix.varchar2_t) return varchar2; 

end &tq84_prefix.string_op;
/
show errors
