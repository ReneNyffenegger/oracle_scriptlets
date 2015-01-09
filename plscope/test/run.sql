connect / as sysdba

declare

  procedure drop_user_if_exists is
      cnt number;
  begin

      select count(*) into cnt from dba_users where username = 'TQ84_PLSCOPE_TEST';

      if cnt > 0 then
         execute immediate 'drop user tq84_plscope_test cascade';
      end if;

  end drop_user_if_exists;

begin

  drop_user_if_exists;

end;
/


create user tq84_plscope_test 
   identified by tq84_plscope_test
   default   tablespace users
   temporary tablespace temp_ts
   quota unlimited on users;

grant
  create procedure,
  create session,
  create synonym,
  create table,
  create view
  to tq84_plscope_test;

grant all on sys.all_identifiers        to tq84_plscope_test;

-- Grants needed for tq84_all_identifiers (see ../tq84_plscope_test.sql)
grant all on sys."_CURRENT_EDITION_OBJ" to tq84_plscope_test;
grant all on sys.plscope_identifier$    to tq84_plscope_test;
grant all on sys.plscope_action$        to tq84_plscope_test;
grant all on sys.user$                  to tq84_plscope_test;



connect tq84_plscope_test/tq84_plscope_test;


@pck_a.pks

@pck_a.pkb

-- Install PL-Scope:

@@../tables.sql

@@../spec.plsql
@@../body.plsql

-- Run PL-Scope

exec plscope.gather_identifiers
@@../tq84_all_identifiers
-- Prevent ORA-04068: existing state of packages has been discarded
connect tq84_plscope_test/tq84_plscope_test
exec plscope.fill_call(user, true);

-- Vim Tests
@@../vim/unused_constants.sql
