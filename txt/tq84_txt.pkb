create or replace package body tq84_txt as

   function rpd(txt varchar2, len_ number) return varchar2 is
   begin
       if txt is null then
          return rpad(' ', len_);
       end if;
       return rpad(txt, len_);
   end rpd;

   function num(nm number, pattern varchar2) return varchar2 is
   begin

       if nm is null then
          return rpad(' ', length(pattern) + 1);
       end if;

       return to_char(nm, pattern);
   end num;

   function num(nm number, len_left_of_dot pls_integer, len_right_of_dot pls_integer := 0) return varchar2 is
      pattern varchar2(100);
   begin

     pattern := lpad('9', len_left_of_dot - 1, '9');
     pattern := pattern || '0';

     if len_right_of_dot > 0 then
        pattern := pattern || '.';
        pattern := pattern || lpad('0', len_right_of_dot, '0');
     end if;

     return num(nm, pattern);

   end num;

   function dt(d date) return varchar2 is
   begin
       return to_char(d, 'yyyy-mm-dd');
   end dt;

end tq84_txt;
/
