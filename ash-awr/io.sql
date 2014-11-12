--
-- @SQLToExcel  29879  29907 io.sql """Total MB:30,30,30|10;Total read MB:0,0,255|5;Total write MB:0,255,0|5;Total small read MB:255,87,223|2;Total large read MB:151,151,151|2;Total small write MB:100,100,50|2;Total large write MB:50,100,80|2"""
--
with 
io as              ( -- {
  select 
    snap_id,
    --
    sum_sm_r_mb                                                     total_sm_r_mb,
    sum_lg_r_mb                                                     total_lg_r_mb,
    --
    sum_sm_w_mb                                                     total_sm_w_mb,
    sum_lg_w_mb                                                     total_lg_w_mb,
    --
   (sum_sm_r_mb + sum_lg_r_mb)                                      total_r_mb,
   (sum_sm_w_mb + sum_lg_w_mb)                                      total_w_mb,
   (sum_sm_r_mb + sum_lg_r_mb + sum_sm_w_mb + sum_lg_w_mb)          total_mb
  from (
    select
      snap_id,
      --
      sum(small_read_megabytes ) - lag(sum(small_read_megabytes )) over (order by snap_id) sum_sm_r_mb,
      sum(large_read_megabytes ) - lag(sum(large_read_megabytes )) over (order by snap_id) sum_lg_r_mb,
      sum(small_write_megabytes) - lag(sum(small_write_megabytes)) over (order by snap_id) sum_sm_w_mb,
      sum(large_write_megabytes) - lag(sum(large_write_megabytes)) over (order by snap_id) sum_lg_w_mb
    from
      dba_hist_iostat_detail
    where snap_id -1 between &SnapBegin and &SnapEnd
    group by 
      snap_id
    )
) -- }
select
  to_char(snap.end_interval_time, 'dd.mm hh24 dy') "Snap End",
  --
  total_mb                                         "Total MB",
    total_r_mb                                     "Total read MB",
    total_w_mb                                     "Total write MB",
      total_sm_r_mb                                "Total small read MB",
      total_lg_r_mb                                "Total large read MB",
      total_sm_w_mb                                "Total small write MB",
      total_lg_w_mb                                "Total large write MB"
  --
from  io                                     
join dba_hist_snapshot snap using (snap_id) 
where snap_id between &SnapBegin and &SnapEnd
order by snap_id
