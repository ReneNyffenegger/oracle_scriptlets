create or replace package body mailer as

  c_seperator constant varchar2(19) := 'tq84$tq84$tq84$tq84';

  procedure auth_login( -- {
               smtp      in out utl_smtp.connection,
               username  in     varchar2,
               password  in     varchar2) is
  begin

    utl_smtp.command(smtp, 'AUTH LOGIN');
    utl_smtp.command(smtp, utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(username))));
    utl_smtp.command(smtp, utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(password)))); 

  end auth_login; -- }

  procedure header ( -- {
               smtp            in out utl_smtp.connection,
               mail_addr_from  in     varchar2,
               mail_addr_to    in     varchar2,
               subject         in     varchar2)
  is
  begin

    utl_smtp.write_data(smtp, 'Date: ' || to_char(sysdate, 'dd-mon-yyyy hh24:mi:ss') || utl_tcp.crlf);
    utl_smtp.write_data(smtp, 'To: ' || mail_addr_to || utl_tcp.crlf);
    utl_smtp.write_data(smtp, 'From: ' || mail_addr_from || utl_tcp.crlf);
    utl_smtp.write_data(smtp, 'Subject: ' || subject || utl_tcp.crlf);
    utl_smtp.write_data(smtp, 'reply-to: ' || mail_addr_from || UTL_TCP.crlf);
    utl_smtp.write_data(smtp, 'MIME-Version: 1.0' || utl_tcp.crlf);
    utl_smtp.write_data(smtp, 'Content-Type: multipart/mixed; boundary="' || c_seperator || '"' || utl_tcp.crlf || utl_tcp.crlf);

  end header; -- }

  procedure html(smtp in out  utl_smtp.connection, -- {
                 html in      varchar2) is
  begin

    utl_smtp.write_data(smtp, '--' || c_seperator || utl_tcp.crlf);
    utl_smtp.write_data(smtp, 'Content-Type: text/html' || utl_tcp.crlf || utl_tcp.crlf);

    utl_smtp.write_data(smtp, html);

    utl_smtp.write_data(smtp, utl_tcp.crlf || utl_tcp.crlf);

    return;

  end html; -- }

  procedure attachment( -- {
    smtp     in out utl_smtp.connection,
    filename in     varchar2, 
    content  in blob) is

    c_step   constant pls_integer  := 12000; -- Multiple of 3, not higher than 24573

  begin

    utl_smtp.write_data(smtp, '--' || c_seperator || utl_tcp.crlf);
    utl_smtp.write_data(smtp, 'Content-Type: application/octet-stream; name="' || filename || '"' || utl_tcp.crlf);
    utl_smtp.write_data(smtp, 'Content-Transfer-Encoding: base64' || UTL_TCP.crlf);
    utl_smtp.write_data(smtp, 'Content-Disposition: attachment; filename="' || filename || '"' || utl_tcp.crlf || utl_tcp.crlf);
  
    for i in 0 .. trunc((dbms_lob.getlength(content) - 1 )/c_step) loop
      utl_smtp.write_data(smtp, utl_raw.cast_to_varchar2(utl_encode.base64_encode(DBMS_LOB.substr(content, c_step, i * c_step + 1))));
    end loop;
  
    utl_smtp.write_data(smtp, utl_tcp.crlf || utl_tcp.crlf);


  end attachment; -- }

  procedure end_mail( -- {
    smtp     in out utl_smtp.connection
  ) is
  begin

    utl_smtp.write_data(smtp, '--' || c_seperator || '--' || utl_tcp.crlf);
    utl_smtp.close_data(smtp);
  
    utl_smtp.quit(smtp);

  end end_mail; -- }

end mailer;
/
