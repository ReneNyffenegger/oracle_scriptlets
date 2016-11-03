create or replace package body source_code as

  function name_from_line(p_name varchar2, p_type varchar2, p_line number, p_owner varchar2 := user) return type_and_name is
  -- original code by GARBUYA 2010 ©.
     v_obj_type        varchar2(30);
     v_curr_line       varchar2(2048);
     in_comment        boolean := false;
     it_is_literal     boolean := false;
     v_pos1            number  := 0;
     v_pos2            number  := 0;
     v_tmp_1           varchar2(1024);
     v_tmp_2           varchar2(1024);
     v_bgn_cnt         number := 0;
     v_end_cnt         number := 0;
     v_blk_cnt         number := 0;
     v_str_len         number := 0;

     v_unknown         type_and_name;
--   v_type_and_name   type_and_name;

     type num_table_t  is table of number;

     v_blk_bgn_len_tbl num_table_t := num_table_t();

     type str_table_t  is table of varchar2(256);

     v_blk_bgn_tbl     str_table_t := str_table_t (' IF '   , ' LOOP '   , ' CASE ', ' BEGIN ');

     type type_and_name_t is table of type_and_name;

     v_name_stack             type_and_name_t := type_and_name_t();

     type str_varr_t   is varray(2) of char(1);
     v_literal_arr     str_varr_t := str_varr_t ('''', '"');
   begin

   v_unknown.type_ := '?';
   v_unknown.name_ := '?';

   for v_idx in v_blk_bgn_tbl.first .. v_blk_bgn_tbl.last loop
      v_blk_bgn_len_tbl.extend(1);
      v_blk_bgn_len_tbl (v_blk_bgn_len_tbl.last) := length(v_blk_bgn_tbl(v_idx));
   end loop;

   for src in (
     select  -- {
        ' ' || replace(
                  translate(upper(text),
                           ';(' || chr(10),
                           '   '
                  ),
                  '''''',
                  ' '
               ) || ' ' text
      from
        all_source
      where
        owner = p_owner and
        name  = p_name  and
        type  = p_type  and
        line  < p_line
      order  by
        line -- }
   )
   loop -- {

     v_curr_line := src.text;

     if in_comment then -- {

        declare
          v_pos_end_comment number;
        begin

          v_pos_end_comment :=  instr (v_curr_line, '*/');

          if v_pos_end_comment > 0 then
             v_curr_line := substr (v_curr_line, v_pos_end_comment + 2);
             v_curr_line := substr (v_curr_line, v_pos1 + 2);
             in_comment := false;
          else
             v_curr_line := ' ';
          end if;
        end;

     end if; -- }

     if v_curr_line != ' ' then -- {

        declare

          v_pos_start_comment   number;
          v_pos_end_comment     number;
          v_text_before_comment varchar2(2048);
          v_text_after_comment  varchar2(2048);

        begin

          v_pos_start_comment := instr(v_curr_line, '/*');

          while v_pos_start_comment > 0 loop -- {

             v_text_before_comment := substr (v_curr_line, 1, v_pos_start_comment - 1);
             v_pos_end_comment := instr  (v_curr_line, '*/');

             if v_pos_end_comment > 0 then
                v_text_after_comment := substr (v_curr_line, v_pos_end_comment + 2);
                v_curr_line              := v_text_before_comment || v_text_after_comment;
             else
                v_curr_line    := v_text_before_comment;
                in_comment := true;
             end if;

             v_pos_start_comment := instr (v_curr_line, '/*');

          end loop; -- }

        end;

        if v_curr_line != ' ' then -- {
           v_pos1 := instr (v_curr_line, '--');

           if v_pos1 > 0 then -- {
              v_curr_line := substr (v_curr_line, 1, v_pos1 - 1);
           end if; -- }

           if v_curr_line != ' ' then -- {

              for v_idx in v_literal_arr.first .. v_literal_arr.last loop -- {

                 v_pos1 := instr (v_curr_line, v_literal_arr (v_idx) );

                 while v_pos1 > 0  loop

                    v_pos2 := instr (v_curr_line, v_literal_arr (v_idx), v_pos1 + 1);

                    if v_pos2 > 0 then

                       v_tmp_1 := substr (v_curr_line, 1, v_pos1 - 1);
                       v_tmp_2 := substr (v_curr_line, v_pos2 + 1);
                       v_curr_line := v_tmp_1 || v_tmp_2;

                    else

                       if it_is_literal then
                          v_curr_line := substr (v_curr_line, v_pos1 + 1);
                          it_is_literal := false;
                       else
                          v_curr_line := substr (v_curr_line, 1, v_pos1 - 1);
                          it_is_literal := true;
                       end if;

                    end if;

                    v_pos1 := instr (v_curr_line, v_literal_arr (v_idx) );

                 end loop;

              end loop; -- }

              if v_curr_line != ' ' then -- {

                 while instr (v_curr_line, '  ') > 0 loop
                    v_curr_line := replace(v_curr_line, '  ', ' ');
                 end loop;

                 v_curr_line := replace(v_curr_line, ' END IF '  , ' END ');
                 v_curr_line := replace(v_curr_line, ' END LOOP ', ' END ');

                 if v_curr_line != ' ' then -- {

                    v_curr_line := ' ' || v_curr_line;

                    v_pos1 := instr(v_curr_line, ' FUNCTION ') + INSTR(v_curr_line, ' PROCEDURE ');

                    if v_pos1 > 0 then -- {

                       v_obj_type := trim(substr(v_curr_line, v_pos1 + 1, 9));  -- get object type


                       v_curr_line := trim(substr(v_curr_line, v_pos1 + 10))||'  ';  -- cut object type
                       v_curr_line :=      substr(v_curr_line, 1,  instr(v_curr_line, ' ') - 1 );  -- get object name

--                     v_type_and_name.name_ := v_curr_line;
--                     v_type_and_name.type_ := v_obj_type ;


                       v_name_stack.extend;
--                     v_name_stack(v_name_stack.last) := v_type_and_name;
                       v_name_stack(v_name_stack.last ).name_  := v_curr_line;
                       v_name_stack(v_name_stack.last ).type_  := v_obj_type ;

                    end if; -- }

                    v_pos1  := 0;
                    v_pos2  := 0;
                    v_tmp_1 := v_curr_line;
                    v_tmp_2 := v_curr_line;

                    for v_idx in v_blk_bgn_tbl.first .. v_blk_bgn_tbl.last loop -- {

                       v_str_len := nvl(length(v_tmp_1),0);
                       v_tmp_1   := replace(v_tmp_1,v_blk_bgn_tbl(v_idx), null);
                       v_bgn_cnt := nvl(length(v_tmp_1), 0);
                       v_pos1    := v_pos1 + (v_str_len - v_bgn_cnt)/v_blk_bgn_len_tbl(v_idx);
                       v_str_len := nvl(length(v_tmp_2),0);
                       v_tmp_2   := replace(v_tmp_2,' END ', null);
                       v_end_cnt := nvl(length(v_tmp_2), 0);
                       v_pos2    := v_pos2 + (v_str_len - v_end_cnt)/5; --- 5 is the length(' end ') 

                    end loop; -- }

                    if v_pos1 > v_pos2 then -- {
                       v_blk_cnt := v_blk_cnt + 1; -- }
                    elsif v_pos1 < v_pos2 then -- {
                       v_blk_cnt := v_blk_cnt - 1;

                       if v_blk_cnt = 0 and v_name_stack.count > 0 then
                          v_name_stack.delete(v_name_stack.last);
                       end if;

                    end if; -- }

                 end if; -- }

              end if; -- }

           end if; -- }

        end if; -- }

     end if; -- }

   end loop; -- }


   return 
     case v_name_stack.last
        when 0 then  v_unknown
        else v_name_stack(v_name_stack.last)
    end;

  end name_from_line;

end source_code;
/

show errors
