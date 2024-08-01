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
