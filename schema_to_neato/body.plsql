create or replace package body schema_to_neato as

  type descriptions is table of desc_table.description;

  procedure print(l in varchar2) is begin
    dbms_output.put_line(l);
  end print;

  procedure add_relations(descs in descriptions) is 
    description desc_table.description;

    procedure add_relation(parent in desc_table.table_t, child in desc_table.table_t) is begin
      print('  "' || child.own || '.' || child.nam || '" -> "' || parent.own || '.' || parent.nam || '" [arrowhead=crow]');
    end add_relation;
  begin
    
    -- iterating over all table descriptions:
    for desc_no in 1 .. descs.count loop
      description := descs(desc_no);

      for child_no in 1 .. description.children.count loop
        for tab_no_i in 1 .. descs.count loop

          if descs(tab_no_i).tab.nam = description.children(child_no).nam and
             descs(tab_no_i).tab.own = description.children(child_no).own then

            add_relation(descs(tab_no_i).tab, descs(desc_no).tab);
          end if;

        end loop;
      end loop;
    end loop;
  end add_relations;

  procedure create_neato(tables in tables_t) is 
    descs descriptions := descriptions();
  begin
    print('digraph ri {'                                      );
    print('  page = "15,10";'                                 ); -- A3
    print('  overlap=false;'                                  );
    print('  splines=true;'                                   );
    print('  node [fontsize=8 fontname=Verdana shape=record];');

    for idx_table in 1 .. tables.count loop
      descs.extend;
      descs(descs.count) := desc_table.describe(tables(idx_table));
    end loop;

    add_relations(descs);
    
    print('}');
  end create_neato;

end schema_to_neato;
/
