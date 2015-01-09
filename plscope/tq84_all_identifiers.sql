--
--     Workaround for a bug.
--
--     See http://dba.stackexchange.com/questions/31683/is-there-a-bug-with-pl-scope-in-combination-with-associative-arrays
--
--     Query below extracted from all_identifiers, but
--     with outer join to sys.plscope_identifier$.
--

declare procedure drop_if_exists is -- {
       type_ varchar2(30);
   begin

       select object_type into type_ from user_objects where object_name = 'TQ84_ALL_IDENTIFIERS';

       execute immediate
           'drop ' || type_  || ' tq84_all_identifiers' ||
            case when type_ = 'TABLE' then ' purge' end;

   exception when no_data_found then

       null;

   end drop_if_exists;

begin

   drop_if_exists;

end;
/



create table tq84_all_identifiers (
  owner,
  name,
  signature,
  type,
  object_name,
  object_type,
  usage,
  usage_id,
  line,
  col,
  usage_context_id,
  --
  constraint tq84_all_identifiers_pk primary key (object_name, object_type, owner, usage_id)
)
organization index
as
--insert into tq84_all_identifiers
select u.name owner, i.symrep name, i.signature,
decode(i.type#, 1, 'VARIABLE', 2, 'ITERATOR', 3, 'DATE DATATYPE',
                4, 'PACKAGE',  5, 'PROCEDURE', 6, 'FUNCTION', 7, 'FORMAL IN',
                8, 'SUBTYPE',  9, 'CURSOR', 10, 'INDEX TABLE', 11, 'OBJECT',
               12, 'RECORD', 13, 'EXCEPTION', 14, 'BOOLEAN DATATYPE', 15, 'CONSTANT',
               16, 'LIBRARY', 17, 'ASSEMBLY', 18, 'DBLINK', 19, 'LABEL',
               20, 'TABLE', 21, 'NESTED TABLE', 22, 'VARRAY', 23, 'REFCURSOR',
               24, 'BLOB DATATYPE', 25, 'CLOB DATATYPE', 26, 'BFILE DATATYPE',
               27, 'FORMAL IN OUT', 28, 'FORMAL OUT', 29, 'OPAQUE',
               30, 'NUMBER DATATYPE', 31, 'CHARACTER DATATYPE',
               32, 'ASSOCIATIVE ARRAY', 33, 'TIME DATATYPE', 34, 'TIMESTAMP DATATYPE',
               35, 'INTERVAL DATATYPE', 36, 'UROWID', 37, 'SYNONYM', 38, 'TRIGGER',
                   'UNDEFINED') type,
o.name object_name,
decode(o.type#, 5, 'SYNONYM', 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                11, 'PACKAGE BODY', 12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
                22, 'LIBRARY', 33, 'SPEC OPERATOR', 87, 'ASSEMBLY',
                'UNDEFINED') object_type,
decode(a.action, 1, 'DECLARATION', 2, 'DEFINITION', 3, 'CALL', 4, 'REFERENCE',
                 5, 'ASSIGNMENT', 'UNDEFINED') usage,
  a.action# usage_id, a.line, a.col, a.context# usage_context_id
from
  sys."_CURRENT_EDITION_OBJ" o,
  sys.plscope_identifier$ i,
  sys.plscope_action$ a,
  sys.user$ u
where i.signature (+) = a.signature
  and o.obj# = a.obj#
  and o.owner# = u.user#
  and ( o.type# in ( 5, 7, 8, 9, 11, 12, 14, 22, 33, 87) OR
       ( o.type# = 13 AND o.subname is null));


commit;

create synonym all_identifiers for tq84_all_identifiers;
