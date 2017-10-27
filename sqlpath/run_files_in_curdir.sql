--
--   Windows only.
--
--   Executes («run») the files in the current directory
--
define file_pattern=&1
$echo -- create new file or delete existing > %temp%\run_files_in_curdir_.sql
$@for /f "usebackq" %a in (`dir /b &file_pattern`) do @echo @ %a >> %temp%\run_files_in_curdir_.sql
prompt %temp%\run_files_in_curdir_.sql created, running it...
@%TEMP%/run_files_in_curdir_.sql
