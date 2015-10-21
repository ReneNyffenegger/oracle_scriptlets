$ del c:\temp\tq84.zip
create directory zip_dir as 'c:\temp';

declare

  zip        blob;

  file1      blob := utl_raw.cast_to_raw('Hello world!'                                    );
  file2      blob := utl_raw.cast_to_raw('foo bar baz'                                     );
  file3      blob := utl_raw.cast_to_raw('one two three'                                   );
  file4      blob := utl_raw.cast_to_raw('file four' || chr(13) || chr(10) || 'second line');
  large_file blob;

  i          number := 1;

begin

  dbms_lob.createTemporary(zip       , true);
  dbms_lob.createTemporary(large_file, true);

  while i < 1721057 loop
    dbms_lob.append(large_file, utl_raw.cast_to_raw(to_char(to_date(i, 'j'),'jsp') || chr(13) || chr(10)));
    i := i + 1;
  end loop;
  
  zipper.addFile(zip, 'hi-world.txt'                  , file1 );
  zipper.addFile(zip, 'file_2.txt'                    , file2 );
  zipper.addFile(zip, 'subdir1/file_3.txt'            , file3 );
  zipper.addFile(zip, 'subdir1/subdir2/four_lines.txt', file4 );
  zipper.addFile(zip, 'subdir1/large/file.txt'    , large_file ); zipper.finish (zip);

  -- ../blob_wrapper/
  blob_wrapper.to_file('ZIP_DIR', 'tq84.zip', zip);

  dbms_lob.freeTemporary(large_file);
  dbms_lob.freeTemporary(zip);

end;
/

drop directory zip_dir;
$ c:\temp\tq84.zip
