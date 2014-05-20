--
--   Call 'plscope.gather_identifiers' after
--   installing these tables/views in order
--   to fill 'all_identifiers'.
--
--   Then call 'plscope.fill_call'.
--

drop view  plscope_ref_v;
drop view  plscope_call_v;
drop table plscope_call      purge;
drop table plscope_callable  purge;


create table plscope_callable (
  signature varchar2(32) not null primary key,
  object_name varchar2(30) not null,
  name varchar2(30) not null,
  complete_name varchar2(61) as (object_name || '.' || name) virtual,
  exclude       number(1) not null check (exclude in (0,1))
);

comment on column plscope_callable.exclude is 'Flag if calls from/to this callable should be excluded when plscope.downwards / plscope.upwards is executed';

create table plscope_call (
  caller not null references plscope_callable,
  callee not null references plscope_callable
);

create view plscope_call_v as
select
             caller.object_name   object_name_caller,
             caller.name          name_caller,
             caller.complete_name complete_name_caller,
             caller.exclude       exclude_caller,
             --
             callee.object_name   object_name_callee,
             callee.name          name_callee,
             callee.complete_name complete_name_callee,
             callee.exclude       exclude_callee,
             --
             caller.signature signature_caller,
             callee.signature signature_callee
from
                     plscope_call call
             join plscope_callable caller on call.caller = caller.signature
             join plscope_callable callee on call.callee = callee.signature;



create view plscope_ref_v as with direct as (
     select '->' ion from dual union all
     select '<-' ion from dual
)
select
     case when direct.ion = '->' then object_name_caller else object_name_callee end object_name_referenced,
     case when direct.ion = '->' then name_caller else name_callee end name_referenced,
     case when direct.ion = '->' then complete_name_caller else complete_name_callee end complete_name_referenced,
     --
     direct.ion direction,
     --
     case when direct.ion = '<-' then object_name_caller else object_name_callee end object_name_references,
     case when direct.ion = '<-' then name_caller else name_callee end name_references,
     case when direct.ion = '<-' then complete_name_caller else complete_name_callee end complete_name_references
from
     plscope_call_v cross join direct;
