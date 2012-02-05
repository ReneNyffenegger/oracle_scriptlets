create or replace package debugged_package as/*{*/
  function tst_1(i in integer) return integer;
  function tst_2(i in integer) return integer;
end debugged_package;/*}*/
/

create or replace package body debugged_package as/*{*/

  function tst_1(i in integer) return integer is/*{*/
  begin
    if i between 5 and 10 then 
       return 2*i; 
    end if;
    
    if i between 0 and 4 then
       return tst_2(3+i);
    end if;

    if i between 6 and 10 then
       return tst_2(i-2);
    end if;

    return i;
  end tst_1;/*}*/

  function tst_2(i in integer) return integer is/*{*/
  begin
    if i between 6 and 8 then
       return tst_1(i-1);
    end if;

    if i between 1 and 5 then
       return i*2;
    end if;

    return i-1;
  end tst_2;/*}*/

end debugged_package;/*}*/
/

alter package debugged_package compile debug;
