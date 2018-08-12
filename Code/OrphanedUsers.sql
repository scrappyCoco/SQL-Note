CREATE TABLE #OrphanedUser (
  [DataBase] SYSNAME,
  TypeDesc   NVARCHAR(60),
  Sid        VARBINARY(85),
  UserName   SYSNAME
);

DECLARE @command VARCHAR(1000)
SELECT @command =
       'USE ?;

       INSERT INTO #OrphanedUser ([DataBase], TypeDesc, Sid, UserName)
       SELECT DB_NAME(),
              dp.type_desc,
              dp.SID,
              dp.name AS user_name
       FROM sys.database_principals AS dp
            LEFT JOIN sys.server_principals AS sp ON dp.SID = sp.SID
       WHERE sp.SID IS NULL
         AND authentication_type_desc = ''INSTANCE'';';


EXEC sp_MSforeachdb @command;

SELECT *
FROM #OrphanedUser;