create package body pck_a as -- {

    function foo_bar_baz return varchar2 is -- {
      v_unused number;
      v_used   varchar2(20);
    begin
      v_used := pck_c.func_c_01;

      return c_foo||c_bar||c_baz||v_used;
    end foo_bar_baz; -- }

end pck_a; -- }
/
show errors
