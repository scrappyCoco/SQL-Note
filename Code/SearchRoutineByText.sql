-- Описание: Поиск процедур у функций с указанным названием в коде.
DECLARE @TEXT_FOR_SEARCH NVARCHAR(1000) = N'vw_CompaniesInCases';

DECLARE @searchQuery NVARCHAR(MAX) = N'';

SELECT @searchQuery += N'
UNION
SELECT
 [Database] = ''' + databases.name + ''',
 [Schema]   = CAST(schemas.name COLLATE DATABASE_DEFAULT AS NVARCHAR(500)),
 [Routine]  = CAST(objects.name COLLATE DATABASE_DEFAULT AS NVARCHAR(500)),
 [TypeDesc] = CAST(objects.type_desc COLLATE DATABASE_DEFAULT AS NVARCHAR(500))
FROM [' + databases.name + '].sys.syscomments
INNER JOIN [' + databases.name + '].sys.objects ON objects.object_id = syscomments.id
INNER JOIN [' + databases.name + '].sys.schemas ON schemas.schema_id = objects.schema_id
WHERE syscomments.text LIKE N''%' + @TEXT_FOR_SEARCH + '%''
'
FROM sys.databases
WHERE databases.state_desc = 'ONLINE';

SET @searchQuery = STUFF(@searchQuery, 1, LEN('  UNION  '), '')

EXEC (@searchQuery)