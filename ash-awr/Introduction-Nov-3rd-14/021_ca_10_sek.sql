--
--  An SQL statement that takes a while to finish.
--
--  Note how SQL_ID changes when SQL changes.
--
set timing on

select
  avg(kurs)
from
  bewertungvalor
where
--IT:
--  stichtag between date '2011-01-01' and date '2011-03-22' and
--66er:
    stichtag between 
               date '2013-01-01' and 
               date '2013-02-10' 
    and kurs > 1000;

set timing off
