create or replace package desc_table 
  authid current_user
as

  table_does_not_exist exception;
  pragma exception_init(table_does_not_exist, -20010);

  type check_t        is table of long;

  type col_t          is record (name varchar2(30), nullable boolean, datatype varchar2(106), checks check_t);
  type cols_t         is table   of col_t;

  type col_comment_t  is record (pos number, comment user_tab_comments.comments%type);
  type col_comments_t is table   of col_comment_t;

  type table_t        is record (own varchar2(30), nam varchar2(30));
  type tables_t       is table   of table_t;

  type char_to_number is table   of number(2) index by varchar2(30);

  type description    is record (tab           table_t,
                                 tab_type      user_tab_comments.table_type%type, -- 'TABLE', 'VIEW' ..?
                                 tab_comment   user_tab_comments.comments%type,
                                 cols          cols_t,
                                 col_comments  col_comments_t,
                                 pks           char_to_number, -- Position of primary keys
                                 parents       tables_t,
                                 children      tables_t);

  -- table_name: 61 chars maximum: 30 chars schema (optional), 1 char dot (optional), 30 chars username 
  function describe(table_name in varchar2) return description;

  function describe(tab        in table_t ) return description;

end desc_table;
/
