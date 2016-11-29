create or replace package &tq84_prefix.string_op as
-- vi: ft=sql
--
-- https://raw.githubusercontent.com/ReneNyffenegger/oracle_scriptlets/master/string_op/spec.plsql
--

  function strtok (str in varchar2, delimiter    in varchar2) return &tq84_prefix.varchar2_t;
  function grep_re(str in varchar2, regexp       in varchar2) return &tq84_prefix.varchar2_t;

-- sprintf related -- {
--         see http://www.adp-gmbh.ch/blog/2007/04/14.php
--         see also utl_lms
  function sprintf(format varchar2, parms in &tq84_prefix.varchar2_t) return varchar2; 
  function sprintf(format varchar2, parm_01 varchar2                                                                                          ) return varchar2;
  function sprintf(format varchar2, parm_01 varchar2, parm_02 varchar2                                                                        ) return varchar2;
  function sprintf(format varchar2, parm_01 varchar2, parm_02 varchar2, parm_03 varchar2                                                      ) return varchar2;
  function sprintf(format varchar2, parm_01 varchar2, parm_02 varchar2, parm_03 varchar2, parm_04 varchar2                                    ) return varchar2;
  function sprintf(format varchar2, parm_01 varchar2, parm_02 varchar2, parm_03 varchar2, parm_04 varchar2, parm_05 varchar2                  ) return varchar2;
  function sprintf(format varchar2, parm_01 varchar2, parm_02 varchar2, parm_03 varchar2, parm_04 varchar2, parm_05 varchar2, parm_06 varchar2) return varchar2;
 -- }

-- printf related -- {
  procedure printf(format varchar2, parms &tq84_prefix.varchar2_t); 
  procedure printf(format varchar2, parm_01 varchar2                                                                                          );
  procedure printf(format varchar2, parm_01 varchar2, parm_02 varchar2                                                                        );
  procedure printf(format varchar2, parm_01 varchar2, parm_02 varchar2, parm_03 varchar2                                                      );
  procedure printf(format varchar2, parm_01 varchar2, parm_02 varchar2, parm_03 varchar2, parm_04 varchar2                                    );
  procedure printf(format varchar2, parm_01 varchar2, parm_02 varchar2, parm_03 varchar2, parm_04 varchar2, parm_05 varchar2                  );
  procedure printf(format varchar2, parm_01 varchar2, parm_02 varchar2, parm_03 varchar2, parm_04 varchar2, parm_05 varchar2, parm_06 varchar2);
 -- }

  function is_number(str varchar2) return boolean;

end &tq84_prefix.string_op;
/
show errors
