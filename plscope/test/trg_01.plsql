create trigger trg_01
  before insert or update on tab_01
  for each row
begin
  :new.text := pck_c.func_c_trg_01;
end trg_01;
/
