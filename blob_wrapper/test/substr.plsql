create directory blob_substr_dir as 'c:\temp';

$del c:\temp\substr_de123_expected.txt
$del c:\temp\substr_de123_gotten.txt

$del c:\temp\substr_234_expected.txt
$del c:\temp\substr_234_gotten.txt

$del c:\temp\substr_bcde12345AB_expected.txt
$del c:\temp\substr_bcde12345AB_gotten.txt

declare
  b       blob;

  procedure t(b_ in blob, length_ in number, start_ in number, filename in varchar2) is -- {

    b_expected blob;
    b_gotten   blob;

  begin

    b_expected := dbms_lob    .substr(b_, length_, start_);
    b_gotten   := blob_wrapper.substr(b_, length_, start_, chunk_size => 5);

    blob_wrapper.to_file('BLOB_SUBSTR_DIR', 'substr_' || filename || '_expected.txt', b_expected);
    blob_wrapper.to_file('BLOB_SUBSTR_DIR', 'substr_' || filename || '_gotten.txt'  , b_gotten  );

    dbms_lob.freeTemporary(b_gotten);

  end t; -- }

begin

  b := utl_raw.cast_to_raw('abcde12345ABCDE');

  t(b,  5, 3, 'de123');
  t(b,  3, 7, '234');
  t(b, 11, 2, 'bcde12345AB');

end;
/

drop directory blob_substr_dir;

$ c:\temp\substr_de123_expected.txt
$ c:\temp\substr_de123_gotten.txt

$ c:\temp\substr_234_expected.txt
$ c:\temp\substr_234_gotten.txt

$ c:\temp\substr_bcde12345AB_expected.txt
$ c:\temp\substr_bcde12345AB_gotten.txt
