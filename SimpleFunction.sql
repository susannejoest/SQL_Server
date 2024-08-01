DECLARE @CandidateName as varchar(30)
DECLARE @RESULTSTRING AS VARCHAR(255)
Declare @CandidateID as integer

set @CandidateName = 'Darrin'

/* Contract ID must be valid */
	IF EXISTS ( SELECT  null
					FROM    candidates
					WHERE   candidate = @CandidateName)
		BEGIN
			set @CandidateID  = (select candidateid from candidates where candidate = @CandidateName)
			SET @RESULTSTRING = 'Candidate does exist: ' + str(@candidateid)
			select @RESULTSTRING
			goto lblEnd
		END

			SET @RESULTSTRING = 'Candidate does not exist: ' + (CASE WHEN @CandidateName IS NULL THEN 'NULL' ELSE 'STR(@CandidateID)' END)
			select @RESULTSTRING
lblEnd:		
