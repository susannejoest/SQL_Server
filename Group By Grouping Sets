select year([Exam_Date]) as year,
		month([Exam_Date]) as month,
		sum(marks) as Marks_Sum,
		count(marks) as Marks_Count
from [dbo].[ExamResult]
group by  year([Exam_Date]), month([Exam_Date])


SELECT 
    year([Exam_Date]),
    month([Exam_Date]),
    sum(marks) as Marks_Sum,
    count(marks) as Marks_Count,
    /* GROUPING(year([Exam_Date])) as Is_this_all_years, */
FROM 
    [dbo].[ExamResult]
GROUP BY 
    GROUPING SETS (
        (year([Exam_Date]), month([Exam_Date])), 
        year([Exam_Date])
    );




SELECT 
    year([Exam_Date]),
    month([Exam_Date]),
    sum(marks) as Marks_Sum,
    count(marks) as Marks_Count,
    /* GROUPING(year([Exam_Date])) as Is_this_all_years, */
    STRING_AGG([StudentName], ',') WITHIN GROUP (ORDER BY [StudentName]) AS Y
FROM 
    [dbo].[ExamResult]
GROUP BY year([Exam_Date]), month([Exam_Date])
  
