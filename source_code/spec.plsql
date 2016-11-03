create or replace package source_code as

   type type_and_name is record (
     type_  varchar2(99),
     name_  varchar2(30)
   );

   -- original code by GARBUYA 2010 ©.
   function name_from_line(p_name varchar2, p_type varchar2, p_line number, p_owner varchar2 := user) return type_and_name;

end source_code;
/
