create or replace package body plscope as

    procedure dot_call(object_name_caller in varchar2, name_caller in varchar2, object_name_callee in varchar2, name_callee in varchar2) is/*{*/
    begin
        dbms_output.put_line ('  "' || object_name_caller || '.' || name_caller || '" -> "' || object_name_callee || '.' || name_callee || '"');
    end dot_call;/*}*/

    procedure fill_callable(owner_ in varchar2, delete_existing in boolean) is/*{*/
    begin

        if delete_existing then 
           delete plscope_callable;
        end if;

        insert into plscope_callable 
              (signature, object_name, name)
        select signature, object_name, name
          from all_identifiers
         where type in ('PROCEDURE', 'FUNCTION') and
               usage = 'DEFINITION'              and
               owner =  owner_;

    end fill_callable;/*}*/

    procedure fill_call(owner_ in varchar2, delete_existing in boolean) is/*{*/
        callees signature_t_;
    begin

        if delete_existing then
           delete plscope_call;
        end if;

        fill_callable(owner_, delete_existing);

        for callable in (select signature from plscope_callable /* TODO:  where owner = owner_ */) loop

            callees := who_calls(callable.signature);

            for i in 1 .. callees.count loop
                
                begin
                insert into plscope_call values (callees(i), callable.signature);
                exception when others then
                raise_application_error(-20801, callable.signature || '  ' || callees(i));
                end;

            end loop;

        end loop;

    end fill_call;/*}*/

    procedure print_dot_graph is/*{*/
    begin

        dbms_output.put_line('digraph G {'); 

        for call in (

           select
             caller.object_name      object_name_caller,
             caller.name             name_caller,
             ' -> ',
             callee.object_name      object_name_callee,
             callee.name             name_callee
           from
                     plscope_call     call
             join    plscope_callable caller on  call.caller = caller.signature
             join    plscope_callable callee on  call.callee = callee.signature
           where
             callee.object_name not in ('VSMLOG', 'VSMCONST', 'VERWENDUNGSNACHWEIS', 'VSMEXC', 'OUTPUT', 'STRINGUTIL', 'VSMTRIGGER', 'Z2X_ADMLOG', 'BATLOG') and
             callee.object_name || '.' || callee.name not in 
                (
                  'TOOLS.EQ', 'TOOLS.DEVISEN_UMRECHNEN', 'TOOLS.SOLLHABENFAKTOR','TOOLS.NICE_ERRM', 'TOOLS.APP', 'TOOLS.BETRAG_IN_CHF',
                  'TOOLS.VERBINDE', 'VALOR_TYP.VALOR_TYP', 'TOOLS.INC',
                  'PORTFOLIO_TYP.NICE_STRING', 'SE_AUFTRAGVARIANTE_TYP.ADD_AUFTRAGSBEWEGUNG',
                 'SECEVENTS_AUFTRAG_ERSTELLEN.CREATE_SE_AUFTRAGBEWEGNG', 'SEGEVENTS.GET_SECEVPARAM_NUM', 'PORTFOLIO_TYP.PORTFOLIO_TYP',
                 'SECEVENTS_RECHNE_AUFTRAGSDATEN.GET_TITEL_POSITIONS_DATEN','TOOLS.BETRAG_GERUNDET',
                 'Z2X_ADMVALST.MAPPING_KAPITALANLAGE_TYP', 'RISIKOANALYSE.EQUAL', 'EINZELVALOREN.IST_EINZELVALOR',
                 'FOND_VISIONEN.WHEN_NULL_FILL_UP_WITH_SPACES', 
                 'VSMTREE.PL', 'RISIKOANALYSE.TEST',
                 'BATLOAD2ADB.STATS')
            and callee.name        not in ('NICE_STRING', 'ADD_C', 'FORMATIERTER_ERRORTEXT', 'CHECKMESSAGE_CONCAT', 'UNTERSCHIED_1_SBI_PF', 'RESET_ADB_STATUS')
            and callee.name        not in ('TEST')
            and callee.object_name not like 'SECEVENT%'
            and callee.object_name not like 'SE_AUFTRAG%'
            and callee.object_name not like 'BATLOD2ADB%'
            and callee.object_name not like 'Z2X%'
            and callee.object_name not in ('BATLOD2ADB', 'ZEIT_AKKUMULATOR_TYP', 'TAB_UTILS')

        ) loop
         
           dot_call(call.object_name_caller, call.name_caller, call.object_name_callee, call.name_callee);

        end loop;


        dbms_output.put_line('}');

    end print_dot_graph;/*}*/

    procedure print_upwards_graph(sig signature_, format in varchar2) is /*{*/
    begin
    --
    --        Use ../sqlpath/ps_upwards.sql to create a dot file and
    --        render it's content.
    --

        if    lower(format) = 'dot' then
      
              dbms_output.put_line('digraph G {');
              dbms_output.put_line('  graph [overlap=false size="11.7,16.5"];');
              dbms_output.put_line('  node [shape=plaintext fontsize=11 fontname="Arial Narrow"];'); -- shape=record

        elsif lower(format) = 'gefx' then

              null; -- TODO.

        end if;


        for r in (


                      with c  (object_name_caller, name_caller, object_name_callee, name_callee, signature_caller, level_)  as (
                                       select object_name_caller, name_caller, 
                                              object_name_callee, name_callee,
                                              signature_caller,
                                              0 level_
                                        from  plscope_call_v xx
                                       where  xx.signature_callee = sig
                             UNION  ALL
                                       select yy.object_name_caller, yy.name_caller, 
                                              yy.object_name_callee, yy.name_callee,
                                              yy.signature_caller,
                                              cc.level_  + 1 level_
                                        from  c cc join plscope_call_v yy on
                                              yy.signature_callee = cc.signature_caller
                                      where   yy.name_caller not like 'TEST%'
                      )
                      --search depth first by c.object_name_caller set sorting
                      cycle signature_caller set is_cycle to 1 default 0
                      select distinct object_name_caller, name_caller, object_name_callee, name_callee, signature_caller /*, is_cycle */ from c
                      where 
                        is_cycle = 0 /*and
                        level_   < 5*/


        )  loop

           dot_call(r.object_name_caller, r.name_caller, r.object_name_callee, r.name_callee);

        end loop;


        if    lower(format) = 'dot' then
              dbms_output.put_line('}');
        elsif lower(format) = 'gefx' then
              null; -- TODO: finish me
        end if;

    end print_upwards_graph;/*}*/

    procedure find_definition (/*{*/
       --   In:
       obj_ in varchar2, obj_typ_ in varchar2, usage_id_ in number,
       ---  Out:
       sig out signature_/*, nam_ out varchar2*/
     ) 
    is 

       wait_for_definition varchar2(30) := '?';
       wait_for_type       varchar2(30) := '?';
       usage_id_l number;
    
    begin

       usage_id_l := usage_id_;

       while wait_for_definition != 'DEFINITION' or wait_for_type not in ('FUNCTION', 'PROCEDURE') loop

             select signature, usage              /*, name*/, type            ,  usage_context_id
               into sig      , wait_for_definition/*, nam_*/, wait_for_type   ,  usage_id_l
              from
                all_identifiers where usage_id    = usage_id_l and
                                      object_name = obj_       and
                                      object_type = obj_typ_;

       end loop;

       exception when others then
         
        dbms_output.put_line('?: ' ||  obj_ || ' / ' || obj_typ_ || ' / ' || usage_id_);

        sig := null;
          
    end find_definition ;/*}*/

    function who_calls(sig_called signature_) return signature_t_ is/*{*/
        caller_sig signature_;
        ret  signature_t_ := signature_t_();
    begin

    -- exec plscope.who_calls('35A5315DE6E5AE2AAC39A5B09E903F13');

        for caller in (
            select object_name, object_type, usage_context_id from all_identifiers
             where signature = sig_called and
                   usage     ='CALL'
        ) loop

           find_definition(caller.object_name, caller.object_type, caller.usage_context_id, caller_sig/*, caller_nam*/);

           if caller_sig is not null then
                                
           ret.extend;
           ret(ret.count) := caller_sig;

           end if;

--         dbms_output.put_line(caller_sig || ' ' || caller.object_name || '.' || caller_nam);

        end loop;

        return ret;

    end who_calls;/*}*/

    procedure gather_identifiers is/*{*/
    begin

       execute immediate q'!alter session set plscope_settings='IDENTIFIERS:ALL'!';

       for o in (
          select object_type, object_name from user_objects
           where object_type in ('PACKAGE', 'TYPE', 'FUNCTION', 'PROCEDURE')
       ) loop

         begin
           execute immediate 'alter ' || o.object_type || ' ' || o.object_name || ' compile';
         exception when others then
           dbms_output.new_line;
           dbms_output.put_line (sqlerrm);
           dbms_output.put_line ('  ' || o.object_name || ' (' || o.object_type || ')');
         end;

       end loop;
  
    end gather_identifiers;/*}*/

end plscope;
/
