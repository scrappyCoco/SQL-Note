-- All sessions.
SELECT SessionId             = Session.session_id,
	   LastRequestStartTime  = Session.last_request_start_time,
	   LastRequestEndTime    = Session.last_request_end_time,
	   CputTime              = Session.cpu_time,
	   LogicalReads          = Session.logical_reads,
	   Reads                 = Session.reads,
	   Writes                = Session.writes,
	   UsedMemoryInMb        = CAST(Memory.used_memory_kb / 1024.0 AS DECIMAL(8, 2)),
	   RequestedMemoryInMb   = CAST(Memory.requested_memory_kb / 1024.0 AS DECIMAL(8, 2)),
	   TempDbAllocatedInGb   = CAST(
				   TempDbUsage.internal_objects_alloc_page_count * 8096.0 / 1024.0 / 1024.0 / 1024.0 AS DECIMAL(6, 2)),
	   TempDbDeallocatedInGb = CAST(TempDbUsage.internal_objects_dealloc_page_count * 8096.0 / 1024.0 / 1024.0 /
									1024.0 AS DECIMAL(6, 2)),
	   Status                = Session.status,
	   HostName              = Session.host_name,
	   ProgramName           = Session.program_name,
	   LoginName             = Session.login_name,
	   TsqlFrame             = SUBSTRING(
		   -- @formatter:off
    		SqlText.text,
    		Request.statement_start_offset / 2 + 1,
			((
			    IIF (Request.statement_end_offset = -1,
			        DATALENGTH(SqlText.text),
			        Request.statement_end_offset
			    	) - Request.statement_start_offset) / 2
			) + 1),
			-- @formatter:on
	   SqlPlan               = SqlPlan.query_plan
FROM sys.dm_exec_sessions AS Session
LEFT JOIN sys.dm_exec_requests AS Request ON Request.session_id = Session.session_id
LEFT JOIN sys.dm_exec_query_memory_grants AS Memory ON Memory.session_id = Session.session_id
LEFT JOIN sys.dm_db_task_space_usage AS TempDbUsage ON TempDbUsage.session_id = Session.session_id
OUTER APPLY sys.dm_exec_sql_text(Request.sql_handle) AS SqlText
OUTER APPLY sys.dm_exec_query_plan(Request.plan_handle) AS SqlPlan
WHERE
	Session.is_user_process = 1
ORDER BY
	Session.cpu_time DESC