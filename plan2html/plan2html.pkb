create or replace package body plan2html as

  nbsp constant varchar2(6) := chr(38) || 'nbsp;';

  procedure write_out(html varchar2) is -- {
  begin
      insert into plan2html_t values(plan2html_seq.nextval, html);
  end write_out; -- }

  procedure explained_stmt_to_table(stmt_id varchar2) is -- {

    c_show_projection constant boolean := false;

    object_id   varchar2(4000);

    procedure show_step(stmt_id varchar2, pid number, lvl number) is -- {

      v_rowspan number;
      padding_left  varchar2(4000);

      procedure td(text varchar2, attr varchar2:=null) is -- {
        attr_ varchar2(4000);
      begin

        if attr is not null then
           attr_ := ' ' || attr;
        end if;
        write_out('<td' || attr_ || '>' || text || '</td>');
      end td; -- }

    begin


      for step in (select * from plan_table where statement_id = stmt_id and nvl(parent_id, -999) = nvl(pid, -999) order by position) loop
        v_rowspan := 1;

        if c_show_projection then
           v_rowspan := v_rowspan + 1;
        end if;

        padding_left := 'padding-left:' || (lvl * 20) || 'px';

        if step.filter_predicates is not null then
           v_rowspan := v_rowspan + 1;
        end if;
        if step.access_predicates is not null then
           v_rowspan := v_rowspan + 1;
        end if;

        write_out('<tr>'); -- {

        if lvl != step.depth then
           raise_application_error(-20800, 'Wrong assumption lvl=' || lvl || ', depth=' || step.depth || '!');
        end if;

        td(step.id, 'rowspan=' || v_rowspan || ' style=''vertical-align:top; color:grey''');

        if step.object_name is not null then -- {
           object_id := ' <b>' || lower(step.object_owner || '.' || step.object_name) || '</b>';

           if step.object_node is not null then -- {
              
              object_id := object_id || '@' || lower(step.object_node);

           end if; -- }

           
        -- }
        else -- {

           object_id := null;

           if step.object_node is not null then
              raise_application_error(-20800, 'wrong assumption');
           end if;


        end if; -- }

        if step.object_alias is not null then -- {
           if object_id is not null then
              object_id := ' ' || object_id;
           end if;

           object_id := object_id || ' [' || lower(step.object_alias) || ']';

        end if; -- }

        td(lower(step.operation) || ' ' || lower(step.options) || object_id, 'colspan=2 style=''' || padding_left || '''');


        td(lower(step.object_type)); 
        td(      step.object_instance); 
        td(      step.cardinality, 'style=''text-align: right'''); 
        td(      step.cost || ' [' || step.cpu_cost || '+' || step.io_cost || ']'); 
        td(      step.bytes     , 'style=''text-align: right'''); 
        td(      step.temp_space, 'style=''text-align: right'''); 
        td(      step.time); 
        td(      step.qblock_name);  -- Name of the query block (either system-generated or defined by the user with the QB_NAME hint)
        td(      step.partition_start || ' - ' || step.partition_stop || ' [' || step.partition_id || ']'); 
        td(      step.distribution);
--      td('xml: '    || step.other_xml);
--      td('Other: '  || step.other_tag); 
        td(              step.optimizer); -- ALL_ROWS, ANALYZED ...
        td(step.search_columns);  -- Number of index columns with start and stop keys (that is: the number of columns with matching predicates)

        write_out('</tr>'); -- }

        if c_show_projection then -- {
           write_out('<tr>');
           td('');
           td('Proj: ' || step.projection, 'colspan=14');
           write_out('</tr>');
        end if; -- }

        if step.filter_predicates is not null then -- {
           write_out('<tr>');
           td('<span style=''color:grey''>' || replace(substr(step.filter_predicates, 1, 3950), '"', '') || '</span>', 'colspan=14 style=''' || padding_left || '''');
           write_out('</tr>');
        end if; -- }

        if step.access_predicates is not null then -- {
           write_out('<tr>');
           td('<span style=''color:grey''>' || replace(substr(step.access_predicates, 1, 3950), '"', '') || '</span>', 'colspan=14 style=''' || padding_left || '''');
           write_out('</tr>');
        end if; -- }

        show_step(stmt_id, step.id, lvl+1);

      end loop;

    end show_step; -- }

  begin


    write_out('<table border=0 style=''border:black solid 1px''>');
    write_out('<tr style=''background-color:#ecdcff''><td></td><td></td><td></td><td>Typ</td><td>Inst</td><td>Card</td><td>Cost</td><td>Bytes</td><td>Temp</td><td>Time</td><td>qblck</td><td>Part</td><td>Dist</td><td>Opt</td><td>S.C.</td></tr>');
    show_step(stmt_id, null, 0);
    write_out('</table>');

  end explained_stmt_to_table; -- }

end plan2html;
/
show errors
