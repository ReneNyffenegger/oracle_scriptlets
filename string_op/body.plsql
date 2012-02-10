create or replace package body string_op as

  function strtok      (str in varchar2, delimiter in varchar2)
     return varchar2_t
  IS
    tokens      varchar2_t := varchar2_t();
    i           pls_integer;
    t           varchar2(4000);
  begin

    if str is null then
       return tokens;
    end if;

    t := str;

    loop
      i := instr(t, delimiter);

      tokens.extend;

      if i is null or i = 0  then /* none or last one found */
        tokens(tokens.count) :=  t;
        return tokens;
      else
        tokens(tokens.count) := substr(t, 0, i -1);
      end if;

      t := substr(t,i + length(delimiter),length(t));

    end loop;

  end strtok;

  function strtokregexp(str in varchar2, regexp    in varchar2) return varchar2_t
  is
    tokens       varchar2_t := varchar2_t();
    substr_      varchar2(4000);
    occurrence_  number := 1;
  begin

      loop

        substr_ := regexp_substr(str, regexp, occurrence => occurrence_);

        if substr_ is null then
           return tokens;
        end if;

        tokens.extend;
        tokens(tokens.count) := upper(substr_);

        occurrence_ := occurrence_ + 1;

      end loop;


  end strtokregexp;

end string_op;
/
