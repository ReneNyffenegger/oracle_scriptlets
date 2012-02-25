@rem
@rem      Pass the name of a file to this script
@rem
@rem      This script will then create the file 'c:\temp\file_to_table.out'.
@rem
@rem      For each line found in the file whose name
@rem      is passed to this script, the script will
@rem      append a line into c:\temp\file_to_table.out
@rem      with a 
@rem        insert into tmp_file_to_table values (<LINENUMBER>, <LINETEXT>);
@rem
@rem      It is intended that this script is called by 'file_to_table.sql'.
@rem
@rem      The following
@rem          setlocal ENABLEDELAYEDEXPANSION 
@rem      ist very necessary as it allows for the local variable 'linenumber'
@rem      to be incremented. Such variables to be locally expanded (or evaluated)
@rem      are not identified by a %-sign, but rather with the !-sign.
@rem


@set /a linenumber=1
@    setlocal ENABLEDELAYEDEXPANSION
@FOR /F " usebackq delims==" %%i IN (`type %1`) DO   @( echo insert into tmp_file_to_table values ^(!linenumber!, q'#%%i#'^)^;
@set /a linenumber+=1
) >> c:\temp\file_to_table.out  
@endlocal
