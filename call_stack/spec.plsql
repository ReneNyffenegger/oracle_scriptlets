create or replace package call_stack as

    type who_am_i_r is record (

      type_    varchar2(32),
      name_    varchar2(30),
      pkg_name varchar2(30),
      line     number,
      owner    varchar2(30)

    );

    function who_am_i(p_lvl in number := 0) return who_am_i_r;

end call_stack;
/
show errors
