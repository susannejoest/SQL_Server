/* range row */
OVER (  
  [ <PARTITION BY clause> ]
  [ <ORDER BY clause> ]
  [ <ROW or RANGE clause> 
BETWEEN <Start expr> AND <End expr>] /* default is RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW; e.g. running total */
)

/* moving average */
  AVG(revenue_amount) OVER (
    PARTITION BY shop
    ORDER BY date ASC
    RANGE BETWEEN INTERVAL '1' DAY PRECEDING AND CURRENT ROW
  ) AS moving_avg
	
	avg(marks) over (ORDER BY exam_date ASC     
		ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as avg_marks_moving
	  LAST_VALUE(revenue_amount) OVER (
	
    PARTITION BY shop
    ORDER BY date

    ORDER BY (date - '2021_05_01')
	
    /* default is RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW; e.g. running total */
  	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	RANGE BETWEEN 1 PRECEDING AND CURRENT ROW
	RANGE BETWEEN 1000 PRECEDING AND 1000 FOLLOWING
	RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	
	ROWS BETWEEN 3 PRECEDING AND CURRENT ROW /* valid in sql server */
	ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
	/* In SQL Server, the INTERVAL keyword is not supported
	Date Interval: RANGE BETWEEN INTERVAL '3' DAY PRECEDING AND INTERVAL '1' DAY FOLLOWING
	RANGE BETWEEN INTERVAL '7' DAY PRECEDING AND CURRENT ROW */
	
with all_candidates_skills
as (select c.candidate, s.skill ,
	row_number() over (partition by c.candidate order by skill) as Row_No_Candidate_Skill
	from candidates c, skills s)
/* select * from candidates_Skills, 9 per person */
,
candidate_skill_matrix as
(
select c_s.candidate, c_s.Row_No_Candidate_Skill, c_s.skill as All_Skills, cs.skill 
from all_candidates_skills c_s
left outer join [dbo].[CandidateSkills] cs on c_s.skill = cs.skill and c_s.candidate = cs.candidate
)
/*
select candidate,
	string_agg(skill,',') as Skill_List
from candidate_skill_matrix
group by candidate
*/

SELECT 
    candidate,
    STRING_AGG(CASE WHEN Skill IS NULL THEN All_Skills END, ',') AS Missing_Skill_List,
    STRING_AGG(skill, ',') AS Candidate_Skill_List
	/* STRING_AGG(if count(select skill from roleskills rs where role = 'DB Architect' and rs.skill = skill)>0, skill, null) as Skills_DB_Architect */
FROM 
    candidate_skill_matrix
GROUP BY 
    candidate;

/* Students marks etc. */
SELECT 
		/* Studentname, 
       Subject, */
       
	   city, 
	   Marks, 
       /* ROW_NUMBER() OVER(partition by city ORDER BY e.Marks asc) Subject_Mark_RowNumber, */
	   /* RANK() OVER(PARTITION BY city ORDER BY Marks DESC) as City_Rank */
	   /* DENSE_RANK() OVER(PARTITION BY e.Subject ORDER BY Marks DESC, studentname asc /* tie breaker */) as Subject_Rank,
	   NTILE(2) OVER(partition by e.subject ORDER BY Marks DESC) as Ntile_2_Rank, */
	   avg(marks) /* FILTER(WHERE marks > 60) Postgre SQL */ over ( partition by city order by marks desc ROWS BETWEEN 1 /* UNBOUNDED */ PRECEDING AND 1 /* UNBOUNDED */ FOLLOWING) as Avg_Marks,
	   /* SUM(marks) OVER( PARTITION BY city   ORDER BY marks asc 
	   /* ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING */) AS CumulativeTotalMarks */
	   first_value(marks) over (order by marks) as lowest_Mark,
	   last_value(marks) over (order by marks RANGE BETWEEN /* 1 */ UNBOUNDED PRECEDING AND 
                               /* 1 */ UNBOUNDED FOLLOWING /* EXCLUDE CURRENT ROW */) as hightest_Mark,
		/* nth_value(count(marks)) over (partition by city) as hightest_Mark, ORACLE ONLY */
		lag(marks) over (partition by city order by marks) as Prev_row_mark,
	
		lead(marks) over (partition by city order by marks) as Next_row_mark
	lead(exam_date,1) over (order by exam_date asc) as lead_exam_date, /* default is 1 row */
	lead(exam_date,2) over (order by exam_date asc) as lead_exam_date2,
	
	datediff(dd,exam_date, lead(exam_date) over (order by exam_date asc)) as diff_date,
	sum(marks) over () as sum_marks_ALL, /* ALL marks in entire table added up */
	sum(marks) over (order by exam_date, marks) as sum_marks_dt,
	
	avg(marks) over (ORDER BY exam_date ASC     
		ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) as avg_marks_moving,
	sum(marks) over (ORDER BY exam_date ASC     
		RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as sum_marks_movings

	
	PERCENT_RANK(5) WITHIN GROUP (ORDER BY X DESC) as How_would_rank_x_percent
	PERCENT_CONT(0) WITHIN GROUP (ORDER BY X DESC) as Inverse_continuous /* 0.5 = Median */
	PERCENT_DISC(0) WITHIN GROUP (ORDER BY X DESC) as Inverse_Discrete
FROM ExamResult e
order by city, marks desc
	/* ROW_NUMBER() OVER(partition by city ORDER BY e.Marks asc) */
/* order by ntile_2_rank
OFFSET 1 ROWS FETCH NEXT 3 ROWS ONLY;*/

/* 28-Jul-2024 */
select
city, 
subject,
Marks,
avg(marks) OVER (partition by city order by city ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) as avg_marks_city,
sum(marks) OVER (ORDER BY marks ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as sum_marks_unbprec_curr,
first_value(marks) OVER (partition by city order by marks) as first_value_marks_city,
last_value(marks) OVER (partition by city order by marks) as last_value_marks_city,
rank() over (/* partition by city */ order by subject desc) as rank_city_marks,
ntile(4) over (order by marks desc) as ntile_c,
sum(marks) OVER (order by city asc, marks asc ) as city_sum_marks,
lag(marks) over (order by city ) as lag_mark,
lead(marks) over (order by city, marks) as lead_mark,
row_number() over (order by city, marks) as row_no,
PERCENT_RANK() over (order by marks desc) as pct_rank_grp

FROM ExamResult e
/* where subject = 'english' */
order by city asc, marks asc
	
	/* window only works in postgre ? */
Window w as (partition by city order by marks asc, studentname desc)

	
/* cast is ansi sql, convert has additional formatting */
SELECT CAST('2024-07-28' AS DATETIME) AS DateValue;

SELECT CONVERT(DATETIME, '2024-07-28', 120) AS DateValue;

