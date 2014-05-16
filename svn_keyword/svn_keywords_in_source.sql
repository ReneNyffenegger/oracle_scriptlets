create or replace view svn_keywords_in_source as
select /*+ materialize */
      substr(o.owner      , 1, 10)    schema,
      substr(o.object_name, 1, 30)    name,
      o.object_type                   type,
      --
      to_number(replace(
      max(
        case when regexp_like(c.text,   '\$Revision: (\d+)')                                         then
               regexp_replace(c.text, '.*\$Revision: (\d+) .*'                          , '\1')
             when regexp_like(c.text,     '\$Id: \S* (\d+)')                                         then
               regexp_replace(c.text,   '.*\$Id: \S* (\d+).*'                           , '\1')
        end
      )
      ,chr(10),''))                                                                                                              svn_revision,
      --
      max(
        case when regexp_like(c.text,   '\$Date: (\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d)' )              then
      to_date( regexp_replace(c.text, '.*\$Date: (\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d) .*'     , '\1'), 'yyyy-mm-dd hh24:mi:ss')

             when regexp_like(c.text,   '\$Date: (\d\d\.\d\d\.\d\d \d\d:\d\d)'        )              then
      to_date( regexp_replace(c.text, '.*\$Date: (\d\d\.\d\d\.\d\d \d\d:\d\d) .*'            , '\1'), 'dd.mm.yy hh24:mi'    )

             when regexp_like(c.text,    '\$Id: \S* \d+ (\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d).*')      then
      to_date( regexp_replace(c.text,  '.*\$Id: \S* \d+ (\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d).*','\1'), 'yyyy-mm-dd hh24:mi:ss')
        end
      )                                                                                                                          svn_date
    from
      all_objects  o left join
      all_source   c on o.owner                   = c.owner and
                        o.object_type             = c.type  and
                        o.object_name             = c.name
    where
      o.object_type in (/*'TRIGGER', */'TYPE', 'TYPE BODY', 'PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY') and
      o.owner   not in ('SYS', 'SYSTEM', 'DBSNMP', 'OUTLN')
    group by
      substr(o.owner      , 1, 10),
      substr(o.object_name, 1, 30),
      o.object_type;
      

create public synonym svn_keywords_in_source for svn_keywords_in_source;
