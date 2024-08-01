/* Weekday name, e.g. Sunday */
select DATENAME(weekday, date_created) as cd 
from date_series

/* Weekday name short e.g. Sat */
SELECT
  FORMAT(CAST('2022-01-01' AS DATE), 'ddd');
The result is 'Sat'.

SELECT
  FORMAT(CAST('2022-01-01' AS DATE), 'dddd', 'de-de');
The result is 'Samstag'.

/* yyyy-MM-dd */
SELECT FORMAT(date_created, 'yyyy-MM-dd') AS dt /* Month as two digit number, do not use lower case mm since this is MINUTES */
SELECT FORMAT(date_created, 'yyyy-MMM-dd') AS dt 
FROM generate_date_series;

FORMAT(RegistrationDate ,'dddd, d MMMM, yyyy') AS FormattedRegistrationDate

/* Weekday number 1-7 */
select datepart(WEEKDAY, date_created) as cd 
from generate_date_series

SELECT SYSDATETIME() AS SysDateTime;
SELECT ISDATE('2017-08-25');

SELECT GETUTCDATE();
SELECT GETDATE();

SELECT DATEFROMPARTS(2018, 10, 31) AS DateFromParts;

SELECT DATEDIFF(year, '2017/08/25', '2011/08/25') AS DateDiff;
SELECT DATEADD(year, 1, '2017/08/25') AS DateAdd;
SELECT CURRENT_TIMESTAMP;

