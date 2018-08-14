create or replace package tq84_txt as

    function rpd(txt varchar2, len_ number) return varchar2;
    function dt(d date) return varchar2;
    function num(nm number, pattern varchar2) return varchar2;

    function num(nm number, len_left_of_dot pls_integer, len_right_of_dot pls_integer := 0) return varchar2;

end tq84_txt;
/
