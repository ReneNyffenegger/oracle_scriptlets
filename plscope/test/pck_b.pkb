create package body pck_b as -- {

    function fun_unused return varchar2 is -- {
    begin
      return 'unused';
    end fun_unused; -- }

    function fun_another_unused return varchar2 is -- {
    begin
      return 'another unused';
    end fun_another_unused; -- }

    function fun_2 return varchar2 is -- {
    begin
      return 'fun_2';
    end fun_2;

    function fun_1 return varchar2 is -- {
    begin
      return fun_2 || pck_a.foo_bar_baz;
    end fun_1; -- }

end pck_b; -- }
/
