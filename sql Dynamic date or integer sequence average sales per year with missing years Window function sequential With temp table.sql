/* date series */
DECLARE @StartDateTime DATETIME = '2024-01-01 00:00:00';
DECLARE @EndDateTime DATETIME = '2024-01-01 23:59:00';

WITH DateSeries AS (
    SELECT @StartDateTime AS DateTimeValue  /* Anchor member determines data type !*/
    UNION ALL
    SELECT DATEADD(MINUTE, 1, DateTimeValue)
    FROM DateSeries
    WHERE DATEADD(MINUTE, 1, DateTimeValue) <= @EndDateTime
)
SELECT DateTimeValue
FROM DateSeries
OPTION (MAXRECURSION 0); /* used to prevent a poorly formed recursive CTE from entering into an infinite loop */

/* WITH date series , Max Recursion */
WITH generate_series AS (
    SELECT CAST('2019-01-01' AS DATE) AS date_created /* Anchor member determines data type !*/
    UNION ALL
    SELECT DATEADD(day, 1, date_created)
    FROM generate_series
    WHERE date_created < '2020-01-01'

	)
	SELECT *
	FROM generate_series
	order by date_created
	OPTION (MAXRECURSION 0); /* or e.g. 365 for a whole year */


/* DYNAMIC NUMBER SERIES */

	WITH number_series as (
	select 1 as Number  /* Anchor member determines data type !*/
	UNION ALL
	SELECT Number + 1
	FROM number_series
	 WHERE Number <3)

select * from number_series


/* get average sales per customer for a specific range of years while including years with zero turnover with a value of 0 */

/* Short solution with nesting */

WITH  integer_sequence(n) AS ( /* the (n) in brackets is OPTIONAL and just to illustrate what the variable is */
  SELECT 2019 /* as n */ -- anchor / starting value  /* Anchor member determines data type !*/
  UNION ALL
  SELECT n+1 FROM integer_sequence WHERE n < 2021 -- ending value
)
	
			Select customer_id,customer_name,AVG(amount) from (
			Select A.n as bill_Year,A.customer_id ,A.customer_name,ISNULL(billing_amount,0) AS Amount from (
			SELECT * FROM integer_sequence A  cross join  (Select distinct customer_id,customer_name from [DAQ-1445_Contiki_App_DESQL016_Divestment].[dbo].[T_0_SJ_Customers])B

			) A
				left outer join  [DAQ-1445_Contiki_App_DESQL016_Divestment].[dbo].[T_0_SJ_Customers] B on  A.n=DATEPART(YEAR,B.billing_creation_date) and A.customer_id=B.customer_id

			 
) B
group by customer_id,customer_name

/* Longer solution with three staging tables to make it simpler to read */

WITH  

integer_sequence(n) AS (
  SELECT 2019 -- starting value
  UNION ALL
  SELECT n+1 FROM integer_sequence WHERE n < 2021 -- ending value
) 
, 

customers_years as
(
	SELECT * FROM integer_sequence A  cross join  
		(Select distinct customer_id,customer_name 
		from [DAQ-1445_Contiki_App_DESQL016_Divestment].[dbo].[T_0_SJ_Customers]) B

		)
															
, 

Billing_Customer_Year as

(select * , DATEPART(YEAR,billing_creation_date) as Billing_Creation_Date_YYYY
from [DAQ-1445_Contiki_App_DESQL016_Divestment].[dbo].[T_0_SJ_Customers])

,

Billing_Customer_Year_Joined as

(				Select A.n as bill_Year,
						A.customer_id ,
						A.customer_name,
						b.billing_id,
						b.Billing_Creation_Date_YYYY,
						ISNULL(billing_amount,0) AS Amount 
				from customers_years A

				left outer join  Billing_Customer_Year B on  
					A.n=B.Billing_Creation_Date_YYYY and A.customer_id=B.customer_id

)
/* begin main statement */

			Select customer_id,
				customer_name,
				AVG(Amount) as avg_amt
			from Billing_Customer_Year_Joined
			group by customer_id,customer_name
