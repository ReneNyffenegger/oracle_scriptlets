--
--  A procedure that takes a while to run...
--  which SQL statement contributes most to
--  spent time?
--
set timing on

declare

  start_time  date;

begin

  start_time := sysdate;

  <<ONE_MINUTE>> while true loop

     for valor in (
       select valorennr, valorenzusatznr 
         from valorgattung
     ) loop
     
       if start_time +  1 * 1/24/60 < sysdate then
          exit ONE_MINUTE;
       end if;

       ------------------------------------------------------------
       declare
         r bewertungvalor%rowtype;
       begin

       -- 407918886kfkv

         select * into r from bewertungvalor
          where valorennr       = valor.valorennr and
                valorenzusatznr = valor.valorenzusatznr and 
                stichtag        = date '2012-12-20';

       exception
         when no_data_found or 
              too_many_rows then

              null;
       end;

       ------------------------------------------------------------

/*
       declare
         r bewertungvalor%rowtype;
       begin

         execute immediate 'select * from bewertungvalor ' ||
         'where valorennr       = ''' || valor.valorennr || ''' and ' ||
               'valorenzusatznr = ''' || valor.valorenzusatznr || ''' and ' ||
               'stichtag = date ''2012-12-20'' ' into r;

       exception
         when no_data_found or 
              too_many_rows then

              null;
       end;
*/

       ------------------------------------------------------------

       declare
         r valorenkurs%rowtype;
       begin

         select * into r from valorenkurs
          where valorennr       = valor.valorennr and
                valorenzusatznr = valor.valorenzusatznr and
                gueltigabdatum  = date '2012-12-20';

       exception
         when no_data_found or 
              too_many_rows then

              null;

       end;


     end loop;

  end loop;

end;
/
