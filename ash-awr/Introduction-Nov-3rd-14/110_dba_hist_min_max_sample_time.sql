select
  to_char(min(sample_time), 'dd-mm-yyyy hh24:mi:ss') "Min sample time",
  to_char(max(sample_time), 'dd-mm-yyyy hh24:mi:ss') "Max sample time",
  count(*)
from
  dba_hist_active_sess_history;
