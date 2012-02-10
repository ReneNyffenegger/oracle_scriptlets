create or replace package string_op as

  function strtok      (str in varchar2, delimiter in varchar2) return varchar2_t;
  function strtokregexp(str in varchar2, regexp    in varchar2) return varchar2_t;

end string_op;
/
