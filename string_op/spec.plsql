create or replace package string_op as

  function strtok      (str in varchar2, delimiter in varchar2) return varchar2_t;
  function strtokregexp(str in varchar2, regexp    in varchar2) return varchar2_t;

--         see http://www.adp-gmbh.ch/blog/2007/04/14.php
--         see also utl_lms
  function sprintf     (format in varchar2, parms in varchar2_t) return varchar2; 

end string_op;
/
