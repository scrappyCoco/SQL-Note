CREATE EVENT SESSION Errors ON SERVER
ADD EVENT sqlserver.error_reported (
    ACTION (
        package0.last_error,
        sqlserver.client_app_name,
        sqlserver.client_hostname,
        sqlserver.database_name,
        sqlserver.plan_handle,
        sqlserver.query_hash,
        sqlserver.query_plan_hash,
        sqlserver.sql_text,
        sqlserver.tsql_frame,
        sqlserver.tsql_stack,
        sqlserver.username,
        collect_system_time
    ) WHERE (
		error_number <> 0
		AND error_number <> 18264 -- Database backed up.
		AND error_number <> 18270 -- Database differential changes were backed up.
		AND error_number <> 3262 -- The backup set on file 1 is valid.
		AND error_number <> 15477 -- Caution: Changing any part of an object name could break scripts and stored procedures.
		AND error_number <> 9008 -- Cannot shrink log file 2 because the logical log file located at the end of the file is in use.
		AND error_number <> 6299 -- AppDomain 656 created.
		AND error_number <> 6290 -- AppDomain 633 unloaded.
		AND error_number <> 10311 -- AppDomain 671 is marked for unload due to memory pressure.
		AND error_number <> 2528 -- DBCC execution completed...
		AND error_number <> 3014 -- BACKUP LOG successfully processed ...
		AND error_number <> 4035 -- Processed 0 pages for database ...
		AND error_number <> 5701 -- Changed database context to ...
		AND error_number <> 5703 -- Changed language setting to ...
		AND error_number <> 18265 -- Log was backed up.
		AND error_number <> 14205 -- (unknown)
		AND error_number <> 14213 -- Core Job Details:
		AND error_number <> 14214 -- Job Steps:
		AND error_number <> 14215 -- Job Schedules:
		AND error_number <> 14216 -- Job Target Servers:
		AND error_number <> 14549 -- (Description not requested.)
		AND error_number <> 14558 -- (encrypted command)
		AND error_number <> 14559 -- (append output file)
		AND error_number <> 14560 -- (include results in history)
		AND error_number <> 14561 -- (normal)
		AND error_number <> 14562 -- (quit with success)
		AND error_number <> 14563 -- (quit with failure)
		AND error_number <> 14564 -- (goto next step)
		AND error_number <> 14565 -- (goto step)
		AND error_number <> 14566 -- (idle)
		AND error_number <> 14567 -- (below normal)
		AND error_number <> 14568 -- (above normal)
		AND error_number <> 14569 -- (time critical)
		AND error_number <> 14570 -- (Job outcome)
		AND error_number <> 14635 -- Mail queued.
		AND error_number <> 14638 -- Activation successful.
		AND error_number <> 8153 -- NULL value aggregate.
		AND error_number <> 9101 -- auto statistics internal
		AND error_number <> 9104 -- auto statistics internal
		AND error_number <> 2701 -- Database name 'tempdb' ignored, referencing object in tempdb. Example: tempdb..#LinkedTable
		AND error_number <> 8625 -- message	Warning: The join order has been enforced because a local join hint is used.
		AND error_number <> 9943 -- Informational: Full-text Auto population completed for table or indexed view '...' (table or indexed view ID '417344689', database ID '78'). Number of documents processed: 2. Number of documents failed: 0. Number of documents that will be retried: 0.
		AND error_number <> 22803 -- Change Data Capture has scanned the log from LSN{006925C4:0001A8A8:0001} to LSN{006925C4:0001A960:0003}, 1 transactions with 2 commands have been extracted. To report on the progress of the operation, query the sys.dm_cdc_log_scan_sessions dynamic management view.
		AND error_number <> 9911 -- Informational: Full-text Auto population initialized for table or indexed view '...' (table or indexed view ID '417344689', database ID '78'). Population sub-tasks: 1.
		AND error_number <> 282 -- The 'GetFileIdToUpdate' procedure attempted to return a status of NULL, which is not allowed. A status of 0 will be returned instead.
		AND error_number <> 9927 -- Informational: The full-text search condition contained noise word(s).
		AND client_app_name NOT LIKE '%Microsoft SQL Server Management Studio%'
		AND client_app_name NOT LIKE '%dbForge Studio%'
		AND client_app_name NOT LIKE '%DataGrip%'
		AND error_number <= 50000 -- Exclude User Errors
		AND error_number <> 3211 -- Backup progress
	)
) ADD TARGET package0.ring_buffer(SET max_memory = (102400)) WITH (STARTUP_STATE = ON)

GO


