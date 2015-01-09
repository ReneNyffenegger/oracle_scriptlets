create package pck_a as -- {

    c_foo    constant varchar2(3)  := 'foo';
    c_bar    constant varchar2(3)  := 'bar';
    c_baz    constant varchar2(3)  := 'baz';

    c_unused constant varchar2(10) := 'Unused';

    function foo_bar_baz return varchar2;

end pck_a; -- }
/
