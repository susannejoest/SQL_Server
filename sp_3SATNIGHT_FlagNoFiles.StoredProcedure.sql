USE [DAQ-1445_Contiki_App_DESQL016_Divestment]
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_3SATNIGHT_FlagNoFiles]    Script Date: 24 Jun 2024 11:12:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_3SATNIGHT_FlagNoFiles]

AS

BEGIN


/* 6a remove flag ' *NO FILES*' from contracts that have a document attached */

	update [TCONTRACT]
	set [CONTRACT]=  RTRIM(REPLACE([CONTRACT], '*NO FILES*', '')) /* remove flag */
	where 
	[CONTRACT] LIKE ('%*NO FILES*%') /* has flag */
	AND [CONTRACT] NOT LIKE ('%DELETE (NO FILES FOR OVER 2 YEARS): %')
	/* [V_Takeda_VDOCUMENT] WITH AMENDMENT!!!! */
	AND CONTRACTID IN (SELECT OBJECTID from TDOCUMENT WHERE MIK_VALID = 1) /* has attachment */

	/*/* remove flag if AUTODELETE */
	update [TCONTRACT]
	set [CONTRACT]=  RTRIM(REPLACE([CONTRACT], '*NO FILES*', '')) /* remove flag */
	where 
	[CONTRACT] LIKE ('%*NO FILES*%') /* has flag */
	AND [CONTRACT] NOT LIKE '%DELETE (NO FILES FOR OVER 2 YEARS): %'
	AND ([COUNTERPARTYNUMBER] = ('!AUTODELETE') /* autodelete */
		OR 	contracttypeid IN ('6' /*Access*/,'11'  /*Case*/, '13' /* DELETE */, '102' /* TEST */) 
		)
	*/
	
/* 6b add flag ' *NO FILES*' to contracts that have no document attached */

	update [TCONTRACT]
	set [CONTRACT]= [CONTRACT] +' *NO FILES*'
	where 
	[CONTRACT] NOT LIKE ('%*NO FILES*%') /* flag not already set */
	AND [CONTRACT] NOT LIKE ('%DELETE (NO FILES FOR OVER 2 YEARS): %')
	AND [CONTRACT] NOT LIKE ('%AUTODELETE%')
	AND CONTRACTID 	/* [V_Takeda_VDOCUMENT] WITH AMENDMENT!!!! */ NOT IN (SELECT OBJECTID from TDOCUMENT) /* does not have attachment */
	AND LEN([CONTRACT] +' *NO FILES*') <=255 /* would not exceed field size */
	AND contracttypeid NOT IN ('6' /*Access*/,'11'  /*Case*/, '13' /* DELETE */, '102' /* TEST */) /* junk */
	and getdate() > dateadd(hh,+27,contractdate)   /* has been registered for more than 1 day */

/* 6c add flag 'DELETE (NO FILES FOR OVER 2 YEARS' and mark as AUTODELETE */

	update [TCONTRACT]
	set [CONTRACT]= SUBSTRING('DELETE (NO FILES FOR OVER 2 YEARS): '+[CONTRACT],1,255)
	where 
	[CONTRACT] NOT LIKE ('%DELETE (NO FILES FOR OVER 2 YEARS): %') /* flag not already set */
	AND CONTRACTID 	/* [V_Takeda_VDOCUMENT] WITH AMENDMENT!!!! */ NOT IN (SELECT OBJECTID from TDOCUMENT where MIK_VALID = 1) /* does not have attachment */
	AND contracttypeid NOT IN ('11' /*Case*/, '13' /* DELETE */, '102' /* TEST */)
	and getdate() > dateadd(yy,+2,contractdate)   /* has been registered for more than 2 years */

	/* AUTODELETE if older than 2 years */
		update [TCONTRACT]
		set [COUNTERPARTYNUMBER]= '!AUTODELETE'
		where 
		CONTRACTID 	/* [V_Takeda_VDOCUMENT] WITH AMENDMENT!!!! */ NOT IN (SELECT OBJECTID from TDOCUMENT where MIK_VALID = 1) /* does not have attachment */
		AND contracttypeid = 12 /* Contract */
		and getdate() > dateadd(yy,+2,contractdate)   /* has been registered for more than 2 years */
		AND ([COUNTERPARTYNUMBER]<> '!AUTODELETE' 
				OR [COUNTERPARTYNUMBER] is null)
			
			
/* old code
	update [TCONTRACT]
	set [CONTRACT]= [CONTRACT] +' *NO FILES*'
	where [NUMBEROFFILES] = 0
	and len([CONTRACT]) <= 244
	and getdate() > dateadd(hh,+12,contractdate)   /* registered for more than 12 hrs */
	and contract not like '%NO FILES%'
	and contractid not in (select objectid from tdocument where mik_valid = 1)
	and CONTRACTTYPEID not in(	6 /* Access */
								, 5 /* Test Old */
								,102 /* Test New */
								,13 /* DELETE */ 
								,106 /* autodelete */
								,103 /*file*/
								,104 /*corp file*/
								,105 /* ContractList */)

/* Remove Flag */
update [TCONTRACT]
set [CONTRACT]= replace([CONTRACT],' *NO FILES*','')
where contract like '%NO FILES%'
AND ([NUMBEROFFILES] > 0 OR
		contractid in (select objectid from tdocument where mik_valid = 1))

/* update [TCONTRACT]
set [CONTRACT]= replace([CONTRACT],'DELETE (NO FILES FOR OVER 2 YEARS): ','') 
where contract like '%DELETE (NO FILES FOR OVER 2 YEARS)%'
AND ([NUMBEROFFILES] > 0 OR
		contractid in (select objectid from tdocument where mik_valid = 1))
*/ */

END
GO
