create or replace package mailer is
  
  procedure auth_login(
               smtp      in out utl_smtp.connection,
               username  in     varchar2,
               password  in     varchar2);

  procedure header (
               smtp            in out utl_smtp.connection,
               mail_addr_from  in     varchar2,
               mail_addr_to    in     varchar2,
               subject         in     varchar2);

  procedure html(smtp in out  utl_smtp.connection,
                 html in      varchar2);

  procedure attachment(
    smtp     in out utl_smtp.connection,
    filename in     varchar2, 
    content  in blob);

  procedure end_mail(
    smtp     in out utl_smtp.connection);

end mailer;
/
