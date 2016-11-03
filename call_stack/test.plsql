
create or replace package test_who_am_i as -- {

   procedure g;
   procedure h;
   procedure i;

end test_who_am_i; -- }
/

create or replace procedure    test_who_am_i_proc as -- {
     w call_stack.who_am_i_r;
begin

     w := call_stack.who_am_i(0);

     if w.pkg_name  is not null             then raise_application_error(-20800, 'pkg_name: ' || w.pkg_name); end if;
     if w.name_     != 'TEST_WHO_AM_I_PROC' then raise_application_error(-20800, 'name: '     || w.name_   ); end if;
     if w.type_     != 'PROCEDURE'          then raise_application_error(-20800, 'type'                    ); end if;
     if w.line      !=  5                   then raise_application_error(-20800, 'line: '     || w.line    ); end if;
     if w.owner     != user                 then raise_application_error(-20800, 'owner'                   ); end if;


end test_who_am_i_proc; -- }
/

create or replace package body test_who_am_i as -- {

   procedure i is -- {
   begin
     h();
   end i; -- }

   procedure h is -- {
     w call_stack.who_am_i_r;
   begin

     w := call_stack.who_am_i(0);

     if nvl(w.pkg_name, '?')  != 'TEST_WHO_AM_I' then raise_application_error(-20800, 'pkg_name: ' || w.pkg_name); end if;
     if nvl(w.name_   , '?')  != 'H'             then raise_application_error(-20800, 'name: '     || w.name_   ); end if;
     if nvl(w.type_   , '?')  != 'PROCEDURE'     then raise_application_error(-20800, 'type: '     || w.type_   ); end if;
     if nvl(w.line    ,  0 )  !=  12             then raise_application_error(-20800, 'line: '     || w.line    ); end if;
     if nvl(w.owner   , '?')  != user            then raise_application_error(-20800, 'owner: '    || w.owner   ); end if;

     w := call_stack.who_am_i(1);

     if nvl(w.pkg_name, '?')  != 'TEST_WHO_AM_I' then raise_application_error(-20800, 'pkg_name: ' || w.pkg_name); end if;
     if nvl(w.name_   , '?')  != 'I'             then raise_application_error(-20800, 'name: ' || w.name_); end if;
     if nvl(w.type_   , '?')  != 'PROCEDURE'     then raise_application_error(-20800, 'type'); end if;
     if nvl(w.line    ,  0 )  !=  5              then raise_application_error(-20800, 'line: ' || w.line); end if;
     if nvl(w.owner   , '?')  != user            then raise_application_error(-20800, 'owner'); end if;

     w := call_stack.who_am_i(2);

     if nvl(w.pkg_name, '?')  != 'TEST_WHO_AM_I' then raise_application_error(-20800, 'pkg_name: ' || w.pkg_name); end if;
     if nvl(w.name_   , '?')  != 'G'             then raise_application_error(-20800, 'name: ' || w.name_); end if;
     if nvl(w.type_   , '?')  != 'PROCEDURE'     then raise_application_error(-20800, 'type'); end if;
     if nvl(w.line    ,  0 )  !=  43             then raise_application_error(-20800, 'line: ' || w.line); end if;
     if nvl(w.owner   , '?')  != user            then raise_application_error(-20800, 'owner'); end if;

     test_who_am_i_proc;
  
   end h; -- }

   procedure g is -- {
   begin

     i();

   end g; -- }
  
end test_who_am_i; -- }
/

exec test_who_am_i.g;

select text  from user_source where name = 'TEST_WHO_AM_I' and type = 'PACKAGE BODY' and line in (12, 5, 43);
