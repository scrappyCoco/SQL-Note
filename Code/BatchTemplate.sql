--
-- Шаблон для добавление данных пачками из одной таблицы в другую.
--
DECLARE @SourceTable TABLE (
  Id INT PRIMARY KEY
);
DECLARE @DestinationTable TABLE (
  Id INT PRIMARY KEY
);

DECLARE @BATCH_SIZE INT = 500;

DECLARE @output TABLE (
  Id INT PRIMARY KEY NOT NULL
);
DECLARE @id INT = 1;

WHILE @id > 0
BEGIN
  INSERT
  INTO @DestinationTable (Id)
    OUTPUT inserted.Id INTO @output (Id)
  SELECT TOP (@BATCH_SIZE)
    Id
  FROM @SourceTable
  WHERE
    Id >= @id
  ORDER BY Id ASC;

  SET @id = -1;

  SELECT
    @id = MAX(Id) + 1
  FROM @output;

  DELETE @output;
END