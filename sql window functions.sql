
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
	   /* DENSE_RANK() OVER(PARTITION BY e.Subject ORDER BY Marks DESC) as Subject_Rank,
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

/* cast is ansi sql, convert has additional formatting */
SELECT CAST('2024-07-28' AS DATETIME) AS DateValue;

SELECT CONVERT(DATETIME, '2024-07-28', 120) AS DateValue;

