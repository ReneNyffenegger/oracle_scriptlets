set verify off
declare

  r  v$session_wait%rowtype;

begin

  select * into r from v$session_wait where sid = &1;

  dbms_output.put_line('');
  if     r.wait_time = 0 then -- See Metalink 43718.1 / 1360119.1
         dbms_output.put_line('Session is waiting (no CPU activity)');

  else
         dbms_output.put_line('Session is waiting with CPU activity');

         if     r.wait_time > 0 then
                dbms_output.put_line('Duration of last wait in 100th of seconds');

         else
                dbms_output.put_line('TODO: Implement me, wait_time =  ' || r.wait_time);
         --     wait_time = -2 -> 'Duration of last wait unknown'
         --     wait_time = -1 -> 'Last wait < 1 ms'
         --     wait_time < -2 -> 'Time has probl. wrapped'

         end if;

  end if;


  dbms_output.put_line('');
  dbms_output.put_line(r.event);

  if     r.event = 'db file sequential read' then -- See Metalink 181306.1 -- {

         declare
           ts           varchar2( 30);
           fn           varchar2(500);

           is_tempfile  boolean;
         begin

           begin
             select tablespace_name, file_name
             into   ts             , fn
             from   dba_data_files
             where  file_id = r.p1;

             is_tempfile := false;
           exception when no_data_found then

           -- If select statement does not return anything AND
           -- r.p1 > db_files parameter THEN the file is probably
           -- a tempfile:

             select tablespace_name, file_name
             into   ts             , fn
             from   dba_temp_files   t                                 join
                    v$parameter      p  on p.value + t.file_id = r.p1
             where  p.name     = 'db_files';

             is_tempfile := true;

           end;

           dbms_output.put_line('  Tablespace: ' || ts  );
           dbms_output.put_line('  File:       ' || fn  );
           dbms_output.put_line('  Blocks:     ' || r.p3);

           if not is_tempfile then -- { Show segment name

              declare
                own     varchar2(30);
                seg     varchar2(30);
                typ     varchar2(30);
              begin

              --
              --       Slow query ahead
              --
                select owner, segment_name, segment_type
                into   own  , seg         , typ
                from   dba_extents
                where  file_id  = r.p1 and
                       r.p2 between block_id and block_id + blocks - 1;

                dbms_output.put_line('  Segment:    ' || initcap(typ) || ' ' || own || '.' || seg);

              end;

           end if; -- }

        end;

  end if; -- }

end;
/
