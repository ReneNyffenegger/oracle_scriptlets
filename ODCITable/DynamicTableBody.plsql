create or replace type body DynamicTable as

   static function ODCITableDescribe(/*{*/
     record_table    out anytype,
     nof_columns_     in number,
     nof_rows_        in number
   ) return number

   is

     record_structure anytype;

     -- Straight from the docs: Any arguments of the table function
     -- that are not constants are passed to ODCITableDescribe as NULLs because
     -- their values are not known at compile time.

   begin

       -------------------------------------- Columns:

       anytype.begincreate(dbms_types.typecode_object, record_structure);

       for i in 0 .. nof_columns_ - 1 loop

             record_structure.addattr(
                         aname     =>'COL_' || to_char(i, 'fm009'),
                         typecode  => dbms_types.typecode_varchar2,
                         prec      => null,
                         scale     => null,
                         len       =>  12, 
                         csid      => null,
                         csfrm     => null
             );

       end loop;

       record_structure.endcreate;

       -------------------------------------- Table:

       anytype.begincreate(dbms_types.typecode_table, record_table);

       record_table.setinfo(null, null, null, null, null, record_structure, dbms_types.typecode_object, 0);
       record_table.endcreate();

       return odciconst.success;

   exception when others then

       return odciconst.error;

   end ODCITableDescribe;/*}*/

   static function ODCITablePrepare (/*{*/
     sctx            out DynamicTable,
     tab_func_info    in sys.ODCITabFuncInfo,
     nof_columns_     in number,
     nof_rows_        in number
   ) return number
   is


     record_desc      anytype;


     ------------------------------
     -- Dummies...
     dummy            pls_integer;
     prec             pls_integer;
     scale            pls_integer;
     len              pls_integer;
     csid             pls_integer;
     csfrm            pls_integer;
     aname            varchar2(30) ;
     ------------------------------

   begin



   --  This call seems necessary, although it is a bit in the dark as to why:
       dummy := tab_func_info.retType.GetAttrElemInfo(null, prec, scale, len, csid, csfrm, record_desc, aname);

   --  v_nof_columns := tab_func_info.attrs.count;

       sctx := DynamicTable(
                 row_types   => record_desc, 
                 nof_columns => nof_columns_,
                 nof_rows    => nof_rows_,
                 current_row => 0);

       return odciconst.success;

   exception when others then

       return odciconst.error;

   end ODCITablePrepare;/*}*/

   static function ODCITableStart(/*{*/
     sctx             in out DynamicTable,
     nof_columns_     in number,
     nof_rows_        in number
   ) return number
   is
   begin

       return odciconst.success;
   exception when others then

       return odciconst.error;

   end ODCITableStart;/*}*/

   member function ODCITableFetch(/*{*/
     self       in out DynamicTable,
     nrows      in     number,            -- TODO
     record_out    out anydataset
   ) return number
   is

   begin
       record_out := null;

       if self.current_row >= self.nof_rows then 
       -- Return if enough records fetched:
          return ODCIconst.success;
       end if;

       -- create another record to be fetched:

       anydataset.begincreate(dbms_types.typecode_object, self.row_types, record_out);
       record_out.addinstance;
       record_out.piecewise();

       -- Add columsn to the new record:
       for i in 0 .. self.nof_columns -1 loop
           record_out.setvarchar2(to_char(i, '999') || ' - ' || to_char(self.current_row, '9999'));
       end loop;

       record_out.endcreate;

       -- Remember the count of fetched rows for next call of ODCITableFetch
       self.current_row := self.current_row + 1;

       return odciconst.success;

   exception when others then
       return odciconst.error;

   end ODCITableFetch;/*}*/

   member function ODCITableClose(/*{*/
     self    in /*out*/ DynamicTable
   ) return         number
   is
   begin

       return odciconst.success;

   exception when others then

       return odciconst.error;

   end ODCITableClose;/*}*/

end;
/
