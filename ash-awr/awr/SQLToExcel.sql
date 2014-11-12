set    verify off
define SnapBegin=&1
define SnapEnd=&2
define SQLFile=&3
define LineCharacteristics=&4

set termout off

-- https://github.com/ReneNyffenegger/oracle_scriptlets/blob/master/sqlpath/to_csv.sql
@to_csv &SQLFile u:/temp/awr_data.csv

set termout on

-- https://github.com/ReneNyffenegger/development_misc/blob/master/vba/runVBAFilesInOffice.vbs
$u:\dev1\githup_development_misc\vba\runVBAFilesInOffice.vbs -excel AWRDataToExcel -c Run u:\temp\awr_data.csv "&LineCharacteristics"
