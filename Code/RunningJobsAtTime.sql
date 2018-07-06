--
-- Получение списка job'ов, которые були запущены в указанное время.
--
DECLARE @jobDate DATETIME = '2018-07-05T00:36:36';

SELECT *
FROM (
       SELECT JobName           = sysjobs.name,
              StepName          = sysjobsteps.step_name,
              BeingStepDateTime = msdb.dbo.agent_datetime(run_date, run_time),
              EndStepDateTime   = DATEADD(SS, run_duration, msdb.dbo.agent_datetime(run_date, run_time))
       FROM msdb.dbo.sysjobs
            INNER JOIN msdb.dbo.sysjobhistory ON sysjobs.job_id = sysjobhistory.job_id
            INNER JOIN msdb.dbo.sysjobsteps ON sysjobsteps.step_id = sysjobhistory.step_id
                                               AND sysjobsteps.job_id = sysjobhistory.job_id
     ) AS g
WHERE @jobDate BETWEEN BeingStepDateTime AND EndStepDateTime
ORDER BY JobName;