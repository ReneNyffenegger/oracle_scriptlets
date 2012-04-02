create or replace type DynamicTable as object (

  row_types     anytype,

  nof_columns   number,
  nof_rows      number,

  current_row   number,

  -------------------------------------------

  static function go(
    nof_columns_     in number,
    nof_rows_        in number
  )
  return anydataset pipelined using DynamicTable,
 
  static function ODCITableDescribe(
    record_table    out anytype,
    nof_columns_    in  number,
    nof_rows_       in  number
  ) return number,
 
  static function ODCITablePrepare (
    sctx            out DynamicTable,
    tab_func_info    in sys.ODCITabFuncInfo,
    nof_columns_     in  number,
    nof_rows_        in  number
  ) return number,
 
  static function ODCITableStart(
    sctx             in out DynamicTable,
    nof_columns_     in number,
    nof_rows_        in number
  ) return number,
 
  member function ODCITableFetch(
    self            in out DynamicTable,
    nrows           in     number,
    record_out         out anydataset
  ) return number,
 
  member function ODCITableClose(
    self  in /*out*/ DynamicTable
  ) return number

);
/
