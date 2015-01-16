with relevant as (
    select
    0 lvl, id, parent_id, operation, options, object_name, object_alias, time, qblock_name, cpu_cost, io_cost, sql_id, timestamp,
    dense_rank() over (order by timestamp desc) r
  from
    dba_hist_sql_plan
  where
    sql_id = '&sql_id'
),
step (lvl, id, operation, options, object_name, object_alias, time, qblock_name, cpu_cost, io_cost, sql_id, r) as (
  select
    0 lvl, id, operation, options, object_name, object_alias, time, qblock_name, cpu_cost, io_cost, sql_id, r
  from
    relevant
  where
    r = 1    and       -- newest timestampe (r=1)
    parent_id is null 
union all
  select
    p.lvl + 1,
    c.id, c.operation, c.options, c.object_name, c.object_alias, c.time, c.qblock_name, c.cpu_cost, c.io_cost, c.sql_id, c.r
  from
    step              p     join
    relevant          c on p.id        = c.parent_id and 
                           p.sql_id    = c.sql_id    and
                           p.r         = c.r
)
select 
  lpad('  ', 2*lvl) ||operation || ' (' || options || ')' op,
  object_name,
  object_alias,
  qblock_name,
  time,
  cpu_cost,
  io_cost
from
  step
order by
  id;
