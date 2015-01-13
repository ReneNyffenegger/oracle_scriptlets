create or replace package body plscope as

    -- Used if it is necessary to prevent circles, for example
    -- in find_call_path_recurse.
    type signatures_seen_t is table of number(1) index by signature_;

    counter number := 0;

    procedure dot_call(caller in varchar2, callee in varchar2) is/*{*/
    begin
        dbms_output.put_line(' "' || caller || '" -> "' || callee || '"');
    end dot_call;/*}*/

    procedure gexf_call(caller in varchar2, callee in varchar2) is/*{*/
    begin
        dbms_output.put_line(' <edge source="' || caller || '" target="' || callee || '"/>');
    end gexf_call;/*}*/

    procedure fill_callable(owner_ in varchar2, delete_existing in boolean) is/*{*/
    begin

        if delete_existing then
           delete plscope_callable;
        end if;

        insert into plscope_callable
              (signature, object_name, name, exclude)
        select signature, object_name, name,       0
          from all_identifiers
         where ( ( type in ('PROCEDURE', 'FUNCTION'                ) and usage = 'DEFINITION' )  or
                 ( type in ('CURSOR'   , 'PACKAGE', 'PACKAGE BODY' ) and usage = 'DECLARATION') 
               ) 
               and owner = owner_;

    end fill_callable;/*}*/

    procedure fill_call(owner_ in varchar2, delete_existing in boolean) is/*{*/
        callers signature_t_;
    begin

        if delete_existing then
           delete plscope_call;
        end if;

        fill_callable(owner_, delete_existing);

        for callable in (select signature from plscope_callable /* TODO: where owner = owner_ */) loop

            callers := who_calls(callable.signature);

            for i in 1 .. callers.count loop

                begin
                insert into plscope_call (caller, callee) values (callers(i), callable.signature);
                exception when others then
