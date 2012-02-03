
create or replace package body calendar as

  function EasterSunday(yr in number) return date /*{*/
  is
    a        number;
    b        number;
    c        number;
    d        number;
    e        number;
    m        number;
    n        number;
    day_     number;
    month_   number;

  begin

    if yr < 1583 or yr > 2299 then
       return null;
    end if;

    if    yr < 1700 then m := 22; n :=  2;
    elsif yr < 1800 then m := 23; n :=  3;
    elsif yr < 1900 then m := 23; n :=  4;
    elsif yr < 2100 then m := 24; n :=  5;
    elsif yr < 2200 then m := 24; n :=  6;
    else                 m := 25; n :=  0;
    end if;

    a := mod (yr,19);
    b := mod (yr, 4);
    c := mod (yr, 7);
    d := mod (19*a + m, 30);
    e := mod (2*b + 4*c + 6*d + n,7);

    day_   := 22 + d + e;
    month_ := 3;

    if day_ > 31 then
       day_  := day_-31;
       month_:= month_+1;
    end if;

    if day_ = 26 and  month_ = 4 then
       day_ := 19;
    end if;

    if day_ = 25 and month_ = 4 and d = 28 and e = 6 and a > 10 then
       day_:=18;
    end if;

   return to_date(
          to_char(day_,    '00') || '.' ||
          to_char(month_,  '00') || '.' ||
          to_char(yr,   '0000'),
         'DD.MM.YYYY'
   );

  end EasterSunday;/*}*/

  function CarnivalMonday      (yr in number) return date is begin return EasterSunday(yr) -48; end;
  function MardiGras           (yr in number) return date is begin return EasterSunday(yr) -47; end;
  function AshWednesday        (yr in number) return date is begin return EasterSunday(yr) -46; end;
  function PalmSunday          (yr in number) return date is begin return EasterSunday(yr) - 7; end;
  function EasterFriday        (yr in number) return date is begin return EasterSunday(yr) - 2; end;
  function EasterSaturday      (yr in number) return date is begin return EasterSunday(yr) - 1; end;
  function EasterMonday        (yr in number) return date is begin return EasterSunday(yr) + 1; end;
  function AscensionOfChrist   (yr in number) return date is begin return EasterSunday(yr) +39; end;
  function Whitsunday          (yr in number) return date is begin return EasterSunday(yr) +49; end;
  function Whitmonday          (yr in number) return date is begin return EasterSunday(yr) +50; end;
  function FeastOfCorpusChristi(yr in number) return date is begin return EasterSunday(yr) +60; end;

end;
/
