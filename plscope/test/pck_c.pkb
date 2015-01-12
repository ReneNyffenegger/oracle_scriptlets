create package body pck_c as -- {

    function func_c_02 return varchar2 is begin -- {
      return 'FUNC_D';
    end func_c_02; -- }

    function func_c_01 return varchar2 is begin -- {

      for r in (select * from tab_01) loop

          if    r.text = pck_a.c_foo then
                return 'X';

          elsif r.text = pck_a.c_bar then
                return 'Y';

          elsif r.text = pck_a.c_baz then
                return func_c_02;

          end if;


      end loop;

      return null;

    end func_c_01; -- }

end pck_c; -- }
/
