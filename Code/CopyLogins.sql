-- Описание: Создание логинов SQL для переноса на другой сервер (SID). Копирование родей сервера необходимо отдельно.
-- Источник: https://support.microsoft.com/ru-ru/help/918992/how-to-transfer-logins-and-passwords-between-instances-of-sql-server

SELECT
  CreateLoginSql = 'CREATE LOGIN ' + QUOTENAME(p.name)
                     + CASE
                         WHEN p.type IN ('G', 'U') THEN ' FROM WINDOWS WITH DEFAULT_DATABASE = [' + p.default_database_name + ']'
                         ELSE ' WITH PASSWORD = ' + CONVERT(VARCHAR(512), LOGINPROPERTY(p.name, 'PasswordHash'), 1) + ' HASHED,'
                           + ' SID = ' + CONVERT(VARCHAR(512), p.sid, 1) + ','
                           + ' DEFAULT_DATABASE = [' + p.default_database_name + ']'
                           + IIF(sql_logins.default_language_name IS NULL, '', ', DEFAULT_LANGUAGE = ' + sql_logins.default_language_name)
                           + IIF(sql_logins.is_policy_checked IS NULL, '', ', CHECK_POLICY = ' + IIF(sql_logins.is_policy_checked = 1, 'ON', 'OFF'))
                           + IIF(sql_logins.is_expiration_checked IS NULL, '', ', CHECK_EXPIRATION = ' + IIF(sql_logins.is_expiration_checked = 1, 'ON', 'OFF'))
                     END + ';'
                     + IIF(l.denylogin IS NULL, '', CHAR(10) + 'DENY CONNECT SQL TO ' + QUOTENAME(p.name)) + ';'
                     + IIF(l.hasaccess IS NULL, '', CHAR(10) + 'REVOKE CONNECT SQL TO ' + QUOTENAME(p.name)) + ';'
                     + IIF(p.is_disabled IS NULL, '', CHAR(10) + 'ALTER LOGIN ' + QUOTENAME(p.name) + ' DISABLE') + ';'
                     + CHAR(10) + '-- Server roles'
                     + ISNULL(
                       CAST(
                           (
                             SELECT
                               CHAR(10) + 'EXEC sp_addrolemember ''' + ServerRole.name + ''', ''' + ServerLogin.name + ''''
                             FROM sys.server_role_members
                                  INNER JOIN sys.server_principals AS ServerRole ON ServerRole.principal_id = server_role_members.role_principal_id
                                  INNER JOIN sys.server_principals AS ServerLogin ON ServerLogin.principal_id = server_role_members.member_principal_id
                             WHERE ServerLogin.name = p.name
                               FOR XML PATH (''), TYPE
                           ) AS VARCHAR(MAX)), '-->> Nothing'
                     )
                     + CHAR(10) + '-- Securables'
                     + ISNULL(
                       CAST(
                           (
                             SELECT
                                 CHAR(10) + CASE
                                              WHEN server_permissions.state_desc LIKE 'GRANT%' THEN 'GRANT '
                                              ELSE 'DENY '
                                 END
                                 + server_permissions.permission_name + ' TO ' + QUOTENAME(p.name)
                                 + IIF(server_permissions.state_desc = 'GRANT_WITH_GRANT_OPTION', ' WITH GRANT OPTION', '')
                                 + ';'
                             FROM sys.server_permissions
                             WHERE server_permissions.grantee_principal_id = p.principal_id
                               FOR XML PATH (''), TYPE
                           ) AS VARCHAR(MAX)), '-->> Nothing'
                     )
FROM sys.server_principals p
     LEFT JOIN sys.syslogins l ON l.name = p.name
     LEFT JOIN sys.sql_logins ON sql_logins.name = l.name
WHERE p.type IN ('S', 'G', 'U')
  AND p.name <> 'sa';