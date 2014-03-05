--
-- Avoid ORA-04007: MINVALUE cannot be made to exceed the current value
--

declare
  seq_name      varchar2(30) := '&1';
  new_min_value number       :=  &2;

  diff          number;

  inc_by        number;
  
begin

  select increment_by into inc_by from all_sequences where lower(sequence_name) = lower(seq_name);

  execute immediate 'begin :1 := :2 - ' || seq_name || '.nextval; end;' using out diff, in  new_min_value;

  dbms_output.put_line('Diff: ' || diff);

  execute immediate 'alter sequence ' || seq_name || ' increment by ' || diff;

  execute immediate 'declare dummy number := ' || seq_name || '.nextval; begin null; end;';

  execute immediate 'alter sequence ' || seq_name || ' increment by ' || inc_by;

end;
/
