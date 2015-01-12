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

    function not_really_used return varchar2 is -- {

      type rec_t is record (
          id      number,
          unused  varchar2(100)
      );

      rec rec_t;

    begin

      select id into rec.id from tab_01 where rownum = 1;

      return fun_2 || pck_a.foo_bar_baz;
    end not_really_used; -- }

end pck_b; -- }
/
show errors