--              raise_application_error(-20801, sqlerrm || ': ' ||  callers(i) || ' ' || callable.signature);
                dbms_output.put_line           (sqlerrm || ': ' ||  callers(i) || ' ' || callable.signature);
                end;

            end loop;

        end loop;

    end fill_call;/*}*/

    procedure print_dot_graph is/*{*/
    begin

        dbms_output.put_line('digraph G {');

        for call in (

           select
             caller.object_name object_name_caller,
             caller.name name_caller,
             ' -> ',
             callee.object_name object_name_callee,
             callee.name name_callee
           from
                     plscope_call call
             join plscope_callable caller on call.caller = caller.signature
             join plscope_callable callee on call.callee = callee.signature
        ) loop

           dot_call(call.object_name_caller || '.' || call.name_caller, call.object_name_callee || '.' || call.name_callee);

        end loop;


        dbms_output.put_line('}');

    end print_dot_graph;/*}*/

    procedure print_upwards_graph(sig signature_, format in varchar2) is /*{*/
    begin
    --
    -- Use ../sqlpath/ps_upwards.sql to create a dot file and
    -- render it's content.
    --

        if lower(format) = 'dot' then

              dbms_output.put_line('digraph G ' || chr(123));
              dbms_output.put_line(' graph [overlap=false size="11.7,16.5"];');
              dbms_output.put_line(' node [shape=plaintext fontsize=11 fontname="Arial Narrow"];'); -- shape=record

        elsif lower(format) = 'gefx' then
        --
        -- Fileformat: see http://gexf.net/format/
        --

              dbms_output.put_line('<?xml version="1.0" encoding="UTF-8"?>');
              dbms_output.put_line('<gexf xmlns="http://www.gexf.net/1.2draft" version="1.2">');
              dbms_output.put_line('<edges>');

        end if;


        for r in (


                      with c (complete_name_caller, complete_name_callee, signature_caller, level_) as (
                      ------
                      -- Recursive query:
                      -- First "iteration" get the direct callers of the desired signature_ (parameter sig):
                      --
                                       select complete_name_caller,
                                              complete_name_callee,
                                              signature_caller,
                                              0 level_ -- First iteration, "level" is 0
                                        from plscope_call_v xx
                                       where xx.signature_callee = sig

                              UNION ALL
                      --
                      -- Itaration:
                      -- get the callers of all calls that had been identified
                      -- by the prior iteration:
                      --
                                       select yy.complete_name_caller,
                                              yy.complete_name_callee,
                                              yy.signature_caller,
                                              cc.level_ + 1 level_ -- Next iteration, increase level
                                        from c cc join plscope_call_v yy on
                                              yy.signature_callee = cc.signature_caller and
                                              yy.exclude_caller   = 0
                      )
                      --search depth first by c.object_name_caller set sorting
                      cycle signature_caller set is_cycle to 1 default 0
                      select distinct complete_name_caller, complete_name_callee, signature_caller /*, is_cycle */ from c
                      where
                        is_cycle = 0 /*and
                        level_ < 5*/


        ) loop

           if lower(format) = 'dot' then
                  dot_call(r.complete_name_caller, r.complete_name_callee);
           else
                  gexf_call(r.complete_name_caller, r.complete_name_callee);
           end if;

        end loop;


        if lower(format) = 'dot' then
              dbms_output.put_line(chr(125));
        elsif lower(format) = 'gefx' then
              dbms_output.put_line('</edges>');
              dbms_output.put_line('</gexf>');
        end if;

    end print_upwards_graph;/*}*/

    procedure print_downwards_graph(sig signature_, format in varchar2) is /*{*/
    begin
    --
    -- Use ../sqlpath/ps_downwards.sql to create a dot file and
    -- render it's content.
    --

        if lower(format) = 'dot' then

              dbms_output.put_line('digraph G ' || chr(123));
              dbms_output.put_line(' graph [overlap=false size="11.7,16.5"];');
              dbms_output.put_line(' node [shape=plaintext fontsize=11 fontname="Arial Narrow"];'); -- shape=record

        elsif lower(format) = 'gefx' then
        --
        -- Fileformat: see http://gexf.net/format/
        --

              dbms_output.put_line('<?xml version="1.0" encoding="UTF-8"?>');
              dbms_output.put_line('<gexf xmlns="http://www.gexf.net/1.2draft" version="1.2">');
              dbms_output.put_line('<edges>');

        end if;


        for r in (


                      with c (complete_name_caller, complete_name_callee, signature_callee, level_) as (
                      ------
                      -- Recursive query:
                      -- First "iteration" get the direct callees of the desired signature_ (parameter sig):
                      --
                                       select complete_name_caller,
                                              complete_name_callee,
                                              signature_callee,
                                              0 level_ -- First iteration, "level" is 0
                                        from plscope_call_v xx
                                       where xx.signature_caller = sig and
                                             xx.exclude_callee   =   0

                              UNION ALL
                      --
                      -- Iteration:
                      -- get the callees of all calls that had been identified
                      -- by the prior iteration:
                      --
                                       select yy.complete_name_caller,
                                              yy.complete_name_callee,
                                              yy.signature_callee,
                                              cc.level_ + 1 level_ -- Next iteration, increase level
                                        from c cc join plscope_call_v yy on
                                              yy.signature_caller = cc.signature_callee
                                        where yy.exclude_caller = 0 and
                                              yy.exclude_callee = 0
                      )
                      --search depth first by c.object_name_caller set sorting
                      cycle signature_callee set is_cycle to 1 default 0
                      select distinct complete_name_caller, complete_name_callee, signature_callee /*, is_cycle */ from c
                      where
                        is_cycle = 0 /*and
                        level_ < 5*/


        ) loop

           if lower(format) = 'dot' then
                  dot_call(r.complete_name_caller, r.complete_name_callee);
           else
                  gexf_call(r.complete_name_caller, r.complete_name_callee);
           end if;

        end loop;


        if lower(format) = 'dot' then
              dbms_output.put_line(chr(125));
        elsif lower(format) = 'gefx' then
              dbms_output.put_line('</edges>');
              dbms_output.put_line('</gexf>');
        end if;

    end print_downwards_graph;/*}*/

    function  find_call_path_recurse(sig_from signature_, sig_to signature_, sigs_seen in out nocopy signatures_seen_t) return boolean/*{*/
    is

      found_at_least_one boolean := false;

    begin

    counter := counter + 1;

    if counter > 1000 then
       return false;
    end if;

    -- Check if this function had already been called with the
    -- 'current' value of sig_from:
              if sigs_seen.exists(sig_from) then
              -- Yes, already been called, return so as not to
              -- recurse infinitely (or at least until there's a
              -- stack problem).
                 return false;
              end if;


    -- Mark the 'current' signature as seen, see check above:
              sigs_seen(sig_from) := 1;

              for call in (

                  select
                    complete_name_caller,
                    complete_name_callee,
                    signature_callee
                  from
                    plscope_call_v
                  where
                    signature_caller = sig_from

              ) loop


                 if call.signature_callee = sig_to then
                    dot_call(call.complete_name_caller, call.complete_name_callee);
                    found_at_least_one := true;
                 else

                    if find_call_path_recurse(call.signature_callee, sig_to, sigs_seen) then
                       dot_call(call.complete_name_caller, call.complete_name_callee);
                       found_at_least_one := true;
                    end if;

                 end if;

              end loop;

              return found_at_least_one;


    end find_call_path_recurse;/*}*/

    procedure find_call_path(sig_from signature_, sig_to signature_)/*{*/
    is
    -- Try to find a call path from a 'callable' to another 'callable',
    -- possibly via more than one hop.

              call_count number;

              sigs_seen signatures_seen_t;
              dummy boolean;
    begin


              dbms_output.put_line('digraph G {');
              dbms_output.put_line(' node [shape=plaintext fontsize=11 fontname="Arial Narrow"];');

              dummy := find_call_path_recurse(sig_from, sig_to, sigs_seen);

              dbms_output.put_line('}');


    end find_call_path;/*}*/

    procedure find_definition (/*{*/
       -- In:
       obj_ in varchar2, owner_ in varchar2, obj_typ_ in varchar2, usage_id_ in number,
       --- Out:
       sig out signature_/*, nam_ out varchar2*/
     )
    is

       wait_for_definition varchar2(30) := '?';
       wait_for_type varchar2(30) := '?';
       usage_id_l number;

    begin

       usage_id_l := usage_id_;

       while usage_id_l != 0 and (wait_for_definition != 'DEFINITION' or wait_for_type not in ('FUNCTION', 'PROCEDURE', 'CURSOR', 'PACKAGE', 'PACKAGE BODY')) loop

             select signature, usage /*, name*/, type , usage_context_id
               into sig , wait_for_definition/*, nam_*/, wait_for_type , usage_id_l
              from
                all_identifiers where usage_id    = usage_id_l and
                                      object_name = obj_       and
                                      owner       = owner_     and
                                      object_type = obj_typ_;

       end loop;

       exception when others then

        dbms_output.put_line('find_definition: obj: ' || obj_ || ' / ' || obj_typ_ || ', usage_id: ' || usage_id_ || ',' || usage_id_l);
        dbms_output.put_line('    ' || sqlerrm);

        sig := null;

    end find_definition ;/*}*/

    function  who_calls(sig_called signature_) return signature_t_ is/*{*/
        caller_sig signature_;
        ret signature_t_ := signature_t_();
    begin

        for caller in (
            select object_name, owner, object_type, usage_context_id from all_identifiers
             where signature = sig_called and
                   usage ='CALL'
        ) loop

           find_definition(
             -- In: 
                caller.object_name, 
                caller.owner,
                caller.object_type, 
                caller.usage_context_id, 
             -- Out:
                caller_sig/*, caller_nam*/);

           if caller_sig is not null then

              ret.extend;
              ret(ret.count) := caller_sig;

           else

              dbms_output.put_line('find_definition failed for ' || caller.object_name || ' ' || caller.object_type || ' ' || caller.usage_context_id || ' ' || sig_called);
   
           end if;

        end loop;

        return ret;

    end who_calls;/*}*/

    procedure gather_identifiers is/*{*/
    begin

       execute immediate q'!alter session set plscope_settings='IDENTIFIERS:ALL'!';

       for i in 1 .. 2 loop
       --
       -- For a reason I don't really understand, the loop needs to run twice,
       -- as otherwise not all identifiers are collected correctly.

           for o in (
              select object_type, object_name from user_objects
               where object_type in ('PACKAGE', 'TYPE', 'FUNCTION', 'PROCEDURE', 'TRIGGER') and
                     object_name not in ('PLSCOPE')
           ) loop
    
             begin
               execute immediate 'alter ' || o.object_type || ' ' || o.object_name || ' compile';
             exception when others then
               dbms_output.new_line;
               dbms_output.put_line (sqlerrm);
               dbms_output.put_line (' ' || o.object_name || ' (' || o.object_type || ')');
             end;
    
           end loop;

       end loop;

    end gather_identifiers;/*}*/

end plscope;
/
