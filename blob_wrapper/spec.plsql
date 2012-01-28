create or replace package blob_wrapper as

  procedure   to_file(dir in varchar2, file in varchar2, lob in blob);

  function  from_file(dir in varchar2, file in varchar2) return blob;
  procedure from_file(dir in varchar2, file in varchar2, b in out blob);

end blob_wrapper;
/
