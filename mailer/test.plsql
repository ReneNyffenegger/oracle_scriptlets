declare

  mailserver  varchar2(100) := '&1';
  port        number        :=  &2 ;
  from_addr   varchar2(100) := '&3';
  to_addr     varchar2(100) := '&4';
  auth_pw     varchar2(100) := '&5';
  from_name   varchar2(100) := '&6';

  smtp_conn   utl_smtp.connection;

  zip         blob;

  function create_zip return blob is -- {

    zip blob;

    file1 blob := utl_raw.cast_to_raw('Hello world!'                                    );
    file2 blob := utl_raw.cast_to_raw('foo bar baz'                                     );
    file3 blob := utl_raw.cast_to_raw('one two three'                                   );
    file4 blob := utl_raw.cast_to_raw('file four' || chr(13) || chr(10) || 'second line');

    large_file blob;

    i number := 1;

  begin

    dbms_lob.createTemporary(zip       , true);
    dbms_lob.createTemporary(large_file, true);

    while i < 10000 loop

      dbms_lob.append(large_file, utl_raw.cast_to_raw(to_char(to_date(i, 'j'),'jsp') || chr(13) || chr(10)));
      i := i+1;
    end loop;

    -- ../zipper
    zipper.addFile(zip, 'hi-world.txt'              , file1     );
    zipper.addFile(zip, 'file_2.txt'                , file2     );
    zipper.addFile(zip, 'subdir1/file_3.txt'        , file3     );
    zipper.addFile(zip, 'subdir1/subdir2/file_4.txt', file4     );
    zipper.addFile(zip, 'subdir1/large/file.txt'    , large_file);

    zipper.finish (zip);
    dbms_lob.freeTemporary(large_file);

    return zip;

  end create_zip; -- }

begin

  smtp_conn := utl_smtp.open_connection(mailserver, port);

  utl_smtp.ehlo(smtp_conn, mailserver );

  mailer.auth_login(smtp_conn, from_addr, auth_pw);
  
  utl_smtp.mail(smtp_conn, from_addr  );
  utl_smtp.rcpt(smtp_conn, to_addr    );

  utl_smtp.open_data(smtp_conn);

  mailer.header( -- {
    smtp_conn,
    mail_addr_from  => from_addr,
    mail_addr_to    => to_addr,
    subject         =>'/// Test mail with attachment ///'
  ); -- }
  
  mailer.html(smtp_conn, q'{<html><head><title>Test with Attachment</title>
   <style type='text/css'>
     * { font-family: Garamond; }
     body {background-color: #f7f0ff;}
   </style>
 </head>
 <body>

 <h1>Hi</h1>

 Attached, you find the zip file.


</body>
</html>
  }');

  zip := create_zip();
  mailer.attachment(smtp_conn, 'The.zip', zip);

  mailer.end_mail(smtp_conn);

  dbms_lob.freeTemporary(zip);


end;
/
