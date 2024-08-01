select * 
from candidates c
	left outer join 
		(candidateskills cs
			inner join roleskills r 
			on cs.skill = r.skill)
			on c.candidate = cs.candidate
			
