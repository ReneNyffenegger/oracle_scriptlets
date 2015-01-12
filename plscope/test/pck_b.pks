create package pck_b as -- {

    type used_rec_t is record (
         id    tab_01.id%type,
         text  tab_01.text%type
    );

    v_unused_b  date;

    function not_really_used return varchar2;

end pck_b; -- }
/
