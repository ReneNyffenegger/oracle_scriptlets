create package body pck_a as -- {

    function foo_bar_baz return varchar2 is -- {
    begin
      return c_foo||c_bar||c_baz;
    end foo_bar_baz; -- }

end pck_a; -- }
/
show errors
