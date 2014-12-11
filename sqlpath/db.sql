select
-- dbid,
   name,
   to_char(created, 'dd.mm.yyyy') created,
-- resetlogs_change#,                         -- System change number (SCN) at open resetlogs
-- resetlogs_time,                            
   log_mode,                                  -- NOARCHIVELOG, ARCHIVELOG, MANUAL
   checkpoint_change#,                        -- Last SCN checkpointed
   archive_change#,                           -- Database force archiving SCN. Any redo log with a start SCN below this will be forced to archive out.
   controlfile_type,                          -- STANDBY: database is in standby mode
                                              -- CLONE 
                                              -- BACKUP | CREATED : database is being recovered using a backup or created control file
                                              -- CURRENT database available for general use
   to_char(controlfile_created, 'dd.mm.yyyy')   "Ctrl Cr.t", -- Creation date of the control file
   controlfile_sequence#                        "Ctrl Seq",
   controlfile_change#                          "Ctrl SCN",
   controlfile_time                             "Ctrl Tim",
   open_resetlogs,
   open_mode,
   database_role
-- switchover_status
-- version_time
from
   v$database;
