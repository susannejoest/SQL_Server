SELECT *
FROM TestTable
WHERE TextData LIKE '%' + CHAR(13) + '%' OR TextData LIKE '%' + CHAR(10) + '%';

SELECT charindex(CHAR(13),TextData) as StringPos
FROM TestTable

/* STRING_SPLIT */
  
  SELECT value FROM STRING_SPLIT('Lorem ipsum dolor sit amet.', ' ');
  
  DECLARE @tags NVARCHAR(400) = 'clothing,road,,touring,bike'
  
  SELECT value COLLATE SQL_Latin1_General_CP1_CI_AS
  FROM STRING_SPLIT(@tags, ',')
  WHERE RTRIM(value) <> '';
