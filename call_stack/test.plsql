
create or replace package test_who_am_i as

   procedure g;
   procedure h;
   procedure i;

end test_who_am_i;
/

create or replace package body test_who_am_i as

   procedure i is
   begin
      h();
   end i;

   procedure h is
     w call_stack.who_am_i_r;
   begin

     w := call_stack.who_am_i(0);

     if w.name_ != 'H'         then raise_application_error(-20800, 'name: ' || w.name_); end if;
     if w.type_ != 'PROCEDURE' then raise_application_error(-20800, 'type'); end if;
     if w.line  !=  12         then raise_application_error(-20800, 'line: ' || w.line); end if;
     if w.owner != user        then raise_application_error(-20800, 'owner'); end if;

     w := call_stack.who_am_i(1);

     if w.name_ != 'I'         then raise_application_error(-20800, 'name: ' || w.name_); end if;
     if w.type_ != 'PROCEDURE' then raise_application_error(-20800, 'type'); end if;
     if w.line  !=  5          then raise_application_error(-20800, 'line: ' || w.line); end if;
     if w.owner != user        then raise_application_error(-20800, 'owner'); end if;

     w := call_stack.who_am_i(2);

     if w.name_ != 'G'         then raise_application_error(-20800, 'name: ' || w.name_); end if;
     if w.type_ != 'PROCEDURE' then raise_application_error(-20800, 'type'); end if;
     if w.line  !=  37         then raise_application_error(-20800, 'line: ' || w.line); end if;
     if w.owner != user        then raise_application_error(-20800, 'owner'); end if;
  
   end h;

   procedure g is
   begin

     i();

   end g;
  
end test_who_am_i;
/

exec test_who_am_i.g;
