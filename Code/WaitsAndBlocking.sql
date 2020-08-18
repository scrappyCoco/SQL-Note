-- Resource waits.
SELECT SessionId         = Tasks.session_id,
	   StartTime         = Requests.start_time,
	   WaitDurationMs    = Tasks.wait_duration_ms,
	   WaitType          = Tasks.wait_type,
	   BlockindSessionId = Tasks.blocking_session_id,
	   HostName          = Sessions.host_name,
	   ProgramName       = Sessions.program_name,
	   LoginName         = Sessions.login_name,
	   TsqlFrame         = SUBSTRING(
		   -- @formatter:off
    		SqlText.text,
    		Requests.statement_start_offset / 2 + 1,
			((
			    IIF (Requests.statement_end_offset = -1,
			        DATALENGTH(SqlText.text),
			        Requests.statement_end_offset
			    	) - Requests.statement_start_offset) / 2
			) + 1),
			-- @formatter:on
	   SqlPlan           = SqlPlan.query_plan
FROM sys.dm_exec_sessions AS Sessions
INNER JOIN sys.dm_os_waiting_tasks AS Tasks ON Tasks.session_id = Sessions.session_id
LEFT JOIN sys.dm_exec_requests AS Requests ON Requests.session_id = Sessions.session_id
OUTER APPLY sys.dm_exec_sql_text(Requests.sql_handle) AS SqlText
OUTER APPLY sys.dm_exec_query_plan(Requests.plan_handle) AS SqlPlan
WHERE Sessions.is_user_process = 1
  AND Tasks.wait_type NOT IN ('WAITFOR', 'SP_SERVER_DIAGNOSTICS_SLEEP', 'CXPACKET')
ORDER BY Tasks.wait_duration_ms DESC

-- Blocking requests.
SELECT BlockingSessionId = BlockingRequests.session_id,
       StartTime         = BlockingRequests.start_time,
	   HostName          = BlockingSessions.host_name,
	   ProgramName       = BlockingSessions.program_name,
	   LoginName         = BlockingSessions.login_name,
	   TsqlFrame         = SUBSTRING(
		   -- @formatter:off
    		SqlText.text,
    		BlockingRequests.statement_start_offset / 2 + 1,
			((
			    IIF (BlockingRequests.statement_end_offset = -1,
			        DATALENGTH(SqlText.text),
			        BlockingRequests.statement_end_offset
			    	) - BlockingRequests.statement_start_offset) / 2
			) + 1),
			-- @formatter:on
	   SqlPlan           = SqlPlan.query_plan
FROM (SELECT DISTINCT blocking_session_id FROM sys.dm_exec_requests WHERE blocking_session_id IS NOT NULL) AS BlockedRequests
INNER JOIN sys.dm_exec_requests AS BlockingRequests ON BlockingRequests.session_id = BlockedRequests.blocking_session_id
INNER JOIN sys.dm_exec_sessions AS BlockingSessions ON BlockingSessions.session_id = BlockingRequests.session_id
OUTER APPLY sys.dm_exec_sql_text(BlockingRequests.sql_handle) AS SqlText
OUTER APPLY sys.dm_exec_query_plan(BlockingRequests.plan_handle) AS SqlPlan