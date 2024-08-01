set statistics io, time on

select candidate 
from candidates 
where candidate = ANY (select candidate from candidateskills)

select candidate 
from candidates 
where exists (select null from candidateskills where candidateskills.candidate = candidates.candidate)


select studentname, marks
from examresult
where marks >= ALL (select marks from examresult)

IF 3 < SOME (SELECT ID FROM T1)  /* There is no functional or performance benefit in choosing SOME over ANY or vice versa */
PRINT 'TRUE'   
ELSE  
PRINT 'FALSE' ;
