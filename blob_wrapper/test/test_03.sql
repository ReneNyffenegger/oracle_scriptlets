create table blob_wrapper_test_03 (
  id  number primary key,
  blb blob
);


declare
  blob_ blob;
begin
  insert into blob_wrapper_test_03 values (1, empty_blob() ) return blb into blob_;

  blob_wrapper.from_file('LOB_TEST_DIR', 'circle_new.txt', blob_);
end;
/

commit;
