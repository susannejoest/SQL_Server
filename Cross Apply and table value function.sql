/* Applying Table-Valued Functions */

SELECT e.Studentname, e.Subject, f.*
FROM ExamResult e
CROSS APPLY dbo.GetStudentDetails(e.StudentID) AS f;

/* table value function student city */

CREATE FUNCTION dbo.GetStudentDetails (@StudentID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT City
    FROM Student
    WHERE StudentID = @StudentID
);


/* Filtering Rows with Correlated Subqueries */
SELECT e.Studentname, e.Subject, e.marks, r.MaxMarks
FROM ExamResult e
CROSS APPLY (
    SELECT MAX(Marks) AS MaxMarks
    FROM ExamResult r
    WHERE r.Subject = e.Subject
) AS r;

/* returning related rows */

SELECT e.Studentname, e.Subject, r.TopMarks
FROM ExamResult e
CROSS APPLY (
    SELECT TOP 1 Marks AS TopMarks
    FROM ExamResult r
    WHERE r.Subject = e.Subject
    ORDER BY Marks DESC
) AS r;
