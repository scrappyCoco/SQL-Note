-- Описание: Поиск процедур у функций с указанным названием в коде.
DECLARE @TEXT_FOR_SEARCH NVARCHAR(1000) = N'My text to search';

CREATE TABLE #SearchResult (
  [Database] SYSNAME,
  [Schema]   SYSNAME,
  Routine    SYSNAME,
  TypeDesc   SYSNAME
);

DECLARE @searchQuery NVARCHAR(1000);

SET @searchQuery = N'
USE [?];

INSERT INTO #SearchResult ([Database], [Schema], [Routine], [TypeDesc])
SELECT DISTINCT
 [Database] = ''?'',
 [Schema]   = schemas.name,
 [Routine]  = objects.name,
 [TypeDesc] = objects.type_desc
FROM sys.syscomments
INNER JOIN sys.objects ON objects.object_id = syscomments.id
INNER JOIN sys.schemas ON schemas.schema_id = objects.schema_id
WHERE syscomments.text LIKE ''%' + @TEXT_FOR_SEARCH + '%''
';

EXEC sys.sp_MSforeachdb @searchQuery;

SELECT *
FROM #SearchResult;

DROP TABLE #SearchResult;