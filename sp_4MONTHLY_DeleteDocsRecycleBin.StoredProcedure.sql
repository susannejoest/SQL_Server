USE [DAQ-1445_Contiki_App_DESQL016_Divestment]
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_4MONTHLY_DeleteDocsRecycleBin]    Script Date: 24 Jun 2024 11:12:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TheCompany_4MONTHLY_DeleteDocsRecycleBin]
/* added to MONTHLY script */
as

BEGIN

BEGIN TRANSACTION

declare @noteId bigint,
	@objectTypeDocumentId bigint

Select @objectTypeDocumentId = objectTypeId from TOBJECTTYPE where FIXED = 'DOCUMENT'

/* Delete Clauses in document */
delete from TCLAUSE_IN_DOCUMENT where documentid in (Select documentId from tdocument where MIK_VALID = 0)

/* Delete ACL */
delete from TACL where objectTypeId = @objectTypeDocumentId and objectId in (Select documentId from tdocument where MIK_VALID = 0)

/* Delete Note */
delete from TNOTE_IN_OBJECT where objectTypeId = @objectTypeDocumentId and objectId in (Select documentId from tdocument where MIK_VALID = 0)
delete from TOBJECTHISTORY where noteid in (select noteid from TNOTE where documentId in (Select documentId from tdocument where MIK_VALID = 0))
delete from TNOTE where noteid in (select noteid from TNOTE where documentId in (Select documentId from tdocument where MIK_VALID = 0))

/* Update the DocumentId in table FileInfo if it is missing */
Update TFILEINFO set DOCUMENTID = (Select TDOCUMENT.documentId from TDOCUMENT, TFILEINFO fi where TFILEINFO.fileInfoId = fi.fileInfoId and tdocument.fileInfoId = fi.fileInfoId and fi.documentid is null and fi.moduleid is null) where documentid is null and moduleid is null

/* Update the ModuleId in table FileInfo if it is missing */
Update TFILEINFO set MODULEID = (Select TMODULE.MODULEID from TMODULE, TFILEINFO fi where TFILEINFO.fileInfoId = fi.fileInfoId and TMODULE.FILEINFOID = fi.fileInfoId and fi.documentid is null and fi.moduleid is null) where documentId is null and moduleid is null

/* Delete File and FileInfo */
Update TDOCUMENT set SOURCEFILEINFOID = NULL where MIK_VALID = 0 
Update TDOCUMENT set SOURCEFILEINFOID = NULL where SOURCEFILEINFOID in (select sourcefileinfoId from tfileinfo where DOCUMENTID in (Select documentId from tdocument where MIK_VALID = 0) or (documentId is null and moduleid is null))
Update TDOCUMENT set FILEINFOID = NULL where MIK_VALID = 0

Update TFILEINFO set DOCUMENTID = NULL where DOCUMENTID in (Select documentId from tdocument where MIK_VALID = 0)
Delete from TFILEINFO where DOCUMENTID is NULL and MODULEID is NULL  

Delete from TRECYCLEDDOCUMENT

DELETE FROM TFILEPART where fileId not in (Select fileId from tfileinfo)

--Delete from TFILE where fileId not in (Select fileId from tfileinfo)
update f
set    f.ScheduledForDeletion = 1
from tfile f
where 
not exists (select * from tfileinfo fi where fi.fileId = f.fileid)

/* Delete Document */
Delete from TDOCUMENT where documentId in (Select documentId from tdocument where MIK_VALID = 0)

COMMIT TRANSACTION

END
GO
