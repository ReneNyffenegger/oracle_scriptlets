create or replace package call_stack as

    type who_am_i_r is record (

      type_    varchar2( 32),
      name_    varchar2(255), -- 2016-11-22 Because of »0X459AF82320        40  ANONYMOUS BLOCK«
      pkg_name varchar2(255), -- 2016-11-22
      line     number,
      owner    varchar2( 30)

    );

    function who_am_i(p_lvl in number := 0) return who_am_i_r;

end call_stack;
/
show errors
