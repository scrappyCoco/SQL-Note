-- Описание: Создание логинов SQL для переноса на другой сервер (SID). Копирование родей сервера необходимо отдельно.
-- Источник: https://support.microsoft.com/ru-ru/help/918992/how-to-transfer-logins-and-passwords-between-instances-of-sql-server

SELECT
  CreateLoginSql = 'CREATE LOGIN ' + QUOTENAME(p.name)
                     + CASE
                         WHEN p.type IN ('G', 'U') THEN ' FROM WINDOWS WITH DEFAULT_DATABASE = [' + p.default_database_name + ']'
                         ELSE ' WITH PASSWORD = ' + CONVERT(VARCHAR(512), LOGINPROPERTY(p.name, 'PasswordHash'), 1) + ' HASHED,'
                           + ' SID = ' + CONVERT(VARCHAR(512), p.sid, 1) + ','
                           + ' DEFAULT_DATABASE = [' + p.default_database_name + ']'
                           + IIF(sql_logins.is_policy_checked IS NULL, '', ', CHECK_POLICY = ' + IIF(sql_logins.is_policy_checked = 1, 'ON', 'OFF'))
                           + IIF(sql_logins.is_expiration_checked IS NULL, '', ', CHECK_EXPIRATION = ' + IIF(sql_logins.is_expiration_checked = 1, 'ON', 'OFF'))
                     END + ';'
                     + IIF(l.denylogin IS NULL, NULL, CHAR(10) + 'DENY CONNECT SQL TO ' + QUOTENAME(p.name)) + ';'
                     + IIF(l.hasaccess IS NULL, NULL, CHAR(10) + 'REVOKE CONNECT SQL TO ' + QUOTENAME(p.name)) + ';'
                     + IIF(p.is_disabled IS NULL, NULL, CHAR(10) + 'ALTER LOGIN ' + QUOTENAME(p.name) + ' DISABLE') + ';'
FROM sys.server_principals p
     LEFT JOIN sys.syslogins l ON l.name = p.name
     LEFT JOIN sys.sql_logins ON sql_logins.name = l.name
WHERE p.type IN ('S', 'G', 'U')
  AND p.name <> 'sa';