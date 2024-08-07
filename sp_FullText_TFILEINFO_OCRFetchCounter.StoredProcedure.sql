USE [DAQ-1445_Contiki_App_DESQL016_Divestment]
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_FullText_TFILEINFO_OCRFetchCounter]    Script Date: 24 Jun 2024 11:12:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_FullText_TFILEINFO_OCRFetchCounter]
/* 
instructions: \\theserver.local\fs14$\Shares\DEKON23\legal\TheVendor\Regular Tasks\OCR Scan
This procedure sets the OCR counter to a number 5-9 if text content is detected in pdfs 
(these are the only ones full text scanned so the counter is not needed elsewhere)
it must be run before any documents are automatically full text scanned

Purpose: only documents that are not already OCR Scanned must be included in the bulk OCR scan
primarily because of conversion issues caused by:
- Adobe Docusign (UK uses this)
- Docusign in general (e.g. used by Canada) - docusign locks the docs for editing and this crashes the ocr process
3. per Kim, documents with drawings can get messed up but that is not a major concern for legal docs since most are text

V_Takeda_FullText_TFILEINFO_OCR_FileIDsInScope

*/
AS

BEGIN

/* pdfs flagged as corrupt = fetch counter 99 */
/* flag as corrupt = alter TITLE in Tdocument via edit first 200 rows then filter by fileid to be */
/* *CORRUPT FILE* */
/* *PASSWORD PROTECTED* */
/* *WRITE PROTECTED* */

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 99
	where 
		([OCRFetchCounter] is null or [OCRFetchCounter] <2)
		and filetype = '.pdf'
        and (DocumentID in (SELECT documentid
                       FROM TDOCUMENT
					   where 
					document like '%CORRUPT FILE%'
					or document like '%PASSWORD PROTECTED%'
					or document like '%DOCUSIGN PROTECTED%'
					or document like '%WRITE PROTECTED%'))

/* find files that are already full text scanned */

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 9
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter between 0 and 8) /* after ocr upload, file gets new fileinfo version 
		and that entry has the fetchcounter set to 0 instead of NULL) */
		/* and i.documentid in (select documentid from TDOCUMENT where mik_valid = 1) */
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '"Takeda"' ) 
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 	


/* unfortunately single letters are not allowed, they are considered noise words */
/*		update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 1 /* a */
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter = 0) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '%a%' ) /* e.g. handwritten note */
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 

								*/
	/* to include more records key words could be e.g. 199 for 1998 etc 
	BUT many such pdfs will not be relevant (e.g. printer brochure found) 
	STILL this will lessen the number of documents to scan and the # of errors !! */

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 1 /* already picked */
	where (OCRFetchCounter = 0 OR OCRFetchCounter is null)
	and fileid in (select fileid from tfileinfo where OCRFetchCounter > 0) /* previously picked, and flag set back to 0 due to file upload */

END

GO
