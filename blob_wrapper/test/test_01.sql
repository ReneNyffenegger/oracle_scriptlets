declare
  out_width  number       := 400;
  radius     number       := 300;
  dir        varchar2(30) :='LOB_TEST_DIR';
  file       varchar2(30) :='circle.txt';

  some_lob blob;
  one_byte raw(1);

begin

  some_lob := empty_blob();
  dbms_lob.createTemporary(some_lob, true);
  dbms_lob.open(some_lob, dbms_lob.lob_readwrite);

  for x in -out_width/2 .. out_width/2 loop /*{*/
      for y in -out_width/2 .. out_width/2 loop/*{*/

          if sqrt(x*x + y*y) > radius/2 then
            one_byte := utl_raw.cast_to_raw(' ');
          else
            one_byte := utl_raw.cast_to_raw('X');
          end if;
          dbms_lob.append(some_lob, one_byte);

      end loop; /*}*/
      one_byte := utl_raw.cast_to_raw(chr(10));
      dbms_lob.append(some_lob, one_byte);
  end loop;/*}*/

  blob_wrapper.to_file(dir, file, some_lob);

  dbms_lob.close(some_lob);
end write_circle;
/

-- Should be 161'202 (=401*402) bytes:
$dir c:\temp\circle.txt
