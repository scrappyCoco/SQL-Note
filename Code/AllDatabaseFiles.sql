-- Описание: Список файлов всех БД.
SELECT DBName   = db.name,
	   FileType = mf.type_desc,
	   Location = mf.Physical_Name,
Size = mf.size
FROM sys.master_files AS mf
INNER JOIN sys.databases AS db ON db.database_id = mf.database_id
ORDER BY mf.size DESC