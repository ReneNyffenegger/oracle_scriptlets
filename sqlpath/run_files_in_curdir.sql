--
--   Windows only.
--
--   Executes («run») the files in the current directory
--
$echo -- create new file or delete existing > %temp%\run_files_in_curdir_.sql
$@for /f "usebackq" %a in (`dir /b`) do @echo @ %a >> %temp%\run_files_in_curdir_.sql
@%TEMP%/run_files_in_curdir_
