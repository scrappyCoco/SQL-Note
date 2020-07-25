--
-- Размеры индексов для указанной таблицы.
--
SELECT
  [Index] = indexes.name,
  Gb      = allocation_units.total_pages * 8 / 1024.0 / 1024.0,
  Rows    = partitions.rows
FROM sys.objects
INNER JOIN sys.partitions ON objects.object_id = partitions.object_id
INNER JOIN sys.allocation_units ON partitions.partition_id = allocation_units.container_id
INNER JOIN sys.indexes ON indexes.object_id = partitions.object_id AND indexes.index_id = partitions.index_id
WHERE
  objects.name = 'MyTableName';