--
-- Получение списка job'ов, которые були запущены в указанное время.
--
DECLARE @jobDate DATETIME = '2020-07-28T02:58:00';

SELECT JobName,
       StepName,
       BeingStepDateTime = MIN(BeingStepDateTime),
       EndStepDateTime = MAX(EndStepDateTime)
FROM (
       SELECT JobName           = sysjobs.name,
              StepName          = sysjobsteps.step_name,
              BeingStepDateTime = msdb.dbo.agent_datetime(run_date, run_time),
              EndStepDateTime   = DATEADD(SS, run_duration, msdb.dbo.agent_datetime(run_date, run_time))
       FROM msdb.dbo.sysjobs
            INNER JOIN msdb.dbo.sysjobhistory ON sysjobhistory.job_id = sysjobs.job_id
            INNER JOIN msdb.dbo.sysjobsteps ON sysjobsteps.step_id = sysjobhistory.step_id
                                           AND sysjobsteps.job_id  = sysjobhistory.job_id
     ) AS g
WHERE @jobDate BETWEEN BeingStepDateTime AND EndStepDateTime
GROUP BY JobName, StepName
ORDER BY JobName;