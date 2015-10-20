create directory zip_dir as 'c:\temp';

declare

  zip blob;

  file1 blob := utl_raw.cast_to_raw('Hello world!'                                    );
  file2 blob := utl_raw.cast_to_raw('foo bar baz'                                     );
  file3 blob := utl_raw.cast_to_raw('one two three'                                   );
  file4 blob := utl_raw.cast_to_raw('file four' || chr(13) || chr(10) || 'second line');

begin
  
  zipper.addFile(zip, 'hi-world.txt'              , file1 );
  zipper.addFile(zip, 'file_2.txt'                , file2 );
  zipper.addFile(zip, 'subdir1/file_3.txt'        , file3 );
  zipper.addFile(zip, 'subdir1/subdir2/file_4.txt', file4 );
  zipper.finish (zip);

  -- ../blob_wrapper/
  blob_wrapper.to_file('ZIP_DIR', 'tq84.zip', zip);

end;
/

drop directory zip_dir;
