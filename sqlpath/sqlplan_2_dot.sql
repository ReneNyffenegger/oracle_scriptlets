--
--     Creates a graphviz-dot file based on the latest
--     entries in the plan_table (filled by "explain plan
--     for ...") and then produces a graph with dot
--

define temp_dir=c:\temp\
@spool &temp_dir.generated.dot
declare

  function grey_if_not_null(txt in varchar2) return varchar2 is/*{*/
  begin
    
      if txt is null then
         return null;
      end if;

      return ' <font color="#aaaaaa">(' || txt || ')</font>';

  end grey_if_not_null;/*}*/

  procedure nodes_with_same_parent(parent_node in number) is/*{*/
      last_node number;
  begin

      for nodes in (

        select id, position from (
          select id, position,
                 rank () over (order by timestamp desc) r
            from plan_table
           where (parent_node is null and parent_id is null) or
                 (parent_node is not null and parent_id = parent_node)
          )
          where r = 1
          order by position

      ) loop

         if parent_node is not null then 
            dbms_output.put_line (parent_node || ' -> ' || nodes.id || ' [arrowhead=none];');
         end if;

         if last_node is not null then
             dbms_output.put_line(last_node || ' -> ' || nodes.id || ' [color="#aaaaaa" constraint=false];');
         end if;

         last_node := nodes.id;

         nodes_with_same_parent(nodes.id);

      end loop;

  end nodes_with_same_parent;/*}*/

  function  html_encode(txt in varchar2) return varchar2 is
  begin

      return replace(
             replace(txt
                        , '<', chr(38) || 'lt;')
                        , '>', chr(38) || 'gt;');

  end html_encode;
 
begin

  dbms_output.put_line('digraph G {');
  dbms_output.put_line('  node [shape=plaintext fontname="Arial"];');

--First the edges:
--   http://stackoverflow.com/questions/9238672/how-does-a-script-optimally-layout-a-pure-hierarchical-graphviz-dot-graph and
--   https://github.com/ReneNyffenegger/development_misc/tree/master/graphviz/layout/edge_crossing
  nodes_with_same_parent(null);


--Then the nodes:
  for node in (

      select * from  (
               select statement_id,/*{*/
                      plan_id,
                      timestamp,
                      remarks,
                      operation,
                      options,
                      object_node,
                      object_owner,
                      object_name,
                      object_alias,
                      object_instance,
                      object_type,
                      optimizer,
                      search_columns,
                      id,
                      parent_id,
                      depth,
                      position,
                      cost,
                      cardinality,
                      bytes,
                      other_tag,
                      partition_start,
                      partition_stop,
                      partition_id,
                      other,
                      other_xml,
                      distribution,
                      cpu_cost,
                      io_cost,
                      temp_space,
                      access_predicates,
                      filter_predicates,
                      projection,
                      time,
                      qblock_name,
                      --
                      rank() over (order by timestamp desc) r/*}*/
                 from plan_table
      )
      where r = 1
  ) loop/*{*/

     dbms_output.put_line( node.id || ' [label=<');
     dbms_output.put_line('<table border="1" cellborder="0" cellspacing="0">');
     dbms_output.put_line('<tr><td align="left">' ||
        '<font point-size="12">' || node.operation || 
           grey_if_not_null(node.options) ||
        '</font></td></tr>');

     if node.object_name is not null then/*{*/
        dbms_output.put_line('<tr><td>' || 
          '<font point-size="12">' || node.object_name ||
           grey_if_not_null(node.object_alias) ||
          '</font>' ||

          case when node.object_instance is not null then
            ' <font point-size="12" color="#ff8c00" face="Arial Bold">' || node.object_instance || '</font>'
          end ||
          
          '</td></tr>'
        );
     end if;/*}*/

     dbms_output.put_line('<tr><td align="left" bgcolor="#aaaaff">' ||
       '<font point-size="9">Cost: ' || node.cost || ', bytes: ' || node.bytes || ', card: ' || node.cardinality || ', io: ' || node.io_cost || ', cpu: ' || node.cpu_cost || '</font>' ||
       '</td></tr>');

     if node.access_predicates is not null then
        dbms_output.put_line('<tr><td align="left"><font point-size="9">Acc: ' || html_encode(node.access_predicates) || '</font></td></tr>');
     end if;
       
     if node.filter_predicates is not null then
        dbms_output.put_line('<tr><td align="left"><font point-size="9">Flt: ' || html_encode(substr(node.filter_predicates, 1, 50)) || '</font></td></tr>');
     end if;

     if node.projection is not null then

        for proj in (
            select column_value from table(string_op.strtok(node.projection, ', '))
        ) loop
           dbms_output.put_line('<tr><td align="left"><font point-size="9">Proj: ' || proj.column_value ||'</font></td></tr>');
        end loop;
        
     end if;

     dbms_output.put_line('</table>');
     dbms_output.put_line('>];');

  end loop;/*}*/

  dbms_output.put_line('}');

end;
/

spool off
set termout on
@dot &temp_dir.generated
