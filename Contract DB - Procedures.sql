
/****** Object:  StoredProcedure [dbo].[SP_DEPARTMENT_PERMISSIONS]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEPARTMENT_PERMISSIONS] 

AS
BEGIN
/* DAILY SCRIPT TheVendor Support Team */
/* Last Modified: Joest, Susanne */
/* Updated on: 10-Dec-2014 */


/* 1. Corporate Legal Dpt Permissions for all records where it is missing, except Top Secret records */

	PRINT '1. Corporate Legal Dpt Permissions'

/* 1a READ Permission*/

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
	contractid
	, 1 /*contract*/
	, (select usergroupid from tusergroup where fixed = 'GROUPLEGAL')
	, NULL /*USERID*/
	, 1 /*PRIVILEGE READ*/
	, 0 /*inheritable*/


	from tcontract 
	where 
	contractid not in (select ta.objectid from tacl ta
		where 
		ta.objecttypeid = 1 /*contract*/ and 
		ta.privilegeid = 1 /*PRIVILEGE READ*/ and 
		ta.groupid in (select usergroupid from tusergroup where fixed = 'GROUPLEGAL') 
		) 

	AND contractid NOT IN (SELECT CONTRACTID FROM TCONTRACT WHERE CONTRACTTYPEID in('6' /* Access SAKSNR number Series*/, '5' /* Test Old */,'102' /* Test New */,'13' /* DELETE */ ))

	AND (UPPER([CONTRACT]) not like '%TOP SECRET%' and [CONTRACT] not like '%CONFIDENTIAL[*]%')

	PRINT '  1a - READ: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* 1b WRITE Permission*/

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
	contractid
	, 1 /*contract*/ 
	, (select usergroupid from tusergroup where fixed = 'GROUPLEGAL') 
	, NULL /*USERID*/
	, 2 /*PRIVILEGE WRITE*/ 
	, 0 /*inheritable*/ 

	from tcontract 
	where 
	contractid not in (select distinct ta.objectid from tacl ta
		where 
		ta.objecttypeid = 1 /*contract*/ and 
		ta.privilegeid = 2 /*PRIVILEGE WRITE*/  and 
		ta.groupid in (select usergroupid from tusergroup where fixed = 'GROUPLEGAL') 
		) 

	AND contractid NOT IN (SELECT CONTRACTID FROM TCONTRACT WHERE CONTRACTTYPEID in('6' /* Access SAKSNR number Series*/, '5' /* Test Old */,'102' /* Test New */,'13' /* DELETE */ ))

	AND (UPPER([CONTRACT]) not like '%TOP SECRET%' and [CONTRACT] not like '%CONFIDENTIAL[*]%')

	PRINT '  1b - WRITE: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* 1c OWNER Permission*/

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
	contractid
	, 1 /*contract*/ 
	, (select usergroupid from tusergroup where fixed = 'GROUPLEGAL') 
	, NULL /*USERID*/
	, 5 /*PRIVILEGE OWNER*/ 
	, 0 /*inheritable*/ 

	from tcontract 
	where 
	contractid not in (select distinct ta.objectid from tacl ta
		where 
		ta.objecttypeid = 1 /*contract*/ and 
		ta.privilegeid = 5 /*PRIVILEGE OWNER*/  and 
		ta.groupid in (select usergroupid from tusergroup where fixed = 'GROUPLEGAL') 
		) 

	AND contractid NOT IN (SELECT CONTRACTID FROM TCONTRACT WHERE CONTRACTTYPEID in('6' /* Access SAKSNR number Series*/, '5' /* Test Old */,'102' /* Test New */,'13' /* DELETE */ ))

	AND (UPPER([CONTRACT]) not like '%TOP SECRET%' and [CONTRACT] not like '%CONFIDENTIAL[*]%')

	PRINT '  1c - OWNER: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'




/* 2. Top Secret Permissions for all records where it is applicable */

/* 2a Top Secret READ Permission*/

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
	contractid
	, 1 /*contract*/
	, (select usergroupid from tusergroup where fixed = 'LG_TOP_SECRET_CONF')
	, NULL /*USERID*/
	, 1 /*PRIVILEGE READ*/
	, 0 /*inheritable*/


	from tcontract 
	where 
	contractid not in (select ta.objectid from tacl ta
		where 
		ta.objecttypeid = 1 /*contract*/ and 
		ta.privilegeid = 1 /*PRIVILEGE READ*/ and 
		ta.groupid in (select usergroupid from tusergroup where fixed = 'LG_TOP_SECRET_CONF') 
		) 

	AND contractid NOT IN (SELECT CONTRACTID FROM TCONTRACT WHERE CONTRACTTYPEID in('6' /* Access SAKSNR number Series*/, '5' /* Test Old */,'102' /* Test New */,'13' /* DELETE */ ))

	AND (UPPER([CONTRACT]) LIKE '%TOP SECRET%')

	PRINT '  2a - READ: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* 2b Top Secret WRITE Permission*/

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
	contractid
	, 1 /*contract*/ 
	, (select usergroupid from tusergroup where fixed = 'LG_TOP_SECRET_CONF') 
	, NULL /*USERID*/
	, 2 /*PRIVILEGE WRITE*/ 
	, 0 /*inheritable*/ 

	from tcontract 
	where 
	contractid not in (select distinct ta.objectid from tacl ta
		where 
		ta.objecttypeid = 1 /*contract*/ and 
		ta.privilegeid = 2 /*PRIVILEGE WRITE*/  and 
		ta.groupid in (select usergroupid from tusergroup where fixed = 'LG_TOP_SECRET_CONF') 
		) 

	AND contractid NOT IN (SELECT CONTRACTID FROM TCONTRACT WHERE CONTRACTTYPEID in('6' /* Access SAKSNR number Series*/, '5' /* Test Old */,'102' /* Test New */,'13' /* DELETE */ ))

	AND (UPPER([CONTRACT]) LIKE '%TOP SECRET%')

	PRINT '  2b - WRITE: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* 2c Top Secret OWNER Permission*/

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
	contractid
	, 1 /*contract*/ 
	, (select usergroupid from tusergroup where fixed = 'LG_TOP_SECRET_CONF') 
	, NULL /*USERID*/
	, 5 /*PRIVILEGE OWNER*/ 
	, 0 /*inheritable*/ 

	from tcontract 
	where 
	contractid not in (select distinct ta.objectid from tacl ta
		where 
		ta.objecttypeid = 1 /*contract*/ and 
		ta.privilegeid = 5 /*PRIVILEGE OWNER*/  and 
		ta.groupid in (select usergroupid from tusergroup where fixed = 'LG_TOP_SECRET_CONF') 
		) 

	AND contractid NOT IN (SELECT CONTRACTID FROM TCONTRACT WHERE CONTRACTTYPEID in('6' /* Access SAKSNR number Series*/, '5' /* Test Old */,'102' /* Test New */,'13' /* DELETE */ ))

	AND (UPPER([CONTRACT]) LIKE '%TOP SECRET%')

	PRINT '  2c - OWNER: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'



/* 3 PUBLIC Read Permissions for CDAs */
/* Add READ */

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
	contractid
	, 1 /*contract*/
	, (select usergroupid from tusergroup where fixed = 'READ_PUBLIC')
	, NULL /*USERID*/
	, 1 /*PRIVILEGE READ*/
	, 0 /*inheritable*/

	from tcontract 
	where 
	contractid not in (select distinct ta.objectid from tacl ta
		where 
		ta.objecttypeid = 1 /*contract*/ and 
		ta.privilegeid = 1 /*PRIVILEGE READ*/ and 
		ta.groupid in (select usergroupid from tusergroup where fixed = 'READ_PUBLIC') 
		) 

	AND CONTRACTTYPEID NOT IN ('6' /*Access SAKSNR number Series*/, '5' /*TEST OLD*/,'102' /* TEST NEW */,'13' /*DELETE*/ )

	AND AGREEMENT_TYPEID = 5 /* CDA */

	AND (UPPER([CONTRACT]) not like '%TOP SECRET%' and [CONTRACT] not like '%CONFIDENTIAL[*]%')

	PRINT '3 PUBLIC User Group, Add Read Permission: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'




/* 4 Delete ACL Junk Entries for Territories and Internal Partners Records (that have no effect on permissions but are clutter) */

	DELETE FROM TACL WHERE ACLID IN
	(SELECT ACLID FROM TACL t, TUSERGROUP u WHERE
	t.GROUPID = u.USERGROUPID AND
	  (u.USERGROUP  LIKE  'Territories%'
	   OR
	   u.USERGROUP  LIKE  'Internal Partner%'))

	PRINT '4 DELETE ACL Territories And Internal Partners: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'




/* 5 ADD READ_ALL_HEADERS user group permissions where applicable */

	PRINT '5 ADD READ_ALL_HEADERS user group permissions where applicable'
/* 5a ADD*/
	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
	contractid
	, 1 /*contract*/
	, (select usergroupid from tusergroup where fixed = 'READ_ALL_HEADERS')
	, NULL /*USERID*/
	, 1 /*PRIVILEGE READ*/
	, 0 /*inheritable*/

	from tcontract 
	where 
	contractid not in (select distinct ta.objectid from tacl ta
		where 
		ta.objecttypeid = 1 /*contract*/ and 
		ta.privilegeid = 1 /*PRIVILEGE READ*/ and 
		ta.groupid in (select usergroupid from tusergroup where fixed = 'READ_ALL_HEADERS') 
		) 

	AND CONTRACTTYPEID NOT IN (SELECT CONTRACTID FROM TCONTRACT WHERE CONTRACTTYPEID in(
	   '6' /* Access SAKSNR number Series*/
	,  '5' /* Test Old */
	,'102' /* Test New */
	, '13' /* DELETE */ 
	, '11' /* CASE */)
	)

	AND (UPPER([CONTRACT]) not like '%TOP SECRET%' and [CONTRACT] not like '%STRICTLY CONFIDENTIAL%')

	PRINT '  5a ADD: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* 5b REMOVE Inapplicable READ_ALL_HEADERS user group permissions */

	DELETE FROM TACL WHERE ACLID IN
	(SELECT ACLID FROM TACL t, TUSERGROUP u
	WHERE
		t.GROUPID = u.USERGROUPID 
		AND u.FIXED = 'READ_ALL_HEADERS'	
		)


	AND OBJECTID IN (SELECT CONTRACTID FROM TCONTRACT WHERE CONTRACTTYPEID in(
	   '6' /* Access SAKSNR number Series*/
	,  '5' /* Test Old */
	,'102' /* Test New */
	, '13' /* DELETE */ 
	, '11' /* CASE */) 
		OR (UPPER([CONTRACT]) like '%TOP SECRET%' or [CONTRACT] like '%STRICTLY CONFIDENTIAL%')
	)

	PRINT '  5b REMOVE: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'




/* 6 '*NO FILES*' Flag */

/* 6a remove flag ' *NO FILES*' from contracts that have a document attached */

	update [TCONTRACT]
	set [CONTRACT]=  RTRIM(REPLACE([CONTRACT], '*NO FILES*', ''))
	where 
	[CONTRACT] LIKE '%*NO FILES*%'
	AND CONTRACTID IN (SELECT OBJECTID from TDOCUMENT)
	AND LEN (RTRIM(REPLACE([CONTRACT], '*NO FILES*', ''))) <=255

	PRINT '6a remove flag NO FILES' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* 6b add flag ' *NO FILES*' to contracts that have no document attached */
	update [TCONTRACT]
	set [CONTRACT]= [CONTRACT] +' *NO FILES*'
	where 
	[CONTRACT] NOT LIKE ('%*NO FILES*%')
	AND CONTRACTID NOT IN (SELECT OBJECTID from TDOCUMENT)
	AND LEN([CONTRACT] +' *NO FILES*') <=255

	PRINT '6b add flag NO FILES' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'





/*7 DELETE RECORDS*/

	PRINT '7 - DELETE RECORDS'

/*7a Remove all group Permissions for DELETE Records*/

	DELETE FROM TACL 
	WHERE OBJECTID IN
	(SELECT CONTRACTID FROM TCONTRACT WHERE CONTRACTTYPEID ='13' /* DELETE */ )
	AND  groupid not in 
	(select usergroupid from tusergroup where fixed IN( 'DEL_NUM_SERIES','SYSTEMINTERNAL')  )

	PRINT '  7a Remove all GROUP permissions: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/*7b Remove all user Permissions for DELETE Records except Administrator user */

	DELETE FROM TACL 
	WHERE OBJECTID IN
	(SELECT CONTRACTID FROM TCONTRACT WHERE CONTRACTTYPEID ='13' /* DELETE */ )
	AND  USERID <> 20134 /* ADMINISTRATOR, TheVendor */

	PRINT '  7b Remove all USER permissions: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* 7c ADD DEL_NUM_SERIES user group permissions */

/* 7c READ*/

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
	contractid
	, 1 /*contract*/
	, (select usergroupid from tusergroup where fixed = 'DEL_NUM_SERIES')
	, NULL /*USERID*/
	, 1 /*PRIVILEGE READ*/
	, 0 /*inheritable*/


	from tcontract 
	where 
	contractid not in (select ta.objectid from tacl ta
	where 
	ta.objecttypeid = 1 /*contract*/ and 
	ta.privilegeid = 1 /*PRIVILEGE READ*/ and 
	ta.groupid in (select usergroupid from tusergroup where fixed = 'DEL_NUM_SERIES') 
	) 
	AND contractid IN (SELECT CONTRACTID FROM TCONTRACT WHERE CONTRACTTYPEID ='13' /* DELETE */ )

	PRINT '  7c Add READ: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* 7d WRITE*/

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
	contractid
	, 1 /*contract*/ 
	, (select usergroupid from tusergroup where fixed = 'DEL_NUM_SERIES')
	, NULL /*USERID*/
	, 2 /*PRIVILEGE WRITE*/ 
	, 0 /*inheritable*/ 

	from tcontract 
	where 
	contractid not in (select distinct ta.objectid from tacl ta
	where 
	ta.objecttypeid = 1 /*contract*/ and 
	ta.privilegeid IN (2 /*PRIVILEGE WRITE*/)   and 
	ta.groupid in (select usergroupid from tusergroup where fixed = 'DEL_NUM_SERIES') 
	) 
	AND contractid IN (SELECT CONTRACTID FROM TCONTRACT WHERE CONTRACTTYPEID ='13' /* DELETE */ )

	PRINT '  7d Add WRITE: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'


/* 7e OWNER*/

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
	contractid
	, 1 /*contract*/ 
	, (select usergroupid from tusergroup where fixed = 'DEL_NUM_SERIES')
	, NULL /*USERID*/
	, 5 /*PRIVILEGE OWNER*/ 
	, 0 /*inheritable*/ 

	from tcontract 
	where 
	contractid not in (select distinct ta.objectid from tacl ta
	where 
	ta.objecttypeid = 1 /*contract*/ and 
	ta.privilegeid = 5 /*PRIVILEGE OWNER*/  and 
	ta.groupid in (select usergroupid from tusergroup where fixed = 'DEL_NUM_SERIES') 
	) 
	AND contractid IN (SELECT CONTRACTID FROM TCONTRACT WHERE CONTRACTTYPEID ='13' /* DELETE */ )

	PRINT '  7e Add OWNER: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* 7c DELETE*/

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
	contractid
	, 1 /*contract*/ 
	, (select usergroupid from tusergroup where fixed = 'DEL_NUM_SERIES')
	, NULL /*USERID*/
	, 4 /*PRIVILEGE DELETE*/ 
	, 0 /*inheritable*/ 

	from tcontract 
	where 
	contractid not in (select distinct ta.objectid from tacl ta
	where 
	ta.objecttypeid = 1 /*contract*/ and 
	ta.privilegeid = 4 /*PRIVILEGE DELETE*/  and 
	ta.groupid in (select usergroupid from tusergroup where fixed = 'DEL_NUM_SERIES') 
	) 
	AND contractid IN (SELECT CONTRACTID FROM TCONTRACT WHERE CONTRACTTYPEID ='13' /* DELETE */ )

	PRINT '  7e Add DELETE: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'




/* 8. Delete Awarded Dates so that other dates can be changed without errors */

	PRINT '8. Delete Awarded Dates'

UPDATE tCONTRACT
SET [AWARDDATE] = NULL
WHERE [AWARDDATE] IS NOT NULL

/* 9. Issue #342 - Script to fix active contracts that should be expired and expired ones that should be active */

	PRINT '9. Incorrect Status'

	PRINT '  9a. Active where expiry date has passed'

UPDATE TCONTRACT 
SET STATUSID = 6 /*Expired*/
WHERE STATUSID = 5 /*Active*/
AND ((CASE WHEN [REV_EXPIRYDATE] is not null THEN [REV_EXPIRYDATE] ELSE [EXPIRYDATE] END) < GETDATE()-1) /*Date minus one day for status workflow delay*/

	PRINT '  9b. Expired where expiry date has NOT passed'

UPDATE TCONTRACT 
SET STATUSID = 5 /*Active*/
WHERE STATUSID = 6 /*Expired*/
AND ((CASE WHEN [REV_EXPIRYDATE] is not null THEN [REV_EXPIRYDATE] ELSE [EXPIRYDATE] END) > GETDATE()+1) /*Date plus one day for status workflow delay*/



                               
END
GO

/****** Object:  StoredProcedure [dbo].[TheCompany_0_ARIBADataLoad]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_0_ARIBADataLoad]

as

	begin
	/* make sure to back up old Ariba raw table and rename new table prior to running */
	/* select COUNT(*) from [dbo].[T_TheCompany_Ariba_Dump_Raw] */
	/* select COUNT(*) from [dbo].[T_TheCompany_Ariba_Dump_Raw_2020_07] 104000 records*/

	
	/* EXEC [dbo].[TheCompany_0_ARIBADataLoad_00_SupplierData] */
	EXEC [dbo].[TheCompany_0_ARIBADataLoad_01]
	EXEC [dbo].[TheCompany_0_ARIBADataLoad_02]
	/* EXEC [dbo].[TheCompany_0_ARIBADataLoad_03_SupplierData] - run first since used in 01?*/


	/* Optional: exec TheCompany_3SATNIGHT_ProductGroupUpload_ARIBA_Description again (is executed every Saturday)
		/* runs on T_TheCompany_AribaDump, populate product ids etc. that are then concatenated */ 
		*/

	end
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_0_ARIBADataLoad_00_SupplierData]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_0_ARIBADataLoad_00_SupplierData]

as

begin

/*
	insert into [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields] 
	(
	 [SupID_SAP]
      ,[SupName_SAP]
      ,[SupRegStatus]
      ,[SupCountry]
      ,[SupApprovalStatus]
      ,[SupApprCommodity_BLANK]
      ,[Sup_LettersNumbersOnly_UPPER]
      ,[Sup_LettersNumbersOnly_UPPER_LEN]
      ,[Sup_Name_SAP_LEN]
      ,[Sup_Name_LEN_VARIANCE]
      ,[Sup_Name_ValidString_FLAG]
      ,[Sup_COMPANYID]
	  )
	  select
	   [VendorSAP_ID]
      ,[Name1] /* as [SupName_SAP] */
      ,NULL as [SupRegStatus]
      ,[Country2LetterCode] as [SupCountry]
      ,NULL as [SupApprovalStatus]
      ,NULL as [SupApprCommodity_BLANK]
      ,NULL as [Sup_LettersNumbersOnly_UPPER]
      ,NULL as [Sup_LettersNumbersOnly_UPPER_LEN]
      ,NULL as [Sup_Name_SAP_LEN]
      ,NULL as [Sup_Name_LEN_VARIANCE]
      ,NULL as [Sup_Name_ValidString_FLAG]
      ,NULL as [Sup_COMPANYID]
	  from T_TheCompany_Ariba_SAPID_LieferantendatenChristophMatt_2021_02_22 l 
		left join [dbo].[T_TheCompany_TCountries] c on l.[Country2LetterCode] = c.[CtyCode2Letter]
		WHERE vendorsap_id is not null and Name1 is not null
*/

	alter table [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country]
	alter column [SupName_SAP] varchar(150)

	update [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields]
	set [Sup_LettersNumbersOnly_UPPER] = dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([SupName_SAP]) 
	/* chinese characters are stripped */
/* vba modules db Public Function fctString_MakeAlphaNumeric(inputStr As String, blnNumbers As Boolean, blnSpace As Boolean) */

/* LEN */
	update [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields]
	set [Sup_Name_SAP_LEN] = LEN([SupName_SAP])
	/* where [Sup_LettersNumbersOnly_UPPER] is not null */

	update [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields]
	set [Sup_LettersNumbersOnly_UPPER_LEN] = LEN([Sup_LettersNumbersOnly_UPPER])
	/* where [Sup_LettersNumbersOnly_UPPER] is not null */

	update [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields]
	set [Sup_Name_LEN_VARIANCE] = [Sup_Name_SAP_LEN] - [Sup_LettersNumbersOnly_UPPER_LEN]
	/* where [Sup_LettersNumbersOnly_UPPER] is not null */

/* VALID ENTRY OR NOT */

	update [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields]
	set [Sup_Name_ValidString_FLAG] = 0 /* no filter to catch NULL as well */
	/* WHERE 
		[dbo].[TheCompany_CountQuestionMarkCharChineseEtc_Varchar255] ([SupName_SAP])>1 */
	/* select * from 
	[dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields] where [Sup_Name_ValidString_FLAG] is null */

	update [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields]
	set [Sup_Name_ValidString_FLAG] = 1
	WHERE 
		[dbo].[TheCompany_CountQuestionMarkCharChineseEtc_Varchar255] ([SupName_SAP]) = 0 /* no special char found */
		and [Sup_Name_SAP_LEN]  >3 /* must have more than 3 char */


END
/*
select 
[dbo].[TheCompany_CountQuestionMarkCharChineseEtc_Varchar255] ([SupName_SAP]) as tst
, *
from [T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields]
where supid_sap = 'ACM_92517841'*/
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_0_ARIBADataLoad_01]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TheCompany_0_ARIBADataLoad_01]

as
/* in Ariba, run TheCompany Contract Report 1960-2015 All Fields */
/* import T_TheCompany_AribaDump_Raw from .csv as text file through access upload into sql server, with formatted fields RAW_FORMATTED */
	
	/* Products: runs every Saturday, and run after import, takes 2 hrs */

	begin

	/* back up old tbl */
	/*
	select * into [dbo].[T_TheCompany_AribaDump_BAK]
	from T_TheCompany_AribaDump /* [dbo].[T_TheCompany_Ariba_Dump_Raw] */

	rename old raw dump
	/* rename T_TheCompany_Ariba_Dump_Raw_FormattedFields to T_TheCompany_Ariba_Dump_Raw */
	*/


		alter table [dbo].[T_TheCompany_Ariba_Dump_Raw]
		alter column [Description] nvarchar(1000) /* ntext does not work in view */

		alter table [dbo].[T_TheCompany_Ariba_Dump_Raw]
		add [AllSupplier] varchar(255) /* for TheVendor legacy contracts , since those are all 'legacy suppliers' */

		alter table [dbo].[T_TheCompany_Ariba_Dump_Raw]
		add [CompanyCountry] varchar(25) /* for TheVendor legacy contracts , since those are all 'legacy suppliers' */

		alter table [dbo].[T_TheCompany_Ariba_Dump_Raw]
		add [CompanyCountryID] bigint /* for TheVendor legacy contracts , since those are all 'legacy suppliers' */
		
		alter table [dbo].[T_TheCompany_Ariba_Dump_Raw]
	    add [AffectedParties_LETTERSNUMBERSONLY] varchar(150)

		alter table [dbo].[T_TheCompany_Ariba_Dump_Raw]
	    add [CompanySAPID] varchar(25)
		
		/* alter table T_TheCompany_Ariba_Dump_Raw
		add [Affected Parties - Common Supplier LETTERS ONLY] varchar(150) /* strip special characters */

		alter table T_TheCompany_Ariba_Dump_Raw
		add [Company_LettersNumbersSpacesOnly] varchar(255) /* strip special characters */

		alter table T_TheCompany_Ariba_Dump_Raw
		add [Affected Parties - Common Supplier First Word] varchar(255) /* strip special characters, but big enough for pricewaterhousecoopers */
		
		alter table T_TheCompany_Ariba_Dump_Raw		
		add [Company_LettersNumbersOnly_NumSpacesWords] int */

/*		CREATE UNIQUE CLUSTERED INDEX T_TheCompany_Ariba_Dump_Raw_ProjectIDContractInternalID /* added unique oct-20 */
		ON T_TheCompany_Ariba_Dump_Raw ([Project - Project Id])
		FAILS because raw table is not yet flattened!
	select [Project - Project Id] , COUNT(*) from T_TheCompany_Ariba_Dump_Raw
	group by [Project - Project Id]

*/

END

GO
/****** Object:  StoredProcedure [dbo].[TheCompany_0_ARIBADataLoad_02]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.5598)
    Source Database Engine Edition : Microsoft SQL Server Standard Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/

CREATE PROCEDURE [dbo].[TheCompany_0_ARIBADataLoad_02]

as

begin
	/* alter table [dbo].[T_TheCompany_Ariba_Dump_Raw]
	alter column [Contract ID] nvarchar(30)

	alter table [dbo].[T_TheCompany_Ariba_Dump_Raw]
	alter column [Project - Project Id] nvarchar(30) */



	/* if migrated TheVendor contract, replace 'unclassified' supplier with supplier name */
	update  T_TheCompany_Ariba_Dump_Raw
	set [AllSupplier] = (case when ([Affected Parties - Common Supplier] like '%legacy%supplier%' 
						OR [Affected Parties - Common Supplier] like '%nclassifie%'
						) /* e.g. TheVendor contracts */ 				
				then (select CompanyList from T_TheCompany_ALL where number = rtrim(substring([Contract id],6,25)))
				else [Affected Parties - Common Supplier] end)

	/* other contracts with 'unclassified' - take project description */
	update  T_TheCompany_Ariba_Dump_Raw
	set [AllSupplier] = RTRIM(ltrim([Project - Project Name]))
	where [Affected Parties - Common Supplier] like '%BOS_LegacySupplie%'

	/* description should not be blank even if project name already used to get vendor name */
	update  T_TheCompany_Ariba_Dump_Raw
	set [Description] =  RTRIM(ltrim([Project - Project Name]))
	WHERE [Description] is null

/* supplier country */
/* now in part 1		alter table [dbo].[T_TheCompany_Ariba_Dump_Raw]
		add [CompanyCountry] varchar(25) /* for TheVendor legacy contracts , since those are all 'legacy suppliers' */
	*/
	/*	alter table [dbo].[T_TheCompany_Ariba_Dump_Raw]
		add [CompanyCountryID] bigint /* for TheVendor legacy contracts , since those are all 'legacy suppliers' */
*/
	alter table [dbo].[T_TheCompany_Ariba_Dump_Raw]
	alter column [Affected Parties - Common Supplier] varchar(150)


	

	update [dbo].[T_TheCompany_Ariba_Dump_Raw]
	set [AffectedParties_LETTERSNUMBERSONLY] 
		= dbo.TheCompany_RemoveNonAlphaNonNumericCharacters ([Affected Parties - Common Supplier])

	/* moved	update d
		set d.[CompanyCountry] = s.[SupCountry]
		/*,  d.[CompanyCountryID] */
		from [dbo].[T_TheCompany_Ariba_Dump_Raw] d 
			inner join [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields] s 
			on d.[AffectedParties_LETTERSNUMBERSONLY] = /*like '%'+ */ s.[Sup_LettersNumbersOnly_UPPER] /* + '%' */
		WHERE d.companycountry is null
		*/
		/* Ariba - only needed after new data load */


/* RAW FLAT */
	/* run time 12 seconds, does not contain any supplier first word etc. */
	if OBJECT_ID('T_TheCompany_Ariba_Dump_Raw_FLAT') is not null 
	drop table [dbo].[T_TheCompany_Ariba_Dump_Raw_FLAT]

	select * into [dbo].[T_TheCompany_Ariba_Dump_Raw_FLAT]
	from [dbo].[V_TheCompany_Ariba_Dump_Raw_FLAT] /* [dbo].[T_TheCompany_Ariba_Dump_Raw] */
	order by ContractInternalID asc

	CREATE UNIQUE CLUSTERED INDEX T_TheCompany_Ariba_Dump_Raw_Flat_ContractInternalID
	ON T_TheCompany_Ariba_Dump_Raw_FLAT (CONTRACTINTERNALID)

	/* make sure that nvarchar(max) is converted to 255 max len */
		alter table T_TheCompany_Ariba_Dump_Raw_FLAT
		alter column [Effective Date - Date] date

		alter table T_TheCompany_Ariba_Dump_Raw_FLAT
		alter column [Begin Date] date

		alter table T_TheCompany_Ariba_Dump_Raw_FLAT /* fails if 'unclassified etc.' left in */
		alter column [End Date - Date] date

		alter table T_TheCompany_Ariba_Dump_Raw_FLAT
		alter column [Due Date - Date] date

		alter table T_TheCompany_Ariba_Dump_Raw_FLAT  /* fails if 'unclassified etc.' left in */
		alter column [Expiration Date - Date] date

	update T_TheCompany_Ariba_Dump_Raw_FLAT
		set [Expiration Date - Date] = null
	WHERE 
		[state] = 'Active' /* 'term type' perpetual overrides expiration date */
		and ([Expiration Date - Date] < [datetablerefreshed])

		/* long names */
		alter table T_TheCompany_Ariba_Dump_Raw_FLAT  /* fails if 'unclassified etc.' left in */
		alter column [Contract Signatory - User Concat] nvarchar(255)

		alter table T_TheCompany_Ariba_Dump_Raw_FLAT  /* fails if 'unclassified etc.' left in */
		alter column [Owner Name Concat] nvarchar(255)

		alter table T_TheCompany_Ariba_Dump_Raw_FLAT  /* fails if 'unclassified etc.' left in */
		alter column [Business Owner - User] nvarchar(110) /* max len 89 failed apr at 100 increase to 150 */

		alter table T_TheCompany_Ariba_Dump_Raw_FLAT  /* fails if 'unclassified etc.' left in */
		alter column [Region - Region Concat] nvarchar(255)					

		alter table T_TheCompany_Ariba_Dump_Raw_FLAT  /* fails if 'unclassified etc.' left in */
		alter column [Commodity - Commodity Concat] nvarchar(255)		

		/*alter table T_TheCompany_Ariba_Dump_Raw_FLAT  /* fails if 'unclassified etc.' left in */
		alter column [Contracting Legal Entity Concat] nvarchar(255)	*/
		
		alter table T_TheCompany_Ariba_Dump_Raw_FLAT  
		alter column [Affected Parties - Common Supplier Concat] nvarchar(255)	/* max len 178 */						

		alter table T_TheCompany_Ariba_Dump_Raw_FLAT 
		alter column [Affected Parties - Common Supplier ID Concat] nvarchar(255) /* max len 75 */		
		
		alter table T_TheCompany_Ariba_Dump_Raw_FLAT 
		alter column [Regional Department] nvarchar(255) /* max len 75 */		
		
		alter table T_TheCompany_Ariba_Dump_Raw_FLAT 
		alter column [Organization - Department (L1)] nvarchar(255) /* max len 75 */		
		

		/* select max(len([Business Owner - User])) from T_TheCompany_Ariba_Dump_Raw_FLAT */
			alter table T_TheCompany_Ariba_Dump_Raw_FLAT
			add [All Products] nvarchar(1000)	/* no permission ? */

			drop table [dbo].[T_TheCompany_AribaDump]

	select * into [dbo].[T_TheCompany_AribaDump]
	from [dbo].[T_TheCompany_Ariba_Dump_Raw_FLAT] /* [dbo].[T_TheCompany_Ariba_Dump_Raw] */
/* run time 1:09 min with just products field pulled by id  */

/* check match level, if to run quickly choose >5 char product name length, or 2 if more time */
	if OBJECT_ID('T_TheCompany_Ariba_Dump_Raw_FLAT_AllProducts') is not null 
	drop table [dbo].[T_TheCompany_Ariba_Dump_Raw_FLAT_AllProducts]

	select * into [dbo].[T_TheCompany_Ariba_Dump_Raw_FLAT_AllProducts]
	from [dbo].[V_TheCompany_Ariba_Dump_Raw_FLAT_AllProducts] /* [dbo].[T_TheCompany_Ariba_Dump_Raw] */

	update [dbo].[T_TheCompany_Ariba_Dump_Raw_FLAT_AllProducts] 
		set [All Products] = LTRIM(RTRIM([All Products])) /* strip off spaces */

	update f
	set f.[All Products] = p.[All Products] 
	from [T_TheCompany_AribaDump] f 
		inner join T_TheCompany_Ariba_Dump_Raw_FLAT_AllProducts p 
		on f.contractinternalid = p.contractinternalid

		/* tag table contract ids */
		update t
			set t.contractinternalid = a.contractinternalid
			from  [dbo].[T_TheCompany_Ariba_TTAG_IN_ContractInternalID] t
			inner join T_TheCompany_AribaDump a on t.contractnumber = a.contractnumber



	/* delete staging tables , Oct-2020 */

		if OBJECT_ID('T_TheCompany_Ariba_Dump_Raw_FormattedFields') is not null 
			drop table T_TheCompany_Ariba_Dump_Raw_FormattedFields /* and JPS */

		if OBJECT_ID('T_TheCompany_Ariba_Dump_Raw_FLAT') is not null 
			drop table [dbo].[T_TheCompany_Ariba_Dump_Raw_FLAT]

		if OBJECT_ID('T_TheCompany_Ariba_Dump_Raw_Flat_AllProducts') is not null 
			drop table [dbo].[T_TheCompany_Ariba_Dump_Raw_Flat_AllProducts]

	/* Vcompany */
	if OBJECT_ID('T_TheCompany_ContractData_ARB_1VCOMPANY') is not null 
		drop table T_TheCompany_ContractData_ARB_1VCOMPANY

		select * into T_TheCompany_ContractData_ARB_1VCOMPANY
		FROM V_TheCompany_ContractData_ARB_1VCOMPANY

END

GO
/****** Object:  StoredProcedure [dbo].[TheCompany_0_ARIBADataLoad_03_SupplierData]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TheCompany_0_ARIBADataLoad_03_SupplierData]

as

begin

/* set [AffectedParties_LETTERSNUMBERSONLY] in 02 */

/* [CompanySAPID] */

			update d
			set d.[CompanySAPID] = s.[SupID_SAP]
			/*,  d.[CompanyCountryID] */
			from [dbo].[T_TheCompany_Ariba_Dump_Raw] d 
				inner join [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields] s 
				on d.[AffectedParties_LETTERSNUMBERSONLY] = s.[Sup_LettersNumbersOnly_UPPER] 
			WHERE 
				[Sup_Name_ValidString_FLAG] = 1
				and d.[CompanySAPID] is null
				and s.SupID_SAP is not null
				and [Sup_Name_SAP_LEN] > 3 /* at least 3 char */

/* update TCOMPANY */
/* daily proc 
			update c
			set c.[externalnumber] = s.[SupID_SAP]
			/*,  d.[CompanyCountryID] */
			from tcompany c
				inner join [dbo].[t_TheCompany_vcompany] c2
					on c.COMPANYID = c2.companyid_LN 
				inner join [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields] s 
				on c2.Company_LettersNumbersOnly_UPPER = s.[Sup_LettersNumbersOnly_UPPER] 
			WHERE 
				c.[externalnumber] is null
				and s.SupID_SAP is not null
				and s.[Sup_Name_ValidString_FLAG]  = 1
				and c2.Company_LEN >3
				and s.[Sup_Name_SAP_LEN] > 3 /* at least 3 char */
*/
/* SAP Country */

		update d
		set d.[CompanyCountry] = s.[SupCountry]
		/*,  d.[CompanyCountryID] */
		from [dbo].[T_TheCompany_Ariba_Dump_Raw] d 
			inner join [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields] s 
			on d.[CompanySAPID] = s.SupID_SAP
		WHERE d.companycountry is null

		update  s2
			set s2.[SupCountry]  = s1.[SupCountry]		
		from [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields] s1 
				inner join /*[dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country]*/ T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields s2
				on s1.SupID_SAP = s2.SupID_SAP
		WHERE 
			s2.SupCountry is null
			and s1.SupCountry is not null

		if OBJECT_ID('T_TheCompany_Ariba_Suppliers_SAPID_ValidMatchedCompanies') is not null 
		drop table T_TheCompany_Ariba_Suppliers_SAPID_ValidMatchedCompanies

			select *
			into T_TheCompany_Ariba_Suppliers_SAPID_ValidMatchedCompanies
			from [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields]
			where [Sup_Name_ValidString_FLAG] = 1
			and Sup_COMPANYID is not null /* would create dupes */

		CREATE UNIQUE CLUSTERED INDEX T_TheCompany_Ariba_Suppliers_SAPID_ValidMatchedCompanies_COMPANYID
		ON T_TheCompany_Ariba_Suppliers_SAPID_ValidMatchedCompanies (Sup_COMPANYID)

END
/*
select sup_companyid , count(*)
from [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields]
group by sup_companyid
having count(*) >1
*/
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_0_ARIBADataLoad_Delta]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[TheCompany_0_ARIBADataLoad_Delta]

as
/* in Ariba, run TheCompany Contract Report 1960-2015 All Fields */
/* import T_TheCompany_AribaDump_Raw from .csv as text file through access upload into sql server, with formatted fields RAW_FORMATTED */
	
	/* Products: runs every Saturday, and run after import, takes 2 hrs */
	/*
	alter table [dbo].[T_TheCompany_Ariba_Dump_Raw_FormattedFields_Delta]
	alter column [Description] nvarchar(1000) /* ntext does not work in view */

		alter table T_TheCompany_Ariba_Dump_Raw_FormattedFields_Delta
	add [AllSupplier] varchar(255) /* for TheVendor legacy contracts , since those are all 'legacy suppliers' */

		alter table T_TheCompany_Ariba_Dump_Raw_FormattedFields_Delta
	add [Affected Parties - Common Supplier LETTERS ONLY] varchar(150) /* strip special characters */
		alter table T_TheCompany_Ariba_Dump_Raw_FormattedFields_Delta
	add [Company_LettersNumbersSpacesOnly] varchar(255) /* strip special characters */
			alter table T_TheCompany_Ariba_Dump_Raw_FormattedFields_Delta
		add [Company_LettersNumbersOnly_NumSpacesWords] int
		alter table T_TheCompany_Ariba_Dump_Raw_FormattedFields_Delta
	add [Affected Parties - Common Supplier First Word] varchar(255) /* strip special characters, but big enough for pricewaterhousecoopers */

	*/
	update T_TheCompany_Ariba_Dump_Raw_FormattedFields_Delta
	set [Affected Parties - Common Supplier] = ltrim(rtrim([Affected Parties - Common Supplier]))
	WHERE [Affected Parties - Common Supplier] is not null


	/* alter table T_TheCompany_Ariba_Dump_Raw
	add [Affected Parties - Common Supplier LETTERS ONLY] varchar(255) /* for TheVendor legacy contracts , since those are all 'legacy suppliers' */
	*/

	/* if migrated TheVendor contract, replace 'unclassified' supplier with supplier name */
	update  T_TheCompany_Ariba_Dump_Raw_FormattedFields_Delta
	set [AllSupplier] = (case when ([Affected Parties - Common Supplier] like '%legacy%supplier%' 
						OR [Affected Parties - Common Supplier] like '%nclassifie%'
						) /* e.g. TheVendor contracts */ 				
				then (select CompanyList from T_TheCompany_ALL where number = rtrim(substring([Contract id],6,25)))
				else [Affected Parties - Common Supplier] end)

	/* other contracts with 'unclassified' - take project description */
	update  T_TheCompany_Ariba_Dump_Raw_FormattedFields_Delta
	set [AllSupplier] = RTRIM(ltrim([Project - Project Name]))
	where [Affected Parties - Common Supplier] like '%BOS_LegacySupplie%'
	/* [AllSupplier] is null
	AND */ 

		/* select * from  T_TheCompany_Ariba_Dump_Raw
		where [Affected Parties - Common Supplier] = 'TBOS_LegacySupplier' */


	update  T_TheCompany_Ariba_Dump_Raw_FormattedFields_Delta
		set [Affected Parties - Common Supplier LETTERS ONLY] = NULL
	WHERE [Affected Parties - Common Supplier LETTERS ONLY] IS NOT NULL

	update  T_TheCompany_Ariba_Dump_Raw_FormattedFields_Delta
		set [Affected Parties - Common Supplier LETTERS ONLY] = 
		dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([AllSupplier])


	update  T_TheCompany_Ariba_Dump_Raw_FormattedFields_Delta
		set [Company_LettersNumbersSpacesOnly] = 
		dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([AllSupplier])


	update T_TheCompany_Ariba_Dump_Raw_FormattedFields_Delta
		set [Affected Parties - Common Supplier First Word] = 
		SUBSTRING([Company_LettersNumbersSpacesOnly],1,(CHARINDEX(' ',[Company_LettersNumbersSpacesOnly] + ' ')-1)) 
		WHERE [AllSupplier] is not null
		/* and LEN(dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(SUBSTRING([AllSupplier],1,(CHARINDEX(' ',[AllSupplier] + ' ')-1)) )
		) >3 /* was 6 */ */
		/* otherwise too much junk */


	update  T_TheCompany_Ariba_Dump_Raw_FormattedFields_Delta
	set [Company_LettersNumbersOnly_NumSpacesWords]
	= LEN(replace(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([AllSupplier]),'  ',' '))
		-LEN(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([AllSupplier])) 
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_0_JPS_DataLoad]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[TheCompany_0_JPS_DataLoad]

as

BEGIN

/* T_TheCompany_ContractData_JP_Sunrise_ExecutedAgreements */
/* company country added */

	drop table T_TheCompany_ContractData_JPS_1VCOMPANY

	select * into T_TheCompany_ContractData_JPS_1VCOMPANY
	FROM [dbo].[V_TheCompany_ContractData_JPS_1VCOMPANY]

	/* Countries */

		update j
		set j.companycountry = c.country
		, j.CompanyCountryID = c.countryid
	from
		T_TheCompany_ContractData_JP_Sunrise_ExecutedAgreements j
			inner join tcountry c on j.[Party(master)] like '%' + c.country + '%'

	update j
		set j.companycountry = 'United States'
		, j.CompanyCountryID = 232
	from
		T_TheCompany_ContractData_JP_Sunrise_ExecutedAgreements j
			where j.[Party(master)] like '%' + '(USA' + '%'
			/* more transform code in access ? Ariba db */
END



  

			/*copy corp DS table TCountries */
/*
			select * from T_TheCompany_ContractData_JP_Sunrise_ExecutedAgreements
			where companycountry is null */
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_0_LNC_DataLoad]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_0_LNC_DataLoad]

as

BEGIN

		delete from T_TheCompany_KWS_0_Data_LINC 
			where [reference] in 
			(select [reference] from T_TheCompany_KWS_0_Data_LINC_RAW)

/* RAW */
		INSERT INTO T_TheCompany_KWS_0_Data_LINC 
		 ([Reference]
			  ,[Status]
			  ,[Contract type]
			  ,[Amendment no]
			  ,[Contract title]
			  ,[Outside party]
			  ,[TheCompany entity/first party]
			  ,[Start date]
			  ,[End date]
			  ,[Description]
			  ,[Currency]
			  ,[Total or max value]
			  ,[Business unit]
			  ,[Approval only]
			  ,[Material contract]
			  ,[Compound/product]
			  ,[Study]
			  ,[Created]
			  ,[External reference]
			  ,[Updated]
		 ,[DateTableRefreshed]
		) 

		SELECT 
		[Reference]
			  ,[Status]
			  ,[Contract type]
			  ,[Amendment no]
			  ,[Contract title]
			  ,[Outside party]
			  ,[TheCompany entity/first party]
			  ,[Start date]
			  ,[End date]
			  ,[Description]
			  ,[Currency]
			  ,[Total or max value]
			  ,[Business unit]
			  ,[Approval only]
			  ,[Material contract]
			  ,[Compound/product]
			  ,[Study]
			  ,[Created]
			  ,[External reference]
			  ,[Updated]
			  ,GETDATE()
		FROM 
			T_TheCompany_KWS_0_Data_LINC_RAW r
		where r.[reference] not in 
			(select [reference] from T_TheCompany_KWS_0_Data_LINC)

	/* select *  into T_TheCompany_KWS_0_Data_LINC_bak from T_TheCompany_KWS_0_Data_LINC */
/* FINAL */
/*
	alter table [dbo].[T_TheCompany_KWS_0_Data_LINC]
	alter column [Description] nvarchar(1500) 

	alter table [dbo].[T_TheCompany_KWS_0_Data_LINC]
	add DateTableRefreshed datetime */

	update [dbo].[T_TheCompany_KWS_0_Data_LINC]
	set DateTableRefreshed = Getdate() /* '20-Aug-2020' */ where DateTableRefreshed is null

	update T_TheCompany_KWS_0_Data_LINC
	set [outside party] = ltrim([outside party]) /* spaces in CK dump for Nick */

	/* Final Table */
		drop table T_TheCompany_ContractData_LNC_1VCOMPANY

			select * into T_TheCompany_ContractData_LNC_1VCOMPANY
			FROM V_TheCompany_ContractData_LNC_1VCOMPANY
/*   truncate table [dbo].[T_TheCompany_KWS_0_Data_LINC_RAW] */

END

GO
/****** Object:  StoredProcedure [dbo].[TheCompany_01_DWH_DataLoad_DRAFT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_01_DWH_DataLoad_DRAFT]

as

	begin
	/* run time oct-20: */

	Drop table T_TheCompany_KWS_DWH_AllSystems_Union

	SELECT * INTO T_TheCompany_KWS_DWH_AllSystems_Union
	FROM V_TheCompany_KWS_DWH_AllSystems_Union

	/* index makes no sense on contractid since ariba has char ID */
	/* CREATE UNIQUE CLUSTERED INDEX T_TheCompany_KWS_DWH_AllSystems_Union_ContractID
	ON T_TheCompany_KWS_DWH_AllSystems_Union (CONTRACTID, SourceSystem) */ 


/* 
bulk insert T_TheCompany_KWSR_1_CNT_ARB
FROM 'M:\'
WITH (FORMAT = 'CSV') */

/* NO Permission for user TheVendor 
BULK INSERT T_TheCompany_Ariba_Dump_Raw_FormattedFields_Staging
FROM '\\nycomed.local\shares\aa-fsa-data-legal-transfer\ECM_Ariba\Data_Dump_Ariba\AribaDataDump.xlsx' --This is CSV file
WITH ( FIELDTERMINATOR =',',rowterminator = '\n',FIRSTROW = 1 )
*/
END

GO
/****** Object:  StoredProcedure [dbo].[TheCompany_1DAILY_03DataLoad_KWS]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_1DAILY_03DataLoad_KWS]

as

BEGIN

	/* Key Word Search Items */

		/* T_TheCompany_ALL_VIEW */
			drop table T_TheCompany_KWS_0_TheVendorView_CNT
	
			select * into T_TheCompany_KWS_0_TheVendorView_CNT
			from [V_TheCompany_KWS_0_TheVendorView_CNT]

			CREATE UNIQUE CLUSTERED INDEX T_TheCompany_KWS_0_TheVendorView_CNT_CONTRACTID
			ON T_TheCompany_KWS_0_TheVendorView_CNT(CONTRACTID)

		/* PRODUCT */
			drop table T_TheCompany_TPRODUCTGROUP
	
				select * into T_TheCompany_TPRODUCTGROUP
				from [dbo].[V_TheCompany_VPRODUCT]

				CREATE UNIQUE CLUSTERED INDEX T_TheCompany_TPRODUCTGROUP_PRODUCTGROUPID
				ON T_TheCompany_TPRODUCTGROUP (PRODUCTGROUPID) 

		/* COMPANY - also run daily! */

			drop table T_TheCompany_VCOMPANY

				select * into T_TheCompany_VCompany
				from [dbo].[V_TheCompany_VCOMPANY]

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_1DAILY_0DataLoad]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_1DAILY_0DataLoad]

as

print 'this'
/*
/* t_TheCompany_Hierarchy run time on 6-feb-19 13:00 was 2 sec
, this must be run before T_TheCompany_ALL because the hierarchy is used in V_TheCompany_ALL */

	truncate table t_TheCompany_Hierarchy
	
		insert into T_TheCompany_Hierarchy select *
		from [dbo].[V_TheCompany_Hierarchy_MakeTable]	

		/* ONLY NEEDED AFTER INSERT CREATE UNIQUE CLUSTERED INDEX T_TheCompany_Hierarchy_DEPARTMENTID
		ON T_TheCompany_Hierarchy (DEPARTMENTID) */

		/* COMPANY - also run in KWS procedure */

/* update TCOMPANY run time 13 sec 23-feb */
	if OBJECT_ID('T_TheCompany_VCOMPANY') is not null 
			drop table T_TheCompany_VCOMPANY			

			select * into T_TheCompany_VCompany
			from [dbo].[V_TheCompany_VCOMPANY]

			CREATE UNIQUE CLUSTERED INDEX T_TheCompany_VCompany_COMPANYID
			ON T_TheCompany_VCompany (COMPANYID_ln)

			update c
			set c.[externalnumber] = s.[SupID_SAP]
			/*,  d.[CompanyCountryID] */
			from tcompany c
				inner join [dbo].[t_TheCompany_vcompany] c2
					on c.COMPANYID = c2.companyid_LN 
				inner join [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields] s 
				on c2.Company_LettersNumbersOnly_UPPER = s.[Sup_LettersNumbersOnly_UPPER] 
			WHERE 
				c.[externalnumber] is null
				and s.SupID_SAP is not null
				and s.[Sup_Name_ValidString_FLAG]  = 1
				and c2.Company_LEN >3
				and s.[Sup_Name_SAP_LEN] > 3 /* at least 3 char */
/* second time */
	if OBJECT_ID('T_TheCompany_VCOMPANY') is not null 
			drop table T_TheCompany_VCOMPANY	

			select * into T_TheCompany_VCompany
			from [dbo].[V_TheCompany_VCOMPANY]

		CREATE UNIQUE CLUSTERED INDEX T_TheCompany_VCompany_COMPANYID
		ON T_TheCompany_VCompany (COMPANYID_ln)

/* Tenderer FLAT */
	if OBJECT_ID('T_TheCompany_TTENDERER_FLAT') is not null 
			drop table T_TheCompany_TTENDERER_FLAT

			select * into T_TheCompany_TTENDERER_FLAT
			FROM V_TheCompany_TTENDERER_FLAT

			CREATE UNIQUE CLUSTERED INDEX T_TheCompany_TTENDERER_FLAT_CONTRACTID
			ON T_TheCompany_TTENDERER_FLAT (CONTRACTID)

/* Dptroles FLAT - run time 4:41 */
	if OBJECT_ID('T_TheCompany_VCONTRACT_DPTROLES_FLAT') is not null 
			drop table T_TheCompany_VCONTRACT_DPTROLES_FLAT

			select * into T_TheCompany_VCONTRACT_DPTROLES_FLAT
			FROM [dbo].[V_TheCompany_VCONTRACT_DPTROLES_FLAT] 

			CREATE UNIQUE CLUSTERED INDEX T_TheCompany_VCONTRACT_DPTROLES_FLAT_DPT_CONTRACTID
			ON T_TheCompany_VCONTRACT_DPTROLES_FLAT (DPT_CONTRACTID)

			update T_TheCompany_VCONTRACT_DPTROLES_FLAT 
			set Dpt_ContractOwnerDpt_ID	= 203688 /* GGC sysadmin */
			where  Dpt_ContractOwnerDpt_ID IS NULL /* for hierarchy outer join */

			/* NO records 24-feb - if exists active primary entity then replace outdated entity 
			update  T_TheCompany_VCONTRACT_DPTROLES_FLAT 
			set [InternalPartners_ACTIVE_MAX_DPTID] 
			select * from T_TheCompany_VCONTRACT_DPTROLES_FLAT 
			where [InternalPartners_ACTIVE_MAX_DPTID] in 
				(select departmentid from tdepartment where mik_valid = 0) 
			and [InternalPartners_ACTIVE_MAX_DPTID] in 
				(select departmentid from tdepartment where mik_valid = 1)*/

/* V_TheCompany_VPERSONROLE_IN_OBJECT */
	if OBJECT_ID('T_TheCompany_VPERSONROLE_IN_OBJECT ') is not null 
			drop table T_TheCompany_VPERSONROLE_IN_OBJECT 

			select * into T_TheCompany_VPERSONROLE_IN_OBJECT 
			FROM [dbo].[V_TheCompany_VPERSONROLE_IN_OBJECT ] 

			CREATE INDEX T_TheCompany_VPERSONROLE_IN_OBJECT_Roleid_Cat2Letter
			ON T_TheCompany_VPERSONROLE_IN_OBJECT (Roleid_Cat2Letter)

			CREATE INDEX T_TheCompany_VPERSONROLE_IN_OBJECT_CONTRACTID
			ON T_TheCompany_VPERSONROLE_IN_OBJECT (CONTRACTID)

		/*	update T_TheCompany_VPERSONROLE_IN_OBJECT 
			set userid /* GGC sysadmin */
			where  Dpt_ContractOwnerDpt_ID IS NULL /* for hierarchy outer join */*/
/* [V_TheCompany_VCONTRACT_PERSONROLES_FLAT]  */
	if OBJECT_ID('T_TheCompany_VCONTRACT_PERSONROLES_FLAT') is not null 
			drop table T_TheCompany_VCONTRACT_PERSONROLES_FLAT

			select * into T_TheCompany_VCONTRACT_PERSONROLES_FLAT
			FROM [dbo].[V_TheCompany_VCONTRACT_PERSONROLES_FLAT] 

			CREATE INDEX T_TheCompany_VCONTRACT_PERSONROLES_FLAT_Prs_CONTRACTID
			ON T_TheCompany_VCONTRACT_PERSONROLES_FLAT (Prs_CONTRACTID)

/* T_TheCompany_ALL run time 21-Nov-18 was 9 minutes 
22-feb-21 - run time 2 min
*/
	if OBJECT_ID('T_TheCompany_ALL') is not null 
		drop table T_TheCompany_ALL

		select * into T_TheCompany_ALL 
		from [dbo].[V_TheCompany_ALL] 
		order by CONTRACTID asc

		CREATE UNIQUE CLUSTERED INDEX T_TheCompany_ALL_CONTRACTID
		ON T_TheCompany_ALL (CONTRACTID)

/* xt table run time 23-Feb 13s for 36k records*/

	if OBJECT_ID('T_TheCompany_ALL_Xt') is not null 
		drop table T_TheCompany_ALL_Xt

		select * into T_TheCompany_ALL_Xt
		from [dbo].[V_T_TheCompany_ALL_Xt] 
		order by CONTRACTID asc

		CREATE UNIQUE CLUSTERED INDEX T_TheCompany_ALL_Xt_CONTRACTID
		ON T_TheCompany_ALL_Xt (CONTRACTID)
	
/* T_TheCompany_ALL */

	drop table T_TheCompany_tdepartmentrole_in_object_GroupedByDptID

	select * into T_TheCompany_tdepartmentrole_in_object_GroupedByDptID 
	from [dbo].[V_TheCompany_tdepartmentrole_in_object_GroupedByDptID] 
	order by dpt_objectid asc

	CREATE INDEX T_TheCompany_drio_GByDptIDCONTRACTID
	ON T_TheCompany_tdepartmentrole_in_object_GroupedByDptID (Dpt_ObjectID)


*/

	if OBJECT_ID('T_TheCompany_VPERSONROLE_IN_OBJECT ') is not null 
			drop table T_TheCompany_LNC_GoldStandard_Documents

			select * into T_TheCompany_LNC_GoldStandard_Documents
			FROM [dbo].[V_TheCompany_LNC_GoldStandard_Documents] 

		CREATE INDEX T_TheCompany_LNC_GoldStandard_Documents_DOCUMENTID
		ON T_TheCompany_LNC_GoldStandard_Documents (DOCUMENTID)
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_1DAILY_0Edit_DataLoad]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TheCompany_1DAILY_0Edit_DataLoad]

as

BEGIN

/* EDIT Report */

/* Duplicate documents - Signed Contracts Only */
/* normal run time 00:10 */

	drop table T_TheCompany_Docx
	
	select * into T_TheCompany_Docx 
	from [dbo].[V_TheCompany_DocxValidSignedNotRegForm] 
	order by [DescRemNonAlphaHashbSHA1] asc

	CREATE INDEX T_TheCompany_Docx_OBJECTID
	ON T_TheCompany_Docx(OBJECTID) 
	
/* Duplicate Contracts */
/* normal run time 00:27 */

	/* [V_TheCompany_Duplicates] is base duplicate detection query,
	 the view [V_TheCompany_Duplicates_Final] includes both min and max to show them side by side in list 
	 while V_TheCompany_EDIT_ITEMS only includes the min dupe number so that there is only one item showing
	 both duplicate #s */

	Drop table T_TheCompany_Duplicates_Final

	select * into T_TheCompany_Duplicates_Final 
	from [dbo].[V_TheCompany_Duplicates_Final]
	order by CONTRACTID_UNIQUE

	CREATE INDEX T_TheCompany_Duplicates_Final_CONTRACTID_DUPE
	ON T_TheCompany_Duplicates_Final (CONTRACTID_UNIQUE)
	
	CREATE UNIQUE CLUSTERED INDEX T_TheCompany_Duplicates_Final_CONTRACTID_UNIQUE
	ON T_TheCompany_Duplicates_Final (CONTRACTID_UNIQUE)	

	
/* V_TheCompany_EDIT_ITEMS */
/* normal run time 01:19 */

	drop table T_TheCompany_EDIT_ITEMS
	
	select e.EditNo, a.* into  T_TheCompany_EDIT_ITEMS 
	from V_TheCompany_EDIT_ITEMS e 
		INNER JOIN V_T_TheCompany_ALL_WeeklyEditRpt a 
			/* custom view removing some fields since too many fields lead to record too large error in Access 
			AND e.g. agreement type string for admin is 5 lines, reducing to 2 */
			on e.CONTRACTID = a.CONTRACTID
	
	CREATE INDEX T_TheCompany_EDIT_ITEMS_CONTRACTID
	ON T_TheCompany_EDIT_ITEMS(CONTRACTID) 
	


	/* 
	drop table T_TheCompany_Edit_Wrong_DPTROLE_IN_OBJECT
	

	select * into T_TheCompany_Edit_Wrong_DPTROLE_IN_OBJECT FROM
	V_TheCompany_Edit_Wrong_DPTROLE_IN_OBJECT
	*/
	
/* V_TheCompany_EditDocuments */
/* normal run time 01:34 */

	drop table T_TheCompany_EditDocuments
	
	select * into  T_TheCompany_EditDocuments 
	from V_TheCompany_EditDocuments
	
	 CREATE UNIQUE INDEX T_TheCompany_EditDocuments_DOCUMENTID
	ON T_TheCompany_EditDocuments(DOCUMENTID)
	
	CREATE INDEX T_TheCompany_EditDocuments_CONTRACTID
	ON T_TheCompany_EditDocuments(CONTRACTID) 
	
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_1DAILY_ACL_AddMissingPermissions_AUTO]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[TheCompany_1DAILY_ACL_AddMissingPermissions_AUTO]
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

DECLARE @OBJECTID bigint 
DECLARE @groupid SMALLINT
DECLARE @privilegeid TINYINT


IF NOT EXISTS(select distinct r.contractid, u.usergroupid, u.privilege
	from V_TheCompany_AUTO_ACL_ContractIDs  r /* excludes test delete case TS Confidential etc , ACL Table not used so OBJECTTYPEID not relevant */
		inner join dbo.V_TheCompany_AUTO_ACL_Upload u  /* ACL Table not used so OBJECTTYPEID not relevant */
	on r.Code = u.Code3Digit
		inner join tcontract c on c.contractid = r.contractid
	where r.contractid not in 
			(SELECT OBJECTID 
			from tacl a 
			where 
				a.objectid = r.contractid 
				AND a.objecttypeid = 1 /* Contract, document (typeid 7) might have same number */
				and a.groupid = u.usergroupid
				and a.PRIVILEGEID = u.privilege)
		AND getdate() > dateadd(hh,+3,c.contractdate)   /* registered for more than 1 hr */
	/*	AND CONTRACTTYPEID not in(
						11 /*Case*/
								, 6 /* Access */
								, 5 /* Test Old */
								,102 /* Test New */
								, 13 /* DELETE */ 
								,106 /* autodelete */
								,103 /*file*/
								,104 /*corp file*/)
		AND (UPPER([CONTRACT]) not like '%TOP SECRET%' 
		AND [CONTRACT] not like '%CONFIDENTIAL[*]%')
		AND AGREEMENT_TYPEID not in (23 /* Admin - Anti corruption etc. */
			,100283 /* Administration - auditors etc */
			,25 /* Admin - filing case */)
		AND ([COUNTERPARTYNUMBER] IS NULL OR ([COUNTERPARTYNUMBER] 
				not like '!ARIBA%' AND [COUNTERPARTYNUMBER] not like '!AUTODELETE%'))
		/* AND c.contractid = 296959 */
		*/
		)

	BEGIN
		SET @RESULTSTRING = 'No records'
		GOTO lblEnd
	END

BEGIN

DECLARE myCursor CURSOR LOCAL FAST_FORWARD FOR

select distinct 
	r.contractid
	, u.usergroupid
	, u.privilege
from V_TheCompany_AUTO_ACL_ContractIDs  r 
	inner join dbo.V_TheCompany_AUTO_ACL_Upload u
on r.Code = u.Code3Digit
	inner join tcontract c on c.contractid = r.contractid
where r.contractid not in 
	(SELECT OBJECTID from tacl a 
		where a.objectid = r.contractid 
		AND a.objecttypeid = 1 /* Contract, document (typeid 7) might have same number */
		and a.groupid = u.usergroupid
		and a.PRIVILEGEID = u.privilege)
	AND getdate() > dateadd(hh,+3,c.contractdate)   /* registered for more than 1 hr */
	/* AND CONTRACTTYPEID not in(11 /*Case*/
							, 6 /* Access */
							, 5 /* Test Old */
							,102 /* Test New */
							, 13 /* DELETE */ 
							,106 /* autodelete */
							,103 /*file*/
							,104 /*corp file*/)
	AND (UPPER([CONTRACT]) not like '%TOP SECRET%' 
	AND [CONTRACT] not like '%CONFIDENTIAL[*]%')
	AND AGREEMENT_TYPEID not in (23 /* Admin - Anti corruption etc. */,100283 /* Administration - auditors etc */,25 /* Admin - filing case */)
	AND ([COUNTERPARTYNUMBER] IS NULL OR ([COUNTERPARTYNUMBER] not like '!ARIBA%' AND [COUNTERPARTYNUMBER] not like '!AUTODELETE%')
	/* AND c.contractid = 296959 */ 
	)*/


OPEN myCursor
FETCH NEXT FROM myCursor INTO @OBJECTID, @groupid, @privilegeid
		/* PRINT 'TheCompany_ACL_Upload_Group_ObjectIDGroupID'  
		PRINT @OBJECTID
		PRINT @groupid
		PRINT @privilegeid
		PRINT 0 */
WHILE @@FETCH_STATUS = 0 BEGIN
	
	BEGIN TRANSACTION TranAclPermissions
    WITH MARK N'ACL Permissions';
		/* PRINT 'TheCompany_ACL_Upload_Group_ObjectIDGroupID'  
		PRINT @OBJECTID
		PRINT @groupid
		PRINT @privilegeid
		PRINT 0 */
		
		exec TheCompany_ACL_Upload_Group_ObjectIDGroupID  @OBJECTID=@OBJECTID, @OBJECTTYPEID = 1, @GROUPID=@groupid, @PRIVILEGEID=@privilegeid, @NONINHERITABLE=0
	
		IF @privilegeid = 2 /*Write, implement Read also */
		BEGIN
			exec TheCompany_ACL_Upload_Group_ObjectIDGroupID  @OBJECTID=@OBJECTID, @OBJECTTYPEID = 1, @GROUPID=@groupid, @PRIVILEGEID=1 /*Read*/, @NONINHERITABLE=0
		END 

		FETCH NEXT FROM myCursor INTO @OBJECTID, @groupid, @privilegeid

	COMMIT TRANSACTION TranAclPermissions;

	SET @RESULTSTRING = 'Success'
END

CLOSE myCursor
DEALLOCATE myCursor

GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'


lblEnd: 
PRINT 'Result String: ' + @RESULTSTRING
PRINT '*** END [dbo].[TheCompany_ACL_AddMissingPermissions]'


END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_1DAILY_ACL_AddRemoveAutoPermissions]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_1DAILY_ACL_AddRemoveAutoPermissions]
/* added to MONTHLY script */
as

BEGIN
/* 1. Corporate Legal Dpt Permissions for all records where it is missing, except Top Secret records */

	PRINT '1. Corporate Legal Dpt Permissions'

/* 1a READ Permission*/

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
		contractid
		, 1 /*contract*/
		, (select usergroupid from tusergroup where fixed = 'GROUPLEGAL')
		, NULL /*USERID*/
		, 1 /*PRIVILEGE READ*/
		, 0 /*inheritable*/
	from V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig_TSConfidential
	where 
		contractid not in (select ta.objectid from tacl ta
			where 
			ta.objecttypeid = 1 /*contract*/ and 
			ta.privilegeid = 1 /*PRIVILEGE READ*/ and 
			ta.groupid in (select usergroupid from tusergroup where fixed = 'GROUPLEGAL') 
			) 
	AND [AGREEMENT_TYPEID] not in (select AgrTypeID from V_TheCompany_AgreementType
			WHERE [AgreementType_IsPrivate_FLAG] = 0 /* public */)

	PRINT '  1a - READ: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* 1b WRITE Permission*/

/*	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
	contractid
		, 1 /*contract*/ 
		, (select usergroupid from tusergroup where fixed = 'GROUPLEGAL') 
		, NULL /*USERID*/
		, 2 /*PRIVILEGE WRITE*/ 
		, 0 /*inheritable*/ 
	from V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig_TSConfidential
	where 
	contractid not in (select distinct ta.objectid from tacl ta
						where 
						ta.objecttypeid = 1 /*contract*/ and 
						ta.privilegeid = 2 /*PRIVILEGE WRITE*/  and 
						ta.groupid in (select usergroupid from tusergroup where fixed = 'GROUPLEGAL') 
						) 

	PRINT '  1b - WRITE: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

*/
	
/* 1bc DELETE Permission*/

/*
	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
		contractid
		, 1 /*contract*/ 
		, (select usergroupid from tusergroup where fixed = 'GROUPLEGAL') 
		, NULL /*USERID*/
		, 4 /*PRIVILEGE DELETE*/ 
		, 0 /*inheritable*/ 
	from V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig_TSConfidential
	where 
	contractid not in (select distinct ta.objectid from tacl ta
						where 
						ta.objecttypeid = 1 /*contract*/ and 
						ta.privilegeid = 4 /*PRIVILEGE DELETE*/   and 
						ta.groupid in (select usergroupid from tusergroup where fixed = 'GROUPLEGAL') 
						) 

	PRINT '  1bc - DELETE: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'
*/
/* 1c OWNER Permission*/
/*
	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
		contractid
		, 1 /*contract*/ 
		, (select usergroupid from tusergroup where fixed = 'GROUPLEGAL') 
		, NULL /*USERID*/
		, 5 /*PRIVILEGE OWNER*/ 
		, 0 /*inheritable*/ 
	from  V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig_TSConfidential
	where 
	contractid not in (select distinct ta.objectid from tacl ta
						where 
						ta.objecttypeid = 1 /*contract*/ and 
						ta.privilegeid = 5 /*PRIVILEGE OWNER*/  and 
						ta.groupid in (select usergroupid from tusergroup where fixed = 'GROUPLEGAL') 
						) 


	PRINT '  1c - OWNER: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'
*/
/* 2. Top Secret Permissions for all records where it is applicable */

/* 2a Top Secret READ Permission*/

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
		contractid
		, 1 /*contract*/
		, (select usergroupid from tusergroup where fixed = 'LG_TOP_SECRET')
		, NULL /*USERID*/
		, 1 /*PRIVILEGE READ*/
		, 0 /*inheritable*/
	from  V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig
	where 
	contractid not in (select ta.objectid from tacl ta
						where 
						ta.objecttypeid = 1 /*contract*/ and 
						ta.privilegeid = 1 /*PRIVILEGE READ*/ and 
						ta.groupid in (select usergroupid from tusergroup where fixed = 'LG_TOP_SECRET') 
						) 
	AND (UPPER([CONTRACT]) LIKE '%TOP SECRET%')

	PRINT '  2a - READ: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* 2b Top Secret WRITE Permission*/
/*
	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
		contractid
		, 1 /*contract*/ 
		, (select usergroupid from tusergroup where fixed = 'LG_TOP_SECRET') 
		, NULL /*USERID*/
		, 2 /*PRIVILEGE WRITE*/ 
		, 0 /*inheritable*/ 
	from V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig
	where 
	contractid not in (select distinct ta.objectid from tacl ta
						where 
						ta.objecttypeid = 1 /*contract*/ and 
						ta.privilegeid = 2 /*PRIVILEGE WRITE*/  and 
						ta.groupid in (select usergroupid from tusergroup where fixed = 'LG_TOP_SECRET') 
						) 
	AND (UPPER([CONTRACT]) LIKE '%TOP SECRET%')
*/
	PRINT '  2b - WRITE: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* 2c Top Secret OWNER Permission*/
/*
	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
		contractid
		, 1 /*contract*/ 
		, (select usergroupid from tusergroup where fixed = 'LG_TOP_SECRET') 
		, NULL /*USERID*/
		, 5 /*PRIVILEGE OWNER*/ 
		, 0 /*inheritable*/ 
	from V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig
	where 
	contractid not in (select distinct ta.objectid from tacl ta
		where 
		ta.objecttypeid = 1 /*contract*/ and 
		ta.privilegeid = 5 /*PRIVILEGE OWNER*/  and 
		ta.groupid in (select usergroupid from tusergroup where fixed = 'LG_TOP_SECRET') 
		) 
	AND (UPPER([CONTRACT]) LIKE '%TOP SECRET%')

	PRINT '  2c - OWNER: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'
*/
/* 3. STRICTLY CONFIDENTIAL Permissions for all records where it is applicable */

/* 3a STRICTLY CONFIDENTIAL READ Permission*/

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
		contractid
		, 1 /*contract*/
		, (select usergroupid from tusergroup where fixed = 'LG_CONFIDENTIAL')
		, NULL /*USERID*/
		, 1 /*PRIVILEGE READ*/
		, 0 /*inheritable*/
	from V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig
	where 
	contractid not in (select ta.objectid from tacl ta
		where 
		ta.objecttypeid = 1 /*contract*/ and 
		ta.privilegeid = 1 /*PRIVILEGE READ*/ and 
		ta.groupid in (select usergroupid from tusergroup where fixed = 'LG_CONFIDENTIAL') 		) 
	AND (UPPER([CONTRACT]) LIKE '%STRICTLY CONFIDENTIAL%')
	AND (UPPER([CONTRACT]) NOT LIKE '%TOP SECRET%')
		

	PRINT '  2a - READ: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* 3b STRICTLY CONFIDENTIAL WRITE Permission*/
/*
	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
		contractid
		, 1 /*contract*/ 
		, (select usergroupid from tusergroup where fixed = 'LG_CONFIDENTIAL') 
		, NULL /*USERID*/
		, 2 /*PRIVILEGE WRITE*/ 
		, 0 /*inheritable*/ 
	from V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig
	where 
	contractid not in (select distinct ta.objectid from tacl ta
		where 
		ta.objecttypeid = 1 /*contract*/ and 
		ta.privilegeid = 2 /*PRIVILEGE WRITE*/  and 
		ta.groupid in (select usergroupid from tusergroup where fixed = 'LG_CONFIDENTIAL') 		) 
	AND (UPPER([CONTRACT]) LIKE '%STRICTLY CONFIDENTIAL%')
	AND (UPPER([CONTRACT]) NOT LIKE '%TOP SECRET%')
	
	PRINT '  2b - WRITE: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'
*/
/* 3c STRICTLY CONFIDENTIAL OWNER Permission*/
/*
	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
		contractid
		, 1 /*contract*/ 
		, (select usergroupid from tusergroup where fixed = 'LG_CONFIDENTIAL') 
		, NULL /*USERID*/
		, 5 /*PRIVILEGE OWNER*/ 
		, 0 /*inheritable*/ 
	from V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig
	where 
	contractid not in (select distinct ta.objectid from tacl ta
		where 
		ta.objecttypeid = 1 /*contract*/ and 
		ta.privilegeid = 5 /*PRIVILEGE OWNER*/  and 
		ta.groupid in (select usergroupid from tusergroup where fixed = 'LG_CONFIDENTIAL') 		) 
	AND (UPPER([CONTRACT]) LIKE '%STRICTLY CONFIDENTIAL%')
	AND (UPPER([CONTRACT]) NOT LIKE '%TOP SECRET%')
	
	PRINT '  2c - OWNER: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'
	
*/
	
/* 4 Delete ACL Junk Entries for Territories and Internal Partners Records (that have no effect on permissions but are clutter) */

	/* OBJECTTYPEID not relevant here since it is by user group */
	DELETE 
	FROM TACL 
	WHERE ACLID IN
		(SELECT ACLID 
			FROM TACL t, TUSERGROUP u 
			WHERE
			t.GROUPID = u.USERGROUPID AND
			  (u.USERGROUP  LIKE  'Territories%'
			   OR
			   u.USERGROUP  LIKE  'Internal Partner%'))

	PRINT '4 DELETE ACL Territories And Internal Partners: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* 5 ADD READ_ALL_HEADERS user group permissions where applicable */

	PRINT '5 ADD READ_ALL_HEADERS user group permissions where applicable'

/* READ ALL group (automatic ACL Setup) - 3d STRICTLY CONFIDENTIAL remove */
	
	DELETE FROM TACL 
	WHERE ACLID IN
	(SELECT ACLID 
		FROM TACL t inner join TUSERGROUP u on t.GROUPID = u.USERGROUPID 
			inner join TCONTRACT c 
						on t.OBJECTID = c.contractid 
						AND t.objecttypeid = 1 /* Contract, document might have same id but objecttype = 7 */
		WHERE
			u.fixed = 'READ_ALL' /* Read All user group */
			AND UPPER([CONTRACT]) LIKE '%STRICTLY CONFIDENTIAL%')

/* Read ALL HEADERS - ADD */

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
		contractid
		, 1 as OBJECTTYPEID 
		, (select usergroupid from tusergroup where fixed = 'READ_ALL_HEADERS') as USERGROUPID
		, NULL /*USERID*/ as USERID
		, 1 /*PRIVILEGE READ*/ as PRIVILEGEID
		, 1 /* 1 = noninheritable so that only headers can be read*/ as NONINHERITABLE
	from V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig_TSConfidential
	where 
		contractid not in (select distinct ta.objectid from tacl ta
							where 
							ta.objecttypeid = 1 /*contract*/ and 
							ta.privilegeid = 1 /*PRIVILEGE READ*/ and 
							ta.groupid in (select usergroupid 
								from tusergroup where fixed = 'READ_ALL_HEADERS') 
								) 
			/* do not add read headers group if agreement type is public */
		AND [AGREEMENT_TYPEID] not in (select AgrTypeID from V_TheCompany_AgreementType
			WHERE [AgreementType_IsPrivate_FLAG] = 0 /* public */)
		and contracttypeid <> '11' /* exclude CASE */

	PRINT '  5a ADD: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* 5b REMOVE Inapplicable READ_ALL_HEADERS user group permissions */

	DELETE 
	FROM TACL 
	WHERE 
	groupid = 3397 /* Read all headers */
	AND ACLID IN
			(SELECT ACLID FROM TACL t, TUSERGROUP u
				WHERE
					t.GROUPID = u.USERGROUPID 
					AND u.FIXED = 'READ_ALL_HEADERS'	
					)
			AND OBJECTTYPEID = 1 /* Contract */ 
			AND 
				(OBJECTID not IN (SELECT CONTRACTID 
									FROM [dbo].[V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig_TSConfidential]	
									WHERE 
										contracttypeid <> '11' /* exclude CASE */
									AND [AGREEMENT_TYPEID] not in (select AgrTypeID 
											from V_TheCompany_AgreementType
											WHERE [AgreementType_IsPrivate_FLAG] = 0 /* public */ 
											/* is public, no header needed */
									)
				))

	PRINT '  5b REMOVE: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'
	
/*7a Change TEST Records older than 12 months to DELETE number series*/

		update TCONTRACT
		set CONTRACTTYPEID = 106 /* AutoDelete */
			, contractnumber = replace(contractnumber, 'Test','TestDelete')
		where CONTRACTTYPEID ='102' /* TEST */	
			AND CONTRACTDATE < DATEADD(MONTH, -12, GETDATE())	

	PRINT '  7a Change TEST records older than 12 months to DELETE number series: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* 7c ADD DEL_NUM_SERIES user group permissions */

/* 7c READ*/

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
		contractid
		, 1 /*contract*/
		, (select usergroupid from tusergroup where fixed = 'DEL_NUM_SERIES')
		, NULL /*USERID*/
		, 1 /*PRIVILEGE READ*/
		, 0 /*inheritable*/
	from tcontract 
	where 
		/* Read permission not already there */
		contractid not in (select ta.objectid from tacl ta
						where 
						ta.objecttypeid = 1 /*contract*/ and 
						ta.privilegeid = 1 /*PRIVILEGE READ*/ and 
						ta.groupid in (select usergroupid from tusergroup where fixed = 'DEL_NUM_SERIES') 
						) 
		AND contractid IN (SELECT CONTRACTID FROM TCONTRACT 
				WHERE CONTRACTTYPEID in('13' /* DELETE */, 106 /* AutoDelete */))

	PRINT '  7c Add READ: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* 7d WRITE*/
/*
	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
		contractid
		, 1 /* contract OBJECTTYPEID*/ 
		, (select usergroupid from tusergroup where fixed = 'DEL_NUM_SERIES')
		, NULL /*USERID*/
		, 2 /*PRIVILEGE WRITE*/ 
		, 0 /*inheritable*/ 
	from tcontract 
	where 
		contractid not in (select distinct ta.objectid from tacl ta
		where 
		ta.objecttypeid = 1 /*contract*/ and 
		ta.privilegeid IN (2 /*PRIVILEGE WRITE*/)   and 
		ta.groupid in (select usergroupid from tusergroup where fixed = 'DEL_NUM_SERIES') 
		) 
	AND contractid IN (SELECT CONTRACTID 
						FROM TCONTRACT 
						WHERE CONTRACTTYPEID in(
						13 /* DELETE */
						, 106 /* AutoDelete */
						))
*/
	PRINT '  7d Add WRITE: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'


/* 7e OWNER*/
/*
	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
		contractid
		, 1 /* contract OBJECTTYPEID */ 
		, (select usergroupid from tusergroup where fixed = 'DEL_NUM_SERIES')
		, NULL /*USERID*/
		, 5 /*PRIVILEGE OWNER*/ 
		, 0 /*inheritable*/ 
	from tcontract 
	where 
		contractid not in (select distinct ta.objectid from tacl ta
		where 
		ta.objecttypeid = 1 /*contract*/ and 
		ta.privilegeid = 5 /*PRIVILEGE OWNER*/  and 
		ta.groupid in (select usergroupid from tusergroup where fixed = 'DEL_NUM_SERIES') 
		) 
	AND contractid IN (SELECT CONTRACTID 
						FROM TCONTRACT 
						WHERE CONTRACTTYPEID in(
						13 /* DELETE */
						, 106 /* AutoDelete */
						))

	PRINT '  7e Add OWNER: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'
*/
/* 7f DELETE*/
/*
	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
		contractid
		, 1 /* contract OBJECTTYPEID */ 
		, (select usergroupid from tusergroup where fixed = 'DEL_NUM_SERIES')
		, NULL /*USERID*/
		, 4 /*PRIVILEGE DELETE*/ 
		, 0 /*inheritable*/ 
	from tcontract 
	where 
	contractid not in (select distinct ta.objectid from tacl ta
		where 
		ta.objecttypeid = 1 /*contract*/ 
		and ta.privilegeid = 4 /*PRIVILEGE DELETE*/  
		and ta.OBJECTID is not null
		and ta.groupid in (select usergroupid from tusergroup where fixed = 'DEL_NUM_SERIES') 
		) 
	AND contractid IN (SELECT CONTRACTID 
						FROM TCONTRACT 
						WHERE CONTRACTTYPEID in(
						13 /* DELETE */
						, 106 /* AutoDelete */
						))
*/
	PRINT '  7f Add DELETE: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'


/* 8 - top secret remove all permission from contracts and documents except system, top secret and named users */

	Delete 
	from TACL 
	WHERE
		OBJECTTYPEID = 1 /* Contract */
		AND objectid in (select contractid from tcontract where UPPER([CONTRACT]) LIKE '%TOP SECRET%')
		AND USERID is null /* is not a named user */ 
		AND (/* groupid IS NULL or */ groupid not in(
			126 /*System Internal*/
			, 4901 /*All contracts top secret, FIXED = LG_TOP_SECRET */
			, 0 /* Administration - System DELETE PRIVILEGE */
			/* , 20  (ALL CONTRACTS) Corporate Legal Division */
			))

	PRINT '  Delete top secret contract permissions from ACL ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'
	
/* 9 Ariba migration records - delete write permission - move out of this procedure to separate Ariba adhoc */

	Delete 
	from TACL 
	WHERE 
	PRIVILEGEID = 2 /* WRITE */ 
	AND objectid in (select contractid from tcontract 
			where COUNTERPARTYNUMBER = '!ARIBA_W01' /* migrated records */) 
	AND	(groupid is null or groupid not in(
				126 /*System Internal*/
				, 0 /* Administration - System DELETE PRIVILEGE */
				))

	PRINT '  Delete Ariba migration contract permissions from ACL ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

	/* 1b3 Missing CREATE Privilege for super user - ALL CONTRACTS INCL TOP SECRET*/

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE) 
	select distinct 
		contractid
		, 1 /*contract*/
		, NULL /* No groupid */
		, (SELECT EXECUTORID FROM TCONTRACT WHERE CONTRACTID = c.contractid) /* USERID */
		, 3 /*PRIVILEGE CREATE*/
		, 0 /*inheritable*/
	from V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig c /* WITH CONFIDENTIAL */
	where 
		contractid not in 
		(select ta.objectid from tacl ta
			where 
			ta.objecttypeid = 1 /*contract*/ 
			AND ta.privilegeid = 3 /*PRIVILEGE CREATE*/
			and ta.OBJECTID is not null) 			
		AND EXECUTORID IS NOT NULL
	/*	AND contractid NOT IN (SELECT CONTRACTID FROM TCONTRACT WHERE CONTRACTTYPEID in(
						/* 6 /* Access SAKSNR number Series*/ no records left Jan-2021 */
						 5 /* Test Old */
						, 102 /* Test New */
						, 13 /* DELETE */
						, 106 /* AutoDelete */ 
		)) */

/* remove person permissions not needed */

/*	don't run on a weekend for first time
	DELETE 
	select * 
	from TACL a 
		inner join V_TheCompany_VUSER u on a.USERID = u.USERID
	where 
	a.USERID is not null /* not group based */
	and u.UserProfileCategory <> 'Administrator'
	and u.USER_MIK_VALID = 0
	and OBJECTtypeID = 1 /* contract */
	and PRIVILEGEID = 1 /* read */
	and u.userid not in (select r.userid from [dbo].[V_TheCompany_VPPERSONROLE_IN_OBJECT] r 
					where a.OBJECTID = r.objectid 
					and r.roleid_Cat2Letter <>'US' /* not the super user */)
	/* public */
	and OBJECTID in (select contractid 
					from V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig_TSConfidential
					where [AgreementType_IsPUBLIC_FLAG] = 1)
*/

/* remove group permissions not needed, procurement etc. but not if auto added then remove auto add */

/* missing CREATE Privilege on CONTRACTS */

	 insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID
	, [INHERITFROMPARENTOBJECT]
	, [PARENTOBJECTTYPEID]
	, [PARENTOBJECTID]
	 , NONHERITABLE) 
	select distinct 
		contractid
		, 1 /* contract */
		, 20 /* legal */ as GROUPID
		, null /* 1 = sysadm */
		, 3 as PRIVILEGEID /*PRIVILEGE CREATE*/
		, 0 /* is contract, not document, so no [INHERITFROMPARENTOBJECT] */ /* defaults to FALSE if null not passed */
		, null /* [PARENTOBJECTTYPEID] */
		, null /* [PARENTOBJECTID] */
		, 0 as NONINHERITABLE /*inheritable which leads to warning in display*/
	from tcontract c 
	where 
	/* CONTRACTID = 113548 and */
	contractid not in
		(select ta.objectid from tacl ta
			where 
			ta.objecttypeid = 1 /* contract */
			AND ta.privilegeid = 3 /*PRIVILEGE CREATE*/ 
			and ta.OBJECTID is not null) 		

/* missing CREATE Privilege on documents */

	 insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID
	, [INHERITFROMPARENTOBJECT]
	, [PARENTOBJECTTYPEID]
	, [PARENTOBJECTID]
	 , NONHERITABLE) 
	select distinct 
		d.documentid
		, 7 /* document */
		, NULL /* legal = 20  but does not work with a group id, only inherits if user id is populated */ as GROUPID
		, 1 as USERID_SYSADM /* 1 = sysadm */
		, 3 as PRIVILEGEID /* 3 = PRIVILEGE CREATE*/
		, 1 /* Inherit from contract [INHERITFROMPARENTOBJECT] */ /* defaults to FALSE if null not passed */
		, 1 /* [PARENTOBJECTTYPEID] */
		, c.CONTRACTID /* [PARENTOBJECTID] */
		, 0 as NONINHERITABLE /*inheritable which leads to warning in display*/
	from V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig c 
		inner join V_TheCompany_vdocument d on c.CONTRACTID = d.contractid /* WITH CONFIDENTIAL */
	where /* DOCUMENTID = 124901
	 	 and */ DOCUMENTID not in 
		(select ta.objectid from tacl ta
			where 
			ta.objecttypeid = 7 /*document*/ 
			AND ta.privilegeid = 3 /*PRIVILEGE CREATE*/ and ta.OBJECTID is not null) 			


/* missing document inheritance - NON ISSUE FOR PUBLIC CONTRACTS BECAUSE inheritable flag = 0 on contract makes public inherit to the document */
/* see comment - non issue
	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE)
	select distinct 
	d.documentid
	, 7 /* document */ AS TYPE_CONTRACT
	, (select usergroupid from tusergroup where fixed = 'READ_PUBLIC' /* 1089 */) AS USERGROUPID
	, NULL /*USERID*/ AS USERID
	, 1 /*PRIVILEGE READ*/ AS READ_PRIVILEGE
	, 0 /*inheritable - 0 = inherits from contract, this is what we want for PUBLIC contracts */ AS INHERITABLE
	from v_TheCompany_vdocument d inner join TCONTRACT c on d.contractid = c.contractid
	WHERE /* documentid = 12754
		and */ d.amendmentid is null
		and AGREEMENT_TYPEID IN(select [AGREEMENT_TYPEID] from [TAGREEMENT_TYPE] where FIXED LIKE '%PUBLIC%')
		AND d.documentid not in /* record does not already exist */ ( 
			select distinct ta.objectid from tacl ta
			where 
			ta.objecttypeid = 7 /*contract*/ and 
			ta.privilegeid = 1 /*PRIVILEGE READ*/ and 
			ta.groupid in (select usergroupid from tusergroup where fixed= 'READ_PUBLIC' /* 1089 */
			/* and CONTRACTID = 2974 */)
			/* and ta.NONHERITABLE = 1 /* not inheritable */ */
			) 
		AND CONTRACTTYPEID NOT IN (102 /* TEST NEW */,13 /*DELETE*/, 106 /* AutoDelete */  )
		AND ([CONTRACT] not like '%TOP SECRET%' 
		AND [CONTRACT] not like '%CONFIDENTIAL[*]%')
*/

		/* and CONTRACTID = 144525 test record */
		/*
	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID	
	,  [INHERITFROMPARENTOBJECT]
	, 	[PARENTOBJECTTYPEID]
	, 	 [PARENTOBJECTID]
	, [NONHERITABLE])
	select distinct 
	DOCUMENTID as OBJECTID
	, 7 /*contract*/ AS OBJECTTYPE
	,  (select usergroupid from tusergroup where fixed = 'READ_PUBLIC') AS USERGROUPID
	, 83663 /* USERID Joest */ AS USERID
	, 1 /* READ */ AS PRIVILEGEID_READ
	, 0 as [INHERITFROMPARENTOBJECT]
	, 1 /* contract */ as [PARENTOBJECTTYPEID]
	, CONTRACTID as [PARENTOBJECTID]
	 , 0 as NONHERITABLE
	from V_TheCompany_VDOCUMENT
	WHERE
		contractid not in (	
			select ct.contractid 
			from tcontract ct inner join TAGREEMENT_TYPE ta 
			on ct.agreement_typeid = ta.AGREEMENT_TYPEID 
			where ta.FIXED like '%PUBLIC%')
		and contractid not IN (SELECT ct2.contractid from tcontract ct2 where
						CONTRACTTYPEID IN ('102' /* TEST NEW */,'13' /*DELETE*/, 106 /* AutoDelete */ )
						OR [CONTRACT] like '%TOP SECRET%' 
						OR [CONTRACT] like '%CONFIDENTIAL[*]%') 
		and documentid not in (select OBJECTID from tacl 
				where OBJECTTYPEID = 7
				and PRIVILEGEID = 3
				 and OBJECTID = contractid /* even null seems to work, or wrong */
				/* and (INHERITFROMPARENTOBJECT is null or INHERITFROMPARENTOBJECT = 0*/ 
				)
/* 
		and documentid not in (select OBJECTID from tacl 
				where OBJECTTYPEID = 7 and PRIVILEGEID = 3
				and OBJECTID is NOt null)
				 */
				 */
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_1DAILY_AUTODELETE]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_1DAILY_AUTODELETE]

AS

BEGIN

/*7 DELETE, !AUTODELETE */


		update TCONTRACT
		set CONTRACTTYPEID = 106 /* AutoDelete */
		where COUNTERPARTYNUMBER like '!AUTODELETE%'
		and CONTRACTTYPEID <>106 /* AutoDelete */	
		
		/* removed because it is better to keep the old contract number */
		
		/* update tcontract
		set contractnumber = replace(contractnumber, 'Contract','Delete')
		where COUNTERPARTYNUMBER like '!AUTODELETE%' 
		and CONTRACTTYPEID = 106 /* Delete */
		and CONTRACTNUMBER like 'Contract-%' /* only if not Yoda etc. */
		*/
		
		Update TCONTRACT
		set DEFINEDENDDATE = 1 /* Defined End Date = true */
		, EXPIRYDATE = GETDATE() /* will put the actual time instead of 22:00 but not a problem */
		where expirydate is null /* does not already have an expiry date */
		AND CONTRACTTYPEID = 106 /* AutoDelete */
		AND COUNTERPARTYNUMBER like '!AUTODELETE%'
		
		update TCONTRACT
		set STATUSID = 6 /* expired */ /* was 9 Annulled */
		where CONTRACTTYPEID = 106 /* AutoDelete */	
		and STATUSID in (4 /* Awarded */, 5 /* Active */)	
		
		/* note that the CONTRACTNUMBER in this table is still the old one, not delete** */
		/* should we do this? the contractnumber table would be a history record of what number series a contract used to have */
			/* update TCONTRACTNUMBER
		set CONTRACTTYPEID = 106 /* set to AutoDelete */
		where CONTRACTID in (select CONTRACTID from TCONTRACT where CONTRACTTYPEID = 106 /* AutoDelete */)
		and CONTRACTTYPEID <>106 /* not already AutoDelete */
		*/
		
		PRINT '  7 !AUTODELETE records changed to DELETED number series: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'	
	
		/* now directly in daily pro 
			exec TheCompany_1DAILY_AUTODELETE_Deactivate_Reminders		
				/* Delete all permissions for num series 106 AUTODELETE except admin, delete etc. */
			exec TheCompany_1DAILY_AUTODELETE_RemovePermissions */
		
		/* Change Num Series to Delete for !AUTODELETE contracts, and set !AUTODELETE' flag in description  */
		update TCONTRACT
		set CONTRACT = '!AUTODELETE, PERMISSIONS REMOVED! ' + substring(contract,0,200)
		where COUNTERPARTYNUMBER like '!AUTODELETE%'
		and CONTRACT not like '!AUTODELETE, PERMISSIONS REMOVED!%'
		
	PRINT '  7b Removed all GROUP and USER permissions: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'	
	
/* REVERSE */

		update tcontract
		set contractnumber = replace(contractnumber, 'Delete', 'Contract')
		, CONTRACTTYPEID = 12
		where COUNTERPARTYNUMBER = '!UNDELETE' /* flagged for undeletion */
		and CONTRACTTYPEID = 106 /* AutoDelete */
		and CONTRACTNUMBER like 'Delete-%' /* No Yoda etc. */

	/* contracts where the number series was not changed to Delete */
		update tcontract
		set CONTRACTTYPEID = 12
		where COUNTERPARTYNUMBER = '!UNDELETE' /* flagged for undeletion */
		and CONTRACTTYPEID = 106 /* AutoDelete */

END

GO
/****** Object:  StoredProcedure [dbo].[TheCompany_1DAILY_AUTODELETE_Deactivate_Reminders]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_1DAILY_AUTODELETE_Deactivate_Reminders]

/* Issue #403 - delete CDA Reminders */
/* DO NOT USE unless it surely works, seems not to turn off */

AS

/* set turnedoff date */

	update tperson_in_warning
	set turnedoffdate = getdate()
	,INTERNALWARNING = 0
	,EMAILWARNING = 0
	,isturnedoff = 1 /* OFF */
	where (tperson_in_warning.isturnedoff = 0 /* ON */ or TURNEDOFFDATE is null)
		and warningid in (select warningid 
					from twarning w inner join tcontract c 
					on w.objectid = c.contractid
					where /* w.WARNINGDATE >= GETDATE()
					AND */ (c.CONTRACTTYPEID = 106 /* AutoDelete */ or CONTRACTNUMBER like 'Xt_%'))
					
/* TWARNING: ISACTIVE from 0 to 1 to turn off */

	UPDATE TWARNING
	set ISACTIVE = 0
	WHERE ISACTIVE = 1 
	/* AND objectid = 133810 /* 'Contract-11127305' */ */
	AND WARNINGFIELDNAME= 'REVIEWDATE'
	AND warningid in (select warningid 
					from twarning w inner join tcontract c 
					on w.objectid = c.contractid
					where /* w.WARNINGDATE >= GETDATE()
					AND */ (c.CONTRACTTYPEID = 106 /* AutoDelete */ or CONTRACTNUMBER like 'Xt_%'))
					
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_1DAILY_AUTODELETE_RemovePermissions]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_1DAILY_AUTODELETE_RemovePermissions]
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

DECLARE @ACLID bigint 


IF not EXISTS(select ACLID 
	FROM TACL 
	WHERE 	
		OBJECTTYPEID = 1 /* contract, document type 7 could have same OBJECTID */
		AND OBJECTID IN
			(SELECT CONTRACTID FROM TCONTRACT 
			WHERE CONTRACTTYPEID ='106' /* AutoDelete */)
			AND  (groupid not in (0 /* Delete Privilege */, 126 /* System Internal */ , 4633 /* Delete num series */) or GROUPID is null)
			AND  (USERID not in (1 /*sysadm */, 20134 /* TheVendoradmin */, 81995 /* systemservice */) or USERID is null)
			)
		
	BEGIN
		SET @RESULTSTRING = 'No records'
		GOTO lblEnd
	END

BEGIN

DECLARE myCursor CURSOR LOCAL FAST_FORWARD FOR

	select ACLID  
	FROM TACL 
	WHERE 
		OBJECTTYPEID = 1 /* contract, document type 7 could have same OBJECTID */
		AND OBJECTID IN
			(SELECT CONTRACTID FROM TCONTRACT WHERE CONTRACTTYPEID ='106' /* AutoDelete */)
		AND  (groupid not in (0 /* admin sysem */, 126 /* System Internal */ , 4633 /* Delete num series */) or GROUPID is null)
		AND  (USERID not in (1 /*sysadm */, 20134 /* TheVendoradmin */, 81995 /* systemservice */) or USERID is null)

		
OPEN myCursor
FETCH NEXT FROM myCursor INTO @ACLID

WHILE @@FETCH_STATUS = 0 BEGIN
	
	BEGIN TRANSACTION TranAclPermissions
    WITH MARK N'ACL Permissions';
		
		exec TheCompany_ACL_Remove_ACLID  @ACLID, 1 /* @OBJECTTYPEID Contract */

		FETCH NEXT FROM myCursor INTO @ACLID

	COMMIT TRANSACTION TranAclPermissions;

	SET @RESULTSTRING = 'Success'
END

CLOSE myCursor
DEALLOCATE myCursor

GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'


lblEnd: 
PRINT 'Result String: ' + @RESULTSTRING
PRINT '*** END [dbo].[TheCompany_ACL_AddMissingPermissions]'


END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_1DAILY_ConfidentialityFlag]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[TheCompany_1DAILY_ConfidentialityFlag]

as

BEGIN

/* insert new records */

/* TOP SECRET - INSERT */

  INSERT INTO [TheVendor_app].[dbo].[TEXTRA_FIELD_IN_CONTRACT]
			( 
		  [EXTRA_FIELDID] /* 100002 = Confidentiality Flag */
		  ,[CONTRACTID]
		  ,[MIK_EDIT_VALUE] /* Top Secret etc. */
		  )

	  SELECT 
		  100002 /* [EXTRA_FIELDID] */
		  , [CONTRACTID]
		  , 'TOP SECRET'
	  FROM TCONTRACT
	  WHERE [contract] like '%TOP SECRET%'
	  and CONTRACTID not in (select CONTRACTID 
		from [TEXTRA_FIELD_IN_CONTRACT] 
		where [EXTRA_FIELDID] = 100002) /* not already there */

/* STRICTLY CONFIDENTIAL - INSERT */

  INSERT INTO [TheVendor_app].[dbo].[TEXTRA_FIELD_IN_CONTRACT]
			( 
		  [EXTRA_FIELDID] /* 100002 = Confidentiality Flag */
		  ,[CONTRACTID]
		  ,[MIK_EDIT_VALUE] /* Top Secret etc. */
		  )
	  SELECT 
		  100002 /* [EXTRA_FIELDID] */
		  , [CONTRACTID]
		  , 'STRICTLY CONFIDENTIAL'
	  FROM TCONTRACT
	  WHERE [contract] like '%Strictly Confidential*%'
	  and CONTRACTID not in (select CONTRACTID from [TEXTRA_FIELD_IN_CONTRACT] where [EXTRA_FIELDID] = 100002) /* not already there */

/* CONFIDENTIAL - INSERT */

  INSERT INTO [TheVendor_app].[dbo].[TEXTRA_FIELD_IN_CONTRACT]
			( 
		  [EXTRA_FIELDID] /* 100002 = Confidentiality Flag */
		  ,[CONTRACTID]
		  ,[MIK_EDIT_VALUE] /* Strictly Confidential */
		  )
	  SELECT 
		  100002 /* [EXTRA_FIELDID] */
		  , [CONTRACTID]
		  , 'CONFIDENTIAL'
	  FROM TCONTRACT
	  WHERE 
		([contract] like '%Confidential*%' 
			and [contract] not like '%strictly Confidential%' 
			and [contract] not like '%top secret%')
	  and CONTRACTID not in (select CONTRACTID from [TEXTRA_FIELD_IN_CONTRACT] where [EXTRA_FIELDID] = 100002) /* not already there */

/* Material Agreement Flag */

	    INSERT INTO [TheVendor_app].[dbo].[TEXTRA_FIELD_IN_CONTRACT]
			( 
		  [EXTRA_FIELDID] /* 100003 */
		  ,[CONTRACTID]
		  ,[MIK_EDIT_VALUE] /* Top Secret etc. */
		  )
	  SELECT 
		  100003 /* [EXTRA_FIELDID] = MaterialContract*/
		  , [CONTRACTID]
		  , 'Material'
	  FROM T_TheCompany_ALL
	  WHERE 
		CONTRACTID not in (select CONTRACTID 
							from [TEXTRA_FIELD_IN_CONTRACT] 
							where 
							[EXTRA_FIELDID] = 100003) /* not already there */
		AND STATUSID = 5 /* active */
		AND ([Title_InclTopSecret] like '%top secret%' /* Title is Top Secret */
			OR [Title_InclTopSecret] like '%Strictly Confidential%'
			OR (AGREEMENT_TYPEID in (SELECT AGREEMENT_TYPEID 
							FROM TAGREEMENT_TYPE 
							WHERE FIXED LIKE '%§Material%')
							)
			OR (LumpSum >1000000 
				AND LumpSumCurrency in ('NOK','EUR','DKK', 'SEK', 'USD')) /* Agreement Type Distribution and high amount */
				)

/* update existing records, in case of flag changes, alternatively, delete all flags and redo daily */

/* Confidentiality Flags, [EXTRA_FIELDID] = 100002 */

  UPDATE  [TheVendor_app].[dbo].[TEXTRA_FIELD_IN_CONTRACT] 
  SET [MIK_EDIT_VALUE] = 'TOP SECRET' /* Top Secret etc. */
	WHERE contractid in (select CONTRACTID from TCONTRACT where [CONTRACT] like '%top secret%')
	  and CONTRACTID not in (select CONTRACTID from [TEXTRA_FIELD_IN_CONTRACT] 
			where [EXTRA_FIELDID] = 100002 /* Confidentiality Flag */
			AND MIK_EDIT_VALUE ='TOP SECRET') /* not already there */

  UPDATE  [TheVendor_app].[dbo].[TEXTRA_FIELD_IN_CONTRACT] 
  SET [MIK_EDIT_VALUE] = 'STRICTLY CONFIDENTIAL' /* Top Secret etc. */
	WHERE contractid in (select CONTRACTID from TCONTRACT where [CONTRACT] like '%STRICTLY CONFIDENTIAL%'
		AND [CONTRACT] NOT like '%TOP SECRET%')
		/* and not already tagged */
		and CONTRACTID not in (select CONTRACTID from [TEXTRA_FIELD_IN_CONTRACT] 
			where [EXTRA_FIELDID] = 100002 /* Confidentiality Flag */
			AND MIK_EDIT_VALUE ='STRICTLY CONFIDENTIAL' ) /* not already there */
						
  UPDATE  [TheVendor_app].[dbo].[TEXTRA_FIELD_IN_CONTRACT] 
  SET [MIK_EDIT_VALUE] = 'CONFIDENTIAL' /* Top Secret etc. */
	WHERE contractid in (select CONTRACTID 
							from TCONTRACT 
							where [CONTRACT] like '%CONFIDENTIAL*%' 
							/* star needed because otherwise confidentiality etc. are tagged */ 
		AND [CONTRACT] NOT like '%STRICTLY CONFIDENTIAL%'
		AND [CONTRACT] NOT like '%TOP SECRET%')
	 AND CONTRACTID not in (select CONTRACTID from [TEXTRA_FIELD_IN_CONTRACT] 
			where [EXTRA_FIELDID] = 100002 /* Confidentiality Flag */
			AND MIK_EDIT_VALUE ='CONFIDENTIAL' ) /* do not overwrite existing values */
						

/* Material Agreement Flag, [EXTRA_FIELDID] = 100003 */

  UPDATE  [TheVendor_app].[dbo].[TEXTRA_FIELD_IN_CONTRACT] 
  SET [MIK_EDIT_VALUE] = 'Material' /* Top Secret etc. */
	WHERE 
	[EXTRA_FIELDID] = 100003 /* Material Agreement Flag */
	AND CONTRACTID IN 
		 ( SELECT CONTRACTID
	  FROM T_TheCompany_ALL /* not TCONTRACT because lump sum needed */
	  WHERE 
		([Title_InclTopSecret] like '%top secret%' /* Title is Top Secret */
			OR (AGREEMENT_TYPEID in (SELECT AGREEMENT_TYPEID 
							FROM TAGREEMENT_TYPE 
							WHERE FIXED LIKE '%§Material%')
				AND LumpSum >1000000 and LumpSumCurrency in ('NOK','EUR','DKK', 'SEK', 'USD') /* Agreement Type Distribution and high amount */
			OR (AGREEMENT_TYPEID in (SELECT AGREEMENT_TYPEID 
							FROM TAGREEMENT_TYPE 
							WHERE FIXED LIKE '%§Material%')
				AND [Title_InclTopSecret] like '%Confidential%') /* Title is Strictly Confidential */
				))
		AND CONTRACTID not in (select CONTRACTID 
							from [TEXTRA_FIELD_IN_CONTRACT] 
							where 
							[EXTRA_FIELDID] = 100003 /* Material Agreement Flag */
							AND MIK_EDIT_VALUE >'' ) /*in('Material','NonMaterial') */ /* not already there */)

END

	/* select * 
	FROM [TEXTRA_FIELD_IN_CONTRACT]
	WHERE CONTRACTID = 101130 /* contractnumber = 'TEST-00000080' */ 

	select * from TCONTRACT where 
	CONTRACTID = 142716
	*/
	
	/* select * 
	FROM [TEXTRA_FIELD_IN_CONTRACT]
	WHERE [EXTRA_FIELDID] = 100002 */

/*	
	delete 
							from [TEXTRA_FIELD_IN_CONTRACT] 
							where 
							[EXTRA_FIELDID] = 100002
*/
/*
	EXTRA_FIELDID	MIK_TABLE_NAME	MIK_LABEL_TEXT	MIK_FIELD_TYPE	OBJECTTYPEID	MANDATORYFLAG	FIXED	FIELDTYPEID	MIK_SEQUENCE	MIK_VALID	MULTIPLEFLAG	ISDEFAULT
1	TABLENAME	Therapy (open)	NULL	1	0	NULL	0	2	1	NULL	NULL
2	TABLENAME	Mechanism / Profile / Benefit (open)	NULL	1	0	NULL	0	1	1	NULL	NULL
100000	TABLENAME	ATC Codes	NULL	1	0	ATCCODES	0	3	1	1	0
100001	TABLENAME	Payment Terms	NULL	1	0	NULL	0	4	1	0	0
100002	TABLENAME	Confidentiality	NULL	1	0	CONFIDENTIALITY	0	5	1	0	1
100003	TABLENAME	MaterialAgreement	NULL	1	0	MATERIALAGREEMENT	0	6	1	0	1
*/
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_1DAILY_PUBLIC_READ_Permissions]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_1DAILY_PUBLIC_READ_Permissions]

AS

BEGIN

/* PUBLIC Read Permissions for CDAs etc. where FIXED LIKE '%PUBLIC%' */
/* Add READ PUBLIC for PUBLIC contract types*/

	insert into tacl(OBJECTID, OBJECTTYPEID, GROUPID, USERID, PRIVILEGEID, NONHERITABLE)
	select distinct 
	contractid
	, 1 /*contract*/ AS TYPE_CONTRACT
	, (select usergroupid from tusergroup where fixed = 'READ_PUBLIC') AS USERGROUPID
	, NULL /*USERID*/ AS USERID
	, 1 /*PRIVILEGE READ*/ AS READ_PRIVILEGE
	, 0 /*inheritable*/ AS INHERITABLE
	from tcontract 
	WHERE
		AGREEMENT_TYPEID IN(select [AGREEMENT_TYPEID] from [TAGREEMENT_TYPE] where FIXED LIKE '%PUBLIC%')
		AND contractid not in /* record does not already exist */ ( 
			select distinct ta.objectid from tacl ta
			where 
			ta.objecttypeid = 1 /*contract*/ and 
			ta.privilegeid = 1 /*PRIVILEGE READ*/ and 
			ta.groupid in (select usergroupid from tusergroup where fixed= 'READ_PUBLIC'
			/* and CONTRACTID = 2974 */)
			) 
		AND CONTRACTTYPEID NOT IN (102 /* TEST NEW */,13 /*DELETE*/, 106 /* AutoDelete */  )
		AND ([CONTRACT] not like '%TOP SECRET%' 
		AND [CONTRACT] not like '%CONFIDENTIAL[*]%')
		/* and CONTRACTID = 144525 test record */
	
	PRINT 'PUBLIC User Group, Add Read Permission: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* Remove READ PUBLIC for non-public Categories */

	delete 
	from tacl
	where 
		groupid in (select usergroupid from tusergroup where fixed= 'READ_PUBLIC')
	and 
		(
			objectid not in 
			(select ct.contractid 
			from tcontract ct inner join TAGREEMENT_TYPE ta 
			on ct.agreement_typeid = ta.AGREEMENT_TYPEID 
			where ta.FIXED like '%PUBLIC%')
			 OR OBJECTID IN (SELECT ct2.contractid from tcontract ct2 where
						CONTRACTTYPEID IN ('102' /* TEST NEW */,'13' /*DELETE*/, 106 /* AutoDelete */ )
						OR [CONTRACT] like '%TOP SECRET%' 
						OR [CONTRACT] like '%CONFIDENTIAL[*]%') 
					
		)
	
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_1HOURLY_CancelCheckoutAllPdfs]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_1HOURLY_CancelCheckoutAllPdfs]

as

/* #410 - Cancel checkout all PDFs '*/
/* analogue to 'Cancel checkout on all documents' script in TheVendor install package */
BEGIN

/* PDF after 1 hr*/

	update tdocument
	set checkedin = 1 , /* set to checked in */
		CheckedOutBy = NULL,
		CheckedOutDate = NULL
	where (checkedin <> 1 or checkedin is null /* is checked out */)
		and fileinfoid in (select fileinfoid from tfileinfo where upper(filetype) = '.PDF')
		and getdate() > dateadd(hh,+3,checkedoutdate)   /* checked out for more than 1 hr */

	/* ALL FILES after 2 days */
	update tdocument
	set checkedin = 1 , /* set to checked in */
		CheckedOutBy = NULL,
		CheckedOutDate = NULL
	where (checkedin <> 1 or checkedin is null /* is checked out */)
		and getdate() > dateadd(hh,+51,checkedoutdate)   /* checked out for more than 2 days */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_1HOURLY_SetToAwarded_DeleteAwardedDate]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_1HOURLY_SetToAwarded_DeleteAwardedDate]

AS

BEGIN

	/* #409 - Awarded Contracts to Company */

	PRINT 'Update TTENDERER SET ISAWARDED = 1'
	
	/* notes: if awarded date is null, still do this? , refer to [dbo].[TheCompany_CORRECTION_STATUS] */
	update [TTENDERER]
		set [ISAWARDED] =  1 /* Awarded */
		, comment = 'set to awarded ' +CONVERT(CHAR(10),  GETDATE(), 120) 
	where [ISAWARDED] = 0 /* NOT Awarded */

	PRINT '[TheCompany_409_SetContractsToAwarded]Result: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Updated'

	/* 8. Delete Awarded Dates so that other dates can be changed without errors */

		PRINT '8. Delete Awarded Dates'

/* removed since it is causing status issues, refer to [dbo].[TheCompany_CORRECTION_STATUS] */
	/* UPDATE tCONTRACT
	SET [AWARDDATE] = NULL
	WHERE [AWARDDATE] IS NOT NULL */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_2DAILY_AlphaSort_TDEPARTMENT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_2DAILY_AlphaSort_TDEPARTMENT]

AS

BEGIN

/* #326 - Alphabetical Sort TDEPARTMENT */

SELECT 
      PARENTID,
       DEPARTMENTID,
       DEPARTMENT,
   MIK_SEQUENCE,
   ROW_NUMBER() OVER (PARTITION BY PARENTID ORDER BY DEPARTMENT) AS NEW_MIK_SEQUENCE 
into #tmp_dbo_tdpt 
FROM   dbo.TDEPARTMENT
where MIK_VALID = 1


UPDATE d
set d.MIK_SEQUENCE = t.NEW_MIK_SEQUENCE
FROM dbo.TDEPARTMENT d
inner join #tmp_dbo_tdpt t
on d.DEPARTMENTID = t.DEPARTMENTID
WHERE d.MIK_SEQUENCE <> t.NEW_MIK_SEQUENCE

drop table #tmp_dbo_tdpt 


END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_2DAILY_UpdateStrategyTypeTakPhVertrieb]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TheCompany_2DAILY_UpdateStrategyTypeTakPhVertrieb]

as

BEGIN
 print 'moved to maintenance agreement types '

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_2WEEKLY_CompanyCleanup_TheCompanyIntercompany]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_2WEEKLY_CompanyCleanup_TheCompanyIntercompany]

AS

BEGIN

/* Issue # 394 see also #339 - Company cleanup */

PRINT '[dbo].[TheCompany_341_RemapTT_InternalPartnerToTerritory]'



/* Merge junk TheCompany entities into Intercompany Dummy entity */
	UPDATE TTENDERER
	SET COMPANYID = 1 /* Intercompany TheCompany */
	WHERE 
		COMPANYID <> 1 /* not already Intercompany TheCompany */
		and COMPANYID <> 224910 /* INTRAcompany TheCompany */
		AND COMPANYID IN (SELECT COMPANYID
							FROM  TCOMPANY WHERE MIK_VALID = 1 
							AND
							(company like '%Altana%'
							or company like '%Byk Gulden%'
							or company like '%Nycomed%'
							or company like '%TheCompany%')
							)


	PRINT 'Result Flag Merge into Intercompany TheCompany: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* Delete Primary Contact ID if there is one */
	UPDATE TTENDERER
	SET PRIMARYCOMPANYCONTACTID = NULL 
	WHERE 
	COMPANYID = 1 /* Intercompany TheCompany */
	AND PRIMARYCOMPANYCONTACTID IS NOT NULL 

	PRINT 'Result Delete Primary Contact ID: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* Flag junk entries without contracts attached */
/* Note: user group name not updated, but will be disabled below */
	update [TCOMPANY]
		SET [COMPANY]=  [COMPANY] +' *NO CONTRACTS*'
	WHERE
		[COMPANY] NOT LIKE ('%*NO CONTRACTS*%')
		AND COMPANYID NOT IN (SELECT COMPANYID FROM TTENDERER)
		AND  LEN([COMPANY]) <230 /*there must be extra room in description for flag */

	PRINT 'Result Flag *NO CONTRACTS*: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* Disable companies without contracts attached */
	UPDATE TCOMPANY 
		SET MIK_VALID = 0 
	WHERE 
		MIK_VALID = 1
		AND COMPANYID <> 1 /* not Intercompany TheCompany */
		AND COMPANYID <> 224910 /* not INTRAcompany TheCompany */
		AND COMPANYID NOT IN (SELECT COMPANYID FROM TTENDERER) /* No contracts */

/* Company usergroups = inactive if company inactive */

	UPDATE TUSERGROUP
		SET MIK_VALID = 0
	WHERE 
		MIK_VALID = 1 /* is active */
		AND COMPANYID NOT IN (SELECT COMPANYID 
								FROM TCOMPANY 
								WHERE MIK_VALID = 1) /* Company deactivated */

	/* SELECT * FROM TCOMPANY
	WHERE 
	COMPANYID <> 1 /* not already Intercompany TheCompany */
	AND COMPANYID <> 224910 /* INTRAcompany TheCompany */
	AND COMPANYID NOT IN (SELECT COMPANYID FROM TTENDERER) /* No contracts */
	AND COMPANYID not in (select companyid from TCOMPANYADDRESS)
	AND COMPANYID NOT IN (select companyid from TCOMPANYCONTACT)
	AND CREATEDATE < GETDATE()-30 */

	PRINT 'Result Disable Companies without contracts attached: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_2WEEKLY_HardcopyArchiving_DeleteTTEntries]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[TheCompany_2WEEKLY_HardcopyArchiving_DeleteTTEntries]

as

/* #361: Hardcopy Archiving Location - Delete Territory Entries */

BEGIN

DELETE
FROM TDEPARTMENTROLE_IN_OBJECT
WHERE ROLEID = 103 /* Hardcopy Archiving */
AND DEPARTMENTID IN (SELECT DEPARTMENTID 
					  FROM TDEPARTMENT 
					  WHERE (
					  (DEPARTMENT_CODE like ';%' 
					  OR DEPARTMENT_CODE LIKE '.%' 
					  /* is not Internal Partner or CCO but Territory*/)
					  AND DEPARTMENT_CODE NOT LIKE('.DES%')
					  AND DEPARTMENT_CODE NOT LIKE('.CHA%')	
					  AND DEPARTMENT_CODE NOT LIKE('.BET%')		  
					  ))

PRINT '[TheCompany_361_Weekly_HardcopyArchiving_DeleteTTEntries] Result: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Deleted'


END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_2WEEKLY_Maintenance_AgreementTypes]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_2WEEKLY_Maintenance_AgreementTypes]

AS

BEGIN

	INSERT INTO T_TheCompany_JobLog values('Scheduled_Weekly', getdate(),'[TheCompany_Maintenance_AgreementTypes] START')

	delete from TAGREEMENT_TYPE 
		where AGREEMENT_TYPEID not in (select AGREEMENT_TYPEID from TCONTRACT)

	/* Contract Relation - MSA */

		update tcontract
		set contractrelationid = 5 /* Master Agreement */
		 where 
		 contractrelationid <>  5 /* msa */
		  and (contract like '% master %' and agreement_typeid = 1 /* MSA */) 
		  and contract not like '!AUTODELETE%'
		  and contract not like 'ARIBA#%'

		  /* other, purchase etc. to Master if keywords */
		update tcontract
			set contractrelationid = 5 /* Master Agreement */
		 where 
			 contractrelationid between 1 and 4 /* Other, sales, purchase, license old */
			  and (contract like '% master services%' 
					OR contract like '% MSA %' 
					OR contract like '% MASTER SA %' ) 
			  and contract not like '!AUTODELETE%'
			  and contract not like 'ARIBA#%'

		/* Contract relation - set to Other for HCX agreements set to 'purchase' */
		/* valerie linars feb-2021 */
		update TCONTRACT
			set CONTRACTRELATIONID = 3 /* Other */ 
		where contractrelationid = 1 /* Purchase */ /* <>3 not ok since MSA etc. too */
		and AGREEMENT_TYPEID in (select AgrTypeID from V_TheCompany_AgreementType
									where AgrType_IsHCX_Flag = 1)

		/*  select * from tcontract */



	/* convert blank type to consultancy */
		update tcontract
		set agreement_typeid = (select agreement_typeid from tagreement_type 
								where fixed = '!CNS! $DPT')
		where 
		contract like '%consultancy%'
		and (agreement_typeid is null OR AGREEMENT_TYPEID = 20 /* Other */)
		and contract not like '!AUTODELETE%'

	/* convert blank type to speaker */
		update tcontract
		set agreement_typeid = (select agreement_typeid from tagreement_type 
								where fixed like '!SP! PRIVATE $LEGAL%')
		where 
		contract like '%speaker%'
		and (agreement_typeid is null OR AGREEMENT_TYPEID = 20 /* Other */)
		and contract not like '!AUTODELETE%'

/* Vertrieb */

	/*	update tcontract
		set STRATEGYTYPEID = 21 /* HCP HCO */
		where 
		AGREEMENT_TYPEID in (select AGREEMENT_TYPEID from TAGREEMENT_TYPE where fixed like '%+HCX%')
		and (STRATEGYTYPEid IS NULL or STRATEGYTYPEid in (14 /* not sure */, 6 /* speaking engagement */))
		*/

		update tcontract
		set STRATEGYTYPEID = 21 /* HCP HCO */
			where 
			(STRATEGYTYPEid IS NULL or STRATEGYTYPEID in( 
				5 /* not applicable */
				, 10 /* blank */
				, 14 /* not sure */))
			and agreement_typeid in (5 /* cda */, 10 /*consultancy*/, 17 /* services one off */)
			and contractid in (select contractid from V_TheCompany_Departmentrole_In_Object 
				where roleid = 2 and department_code = '.DES*' /* Tak DE Vertrieb */)
			and [contract] not like 'ARIBA%'
			and contract not like '!AUTODELET%'
			and contractid in (select contractid from V_TheCompany_TTenderer_Tcompany 
				where (company like '%Dr.%' or company like '%Prof.%' 
						or company like '%hospital%' or company like '%pharmacy%' or company like '%Apotheke%') and company not like '%GmbH%')


	/*	update tcontract
		set STRATEGYTYPEID = 22 /* NON HCP HCO */
		where AGREEMENT_TYPEID in (select AGREEMENT_TYPEID from TAGREEMENT_TYPE where fixed like '%-HCX%')
		and (STRATEGYTYPEid IS NULL or STRATEGYTYPEID in( 5 /* not applicable */, 10 /* blank */, 14 /* not sure */))
		*/

/* HCP/HCO flags, must be done AFTER any agreement type conversions above */

	/* HcP/HCO where null , by agreement type*/
		 update tcontract
			set STRATEGYTYPEID = 21 /* HCP HCO */
		 where 
			STRATEGYTYPEID is NULL /* do not override user entries */
			AND AGREEMENT_TYPEID in (select [AgrTypeID] 
									from V_TheCompany_AgreementType 
									where AgrType_IsHCX_Flag = 1 /* +HCX */)

	/* HCP HCO PO Flag , where agreement type is not classified as HCX */
		 update tcontract
			set STRATEGYTYPEID = 21 /* HCP HCO */
		 where 
			STRATEGYTYPEID is NULL
			and (contract like '%HCP%' 				
				OR contract like '%Health Care%'
				OR contract like '%HCO%' 
				OR contract like '%Patient Org%'
				OR contract like '%Patient Assist%'
				) 
			  and contract not like '!AUTODELETE%'
			  and contract not like 'ARIBA#%' 

	/* NON HcP/HCO where null */
		 update tcontract
			set STRATEGYTYPEID = 22 /* NON-HCP/HCO */
		 where 
			STRATEGYTYPEID is NULL /* do not override user entries */
			AND AGREEMENT_TYPEID in (select [AgrTypeID] 
									from V_TheCompany_AgreementType 
									where AgrType_IsHCX_Flag = 0 /* -HCX */)

									
									/*			, (case when fixed like '%+HCX%' then 1
					when fixed like '%-HCX%' then 0
					else 2 end) as AgrType_IsHCX_Flag*/

	/* Blank agreement types */
		update TCONTRACT 
		set AGREEMENT_TYPEID = 20 /* Other */ 
		where AGREEMENT_TYPEID IS NULL

	/* T_TheCompany_AgreementType - Agreement Type Material Flag */
		insert into 
			[dbo].[T_TheCompany_AgreementType] 
		select 1 /* material flag */ 
			,AGREEMENT_TYPEID
			, AGREEMENT_TYPE
			, 1 /* Agr_IsDivestment_Flag */
		 from TAGREEMENT_TYPE 
		 where AGREEMENT_TYPEID not in (select agr_typeid 
			from [dbo].[T_TheCompany_AgreementType])

		update a
		set [AgrName] = ag.AGREEMENT_TYPE
		from 
			[T_TheCompany_AgreementType] a inner join TAGREEMENT_TYPE ag 
			on a.Agr_typeid = ag.AGREEMENT_TYPEID
		where 
			[AgrName] is null 
			OR [AgrName] <> ag.AGREEMENT_TYPE

	INSERT INTO T_TheCompany_JobLog values('Scheduled_Weekly', getdate(),'[TheCompany_Maintenance_AgreementTypes] END')

END

GO
/****** Object:  StoredProcedure [dbo].[TheCompany_2WEEKLY_RemapTT_IPToTT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_2WEEKLY_RemapTT_IPToTT]

/* Issue #341 - Remap TERRITORY field Internal Partner AND Department to Region Territory value */

/* Create Temp Mapping Table #tmp_dbo_tdptroleinobject */

AS

BEGIN

/* Create temp table */

	SELECT m.*, t.TargetDptID 
	into #tmp_dbo_tdptroleinobject
	FROM (SELECT o.OBJECTID
	, r.role 
	, r.roleid
	, d.department
	, d.departmentid as OrigDptID
	, d.department_code 
	, SUBSTRING(d.department_code,2,2) ctry2Digit

	FROM TDEPARTMENTROLE_IN_OBJECT o, TDEPARTMENT d, TROLE r
	WHERE r.roleid = o.roleid
	and d.departmentid = o.departmentid
	and (d.department_code like (',%') /*Internal Partner*/ OR d.department_code like ('.%') /*Department*/)
	and r.roleid =3 /*Territories*/) m,

	(SELECT 
	u.DEPARTMENTID TargetDptID
	, u.USERGROUP
	, d.department_code
	, SUBSTRING(d.department_code,2,2) as TargetCtry2Digit
	FROM TUSERGROUP u, TDEPARTMENT d
	WHERE 
	d.departmentid = u.departmentid
	and u.mik_valid = 1
	AND u.USERGROUP LIKE 'Territories - Region%') t
	WHERE m.ctry2Digit = t.TargetCtry2Digit

/* Update TDEPARTMENTROLE_IN_OBJECT' */

	UPDATE d
	set d.DEPARTMENTID = t.TargetDptID
	FROM TDEPARTMENTROLE_IN_OBJECT d
	inner join #tmp_dbo_tdptroleinobject t
	on d.DEPARTMENTID = t.OrigDptID
	and t.objectid = d.objectid
	and d.roleid = 3 /*Territories*/

	PRINT '[dbo].[TheCompany_341_RemapTT_InternalPartnerToTerritory] Result: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* Drop temp table #tmp_dbo_tdptroleinobject' */

	drop table #tmp_dbo_tdptroleinobject

/* delete duplicate territory entries that might be created after the update above */

DELETE FROM TDEPARTMENTROLE_IN_OBJECT WHERE [DEPARTMENTROLE_IN_OBJECTID] IN 
(
SELECT  MAX(DEPARTMENTROLE_IN_OBJECTID) 
from TDEPARTMENTROLE_IN_OBJECT
where roleid = 3 /* Territories */
group by OBJECTTYPEID, OBJECTID, DEPARTMENTID, ROLEID
HAVING COUNT(*)>1
)

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_2WEEKLY_RenameDTitleToCTitle]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[TheCompany_2WEEKLY_RenameDTitleToCTitle]

as

BEGIN

UPDATE
    d
SET
    d.DESCRIPTION = c.CTitlePlusDTitle
FROM
    tdocument d
INNER JOIN
    [V_TheCompany_Edit_DocAutoRenameCTitle] c
ON 
    d.objectid = c.contractid
WHERE  
len(d.DESCRIPTION) < 12 AND  
/* d.FILEINFOID in (select fileid from tfile where FileType = '.pdf') AND */
d.DOCUMENTTYPEid = 1 /* Signed Contracts */ AND
d.objectid in (select OBJECTID from TDOCUMENT 
						where mik_valid = 1 
						and d.DOCUMENTTYPEID = 1 /* Signed Contracts */
						group by OBJECTID having COUNT(*)=1)
/* 
select *
FROM
    tdocument d
INNER JOIN
    [V_TheCompany_Edit_DocAutoRenameCTitle] c
ON 
    d.objectid = c.contractid
WHERE  
len(d.DESCRIPTION) < 12 AND  
/* d.FILEINFOID in (select fileid from tfile where FileType = '.pdf') AND */
d.DOCUMENTTYPEid = 1 /* Signed Contracts */ AND
d.objectid in (select OBJECTID from TDOCUMENT 
						where mik_valid = 1 
						and d.DOCUMENTTYPEID = 1 /* Signed Contracts */
						group by OBJECTID having COUNT(*)=1)	*/
						
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_2WEEKLY_ReplaceUnderscoresWithDashes]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_2WEEKLY_ReplaceUnderscoresWithDashes]

AS

BEGIN

/* #368 - replace underscore with dash ' - ' so that names can be recognized */

/* Contract Description */
UPDATE [dbo].[tCONTRACT]
SET [contract] = REPLACE([contract], '_', ' - ')
where [contract] like '%[_]%'

PRINT '[dbo].[TheCompany_368_ReplaceUnderscoresWithDashes]'
PRINT 'Result Contract Description: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Altered'


/* Document Description */
UPDATE [tdocument]
SET [description] = REPLACE([description], '_', ' - ')
where [description] like '%[_]%'
and len(REPLACE([description], '_', ' - ')) <=255 /* field length must still suffice */

PRINT 'Result Document Description: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Altered'


END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_3SATNIGHT_AddCurrentIP_ForActiveContracts]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_3SATNIGHT_AddCurrentIP_ForActiveContracts]

AS

BEGIN

/* 11. Issue #373 Internal Partner: Add current Internal Partner(s) to obsolete ones for active contracts*/
/* Script must run multiple times, at least 3 times, to cover all hierarchy nestings until record count in last run is zero */

PRINT '11. Issue #373 Internal Partner: Add current Internal Partner(s)'

PRINT '		Insert new Internal Partner rows: '

/* 1.  Obsolete entities that are in subnodes underneath the current entity due to having been merged in or that had a name change */

INSERT INTO TDEPARTMENTROLE_IN_OBJECT (OBJECTTYPEID, OBJECTID, ROLEID, DEPARTMENTID ) 
	SELECT DISTINCT
	r.objecttypeid
	,r.objectid
	,r.roleid
	,d1.parentid
	/*, d1.DEPARTMENT  REMOVE */
	FROM
		TDEPARTMENTROLE_IN_OBJECT r
		inner join tdepartment d1 on r.departmentid = d1.departmentid
		inner join tdepartment d2 on d1.parentid = d2.departmentid 
		left join tdepartment d3 on d2.parentid = d3.departmentid
	WHERE SUBSTRING(d1.department_code,1,1) = ',' /* idea: include territories too ? */
		and r.ROLEID IN(
			0 /* ENTITY - CREATOR */
			, 6 /*ENTITY*/
			,   100 /*INTERNAL PARTNER*/
			) 
		and NOT EXISTS (
			   select DEPARTMENTROLE_IN_OBJECTID 
			   from TDEPARTMENTROLE_IN_OBJECT r2 
			   where 
			   r2.roleid = r.roleid
			   and r2.objectid = r.objectid
			   and r2.departmentid = d1.parentid
		)
		and d1.parentid <>10004 /* do not add Internal Partner Root */
		AND d1.parentid <> 204318 /* Inactive Entity Node */
		AND r.objectid IN (SELECT CONTRACTID FROM TCONTRACT WHERE statusid = 5 /* Active */)
		AND r.objectid NOT IN (SELECT CONTRACTID 
								FROM TCONTRACT 
								WHERE CONTRACTTYPEID in('6' /* Access SAKSNR number Series*/
									,'5' /* Test Old */,'102' /* Test New */,'13' /* DELETE */ ))


/* 2. Branch offices, add head office, currently 3 offices for TPIZ with code e.g. ,SG,UK, Ireland */		
							
INSERT INTO TDEPARTMENTROLE_IN_OBJECT (OBJECTTYPEID, OBJECTID, ROLEID, DEPARTMENTID ) 
	SELECT DISTINCT
	r.objecttypeid
	,r.objectid
	,r.roleid
	/* , d1.departmentid /* Branch office */*/
	,d1.DptID_HeadOffice
	FROM TDEPARTMENTROLE_IN_OBJECT r
		inner join  [V_TheCompany_VDepartment_ParsedDpt_InternalPartner] d1 
		on r.departmentid = d1.departmentid /* e.g. CHI */
	WHERE 
		LEFT(d1.department_code,1) = ',' /* idea: include territories too ? */
		and r.roleid = 100 /* Internal Partner */
		and d1.department_code like '%BranchOffice%'
		AND d1.[PARENTID] <> 204318 /* Inactive Entity Node */
		and d1.DptID_HeadOffice is not null
		and NOT EXISTS (
			   select DEPARTMENTROLE_IN_OBJECTID 
			   from TDEPARTMENTROLE_IN_OBJECT r2 
			   where 
			   r2.roleid IN(0 /* ENTITY - CREATOR */
					, 6 /*ENTITY*/
					, 100 /*INTERNAL PARTNER*/
					) 
			   and r2.objectid =  r.objectid 
			   and r2.departmentid = d1.DptID_HeadOffice /* 204044 for TPIZ */
		)
		/* AND r.objectid IN (SELECT CONTRACTID FROM TCONTRACT WHERE statusid = 5 /* Active */) */
		AND r.objectid NOT IN (SELECT CONTRACTID 
								FROM TCONTRACT 
								WHERE CONTRACTTYPEID in('6' /* Access SAKSNR number Series*/
									,'5' /* Test Old */,'102' /* Test New */,'13' /* DELETE */ ))

PRINT '11. Issue #373 Internal Partner: Add current Internal Partner(s): ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* Adhoc, insewrt IP for gold std records where missing */

/*	INSERT INTO TDEPARTMENTROLE_IN_OBJECT (OBJECTTYPEID, OBJECTID, ROLEID, DEPARTMENTID )
	SELECT DISTINCT
	1 /* contract */
	, contractid
	, 100 /* IP */
	, 203266 /* chig, TPI Gmbh */
	/*, d1.DEPARTMENT  REMOVE */
	FROM
		tcontract
	WHERE contractid not in (select objectid from 
			V_TheCompany_vdepartmentrole_in_object 
			where ROLEID IN(0,6/*ENTITY*/,100 /*INTERNAL PARTNER*/))
	and contractid in (select contractid from [V_TheCompany_LNC_GoldStandard])
*/
/*
	select * from t_TheCompany_all where internalpartners =''
	update T_TheCompany_ALL_Xt
		set [InternalPartners_IDs] = '203266' 
		, [InternalPartners] = '(Switzerland) TheCompany Pharmaceuticals International GmbH'
		, [InternalPartners_COUNT] = 1
		where internalpartners =''


		*/
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_3SATNIGHT_AddDocumentTag_FullText]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_3SATNIGHT_AddDocumentTag_FullText]
AS
/* Notes:
Currently excluding lots of names with special chars to be sure
retest
*/

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

DECLARE @KEYWORD AS VARCHAR(255)
DECLARE @TAGID SMALLINT
DECLARE @CONTRACTNUMBER AS VARCHAR(20)
DECLARE @DOCTITLE AS VARCHAR(255)
DECLARE @KEYWORDQUOTE AS VARCHAR(300)

DECLARE @OBJECTID bigint 
DECLARE @OBJECTTYPEID bigint 
DECLARE @DOCUMENTID bigint 
DECLARE @DOC_COUNT bigint 
DECLARE @SQLOBJECTIDS as VARCHAR (1000)
DECLARE @DATEREGISTERED as datetime

BEGIN
/*
delete from [dbo].[TTAG_IN_OBJECT]
where tagid in (select tagid from T_TheCompany_Tag_in_Document)
*/



/* TheVendor Tag Tables
[dbo].[TTAG] 
[dbo].[TTAG_IN_OBJECT]
*/

/*dbo.T_TheCompany_Tag_in_Document
 [V_TheCompany_TTag_Summary] */
/*
select sum([Count])
  FROM [TheVendor_app].[dbo].[V_TheCompany_TTag_Summary]
  */

	DECLARE curLabels CURSOR LOCAL FAST_FORWARD FOR

	select TagID, Keyword from [dbo].[T_TheCompany_Tag_in_Document] /* Aliases, language equivalents, thesaurus */
	/* WHERE TagID in (41) /*  privacy remediation */ */

	OPEN curLabels

	FETCH NEXT FROM curLabels INTO @TAGID, @KEYWORD
	WHILE @@FETCH_STATUS = 0 BEGIN

		SET @KEYWORDQUOTE =  '"' + @KEYWORD + '"'
		PRINT @KEYWORDQUOTE
		PRINT 'Keyword: '  + @KEYWORD + ', ID: ' + convert(varchar(10),@TAGID)
		PRINT 'TAGID: ' + convert(varchar(10),@TAGID)

			BEGIN 

				DECLARE curDocuments CURSOR LOCAL FAST_FORWARD FOR

				SELECT 
					d.DOCUMENTID
					/*, d.OBJECTTYPEID /* 1 - contract */
					,count(d.DOCUMENTID) as DOC_COUNT */
				FROM tdocument d  
					inner join TFILEINFO i on d.DOCUMENTID = i.documentid
					INNER JOIN TFILE f ON i.FileId = f.FileID
				WHERE /* d.documentid = 131879 AND */
				f.FileId IN (SELECT KEY_TBL.[KEY] 
							FROM CONTAINSTABLE(TFILE, [File], @KEYWORDQUOTE ) AS KEY_TBL 
							) 
					AND d.MIK_VALID = N'1' /* active documents */
					AND f.filetype NOT LIKE '%.xl%' /* exclude registration form */ /* AND c.CONTRACTTYPEID  NOT IN  (103,104,101, 13, 5, 102, 6) */
					AND f.filetype not like '%.msg%' /* exclude Outlook */
					AND d.DOCUMENTID NOT IN (SELECT OBJECTID from TTAG_IN_OBJECT 
						WHERE TAGID = @TAGID AND OBJECTTYPEID = 7 /* document , do not use d.OBJECTTYPEID since it is 1 */)
				GROUP BY d.DOCUMENTID   /*, d.DOCUMENTID */

				OPEN curDocuments
				
					FETCH NEXT FROM curDocuments INTO @DOCUMENTID /*, @CONTRACTNUMBER, @DATEREGISTERED */				
				
					WHILE @@FETCH_STATUS = 0 
						BEGIN
							
							PRINT 'curDocuments DOCUMENTID: ' + convert(varchar(10),@DOCUMENTID) + ', TagID ' + convert(varchar(10),@TAGID)
					
	PRINT 'input check OBJECTID' + str(@OBJECTID)
	PRINT 'input check DOCUMENTID' + str(@DOCUMENTID)
	PRINT 'OBJECTTYPEID' + str(@OBJECTTYPEID)
	PRINT 'TAGID' + str(@TAGID)

						EXEC [dbo].[TheCompany_TagUpload_DocumentID] 
							@TAGID
							, 7 /* 7 = document do not use @OBJECTTYPEID since it is 1 */
							, @DOCUMENTID /* OBJECTID */
					FETCH NEXT FROM curDocuments INTO @DOCUMENTID
					END
				
					END  
				
				CLOSE curDocuments

				DEALLOCATE curDocuments

	FETCH NEXT FROM curLabels INTO @TAGID, @KEYWORD
				
	END /* curLabels */

/* delete from T_TheCompany_Product_Upload */
	CLOSE curLabels
	DEALLOCATE curLabels

	SET @RESULTSTRING = 'Success' 

GOTO lblEnd 

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'


lblEnd: 
PRINT '*** END'


END 
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_3SATNIGHT_CorrectContractStatus]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_3SATNIGHT_CorrectContractStatus]

AS 

BEGIN

/* please also see  [dbo].[TheCompany_Maintenance_ContractStatus_CheckAndCorrection] */

	update tcontract
	set statusid = 5 /* active */
	/* select * from tcontract */
	where 
	statusid not in (4 /* awarded */, 5 /* active */) /* awarded or active */
	and CONTRACTTYPEID not in ( 13 /* DELETE */, 106 /* AutoDelete */)
	AND (
		(CASE WHEN REV_EXPIRYDATE is not null then REV_EXPIRYDATE else EXPIRYDATE end) is null
		or (CASE WHEN REV_EXPIRYDATE is not null then REV_EXPIRYDATE else EXPIRYDATE end) > GETDATE() /* no revised expiry further into the future */
		)

/* Set to expired if expiry date has passed */

	update tcontract
	set statusid = 6 /* expired */
	/* select * from tcontract */
	where 
	statusid in (/*4 /* awarded - skip, this resets itself */,*/ 5 /* active */) /* awarded or active */
	and (CASE WHEN REV_EXPIRYDATE is not null then REV_EXPIRYDATE else EXPIRYDATE end) is not null
	and (CASE WHEN REV_EXPIRYDATE is not null then REV_EXPIRYDATE else EXPIRYDATE end) < GETDATE() /* no revised expiry further into the future */


	/*	UPDATE TCONTRACT 
		SET STATUSID = 6 /*Expired*/
		WHERE STATUSID = 5 /*Active*/
			AND 
			(([REV_EXPIRYDATE] is not null  or [EXPIRYDATE] is not null)
			AND ([REV_EXPIRYDATE] is null OR [REV_EXPIRYDATE] < GETDATE()-1) /*Date minus one day for status workflow delay*/
			AND ([EXPIRYDATE] is null OR [EXPIRYDATE] < GETDATE()-1) 
			)

		UPDATE TCONTRACT 
		SET STATUSID = 5 /*Active*/
		WHERE CONTRACTTYPEID not in ( 13 /* DELETE */, 106 /* AutoDelete */)
		AND STATUSID = 6 /*Expired*/
		AND 
		(([REV_EXPIRYDATE] is null  AND [EXPIRYDATE] is null)
		OR ([REV_EXPIRYDATE] is null AND [EXPIRYDATE] > GETDATE()+1) /*Date plus one day for status workflow delay*/
		OR ([REV_EXPIRYDATE] > GETDATE()+1) 
		)
		*/

		update tCONTRACT
		set [DEFINEDENDDATE] = 0 /* No defined end date */
		where 
		([EXPIRYDATE] is null AND [REV_EXPIRYDATE] is null)
		and [DEFINEDENDDATE] = 1


		update tCONTRACT
		set [DEFINEDENDDATE] = 1 /* Has a defined end date */
		where
		([EXPIRYDATE] is not null OR [REV_EXPIRYDATE] is not null)
		and [DEFINEDENDDATE] = 0
	
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_3SATNIGHT_FlagBlank_CountryCityStreet]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_3SATNIGHT_FlagBlank_CountryCityStreet]

as


BEGIN

Update TCOMPANYADDRESS
set ADDRESSLINE4 = '?' /*City*/
where ADDRESSLINE4 is null

Update TCOMPANYADDRESS
set ADDRESSLINE1 = '?' /*Street*/
where ADDRESSLINE1 is null

Update TCOMPANYADDRESS
set COUNTRYID = 251 /*?*/
where COUNTRYID is null

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_3SATNIGHT_FlagNoFiles]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_3SATNIGHT_FlagNoFiles]

AS

BEGIN

 
/* 6 '*NO FILES*' Flag SEE TheCompany_319_FlagNoFiles */

/* 6a remove flag ' *NO FILES*' from contracts that have a document attached */

	update [TCONTRACT]
	set [CONTRACT]=  RTRIM(REPLACE([CONTRACT], '*NO FILES*', '')) /* remove flag */
	where 
	[CONTRACT] LIKE ('%*NO FILES*%') /* has flag */
	AND [CONTRACT] NOT LIKE ('%DELETE (NO FILES FOR OVER 2 YEARS): %')
	/* [V_TheCompany_VDOCUMENT] WITH AMENDMENT!!!! */
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
	AND CONTRACTID 	/* [V_TheCompany_VDOCUMENT] WITH AMENDMENT!!!! */ NOT IN (SELECT OBJECTID from TDOCUMENT) /* does not have attachment */
	AND LEN([CONTRACT] +' *NO FILES*') <=255 /* would not exceed field size */
	AND contracttypeid NOT IN ('6' /*Access*/,'11'  /*Case*/, '13' /* DELETE */, '102' /* TEST */) /* junk */
	and getdate() > dateadd(hh,+27,contractdate)   /* has been registered for more than 1 day */

/* 6c add flag 'DELETE (NO FILES FOR OVER 2 YEARS' and mark as AUTODELETE */

	update [TCONTRACT]
	set [CONTRACT]= SUBSTRING('DELETE (NO FILES FOR OVER 2 YEARS): '+[CONTRACT],1,255)
	where 
	[CONTRACT] NOT LIKE ('%DELETE (NO FILES FOR OVER 2 YEARS): %') /* flag not already set */
	AND CONTRACTID 	/* [V_TheCompany_VDOCUMENT] WITH AMENDMENT!!!! */ NOT IN (SELECT OBJECTID from TDOCUMENT where MIK_VALID = 1) /* does not have attachment */
	AND contracttypeid NOT IN ('11' /*Case*/, '13' /* DELETE */, '102' /* TEST */)
	and getdate() > dateadd(yy,+2,contractdate)   /* has been registered for more than 2 years */

	/* AUTODELETE if older than 2 years */
		update [TCONTRACT]
		set [COUNTERPARTYNUMBER]= '!AUTODELETE'
		where 
		CONTRACTID 	/* [V_TheCompany_VDOCUMENT] WITH AMENDMENT!!!! */ NOT IN (SELECT OBJECTID from TDOCUMENT where MIK_VALID = 1) /* does not have attachment */
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
/****** Object:  StoredProcedure [dbo].[TheCompany_3SATNIGHT_PrdGrpUpload_ARB_Description]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[TheCompany_3SATNIGHT_PrdGrpUpload_ARB_Description]
AS

/* run time on 23-Apr was 3 hours 14 min - worth streamlining like TheVendor script? */

DECLARE @RESULTSTRING AS VARCHAR(255)

DECLARE @PRODUCTGROUP AS VARCHAR(255)
DECLARE @CONTRACTNUMBER AS VARCHAR(50)
DECLARE @CONTRACTINTERNALID AS VARCHAR(50)
DECLARE @DESCRIPTION AS VARCHAR(255)

DECLARE @SOURCENAME AS VARCHAR(255)
DECLARE @MATCHLEVEL AS int
DECLARE @PRODUCTGROUP_LEN AS int

DECLARE @PRODUCTGROUP_LEFTBLANK AS VARCHAR(300)
DECLARE @PRODUCTGROUP_MID AS VARCHAR(300)
DECLARE @PRODUCTGROUP_RIGHTBLANK AS VARCHAR(300)

DECLARE @PRODUCTGROUPID bigint
DECLARE @OBJECTID bigint 
DECLARE @SQLOBJECTIDS as VARCHAR (1000)
DECLARE @DATEREGISTERED as datetime

BEGIN

DECLARE curProducts CURSOR LOCAL FAST_FORWARD FOR

select PRODUCTGROUPID, PRODUCTGROUP 
from V_TheCompany_VPRODUCTGROUP /* p  inner join T_TheCompany_KeyWordSearch k on p.PRODUCTGROUP = k.KeyWordVarchar255 */
WHERE PRODUCTGROUPNOMENCLATUREID IN('2','3') 
/*AND Productgroup_MIK_VALID = 1*/
and ([blnNumHashes]<2 /* one hash or no hash */ or [blnNumHashes] is null)
AND LEN(PRODUCTGROUP)>2 /* 2 , fuzzy match cutoff is set to 5 below, only exact matches for 3 char len */ 
/* and Productgroupid in (6431) */

OPEN curProducts

FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
WHILE @@FETCH_STATUS = 0 BEGIN

		SET @PRODUCTGROUP_RIGHTBLANK = @PRODUCTGROUP + '[^a-z]%' 

		SET @PRODUCTGROUP_MID = '%[^a-z]' + @PRODUCTGROUP + '[^a-z]%'

		SET @PRODUCTGROUP_LEFTBLANK = '%[^a-z]' + @PRODUCTGROUP
		SET @PRODUCTGROUP_LEN = len(@PRODUCTGROUP)

			PRINT 'Product Group: '  + @PRODUCTGROUP 
			PRINT @PRODUCTGROUPID
/************************** CHECK IF ANY RECORDS */
		 IF EXISTS (
			SELECT 1
			FROM T_TheCompany_AribaDump c 
				WHERE (/* c.[All Products] like '%' + @PRODUCTGROUP + '%' *//* should not be needed OR */
					c.[Contract Description] like '%' + @PRODUCTGROUP + '%'
					OR c.[Additional Comments] like '%' + @PRODUCTGROUP + '%'
					OR c.[Project - Project Name] like '%' + @PRODUCTGROUP + '%'
					OR c.[Parent Agreement - Project Name] like '%' + @PRODUCTGROUP + '%'
					OR c.[Study Number] like '%' + @PRODUCTGROUP + '%' )
			AND ContractNumber NOT IN (SELECT ContractNumber
					from T_TheCompany_Ariba_Products_In_Contracts
					WHERE PRODUCTGROUPID = @PRODUCTGROUPID)
						)

			BEGIN
	
			PRINT ' at least one record to add for product' +@PRODUCTGROUP 
				/* sub loop contract upload */

/************************** CHECK IF ANY RECORDS */

/*!!! Exact Match Level = 1 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
				
				SET @SOURCENAME ='DescriptionEtc'
				SET @MATCHLEVEL = 1
				DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR

				SELECT @PRODUCTGROUPID AS PRD 
					, @PRODUCTGROUP AS PRDGRP 
					, c.CONTRACTNUMBER
					, c.CONTRACTINTERNALID
					, max(c.[Begin Date]) as [Begin Date]
					, c.[Contract Description]
				FROM T_TheCompany_AribaDump c 
			WHERE (c.[Contract Description] like @PRODUCTGROUP_LEFTBLANK 
				OR c.[Contract Description] like @PRODUCTGROUP_MID 
				OR c.[Contract Description] like @PRODUCTGROUP_RIGHTBLANK 
				/* Additional Comments */
				OR c.[Additional Comments] like @PRODUCTGROUP_LEFTBLANK 
				OR c.[Additional Comments] like @PRODUCTGROUP_MID 
				OR c.[Additional Comments] like @PRODUCTGROUP_RIGHTBLANK 
				/* Project Name */
				OR c.[Project - Project Name] like @PRODUCTGROUP_LEFTBLANK 
				OR c.[Project - Project Name] like @PRODUCTGROUP_MID 
				OR c.[Project - Project Name] like @PRODUCTGROUP_RIGHTBLANK
				/* Parent Agreement */
				OR c.[Parent Agreement - Project Name] like @PRODUCTGROUP_LEFTBLANK 
				OR c.[Parent Agreement - Project Name] like @PRODUCTGROUP_MID 
				OR c.[Parent Agreement - Project Name] like @PRODUCTGROUP_RIGHTBLANK
				/* Study Number */
				OR c.[Study Number] like @PRODUCTGROUP_LEFTBLANK 
				OR c.[Study Number] like @PRODUCTGROUP_MID 
				OR c.[Study Number] like @PRODUCTGROUP_RIGHTBLANK 
				)
				AND ContractNumber NOT IN (SELECT ContractNumber
						from T_TheCompany_Ariba_Products_In_Contracts
						WHERE PRODUCTGROUPID = @PRODUCTGROUPID)													
				GROUP BY c.CONTRACTNUMBER , c.CONTRACTINTERNALID, c.[Contract Description]

				OPEN curContracts
					
				FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @CONTRACTNUMBER, @CONTRACTINTERNALID,  @DATEREGISTERED, @DESCRIPTION
				WHILE @@FETCH_STATUS = 0 BEGIN
					PRINT @PRODUCTGROUP
					PRINT @CONTRACTNUMBER
					PRINT @DESCRIPTION
						EXEC TheCompany_ProductGroupUpload_ObjectidProductgroupID_ARIBA @CONTRACTNUMBER,  @CONTRACTINTERNALID, @PRODUCTGROUPID, @SOURCENAME,@MATCHLEVEL

						FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @CONTRACTNUMBER, @CONTRACTINTERNALID,  @DATEREGISTERED, @DESCRIPTION
				END
				/* loop 2 */
				CLOSE curContracts
				DEALLOCATE curContracts

/*!!! Fuzzier Match Level = 2 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/		
				SET @SOURCENAME ='DescriptionEtc'
				SET @MATCHLEVEL = 2			
				DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR

				SELECT @PRODUCTGROUPID AS PRD 
					, @PRODUCTGROUP AS PRDGRP 
					, c.CONTRACTNUMBER
					, c.CONTRACTINTERNALID 
					, max(c.[Begin Date]) as [Begin Date]
					, c.[Contract Description]
				FROM T_TheCompany_AribaDump c 
				WHERE (c.[Contract Description] like '%' + @PRODUCTGROUP + '%'
					OR c.[Additional Comments] like '%' + @PRODUCTGROUP + '%'
					OR c.[Project - Project Name] like '%' + @PRODUCTGROUP + '%'
					OR c.[Parent Agreement - Project Name] like '%' + @PRODUCTGROUP + '%'
					OR c.[Study Number] like '%' + @PRODUCTGROUP + '%' )
				AND ContractNumber NOT IN (SELECT ContractNumber
						from T_TheCompany_Ariba_Products_In_Contracts
						WHERE PRODUCTGROUPID = @PRODUCTGROUPID)		
					AND @PRODUCTGROUP_LEN > 5 /* not too short for fuzzy */					
				GROUP BY c.CONTRACTNUMBER , c.CONTRACTINTERNALID, c.[Contract Description]

				OPEN curContracts
					
				FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @CONTRACTNUMBER, @CONTRACTINTERNALID,  @DATEREGISTERED, @DESCRIPTION
				WHILE @@FETCH_STATUS = 0 BEGIN
					PRINT @PRODUCTGROUP
					PRINT @CONTRACTNUMBER
					PRINT @DESCRIPTION
						EXEC TheCompany_ProductGroupUpload_ObjectidProductgroupID_ARIBA @CONTRACTNUMBER,  @CONTRACTINTERNALID, @PRODUCTGROUPID, @SOURCENAME,@MATCHLEVEL
		   
						FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @CONTRACTNUMBER,  @CONTRACTINTERNALID,  @DATEREGISTERED, @DESCRIPTION
				END
				/* loop 2 */
				CLOSE curContracts


				DEALLOCATE curContracts
	
		END
		ELSE PRINT 'SKIP PRODUCT: No new records to add for : '  + @PRODUCTGROUP

		FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
END

	CLOSE curProducts
	DEALLOCATE curProducts
	SET @RESULTSTRING = 'Success'

GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'


lblEnd: 
PRINT '*** END'



END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_3SATNIGHT_PrdGrpUpload_CNT_Description]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_3SATNIGHT_PrdGrpUpload_CNT_Description]
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

DECLARE @PRODUCTGROUP AS VARCHAR(255)
DECLARE @CONTRACTNUMBER AS VARCHAR(20)
DECLARE @DESCRIPTION AS VARCHAR(255)
DECLARE @PRODUCTGROUP_LEFTBLANK AS VARCHAR(300)
DECLARE @PRODUCTGROUP_MID AS VARCHAR(300)
DECLARE @PRODUCTGROUP_RIGHTBLANK AS VARCHAR(300)
DECLARE @PRODUCTGROUPID SMALLINT
DECLARE @OBJECTID bigint 
DECLARE @SQLOBJECTIDS as VARCHAR (1000)
DECLARE @DATEREGISTERED as datetime
DECLARE @DEBUG_OUTPUT as bit

BEGIN
/* WHEN NEW PRODUCTS ARE ADDED, or old ones modified, run the procedure WITHOUT the date filter  to make sure the product is tagged in older records too */
	SET @DEBUG_OUTPUT = 1 /* 0 = no debug info, 1 = debug */

	DECLARE curProducts CURSOR LOCAL FAST_FORWARD FOR

	SELECT /* top 100 */ PRODUCTGROUPID, PRODUCTGROUP 
	FROM V_TheCompany_VPRODUCTGROUP 
	WHERE PRODUCTGROUPNOMENCLATUREID IN('2' /* AI */,'3','7' /* Project ID */) 
		AND ProductGroup_MIK_VALID = 1 /* 2563 rows instead of over 4000 */
		/* and [blnNumHashes]<2 /* one hash or no hash for FULL TEXT */ */
		AND LEN(PRODUCTGROUP)>2 /* GEM to be included, 2 char = 2563, 3 char 2559, 4 char 2524, 
			5 char 2354. 8 char 1130 , 9 char 776 , 10 char 498, 11 char 317, 12 char 216 , 13 char 140 */ 
	/* and productgroup = 'XEFOCAM' */
	/* order by [Product_ContractCount] desc */

	OPEN curProducts	

	IF (@DEBUG_OUTPUT = 1) PRINT '1 - Open CurProducts ***';

	FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
	WHILE @@FETCH_STATUS = 0 BEGIN
					IF (@DEBUG_OUTPUT = 1)  PRINT '*********************************************'
					IF (@DEBUG_OUTPUT = 1)  PRINT 'PRODUCTGROUP: ' + @PRODUCTGROUP;
			SET @PRODUCTGROUP_RIGHTBLANK = @PRODUCTGROUP + '[^a-z]%' 	

			SET @PRODUCTGROUP_MID = '%[^a-z]' + @PRODUCTGROUP + '[^a-z]%'

			SET @PRODUCTGROUP_LEFTBLANK = '%[^a-z]' + @PRODUCTGROUP

				/* PRINT 'Product Group: '  + @PRODUCTGROUP 
				PRINT @PRODUCTGROUPID */
	
			IF EXISTS (
				SELECT 1
				FROM tcontract c 
				WHERE 
				(c.CONTRACT like @PRODUCTGROUP_LEFTBLANK 
					OR c.CONTRACT like @PRODUCTGROUP_MID
					OR c.CONTRACT like @PRODUCTGROUP_RIGHTBLANK
					OR c.CONTRACTID in (select objectid from TDOCUMENT d
						where OBJECTTYPEID = 1 /* contract */
						and 
							(d.document like @PRODUCTGROUP_LEFTBLANK 
							OR d.document like @PRODUCTGROUP_MID
							OR d.document like @PRODUCTGROUP_RIGHTBLANK
							)
					))
				/* filter to include NEW contracts only BUT if new products are added then this needs to be taken out */
				AND (c.CONTRACTID in (select objectid from V_TheCompany_Audittrail_ModLast30DaysMin1DayOld where OBJECTTYPEID = 1) 
					OR c.CONTRACTID in (select objectid from tdocument 
							where documentid in (select objectid 
								from V_TheCompany_Audittrail_ModLast30DaysMin1DayOld where OBJECTTYPEID = 7 /* document */ ) 
										)
					OR @PRODUCTGROUPID > 6492 /* new record added after Apr-2020 */
						)
				AND c.CONTRACTDATE < dateadd(dd,-1,GETDATE()) /* at least one day old so that no crashes if record being put in */ 
				AND CONTRACTID NOT IN (SELECT contractid 
						from TPROD_GROUP_IN_CONTRACT 
						WHERE PRODUCTGROUPID = @PRODUCTGROUPID)
				AND CONTRACTTYPEID not in (/* '11' /*Case*/ */
											'6' /* Access */ /* 
											, '5' Test Old */ /* ,'102'Test New */
											,'13' /* DELETE */ 
											,'103' /*file*/
											,'104' /*corp file*/)
					AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!AUTODELETE')
					AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!ARIBA%')
				)
			
				BEGIN /* at least one record for product */
	
					PRINT ' exists at least 1 record'
					/* sub loop contract upload */
				
					DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR

					SELECT @PRODUCTGROUPID AS PRD 
						, @PRODUCTGROUP AS PRDGRP 
						, CONTRACTID
						, c.contractnumber
						, c.contractdate
						, c.CONTRACT
					FROM tcontract c 
					WHERE 
						(c.CONTRACT like @PRODUCTGROUP_LEFTBLANK 
							OR c.CONTRACT like @PRODUCTGROUP_MID
							OR c.CONTRACT like @PRODUCTGROUP_RIGHTBLANK
							OR c.CONTRACTID in (select objectid from TDOCUMENT d
								where OBJECTTYPEID = 1 /* contract */
								and 
									(d.document like @PRODUCTGROUP_LEFTBLANK 
									OR d.document like @PRODUCTGROUP_MID
									OR d.document like @PRODUCTGROUP_RIGHTBLANK
									)
							))
				/* filter to include NEW contracts only BUT if new products are added then this needs to be taken out */
				AND (c.CONTRACTID in (select objectid from V_TheCompany_Audittrail_ModLast30DaysMin1DayOld where OBJECTTYPEID = 1) 
					OR c.CONTRACTID in (select objectid from tdocument 
							where documentid in (select objectid 
								from V_TheCompany_Audittrail_ModLast30DaysMin1DayOld where OBJECTTYPEID = 7 /* document */ ) 
										)
					OR @PRODUCTGROUPID > 6492 /* new record added after Apr-2020 */
						)
					AND c.CONTRACTDATE < dateadd(dd,-1,GETDATE()) /* at least one day old so that no crashes if record being put in */ 
						AND CONTRACTID NOT IN (SELECT contractid 
								from TPROD_GROUP_IN_CONTRACT 
								WHERE PRODUCTGROUPID = @PRODUCTGROUPID)
						AND CONTRACTTYPEID not in (/* '11' /*Case*/ */
													'6' /* Access */ /* 
													, '5' Test Old */ /* ,'102'Test New */
													,'13' /* DELETE */ 
													,'103' /*file*/
													,'104' /*corp file*/)
						AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!AUTODELETE')
						AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!ARIBA%')
					GROUP BY CONTRACTID, c.contractnumber, c.contractdate, c.contract

					/* contracts cursor */
						OPEN curContracts
					
						/* Initial Fetch */
						FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @OBJECTID, @CONTRACTNUMBER, @DATEREGISTERED, @DESCRIPTION

						/* Fetch loop while there are records */
							WHILE @@FETCH_STATUS = 0 BEGIN

								PRINT 'PRODUCTGROUP: ' + @PRODUCTGROUP + ' - (TheCompany_2WEEKLY_ProductGroupUpload_Description)'
								PRINT @CONTRACTNUMBER
								PRINT @DESCRIPTION

									EXEC TheCompany_ProductGroupUpload_ObjectidProductgroupID 
									@OBJECTID
									, @PRODUCTGROUPID
									, 1 /* OBJECTTYPEID */
									, @PRODUCTGROUP
									, @DESCRIPTION
									, @CONTRACTNUMBER
									, @DATEREGISTERED

									FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @OBJECTID, @CONTRACTNUMBER, @DATEREGISTERED, @DESCRIPTION
							
							END  /* at least one record for product */
						/* end fetch loop */

						CLOSE curContracts
						DEALLOCATE curContracts		
			END

			ELSE 

				IF @DEBUG_OUTPUT = 1 
				PRINT '  No (new) records for : '  + @PRODUCTGROUP +' (TheCompany_2WEEKLY_ProductGroupUpload_Description)';

			FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
	END

		CLOSE curProducts
		DEALLOCATE curProducts
		SET @RESULTSTRING = '  Successfully completed, END CurProducts (TheCompany_2WEEKLY_ProductGroupUpload_Description)'

		GOTO lblEnd

	lblTerminate: 
		PRINT 'lblTerminate: !!! Statement did not execute due to invalid input values! (TheCompany_2WEEKLY_ProductGroupUpload_Description)'

	lblEnd: 
		
		/* Archive upload table records older than 14 days */
		EXEC [dbo].[TheCompany_ProductGroupUpload_ArchiveLogTable]

		PRINT @RESULTSTRING

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_3SATNIGHT_PrdGrpUpload_CNT_FullText]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_3SATNIGHT_PrdGrpUpload_CNT_FullText]
AS
/* Notes:
Currently excluding lots of names with special chars to be sure
retest
*/

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

DECLARE @PRODUCTGROUP AS VARCHAR(255)
DECLARE @CONTRACTNUMBER AS VARCHAR(20)
DECLARE @DOCTITLE AS VARCHAR(255)
DECLARE @PRODUCTGROUPQUOTE AS VARCHAR(300)
DECLARE @PRODUCTGROUPID SMALLINT
DECLARE @OBJECTID bigint 
DECLARE @OBJECTTYPEID bigint 
DECLARE @DOCUMENTID bigint 
DECLARE @DOC_COUNT bigint 
DECLARE @SQLOBJECTIDS as VARCHAR (1000)
DECLARE @DATEREGISTERED as datetime

BEGIN


	DECLARE curProducts CURSOR LOCAL FAST_FORWARD FOR

	select PRODUCTGROUPID, PRODUCTGROUP 
	from V_TheCompany_VPRODUCTGROUP 
	WHERE 
	PRODUCTGROUP LIKE '%[a-z]%' /* not just numbers */
	/* AND PRODUCTGROUP like '% %' */ /* Vitamin B12 skipped */
	AND PRODUCTGROUP NOT LIKE '%-%'
	AND PRODUCTGROUPNOMENCLATUREID IN('2','3') /* Trade names and active ingredients */
	and [ProductGroup_LEN] >2
	and PRODUCTGROUP not like '%[1-9]%'
	and PRODUCTGROUP not like '%.%'
	AND [ProductGroup_MIK_VALID] = 1 
	/*and productgroupid =6431 */

	OPEN curProducts

	FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
	WHILE @@FETCH_STATUS = 0 BEGIN

		SET @PRODUCTGROUPQUOTE = '"' + @PRODUCTGROUP + '"' 
		PRINT @PRODUCTGROUPQUOTE
		PRINT 'Product Group: '  + @PRODUCTGROUP + ', ID: ' + convert(varchar(10),@PRODUCTGROUPID)

			BEGIN 

				DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR
				
				SELECT @PRODUCTGROUPID AS PRD
					, d.OBJECTID
					, d.OBJECTTYPEID
					, max(d.DOCUMENTID) as Doc_MaxID
					,COUNT(d.documentid) as Doc_Count
				FROM tdocument d  inner join TFILEINFO i on d.DOCUMENTID = i.documentid
					INNER JOIN TFILE f ON i.FileId = f.FileID
				WHERE f.FileId IN (SELECT KEY_TBL.[KEY] FROM CONTAINSTABLE(TFILE, [File], @PRODUCTGROUPQUOTE ) AS KEY_TBL 
									/* WHERE KEY_TBL.RANK > 10 would exclude 10% of hits */) 
					AND d.MIK_VALID = N'1' 
					AND f.filetype NOT LIKE '%.xl%' /* exclude registration form */ /* AND c.CONTRACTTYPEID  NOT IN  (103,104,101, 13, 5, 102, 6) */
					AND OBJECTID NOT IN (SELECT contractid from TPROD_GROUP_IN_CONTRACT 
											WHERE PRODUCTGROUPID = @PRODUCTGROUPID)
					AND d.objecttypeid = 1 /* contract */ /* AMENDMENT OBJECTTYPE 4 NOT WORKING RIGHT DO  NOT USE */
				GROUP BY d.OBJECTID, d.OBJECTTYPEID /*, d.DOCUMENTID */
				

				OPEN curContracts

				FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, /* @PRODUCTGROUP, */ @OBJECTID , @OBJECTTYPEID, @DOCUMENTID, @DOC_COUNT /*, @CONTRACTNUMBER, @DATEREGISTERED */
				WHILE @@FETCH_STATUS = 0 
				BEGIN
					
						/*   TheCompany_ProductGroupUpload_ObjectidProductgroupID
									  @OBJECTID bigint 
					,@PRODUCTGROUPID bigint
					, @OBJECTTYPEID bigint
					, @PRODUCTGROUP  AS VARCHAR(255)
					, @DESCRIPTION AS VARCHAR(255)
					, @CONTRACTNUMBER AS VARCHAR(20)
					, @DATEREGISTERED as datetime
					*/
					EXEC TheCompany_ProductGroupUpload_ObjectidProductgroupID @OBJECTID, @PRODUCTGROUPID, @OBJECTTYPEID, @PRODUCTGROUP, '' /*@DESCRIPTION */, @CONTRACTNUMBER, @DATEREGISTERED
					
					INSERT INTO T_TheCompany_Product_Upload ( 
						PRODUCTGROUPID       
					   , OBJECTID 
					   , OBJECTTYPEID
					   , Doc_MaxID /* DOCUMENTID */
					   , Doc_Count
					   , Uploaded_DateTime)
					VALUES (@PRODUCTGROUPID 
					, @OBJECTID
					, @OBJECTTYPEID
					, @DOCUMENTID
					, @DOC_COUNT
					, GetDate() )
		
				FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @OBJECTID , @OBJECTTYPEID, @DOCUMENTID, @DOC_COUNT

				END /* curContracts */
				CLOSE curContracts
				DEALLOCATE curContracts

			END /* IF EXISTS */

	FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
				
	END /* curProducts */

/* delete from T_TheCompany_Product_Upload */
	CLOSE curProducts
	DEALLOCATE curProducts

	SET @RESULTSTRING = 'Success' 

GOTO lblEnd 

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'


lblEnd: 
PRINT '*** END'



END 
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_3SATNIGHT_PrdGrpUpload_JPS_Description]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_3SATNIGHT_PrdGrpUpload_JPS_Description]
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

DECLARE @PRODUCTGROUP AS VARCHAR(255)
DECLARE @CONTRACTNUMBER AS VARCHAR(50)
DECLARE @CONTRACTINTERNALID AS VARCHAR(50)
DECLARE @DESCRIPTION AS VARCHAR(255)

DECLARE @SOURCENAME AS VARCHAR(255)
DECLARE @MATCHLEVEL AS int
DECLARE @PRODUCTGROUP_LEN AS int

DECLARE @PRODUCTGROUP_LEFTBLANK AS VARCHAR(300)
DECLARE @PRODUCTGROUP_MID AS VARCHAR(300)
DECLARE @PRODUCTGROUP_RIGHTBLANK AS VARCHAR(300)

DECLARE @PRODUCTGROUPID bigint
DECLARE @CONTRACTID bigint 
DECLARE @SQLOBJECTIDS as VARCHAR (1000)
DECLARE @DATEREGISTERED as datetime

BEGIN

DECLARE curProducts CURSOR LOCAL FAST_FORWARD FOR

select PRODUCTGROUPID, PRODUCTGROUP 
from V_TheCompany_VPRODUCTGROUP /* p  inner join T_TheCompany_KeyWordSearch k on p.PRODUCTGROUP = k.KeyWordVarchar255 */
WHERE PRODUCTGROUPNOMENCLATUREID IN('2','3') 
/*AND Productgroup_MIK_VALID = 1*/
and ([blnNumHashes]<2 /* one hash or no hash */ or [blnNumHashes] is null)
AND LEN(PRODUCTGROUP)>2 /* 2 , fuzzy match cutoff is set to 5 below, only exact matches for 3 char len */ 
/* and Productgroupid in (6431) */

OPEN curProducts

FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
WHILE @@FETCH_STATUS = 0 BEGIN

		SET @PRODUCTGROUP_RIGHTBLANK = @PRODUCTGROUP + '[^a-z]%' 

		SET @PRODUCTGROUP_MID = '%[^a-z]' + @PRODUCTGROUP + '[^a-z]%'

		SET @PRODUCTGROUP_LEFTBLANK = '%[^a-z]' + @PRODUCTGROUP
		SET @PRODUCTGROUP_LEN = len(@PRODUCTGROUP)

			PRINT 'Product Group: '  + @PRODUCTGROUP 
			PRINT @PRODUCTGROUPID
/************************** CHECK IF ANY RECORDS */
	/*	 IF EXISTS (
			SELECT 1
			FROM T_TheCompany_AribaDump c 
				WHERE (/* c.[All Products] like '%' + @PRODUCTGROUP + '%' *//* should not be needed OR */
					c.[Contract Description] like '%' + @PRODUCTGROUP + '%'
					OR c.[Additional Comments] like '%' + @PRODUCTGROUP + '%'
					OR c.[Project - Project Name] like '%' + @PRODUCTGROUP + '%'
					OR c.[Parent Agreement - Project Name] like '%' + @PRODUCTGROUP + '%'
					OR c.[Study Number] like '%' + @PRODUCTGROUP + '%' )
			AND ContractNumber NOT IN (SELECT ContractNumber
					from T_TheCompany_Ariba_Products_In_Contracts
					WHERE PRODUCTGROUPID = @PRODUCTGROUPID)
						)

			BEGIN
	
			PRINT ' at least one record to add for product' +@PRODUCTGROUP 
				/* sub loop contract upload */
				*/
/************************** CHECK IF ANY RECORDS */

/*!!! Exact Match Level = 1 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
				
				SET @SOURCENAME ='DescriptionEtc'
				SET @MATCHLEVEL = 1
				DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR

				SELECT @PRODUCTGROUPID AS PRD 
					, @PRODUCTGROUP AS PRDGRP 
					, c.ContractID
					, C.contractnumber
					/* , max(c.[Begin Date]) as [Begin Date]
					, c.[Contract Description] */
				FROM [dbo].[T_TheCompany_ContractData_JP_Sunrise_ExecutedAgreements] c 
			WHERE (c.[ProductClean] like @PRODUCTGROUP_LEFTBLANK 
				OR c.[ProductClean] like @PRODUCTGROUP_MID 
				OR c.[ProductClean] like @PRODUCTGROUP_RIGHTBLANK 
				/* Productgroup (master) */
				OR c.[product(master)] like @PRODUCTGROUP_LEFTBLANK 
				OR c.[product(master)] like @PRODUCTGROUP_MID 
				OR c.[product(master)] like @PRODUCTGROUP_RIGHTBLANK 
				/* Name of Agreement */
				OR c.[Name of Agreement] like @PRODUCTGROUP_LEFTBLANK 
				OR c.[Name of Agreement] like @PRODUCTGROUP_MID 
				OR c.[Name of Agreement] like @PRODUCTGROUP_RIGHTBLANK
				/* Note */
				OR c.[Note] like @PRODUCTGROUP_LEFTBLANK 
				OR c.[Note] like @PRODUCTGROUP_MID 
				OR c.[Note] like @PRODUCTGROUP_RIGHTBLANK
				)
				AND ContractID NOT IN (SELECT ContractID
						from T_TheCompany_ContractData_JPSunrise_Products_In_Contracts
						WHERE PRODUCTGROUPID = @PRODUCTGROUPID)													
				GROUP BY c.CONTRACTID, C.contractnumber

				OPEN curContracts
					
				FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @CONTRACTID, @CONTRACTNUMBER
				WHILE @@FETCH_STATUS = 0 BEGIN
					/*PRINT @PRODUCTGROUP
					PRINT @CONTRACTNUMBER
					PRINT @DESCRIPTION*/

						EXEC TheCompany_ProductGroupUpload_ObjectidProductgroupID_JPSunrise @CONTRACTNUMBER,  @CONTRACTID, @PRODUCTGROUPID, @SOURCENAME,@MATCHLEVEL

				FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @CONTRACTID, @CONTRACTNUMBER
				END
				/* loop 2 */
				CLOSE curContracts
				DEALLOCATE curContracts

/*!!! Fuzzier Match Level = 2 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/		
/*				SET @SOURCENAME ='DescriptionEtc'
				SET @MATCHLEVEL = 2			
				DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR

				SELECT @PRODUCTGROUPID AS PRD 
					, @PRODUCTGROUP AS PRDGRP 
					, c.CONTRACTNUMBER
					, c.CONTRACTINTERNALID 
					, max(c.[Begin Date]) as [Begin Date]
					, c.[Contract Description]
				FROM T_TheCompany_AribaDump c 
				WHERE (c.[Contract Description] like '%' + @PRODUCTGROUP + '%'
					OR c.[Additional Comments] like '%' + @PRODUCTGROUP + '%'
					OR c.[Project - Project Name] like '%' + @PRODUCTGROUP + '%'
					OR c.[Parent Agreement - Project Name] like '%' + @PRODUCTGROUP + '%'
					OR c.[Study Number] like '%' + @PRODUCTGROUP + '%' )
				AND ContractNumber NOT IN (SELECT ContractNumber
						from T_TheCompany_Ariba_Products_In_Contracts
						WHERE PRODUCTGROUPID = @PRODUCTGROUPID)		
					AND @PRODUCTGROUP_LEN > 5 /* not too short for fuzzy */					
				GROUP BY c.CONTRACTNUMBER , c.CONTRACTINTERNALID, c.[Contract Description]

				OPEN curContracts
					
				FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @CONTRACTNUMBER, @CONTRACTINTERNALID,  @DATEREGISTERED, @DESCRIPTION
				WHILE @@FETCH_STATUS = 0 BEGIN
					PRINT @PRODUCTGROUP
					PRINT @CONTRACTNUMBER
					PRINT @DESCRIPTION
						EXEC TheCompany_ProductGroupUpload_ObjectidProductgroupID_ARIBA @CONTRACTNUMBER,  @CONTRACTINTERNALID, @PRODUCTGROUPID, @SOURCENAME,@MATCHLEVEL
		   
						FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @CONTRACTNUMBER,  @CONTRACTINTERNALID,  @DATEREGISTERED, @DESCRIPTION
				END
				/* loop 2 */
				CLOSE curContracts


				DEALLOCATE curContracts
	
		END
		ELSE PRINT 'SKIP PRODUCT: No new records to add for : '  + @PRODUCTGROUP
*/
		FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
END

	CLOSE curProducts
	DEALLOCATE curProducts
	SET @RESULTSTRING = 'Success'

GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'


lblEnd: 
PRINT '*** END'



END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_3SATNIGHT_RemapTT_AlphaToRegion]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_3SATNIGHT_RemapTT_AlphaToRegion]

AS

BEGIN

SELECT 
  r.objectid
, r.ROLEID
, r.[DEPARTMENTROLE_IN_OBJECTID]
, r.DEPARTMENTID
, d.[DEPARTMENT]
, d.department_code
, TDPT_LOOKUP.[MAX_DEPARTMENT_CODE] 
, TDPT_LOOKUP.DEPARTMENTID_NEW

  INTO #tmp_dbo_tdptrole 

  FROM [TDEPARTMENTROLE_IN_OBJECT] r
  , [TDEPARTMENT] d

	  ,(  select d1.departmentid as DEPARTMENTID_NEW
	  , d1.department_code 
	  , d2.MAX_DEPARTMENT_CODE
	  , d2.DPT_CODE_ALPHABETICAL  
  
		  from tdepartment d1	  
			  , (  
			  select max([DEPARTMENT_CODE]) as [MAX_DEPARTMENT_CODE] 
			  , substring([DEPARTMENT_CODE],1,3) DPT_CODE_3DIGIT
			  , count([departmentid]) as DPTID_COUNT
			  , substring([DEPARTMENT_CODE],1,3) +';' AS DPT_CODE_ALPHABETICAL
			  from tdepartment 
			  where substring(department_code,4,1) in('*','') 
			  and substring(department_code,1,1) in(';')
			  and substring(department_code,2,1) <>''
			  group by substring([DEPARTMENT_CODE],1,3) ) d2 
  
		  where d1.department_code = d2.MAX_DEPARTMENT_CODE) TDPT_LOOKUP

  WHERE r.departmentid = d.departmentid
    and d.DEPARTMENT_CODE = TDPT_LOOKUP.DPT_CODE_ALPHABETICAL


/* update TDEPARTMENTROLE_IN_OBJECT with mapping table */
       UPDATE r
       set r.DEPARTMENTID = t.DEPARTMENTID_NEW
       FROM [dbo].[TDEPARTMENTROLE_IN_OBJECT] r
       inner join #tmp_dbo_tdptrole t
       on r.DEPARTMENTID = t.DEPARTMENTID
	   AND r.objectid = t.OBJECTID 
	   AND r.roleid = t.roleid 

	PRINT '[dbo].[TheCompany_327_RemapTT_AlphaToRegion] Result: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* delete temporary mapping table */
/* 		select * from #tmp_dbo_tdptrole  */
       drop table #tmp_dbo_tdptrole 


/* DELETE any resulting duplicates */

DELETE FROM TDEPARTMENTROLE_IN_OBJECT WHERE [DEPARTMENTROLE_IN_OBJECTID] IN 
(
SELECT  MAX(DEPARTMENTROLE_IN_OBJECTID) 
from TDEPARTMENTROLE_IN_OBJECT
where roleid = 3 /* Territories */
group by OBJECTTYPEID, OBJECTID, DEPARTMENTID, ROLEID
HAVING COUNT(*)>1
)


END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_3SATNIGHT_Reminders_Deactivate_ExpIntercompany]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[TheCompany_3SATNIGHT_Reminders_Deactivate_ExpIntercompany]

as

/* Expired contracts */
	/* TWARNING , review date only (maybe extend to all) */
		UPDATE TWARNING
		set ISACTIVE = 0
		WHERE ISACTIVE = 1 
		AND WARNINGFIELDNAME = 'REVIEWDATE' /* remove? we want all reminders gone */
		/* AND objectid = 133810 /* 'Contract-11127305' */ */
		AND objectid in (select contractid from T_TheCompany_ALL c 
						where final_expirydate < GETDATE())
						
	/* tperson_in_warning */

		update tperson_in_warning
		set turnedoffdate = getdate()
		/* ,INTERNALWARNING = 0
		,EMAILWARNING = 0 */
		,isturnedoff = 1 /* OFF */
		where (tperson_in_warning.isturnedoff = 0 /* ON */ or TURNEDOFFDATE is null)
		and warningid in (select warningid from twarning w inner join T_TheCompany_ALL c on c.contractid = w.objectid
						where WARNINGFIELDNAME = 'REVIEWDATE' 
						AND c.final_expirydate < GETDATE())
						
/* Intercompany contracts */	
			
		UPDATE TWARNING
		set ISACTIVE = 0
		WHERE ISACTIVE = 1 
		AND WARNINGFIELDNAME = 'REVIEWDATE' /* remove? we want all reminders gone */
		/* AND objectid = 133810 /* 'Contract-11127305' */ */
		AND objectid in (select contractid from T_TheCompany_ALL c 
						WHERE companyIDlist ='1' /* Intercompany */	
						OR c.AGREEMENT_TYPEID = 5 /* CDA */)

		update tperson_in_warning
		set turnedoffdate = getdate()
		/* ,INTERNALWARNING = 0
		,EMAILWARNING = 0 */
		,isturnedoff = 1 /* OFF */
		where (tperson_in_warning.isturnedoff = 0 /* ON */ or TURNEDOFFDATE is null)
		and warningid in (select warningid from twarning w inner join T_TheCompany_ALL c on c.contractid = w.objectid
						where WARNINGFIELDNAME = 'REVIEWDATE' 
						AND (companyIDlist ='1' /* Intercompany */
							OR c.AGREEMENT_TYPEID = 5 /* CDA */))

/*					
/* Migrated Ariba Contracts */	
/* ENTER MIGRATION DATE before running */
	
		UPDATE TWARNING
		set ISACTIVE = 0
		WHERE ISACTIVE = 1 
		AND objectid in (select contractid from T_TheCompany_ALL c 
						WHERE c.COUNTERPARTYNUMBER = '!ARIBA_W01')

		UPDATE TWARNING
		set warningdate = '2017-12-19 00:00:00.000'
		WHERE WARNINGDATE >= GETDATE()
		/* and WARNINGID = 119329 */		
		AND objectid in (select contractid from T_TheCompany_ALL c 
						WHERE c.COUNTERPARTYNUMBER = '!ARIBA_W01')	
		
		UPDATE TWARNING	
		set WARNINGTYPEID = 1 /* single reminder */
		, RECURRINGNUMBER	= null
		, RECURRINGSTART = null
		, RECURRENCEINTERVAL = null
		, RECURRENCEXML = null
		WHERE WARNINGTYPEID = 3 /* recurring date */
		AND objectid in (select contractid from T_TheCompany_ALL c 
						WHERE c.COUNTERPARTYNUMBER = '!ARIBA_W01')				

		update tperson_in_warning
		set turnedoffdate = '19-Dec-2017'
		/* ,INTERNALWARNING = 0
		,EMAILWARNING = 0 */
		,isturnedoff = 1 /* OFF */
		where (tperson_in_warning.isturnedoff = 0 /* ON */ or TURNEDOFFDATE is null)
		and warningid in (select warningid from twarning w inner join T_TheCompany_ALL c on c.contractid = w.objectid
						where c.COUNTERPARTYNUMBER = '!ARIBA_W01')
		
		
		update tperson_in_warning
		set EMAILWARNING = 0 /* no email */
		/* set PERSONID = 34530 /* Susanne Joest */ */
		where warningid in (select warningid from twarning w inner join T_TheCompany_ALL c on c.contractid = w.objectid
						where c.COUNTERPARTYNUMBER = '!ARIBA_W01')				

*/
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_489_NoReviewDateReminder]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_489_NoReviewDateReminder]

AS

BEGIN

/* DEACTIVATED???? */

	update C
	set c.COUNTERPARTYNUMBER = right((CASE WHEN c.COUNTERPARTYNUMBER IS not null 
								Then c.COUNTERPARTYNUMBER + ',' 
								else '' END) + 'F1RD',25 /* truncate to 25 char length */)
	from TCONTRACT c inner join V_TheCompany_ALL a on c.CONTRACTID = A.CONTRACTID
	where
		a.FINAL_EXPIRYDATE is null
		and a.RD_ReviewDate_Warning is null
		and a.STATUSID = 5 /* is Active */
		and c.COUNTERPARTYNUMBER not like '%F1RD%' /* not already flagged */
		and c.CONTRACTTYPEID not in ( 11 /* Case */, 13 /* delete */, 106 /* autodelete */)
		and c.counterpartynumber not like 'Xt_%' /* do not flag external numbers */
		and c.COUNTERPARTYNUMBER not like 'TPC-JP%' /* TPC JP intercompany agreement number */
		and c.AGREEMENT_TYPEID <> 5 /* CDA */ 
		and CompanyIDList <> '1' /* intercompany */

/* remove flag from inactive items or now with review date warning */

/* with a comma */
	update C
	set c.COUNTERPARTYNUMBER = replace(c.counterpartynumber,',F1RD','')
	from TCONTRACT c inner join V_TheCompany_ALL a on c.CONTRACTID = A.CONTRACTID
	where c.COUNTERPARTYNUMBER like '%F1RD%' /* Has flag set */
	AND	(a.RD_ReviewDate_Warning is not null /* review date is there */
			or a.STATUSID <> 5 /* is not Active */
			OR c.CONTRACTTYPEID in ( 11 /* Case */, 13 /* delete */, 106 /* autodelete */)
			OR c.COUNTERPARTYNUMBER like 'Xt_%' /* is external */)

		
/* no comma */
	
	update C
	set c.COUNTERPARTYNUMBER = replace(c.counterpartynumber,'F1RD','')
	from TCONTRACT c inner join V_TheCompany_ALL a on c.CONTRACTID = A.CONTRACTID
	where
		(a.RD_ReviewDate_Warning is not null /* review date is there */
			or a.STATUSID <> 5 /* is not Active */
			OR c.CONTRACTTYPEID in ( 11 /* Case */, 13 /* delete */, 106 /* autodelete */)
			OR c.COUNTERPARTYNUMBER like 'Xt_%' /* is external */)
		and c.COUNTERPARTYNUMBER like '%F1RD%' /* Has flag set */

		
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_491_SignedContractsInCase]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_491_SignedContractsInCase]

AS

BEGIN

/* flag new items */

	update C
	set c.COUNTERPARTYNUMBER = right((CASE WHEN c.COUNTERPARTYNUMBER IS not null 
								Then c.COUNTERPARTYNUMBER + ',' 
								else '' END) + 'F2SC',25)
	from TCONTRACT c inner join VDOCUMENT d on c.CONTRACTID = d.objectid
	where
		c.CONTRACTTYPEID = 11 /* Case */
		and d.MIK_VALID = 1
		and d.DOCUMENTTYPEID = 1 /* Signed Contracts */
		and d.FileType = '.pdf'
		and (c.COUNTERPARTYNUMBER is null or c.counterpartynumber not like '%F2SC%')


/* remove flag */

/* with comma in front */
	update C
	set c.COUNTERPARTYNUMBER = replace(c.counterpartynumber,',F2SC','')
	from TCONTRACT c inner join VDOCUMENT d on c.CONTRACTID = d.objectid
	where
		(c.CONTRACTTYPEID <> 11 /* Case */
		OR d.MIK_VALID <> 1
		OR d.DOCUMENTTYPEID <> 1 /* Signed Contracts */
		or d.FileType <> '.pdf')
		and c.COUNTERPARTYNUMBER like '%,F2SC%'
		
/* no coma in front of flag */
	update C
	set c.COUNTERPARTYNUMBER = replace(c.counterpartynumber,'F2SC','')
	from TCONTRACT c inner join VDOCUMENT d on c.CONTRACTID = d.objectid
	where
		(c.CONTRACTTYPEID <> 11 /* Case */
		OR d.MIK_VALID <> 1
		OR d.DOCUMENTTYPEID <> 1 /* Signed Contracts */
		or d.FileType <> '.pdf')
		and c.COUNTERPARTYNUMBER like '%F2SC%'

	/* 
	update C
	set c.COUNTERPARTYNUMBER = replace(c.counterpartynumber,',F2SC','F2SC')
	from TCONTRACT c 
	where c.COUNTERPARTYNUMBER like '%,F2SC%'

	update C
	set c.COUNTERPARTYNUMBER = replace(c.counterpartynumber,'F2SC','F2SC')
	from TCONTRACT c
	where c.COUNTERPARTYNUMBER like '% F2SC%'
	*/
		
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_4MONTHLY_AlphaSort_AGREEMENT_TYPE]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[TheCompany_4MONTHLY_AlphaSort_AGREEMENT_TYPE] 

AS

BEGIN
 
/* TheCompany Issue # 333 - Alphabetical Sort Order TUSERGROUP */

SELECT [AGREEMENT_TYPE],
         [AGREEMENT_TYPEID],
   [MIK_SEQUENCE],
   ROW_NUMBER() OVER (ORDER BY AGREEMENT_TYPE)AS NEW_MIK_SEQUENCE 
into #tmp_dbo_tagreementtype 
FROM   [TAGREEMENT_TYPE]
where [MIK_VALID] = 1


UPDATE d
set d.MIK_SEQUENCE = t.NEW_MIK_SEQUENCE
FROM [TAGREEMENT_TYPE] d
inner join #tmp_dbo_tagreementtype t
on d.AGREEMENT_TYPEID = t.AGREEMENT_TYPEID 
WHERE d.MIK_SEQUENCE <> t.NEW_MIK_SEQUENCE

drop table #tmp_dbo_tagreementtype 

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_4MONTHLY_AlphaSort_TUSERGROUP]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_4MONTHLY_AlphaSort_TUSERGROUP] 

AS

BEGIN
 
/* TheCompany Issue # 333 - Alphabetical Sort Order TUSERGROUP */

SELECT (CASE WHEN DEPARTMENTID is not null THEN 1 when companyid is not null then 2 ELSE 3 END) as Category,
      [USERGROUP],
         [USERGROUPID],
   [MIK_SEQUENCE],
   ROW_NUMBER() OVER (ORDER BY (CASE WHEN DEPARTMENTID is not null THEN 1 when companyid is not null then 2 ELSE 3 END),[USERGROUP]) AS NEW_MIK_SEQUENCE 
into #tmp_dbo_tusergroup
FROM   [TUSERGROUP]
where [MIK_VALID] = 1


UPDATE d
set d.MIK_SEQUENCE = t.NEW_MIK_SEQUENCE
FROM [TUSERGROUP] d
inner join #tmp_dbo_tusergroup t
on d.USERGROUPID = t.USERGROUPID
WHERE d.MIK_SEQUENCE <> t.NEW_MIK_SEQUENCE

drop table #tmp_dbo_tusergroup 

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_4MONTHLY_DeleteDocsRecycleBin]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* CMA TheVendor Performance Pack
Delete documents from rec bin
Ready for  6.10.5.x DB
Ready for  6.11.x   DB
*/

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
/****** Object:  StoredProcedure [dbo].[TheCompany_ACL_Remove_ACLID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[TheCompany_ACL_Remove_ACLID](
                @ACLID bigint
                , @OBJECTTYPEID bigint /* 1 =contract, document = 7 might have same id */
)
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

/* ACL ID must be valid */
	IF NOT EXISTS ( SELECT  1
					FROM    dbo.tACL
					WHERE   
						ACLID = @ACLID
						AND OBJECTTYPEID =  @OBJECTTYPEID)
		BEGIN
			SET @RESULTSTRING = 'ACL ID does not exist: ' + (CASE WHEN @ACLID IS NULL THEN 'NULL' ELSE STR(@ACLID) END)
			GOTO lblTerminate 
		END

/* system GROUPS must not be removed */
	IF EXISTS ( SELECT  1
					FROM    dbo.tACL
					WHERE   
						ACLID = @ACLID
						AND OBJECTTYPEID =  @OBJECTTYPEID
						AND groupid in (0 /* admin del */
										,126 /* System Internal */ 
										, 4633 /* maybe remove here for restored contracts, admin system with delete privilege */) 
										)
								/* users see item directly below */
								/* OBJECTID must not null, see statment below */
		BEGIN
			SET @RESULTSTRING = 'ACL Entry is system service or Delete Group, or sys user - no permission removal'
			GOTO lblNoChange 
		END
		
/* system USERS Must not be removed */
	IF EXISTS ( SELECT  1
					FROM    dbo.tACL
					WHERE   
						ACLID = @ACLID
						AND OBJECTTYPEID =  @OBJECTTYPEID
						AND USERID in (1 /*sysadm*/, 20134 /* TheVendoradmin */, 81995 /* systemservice */) 
					)
										
		BEGIN
			SET @RESULTSTRING = 'ACL Entry is system user - no permission removal'
			GOTO lblNoChange 
		END


BEGIN

			BEGIN
				SET @RESULTSTRING = 'ACL Entry deleted: '+ (CASE WHEN @ACLID IS NULL THEN 'NULL' ELSE STR(@ACLID) END)

				DELETE FROM TACL
				WHERE 
					ACLID = @ACLID
					AND OBJECTTYPEID =  @OBJECTTYPEID
					AND OBJECTID IS NOT NULL /* system entries for creating contracts etc. */
				GOTO lblEnd
			END


GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'
GOTO lblBlankLine

lblNoChange:
PRINT '--- Statement did not result in any changes'
GOTO lblBlankLine

lblEnd: 
PRINT '*** Record removed Successfully'

lblBlankLine:
PRINT '     ' + @RESULTSTRING
PRINT CHAR(13) /* carriage return */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_ACL_Upload_Group_ObjectIDGroupID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  PROCEDURE [dbo].[TheCompany_ACL_Upload_Group_ObjectIDGroupID](
                @OBJECTID bigint 
                , @OBJECTTYPEID bigint /* only type 1 supported (contract) very important, document = 7 might have same id */
                , @GROUPID bigint
                , @PRIVILEGEID bigint
                , @NONINHERITABLE bit /* (0 /*Inheritable / off */,1 /*NONinheritable*/) */

)
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

/* Object ID must be valid, only works for objecttypeid = 1 */
	IF NOT EXISTS ( SELECT  1
					FROM    dbo.tcontract
					WHERE   contractid = @OBJECTID)
		BEGIN
			SET @RESULTSTRING = 'Object ID does not exist: ' + (CASE WHEN @OBJECTID IS NULL THEN 'NULL' ELSE STR(@OBJECTID) END)
			GOTO lblTerminate 
		END

/* Top Secret or Confidential Contract excluded */
	IF EXISTS ( SELECT  1
					FROM    dbo.tcontract
					WHERE   contractid = @OBJECTID
					AND ([CONTRACT] like '%TOP SECRET%' OR [CONTRACT] like '%CONFIDENTIAL[*]%'))
		BEGIN
			SET @RESULTSTRING = 'Contract is flagged as TOP SECRET or CONFIDENTIAL - no automatic permission upload'
			GOTO lblNoChange 
		END

/* Public contract does not need additional READ permission */
	if @PRIVILEGEID = 1 /* Read */
	
	BEGIN
		IF EXISTS ( SELECT  1
						FROM    dbo.tcontract c inner join TAGREEMENT_TYPE a on c.AGREEMENT_TYPEID = a.AGREEMENT_TYPEID
						WHERE   c.contractid = @OBJECTID
						AND a.FIXED LIKE '%PUBLIC%')
			BEGIN
				SET @RESULTSTRING = 'Contract is public - permission 1 - Read not needed, only 2 - Write'
				GOTO lblNoChange 
			END
	END
		
/* Contract type is not TEST etc. */
	IF EXISTS ( SELECT  1
					FROM    dbo.tcontract
					WHERE   contractid = @OBJECTID
					AND CONTRACTTYPEID in('11' /*Case*/,'6' /* Access */, '5' /* Test Old */,'102' /* Test New */,'13' /* DELETE */ ,'103' /*file*/,'104' /*corp file*/))
		BEGIN
			SET @RESULTSTRING = 'Contract Type is Test, Access or similar - no automatic permission upload'
			GOTO lblNoChange 
		END

/* Group ID valid */
	IF NOT EXISTS ( SELECT  1
					FROM    dbo.tusergroup
					WHERE   usergroupid = @GROUPID)

		BEGIN
			SET @RESULTSTRING = 'Group ID does not exist: ' + (CASE WHEN @GROUPID IS NULL THEN 'NULL' ELSE STR(@GROUPID) END)
			GOTO lblTerminate 
		END

/* Protected Group ID cannot be modified */
	IF @GROUPID IN (SELECT usergroupid from dbo.tusergroup WHERE FIXED IN ('SYSTEMINTERNAL','SYSTEM'))

		BEGIN
			SET @RESULTSTRING = 'Group ID invalid: System Internal or System Group ID cannot be modified'
			GOTO lblTerminate 
		END

/* Privilege ID must be valid */
	IF NOT EXISTS ( SELECT  1
					FROM    dbo.tprivilege
					WHERE   PRIVILEGEID = @PRIVILEGEID) or @PRIVILEGEID is null

		BEGIN
			SET @RESULTSTRING = 'Privilege ID invalid (must be between 1-5, or NULL to delete all privileges): '+ (CASE WHEN @PRIVILEGEID IS NULL THEN 'NULL' ELSE STR(@PRIVILEGEID) END)
			GOTO lblTerminate 
		END

/* Inheritance Flag Valid */
	IF NOT (@NONINHERITABLE IN(1,0) or @NONINHERITABLE is null)

		BEGIN
			SET @RESULTSTRING = 'Inheritance Flag has wrong value (must be 0,1 or NULL): ' + STR(@NONINHERITABLE)
			GOTO lblTerminate 
		END

BEGIN
			IF @NONINHERITABLE is null 
			BEGIN
				SET @NONINHERITABLE = 0 /* Inheritable is the default */
			END
			
	/* NULL Privilege ID passed */
			
			IF @PRIVILEGEID IS NULL 
			AND NOT EXISTS (SELECT 1 FROM dbo.TACL 
					WHERE 
					OBJECTID = @OBJECTID
					AND OBJECTTYPEID = @OBJECTTYPEID
					AND GROUPID = @GROUPID)
			BEGIN
			
				SET @RESULTSTRING = 'NULL Privilege ID passed, but no record, no action'
				GOTO lblEnd
			END

			IF @PRIVILEGEID IS NULL 
			AND EXISTS (SELECT 1 FROM TACL 
					WHERE 
					OBJECTID = @OBJECTID
					AND OBJECTTYPEID = @OBJECTTYPEID
					AND GROUPID = @GROUPID)
			BEGIN
			
				SET @RESULTSTRING = 'NULL Privilege ID passed, Privileges deleted successfully'

				DELETE FROM TACL
				WHERE 
						OBJECTID = @OBJECTID
						AND OBJECTTYPEID = @OBJECTTYPEID
						AND GROUPID = @GROUPID
						AND PRIVILEGEID IN(1,2,3,4,5)
				GOTO lblEnd
			END

	/* Valid Privilege ID passed */

		IF EXISTS (SELECT 1 FROM TACL where 
					OBJECTID = @OBJECTID
					AND OBJECTTYPEID = @OBJECTTYPEID
					AND GROUPID = @GROUPID
					AND PRIVILEGEID = @PRIVILEGEID
					AND NONHERITABLE = @NONINHERITABLE)
			BEGIN
				SET @RESULTSTRING = 'Record already exists, no action'
				GOTO lblNoChange
			END 

		IF EXISTS (SELECT 1 FROM TACL where 
					OBJECTID = @OBJECTID
					AND OBJECTTYPEID = @OBJECTTYPEID
					AND GROUPID = @GROUPID
					AND PRIVILEGEID = @PRIVILEGEID
					AND NONHERITABLE <> @NONINHERITABLE)
			BEGIN
				SET @RESULTSTRING = 'Records exists, but with different inheritable flag'

				UPDATE TACL 
				SET NONHERITABLE = @NONINHERITABLE
				WHERE 
					OBJECTID = @OBJECTID
					AND OBJECTTYPEID = @OBJECTTYPEID
					AND GROUPID = @GROUPID
					AND PRIVILEGEID = @PRIVILEGEID

				GOTO lblEnd
			END

		IF NOT EXISTS (SELECT 1 FROM TACL where 
					OBJECTID = @OBJECTID
					AND OBJECTTYPEID = @OBJECTTYPEID
					AND GROUPID = @GROUPID
					AND PRIVILEGEID = @PRIVILEGEID)
		
			BEGIN
				SET @RESULTSTRING = 'Insert Record'

				 INSERT INTO dbo.TACL(OBJECTID
									,OBJECTTYPEID
									,GROUPID
									,USERID
									,PRIVILEGEID
									,NONHERITABLE) 
							 VALUES (@OBJECTID
								,1 /*OBJECTTYPEID = CONTRACT*/
								,@GROUPID
								,NULL /*USERID*/
								,@PRIVILEGEID
								,@NONINHERITABLE)
			END

GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'
GOTO lblBlankLine

lblNoChange:
PRINT '--- Statement did not result in any changes'
GOTO lblBlankLine

lblEnd: 
PRINT '*** Record added or altered Successfully'

lblBlankLine:
PRINT '     ' + @RESULTSTRING
PRINT CHAR(13) /* carriage return */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_ACL_zPerContractid_AllPermissions]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TheCompany_ACL_zPerContractid_AllPermissions](
                @OBJECTID bigint 

)
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

IF NOT EXISTS ( SELECT  1
                FROM    dbo.tcontract
                WHERE   contractid = @OBJECTID)
	BEGIN
		SET @RESULTSTRING = 'Object ID does not exist: ' + (CASE WHEN @OBJECTID IS NULL THEN 'NULL' ELSE STR(@OBJECTID) END)
		GOTO lblTerminate 
	END


BEGIN

DECLARE  @dptc VARCHAR(5)
DECLARE  @groupid SMALLINT
DECLARE  @privilegeid TINYINT

DECLARE myCursor CURSOR LOCAL FAST_FORWARD FOR

select distinct (Case when UPPER(substring(r.[role_department_code],4,1)) LIKE ('[A-Z]') 
	THEN substring(r.[role_department_code],2,3)  
	ELSE  substring(r.[role_department_code],2,2) END)
 as dptc, u.usergroupid, u.privilege
from [TheVendor_app].[dbo].[VCONTRACT_DEPARTMENTROLES]  r inner join dbo.V_TheCompany_AUTO_ACL_Upload u
on (Case when UPPER(substring(r.[role_department_code],4,1)) LIKE ('[A-Z]') 
	THEN substring(r.[role_department_code],0,5)  
	ELSE  substring(r.[role_department_code],0,4) END) = u.Code3Digit
where r.contractid = @OBJECTID

OPEN myCursor
FETCH NEXT FROM myCursor INTO @dptc, @groupid, @privilegeid
WHILE @@FETCH_STATUS = 0 BEGIN

    exec TheCompany_ACL_Upload_Group_ObjectIDGroupID  @OBJECTID=@OBJECTID, @GROUPID=@groupid, @PRIVILEGEID=@privilegeid, @NONINHERITABLE=0
	
	IF @privilegeid = 2 /*Write, implement Read also */
	BEGIN
	    exec TheCompany_ACL_Upload_Group_ObjectIDGroupID  @OBJECTID=@OBJECTID, @GROUPID=@groupid, @PRIVILEGEID=1, @NONINHERITABLE=0
	END 

    FETCH NEXT FROM myCursor INTO @dptc, @groupid, @privilegeid

END

CLOSE myCursor
DEALLOCATE myCursor


GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'
GOTO lblBlankLine

lblNoChange:
PRINT '--- Statement did not result in any changes'
GOTO lblBlankLine

lblEnd: 
PRINT '*** Record added or altered Successfully'

lblBlankLine:
PRINT '     ' + @RESULTSTRING
PRINT CHAR(13) /* carriage return */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Adhoc_EditContractRelation]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[TheCompany_Adhoc_EditContractRelation]

as

BEGIN

	select CONTRACTRELATIONID from TCONTRACT where CONTRACTID = 297239

	/*
	update TCONTRACT set CONTRACTRELATIONID = 6 /* services */ where CONTRACTID = 297239 
	*/

END

/* 
CONTRACTRELATIONID	CONTRACTRELATION	MIK_VALID	MIK_SEQUENCE	FIXED
1	Purchase contract	1	4	JOINT_VENTURE
2	Sales contract	1	6	JOINT_VENTURE
3	Other	1	2	JOINT_VENTURE
4	Product License and Supply	0	-1	test $ARIBA
5	Master Agreement (e.g. MSA with work orders)	1	3	JOINT_VENTURE
6	Services Agreement , One-off (SA)	0	5	JOINT_VENTURE
8	Stand-Alone Agreement (not related to a Master Agreement)	1	7	JOINT_VENTURE
9	SUB Agreement to MSA (please file under MSA!)	1	8	JOINT_VENTURE
*/
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Adhoc_FullText]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[TheCompany_Adhoc_FullText]
AS


BEGIN


	select PRODUCTGROUPID, PRODUCTGROUP 
	from V_TheCompany_VPRODUCTGROUP 
	WHERE /* PRODUCTGROUP IN ('ENTROCORT','MOLLIPECT','KAJOS','MINIFOM' 
	,'LIVOL' ,'SANASOL' ,'MONTELAR') AND */
	blnNumHashes = 0 /* no hash, include in full text search */
	/* AND PRODUCTGROUP IN('ADCETRIS','OMNARIS') */
	and PRODUCTGROUP LIKE '%[a-z]%' 
	AND PRODUCTGROUP NOT LIKE '% %'
	AND PRODUCTGROUP NOT LIKE '%-%'
	AND PRODUCTGROUPNOMENCLATUREID IN('2','3') /* Trade names and active ingredients */
	and [ProductGroup_LEN] >2
	/* and [ProductGroup_MIK_VALID] = 1 */
	/*and productgroupid =6431 */

				SELECT d.title
					, d.OBJECTID
					, d.OBJECTTYPEID
				FROM Vdocument d  inner join TFILEINFO i on d.DOCUMENTID = i.documentid
					INNER JOIN TFILE f ON i.FileId = f.FileID
				WHERE f.FileId IN (SELECT KEY_TBL.[KEY] 
				FROM CONTAINSTABLE(TFILE, [File], 'NITROFUR-C' ) AS KEY_TBL 
									/* WHERE KEY_TBL.RANK > 10 would exclude 10% of hits */) 
					AND d.MIK_VALID = N'1' 
					AND f.filetype NOT LIKE '%.xl%' /* exclude registration form */ /* AND c.CONTRACTTYPEID  NOT IN  (103,104,101, 13, 5, 102, 6) */
					AND d.objecttypeid = 1 /* contract */ /* AMENDMENT OBJECTTYPE 4 NOT WORKING RIGHT DO  NOT USE */
		


END 
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Adhoc_Remap_TT_IP]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_Adhoc_Remap_TT_IP]

AS

BEGIN


/* Issue #408 - Remap INTERNAL PARTNER field Territory to Internal Partner value */
/* ONLY WORKS FOR UNIQUE TWO-LETTER INTERNAL PARTNERS SUFFIXED WITH A COMMA */

PRINT 'Create Temp Mapping Table #tmp_dbo_tdptroleinobject'

	SELECT 
		m.*, t.TargetDptID 
	into 
		#tmp_dbo_tdptroleinobject_ip
	FROM (SELECT 
			o.OBJECTID
			, r.role 
			, r.roleid
			, d.department
			, d.departmentid as OrigDptID
			, d.department_code 
			, SUBSTRING(d.department_code,2,2) ctry2Digit
		FROM 
			TDEPARTMENTROLE_IN_OBJECT o, TDEPARTMENT d, TROLE r
		WHERE 
			r.roleid = o.roleid
			and d.departmentid = o.departmentid
			and (d.department_code like (';%') /*Territory*/ or d.department_code like ('.%') /* CCO Node */)
			and r.roleid = 100 /*Internal Partner*/) m,

			(SELECT 
				u.DEPARTMENTID TargetDptID
				, u.USERGROUP
				, d.department_code
				, SUBSTRING(d.department_code,2,2) as TargetCtry2Digit
			FROM 
				TUSERGROUP u, TDEPARTMENT d
			WHERE 
				d.departmentid = u.departmentid
				and u.mik_valid = 1
				AND u.USERGROUP LIKE 'Internal Partner%'
				and SUBSTRING(d.department_code,4,1) = ',' /* only ,EE, etc two digit codes */) t

		WHERE m.ctry2Digit = t.TargetCtry2Digit

	PRINT 'Update TDEPARTMENTROLE_IN_OBJECT'

		UPDATE d
		set d.DEPARTMENTID = t.TargetDptID
		FROM TDEPARTMENTROLE_IN_OBJECT d
		inner join #tmp_dbo_tdptroleinobject_ip t
		on d.DEPARTMENTID = t.OrigDptID
		and t.objectid = d.objectid
		and d.roleid = 100 /*Internal Partner*/

	PRINT 'Drop temp table #tmp_dbo_tdptroleinobject'

	drop table #tmp_dbo_tdptroleinobject_ip



/* TERRITORIES */

/* Remap TERRITORY field Internal Partner / CCO to Territory value */
/* ONLY WORKS FOR UNIQUE TWO-LETTER INTERNAL PARTNERS SUFFIXED WITH A COMMA */

PRINT 'Create Temp Mapping Table #tmp_dbo_tdptroleinobject'

SELECT m.*, t.TargetDptID 
into #tmp_dbo_tdptroleinobject
FROM (SELECT o.OBJECTID
, r.role 
, r.roleid
, d.department
, d.departmentid as OrigDptID
, d.department_code 
, SUBSTRING(d.department_code,2,2) ctry2Digit

FROM TDEPARTMENTROLE_IN_OBJECT o, TDEPARTMENT d, TROLE r
WHERE r.roleid = o.roleid
and d.departmentid = o.departmentid
and (d.department_code like (',%') /*Territory*/ or d.department_code like ('.%') /* CCO Node */)
and r.roleid = 3 /*Territories*/) m,

(SELECT 
u.DEPARTMENTID TargetDptID
, u.USERGROUP
, d.department_code
, SUBSTRING(d.department_code,2,2) as TargetCtry2Digit
FROM TUSERGROUP u, TDEPARTMENT d
WHERE 
d.departmentid = u.departmentid
and u.mik_valid = 1
AND u.USERGROUP LIKE 'Territor%'
and SUBSTRING(d.department_code,4,1) <> ';') t
WHERE m.ctry2Digit = t.TargetCtry2Digit

PRINT 'Update TDEPARTMENTROLE_IN_OBJECT'

UPDATE d
set d.DEPARTMENTID = t.TargetDptID
FROM TDEPARTMENTROLE_IN_OBJECT d
inner join #tmp_dbo_tdptroleinobject t
on d.DEPARTMENTID = t.OrigDptID
and t.objectid = d.objectid
and d.roleid = 3 /*Territories*/

PRINT 'Drop temp table #tmp_dbo_tdptroleinobject'

drop table #tmp_dbo_tdptroleinobject


END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Adhoc_VariousSingleUpdates]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_Adhoc_VariousSingleUpdates]

as

/* Switch agreement type MSA to SA */
/*
UPDATE TCONTRACT
SET AGREEMENT_TYPEID = 17 /* SA */
WHERE AGREEMENT_TYPEID = 1 /* MSA */
AND CONTRACTNUMBER = 'Contract-11123477'
*/

/* check for duplicate 2-digit country codes */
/*
SELECT 
count(*) as ct,
SUBSTRING(d.department_code,2,2) as TargetCtry2Digit
FROM TUSERGROUP u, TDEPARTMENT d
WHERE 
d.departmentid = u.departmentid
and u.mik_valid = 1
AND u.USERGROUP LIKE 'Territ%'
AND (SUBSTRING(d.department_code,4,1) ='' or SUBSTRING(d.department_code,4,1) = '*')
AND SUBSTRING(d.department_code,1,1) = ';'
group by SUBSTRING(d.department_code,2,2)
having count(SUBSTRING(d.department_code,2,2)) >1
*/

/* fix internal partner */
/*
select * from TDEPARTMENTROLE_IN_OBJECT o, TDEPARTMENT d, TROLE r
WHERE r.roleid = o.roleid
and d.departmentid = o.departmentid
and (d.department_code like (';%') /*Territory*/ or d.department_code like ('.%') /* CCO Node */)
and r.roleid = 100 /*Internal Partner*/
and d.departmentid = 100324

update TDEPARTMENTROLE_IN_OBJECT 
set DEPARTMENTID = 203305
where ROLEID = 100 /*Internal Partner*/
and DEPARTMENTID = 100324

select * from tdepartment where department_code = ',ukt'
*/

/* update super user in contract */
	/*
	select USERID, personid from vuser where displayname like '%wagner, Heike%'
	userid = 80794
	personid = 30970

	tuser

	select * from dbo.TPERSONROLE_IN_OBJECT
	where OBJECTID in (select contractid from T_TheCompany_ALL 
		where InternalPartners like '%Egypt%' and InternalPartners_COUNT = 1)
	and ROLEID = 1
	and PERSONID <>30970 /* Heike Wagner */

	update dbo.TPERSONROLE_IN_OBJECT
	set PERSONID = 30970
	where OBJECTID in (select contractid from T_TheCompany_ALL 
		where InternalPartners like '%Egypt%' and InternalPartners_COUNT = 1)
	and ROLEID = 1
	and PERSONID <>30970 /* Heike Wagner */
	*/

/* pdf file length rename */

	/*
		UPDATE
			d
		SET
			d.DESCRIPTION = c.CTitlePlusDTitle
		FROM
			tdocument d
		INNER JOIN
			[V_TheCompany_Edit_DocAutoRenameCTitle] c
		ON 
			d.objectid = c.contractid
		WHERE  
		len(d.DESCRIPTION) < 12 AND  
		/* d.FILEINFOID in (select fileid from tfile where FileType = '.pdf') AND */
		d.DOCUMENTTYPEid = 1 /* Signed Contracts */ AND
		d.objectid in (select OBJECTID from TDOCUMENT 
								where mik_valid = 1 
								and d.DOCUMENTTYPEID = 1 /* Signed Contracts */
								group by OBJECTID having COUNT(*)=1)
							
	*/					
						
/* 
select *
FROM
    tdocument d
INNER JOIN
    [V_TheCompany_Edit_DocAutoRenameCTitle] c
ON 
    d.objectid = c.contractid
WHERE  
len(d.DESCRIPTION) < 12 AND  
/* d.FILEINFOID in (select fileid from tfile where FileType = '.pdf') AND */
d.DOCUMENTTYPEid = 1 /* Signed Contracts */ AND
d.objectid in (select OBJECTID from TDOCUMENT 
						where mik_valid = 1 
						and d.DOCUMENTTYPEID = 1 /* Signed Contracts */
						group by OBJECTID having COUNT(*)=1)	*/

/* Full text search */						
/* 
SELECT 'non-compete, non-competition' as txt_kwd, 1 as Relevance,
t.* FROM [V_SEARCHENGINE_SEARCHSIMPLEDOCUMENT] t  INNER JOIN 
TFILE ON TFILE.FileId = t.FileId WHERE TFILE.FileId 
IN (SELECT KEY_TBL.[KEY] FROM 
CONTAINSTABLE(TFILE, [File], '"non-compete" OR "non-competition"' ) 
AS KEY_TBL WHERE KEY_TBL.RANK > 10) AND (1=1 AND t.MIKVALID = N'1') 
*/

GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Ariba_ProductUploadFullText]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[TheCompany_Ariba_ProductUploadFullText]

as

BEGIN
/* M:\ECM_Ariba\Data_Dump_Ariba\RawData upload sheet */

update u
set u.[ContractInternalID] = d.ContractInternalID
from [dbo].[T_TheCompany_Ariba_ProductsFullText_Upload] u inner join T_TheCompany_AribaDump d on u.contractnumber = d.ContractNumber

update u 
set u.productgroupid = p.productgroupid
from [dbo].[T_TheCompany_Ariba_ProductsFullText_Upload] u inner join TPRODUCTGROUP p on u.productname = p.PRODUCTGROUP

update [T_TheCompany_Ariba_ProductsFullText_Upload] set source = 'FullText'

INSERT INTO T_TheCompany_Ariba_Products_In_Contracts_FullText 
([ContractNumber]
           ,[Product]
        
          
           ,[ProductgroupID]
           ,[ContractInternalID]
          )
SELECT 
[ContractNumber]
           ,[ProductName]         
       
           ,[PRODUCTGROUPID]
           ,[ContractInternalID]
           
FROM [dbo].[T_TheCompany_Ariba_ProductsFullText_Upload]
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_ConfidentialityFlag_Insert]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[TheCompany_ConfidentialityFlag_Insert]

as

BEGIN
select top 1 1 from t_TheCompany_all
/* TOP SECRET - INSERT */
/* now replaced by TheCompany_1DAILY_ConfidentialityFlag */
/*
  INSERT INTO [TheVendor_app].[dbo].[TEXTRA_FIELD_IN_CONTRACT]
			( 
		  [EXTRA_FIELDID] /* 100002 = Confidentiality Flag */
		  ,[CONTRACTID]
		  ,[MIK_EDIT_VALUE] /* Top Secret etc. */
		  )

	  SELECT 
		  100002 /* [EXTRA_FIELDID] */
		  , [CONTRACTID]
		  , 'Top Secret'
	  FROM TCONTRACT
	  WHERE [contract] like '%top secret%'
	  and CONTRACTID not in (select CONTRACTID 
		from [TEXTRA_FIELD_IN_CONTRACT] 
		where [EXTRA_FIELDID] = 100002) /* not already there */

/* STRICTLY CONFIDENTIAL - INSERT */

  INSERT INTO [TheVendor_app].[dbo].[TEXTRA_FIELD_IN_CONTRACT]
			( 
		  [EXTRA_FIELDID] /* 100002 = Confidentiality Flag */
		  ,[CONTRACTID]
		  ,[MIK_EDIT_VALUE] /* Top Secret etc. */
		  )
	  SELECT 
		  100002 /* [EXTRA_FIELDID] */
		  , [CONTRACTID]
		  , 'STRICTLY CONFIDENTIAL'
	  FROM TCONTRACT
	  WHERE [contract] like '%Strictly Confidential*%'
	  and CONTRACTID not in (select CONTRACTID from [TEXTRA_FIELD_IN_CONTRACT] where [EXTRA_FIELDID] = 100002) /* not already there */

/* CONFIDENTIAL - INSERT */

  INSERT INTO [TheVendor_app].[dbo].[TEXTRA_FIELD_IN_CONTRACT]
			( 
		  [EXTRA_FIELDID] /* 100002 = Confidentiality Flag */
		  ,[CONTRACTID]
		  ,[MIK_EDIT_VALUE] /* Strictly Confidential */
		  )
	  SELECT 
		  100002 /* [EXTRA_FIELDID] */
		  , [CONTRACTID]
		  , 'CONFIDENTIAL'
	  FROM TCONTRACT
	  WHERE 
		([contract] like '%Confidential*%' 
			and [contract] not like '%strictly Confidential%' 
			and [contract] not like '%top secret%')
	  and CONTRACTID not in (select CONTRACTID from [TEXTRA_FIELD_IN_CONTRACT] where [EXTRA_FIELDID] = 100002) /* not already there */

/* Material Agreement Flag */

	    INSERT INTO [TheVendor_app].[dbo].[TEXTRA_FIELD_IN_CONTRACT]
			( 
		  [EXTRA_FIELDID] /* 100003 */
		  ,[CONTRACTID]
		  ,[MIK_EDIT_VALUE] /* Top Secret etc. */
		  )
	  SELECT 
		  100003 /* [EXTRA_FIELDID] = MaterialContract*/
		  , [CONTRACTID]
		  , 'Material'
	  FROM T_TheCompany_ALL
	  WHERE 
		CONTRACTID not in (select CONTRACTID 
							from [TEXTRA_FIELD_IN_CONTRACT] 
							where 
							[EXTRA_FIELDID] = 100003) /* not already there */
		AND STATUSID = 5 /* active */
		AND ([Title_InclTopSecret] like '%top secret%' /* Title is Top Secret */
			OR [Title_InclTopSecret] like '%Strictly Confidential%'
			OR (AGREEMENT_TYPEID in (SELECT AGREEMENT_TYPEID 
							FROM TAGREEMENT_TYPE 
							WHERE FIXED LIKE '%§Material%')
							)
			OR (LumpSum >1000000 
				AND LumpSumCurrency in ('NOK','EUR','DKK', 'SEK', 'USD')) /* Agreement Type Distribution and high amount */
				)
*/
END

	/* select * 
	FROM [TEXTRA_FIELD_IN_CONTRACT]
	WHERE CONTRACTID = 148186 /* contractnumber = 'TEST-00000080' */ 

	select * from TCONTRACT where contractnumber = 'TEST-00000125'
	CONTRACTID = 195094

	select * 
	FROM [TEXTRA_FIELD_IN_CONTRACT]
	WHERE CONTRACTID = 195094 */

GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Convert_Ariba_ContractID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_Convert_Ariba_ContractID](
                  @CONTRACTID bigint
                , @XtPrefix as VARCHAR(255) /* Wave # 01 etc... !ARIBA_WXX */
                , @XtAribaInternalContractID as VARCHAR(255) /* INTERNAL ID so that link works , must start with 'CW' e.g. CW2459900 */
                , @ExpiryDate as date /* e.g. 19 Dec 2017 was the fictional expiry date for W1 */
                , @CommentPrefix as VARCHAR(255) /* This contract has been migrated to Ariba on 19-Dec-2017, 
				you can find it there under the following link: xxx correct link as of Dec-18 */
)
AS




DECLARE @RESULTSTRING AS VARCHAR(255)

/* Contract ID must be valid */
	IF NOT EXISTS ( SELECT  1
					FROM    dbo.tcontract
					WHERE   Contractid = @CONTRACTID)
		BEGIN
			SET @RESULTSTRING = 'Contract ID does not exist: ' + (CASE WHEN @CONTRACTID IS NULL THEN 'NULL' ELSE STR(@CONTRACTID) END)
			GOTO lblTerminate 
		END

/* Counter Party Number must match the @XtPrefix */
	IF NOT EXISTS ( SELECT  1
					FROM    dbo.tcontract
					WHERE   Contractid = @CONTRACTID
					AND COUNTERPARTYNUMBER = @XtPrefix)
		BEGIN
			SET @RESULTSTRING = 'Contract does not have the ARIBA prefix in the Counter party number field, abort'
			GOTO lblNoChange 
		END
		
BEGIN

		BEGIN
		
			
			PRINT '!!! Contract Description: '
			if @XtAribaInternalContractID is not null and @XtPrefix is not null
				BEGIN					
					update tcontract
					set [contract] = 'ARIBA#'+ @XtAribaInternalContractID + ': '+ contract
					/* ARIBA#CW2459900: T-AT - Chemiepark Linz Standortfirmen (TAS Bauphysik) - Vereinbarung über Lärmkataster Chemiepark Linz - 20-Feb-2015 */
					where CONTRACTID = @CONTRACTID 
					and COUNTERPARTYNUMBER = @XtPrefix
					and CONTRACT not like 'ARIBA%'
					and len('ARIBA#'+ @XtAribaInternalContractID + ': ') <=255  /* field size is 255 or statement will terminate */
				END
			
			/* Expiry date, defined end date */

			/* Contract Description */
			/* also: prior exp. date
			select contractid, contractnumber, len(contract + ' * Expiry date was: ' +  CONVERT(VARCHAR(11),  EXPIRYDATE ) + ' *' ), contract
			 from tcontract 
			where COUNTERPARTYNUMBER = '!ARIBA_W01'
			and expirydate > '2017-12-19' 
			and contract not like '%expiry date was%'
			*/

			/* no longer think it is a good idea to set them to expired, therefore commenting out section */
			if @ExpiryDate is not null and EXISTS (select contractid 
													from TCONTRACT 
													where CONTRACTID = @CONTRACTID and EXPIRYDATE is null)
				BEGIN

					update tcontract
						set EXPIRYDATE = @ExpiryDate
						, DEFINEDENDDATE = 1
						, contract = contract + (case when expirydate > @ExpiryDate
												then '* Expiry date was: ' +  CONVERT(VARCHAR(11),  EXPIRYDATE ) + '*' 
												ELSE '' END)
					where CONTRACTID = @CONTRACTID 
						AND [contract] like 'ARIBA%'
						and COUNTERPARTYNUMBER = @XtPrefix
						and (EXPIRYDATE is null /* not expiry date */
							OR EXPIRYDATE > @ExpiryDate /* Expirydate, but in the future and contract would therefore remain active */)
						AND len(contract + (case when expirydate > @ExpiryDate
												then '* Expiry date was: ' +  CONVERT(VARCHAR(11),  EXPIRYDATE ) + '*' 
												ELSE '' END)) <=255

					PRINT '!!! Expiry date populated'

				END

			/* delete review date if there is one, not needed anymore since contract is terminated */
			/* or leave it as a record? 
					update tcontract
						set REVIEWDATE = NULL
					where 
						CONTRACTID = @CONTRACTID 
						AND [contract] like 'ARIBA%'
						and COUNTERPARTYNUMBER = @XtPrefix
						and EXPIRYDATE is not null /* expired */
						AND REVIEWDATE IS NOT NULL /* there is a review date */
*/

			/* review date REMINDERS */
/* NOTE: it could be that these are automatically deactivated once an end date is set - check on wave 3 first */
			EXEC [dbo].[TheCompany_Reminders_Deactivate_ContractID] @CONTRACTID , @ExpiryDate /* expiry date is needed for TPerson turnedoffdate field */

			/* TCONTRACT.comments = nvarchar(2000) */
			PRINT 'Comment Prefix: '+ @CommentPrefix
			if @CommentPrefix is not null 

				BEGIN
				
					update tcontract
					set [COMMENTS] = @CommentPrefix + (CASE WHEN[COMMENTS] IS NULL THEN '' ELSE ' '+[COMMENTS] END) 
					where CONTRACTID = @CONTRACTID 
					AND [contract] like 'ARIBA#%' /* Ariba prefix in contract title */
					and COUNTERPARTYNUMBER = @XtPrefix
					and ([COMMENTS] is null or comments not like '/* This contract has been migrated to Ariba%' )/* comment not already flagged */
					
					PRINT '!!! Comments prefixed with Ariba comment'
					
				END
				
			PRINT '!!! ACL: '
			
			/* Delete write privileges except for system users */

			/* back up ACL entries before deleting */
		 /* unique index is on ACLID to prevent dupes */
			select * 
			INTO T_TheCompany_ACL_Deletes 
			from TACL a
			WHERE 
				a.objectid = @CONTRACTID 
				AND a.PRIVILEGEID = 2 /* WRITE */
				AND a.OBJECTID IN (SELECT CONTRACTID FROM TCONTRACT WHERE COUNTERPARTYNUMBER like '!ARIBA%' /* migrated records */)
				AND	(a.groupid is null or groupid not in(
							126 /*System Internal*/
							, 0 /* Administration - System DELETE PRIVILEGE */
							))
										
			Delete 
			from TACL 
			WHERE 
				objectid = @CONTRACTID 
				AND PRIVILEGEID = 2 /* WRITE */
				AND OBJECTID IN (SELECT CONTRACTID FROM TCONTRACT WHERE COUNTERPARTYNUMBER like '!ARIBA%' /* migrated records */)
				AND	(groupid is null or groupid not in(
							126 /*System Internal*/
							, 0 /* Administration - System DELETE PRIVILEGE */
							))
			
			/* deactivate reminders */
			
			PRINT '!!! TheCompany_Reminders_Deactivate_ContractID: '
			EXEC TheCompany_Reminders_Deactivate_ContractID @CONTRACTID, @ExpiryDate
			
			GOTO lblEnd
			
		END


GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'
GOTO lblBlankLine

lblNoChange:
PRINT '--- Statement did not result in any changes'
GOTO lblBlankLine

lblEnd: 
PRINT '*** Record updated Successfully'

lblBlankLine:
PRINT '     ' + @RESULTSTRING
PRINT CHAR(13) /* carriage return */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Convert_Ariba_ContractID_REVERSE]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_Convert_Ariba_ContractID_REVERSE](
                @CONTRACTID bigint
                , @XtPrefix as VARCHAR(255) /* ARIBA_W01_EXCEPT */
                /* , @ExpiryDate as date */
)
AS

/*
0. SELECT CONTRACTID FROM TCONTRACT WHERE CONTRACTNUMBER = 'Contract-11144466'
1. Open Tcontract as edit top 200 rows and change counter party number to ARIBA_W01_EXCEPT or ARIBA_W02_EXCEPT
WHERE CONTRACTID = 151058
2. Run this procedure: exec TheCompany_Convert_Ariba_ContractID_REVERSE CONTRACTID,'ARIBA_W02_EXCEPT' 
contract is initially read only
remove CW2461283 from title
3. run TheCompany_Maintenance_AddRemoveAutoPermissions manually to add permissions for legal back
4. in the contract under the ACL tab, check 'write' for the groups that need it
5. remove end date if it is equal to the migration date
*/

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)
SET @RESULTSTRING = 'BEGIN'
/* Contract ID must be valid */
	IF NOT EXISTS ( SELECT  1
					FROM    dbo.tcontract
					WHERE   Contractid = @CONTRACTID)
		BEGIN
			SET @RESULTSTRING = 'Contract ID does not exist: ' + (CASE WHEN @CONTRACTID IS NULL THEN 'NULL' ELSE STR(@CONTRACTID) END)
			GOTO lblTerminate 
		END

/* Counter Party Number must match the @XtPrefix */
	IF NOT EXISTS ( SELECT  1
					FROM    dbo.tcontract
					WHERE   Contractid = @CONTRACTID
					AND COUNTERPARTYNUMBER = @XtPrefix)
		BEGIN
			SET @RESULTSTRING = 'Contract does not have the ARIBA_EXCEPT prefix in the Counter party number field, abort'
			GOTO lblNoChange 
		END
		
BEGIN

		BEGIN
			
			/* remove title flag */
			update tcontract
			set contract = replace(contract,'ARIBA#','') 
			where CONTRACTID = @CONTRACTID 
			and COUNTERPARTYNUMBER = @XtPrefix
			and CONTRACT like 'ARIBA#%'
			and counterpartynumber like 'ARIBA_W%_EXCEPT'

				GOTO lblEnd
		END


GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'
GOTO lblBlankLine

lblNoChange:
PRINT '--- Statement did not result in any changes'
GOTO lblBlankLine

lblEnd: 
PRINT '*** Record updated Successfully'

lblBlankLine:
PRINT '     ' + @RESULTSTRING
PRINT CHAR(13) /* carriage return */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Convert_ARIBA_Cursor]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_Convert_ARIBA_Cursor] 

AS
/* before running this check max description length to make sure the ARIBA prefix and the expiry date suffix fit into the 255 char field */

/*
	back up full details 
	
	select * into T_TheCompany_Xt_Detail 
	from TCONTRACT
	where COUNTERPARTYNUMBER = '!ARIBA_Wx'
	*/

/* back up acl for T_TheCompany_Adhoc_ContractNumberFileDownload records first in case of restores / reverse mig

	select * into T_TheCompany_AribaW2_ACL 
	from tacl a
	inner join T_TheCompany_Adhoc_ContractNumberFileDownload l on a.objectid = l.contractid

		select * into T_TheCompany_AribaW2_ACL_Deletes
	from TACL 
	WHERE 	
		PRIVILEGEID = 2 /* WRITE */
		AND OBJECTID IN (SELECT CONTRACTID FROM TCONTRACT WHERE COUNTERPARTYNUMBER like '!ARIBA%' /* migrated records */)
		AND	(groupid is null or groupid not in(
					126 /*System Internal*/
					, 0 /* Administration - System DELETE PRIVILEGE */
					))

	back up 
	/* add migration wave flags */

	select counterpartynumber from tcontract 
	where 
	contractid in (select contractid from T_TheCompany_Adhoc_ContractNumberFileDownload)
	AND (COUNTERPARTYNUMBER not like '!ARIBA%' or COUNTERPARTYNUMBER is null) /* not already previously flagged */

	/* check for problematic counterparty number fields */			
	select CONTRACTNUMBER,COUNTERPARTYNUMBER from tcontract 
	where CONTRACTID in (select contractid from T_TheCompany_Adhoc_ContractNumberFileDownload)
	order by COUNTERPARTYNUMBER desc

	update tcontract set COUNTERPARTYNUMBER ='!ARIBA_W02'
	where 
	contractid in (select contractid from T_TheCompany_Adhoc_ContractNumberFileDownload)
	AND (COUNTERPARTYNUMBER not like '!ARIBA%' or COUNTERPARTYNUMBER is null) /* not already previously flagged */

*/
/*DECLARE @ExpiryDate as Date*/

/* Counter Party Number must match the @XtPrefix 
	IF NOT EXISTS ( 	SELECT  1  /* , EXPIRYDATE, rev_expirydate, DEFINEDENDDATE, statusid, reviewdate */
		FROM    dbo.tcontract c 
				inner join dbo.T_TheCompany_Xt x 
				on c.counterpartynumber = x.xt_Prefix
		WHERE   c.COUNTERPARTYNUMBER = x.COUNTERPARTYNUMBER
			

		BEGIN
			SET @RESULTSTRING = 'No contracts with xt_ Prefix in the counterpartynumber that don not have an xt_ Prefix'
			GOTO lblNoChange 
		END
		*/
BEGIN		

DECLARE @CONTRACTID bigint 
DECLARE @CONTRACTNUMBERARIBA nVARCHAR(255)
DECLARE @CONTRACTINTERNALID nVARCHAR(255)
DECLARE @XtPrefix nvarchar(255)
DECLARE @CommentPrefix  nVARCHAR(255)
DECLARE @EXPIRYDATE as date
/*DECLARE @XtPrefix AS VARCHAR(255)*/
DECLARE @RESULTSTRING  nVARCHAR(255)

/* Notes: counterparty field must have Ariba wave # in it or script won't run */
	/* populate contractid from number */
	/*delete from T_TheCompany_Adhoc_ContractNumber_AribaMigration where counterpartynumber = '!ARIBA_W02'*/

	update m
	set m.CONTRACTID = t.contractid
	from T_TheCompany_Adhoc_ContractNumber_AribaMigration m 
	inner join TCONTRACT t on m.CONTRACTNUMBER = t.CONTRACTNUMBER
	where m.contractid <> t.contractid


	DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR		
			
	SELECT  CONTRACTID
	, /*d.CONTRACTNUMBERARIBA, */ COUNTERPARTYNUMBER AS XtPrefix
	, CONTRACTINTERNALID
	, EXPIRYDATE
		, '/* This contract has been migrated to Ariba' /* + ' on  ' */ +  ', you can find it there under the following link: ' +
		'https://s1.ariba.com/Sourcing/Main/ad/viewDocument?ID=' + CONTRACTINTERNALID /* CW2333826 */ + ' */' as COMMENTPREFIX
	FROM    dbo.T_TheCompany_Adhoc_ContractNumber_AribaMigration d 
	WHERE [Converted_Flag] is null /* (-1 = already done */

	OPEN curContracts
	FETCH NEXT FROM curContracts INTO @CONTRACTID, @XtPrefix,@CONTRACTINTERNALID,  @ExpiryDate, @CommentPrefix
	
		WHILE @@FETCH_STATUS = 0 BEGIN

			PRINT @CONTRACTID
			PRINT @XtPrefix
			
			EXEC TheCompany_Convert_Ariba_ContractID @CONTRACTID, @XtPrefix, @CONTRACTINTERNALID, @ExpiryDate, @CommentPrefix
			FETCH NEXT FROM curContracts INTO @CONTRACTID, @XtPrefix,@CONTRACTINTERNALID,  @ExpiryDate, @CommentPrefix
		END		 
	 
	CLOSE curContracts
	DEALLOCATE curContracts

GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'
GOTO lblBlankLine

lblNoChange:
PRINT '--- Statement did not result in any changes'
GOTO lblBlankLine

lblEnd: 
PRINT '*** Record updated Successfully'

lblBlankLine:
PRINT '     ' + @RESULTSTRING
PRINT CHAR(13) /* carriage return */

END

GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Convert_Xt_ContractID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_Convert_Xt_ContractID](
                @CONTRACTID bigint
                , @XtPrefix as VARCHAR(255)
                , @ExpiryDate as date
)
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

/* Contract ID must be valid */
	IF NOT EXISTS ( SELECT  1
					FROM    dbo.tcontract
					WHERE   Contractid = @CONTRACTID)
		BEGIN
			SET @RESULTSTRING = 'Contract ID does not exist: ' + (CASE WHEN @CONTRACTID IS NULL THEN 'NULL' ELSE STR(@CONTRACTID) END)
			GOTO lblTerminate 
		END

/* Counter Party Number must match the @XtPrefix */
	IF NOT EXISTS ( SELECT  1
					FROM    dbo.tcontract
					WHERE   Contractid = @CONTRACTID
					AND COUNTERPARTYNUMBER = @XtPrefix)
		BEGIN
			SET @RESULTSTRING = 'Contract does not have the XtPrefix in the Counter party number field, abort'
			GOTO lblNoChange 
		END
		
BEGIN

		BEGIN
			
			update tcontract
			set contractnumber = replace(contractnumber, 'Contract',@XtPrefix)
			where CONTRACTID = @CONTRACTID 
			and CONTRACTNUMBER like 'Contract-%'
			and COUNTERPARTYNUMBER = @XtPrefix
			and CONTRACTNUMBER not like 'Nyco%'

			update tcontract
			set contractnumber = replace(contractnumber, 'NycoContract',@XtPrefix+'Nyco')
			where CONTRACTID = @CONTRACTID 
			and CONTRACTNUMBER like 'NycoContract-%'
			and COUNTERPARTYNUMBER = @XtPrefix

			update tcontract
			set contractnumber = replace(contractnumber, 'NycomedContract',@XtPrefix+'_Ny')
			where CONTRACTID = @CONTRACTID 
			and CONTRACTNUMBER like 'NycomedContract-%'
			and COUNTERPARTYNUMBER = @XtPrefix
			
			update tcontract
			set contractnumber = replace(contractnumber, 'Yoda',@XtPrefix+'_Yoda')
			where CONTRACTID = @CONTRACTID 
			and CONTRACTNUMBER like 'Yoda-%'
			and COUNTERPARTYNUMBER = @XtPrefix
			
			update tcontract
			set contractnumber = replace(contractnumber, 'NO',@XtPrefix+'_NO')
			where CONTRACTID = @CONTRACTID 
			and CONTRACTNUMBER like 'NO-%'
			and COUNTERPARTYNUMBER = @XtPrefix
			
			update tcontract
			set EXPIRYDATE = @ExpiryDate 
			, DEFINEDENDDATE = 1
			, REVIEWDATE = null
			, STATUSID = 6 /* expired */
			where CONTRACTID = @CONTRACTID 
			and 
			(
				/*(*/ (EXPIRYDATE is null or EXPIRYDATE > @ExpiryDate) /* and REV_EXPIRYDATE is null) */ /* not yet terminated, or expiry date in the future, preventing the contract to change to status 'expired' */
				OR REVIEWDATE IS NOT NULL
				OR STATUSID IN (4 /* Awarded */, 5 /* Active */)
				OR DEFINEDENDDATE = 0 /* no fixed end date */
			)


				GOTO lblEnd
		END


GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'
GOTO lblBlankLine

lblNoChange:
PRINT '--- Statement did not result in any changes'
GOTO lblBlankLine

lblEnd: 
PRINT '*** Record updated Successfully'

lblBlankLine:
PRINT '     ' + @RESULTSTRING
PRINT CHAR(13) /* carriage return */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Convert_Xt_ContractID_REVERSE]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_Convert_Xt_ContractID_REVERSE](
                @CONTRACTID bigint 
                , @XtPrefix as VARCHAR(255)
                /*, @ExpiryDate as date */
)
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

/* Contract ID must be valid */
	IF NOT EXISTS ( SELECT  1
					FROM    dbo.tcontract
					WHERE   Contractid = @CONTRACTID)
		BEGIN
			SET @RESULTSTRING = 'Contract ID does not exist: ' + (CASE WHEN @CONTRACTID IS NULL THEN 'NULL' ELSE STR(@CONTRACTID) END)
			GOTO lblTerminate 
		END

/* Counter Party Number must match the @XtPrefix */
	IF NOT EXISTS ( SELECT  1
					FROM    dbo.tcontract
					WHERE   Contractid = @CONTRACTID
					AND COUNTERPARTYNUMBER ='!'+ @XtPrefix
					and CONTRACTNUMBER like @XtPrefix +'%')
		BEGIN
			SET @RESULTSTRING = 'Contract does not have an XtPrefix in the contract number, abort'
			GOTO lblNoChange 
		END
		
BEGIN

		BEGIN
			
			update tcontract
			set contractnumber = replace(contractnumber, @XtPrefix,'Contract')
			where CONTRACTID = @CONTRACTID 
			and CONTRACTNUMBER like @XtPrefix + '%'
			AND COUNTERPARTYNUMBER ='!'+ @XtPrefix
			and CONTRACTNUMBER not like 'Nyco%'
			and CONTRACTNUMBER not like '_Ny%'

			update tcontract
			set contractnumber = replace(contractnumber, @XtPrefix+'Nyco', 'NycoContract')
			where CONTRACTID = @CONTRACTID 
			and CONTRACTNUMBER like @XtPrefix+'Nyco'+ '%'
			AND COUNTERPARTYNUMBER ='!'+ @XtPrefix

			update tcontract
			set contractnumber = replace(contractnumber, @XtPrefix+'_Ny', 'NycomedContract')
			where CONTRACTID = @CONTRACTID 
			and CONTRACTNUMBER like @XtPrefix+'_Ny'+ '%'
			AND COUNTERPARTYNUMBER ='!'+ @XtPrefix
			
			update tcontract
			set contractnumber = replace(contractnumber, @XtPrefix+'_Yoda', 'Yoda')
			where CONTRACTID = @CONTRACTID 
			and CONTRACTNUMBER like @XtPrefix+'_Yoda'+ '%'
			AND COUNTERPARTYNUMBER ='!'+ @XtPrefix
			
			update tcontract
			set contractnumber = replace(contractnumber,@XtPrefix+'_NO', 'NO')
			where CONTRACTID = @CONTRACTID 
			and CONTRACTNUMBER like @XtPrefix + '_NO'+ '%'
			AND COUNTERPARTYNUMBER ='!'+ @XtPrefix

			GOTO lblEnd
		END


GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'
GOTO lblBlankLine

lblNoChange:
PRINT '--- Statement did not result in any changes'
GOTO lblBlankLine

lblEnd: 
PRINT '*** Record updated Successfully'

lblBlankLine:
PRINT '     ' + @RESULTSTRING
PRINT CHAR(13) /* carriage return */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Convert_Xt_Cursor]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_Convert_Xt_Cursor]

AS

DECLARE @CONTRACTID AS bigint
DECLARE @XtPrefix AS VARCHAR(255)
DECLARE @RESULTSTRING AS VARCHAR(255)
DECLARE @ExpiryDate as Date

/* Counter Party Number must match the @XtPrefix */
	IF NOT EXISTS ( 	SELECT  1  /* , EXPIRYDATE, rev_expirydate, DEFINEDENDDATE, statusid, reviewdate */
		FROM    dbo.tcontract c 
				inner join dbo.T_TheCompany_Xt x 
				on c.counterpartynumber = x.xt_Prefix
		WHERE   COUNTERPARTYNUMBER like 'Xt_%'	AND 
			(CONTRACTNUMBER not like 'Xt_%'
			OR EXPIRYDATE IS NULL
			OR EXPIRYDATE > GETDATE()
			OR DEFINEDENDDATE = 0
			OR REVIEWDATE is not null
			OR STATUSID in (4 /* Awarded */, 5 /* Active */))					
					)
		BEGIN
			SET @RESULTSTRING = 'No contracts with xt_ Prefix in the counterpartynumber that don not have an xt_ Prefix'
			GOTO lblNoChange 
		END
		
BEGIN		
		
	DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR		
			
	SELECT  CONTRACTID, x.xt_Prefix, x.xt_TermDate  /* , EXPIRYDATE, rev_expirydate, DEFINEDENDDATE, statusid, reviewdate */
		FROM    dbo.tcontract c 
				inner join dbo.T_TheCompany_Xt x 
				on c.counterpartynumber = x.xt_Prefix
		WHERE   COUNTERPARTYNUMBER like 'Xt_%'	AND 
			(CONTRACTNUMBER not like 'Xt_%'
			OR EXPIRYDATE IS NULL
			OR EXPIRYDATE > GETDATE()
			OR DEFINEDENDDATE = 0
			OR REVIEWDATE is not null
			OR STATUSID in (4 /* Awarded */, 5 /* Active */))

	OPEN curContracts
	FETCH NEXT FROM curContracts INTO @CONTRACTID, @XtPrefix, @ExpiryDate
	
		WHILE @@FETCH_STATUS = 0 BEGIN

			PRINT @CONTRACTID
			PRINT @XtPrefix
			
			EXEC TheCompany_Convert_Xt_ContractID @CONTRACTID, @XtPrefix, @ExpiryDate
			FETCH NEXT FROM curContracts INTO @CONTRACTID, @XtPrefix, @ExpiryDate
		END		 
	 
	CLOSE curContracts
	DEALLOCATE curContracts

GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'
GOTO lblBlankLine

lblNoChange:
PRINT '--- Statement did not result in any changes'
GOTO lblBlankLine

lblEnd: 
PRINT '*** Record updated Successfully'

lblBlankLine:
PRINT '     ' + @RESULTSTRING
PRINT CHAR(13) /* carriage return */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Convert_Xt_Cursor_FlagContracts]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[TheCompany_Convert_Xt_Cursor_FlagContracts]

AS

begin

	update  xt 
	set xt.Contractid = (select Contractid from TCONTRACT c where c.ContractNumber = xt.contractnumber)
	from [T_TheCompany_XtConvert] xt
	where contractid is null

	select c.contractnumber, c.COUNTERPARTYNUMBER from TCONTRACT c inner join [T_TheCompany_XtConvert] xt on c.CONTRACTID = xt.contractid
	where c.COUNTERPARTYNUMBER is null or c.COUNTERPARTYNUMBER ='' 

	/* select * from TCONTRACT where COUNTERPARTYNUMBER = '!Xt_AstraZAB' */
	/* Contract-00013785 */

	Update c
	set c.COUNTERPARTYNUMBER = xt.[Xt_Label]
	from TCONTRACT c inner join [T_TheCompany_XtConvert] xt on c.CONTRACTID = xt.contractid
	WHERE 
	c.COUNTERPARTYNUMBER is null or c.COUNTERPARTYNUMBER = ''


END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Convert_Xt_Cursor_REVERSE]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_Convert_Xt_Cursor_REVERSE]

AS

DECLARE @CONTRACTID AS bigint
DECLARE @XtPrefix AS VARCHAR(255)
DECLARE @RESULTSTRING AS VARCHAR(255)
DECLARE @ExpiryDate as Date

/* Counter Party Number must match the @XtPrefix */
	IF NOT EXISTS ( 	SELECT  1  /* , EXPIRYDATE, rev_expirydate, DEFINEDENDDATE, statusid, reviewdate */
		FROM    dbo.tcontract c inner join dbo.T_TheCompany_Xt x 
				on REPLACE(COUNTERPARTYNUMBER,'!','') = x.xt_Prefix
		WHERE   CONTRACTNUMBER like 'Xt_%'	 
			AND COUNTERPARTYNUMBER like '!Xt_%')
			
		BEGIN
			SET @RESULTSTRING = 'No contracts with xt_ Prefix number that do not have an xt_ Prefix counterparty number'
			GOTO lblNoChange 
		END
		
BEGIN		
		
	DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR		
			
	SELECT  CONTRACTID, REPLACE(COUNTERPARTYNUMBER,'!','') /* , EXPIRYDATE, rev_expirydate, DEFINEDENDDATE, statusid, reviewdate */
		FROM    dbo.tcontract c inner join dbo.T_TheCompany_Xt x 
				on REPLACE(COUNTERPARTYNUMBER,'!','') = x.xt_Prefix
		WHERE   CONTRACTNUMBER like 'Xt_%'	 
			AND COUNTERPARTYNUMBER like '!Xt_%'

	OPEN curContracts
	FETCH NEXT FROM curContracts INTO @CONTRACTID, @XtPrefix
	
		WHILE @@FETCH_STATUS = 0 BEGIN

			PRINT @CONTRACTID
			PRINT @XtPrefix
			
			EXEC TheCompany_Convert_Xt_ContractID_REVERSE @CONTRACTID, @XtPrefix
			FETCH NEXT FROM curContracts INTO @CONTRACTID, @XtPrefix
		END		 
	 
	CLOSE curContracts
	DEALLOCATE curContracts

GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'
GOTO lblBlankLine

lblNoChange:
PRINT '--- Statement did not result in any changes'
GOTO lblBlankLine

lblEnd: 
PRINT '*** Record updated Successfully'

lblBlankLine:
PRINT '     ' + @RESULTSTRING
PRINT CHAR(13) /* carriage return */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_CORRECTION_433_Duplicates_tdepartmentrole_in_object]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[TheCompany_CORRECTION_433_Duplicates_tdepartmentrole_in_object]

AS

BEGIN

	   select max(o.DEPARTMENTROLE_IN_OBJECTID) as max_DEPARTMENTROLE_IN_OBJECTID
	   into #tmp_dbo_max_DEPARTMENTROLE_IN_OBJECTID 
	   from tdepartmentrole_in_object o inner join vcontract c on c.contractid = o.objectid
	   group by objecttypeid, objectid, departmentid, roleid
	   having count(*)>1

	   /* select * from #tmp_dbo_max_DEPARTMENTROLE_IN_OBJECTID */

	   delete from tdepartmentrole_in_object where [DEPARTMENTROLE_IN_OBJECTID] in (select max_DEPARTMENTROLE_IN_OBJECTID from #tmp_dbo_max_DEPARTMENTROLE_IN_OBJECTID)
	   drop table #tmp_dbo_max_DEPARTMENTROLE_IN_OBJECTID 


END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_FileDownload_DONOTUSE_AdhocContractList]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_FileDownload_DONOTUSE_AdhocContractList]

as

BEGIN

/* PROBLEM: does not download all files if the names are too long, therefore download plain files */

/*
select * from tfile
where fileid in (select fileid from vdocument where objecttypeid = 1 and objectid in
	(select contractid from tcontract where contractnumber in
	('Contract-xx', 
	'Contract-yy')
	)
	)
*/

select fileid, filetype,replace(filetype,1,'') from tfile
where fileid in (select fileid from V_TheCompany_VDOCUMENT where contractid in
	(SELECT CONTRACTID FROM T_TheCompany_Adhoc_ContractNumberFileDownload )
	)
and FileType in( '.pdf', '.doc', '.docx', '.txt', '.pptx', '.msg')

	update tfile
	set FileType = filetype + '1'
	/* select * from tfile */
	WHERE 
	FileType in( '.pdf', '.doc', '.docx', '.txt', '.pptx', '.msg')
	AND fileid in (select fileid from V_TheCompany_VDOCUMENT where contractid in
	(SELECT CONTRACTID FROM T_TheCompany_Adhoc_ContractNumberFileDownload )
	)

					
	update tfile
	set filetype = replace(filetype,'1','')
	WHERE 
	filetype like '%1'

/* retrieve files without folder structure */		

	/*
	  select replace(contract,' *POGMS*','')   from tcontract 

	   update tcontract 
	 set contract = replace(contract,' *POGMS*','')
	  where contract like '%*POGMS%' 

	where contractnumber in
		('Contract-11144823', )

	 update tcontract 
	 set contract = contract + ' OB_CMO'
	  where contractnumber in ('Contract-11142441'
	, 'Contract-11119667')

	contract = contract + ' *POGMS*' 

	  select   from tcontract 

	 update tcontract 
	 /* set contract = contract + ' OB_CMO' */
	 set contract = replace(contract,' OB_CMO','') 
	where contractnumber in
		('Contract-11144823', 
		'Contract-11132050')
		*/
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_FullText]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_FullText]

as

BEGIN

	/* see Adhoc_FullText */
	/* T_TheCompany_Tag_in_Document */
	/* TheCompany_3SATNIGHT_AddDocumentTag_FullText */
	/* documents currently tagged but not CONTRACTS, however, T-TheCompany_ALL has Tags field that concatenates doc tags */
	/* add log table */
	/* views such as ..*/
	select * from V_TheCompany_FullText_ChangeOfControl

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_FullText_ProcessSteps]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_FullText_ProcessSteps]

as

BEGIN

/* TFILE is the table to modify for .pdf1 (not x since xlsx is then a problem) 
table in Access Adhoc db is T_TheCompany_Adhoc_ContractNumberFileDownload 
use file dsn if TheVendor_PROD DSN does not work */

/* update fetch counter */
EXEC TheCompany_FullText_TFILEINFO_OCRFetchCounter

/* get overview */
	select top 1000 * 
	from V_TheCompany_FullText_TFILEINFO_OCR_FileIDsInScope /* more than 7 days old, ocr flag is null or 0 - no keywords found including Docusign etc */
	where LastChangedBy <>83663 /* not already full text scanned */
		
	/* in access use file dsn to upload table with user TheVendor if sso does not work */
	/* select * from vdocument where fileid = 267117 */

/* RENAME */
/* if you only want signed contracts: add WHERE d.DOCUMENTTYPEID = 1 *//*'Signed Contracts'*/
	update tfile
	set FileType = '.pdf1'
	WHERE 
	fileid in (select top 1000 fileid 
				from V_TheCompany_FullText_TFILEINFO_OCR_FileIDsInScope /* fetch counter = 0 */ 
				where filetype = '.pdf'
		) 
	AND FileType = '.pdf'
		
/* tag files included with fetch counter 0 so that if they are files with e.g. noise words that can't be searched are included again */			
	update tfileinfo
	set OCRFetchCounter = 1
	where fileid in(select fileid from tfile where filetype = '.pdf1')
	and (OCRFetchCounter is null or OCRFetchCounter = 0)

/* DOWNLOAD FILES WITH DOCUMENT PUMPTER */

/* RUN bat cmdRenamePdf1.bat (M:\TheVendor_Confidential\Maintenance\OCR_Scan) */

/* MAKE BACKUP OF ORIGINALS TO ADMIN FOLDER */

	/* undo .pdf1 to make sure database is consistent */
		update tfile
	set filetype = replace(filetype,'.pdf1','.pdf') /* e.g. '.pdf1' to '.pdf' */
	WHERE 
	filetype like '%.pdf1'
	

	/* DO OCR SCAN , select all files, wait for confirm prompt to continue  */

	/* when done check result folder to see if keyword TheCompany can be found in files 
	Explorer search for content:docusign, contains many from Karin that are mixed signature
	when scan all done look for keyword TheCompany and move all files where keyword found, the others are not scanned
	*/

	/*
	check for Dcousign files with mixed or full Dcousign signature but not readable /* 
	exec [dbo].[TheCompany_TagUpload_DocumentID]  34 /* Docusign */ ,7 /* Document */, 111111 /* must convert to DocumentID */ 
	exec [dbo].[TheCompany_TagUpload_DocumentID]  21 /* OCR Bad Scan */, 7 , /* must convert to DocumentID */ 
	(select documentid from VDOCUMENT where FileID = 376450) 
	376450, 406948

		exec [dbo].[TheCompany_TagUpload_DocumentID]  21 /* OCR Bad Scan */, 7 , 365412
		exec [dbo].[TheCompany_TagUpload_DocumentID]  21 /* OCR Bad Scan */, 7 , 395906

	*/
	use workbook in \\DES80022.nycomed.local\fs10$\Shares\AA-Data-Legal-Transfer\TheVendor_Confidential\Maintenance\OCR_Scan
	to tag

	select DOCUMENTID, FileName, Owner, versiondate from [dbo].[T_TheCompany_EDIT_DocusignFullTextScannedFiles] e inner join VDOCUMENT d on e.file_name = d.FileID


	update [dbo].[T_TheCompany_EDIT_DocusignFullTextScannedFiles]
set id = fl

select file_name, owner, max(filename) as SampleFileName, COUNT(*) from V_TheCompany_EDIT_DocusignFullTextScannedFiles
group by owner

	*/

	/* remaining files: scan manually with Acrobat, and flag corrupt files, enter file ids in list below */

	


	update tdocument 
	set [DESCRIPTION] = [DESCRIPTION] + ' *CORRUPT FILE*'	
	/* next fetch counter procedure run will set [OCRFetchCounter] = 99, 
	Problem file, no OCR Scan */
	where documentid in  (select documentid from tfileinfo 
		where fileid in ('290957') )
		and [DESCRIPTION] not like '%CORRUPT FILE%'

	select * from Vdocument where fileid in ('304987')
	select * from VDOCUMENT where documentid = 304987
		/* flag corrupt files, enter file ids in list below */
	update tdocument 
		set [DESCRIPTION] = [DESCRIPTION] + ' *DOCUSIGN PROTECTED*'	
	/* next fetch counter procedure run will set [OCRFetchCounter] = 99, 
	Problem file, no OCR Scan */
	where documentid in  (select documentid from tfileinfo 
		where fileid in ('253578') )
		and [DESCRIPTION] not like '%DOCUSIGN PROTECTED%'

	/* flag corrupt files, enter file ids in list below */
	update tdocument 
		set [DESCRIPTION] = [DESCRIPTION] + ' *PASSWORD PROTECTED*'	
	/* next fetch counter procedure run will set [OCRFetchCounter] = 99, 
	Problem file, no OCR Scan */
	where documentid in  (select documentid from tfileinfo 
		where fileid in ('264163') )
		and [DESCRIPTION] not like '%PASSWORD PROTECTED%'


	/* select * from tfileinfo where OCRFetchCounter = 1 */
select * from vdocument
	where documentid in (select documentid from tfileinfo where fileid in ('264440')) 
		and Title not like '%CORRUPT FILE%'
		and Title not like '%PASSWORD PROTECTED%'
		and Title not like '%WRITE PROTECTED%'

/* set newly flagged files to OCR counter 99 */
EXEC [dbo].[TheCompany_FullText_TFILEINFO_OCRFetchCounter] 

/* get count and file types affected */			
/*	select filetype, count(*) as FileCount from tfile
	WHERE
filetype like '.pdf1'
	group by filetype


		select fileid, FileType from tfile
	where filetype like '.pdf1'
	*/
/* REVERSE */
	

/* make sure there is nothing left with a 1 suffix */

		select * from tfile 
			WHERE filetype like '.%1'



END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_FullText_TFILEINFO_OCRFetchCounter]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_FullText_TFILEINFO_OCRFetchCounter]
/* 
instructions: \\DES80021.nycomed.local\fs14$\Shares\DEKON23\Rechtsabteilung\TheVendor\Regular Tasks\OCR Scan
This procedure sets the OCR counter to a number 5-9 if text content is detected in pdfs 
(these are the only ones full text scanned so the counter is not needed elsewhere)
it must be run before any documents are automatically full text scanned

Purpose: only documents that are not already OCR Scanned must be included in the bulk OCR scan
primarily because of conversion issues caused by:
- Adobe Docusign (UK uses this)
- Docusign in general (e.g. used by Canada) - docusign locks the docs for editing and this crashes the ocr process
3. per Kim, documents with drawings can get messed up but that is not a major concern for legal docs since most are text

V_TheCompany_FullText_TFILEINFO_OCR_FileIDsInScope

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
								FROM CONTAINSTABLE(TFILE, [File], '"TheCompany"' ) 
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 	

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 9
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter between 0 and 8) /* after ocr upload, file gets new fileinfo version 
		and that entry has the fetchcounter set to 0 instead of NULL) */
		/* and i.documentid in (select documentid from TDOCUMENT where mik_valid = 1) */
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '"Такедa"' ) /* Russian */
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 	

								
	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 8
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter between 0 and 7) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '"Nycomed"' ) 
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 	

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 8
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter between 0 and 5) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '"Shire"' ) 
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 	

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 7
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter between 0 and 6) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '"Altana"' ) 
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 7
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter between 0 and 6) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '"Byk"' ) 
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 6 /* Tigenix */
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter between 0 and 5) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '%Tigenix%' ) /* phone */
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 5 /* any other keyword */
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter = 0) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '%Docusign%' ) /* phone */
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 5 /* any other keyword */
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter = 0) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '%act%' ) /* phone */
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 5 /* any other keyword */
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter = 0) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '%tel%' ) 
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 5 /* any other keyword */
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter = 0) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '%tel%' ) 
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 	

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 5 /* any other keyword */
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter = 0) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '%Form%' ) 
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) /* TheCompany France files */
								

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 5 /* any other keyword */
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter = 0) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '%work%' ) 
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) /* framework */

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 5 /* any other keyword */
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter = 0) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '%one%' ) /* phone */
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 5 /* any other keyword */
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter = 0) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '%com%' ) /* .com */
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 4 /* number combo */
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter = 0) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '%000%' ) 
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 4 /* number combo */
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter = 0) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '%201%' ) 
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 4 /* number combo */
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter = 0) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '%200%' ) 
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 

	update [dbo].[TFILEINFO]
	set [OCRFetchCounter] = 5 /* year */
	where 
		filetype = '.pdf'
		and (OCRFetchCounter is null OR OCRFetchCounter = 0) 
		and fileid in  (SELECT KEY_TBL.[KEY] 
								FROM CONTAINSTABLE(TFILE, [File], '%yea%' ) 
								AS KEY_TBL WHERE KEY_TBL.RANK > 1) 
	/* to include more records key words could be e.g. 199 for 1998 etc 
	BUT many such pdfs will not be relevant (e.g. printer brochure found) 
	STILL this will lessen the number of documents to scan and the # of errors !! */

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
/****** Object:  StoredProcedure [dbo].[TheCompany_KeyWord_Compare]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_KeyWord_Compare]

AS 

BEGIN

 /* 0 */
		drop table T_TheCompany_VCompare_Results_0Exact
	
		select * into T_TheCompany_VCompare_Results_0Exact
		from [V_TheCompany_VCompare_Results_0Exact]

	/* 1 */

		drop table T_TheCompany_VCompare_Results_1LikeFull
	
		select * into T_TheCompany_VCompare_Results_1LikeFull
		from [dbo].[V_TheCompany_VCompare_Results_1LikeFull]

	/* 2 */

		drop table T_TheCompany_VCompare_Results_2FirstWord
	
		select * into T_TheCompany_VCompare_Results_2FirstWord
		from [dbo].[V_TheCompany_VCompare_Results_2FirstWord]

	/* 3 */
		drop table T_TheCompany_VCompare_Results_3LikeLeft8
	
		select * into T_TheCompany_VCompare_Results_3LikeLeft8
		from [dbo].[V_TheCompany_VCompare_Results_3LikeLeft8]

		/* CREATE UNIQUE CLUSTERED INDEX T_TheCompany_KWSR_0_CNT_ARB_CONTRACTID
		ON T_TheCompany_KWSR_1_CNT_ARB (CONTRACTID) */


END

GO
/****** Object:  StoredProcedure [dbo].[TheCompany_KeyWordSearch]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_KeyWordSearch]

AS 

BEGIN


/* [dbo].[V_T_TheCompany_ALL_KeyWordSearch] */

/*	MOVED to daily data load, back on 3-4-21 */
	drop table T_TheCompany_KWS_0_TheVendorView_CNT
	
		select * into T_TheCompany_KWS_0_TheVendorView_CNT
		from [V_TheCompany_KWS_0_TheVendorView_CNT]

		CREATE UNIQUE CLUSTERED INDEX T_TheCompany_KWS_0_TheVendorView_CNT_CONTRACTID
		ON T_TheCompany_KWS_0_TheVendorView_CNT(CONTRACTID)


/* Ariba: [dbo].[TheCompany_Ariba_ProductUploadFullText] */

/* PRODUCT, must run first so that new products are included */
	
	/* clean up product names remove special char? already done in keyword bit at front partially */
/* 	daily load - must rerun if products added adhoc

	drop table T_TheCompany_TPRODUCTGROUP
	
		select * into T_TheCompany_TPRODUCTGROUP
		from [dbo].[V_TheCompany_VPRODUCT]

		CREATE UNIQUE CLUSTERED INDEX T_TheCompany_TPRODUCTGROUP_PRODUCTGROUPID
		ON T_TheCompany_TPRODUCTGROUP (PRODUCTGROUPID) 
		*/

/* COMPANY */

/*	DAILY!
drop table T_TheCompany_VCOMPANY

		select * into T_TheCompany_VCompany
		from [dbo].[V_TheCompany_VCOMPANY] */

	/* turn view into table, e.g. function to remove non-alpha char slows down too much otherwise */
/* Keyword Search Table */

	update T_TheCompany_KeyWordSearch_Input
		set [KeyWordVarchar255] = replace([KeyWordVarchar255],'  ',' ')
		where  [KeyWordVarchar255] like '%  %'

	update T_TheCompany_KeyWordSearch_Input
		set [KeyWordVarchar255] = ltrim(rtrim([KeyWordVarchar255]))
		where  [KeyWordVarchar255] like ' %' or [KeyWordVarchar255] like '% '

	drop table T_TheCompany_KeyWordSearch

		select * into T_TheCompany_KeyWordSearch
		from [dbo].[V_TheCompany_KWS_02_Input_AllFields] /* source table T_TheCompany_KeyWordSearch_Input */

/*			update T_TheCompany_KeyWordSearch
		set [KeyWordVarchar255] = dbo.TheCompany_RemoveNonAlphaNonNumNonSpaceNonHyphen([KeyWordVarchar255])
*/
	/* strip last char if it is a special char */
/*	now done via strip function - update T_TheCompany_KeyWordSearch
		set [KeyWordVarchar255_upper] = 
			left([KeyWordVarchar255_upper], len([KeyWordVarchar255_upper])-1) 
		where [KeyWordVarchar255_upper]  not like '%[$a-zA-Z0-9]' /* e.g. MAGESTO-F- */ */

	/* product tagging KeyWordVarchar255 = PRODUCTGROUP  */

/**********************************/	
/* Level 2 */
/**********************************/	
	/* 2 - TheVendor */

		drop table T_TheCompany_KWS_2_CNT_TPRODUCT_ContractID

			select * into T_TheCompany_KWS_2_CNT_TPRODUCT_ContractID
			from dbo.[V_TheCompany_KWS_2_CNT_TPRODUCT_ContractID]

		drop table T_TheCompany_KWS_2_CNT_TCompany_ContractID /* T_TheCompany_KeyWordSearch_Results_TCOMPANY_ContractID */

			select * into T_TheCompany_KWS_2_CNT_TCompany_ContractID
			from [dbo].[V_TheCompany_KWS_2_CNT_TCompany_ContractID] 

		drop table T_TheCompany_KWS_2_CNT_TCOMPANYCountry_ContractID /* T_TheCompany_KeyWordSearch_Results_TCOMPANY_ContractID */

			select * into T_TheCompany_KWS_2_CNT_TCOMPANYCountry_ContractID
			from [dbo].[V_TheCompany_KWS_2_CNT_TCOMPANYCountry_ContractID] 

		drop table T_TheCompany_KWS_2_CNT_InternalPartner_ContractID /* T_TheCompany_KeyWordSearch_Results_TCOMPANY_ContractID */

			select * into T_TheCompany_KWS_2_CNT_InternalPartner_ContractID
			from [dbo].[V_TheCompany_KWS_2_CNT_InternalPartner_ContractID] 

		/*	CREATE UNIQUE CLUSTERED INDEX T_TheCompany_KWS_2_CNT_InternalPartner_ContractID
			ON T_TheCompany_KWS_2_CNT_InternalPartner_ContractID (CONTRACTID) */
	
		/* 2 - TheVendor - Tag */
		drop table T_TheCompany_KWS_2_CNT_Tag_ContractID /* T_TheCompany_KeyWordSearch_Results_TCOMPANY_ContractID */

			select * into T_TheCompany_KWS_2_CNT_Tag_ContractID
			from [dbo].[V_TheCompany_KWS_2_CNT_Tag_ContractID] 

			CREATE UNIQUE CLUSTERED INDEX T_TheCompany_KWS_2_CNT_Tag_ContractID
			ON T_TheCompany_KWS_2_CNT_Tag_ContractID (CONTRACTID)
			

		drop table T_TheCompany_KWS_2_CNT_Territories_ContractID /* T_TheCompany_KeyWordSearch_Results_TCOMPANY_ContractID */

			select * into T_TheCompany_KWS_2_CNT_Territories_ContractID
			from [dbo].[V_TheCompany_KWS_2_CNT_Territories_ContractID] 

			CREATE UNIQUE CLUSTERED INDEX T_TheCompany_KWS_2_CNT_Territories_ContractID
			ON T_TheCompany_KWS_2_CNT_Territories_ContractID (CONTRACTID)		
				
	/* 2- Ariba */
		drop table T_TheCompany_KWS_2_ARB_TPRODUCT_ContractID

			select * into T_TheCompany_KWS_2_ARB_TPRODUCT_ContractID
			from V_TheCompany_KWS_2_ARB_TPRODUCT_ContractID

		/* added for Nick's 10k vendors (run time 2:20 for the 10k */
		drop table T_TheCompany_KWS_2_ARB_TCOMPANY_ContractID

			select * into T_TheCompany_KWS_2_ARB_TCOMPANY_ContractID
			from V_TheCompany_KWS_2_ARB_TCOMPANY_ContractID

		drop table T_TheCompany_KWS_2_ARB_Tag_ContractID

			select * into T_TheCompany_KWS_2_ARB_Tag_ContractID
			from V_TheCompany_KWS_2_ARB_Tag_ContractID

		drop table T_TheCompany_KWS_2_ARB_TCOMPANYCountry_ContractID

			select * into T_TheCompany_KWS_2_ARB_TCOMPANYCountry_ContractID
			from V_TheCompany_KWS_2_ARB_TCOMPANYCountry_ContractID	

		drop table T_TheCompany_KWS_2_ARB_InternalPartner_ContractID /* T_TheCompany_KeyWordSearch_Results_TCOMPANY_ContractID */

			select * into T_TheCompany_KWS_2_ARB_InternalPartner_ContractID
			from [dbo].[V_TheCompany_KWS_2_ARB_InternalPartner_ContractID] 
	/* 2 - LINC */
		drop table T_TheCompany_KWS_2_LNC_TCOMPANY_ContractID

			select * into T_TheCompany_KWS_2_LNC_TCOMPANY_ContractID
			from V_TheCompany_KWS_2_LNC_TCOMPANY_ContractID

		drop table T_TheCompany_KWS_2_LNC_InternalPartner_ContractID /* T_TheCompany_KeyWordSearch_Results_TCOMPANY_ContractID */

			select * into T_TheCompany_KWS_2_LNC_InternalPartner_ContractID
			from [dbo].[V_TheCompany_KWS_2_LNC_InternalPartner_ContractID] 
			/*	drop table T_TheCompany_KWS_2_LNC_TPRODUCT_ContractID

			select * into T_TheCompany_KWS_2_LNC_TPRODUCT_ContractID
			from dbo.[V_TheCompany_KWS_2_LNC_TPRODUCT_ContractID] */

	/* 2 - JPS */

		drop table T_TheCompany_KWS_2_JPS_TPRODUCT_ContractID

			select * into T_TheCompany_KWS_2_JPS_TPRODUCT_ContractID
			from V_TheCompany_KWS_2_JPS_TPRODUCT_ContractID

		drop table T_TheCompany_KWS_2_JPS_TCOMPANY_ContractID

			select * into T_TheCompany_KWS_2_JPS_TCOMPANY_ContractID
			from V_TheCompany_KWS_2_JPS_TCOMPANY_ContractID	

		drop table T_TheCompany_KWS_2_JPS_TCOMPANYCountry_ContractID

			select * into T_TheCompany_KWS_2_JPS_TCOMPANYCountry_ContractID
			from V_TheCompany_KWS_2_JPS_TCOMPANYCountry_ContractID	

		drop table T_TheCompany_KWS_2_JPS_InternalPartner_ContractID /* T_TheCompany_KeyWordSearch_Results_TCOMPANY_ContractID */

			select * into T_TheCompany_KWS_2_JPS_InternalPartner_ContractID
			from [dbo].[V_TheCompany_KWS_2_JPS_InternalPartner_ContractID] 

	/*		CREATE UNIQUE CLUSTERED INDEX T_TheCompany_KWS_2_CNT_InternalPartner_ContractID
			ON T_TheCompany_KWS_2_CNT_InternalPartner_ContractID (CONTRACTID) */
		drop table T_TheCompany_KWS_2_JPS_Territories_ContractID /* T_TheCompany_KeyWordSearch_Results_TCOMPANY_ContractID */

			select * into T_TheCompany_KWS_2_JPS_Territories_ContractID
			from [dbo].[V_TheCompany_KWS_2_JPS_Territories_ContractID] 

/**********************************/	
/* Level 3 */
/**********************************/	

	/* 3 - TheVendor */
		drop table T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended

			select * into T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended
			from dbo.[V_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended]

			CREATE CLUSTERED INDEX T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended
			ON T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended (CONTRACTID)

			/* 1 second run time even with 10K records ?*/
			drop table T_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended /* match level e.g. '1 - EXACT'  */

				select * into T_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended
				from dbo.[V_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended]

	/* 3 - Ariba */

		drop table T_TheCompany_KWS_3_ARB_TCompany_ContractID_Extended /* match level e.g. '1 - EXACT'  */

			select * into T_TheCompany_KWS_3_ARB_TCompany_ContractID_Extended
			from dbo.[V_TheCompany_KWS_3_ARB_TCompany_ContractID_Extended]

		drop table T_TheCompany_KWS_3_ARB_TProduct_ContractID_Extended

			select * into T_TheCompany_KWS_3_ARB_TProduct_ContractID_Extended
			from dbo.[V_TheCompany_KWS_3_ARB_TProduct_ContractID_Extended]

			CREATE CLUSTERED INDEX T_TheCompany_KWS_3_ARB_TProduct_ContractID_Extended
			ON T_TheCompany_KWS_3_ARB_TProduct_ContractID_Extended (CONTRACTID)

	/* 3 - JPS */
		drop table T_TheCompany_KWS_3_JPS_TProduct_ContractID_Extended

			select * into T_TheCompany_KWS_3_JPS_TProduct_ContractID_Extended
			from dbo.[V_TheCompany_KWS_3_JPS_TProduct_ContractID_Extended]

		drop table T_TheCompany_KWS_3_JPS_TCompany_ContractID_Extended

			select * into T_TheCompany_KWS_3_JPS_TCompany_ContractID_Extended
			from dbo.[V_TheCompany_KWS_3_JPS_TCompany_ContractID_Extended]			
	/* 3 - LNC */

		drop table T_TheCompany_KWS_3_LNC_TCompany_ContractID_Extended /* match level e.g. '1 - EXACT'  */

			select * into T_TheCompany_KWS_3_LNC_TCompany_ContractID_Extended
			from dbo.[V_TheCompany_KWS_3_LNC_TCompany_ContractID_Extended]

/**********************************/
/* LEVEL 4 - Prod / DESCRIPTION */
/**********************************/

	drop table T_TheCompany_KWS_4_CNT_TProduct_ContractID

		select * into T_TheCompany_KWS_4_CNT_TProduct_ContractID
		from V_TheCompany_KWS_4_CNT_TProduct_ContractID
	
	drop table T_TheCompany_KWS_4_ARB_TProduct_ContractID

		select * into T_TheCompany_KWS_4_ARB_TProduct_ContractID
		from V_TheCompany_KWS_4_ARB_TProduct_ContractID
/* DESCRIPTION, must be last since it excludes hits that 
	are already covered by product or company 
	Scope: Contract Title and Tags (SLOW) */

/* description , run time 2:45 min*/
	drop table T_TheCompany_KWS_5c_CNT_DESCRIPTION_ContractID 

		select * into T_TheCompany_KWS_5c_CNT_DESCRIPTION_ContractID
		from V_TheCompany_KWS_5c_CNT_DESCRIPTION_ContractID

	drop table T_TheCompany_KWS_5c_ARB_DESCRIPTION_ContractID
		/* currently excludes company for Nick's 10,000 entries */
		select * into T_TheCompany_KWS_5c_ARB_DESCRIPTION_ContractID
		from V_TheCompany_KWS_5c_ARB_DESCRIPTION_ContractID
		
		/* run time 39 seconds for Nick's 10K vendors */
	drop table T_TheCompany_KWS_5c_JPS_DESCRIPTION_ContractID

		select * into T_TheCompany_KWS_5c_JPS_DESCRIPTION_ContractID
		from V_TheCompany_KWS_5c_JPS_DESCRIPTION_ContractID

	drop table T_TheCompany_KWS_5c_LNC_DESCRIPTION_ContractID

		select * into T_TheCompany_KWS_5c_LNC_DESCRIPTION_ContractID
		from V_TheCompany_KWS_5c_LNC_DESCRIPTION_ContractID
	/*	CREATE UNIQUE CLUSTERED INDEX T_TheCompany_KWS_4_JPS_DESCRIPTION_ContractID
		ON  T_TheCompany_KWS_4_JPS_DESCRIPTION_ContractID (CONTRACTID) */

/**********************************/
	/* 6 - UNION */
/**********************************/
	
		drop table T_TheCompany_KWS_6_CNT_ContractID_UNION

			select * into T_TheCompany_KWS_6_CNT_ContractID_UNION
			from V_TheCompany_KWS_6_CNT_ContractID_UNION

			CREATE UNIQUE CLUSTERED INDEX T_TheCompany_KWS_6_CNT_ContractID
			ON  T_TheCompany_KWS_6_CNT_ContractID_UNION (CONTRACTID)

		/* Ariba */
		/* added for Nick's 10k vendors */
		drop table T_TheCompany_KWS_6_ARB_ContractID_UNION

			select * into T_TheCompany_KWS_6_ARB_ContractID_UNION
			from V_TheCompany_KWS_6_ARB_ContractID_UNION

			CREATE UNIQUE CLUSTERED INDEX T_TheCompany_KWS_6_ARB_ContractID
			ON  T_TheCompany_KWS_6_ARB_ContractID_UNION (CONTRACTID)

		drop table T_TheCompany_KWS_6_LNC_ContractID_UNION

			select * into T_TheCompany_KWS_6_LNC_ContractID_UNION
			from V_TheCompany_KWS_6_LNC_ContractID_UNION

			CREATE UNIQUE CLUSTERED INDEX T_TheCompany_KWS_6_LNC_ContractID_UNION
			ON  T_TheCompany_KWS_6_LNC_ContractID_UNION (CONTRACTID)


		drop table T_TheCompany_KWS_6_JPS_ContractID_UNION

			select * into T_TheCompany_KWS_6_JPS_ContractID_UNION
			from V_TheCompany_KWS_6_JPS_ContractID_UNION

			CREATE UNIQUE CLUSTERED INDEX T_TheCompany_KWS_6_JPS_ContractID_UNION
			ON  T_TheCompany_KWS_6_JPS_ContractID_UNION (CONTRACTID)

/**********************************/		
/* 7 - Summary */
/**********************************/

	/* CNT */		/* run time 1 second at 10K vendor rows */
		drop table T_TheCompany_KWS_7_CNT_ContractID_SummaryByContractID

			select * into T_TheCompany_KWS_7_CNT_ContractID_SummaryByContractID
			from V_TheCompany_KWS_7_CNT_ContractID_SummaryByContractID

	/* ARB */		/* run time 2 sec at 10K rows */
		drop table T_TheCompany_KWS_7_ARB_ContractID_SummaryByContractID

			select * into T_TheCompany_KWS_7_ARB_ContractID_SummaryByContractID
			from V_TheCompany_KWS_7_ARB_ContractID_SummaryByContractID

	/* LNC */
		drop table T_TheCompany_KWS_7_LNC_ContractID_SummaryByContractID

			select * into T_TheCompany_KWS_7_LNC_ContractID_SummaryByContractID
			from V_TheCompany_KWS_7_LNC_ContractID_SummaryByContractID
	
	/* JPS */		/* run time 9 seconds at 10K rows */
		drop table T_TheCompany_KWS_7_JPS_ContractID_SummaryByContractID

			select * into T_TheCompany_KWS_7_JPS_ContractID_SummaryByContractID
			from V_TheCompany_KWS_7_JPS_ContractID_SummaryByContractID	

/**********************************/
/* 9 - FINAL / COMBINED */
/**********************************/
/* EXEC [dbo].[TheCompany_1DAILY_03DataLoad_KWS] T_TheCompany_KWS_0_TheVendorView_CNT */
	drop table T_TheCompany_KWSR_1_CNT_ARB /* and JPS */
	
		select * into T_TheCompany_KWSR_1_CNT_ARB
		from [V_TheCompany_KWSR_1_CNT_ARB] 
		/* WHERE 
			[Status] = 'Active' */
		/*	and ([Company Names] <> 'Intercompany TheCompany (Two or more TheCompany Entities)'
				OR [Company Names] is NULL) */

		CREATE UNIQUE CLUSTERED INDEX T_TheCompany_KWSR_0_CNT_ARB_CONTRACTID
		ON T_TheCompany_KWSR_1_CNT_ARB (CONTRACTID)

END

/*
select * from V_TheCompany_KWSR_0_LNC where CONTRACTID is null


exec TheCompany_KeyWordSearch


select *
from V_TheCompany_KWSR_1_CNT_ARB where CONTRACTID is null
group by contractid
having COUNT(*)>1

*/

GO
/****** Object:  StoredProcedure [dbo].[TheCompany_KWS_FullText_AdhocNewProducts]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_KWS_FullText_AdhocNewProducts] 
	( @Keyword as VARCHAR(255))
AS
/* Notes:
Currently excluding lots of names with special chars to be sure
retest
*/

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

DECLARE @PRODUCTGROUP AS VARCHAR(255)
DECLARE @CONTRACTNUMBER AS VARCHAR(20)
DECLARE @DOCTITLE AS VARCHAR(255)
DECLARE @PRODUCTGROUPQUOTE AS VARCHAR(300)
DECLARE @PRODUCTGROUPID SMALLINT
DECLARE @OBJECTID bigint 
DECLARE @OBJECTTYPEID bigint 
DECLARE @DOCUMENTID bigint 
DECLARE @DOC_COUNT bigint 
DECLARE @SQLOBJECTIDS as VARCHAR (1000)
DECLARE @DATEREGISTERED as datetime

BEGIN


	DECLARE curProducts CURSOR LOCAL FAST_FORWARD FOR

	select PRODUCTGROUPID, PRODUCTGROUP 
	from V_TheCompany_VPRODUCTGROUP 
	WHERE upper(PRODUCTGROUP) = (upper(@Keyword))

	OPEN curProducts

	FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
	WHILE @@FETCH_STATUS = 0 BEGIN

		SET @PRODUCTGROUPQUOTE = '"' + @PRODUCTGROUP + '"' 
		PRINT @PRODUCTGROUPQUOTE
		PRINT 'Product Group: '  + @PRODUCTGROUP + ', ID: ' + convert(varchar(10),@PRODUCTGROUPID)

			BEGIN 

				DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR
				
				SELECT @PRODUCTGROUPID AS PRD
					, d.OBJECTID
					, d.OBJECTTYPEID
					, max(d.DOCUMENTID) as Doc_MaxID
					,COUNT(d.documentid) as Doc_Count
				FROM tdocument d  inner join TFILEINFO i on d.DOCUMENTID = i.documentid
					INNER JOIN TFILE f ON i.FileId = f.FileID
				WHERE f.FileId IN (SELECT KEY_TBL.[KEY] FROM CONTAINSTABLE(TFILE, [File], @PRODUCTGROUPQUOTE ) AS KEY_TBL 
									/* WHERE KEY_TBL.RANK > 10 would exclude 10% of hits */) 
					AND d.MIK_VALID = N'1' 
					AND f.filetype NOT LIKE '%.xl%' /* exclude registration form */ /* AND c.CONTRACTTYPEID  NOT IN  (103,104,101, 13, 5, 102, 6) */
					AND OBJECTID NOT IN (SELECT contractid from TPROD_GROUP_IN_CONTRACT 
											WHERE PRODUCTGROUPID = @PRODUCTGROUPID)
					AND d.objecttypeid = 1 /* contract */ /* AMENDMENT OBJECTTYPE 4 NOT WORKING RIGHT DO  NOT USE */
				GROUP BY d.OBJECTID, d.OBJECTTYPEID /*, d.DOCUMENTID */
				

				OPEN curContracts

				FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, /* @PRODUCTGROUP, */ @OBJECTID , @OBJECTTYPEID, @DOCUMENTID, @DOC_COUNT /*, @CONTRACTNUMBER, @DATEREGISTERED */
				WHILE @@FETCH_STATUS = 0 
				BEGIN
					
						/*   TheCompany_ProductGroupUpload_ObjectidProductgroupID
									  @OBJECTID bigint 
					,@PRODUCTGROUPID bigint
					, @OBJECTTYPEID bigint
					, @PRODUCTGROUP  AS VARCHAR(255)
					, @DESCRIPTION AS VARCHAR(255)
					, @CONTRACTNUMBER AS VARCHAR(20)
					, @DATEREGISTERED as datetime
					*/
					EXEC TheCompany_ProductGroupUpload_ObjectidProductgroupID @OBJECTID, @PRODUCTGROUPID, @OBJECTTYPEID, @PRODUCTGROUP, '' /*@DESCRIPTION */, @CONTRACTNUMBER, @DATEREGISTERED
					
					INSERT INTO T_TheCompany_Product_Upload ( 
						PRODUCTGROUPID       
					   , OBJECTID 
					   , OBJECTTYPEID
					   , Doc_MaxID /* DOCUMENTID */
					   , Doc_Count
					   , Uploaded_DateTime)
					VALUES (@PRODUCTGROUPID 
					, @OBJECTID
					, @OBJECTTYPEID
					, @DOCUMENTID
					, @DOC_COUNT
					, GetDate() )
		
				FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @OBJECTID , @OBJECTTYPEID, @DOCUMENTID, @DOC_COUNT

				END /* curContracts */
				CLOSE curContracts
				DEALLOCATE curContracts

			END /* IF EXISTS */

	FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
				
	END /* curProducts */

/* delete from T_TheCompany_Product_Upload */
	CLOSE curProducts
	DEALLOCATE curProducts

	SET @RESULTSTRING = 'Success' 

GOTO lblEnd 

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'


lblEnd: 
PRINT '*** END'



END 
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_KWS_PrdGrpUpload_CNT_Desc_TableAddNewItems]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[TheCompany_KWS_PrdGrpUpload_CNT_Desc_TableAddNewItems]

AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

DECLARE @PRODUCTGROUP AS VARCHAR(255)
DECLARE @CONTRACTNUMBER AS VARCHAR(20)
DECLARE @DESCRIPTION AS VARCHAR(255)
DECLARE @PRODUCTGROUP_LEFTBLANK AS VARCHAR(300)
DECLARE @PRODUCTGROUP_MID AS VARCHAR(300)
DECLARE @PRODUCTGROUP_RIGHTBLANK AS VARCHAR(300)
DECLARE @PRODUCTGROUPID SMALLINT
DECLARE @OBJECTID bigint 
DECLARE @SQLOBJECTIDS as VARCHAR (1000)
DECLARE @DATEREGISTERED as datetime
DECLARE @DEBUG_OUTPUT as bit

BEGIN
/* WHEN NEW PRODUCTS ARE ADDED, or old ones modified, run the procedure WITHOUT the date filter  to make sure the product is tagged in older records too */
	SET @DEBUG_OUTPUT = 1 /* 0 = no debug info, 1 = debug */

	DECLARE curProducts CURSOR LOCAL FAST_FORWARD FOR

	SELECT /* top 100 */ PRODUCTGROUPID, PRODUCTGROUP 
	FROM V_TheCompany_VPRODUCTGROUP 
	WHERE productgroup in (select PRODUCTGROUPNAME from T_TheCompany_TPRODUCTGROUP_AddNewItems)

	OPEN curProducts	

	IF (@DEBUG_OUTPUT = 1) PRINT '1 - Open CurProducts ***';

	FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
	WHILE @@FETCH_STATUS = 0 BEGIN
					IF (@DEBUG_OUTPUT = 1)  PRINT '*********************************************'
					IF (@DEBUG_OUTPUT = 1)  PRINT 'PRODUCTGROUP: ' + @PRODUCTGROUP;
			SET @PRODUCTGROUP_RIGHTBLANK = @PRODUCTGROUP + '[^a-z]%' 	

			SET @PRODUCTGROUP_MID = '%[^a-z]' + @PRODUCTGROUP + '[^a-z]%'

			SET @PRODUCTGROUP_LEFTBLANK = '%[^a-z]' + @PRODUCTGROUP

				/* PRINT 'Product Group: '  + @PRODUCTGROUP 
				PRINT @PRODUCTGROUPID */
	
			IF EXISTS (
				SELECT 1
				FROM tcontract c 
				WHERE 
				(c.CONTRACT like @PRODUCTGROUP_LEFTBLANK 
					OR c.CONTRACT like @PRODUCTGROUP_MID
					OR c.CONTRACT like @PRODUCTGROUP_RIGHTBLANK
					OR c.CONTRACTID in (select objectid from TDOCUMENT d
						where OBJECTTYPEID = 1 /* contract */
						and 
							(d.document like @PRODUCTGROUP_LEFTBLANK 
							OR d.document like @PRODUCTGROUP_MID
							OR d.document like @PRODUCTGROUP_RIGHTBLANK
							)
					))
				/* filter to include NEW contracts only BUT if new products are added then this needs to be taken out */
				AND (c.CONTRACTID in (select objectid from V_TheCompany_Audittrail_ModLast30DaysMin1DayOld where OBJECTTYPEID = 1) 
					OR c.CONTRACTID in (select objectid from tdocument 
							where documentid in (select objectid 
								from V_TheCompany_Audittrail_ModLast30DaysMin1DayOld where OBJECTTYPEID = 7 /* document */ ) 
										)
					OR @PRODUCTGROUPID > 6492 /* new record added after Apr-2020 */
						)
				AND c.CONTRACTDATE < dateadd(dd,-1,GETDATE()) /* at least one day old so that no crashes if record being put in */ 
				AND CONTRACTID NOT IN (SELECT contractid 
						from TPROD_GROUP_IN_CONTRACT 
						WHERE PRODUCTGROUPID = @PRODUCTGROUPID)
				AND CONTRACTTYPEID not in (/* '11' /*Case*/ */
											'6' /* Access */ /* 
											, '5' Test Old */ /* ,'102'Test New */
											,'13' /* DELETE */ 
											,'103' /*file*/
											,'104' /*corp file*/)
					AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!AUTODELETE')
					AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!ARIBA%')
				)
			
				BEGIN /* at least one record for product */
	
					PRINT ' exists at least 1 record'
					/* sub loop contract upload */
				
					DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR

					SELECT @PRODUCTGROUPID AS PRD 
						, @PRODUCTGROUP AS PRDGRP 
						, CONTRACTID
						, c.contractnumber
						, c.contractdate
						, c.CONTRACT
					FROM tcontract c 
					WHERE 
						(c.CONTRACT like @PRODUCTGROUP_LEFTBLANK 
							OR c.CONTRACT like @PRODUCTGROUP_MID
							OR c.CONTRACT like @PRODUCTGROUP_RIGHTBLANK
							OR c.CONTRACTID in (select objectid from TDOCUMENT d
								where OBJECTTYPEID = 1 /* contract */
								and 
									(d.document like @PRODUCTGROUP_LEFTBLANK 
									OR d.document like @PRODUCTGROUP_MID
									OR d.document like @PRODUCTGROUP_RIGHTBLANK
									)
							))
				/* filter to include NEW contracts only BUT if new products are added then this needs to be taken out */
				AND (c.CONTRACTID in (select objectid from V_TheCompany_Audittrail_ModLast30DaysMin1DayOld where OBJECTTYPEID = 1) 
					OR c.CONTRACTID in (select objectid from tdocument 
							where documentid in (select objectid 
								from V_TheCompany_Audittrail_ModLast30DaysMin1DayOld where OBJECTTYPEID = 7 /* document */ ) 
										)
					OR @PRODUCTGROUPID > 6492 /* new record added after Apr-2020 */
						)
					AND c.CONTRACTDATE < dateadd(dd,-1,GETDATE()) /* at least one day old so that no crashes if record being put in */ 
						AND CONTRACTID NOT IN (SELECT contractid 
								from TPROD_GROUP_IN_CONTRACT 
								WHERE PRODUCTGROUPID = @PRODUCTGROUPID)
						AND CONTRACTTYPEID not in (/* '11' /*Case*/ */
													'6' /* Access */ /* 
													, '5' Test Old */ /* ,'102'Test New */
													,'13' /* DELETE */ 
													,'103' /*file*/
													,'104' /*corp file*/)
						AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!AUTODELETE')
						AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!ARIBA%')
					GROUP BY CONTRACTID, c.contractnumber, c.contractdate, c.contract

					/* contracts cursor */
						OPEN curContracts
					
						/* Initial Fetch */
						FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @OBJECTID, @CONTRACTNUMBER, @DATEREGISTERED, @DESCRIPTION

						/* Fetch loop while there are records */
							WHILE @@FETCH_STATUS = 0 BEGIN

								PRINT 'PRODUCTGROUP: ' + @PRODUCTGROUP + ' - (TheCompany_2WEEKLY_ProductGroupUpload_Description)'
								PRINT @CONTRACTNUMBER
								PRINT @DESCRIPTION

									EXEC TheCompany_ProductGroupUpload_ObjectidProductgroupID 
									@OBJECTID
									, @PRODUCTGROUPID
									, 1 /* OBJECTTYPEID */
									, @PRODUCTGROUP
									, @DESCRIPTION
									, @CONTRACTNUMBER
									, @DATEREGISTERED

									FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @OBJECTID, @CONTRACTNUMBER, @DATEREGISTERED, @DESCRIPTION
							
							END  /* at least one record for product */
						/* end fetch loop */

						CLOSE curContracts
						DEALLOCATE curContracts		
			END

			ELSE 

				IF @DEBUG_OUTPUT = 1 
				PRINT '  No (new) records for : '  + @PRODUCTGROUP +' (TheCompany_2WEEKLY_ProductGroupUpload_Description)';

			FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
	END

		CLOSE curProducts
		DEALLOCATE curProducts
		SET @RESULTSTRING = '  Successfully completed, END CurProducts (TheCompany_2WEEKLY_ProductGroupUpload_Description)'

		GOTO lblEnd

	lblTerminate: 
		PRINT 'lblTerminate: !!! Statement did not execute due to invalid input values! (TheCompany_2WEEKLY_ProductGroupUpload_Description)'

	lblEnd: 
		
		/* Archive upload table records older than 14 days */
		EXEC [dbo].[TheCompany_ProductGroupUpload_ArchiveLogTable]

		PRINT @RESULTSTRING

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_KWS_PrdGrpUpload_CNT_FullText_TableAddNewItems]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[TheCompany_KWS_PrdGrpUpload_CNT_FullText_TableAddNewItems]
AS
/* Notes:
Currently excluding lots of names with special chars to be sure
retest
*/

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

DECLARE @PRODUCTGROUP AS VARCHAR(255)
DECLARE @CONTRACTNUMBER AS VARCHAR(20)
DECLARE @DOCTITLE AS VARCHAR(255)
DECLARE @PRODUCTGROUPQUOTE AS VARCHAR(300)
DECLARE @PRODUCTGROUPID SMALLINT
DECLARE @OBJECTID bigint 
DECLARE @OBJECTTYPEID bigint 
DECLARE @DOCUMENTID bigint 
DECLARE @DOC_COUNT bigint 
DECLARE @SQLOBJECTIDS as VARCHAR (1000)
DECLARE @DATEREGISTERED as datetime

BEGIN


	DECLARE curProducts CURSOR LOCAL FAST_FORWARD FOR

	select PRODUCTGROUPID, PRODUCTGROUP 
	from V_TheCompany_VPRODUCTGROUP 
	WHERE 
	productgroup in (select PRODUCTGROUPNAME from T_TheCompany_TPRODUCTGROUP_AddNewItems)

	OPEN curProducts

	FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
	WHILE @@FETCH_STATUS = 0 BEGIN

		SET @PRODUCTGROUPQUOTE = '"' + @PRODUCTGROUP + '"' 
		PRINT @PRODUCTGROUPQUOTE
		PRINT 'Product Group: '  + @PRODUCTGROUP + ', ID: ' + convert(varchar(10),@PRODUCTGROUPID)

			BEGIN 

				DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR
				
				SELECT @PRODUCTGROUPID AS PRD
					, d.OBJECTID
					, d.OBJECTTYPEID
					, max(d.DOCUMENTID) as Doc_MaxID
					,COUNT(d.documentid) as Doc_Count
				FROM tdocument d  inner join TFILEINFO i on d.DOCUMENTID = i.documentid
					INNER JOIN TFILE f ON i.FileId = f.FileID
				WHERE f.FileId IN (SELECT KEY_TBL.[KEY] FROM CONTAINSTABLE(TFILE, [File], @PRODUCTGROUPQUOTE ) AS KEY_TBL 
									/* WHERE KEY_TBL.RANK > 10 would exclude 10% of hits */) 
					AND d.MIK_VALID = N'1' 
					AND f.filetype NOT LIKE '%.xl%' /* exclude registration form */ /* AND c.CONTRACTTYPEID  NOT IN  (103,104,101, 13, 5, 102, 6) */
					AND OBJECTID NOT IN (SELECT contractid from TPROD_GROUP_IN_CONTRACT 
											WHERE PRODUCTGROUPID = @PRODUCTGROUPID)
					AND d.objecttypeid = 1 /* contract */ /* AMENDMENT OBJECTTYPE 4 NOT WORKING RIGHT DO  NOT USE */
				GROUP BY d.OBJECTID, d.OBJECTTYPEID /*, d.DOCUMENTID */
				

				OPEN curContracts

				FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, /* @PRODUCTGROUP, */ @OBJECTID , @OBJECTTYPEID, @DOCUMENTID, @DOC_COUNT /*, @CONTRACTNUMBER, @DATEREGISTERED */
				WHILE @@FETCH_STATUS = 0 
				BEGIN
					
						/*   TheCompany_ProductGroupUpload_ObjectidProductgroupID
									  @OBJECTID bigint 
					,@PRODUCTGROUPID bigint
					, @OBJECTTYPEID bigint
					, @PRODUCTGROUP  AS VARCHAR(255)
					, @DESCRIPTION AS VARCHAR(255)
					, @CONTRACTNUMBER AS VARCHAR(20)
					, @DATEREGISTERED as datetime
					*/
					EXEC TheCompany_ProductGroupUpload_ObjectidProductgroupID @OBJECTID, @PRODUCTGROUPID, @OBJECTTYPEID, @PRODUCTGROUP, '' /*@DESCRIPTION */, @CONTRACTNUMBER, @DATEREGISTERED
					
					INSERT INTO T_TheCompany_Product_Upload ( 
						PRODUCTGROUPID       
					   , OBJECTID 
					   , OBJECTTYPEID
					   , Doc_MaxID /* DOCUMENTID */
					   , Doc_Count
					   , Uploaded_DateTime)
					VALUES (@PRODUCTGROUPID 
					, @OBJECTID
					, @OBJECTTYPEID
					, @DOCUMENTID
					, @DOC_COUNT
					, GetDate() )
		
				FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @OBJECTID , @OBJECTTYPEID, @DOCUMENTID, @DOC_COUNT

				END /* curContracts */
				CLOSE curContracts
				DEALLOCATE curContracts

			END /* IF EXISTS */

	FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
				
	END /* curProducts */

/* delete from T_TheCompany_Product_Upload */
	CLOSE curProducts
	DEALLOCATE curProducts

	SET @RESULTSTRING = 'Success' 

GOTO lblEnd 

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'


lblEnd: 
PRINT '*** END'



END 
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_KWS_PrdGrpUpload_Execute_TableAddNewItemsAndDescFullTxt]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_KWS_PrdGrpUpload_Execute_TableAddNewItemsAndDescFullTxt]

AS

BEGIN

	EXEC [dbo].[TheCompany_KWS_PrdGrpUpload_TableAddNewItems]
	EXEC [dbo].[TheCompany_KWS_PrdGrpUpload_CNT_FullText_TableAddNewItems]
	EXEC [dbo].[TheCompany_KWS_PrdGrpUpload_CNT_Desc_TableAddNewItems]
	EXEC TheCompany_KWS_UpdateProductAI
	/* Ariba, JPS? */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_KWS_PrdGrpUpload_TableAddNewItems]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_KWS_PrdGrpUpload_TableAddNewItems]

AS

BEGIN

	insert into TPRODUCTGROUP (PRODUCTGROUP, PRODUCTGROUPNOMENCLATUREID)
	select PRODUCTGROUPNAME, PRODUCTGROUPNOMENCLATUREID from 
	[dbo].[T_TheCompany_TPRODUCTGROUP_AddNewItems] n
	where upper(n.PRODUCTGROUPNAME) not in (select upper(PRODUCTGROUP) from TPRODUCTGROUP)
	and n.PRODUCTGROUPNOMENCLATUREID in (2,3)

	truncate table T_TheCompany_TPRODUCTGROUP_AddNewItems /* addition complete */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_KWS_PrdGrpUpload_zDesc_Adhoc_SingleName]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[TheCompany_KWS_PrdGrpUpload_zDesc_Adhoc_SingleName] ( @Keyword as VARCHAR(255))
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

DECLARE @PRODUCTGROUP AS VARCHAR(255)
DECLARE @CONTRACTNUMBER AS VARCHAR(20)
DECLARE @DESCRIPTION AS VARCHAR(255)
DECLARE @PRODUCTGROUP_LEFTBLANK AS VARCHAR(300)
DECLARE @PRODUCTGROUP_MID AS VARCHAR(300)
DECLARE @PRODUCTGROUP_RIGHTBLANK AS VARCHAR(300)
DECLARE @PRODUCTGROUPID SMALLINT
DECLARE @OBJECTID bigint 
DECLARE @SQLOBJECTIDS as VARCHAR (1000)
DECLARE @DATEREGISTERED as datetime
DECLARE @DEBUG_OUTPUT as bit

BEGIN
/* WHEN NEW PRODUCTS ARE ADDED, or old ones modified, run the procedure WITHOUT the date filter  to make sure the product is tagged in older records too */
	SET @DEBUG_OUTPUT = 1 /* 0 = no debug info, 1 = debug */

	DECLARE curProducts CURSOR LOCAL FAST_FORWARD FOR

	SELECT /* top 100 */ PRODUCTGROUPID, PRODUCTGROUP 
	FROM V_TheCompany_VPRODUCTGROUP 
	WHERE productgroup = @Keyword

	OPEN curProducts	

	IF (@DEBUG_OUTPUT = 1) PRINT '1 - Open CurProducts ***';

	FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
	WHILE @@FETCH_STATUS = 0 BEGIN
					IF (@DEBUG_OUTPUT = 1)  PRINT '*********************************************'
					IF (@DEBUG_OUTPUT = 1)  PRINT 'PRODUCTGROUP: ' + @PRODUCTGROUP;
			SET @PRODUCTGROUP_RIGHTBLANK = @PRODUCTGROUP + '[^a-z]%' 	

			SET @PRODUCTGROUP_MID = '%[^a-z]' + @PRODUCTGROUP + '[^a-z]%'

			SET @PRODUCTGROUP_LEFTBLANK = '%[^a-z]' + @PRODUCTGROUP

				/* PRINT 'Product Group: '  + @PRODUCTGROUP 
				PRINT @PRODUCTGROUPID */
	
			IF EXISTS (
				SELECT 1
				FROM tcontract c 
				WHERE 
				(c.CONTRACT like @PRODUCTGROUP_LEFTBLANK 
					OR c.CONTRACT like @PRODUCTGROUP_MID
					OR c.CONTRACT like @PRODUCTGROUP_RIGHTBLANK
					OR c.CONTRACTID in (select objectid from TDOCUMENT d
						where OBJECTTYPEID = 1 /* contract */
						and 
							(d.document like @PRODUCTGROUP_LEFTBLANK 
							OR d.document like @PRODUCTGROUP_MID
							OR d.document like @PRODUCTGROUP_RIGHTBLANK
							)
					))
				/* filter to include NEW contracts only BUT if new products are added then this needs to be taken out */
				AND (c.CONTRACTID in (select objectid from V_TheCompany_Audittrail_ModLast30DaysMin1DayOld where OBJECTTYPEID = 1) 
					OR c.CONTRACTID in (select objectid from tdocument 
							where documentid in (select objectid 
								from V_TheCompany_Audittrail_ModLast30DaysMin1DayOld where OBJECTTYPEID = 7 /* document */ ) 
										)
					OR @PRODUCTGROUPID > 6492 /* new record added after Apr-2020 */
						)
				AND c.CONTRACTDATE < dateadd(dd,-1,GETDATE()) /* at least one day old so that no crashes if record being put in */ 
				AND CONTRACTID NOT IN (SELECT contractid 
						from TPROD_GROUP_IN_CONTRACT 
						WHERE PRODUCTGROUPID = @PRODUCTGROUPID)
				AND CONTRACTTYPEID not in (/* '11' /*Case*/ */
											'6' /* Access */ /* 
											, '5' Test Old */ /* ,'102'Test New */
											,'13' /* DELETE */ 
											,'103' /*file*/
											,'104' /*corp file*/)
					AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!AUTODELETE')
					AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!ARIBA%')
				)
			
				BEGIN /* at least one record for product */
	
					PRINT ' exists at least 1 record'
					/* sub loop contract upload */
				
					DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR

					SELECT @PRODUCTGROUPID AS PRD 
						, @PRODUCTGROUP AS PRDGRP 
						, CONTRACTID
						, c.contractnumber
						, c.contractdate
						, c.CONTRACT
					FROM tcontract c 
					WHERE 
						(c.CONTRACT like @PRODUCTGROUP_LEFTBLANK 
							OR c.CONTRACT like @PRODUCTGROUP_MID
							OR c.CONTRACT like @PRODUCTGROUP_RIGHTBLANK
							OR c.CONTRACTID in (select objectid from TDOCUMENT d
								where OBJECTTYPEID = 1 /* contract */
								and 
									(d.document like @PRODUCTGROUP_LEFTBLANK 
									OR d.document like @PRODUCTGROUP_MID
									OR d.document like @PRODUCTGROUP_RIGHTBLANK
									)
							))
				/* filter to include NEW contracts only BUT if new products are added then this needs to be taken out */
				AND (c.CONTRACTID in (select objectid from V_TheCompany_Audittrail_ModLast30DaysMin1DayOld where OBJECTTYPEID = 1) 
					OR c.CONTRACTID in (select objectid from tdocument 
							where documentid in (select objectid 
								from V_TheCompany_Audittrail_ModLast30DaysMin1DayOld where OBJECTTYPEID = 7 /* document */ ) 
										)
					OR @PRODUCTGROUPID > 6492 /* new record added after Apr-2020 */
						)
					AND c.CONTRACTDATE < dateadd(dd,-1,GETDATE()) /* at least one day old so that no crashes if record being put in */ 
						AND CONTRACTID NOT IN (SELECT contractid 
								from TPROD_GROUP_IN_CONTRACT 
								WHERE PRODUCTGROUPID = @PRODUCTGROUPID)
						AND CONTRACTTYPEID not in (/* '11' /*Case*/ */
													'6' /* Access */ /* 
													, '5' Test Old */ /* ,'102'Test New */
													,'13' /* DELETE */ 
													,'103' /*file*/
													,'104' /*corp file*/)
						AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!AUTODELETE')
						AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!ARIBA%')
					GROUP BY CONTRACTID, c.contractnumber, c.contractdate, c.contract

					/* contracts cursor */
						OPEN curContracts
					
						/* Initial Fetch */
						FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @OBJECTID, @CONTRACTNUMBER, @DATEREGISTERED, @DESCRIPTION

						/* Fetch loop while there are records */
							WHILE @@FETCH_STATUS = 0 BEGIN

								PRINT 'PRODUCTGROUP: ' + @PRODUCTGROUP + ' - (TheCompany_2WEEKLY_ProductGroupUpload_Description)'
								PRINT @CONTRACTNUMBER
								PRINT @DESCRIPTION

									EXEC TheCompany_ProductGroupUpload_ObjectidProductgroupID 
									@OBJECTID
									, @PRODUCTGROUPID
									, 1 /* OBJECTTYPEID */
									, @PRODUCTGROUP
									, @DESCRIPTION
									, @CONTRACTNUMBER
									, @DATEREGISTERED

									FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @OBJECTID, @CONTRACTNUMBER, @DATEREGISTERED, @DESCRIPTION
							
							END  /* at least one record for product */
						/* end fetch loop */

						CLOSE curContracts
						DEALLOCATE curContracts		
			END

			ELSE 

				IF @DEBUG_OUTPUT = 1 
				PRINT '  No (new) records for : '  + @PRODUCTGROUP +' (TheCompany_2WEEKLY_ProductGroupUpload_Description)';

			FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
	END

		CLOSE curProducts
		DEALLOCATE curProducts
		SET @RESULTSTRING = '  Successfully completed, END CurProducts (TheCompany_2WEEKLY_ProductGroupUpload_Description)'

		GOTO lblEnd

	lblTerminate: 
		PRINT 'lblTerminate: !!! Statement did not execute due to invalid input values! (TheCompany_2WEEKLY_ProductGroupUpload_Description)'

	lblEnd: 
		
		/* Archive upload table records older than 14 days */
		EXEC [dbo].[TheCompany_ProductGroupUpload_ArchiveLogTable]

		PRINT @RESULTSTRING

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_KWS_UpdateProductAI]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_KWS_UpdateProductAI]

AS 

BEGIN

/* Ariba: [dbo].[TheCompany_Ariba_ProductUploadFullText] */

/* add missing AI to product table */

update T_TheCompany_TPRODUCT_ACTIVEINGREDIENT
set zActiveIngredient = rtrim(ltrim(zActiveIngredient))
where zActiveIngredient like ' %' or zActiveIngredient like '% '

update T_TheCompany_TPRODUCT_ACTIVEINGREDIENT
set zTradeName = rtrim(ltrim(zTradeName))
where zTradeName like ' %' or zTradeName like '% '

INSERT INTO [dbo].[TPRODUCTGROUP]
           ([PRODUCTGROUP]
           ,[PARENTID]
           ,[PRODUCTGROUPNOMENCLATUREID] 
           ,[MIK_VALID]
           ,[PRODUCTGROUPCODE]   )   
	select distinct 
		zActiveIngredient
		, null /* PARENTID */
			, 2 /* AI */
			, 1 /* valid */
			,zActiveIngredient /* PRODUCTGROUPCODE */

			from T_TheCompany_TPRODUCT_ACTIVEINGREDIENT
	where upper(zActiveIngredient) not in (select upper(productgroup) from TPRODUCTGROUP)

INSERT INTO [dbo].[TPRODUCTGROUP]
           ([PRODUCTGROUP]
           ,[PARENTID]
           ,[PRODUCTGROUPNOMENCLATUREID] 
           ,[MIK_VALID]
           ,[PRODUCTGROUPCODE]   )   
	select distinct 
		zTradeName
		, null /* PARENTID */
			, 3 /* TN */
			, 1 /* valid */
			,zTradeName /* PRODUCTGROUPCODE */

			from T_TheCompany_TPRODUCT_ACTIVEINGREDIENT
	where upper(zTradeName) not in (select upper(productgroup) from TPRODUCTGROUP)


	update pai /* TN */
	set PRODUCTGROUPID_TN = P.productgroupid
	, PRODUCTGROUPNOMENCLATUREID_TN = 3
	from T_TheCompany_TPRODUCT_ACTIVEINGREDIENT pai 
		inner join TPRODUCTGROUP p on pai.zTradeName = p.PRODUCTGROUP
	where PRODUCTGROUPID_TN is null and p.PRODUCTGROUPNOMENCLATUREID = 3 /* TN */

	update pai
	set PRODUCTGROUPID_AI = P.productgroupid
	, PRODUCTGROUPNOMENCLATUREID_AI = 2
	from T_TheCompany_TPRODUCT_ACTIVEINGREDIENT pai 
		inner join TPRODUCTGROUP p on pai.zActiveIngredient = p.PRODUCTGROUP
	where PRODUCTGROUPID_AI is null and p.PRODUCTGROUPNOMENCLATUREID = 2


END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Maintenance_AgreementType_MSAtoSA]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[TheCompany_Maintenance_AgreementType_MSAtoSA](
                @CONTRACTNUMBER varchar(255)

)
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

IF NOT EXISTS ( SELECT  1
                FROM    dbo.tcontract
                WHERE   contractnumber = @CONTRACTNUMBER)
	BEGIN
		SET @RESULTSTRING = 'Contract Number does not exist: ' + (CASE WHEN @CONTRACTNUMBER IS NULL THEN 'NULL' ELSE @CONTRACTNUMBER END)
		GOTO lblTerminate 
	END

/* Agreement Type is already SA */
IF EXISTS ( SELECT  1
                FROM    dbo.tcontract
                WHERE   contractnumber = @CONTRACTNUMBER 
                AND AGREEMENT_TYPEID = 17 /* SA */)
	BEGIN
		SET @RESULTSTRING = 'Contract Number already has Agreement Type SA: ' + @CONTRACTNUMBER
		GOTO lblNoChange
	END

BEGIN

UPDATE TCONTRACT
SET AGREEMENT_TYPEID = 17 /* SA */
WHERE AGREEMENT_TYPEID = 1 /* MSA */
AND CONTRACTNUMBER = @CONTRACTNUMBER

GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'
GOTO lblBlankLine

lblNoChange:
PRINT '--- Statement did not result in any changes'
GOTO lblBlankLine

lblEnd: 
PRINT '*** Record added or altered Successfully'

lblBlankLine:
PRINT '     ' + @RESULTSTRING
PRINT CHAR(13) /* carriage return */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Maintenance_AgreementTypes_CorrectAgreementTypeByKeywords]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_Maintenance_AgreementTypes_CorrectAgreementTypeByKeywords]

AS

BEGIN

/* #369 - Three new TheCompany Pharma Vertrieb Categories */
insert into T_TheCompany_AgreementType
select 0, agreement_typeid
, agreement_type
, 1 /* is divestment default to 1 */
, null /* linc subtype */
, null /* linc main type */
from TAGREEMENT_TYPE
where [agreement_typeid] not in (select Agr_Typeid from T_TheCompany_AgreementType)

delete from T_TheCompany_AgreementType 
where Agr_Typeid not in (select agreement_typeid from TAGREEMENT_TYPE)

update ta 
set ta.AgrName = a.AGREEMENT_TYPE
from T_TheCompany_AgreementType  ta inner join tagreement_type a on ta.agr_typeid = a.agreement_typeid
where ta.AgrName is null or ta.AgrName <>a.AGREEMENT_TYPE
 

/* SPONSORING */
update tcontract
set agreement_typeid = (select agreement_typeid from tagreement_type 
						where SUBSTRING([FIXED],1,4) = '!SS!')
where (contract like '%sponsoring%' or contract like '%sponsorship%')
and agreement_typeid <> (select agreement_typeid from tagreement_type 
where SUBSTRING([FIXED],1,4) = '!SS!')

/* SPEAKING ENGAGEMENT */
update tcontract
set agreement_typeid = (select agreement_typeid from tagreement_type 
						where SUBSTRING([FIXED],1,4) = '!SP!')
where contract like '%referentenvertrag%'
and agreement_typeid <> (select agreement_typeid from tagreement_type 
where SUBSTRING([FIXED],1,4) = '!SP!')

/* CONSENT */
update tcontract
set agreement_typeid = (select agreement_typeid from tagreement_type 
						where SUBSTRING([FIXED],1,4) = '!CT!')
where contract like '%einverst%ndniserkl%rung%'
and agreement_typeid <> (select agreement_typeid from tagreement_type 
where SUBSTRING([FIXED],1,4) = '!CT!')

/* Liefervereinbarung */
update tcontract
set agreement_typeid = (select agreement_typeid from tagreement_type 
where SUBSTRING([FIXED],1,4) = '!SL!')
where contract like '%Liefervereinbarung%'
and agreement_typeid <> (select agreement_typeid from tagreement_type 
where SUBSTRING([FIXED],1,4) = '!SL!')

/* stand fee */
update tcontract
set agreement_typeid = (select agreement_typeid from tagreement_type 
						where SUBSTRING([FIXED],1,4) = '!BA!')
where contract like '%stand fee%'
and agreement_typeid <> (select agreement_typeid from tagreement_type 
						where SUBSTRING([FIXED],1,4) = '!BA!')

/* Rahmenagenturvertrag */
update tcontract
set agreement_typeid = (select agreement_typeid from tagreement_type 
						where SUBSTRING([FIXED],1,4) = '!AGC' /* Agency agreement */)
	/* and contract relation to master */
where contract like '%agenturvertrag%'
and agreement_typeid <> (select agreement_typeid from tagreement_type 
						where SUBSTRING([FIXED],1,4) = '!AGC' /* Agency agreement */)


END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Maintenance_ContractStatus_CheckAndCorrection]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_Maintenance_ContractStatus_CheckAndCorrection]

AS 

BEGIN

/* Please note weekly job [dbo].[TheCompany_3STNIGHT_CorrectContractStatus] */

/* Status Active */

	update tcontract
	set statusid = 5 /* active */
	/* select * from tcontract */
	where 
	statusid not in (4 /* awarded */, 5 /* active */) /* awarded or active */
	and CONTRACTTYPEID not in ( 13 /* DELETE */, 106 /* AutoDelete */)
	AND (
		(CASE WHEN REV_EXPIRYDATE is not null then REV_EXPIRYDATE else EXPIRYDATE end) is null
		or (CASE WHEN REV_EXPIRYDATE is not null then REV_EXPIRYDATE else EXPIRYDATE end) > GETDATE() /* no revised expiry further into the future */
		)

/* Set to expired if expiry date has passed */

	update tcontract
	set statusid = 6 /* expired */
	/* select * from tcontract */
	where 
	statusid in (/*4 /* awarded */,*/ 5 /* active */) /* awarded or active */
	and (CASE WHEN REV_EXPIRYDATE is not null then REV_EXPIRYDATE else EXPIRYDATE end) is not null
	and (CASE WHEN REV_EXPIRYDATE is not null then REV_EXPIRYDATE else EXPIRYDATE end) < GETDATE() /* no revised expiry further into the future */

/* Check / correct Expired status, no end date */



/* defined end date flag */

	SELECT *
	FROM TCONTRACT 
	WHERE EXPIRYDATE is not null
	AND DEFINEDENDDATE = 0

	update tcontract 
	set DEFINEDENDDATE = 1
	where expirydate is not null
	and definedenddate = 0 

/* AWARDED */
/* [dbo].[TheCompany_1HOURLY_SetToAwarded_DeleteAwardedDate] */

/*	select * from TCONTRACT where statusid = 4 /* Awarded */
	and CONTRACTID in (select CONTRACTID from TTENDERER)
	and CONTRACTTYPEID = 12 /* contract */

	select * from TTENDERER where CONTRACTID = 103617 /*Contract-00002264*/
	isawarded = 1 but partnersshare is null not 0.00 

	select * from TTENDERER where ISAWARDED = 1 and PARTNERSSHARE is null
	*/

	/* no longer needed? Award date added, no more records 
	update TTENDERER 
	set PARTNERSSHARE = 0

	select * from TTENDERER
	where ISAWARDED = 1 and PARTNERSSHARE is null
	and CONTRACTID = 183132 /* Contract-11156489 */ */

/* Blank Start Date but is expired */

	/* select * from TCONTRACT
	where STARTDATE is null */

	update TCONTRACT
	set STARTDATE = CONTRACTDATE
	where STARTDATE is null /* no start date */
		/* and EXPIRYDATE < GETDATE() /* has expiry date that has already passed */ */
		/* and CONTRACTID in (select CONTRACTID from TTENDERER) /* has a company assigned */ */
		and getdate() > dateadd(hh,+48,contractdate)   /* registered more than 48 hr ago */
		and NUMBEROFFILES > 0 /* otherwise, junk file to be deleted */

		/* cases - set start date */
	update TCONTRACT
	set STARTDATE = CONTRACTDATE
	where STARTDATE is null /* no start date */
		and CONTRACTTYPEID = 11 /* contract - is case, test */

	/* history from 2019
	update TCONTRACT
	set STARTDATE = CONTRACTDATE
	where STARTDATE is null /* no start date */
	AND contractdate < '2019-12-31 23:00:00.000'
	*/


/* Blank Award Date */

	update TCONTRACT
	set AWARDDATE = STARTDATE
	select * from tcontract
	where AWARDDATE is null 
		and STARTDATE is not null
		and CONTRACTID in (select CONTRACTID from TTENDERER) /* has a company assigned */
			/* OR EXPIRYDATE is not null  OR has expiry date, despite not having counter party assigned */
		and getdate() > dateadd(hh,+24,contractdate)   /* registered more than 24 hr ago */

/*
	select * from TCONTRACT where CONTRACTNUMBER = 'Contract-11157818' /* 194460 */
	select * from TTENDERER where contractid = 194460

	select * from TCONTRACT where AWARDDATE is null and CONTRACTTYPEID = 12 /* contract */

		select * from TCONTRACT where STATUSID = 4 /* awarded */ and EXPIRYDATE < GETDATE()

select * from TCONTRACT 
where CONTRACTID not in (select CONTRACTID from TTENDERER)
and AWARDDATE = startdate


update TCONTRACT
set AWARDDATE = NULL
where CONTRACTID not in (select CONTRACTID from TTENDERER)
and AWARDDATE = startdate
*/

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Maintenance_DeleteOldUnattachedUsers]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[TheCompany_Maintenance_DeleteOldUnattachedUsers]

as

/*
select * INTO T_TheCompany_UserID_CountractRoleCount_VUSER
FROM dbo.V_TheCompany_UserID_CountractRoleCount_VUSER

missing: taudittrail, taudittrailhistory, thistory
*/

/*
select * from TAUDITTRAIL
WHERE USERID in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

select * from taudittrail_history
WHERE USERID in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

select * from thistory
WHERE USERID in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

*/

delete from TUSER_IN_USERGROUP 
WHERE USERID in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

delete from TLOGON
where USERID in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

delete from TUSER_IN_CONTRACT
WHERE USERID in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

delete from TOBJECTHISTORY
WHERE USERID in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

delete from TNOTE_IN_OBJECT
WHERE noteid in (select noteid from tnote 
where userid in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL))

delete from TNOTE
WHERE USERID in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

update TFILEINFO
set LastChangedBy = 1
WHERE LastChangedBy in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

update TPOST
set CREATEDBYUSERID = 1
where CREATEDBYUSERID in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

delete from TPROFILESETTING
WHERE USERID in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

delete from TSEARCHFAVOURITE
WHERE SEARCHFAVOURITE_USERID in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

delete from dbo.TMESSAGE
where SenderUserId in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)
or ReceiverUserId in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL) 

delete from TMESSAGESESSION
WHERE ParticipantUserId in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)
or CreatorUserId in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

delete from tuser
WHERE USERID in (select userid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

delete from TEMPLOYEERELATION
WHERE INFERIOREMPLOYEEID in (select employeeid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)
OR MANAGEREMPLOYEEID in (select employeeid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

delete from temployee 
WHERE employeeid in (select employeeid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

/*
update TCONTRACT
set ownerid = 0
where ownerid in (select employeeid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)


select COUNT(*) from tuser
2404
*/


Update TPERSONROLE_IN_OBJECT /* includes amendments etc. - use admin */
set PERSONID = 1
WHERE personid in (select personid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

/* mostly personroleid 16 = everyone NOT YET DONE */
delete from dbo.TPERSONROLE_IN_OBJECTTYPE
WHERE personid in (select personid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

/* select COUNT(*) from TPERSONROLE_IN_OBJECTTYPE where ROLEID = 16

select * from TCONTRACT where contractid = 101798
select * from TACL where OBJECTID = 101798
select * from VUSER where DISPLAYNAME like '%joest%'

select * from TPERSONROLE_IN_OBJECTtype
WHERE /* personid in (select personid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL) */
PERSONID = 34530
*/

/*
delete from TPERSONROLE_IN_OBJECT
WHERE PERSONID not in (select PERSONID from VUSER)

delete from dbo.TPERSONROLE_IN_OBJECTTYPE
WHERE PERSONID not in (select PERSONID from VUSER)
*/

DELETE from tperson
WHERE PERSONID not in (select PERSONID from VUSER)
and PERSONID not in (select PERSONID from TCOMPANYCONTACT)
and PERSONID not in (select PERSONID from TPERSON_IN_WARNING)
and PERSONID not in (select PERSONID from TEMPLOYEE)
and PERSONID not in (select PERSONID from dbo.TCONSULTANT)
and PERSONID IN (select personid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)

/* delete from TACL /* this also deletes super user permissions which then cannot be transferred */
where USERID not in (select USERID from TUSER where MIK_VALID = 1) */

GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Maintenance_DeleteOldUnattachedUsers_UserID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[TheCompany_Maintenance_DeleteOldUnattachedUsers_UserID] (
@USERID bigint
, @EMPLOYEEID bigint
, @PERSONID bigint)

as

/*

select 'exec [dbo].[TheCompany_Maintenance_DeleteOldUnattachedUsers_UserID] ' 
	+ str(USERID) + ' /*' + userinitial + '*/' 
	+ (case when EMPLOYEEID is null then ', NULL ' ELSE ', ' + str(EMPLOYEEID) END)  
	+ (case when PERSONID is null then ', NULL '  ELSE ', ' + str(PERSONID) END)  
	+ ' /* Displayname: ' + DISPLAYNAME + '*/'
	/* + ' /* email: ' + lastname + '*/' */
from v_TheCompany_vuser 
where personid not in (select personid from TPERSONROLE_IN_OBJECT)
/* and userid = 5 */
and USER_MIK_VALID = 0
and (PRIMARYUSERGROUPID is null or PRIMARYUSERGROUPID <> 3529 /* not sys acc */)
and USERID in (select userid from V_TheCompany_UserID_CountractRoleCount where Count_ACL is null)
and USERINITIAL not like '%admin%'
and USERINITIAL not like '%TheVendor%'
order by [userprofilecategory]

*/

DECLARE @RESULTSTRING AS VARCHAR(255)

	IF NOT EXISTS ( select * from v_TheCompany_vuser 
			where 
			userid = @USERID
			and (personid is null or personid not in (select personid from TPERSONROLE_IN_OBJECT)) /* no more person roles */
			and DISPLAYNAME not like '%admin%'
			and DISPLAYNAME not like '%system%'
			and USER_MIK_VALID = 0
			and (PRIMARYUSERGROUPID is null or PRIMARYUSERGROUPID <> 3529 /* not sys acc */)
			)

		BEGIN
			SET @RESULTSTRING = 'User id not valid or not deactivated, user id: ' + STR(@USERID)
			GOTO lblTerminate 
		END

BEGIN

	/* delete from TACL /* this also deletes super user permissions which then cannot be transferred */
	where USERID not in (select USERID from TUSER where MIK_VALID = 1) */

	/* delete privileges 1,2 - read and write */
	delete from TACL
	WHERE USERID  = @USERID
	and privilegeid in (1,2 /* read and write */)

	/* transfer permissions 3,4,5 to admin */
	update TACL 
	set USERID = 83663 /* user id joest, better than user id 1 /*sysadmin*/ */
	WHERE USERID = @USERID 
	and privilegeid in (3,4,5 /* create delete owner */)

	delete from TUSER_IN_USERGROUP 
	WHERE USERID = @USERID

/* print 'exited: ' + STR(@USERID)
goto lblEnd */

/* user id */

	delete from TLOGON
	WHERE USERID = @USERID

	delete from TUSER_IN_CONTRACT
	WHERE USERID = @USERID

	delete from TOBJECTHISTORY
	WHERE USERID = @USERID

	delete from TNOTE_IN_OBJECT
	WHERE noteid in (select noteid from tnote 
			WHERE USERID = @USERID)

	delete from TNOTE
	WHERE USERID = @USERID

	update TFILEINFO
	set LastChangedBy = 1
	WHERE LastChangedBy = @USERID



	Update tdocument
	set USERID = 83663 /* user id joest, better than user id 1 /*sysadmin*/ */ /* sysadmin */
	WHERE userid = @USERID

	Update dbo.TCONTRACT_IN_ARCHIVE
	set USERID = 83663 /* user id joest, better than user id 1 /*sysadmin*/ */ /* sysadmin */
	WHERE userid = @USERID	
	and CONTRACTID not in (select CONTRACTID from dbo.TCONTRACT_IN_ARCHIVE where USERID = 1)

	/* delete records where admin already added */
	delete from dbo.TCONTRACT_IN_ARCHIVE
	WHERE userid = @USERID	
	and CONTRACTID in (select CONTRACTID from dbo.TCONTRACT_IN_ARCHIVE where USERID = 1)

	Update dbo.TWARNING
	set USERID = 83663 /* user id joest, better than user id 1 /*sysadmin*/ */ /* sysadmin */
	WHERE userid = @USERID	

	delete from TPROFILESETTING
	WHERE USERID = @USERID

	delete from dbo.TMESSAGE
	where SenderUserId  = @USERID
	or ReceiverUserId  = @USERID

	delete from TMESSAGESESSION
	WHERE ParticipantUserId  = @USERID
	or CreatorUserId  = @USERID

/* search */
	delete from TSEARCHFAVOURITE
	WHERE SEARCHFAVOURITE_USERID  = @USERID

	delete from tsearchline
	where SEARCHID in (select SEARCHID from TSEARCH where USERID = @USERID)

	delete from tsearch /* custom search profiles */
	WHERE USERID = @USERID
	
	/* NEVER delete anything from this table or files will vanish in CCS */
	
	/* post and discussion, tpost has discussion id */
	update TPOST
	set CREATEDBYUSERID = 1
	where CREATEDBYUSERID = @USERID 

	/* NEVER delete anything from this table or files will vanish in CCS */
	update dbo.TDISCUSSION
	set CREATEDBYUSERID = 1
	where CREATEDBYUSERID = @USERID

	update dbo.TCONTRACT
	set EXECUTORID = 1 /* executorid is outdated field */
	where EXECUTORID = @USERID

	update TUSER_IN_CATEGORY
	set USERID = 83663 /* user id joest, better than user id 1 /*sysadmin*/ */
	WHERE USERID = @USERID

	update TPAYMENTPLAN
	set [REGISTEREDBY] = 1
	WHERE [REGISTEREDBY] = @USERID

	update TPAYMENTPLAN
	set [CHANGEDBY] = 1
	WHERE [CHANGEDBY]  = @USERID

	update tinfoseek
	set USERID = 83663 /* user id joest, better than user id 1 /*sysadmin*/ */
	where userid = @USERID

	update TSTRATEGY
	set USERID = 83663 /* user id joest, better than user id 1 /*sysadmin*/ */
	where userid = @USERID

	update TPREDEFINED_ACTIVITY
	set USERID = 83663 /* user id joest, better than user id 1 /*sysadmin*/ */
	where userid = @USERID

	update dbo.TSYSTEMEVENT
	set USERID = 83663 /* user id joest, better than user id 1 /*sysadmin*/ */
	where userid = @USERID

	update dbo.TROUTINGSLIP
	set USERID = 83663 /* user id joest, better than user id 1 /*sysadmin*/ */
	where userid = @USERID

	update dbo.TACTIVITY
	set USERID = 83663 /* user id joest, better than user id 1 /*sysadmin*/ */
	where userid = @USERID

	update dbo.TACTIVITY
	set RESPONSIBLEUSERID = 1
	where RESPONSIBLEUSERID = @USERID

	update dbo.Tmodule
	set USERID = 83663 /* user id joest, better than user id 1 /*sysadmin*/ */
	where USERID = @USERID

/* LAST!!! */
	delete from tuser
	WHERE USERID  = @USERID


/* Employee ID */

if @EMPLOYEEID is null goto lblPerson

lblEmployee:

	delete from TEMPLOYEERELATION
	WHERE INFERIOREMPLOYEEID = @EMPLOYEEID
	OR MANAGEREMPLOYEEID = @EMPLOYEEID

	delete from temployee 
	WHERE employeeid  = @EMPLOYEEID

	/*
	update TCONTRACT
	set ownerid = 0
	where ownerid in (select employeeid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)


	select COUNT(*) from tuser
	2404
	*/

lblPerson:

if @PERSONID is null goto lblSuccess

	Update TPERSONROLE_IN_OBJECT /* includes amendments etc. - use admin */
	set PERSONID = 34530 /* joest NOT 1 due to dupes for personid 0 */
	WHERE personid = @PERSONID

	/* mostly personroleid 16 = everyone NOT YET DONE */
	delete from dbo.TPERSONROLE_IN_OBJECTTYPE
	WHERE personid = @PERSONID


	DELETE from tperson
	WHERE Personid = @PERSONID
	and PERSONID not in (select PERSONID from VUSER)
	and PERSONID not in (select PERSONID from TCOMPANYCONTACT)
	and PERSONID not in (select PERSONID from TPERSON_IN_WARNING)
	and PERSONID not in (select PERSONID from TEMPLOYEE)
	and PERSONID not in (select PERSONID from dbo.TCONSULTANT)
	and PERSONID IN (select personid from V_TheCompany_UserID_CountractRoleCount_VUSER_DEL)


goto lblSuccess

lblTerminate: 
PRINT 'resultstring: ' + @RESULTSTRING
PRINT '!!! Statement did not execute due to invalid input values!'
goto lblEnd

lblSuccess: 
PRINT '*** SUCCESS for user id:' + str(@USERID)

lblEnd:

END

/*

(0 rows affected)
Msg 547, Level 16, State 0, Procedure TheCompany_Maintenance_DeleteOldUnattachedUsers_UserID, Line 101 [Batch Start Line 5]
The DELETE statement conflicted with the REFERENCE constraint "TUSER_FK_EMPLOYEEID". The conflict occurred in database "TheVendor_app", table "dbo.TUSER", column 'EMPLOYEEID'.
The statement has been terminated.

*/
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Maintenance_DptCodesIP4DigitMergeUpdate]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[TheCompany_Maintenance_DptCodesIP4DigitMergeUpdate]

as
print 'x'
/*
exec TheCompany_MergeDepartments 10087


select r.* , d.DEPARTMENT, dp.department as Parent, d.PARENTID, d.DEPARTMENTLEVEL, d.DEPARTMENT_CODE
from TDEPARTMENTROLE_IN_OBJECT r
inner join TDEPARTMENT d on r.DEPARTMENTID = d.departmentid
inner join TDEPARTMENT dp on d.PARENTID = dp.departmentid
where r.DEPARTMENTID in (select DEPARTMENTID 
						from TDEPARTMENT 
						where MIK_VALID = 0
						and DEPARTMENTLEVEL <> 1 /* not root */)
	and d.PARENTID <> 204318 /* (_Inactive */
	and d.department_code like '.%' /* IP */
	and d.department = 'DEL'


	*/
/*
update m
	set m.[Cnt_CompanyID] = d.DEPARTMENTID
	, m.[Cnt_CompanyName] = d.DEPARTMENT
from [dbo].[T_TheCompany_Blueprint_CompanyReport] c 
	inner join [dbo].[T_TheCompany_Blueprint_Mapping] m 
		on m.[Bp_CompanyQuickRef] = C.[QuickRef]
	
	inner join [dbo].[V_TheCompany_VDepartment_ParsedDpt_InternalPartner_ACTIVE] d 
		on dbo.TheCompany_RemoveNonAlphaCharacters(d.[InternalPartner_Clean])  like  dbo.TheCompany_RemoveNonAlphaCharacters(c.[Company Name]) + '%'
		OR dbo.TheCompany_RemoveNonAlphaCharacters(c.[Company Name])  like  dbo.TheCompany_RemoveNonAlphaCharacters(d.[InternalPartner_Clean]) + '%'
	WHERE /* c.[Company Name] like '%baxalta belg%' */
	d.MIK_VALID = 1 
	and d.DEPARTMENT_CODE like ',[a-z]%'
	and m.[Cnt_CompanyID] is null
	and [Bp_CompanyName] <> '%office%'
	and [Bp_CompanyName] <> '%branch%'
		and [Bp_CompanyName] <> '%tax division%'

	update [dbo].[T_TheCompany_Blueprint_Mapping]
	set [Cnt_CompanyID] = null, [Cnt_CompanyName] = null
	where 
	[Cnt_CompanyID] in (select [Cnt_CompanyID] from [T_TheCompany_Blueprint_Mapping]
	group by [Cnt_CompanyID]
	having COUNT([Cnt_CompanyID])>1)

	select *
	from [dbo].[T_TheCompany_Blueprint_Mapping] 
	where cnt_companyid = 204257

	
	inner join [dbo].[V_TheCompany_VDepartment_ParsedDpt_InternalPartner_ACTIVE] d 
		on d.[InternalPartner_Clean] like '%' + c.[Company Name] + '%'
		OR c.[Company Name] like  '%' + d.[InternalPartner_Clean] + '%'
	WHERE /* c.[Company Name] like '%baxalta belg%' */
	m.[Cnt_CompanyID] is null
	and c.[Company status (code)]='ACTIVE'

	create view V_TheCompany_Blueprint_IP

	as

		select d.*, C.*
	from   [dbo].[V_TheCompany_VDepartment_ParsedDpt_InternalPartner] d 	
		left join [dbo].[T_TheCompany_Blueprint_Mapping] m
			on  m.[Cnt_CompanyID] = d.[DEPARTMENTID]
		left join  [dbo].[T_TheCompany_Blueprint_CompanyReport] c 
			 on c.[QuickRef] = m.[Bp_CompanyQuickRef]

	WHERE d.internalpartnerstatusflag = -1
		and m.cnt_companyid is null


		OR c.[Company Name] like  '%' + d.[InternalPartner_Clean] + '%'
			left join [dbo].[T_TheCompany_Blueprint_CompanyReport] c on 
	inner join
	WHERE /* c.[Company Name] like '%baxalta belg%' */
	and c.[Company status (code)]='ACTIVE'


 update  m
set [Bp_CompanyStatus] = [Company status (code)]
from 
 [dbo].[T_TheCompany_Blueprint_Mapping] m inner join [dbo].[T_TheCompany_Blueprint_CompanyReport] c 
 on m.[Bp_CompanyQuickRef] = C.[QuickRef]

insert 
into [dbo].[T_TheCompany_Blueprint_Mapping] 
select [QuickRef] as [QuickRef]
, [Company Name] as [Company Name], null, null
from [dbo].[T_TheCompany_Blueprint_CompanyReport]
*/
/*
select * from [V_TheCompany_VDepartment_ParsedDpt_InternalPartner] where DEPARTMENT like '%baxalta manuf%'

select * from [T_TheCompany_Blueprint_Mapping] where [Bp_CompanyName] like '%baxalta manuf%'

select * from TDEPARTMENT where upper(DEPARTMENT) like upper('%Pharmaceutical contr%')

Shire Pharmaceuticals Contracts Ltd. (Russia Rep. Office)

*/
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Maintenance_Misc]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[TheCompany_Maintenance_Misc]

as

BEGIN

 /* DELETE from TLOGON where USERID = 85748 /* svc001347 */ */
 
	update TUSERGROUP 
	set MIK_VALID = 0
	where MIK_VALID = 1 
	AND DEPARTMENTID in (select DEPARTMENTID from TDEPARTMENT where MIK_VALID = 0)
 
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Maintenance_restoreTpostDiscussion]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_Maintenance_restoreTpostDiscussion]

as

insert into TDISCUSSION (
 /*[DISCUSSIONID] */
      [OWNEROBJECTTYPEID]
      ,[OWNEROBJECTID]
      ,[DISCUSSIONNUMBER]
      ,[TOPIC]
      ,[STATUSID]
      ,[CREATEDTIMESTAMP]
      ,[CREATEDBYUSERID]
      ,[CLOSEDTIMESTAMP]
      ,[CLOSEDBYUSERID]
      ,[MIK_VALID]
      ,[DISCUSSIONTYPEID]
	  )

		  select /* [DISCUSSIONID]*/
       7 as [OWNEROBJECTTYPEID] /* objecttype document */
      , DOCUMENTID as [OWNEROBJECTID] /* documentid */
      , 0 as [DISCUSSIONNUMBER]
      , '' as [TOPIC] /* null not allowed */
      ,0 as [STATUSID]
		,GETDATE() /*[CREATEDTIMESTAMP] */ as CREATEDTIMESTAMP
	,83663 /* user id joest */ as [CREATEDBYUSERID]
      ,null [CLOSEDTIMESTAMP]
      ,null [CLOSEDBYUSERID]
      ,1 as [MIK_VALID]
      ,2 as [DISCUSSIONTYPEID]

  from TDOCUMENT 
  where  
  documentid  not in (select [OWNEROBJECTID] from tdiscussion where OWNEROBJECTTYPEID = 7 )
  /* and DOCUMENTID = 197020 */
  and MIK_VALID = 1
  and OBJECTID in (select contractid from V_TheCompany_vcontract 
				WHERE contracttypeid NOT IN (	  5 /* Test Old */
									, 6 /* Access SAKSNR number Series*/		
									/*,  11	Case */					
									, 13 /* DELETE */
									, 102 /* Test New */								
									/*, 103, 104, 105 /* Lists */*/
									, 106 /* AutoDelete */
									) 
									/* and STATUSID = 5 *//* active */
									)

/* remove ownerid filter */
  insert into tpost  ([DISCUSSIONID]
      ,[CREATEDTIMESTAMP]
      ,[CREATEDBYUSERID]
      ,[BODY]
      ,[POSTEDOBJECTID]
      ,[POSTEDOBJECTTYPEID]) 
	  
	  select   
	DISCUSSIONID
	,GETDATE() /*[CREATEDTIMESTAMP] */ as CREATEDTIMESTAMP
	,83663 /* user id joest */ as OWNERID
	,null /* body */
	, 208881 /* documentid */
	, 7 /* objecttype document */
	from TDISCUSSION 
	where 
	OWNEROBJECTTYPEID = 7 /* document */
	/* and OWNEROBJECTID = 11998 */
	and DISCUSSIONID not in (select DISCUSSIONID from TPOST)

/* tdiscussion new */

/*
SELECT TOP (1000) [DISCUSSIONID]
      ,[OWNEROBJECTTYPEID]
      ,[OWNEROBJECTID]
      ,[DISCUSSIONNUMBER]
      ,[TOPIC]
      ,[STATUSID]
      ,[CREATEDTIMESTAMP]
      ,[CREATEDBYUSERID]
      ,[CLOSEDTIMESTAMP]
      ,[CLOSEDBYUSERID]
      ,[MIK_VALID]
      ,[DISCUSSIONTYPEID]
  FROM [TheVendor_app].[dbo].[TDISCUSSION]

  select COUNT(*) from TDISCUSSION
  select COUNT(*) from TDOCUMENT where MIK_VALID = 1 /* 155287*/

  select documentid from TDOCUMENT 
  where  documentid  not in (select [OWNEROBJECTID] from tdiscussion where OWNEROBJECTTYPEID = 7 )
  and MIK_VALID = 1
  and OBJECTID in (select contractid from V_TheCompany_vcontract 
				WHERE contracttypeid NOT IN (	  5 /* Test Old */
									, 6 /* Access SAKSNR number Series*/		
									/*,  11	Case */					
									, 13 /* DELETE */
									, 102 /* Test New */								
									, 103, 104, 105 /* Lists */
									, 106 /* AutoDelete */
									) 
									and STATUSID = 5 /* active */)

  select * from v_TheCompany_vDOCUMENT where DOCUMENTID = 202004
  select * from TDISCUSSION where ownerobjectid in(202004 /* missing */, 199301 /*present*/)

  select * from TDOCUMENT where OBJECTID = 111133 and OBJECTTYPEID = 1
  update TDOCUMENT set USERID =  83663 /* user id joest */ where DOCUMENTID in (202004,202005)

  select * from vUSER where lastname like '%joest%'

  select distinct ownerobjecttypeid from tdiscussion

  select * from TDOCUMENT where USERID = 1

  update TDOCUMENT 
  set USERID = 83663 /* user id joest */ where USERID = 1
  and MIK_VALID = 1


  */
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Maintenance_SAP_ID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  PROCEDURE [dbo].[TheCompany_Maintenance_SAP_ID]

AS

BEGIN

print 'this'
/*
Select c.company, c.[Company_LettersNumbersOnly_UPPER] 
	, [SupName_SAP], s.[Sup_LettersNumbersOnly_UPPER]
	, LEN(c.[Company_LettersNumbersOnly_UPPER]) - LEN(c.[Company_LettersNumbersOnly_UPPER]) as LenVar
from [dbo].[T_TheCompany_VCompany] c 
	inner join V_TheCompany_Ariba_Suppliers_SAPID_Country_VALID s 
		on c.[Company_LettersNumbersOnly_UPPER] like s.[Sup_LettersNumbersOnly_UPPER]  + '%' 
		OR s.[Sup_LettersNumbersOnly_UPPER] like   c.[Company_LettersNumbersOnly_UPPER] + '%' 
where 
		c.Company_SAP_ID is null /* EXTERNALNUMBER */  /* SAP number like Fette GmbH = 0000264881 */
		and SupID_SAP is not null
		/* and [Sup_Name_ValidString_FLAG] = 1  no special char(63) Russian Chine Char found  */
		and len(c.[Company_LettersNumbersOnly_UPPER]) >3
		and s.[Sup_Name_SAP_LEN] > 3
		and LEN(c.[Company_LettersNumbersOnly_UPPER]) - s.[Sup_Name_SAP_LEN] <3 /* less than 3 char difference */
		and c.companyid_LN in (select companyid from TTENDERER 
					where CONTRACTID in (select CONTRACTID from T_TheCompany_ALL where InternalPartners_DptCodeList like '%,fr%'))

update TCOMPANY c
set c.EXTERNALNUMBER = [SupID_SAP] 

select cv.COMPANY,cv.Company_LettersNumbersSpacesOnly_UPPER
, s.[SupName_SAP]
,s.[Sup_LettersNumbersOnly_UPPER]
, s.[SupID_SAP]
, s.[Sup_Name_ValidString_FLAG]
from tcompany c
	inner join [dbo].[T_TheCompany_VCompany] cv 
		on c.companyid = cv.companyid_LN
	inner join V_TheCompany_Ariba_Suppliers_SAPID_Country_VALID s 
		on cv.[Company_LettersNumbersOnly_UPPER] like s.[Sup_LettersNumbersOnly_UPPER]  + '%' 
		OR s.[Sup_LettersNumbersOnly_UPPER] like   cv.[Company_LettersNumbersOnly_UPPER] + '%' 
where EXTERNALNUMBER is null
		and c.companyid in (select companyid from TTENDERER 
					where CONTRACTID in (select CONTRACTID from T_TheCompany_ALL where InternalPartners_DptCodeList like '%,fr%'))


END
/*
select * from [T_TheCompany_Ariba_Suppliers_SAPID_Country] where SupName_SAP like 'Amgen%'
	inner join V_TheCompany_Ariba_Suppliers_SAPID_Country_VALID s 
		on cv.[Company_LettersNumbersOnly_UPPER] like s.[Sup_LettersNumbersOnly_UPPER]  + '%' 
		OR s.[Sup_LettersNumbersOnly_UPPER] like   cv.[Company_LettersNumbersOnly_UPPER] + '%' 
		*/
		*/

end
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Maintenance_TerritoryHashTags]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure

[dbo].[TheCompany_Maintenance_TerritoryHashTags]

as 
/*
update d set d.department_code = replace(d.DEPARTMENT_CODE,d.DEPARTMENT_CODE, d.DEPARTMENT_CODE + '#GEM')
from tdepartment d inner join T_TheCompany_Hierarchy h on d.DEPARTMENTID = h.DEPARTMENTID
where 
L1 = 'GEM' 
and (d.DEPARTMENT_CODE LIKE '%;%') 
AND (d.DEPARTMENT_CODE NOT LIKE '%;%;%')
and d.department_code not like '%GEM%'



select d.DEPARTMENT_CODE, replace(d.DEPARTMENT_CODE,d.DEPARTMENT_CODE, d.DEPARTMENT_CODE + '#GEM')
from tdepartment d inner join T_TheCompany_Hierarchy h on d.DEPARTMENTID = h.DEPARTMENTID
where 
L1 = 'GEM' 
and (d.DEPARTMENT_CODE LIKE '%;%') 
AND (d.DEPARTMENT_CODE NOT LIKE '%;%;%')
and d.department_code not like '%GEM%'

/* eu */

select d.department_code , replace(d.DEPARTMENT_CODE,d.DEPARTMENT_CODE, d.DEPARTMENT_CODE + '#EU')
from tdepartment d inner join T_TheCompany_Hierarchy h on d.DEPARTMENTID = h.DEPARTMENTID
where 
L1 = 'Europe and Canada' 
and (d.DEPARTMENT_CODE LIKE '%;%') 
AND (d.DEPARTMENT_CODE NOT LIKE '%;%;%')
and d.department_code not like '%#EU%'


update d set d.department_code = replace(d.DEPARTMENT_CODE,d.DEPARTMENT_CODE, d.DEPARTMENT_CODE + '#EU')
from tdepartment d inner join T_TheCompany_Hierarchy h on d.DEPARTMENTID = h.DEPARTMENTID
where 
L1 = 'Europe and Canada' 
and (d.DEPARTMENT_CODE LIKE '%;%') 
AND (d.DEPARTMENT_CODE NOT LIKE '%;%;%')
and d.department_code not like '%#EU%'

*/
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Maintenance_Usergroup_Department_Cleanup]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[TheCompany_Maintenance_Usergroup_Department_Cleanup]

as 

begin



SELECT 

		 'delete from tusergroup where departmentid = ' + convert(varchar(255),departmentid) 
		 + '/* ' + usergroup + ' */'
		 + '; ' 

		 as DelUsergroup
		, 'delete from tdepartment where departmentid = ' + convert(varchar(255),departmentid) 
		 + '/* ' + DEPARTMENT + ' */'
		 + '; ' 	
		as DelDepartment

  FROM V_TheCompany_VDEPARTMENT_VUSERGROUP
  WHERE 
	DEPARTMENTID not in (select DEPARTMENTID from TDEPARTMENTROLE_IN_OBJECT)
/*	and DEPARTMENTID not in (select GROUPID from TACL) */
/*	and DEPARTMENT like '%delete%' */
	and MIK_VALID = 0
	and Dpt_MIK_VALID = 0

	select * from TDEPARTMENT where DEPARTMENTID = 201973
	delete from TDEPARTMENT where DEPARTMENTID = 201973 


	select * from TUSERGROUP where USERGROUPID = 214

	select g.usergroup, a.* 
	from TACL a 
		inner join TUSERGROUP g on a.GROUPID = g.USERGROUPID
	where GROUPID in (select usergroupid from TUSERGROUP where MIK_VALID = 0)

	/* all dupes since already added */
	select 'update tacl set groupid = ' + convert(varchar(255),d.USERGROUPID) 
			+ '/* ' + d.usergroup + ' */ where aclid = ' + convert(varchar(255),A.aclid) 
			+ ' and groupid = ' + convert(varchar(255),u.USERGROUPID) 
			+ '/* ' + u.usergroup + '*/'
						as Del1 
	, u.USERGROUPID,U.usergroup , d.usergroupid , d.usergroup
	from V_TheCompany_VDEPARTMENT_VUSERGROUP u
		inner join V_TheCompany_VDEPARTMENT_VUSERGROUP d on u.PARENTID = d.departmentid
		inner join tacl a on a.groupid = u.USERGROUPID
	where u.MIK_VALID = 0
	and ACLID not in (select ACLID from TACL aa where aa.OBJECTID = a.objectid and aa.GROUPID = a.GROUPID)

	select 'update tacl set groupid = ' + convert(varchar(255),d.USERGROUPID) 
			+ '/* ' + d.usergroup + ' */ where aclid = ' + convert(varchar(255),A.aclid) 
			+ ' and groupid = ' + convert(varchar(255),u.USERGROUPID) 
			+ '/* ' + u.usergroup + '*/'
						as Del1 
	, u.USERGROUPID,U.usergroup , d.usergroupid , d.usergroup
	from V_TheCompany_VDEPARTMENT_VUSERGROUP u
		inner join V_TheCompany_VDEPARTMENT_VUSERGROUP d on u.PARENTID = d.departmentid
		inner join tacl a on a.groupid = u.USERGROUPID
	where u.MIK_VALID = 0
	and ACLID not in (select ACLID from TACL aa where aa.OBJECTID = a.objectid and aa.GROUPID = a.GROUPID)

	/* delete */
		select 'delete from tacl where aclid = ' + convert(varchar(255),A.aclid) 
						as Del1 
	, u.USERGROUPID,U.usergroup , d.usergroupid , d.usergroup
	from V_TheCompany_VDEPARTMENT_VUSERGROUP u
		inner join V_TheCompany_VDEPARTMENT_VUSERGROUP d on u.PARENTID = d.departmentid
		inner join tacl a on a.groupid = u.USERGROUPID
	where u.MIK_VALID = 0
	and ACLID  in (select ACLID from TACL aa where aa.OBJECTID = a.objectid and aa.GROUPID = a.GROUPID)

		/* delete */
		select 'delete from tacl where aclid = ' + convert(varchar(255),A.aclid) 
						as Del1 
	, u.USERGROUPID,U.usergroup 
	, u.DEPARTMENT_CODE
	from V_TheCompany_VDEPARTMENT_VUSERGROUP u
		inner join tacl a on a.groupid = u.USERGROUPID
	where u.MIK_VALID = 0

	and ACLID  in (select ACLID from TACL aa where aa.OBJECTID = a.objectid and aa.GROUPID = a.GROUPID)

	select * from TDEPARTMENT where DEPARTMENTID = 1
/*
delete from tusergroup where DEPARTMENTID = 201054
delete from TDEPARTMENT where DEPARTMENTID = 201054

select * from TUSERGROUP where DEPARTMENTID  = 201054

select * from TACL where GROUPID not in (select usergroupid from TUSERGROUP where MIK_VALID = 1)

select * from TUSERGROUP 
where COMPANYID not in (select COMPANYID from TTENDERER)
and COMPANYID >4
and MIK_VALID = 0

delete from tusergroup
where COMPANYID not in (select COMPANYID from TTENDERER)
and COMPANYID >4
and MIK_VALID = 0


  select COMPANY, COMPANYNO, EXTERNALNUMBER, DUNSNUMBER from TCOMPANY 
 where externalnumber like '%--%'

  update TCOMPANY
  set DUNSNUMBER = ''
  where COMPANYID in ('220446',
'220447',
'220624'
)

 where EXTERNALNUMBER is not null 
  and EXTERNALNUMBER not like '0000%'
  and EXTERNALNUMBER <>''
  and externalnumber not like '%--%'

  select /* parentcompanyid */
    'delete from TCONSULTANT where COMPANYID = ' + convert(varchar(255),COMPANYID) 
    , '; delete from TCOMPANYFLAGS where COMPANYID = ' + convert(varchar(255),COMPANYID) 
    , '; delete from TCOMPANYcontact where COMPANYID = ' + convert(varchar(255),COMPANYID) 
	, '; delete from TCOMPANYaddress where COMPANYID = ' + convert(varchar(255),COMPANYID) 
	, '; delete from TCOMPANY where COMPANYID = '   + convert(varchar(255),COMPANYID) 
  from TCOMPANY 
  where 
  COMPANYID not in (select COMPANYID from TTENDERER)

  select c.COMPANY, p.COMPANY
   from TCOMPANY c inner join TCOMPANY p on c.PARENTCOMPANYID = p.companyid
  where c.PARENTCOMPANYID not in (select COMPANYID from TTENDERER)



end

select * from dbo.TCOMPANYFLAGS

select * from TTENDERER where COMPANYID = 376419

select 'update tcompany set  EXTERNALNUMBER = ''' +a.SupID_SAP
	+ ''' WHERE companyid = ' +convert(varchar(255), c.companyid_LN)  
from T_TheCompany_VCompany c 
	inner join T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields a
	on c.Company_LettersNumbersOnly_UPPER = Sup_LettersNumbersOnly_UPPER
	where LEN(Sup_LettersNumbersOnly_UPPER) >3
	and (c.Company_SAP_ID = '' or c.Company_SAP_ID is null)


		, UPPER(dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([COMPANY]))
		as Company_LettersNumbersOnly_UPPER

select * from TCOMPANY where COMPANY like '%shire%'

update TCOMPANY set ISINTERNAL = 1 
where COMPANY like '%baxalta%'
and ISINTERNAL = 0

select *
 from T_TheCompany_vcompany c inner join [V_TheCompany_VCOMPANY_DUPLICATES] d
 on c.Company_LettersNumbersOnly_UPPER = d.Company_LettersNumbersOnly_UPPER 

 */

end
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_MergeDepartments]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_MergeDepartments](
                @DEPARTMENTID_OLD bigint 
				/* DEPARTMENT_code must be like '%_DUPE%', and must be child to new dpt */
                /* , @DEPARTMENTID_NEW bigint */
)
AS

/* Check if valid input parameters passed */
/*
select * from TDEPARTMENT where DEPARTMENT like '%TheCompany pharma ag%'
select * from tusergroup where usergroup like '%TheCompany pharma ag%'

update TUSER set primary

	update TUSER_IN_USERGROUP
	set USERGROUPID = 228
	where USERGROUPID in (384, 382,385)

	*/
DECLARE @RESULTSTRING AS VARCHAR(255)
declare @DEPARTMENTID_NEW bigint
declare @USERGROUPID_OLD as VARCHAR(255)
declare @USERGROUPID_NEW as VARCHAR(255)
declare @USERGROUPNAME_NEW as VARCHAR(255)
declare @USERGROUPNAME_OLD as VARCHAR(255)

BEGIN

/* user group first, then department*/


lblUserGroup:


	/*	@USERGROUPID */
	IF NOT EXISTS ( SELECT  1
						FROM    TUSERGROUP
						WHERE   DEPARTMENTID = @DEPARTMENTID_OLD)
			BEGIN
				SET @RESULTSTRING = 'OLD Department id does not exist in USERGROUP table'
				GOTO lblDepartment
			END

	IF NOT EXISTS ( SELECT  1
						FROM    TUSERGROUP
						WHERE   DEPARTMENTID = @DEPARTMENTID_NEW)
			BEGIN
				SET @RESULTSTRING = 'NEW Department id does not exist in USERGROUP table'
				GOTO lblDepartment
			END

	set @USERGROUPID_OLD = (select usergroupid from tusergroup where departmentid = @DEPARTMENTID_OLD)
	set @USERGROUPID_NEW = (select usergroupid from tusergroup where departmentid = @DEPARTMENTID_NEW)
	set @USERGROUPNAME_OLD =  (SELECT USERGROUP FROM TUSERGROUP WHERE departmentid = @DEPARTMENTID_OLD /* usergroupid = @USERGROUPID_OLD */)
	/* set @USERGROUPNAME_NEW =  (SELECT USERGROUP FROM TUSERGROUP WHERE usergroupid = @USERGROUPID_NEW) */

	PRINT 'Usergroupid OLD: ' + @USERGROUPID_OLD + ' - ' + @USERGROUPNAME_OLD
	PRINT 'Usergroupid NEW: ' + @USERGROUPID_NEW /* + ' - ' + @USERGROUPNAME_NEW */

	update TUSER_IN_USERGROUP
	set USERGROUPID = @USERGROUPID_NEW
	where USERGROUPID = @USERGROUPID_OLD

/* goto lblNoChange */
lblUsergroup_DELETE:

	delete from TUSERGROUP where DEPARTMENTID = @DEPARTMENTID_OLD /* dupe */

lblDepartment:

	IF NOT EXISTS ( SELECT  1
						FROM    TDEPARTMENT
						WHERE   DEPARTMENTID = @DEPARTMENTID_OLD)
			BEGIN
				SET @RESULTSTRING = 'OLD Department id does not exist in TDEPARTMENT'
				GOTO lblTerminate
			END

	IF NOT EXISTS ( SELECT  1
					FROM    TDEPARTMENT
					WHERE   
						DEPARTMENTID = @DEPARTMENTID_OLD /* e.g. 204128 */
						/* and DEPARTMENT_code like '%_DUPE%' */
						and MIK_VALID = 0 /* dpt to merge must be inactive */)
		BEGIN
			SET @RESULTSTRING = 'OLD Dpt ID exists in TDEPARTMENT , but is not deactivated: ' + STR(@DEPARTMENTID_OLD) 
			GOTO lblTerminate 
		END

	IF NOT EXISTS ( SELECT  1
					FROM    TDEPARTMENT
					WHERE   
						PARENTID = @DEPARTMENTID_OLD /* e.g. 204128 */)
		BEGIN
			SET @RESULTSTRING = 'PARENTID for old Dpt ID does not exist in TDEPARTMENT : ' + STR(@DEPARTMENTID_OLD) 
			/* set @DEPARTMENTID_NEW = null */
			GOTO lblTerminate
		END

	set @DEPARTMENTID_NEW = (select parentid 
							from TDEPARTMENT 
							where DEPARTMENTID = @DEPARTMENTID_OLD)

/* TDEPARTMENT updates, of new and old department id exist */

	update TDEPARTMENTROLE_IN_OBJECT 
	set DEPARTMENTID = @DEPARTMENTID_NEW /* real DEV */
	where DEPARTMENTID = @DEPARTMENTID_OLD /* dupe */

	/* Primary user group */
	update TEMPLOYEE 
	set DEPARTMENTID = @DEPARTMENTID_NEW /* real DEV */
	where DEPARTMENTID = @DEPARTMENTID_OLD /* dupe */

lblDepartment_DELETE:
	delete from TDEPARTMENT where DEPARTMENTID = @DEPARTMENTID_OLD /* dupe */

GOTO lblEnd

	lblTerminate: 
	PRINT '!!! Statement did not execute due to invalid input values!'
	GOTO lblBlankLine

	lblNoChange:
	PRINT '--- Statement did not result in any changes'
	GOTO lblBlankLine

lblEnd: 
	PRINT '*** Record updated Successfully'

	lblBlankLine:
	PRINT '     ' + @RESULTSTRING
	PRINT CHAR(13) /* carriage return */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_MIG_DOWNLOAD]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_MIG_DOWNLOAD]

as

BEGIN
print 'this'
/* database file path listing = files and paths */

/*
select agreement_type,migfolder, SUM([FileSize]) as Size, COUNT(*) 
from [dbo].[V_TheCompany_LNC_GoldStandard_Documents]
group by agreement_type, migfolder
order by COUNT(*) desc


select migfolder  + MigFolder_Sub
	, SUM([FileSize]) as Size
			, COUNT(*) 
from V_TheCompany_LNC_GoldStandard_Documents a
group by migfolder  + MigFolder_Sub
order by migfolder  + MigFolder_Sub

select migfolder 
	, SUM([FileSize]) as Size
			, COUNT(*) 
from V_TheCompany_LNC_GoldStandard_Documents a
group by migfolder 
order by migfolder

select migfolder, Contract_type, agreement_type, COUNT(*)
 from V_TheCompany_LNC_GoldStandard_documents
 where contract_type = 'MSA'
group by migfolder, Contract_type, agreement_type
order by migfolder, Contract_type, agreement_type

Services Agreement - Framework (MSA / FSA with associated Work Orders)
Supply Agreement

(case when contract_type = 'MSA' then '1_MSA'
	when contract_type = 'PRODUCT' then '2PRODUCT'
	when contract_type = 'Confidentiality' then 'Confidentiality'
	else 'OTHER' END)

select COUNT(*) from V_TheCompany_LNC_GoldStandard_Documents

select * from V_TheCompany_LNC_GoldStandard_Documents where MigFolder = 'other'

select migfolder
			, a.[AgrType_IsHCX_Flag]
			, a.[Agr_IsMaterial_Flag]	
			, a.[contractstatus] 
			, COUNT(*) 
from V_TheCompany_LNC_GoldStandard_Documents a
group by migfolder
			, a.[AgrType_IsHCX_Flag]
			, a.[Agr_IsMaterial_Flag]	
			, a.[contractstatus] 

				if OBJECT_ID('T_TheCompany_LNC_GoldStandard_Documents') is not null 
			drop table T_TheCompany_LNC_GoldStandard_Documents
			 select * into T_TheCompany_LNC_GoldStandard_Documents from V_TheCompany_LNC_GoldStandard_Documents  
	/*	, (case when A.statusid = 5 then 'ACTIVE'
				when a.Agr_IsMaterial_Flag = 1 then 'MATERIAL'
				when a.InactiveWithExpiryDateWithinLast2Yrs = 1 then '2YRS'
				ELSE 'OTHER'
				end) as MigFolder */
/* '2YRS' O:\Mig_FileShare\INACTIVE_Last2Yrs*/
	update f
	set FileType = filetype + '1'
	/* select FileType, filetype + '1' as filetypeapp, replace(filetype,'1','') as replace */
	/* select fileid */
	 from tfile f
	WHERE 
	fileid in (
		select FileID from V_TheCompany_VDOCUMENT 
		where OBJECTTYPEID = 1 /* contract */ 
			and MIK_VALID = 1
			and OBJECTID in (
			select CONTRACTID
					from V_TheCompany_LNC_GoldStandard_Documents 
					where MigFolder = '2YRS'
					)
					)

/* ACTIVE */

	update f
	set FileType = filetype + '1'
	/* select FileType, filetype + '1' as filetypeapp, replace(filetype,'1','') as replace */
	/* select fileid */
	 from tfile f
	WHERE 
	fileid in (
		select FileID from V_TheCompany_VDOCUMENT 
		where OBJECTTYPEID = 1 /* contract */ 
			and MIK_VALID = 1
			and OBJECTID in (
			select CONTRACTID
					from V_TheCompany_LNC_GoldStandard_Documents 
					where MigFolder = 'ACTIVE'
					)
					)

/* material */
	update f
	set FileType = filetype + '1'
	/* select FileType, filetype + '1' as filetypeapp, replace(filetype,'1','') as replace */
	/* select fileid */
	 from tfile f
	WHERE 
	fileid in (
		select FileID from V_TheCompany_VDOCUMENT 
		where OBJECTTYPEID = 1 /* contract */ 
			and MIK_VALID = 1
			and OBJECTID in (
			select CONTRACTID
					from V_TheCompany_LNC_GoldStandard_Documents 
					where MigFolder = 'MATERIAL'
					)
					)

/* AMENDMENT */
	update f
	set FileType = filetype + '1'
	/* select FileType, filetype + '1' as filetypeapp, replace(filetype,'1','') as replace */
	/* select fileid */
	 from tfile f
	WHERE 
	fileid in (
		select FileID from V_TheCompany_VDOCUMENT 
		where documentid in (
			select documentid
					from V_TheCompany_LNC_GoldStandard_Documents 
					where MigFolder = 'AMENDMENT'
					)	)

select distinct filetype from TFILE where FileType not like '%1%'

			update tfile
	set filetype = replace(filetype,'1','') /* e.g. '.pdf1' to '.pdf' */
	WHERE 
	filetype like '%1%'



			select fileid from tfile 
			WHERE filetype like '.%1'
/*
select COUNT(*) from V_TheCompany_VCONTRACT
select * from V_TheCompany_VCONTRACT where CONTRACTID not in (select CONTRACTID from T_TheCompany_ALL)
select COUNT(*) from T_TheCompany_ALL /*67238*/
select COUNT(*) from T_TheCompany_ALL_xt

select * from TCONTRACT where STRATEGYTYPEID is null
*/
end

select * from T_TheCompany_ALL_xt where Number = 'Case-00000785'
select * from TCONTRACT where contractNumber = 'Case-00000785'

update T_TheCompany_ALL set Title_InclTopSecret = 'Shareholder consent' where CONTRACTID = 103928

*/

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_ProductGroupDeactivateUnused]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
create procedure [dbo].[TheCompany_ProductGroupDeactivateUnused]

as 

BEGIN

	update tproductgroup
	set mik_valid = 0 
	  where productgroupid in (SELECT productgroupid
			FROM [TheVendor_app].[dbo].[V_TheCompany_VProductGroupIsUsed]
			where mik_valid = 1 and isused = 0)
	  and MIK_VALID = 1
	  and PRODUCTGROUPNOMENCLATUREID in (2,3)
  
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_ProductGroupUpload_ArchiveLogTable]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[TheCompany_ProductGroupUpload_ArchiveLogTable]

as 

BEGIN

	update tproductgroup
	set mik_valid = 0 
	  where productgroupid in (SELECT productgroupid
			FROM [TheVendor_app].[dbo].[V_TheCompany_VProductGroupIsUsed]
			where mik_valid = 1 and isused = 0)
	  and MIK_VALID = 1
	  and PRODUCTGROUPNOMENCLATUREID in (2,3)

	  insert into T_TheCompany_Product_Upload_History
	  select * from T_TheCompany_Product_Upload
	  where [Uploaded_DateTime] <  dateadd(dd,-14,GETDATE()) 

	  delete from T_TheCompany_Product_Upload
	  where [Uploaded_DateTime] <  dateadd(dd,-14,GETDATE()) 
	 
	/* select * into T_TheCompany_Product_Upload_History from T_TheCompany_Product_Upload 
	where [Uploaded_DateTime] <  dateadd(dd,-14,GETDATE()) */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_ProductGroupUpload_Description_ADHOC]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[TheCompany_ProductGroupUpload_Description_ADHOC]
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

DECLARE @PRODUCTGROUP AS VARCHAR(255)
DECLARE @CONTRACTNUMBER AS VARCHAR(20)
DECLARE @DESCRIPTION AS VARCHAR(255)
DECLARE @PRODUCTGROUP_LEFTBLANK AS VARCHAR(300)
DECLARE @PRODUCTGROUP_MID AS VARCHAR(300)
DECLARE @PRODUCTGROUP_RIGHTBLANK AS VARCHAR(300)
DECLARE @PRODUCTGROUPID SMALLINT
DECLARE @OBJECTID bigint 
DECLARE @SQLOBJECTIDS as VARCHAR (1000)
DECLARE @DATEREGISTERED as datetime

BEGIN

	DECLARE curProducts CURSOR LOCAL FAST_FORWARD FOR

	SELECT PRODUCTGROUPID, PRODUCTGROUP 
	FROM V_TheCompany_VPRODUCTGROUP 
	WHERE PRODUCTGROUPNOMENCLATUREID IN('2' /* AI */,'3','7' /* Project ID */) 
		/* AND MIK_VALID = 1 */
		and [blnNumHashes]<2 /* one hash or no hash */
		AND LEN(PRODUCTGROUP)>2 /* GEM to be included */ 
		and Productgroupid in (6491)

	OPEN curProducts

	FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
	WHILE @@FETCH_STATUS = 0 BEGIN

			SET @PRODUCTGROUP_RIGHTBLANK = @PRODUCTGROUP + '[^a-z]%' 

			SET @PRODUCTGROUP_MID = '%[^a-z]' + @PRODUCTGROUP + '[^a-z]%'

			SET @PRODUCTGROUP_LEFTBLANK = '%[^a-z]' + @PRODUCTGROUP


				PRINT 'Product Group: '  + @PRODUCTGROUP 
				PRINT @PRODUCTGROUPID
	
			IF EXISTS (
				SELECT 1
				FROM tcontract c 
				WHERE (c.CONTRACT like @PRODUCTGROUP_LEFTBLANK 
					OR c.CONTRACT like @PRODUCTGROUP_MID 
					OR c.CONTRACT like @PRODUCTGROUP_RIGHTBLANK)
				AND CONTRACTID NOT IN (SELECT contractid 
						from TPROD_GROUP_IN_CONTRACT 
						WHERE PRODUCTGROUPID = @PRODUCTGROUPID)
				AND CONTRACTTYPEID not in(/* '11' /*Case*/ */
											'6' /* Access */ /* 
											, '5' Test Old */ /* ,'102'Test New */
											,'13' /* DELETE */ 
											,'103' /*file*/
											,'104' /*corp file*/)
					AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!AUTODELETE')
					AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!ARIBA%')
				)
			
				BEGIN
	
				PRINT ' exists at least 1 record'
					/* sub loop contract upload */
				
					DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR

					SELECT @PRODUCTGROUPID AS PRD 
						, @PRODUCTGROUP AS PRDGRP 
						, CONTRACTID
						, c.contractnumber
						, c.contractdate
						, c.CONTRACT
					FROM tcontract c 
					WHERE (c.CONTRACT like @PRODUCTGROUP_LEFTBLANK 
								OR c.CONTRACT like @PRODUCTGROUP_MID 
								OR c.CONTRACT like @PRODUCTGROUP_RIGHTBLANK)
					AND CONTRACTTYPEID not in(/* '11' /*Case*/ */
												'6' /* Access */ /* 
												, '5' Test Old */ /* ,'102'Test New */
												,'13' /* DELETE */ 
												,'103' /*file*/
												,'104' /*corp file*/)
					AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!AUTODELETE')
					AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!ARIBA%')
					GROUP BY CONTRACTID, c.contractnumber, c.contractdate, c.contract

					OPEN curContracts
					
					FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @OBJECTID, @CONTRACTNUMBER, @DATEREGISTERED, @DESCRIPTION
					WHILE @@FETCH_STATUS = 0 BEGIN
						PRINT @PRODUCTGROUP
						PRINT @CONTRACTNUMBER
						PRINT @DESCRIPTION
							EXEC TheCompany_ProductGroupUpload_ObjectidProductgroupID @OBJECTID, @PRODUCTGROUPID, 1 /* OBJECTTYPEID */
							INSERT INTO T_TheCompany_Product_Upload ( PRODUCTGROUPID       
								   ,PRODUCTGROUP  
								   ,OBJECTID 
								   ,[CONTRACT_DESCRIPTION]
								   ,DOCTITLE         
								   ,CONTRACTNUMBER
								   ,DATEREGISTERED
								   , [Uploaded_DateTime]) 
							   VALUES (@PRODUCTGROUPID
								   , @PRODUCTGROUP
								   , @OBJECTID
								   , @DESCRIPTION
								   , '' /* DOCTITLE */
								   , @CONTRACTNUMBER
								   , @DATEREGISTERED
								   , GetDate())
			   
							FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @OBJECTID, @CONTRACTNUMBER, @DATEREGISTERED, @DESCRIPTION
					END
					/* loop 2 */
					CLOSE curContracts
					DEALLOCATE curContracts
	
			END
			ELSE PRINT 'No records for : '  + @PRODUCTGROUP

			FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
	END

		CLOSE curProducts
		DEALLOCATE curProducts
		SET @RESULTSTRING = 'Success'

	GOTO lblEnd

	lblTerminate: 
	PRINT '!!! Statement did not execute due to invalid input values!'


	lblEnd: 
	PRINT '*** END'



END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_ProductGroupUpload_Description_AdhocWrongSql]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[TheCompany_ProductGroupUpload_Description_AdhocWrongSql]
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

DECLARE @PRODUCTGROUP AS VARCHAR(255)
DECLARE @CONTRACTNUMBER AS VARCHAR(20)
DECLARE @DESCRIPTION AS VARCHAR(255)
DECLARE @PRODUCTGROUP_LEFTBLANK AS VARCHAR(300)
DECLARE @PRODUCTGROUP_MID AS VARCHAR(300)
DECLARE @PRODUCTGROUP_RIGHTBLANK AS VARCHAR(300)
DECLARE @PRODUCTGROUPID SMALLINT
DECLARE @OBJECTID bigint 
DECLARE @SQLOBJECTIDS as VARCHAR (1000)
DECLARE @DATEREGISTERED as datetime

BEGIN

DECLARE curProducts CURSOR LOCAL FAST_FORWARD FOR

select PRODUCTGROUPID, PRODUCTGROUP 
from TPRODUCTGROUP 
WHERE productgroupid = 6491
/* and Productgroupid in (6431) */

OPEN curProducts

FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
WHILE @@FETCH_STATUS = 0 BEGIN

		SET @PRODUCTGROUP_RIGHTBLANK = @PRODUCTGROUP + '[^a-z]%' 

		SET @PRODUCTGROUP_MID = '%[^a-z]' + @PRODUCTGROUP + '[^a-z]%'

		SET @PRODUCTGROUP_LEFTBLANK = '%[^a-z]' + @PRODUCTGROUP


			PRINT 'Product Group: '  + @PRODUCTGROUP 
			PRINT @PRODUCTGROUPID
	
		IF EXISTS (
			SELECT 1
			FROM tcontract c 
			WHERE (c.CONTRACT like @PRODUCTGROUP_LEFTBLANK 
				OR c.CONTRACT like @PRODUCTGROUP_MID 
				OR c.CONTRACT like @PRODUCTGROUP_RIGHTBLANK)
			AND CONTRACTID NOT IN (SELECT contractid 
					from TPROD_GROUP_IN_CONTRACT 
					WHERE PRODUCTGROUPID = @PRODUCTGROUPID)
			AND CONTRACTTYPEID not in(/* '11' /*Case*/ */
										'6' /* Access */ /* 
										, '5' Test Old */ /* ,'102'Test New */
										,'13' /* DELETE */ 
										,'103' /*file*/
										,'104' /*corp file*/)
				AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!AUTODELETE')
				AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!ARIBA%')
			)
			
			BEGIN
	
			PRINT ' exists at least 1 record'
				/* sub loop contract upload */
				
				DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR

				SELECT @PRODUCTGROUPID AS PRD 
					, @PRODUCTGROUP AS PRDGRP 
					, CONTRACTID
					, c.contractnumber
					, c.contractdate
					, c.CONTRACT
				FROM tcontract c 
				WHERE (c.CONTRACT like @PRODUCTGROUP_LEFTBLANK 
							OR c.CONTRACT like @PRODUCTGROUP_MID 
							OR c.CONTRACT like @PRODUCTGROUP_RIGHTBLANK)
				AND CONTRACTTYPEID not in(/* '11' /*Case*/ */
											'6' /* Access */ /* 
											, '5' Test Old */ /* ,'102'Test New */
											,'13' /* DELETE */ 
											,'103' /*file*/
											,'104' /*corp file*/)
				AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!AUTODELETE')
				AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!ARIBA%')
				GROUP BY CONTRACTID, c.contractnumber, c.contractdate, c.contract

				OPEN curContracts
					
				FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @OBJECTID, @CONTRACTNUMBER, @DATEREGISTERED, @DESCRIPTION
				WHILE @@FETCH_STATUS = 0 BEGIN
					PRINT @PRODUCTGROUP
					PRINT @CONTRACTNUMBER
					PRINT @DESCRIPTION
						EXEC TheCompany_ProductGroupUpload_ObjectidProductgroupID @OBJECTID, @PRODUCTGROUPID, 1 /* OBJECTTYPEID */
						INSERT INTO T_TheCompany_Product_Upload ( PRODUCTGROUPID       
							   ,PRODUCTGROUP  
							   ,OBJECTID 
							   ,[CONTRACT_DESCRIPTION]
							   ,DOCTITLE         
							   ,CONTRACTNUMBER
							   ,DATEREGISTERED
							   , [Uploaded_DateTime]) 
						   VALUES (@PRODUCTGROUPID
							   , @PRODUCTGROUP
							   , @OBJECTID
							   , @DESCRIPTION
							   , '' /* DOCTITLE */
							   , @CONTRACTNUMBER
							   , @DATEREGISTERED
							   , GetDate())
			   
						FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @OBJECTID, @CONTRACTNUMBER, @DATEREGISTERED, @DESCRIPTION
				END
				/* loop 2 */
				CLOSE curContracts
				DEALLOCATE curContracts
	
		END
		ELSE PRINT 'No records for : '  + @PRODUCTGROUP

		FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
END

	CLOSE curProducts
	DEALLOCATE curProducts
	SET @RESULTSTRING = 'Success'

GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'


lblEnd: 
PRINT '*** END'



END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_ProductGroupUpload_ObjectidProductgroupID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TheCompany_ProductGroupUpload_ObjectidProductgroupID](
                @OBJECTID bigint 
                ,@PRODUCTGROUPID bigint
                , @OBJECTTYPEID bigint
				, @PRODUCTGROUP  AS VARCHAR(255)
				, @DESCRIPTION AS VARCHAR(255)
				, @CONTRACTNUMBER AS VARCHAR(20)
				, @DATEREGISTERED as datetime
)
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)
DECLARE @CONTRACTID bigint

PRINT '********************** ([dbo].[TheCompany_ProductGroupUpload_ObjectidProductgroupID])'
PRINT '@OBJECTID = ' + STR(@OBJECTID)
PRINT '@PRODUCTGROUPID = ' + STR(@PRODUCTGROUPID)
PRINT '@OBJECTTYPEID = ' + STR(@OBJECTTYPEID) /* 1 = contract, 7 = document, 4 = Amendment */

/* Product Group Must Be Valid */

	IF NOT EXISTS ( SELECT  1
					FROM    dbo.tproductgroup
					WHERE   productgroupid = @PRODUCTGROUPID)

		BEGIN
			SET @RESULTSTRING = 'Product Group ID does not exist: ' + (CASE WHEN @PRODUCTGROUPID IS NULL THEN 'NULL' ELSE STR(@PRODUCTGROUPID) END)
			GOTO lblTerminate 
		END

/* Documents */		
	IF @OBJECTTYPEID = 7 /* document */ 
	AND NOT EXISTS ( SELECT  1
					FROM    dbo.tdocument
					WHERE   objectid = @OBJECTID)
		BEGIN
			SET @RESULTSTRING = 'DOCUMENT Object ID does not exist: ' + 
				(CASE WHEN @OBJECTID IS NULL THEN 'NULL' ELSE STR(@OBJECTID) END)
			GOTO lblTerminate 
		END

/* Contracts */	
	IF  @OBJECTTYPEID = 1 /* contract */ 
	AND NOT EXISTS ( SELECT  1
					FROM    dbo.tobjecttype
					WHERE   objecttypeid = @OBJECTTYPEID
					and OBJECTTYPEID in (1 /* contract *//* , 4  amendment */))
		BEGIN
			SET @RESULTSTRING = 'CONTRACT ObjecttypeID invalid or not supported (1=contract, or 4 = amendment): ' + (CASE WHEN @OBJECTTYPEID IS NULL THEN 'NULL' ELSE STR(@OBJECTTYPEID) END)
			GOTO lblTerminate 
		END

BEGIN

	if (@OBJECTTYPEID = 1 ) /* Contract */

		BEGIN /* @OBJECTTYPEID = 1 */
			IF EXISTS (SELECT 1 FROM TPROD_GROUP_IN_CONTRACT where 
						CONTRACTID = @OBJECTID
						AND productgroupid = @PRODUCTGROUPID)
					BEGIN
						SET @RESULTSTRING = 'Contract Record OBJECTID:' + STR(@OBJECTID) 
								+ ', PRODUCTGROUPID: ' + STR(@OBJECTID) + ' already exists, no action'
						GOTO lblNoChange
					END 
				
			INSERT INTO TPROD_GROUP_IN_CONTRACT values (@OBJECTID, @PRODUCTGROUPID)
			
			INSERT INTO T_TheCompany_Product_Upload ( PRODUCTGROUPID       
								   ,PRODUCTGROUP  
								   ,OBJECTID 
								   ,[CONTRACT_DESCRIPTION]
								   ,DOCTITLE         
								   ,CONTRACTNUMBER
								   ,DATEREGISTERED
								   , [Uploaded_DateTime]) 
							   VALUES (@PRODUCTGROUPID
								   , @PRODUCTGROUP
								   , @OBJECTID
								   , @DESCRIPTION
								   , '' /* DOCTITLE */
								   , @CONTRACTNUMBER
								   , @DATEREGISTERED
								   , GetDate())
				
				BEGIN
					SET @RESULTSTRING = 'Contract Record inserted successfully!'+
					(select contractnumber+': '+contract from tcontract
					where contractid = @objectid)
					GOTO lblEnd
				END
		END 

GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'
GOTO lblBlankLine

lblNoChange:
PRINT '--- Statement did not result in any changes'
GOTO lblBlankLine

lblEnd: 
PRINT '*** Record added Successfully'

lblBlankLine:
PRINT '     ' + @RESULTSTRING
PRINT CHAR(13) /* carriage return */

END

/* @OBJECTTYPEID = 1 */
		/* AMENDMENT - main procedure currently leaves out objecttype 4 on purpose - do not use, does not work right, incorrect IDs linked up */
	/* if (@OBJECTTYPEID = 4) /* Amendment */
	
		BEGIN /* @OBJECTTYPEID = 4 */
			IF EXISTS (SELECT 1 FROM TPROD_GROUP_IN_AMENDMENT where 
						AMENDMENTID = @OBJECTID
						AND productgroupid = @PRODUCTGROUPID)
				BEGIN
					SET @RESULTSTRING = 'AMD Record already exists, no action'
					PRINT @RESULTSTRING
					/* GOTO lblNoChange */
				END 
				
			INSERT INTO TPROD_GROUP_IN_AMENDMENT values (@OBJECTID, @PRODUCTGROUPID)
				
				BEGIN
					SET @RESULTSTRING = 'AMD Record inserted successfully'
					PRINT @RESULTSTRING
					/* GOTO lblEnd */
				END

				/* also do input for contract */
				set @CONTRACTID = (select contractid
									from tamendment 
									where amendmentid = @OBJECTID)
									PRINT 'AMD CONTRACTID FOR AMENDMENT IS ' + str(@CONTRACTID)
	/* @OBJECTTYPEID = 1 AND 4 - add to main contract if amendment has a hit */
					BEGIN 
					IF EXISTS (SELECT 1 FROM TPROD_GROUP_IN_CONTRACT c 
										WHERE c.contractid = @CONTRACTID
								AND productgroupid = @PRODUCTGROUPID)
							BEGIN
								SET @RESULTSTRING = 'AMD Contract Record CONTRACTID:' + STR(@CONTRACTID) 
										+ ', PRODUCTGROUPID: ' + STR(@OBJECTID) + ' already exists, no action'
								GOTO lblNoChange
							END 
					
					INSERT INTO TPROD_GROUP_IN_CONTRACT values (@CONTRACTID, @PRODUCTGROUPID)
				
						BEGIN
							SET @RESULTSTRING = 'Contract Record inserted successfully!'+
							(select contractnumber+': '+contract from tcontract
							where contractid = @objectid)
							GOTO lblEnd
						END
				END /* @OBJECTTYPEID = 1 in 4 Amendment */

		END /* @OBJECTTYPEID = 4  Amendment */ 
		*/
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_ProductGroupUpload_ObjectidProductgroupID_ARIBA]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_ProductGroupUpload_ObjectidProductgroupID_ARIBA](
                @CONTRACTNUMBER VARCHAR(50)
				, @CONTRACTINTERNALID VARCHAR(50)
                ,@PRODUCTGROUPID bigint
				, @SOURCENAME VARCHAR(255)
				, @MATCHLEVEL int
				/*, @DEBUG_BLN as bit */

)
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

PRINT '**********************'
PRINT '@CONTRACTNUMBER = ' + @CONTRACTNUMBER
PRINT '@PRODUCTGROUPID = ' + STR(@PRODUCTGROUPID)


/* Product Group Must Be Valid */

	IF NOT EXISTS ( SELECT  1
					FROM    dbo.tproductgroup
					WHERE   productgroupid = @PRODUCTGROUPID)

		BEGIN
			SET @RESULTSTRING = 'Product Group ID does not exist: ' + (CASE WHEN @PRODUCTGROUPID IS NULL THEN 'NULL' ELSE STR(@PRODUCTGROUPID) END)
			GOTO lblTerminate 
		END

/* Contracts */
		
IF NOT EXISTS ( SELECT  1
                FROM    T_TheCompany_AribaDump
                WHERE   CONTRACTNUMBER = @CONTRACTNUMBER)
	BEGIN
		SET @RESULTSTRING = 'CONTRACTNUMBER does not exist: ' + 
			(CASE WHEN @CONTRACTNUMBER IS NULL THEN 'NULL' ELSE @CONTRACTNUMBER END)
		GOTO lblTerminate 
	END
	

BEGIN

			IF EXISTS (SELECT 1 FROM T_TheCompany_Ariba_Products_In_Contracts where 
						CONTRACTNUMBER = @CONTRACTNUMBER
						AND productgroupid = @PRODUCTGROUPID)
					BEGIN
						SET @RESULTSTRING = 'Contract Record CONTRACTNUMBER:' + @CONTRACTNUMBER
								+ ', PRODUCTGROUPID: ' + STR(@PRODUCTGROUPID) + ' already exists, no action'
						GOTO lblNoChange
					END 
				
			INSERT INTO T_TheCompany_Ariba_Products_In_Contracts ([CONTRACTNUMBER],[CONTRACTINTERNALID],[PRODUCTGROUPID],[Source],[MatchLevel],[DateAdded]) 
								values (@CONTRACTNUMBER,@CONTRACTINTERNALID, @PRODUCTGROUPID, @SOURCENAME, @MATCHLEVEL,GetDate())
				
				BEGIN
					SET @RESULTSTRING = 'Contract Record inserted successfully!'+
					(select CONTRACTNUMBER + ': '+[Contract Description] from T_TheCompany_AribaDump
					where CONTRACTNUMBER = @CONTRACTNUMBER)
					GOTO lblEnd
				END


GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'
GOTO lblBlankLine

lblNoChange:
PRINT '--- Statement did not result in any changes'
GOTO lblBlankLine

lblEnd: 
PRINT '*** Record added Successfully'

lblBlankLine:
PRINT '     ' + @RESULTSTRING
PRINT CHAR(13) /* carriage return */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_ProductGroupUpload_ObjectidProductgroupID_JPSunrise]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_ProductGroupUpload_ObjectidProductgroupID_JPSunrise](
                @CONTRACTNUMBER VARCHAR(50)
				, @CONTRACTID int
                ,@PRODUCTGROUPID bigint
				, @SOURCENAME VARCHAR(255)
				, @MATCHLEVEL int
				/*, @DEBUG_BLN as bit */

)
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

PRINT '**********************'
PRINT '@CONTRACTNUMBER = ' + @CONTRACTNUMBER
PRINT '@PRODUCTGROUPID = ' + STR(@PRODUCTGROUPID)


/* Product Group Must Be Valid */

	IF NOT EXISTS ( SELECT  1
					FROM    dbo.tproductgroup
					WHERE   productgroupid = @PRODUCTGROUPID)

		BEGIN
			SET @RESULTSTRING = 'Product Group ID does not exist: ' + (CASE WHEN @PRODUCTGROUPID IS NULL THEN 'NULL' ELSE STR(@PRODUCTGROUPID) END)
			GOTO lblTerminate 
		END

/* Contracts */
		
IF NOT EXISTS ( SELECT  1
                FROM    [dbo].[T_TheCompany_ContractData_JP_Sunrise_ExecutedAgreements]
                WHERE   CONTRACTID = @CONTRACTID)
	BEGIN
		SET @RESULTSTRING = 'CONTRACTNUMBER does not exist: ' + 
			(CASE WHEN @CONTRACTNUMBER IS NULL THEN 'NULL' ELSE @CONTRACTNUMBER END)
		GOTO lblTerminate 
	END
	

BEGIN

			IF EXISTS (SELECT 1 FROM [dbo].[T_TheCompany_ContractData_JPSunrise_Products_In_Contracts] where 
						CONTRACTID = @CONTRACTID
						AND productgroupid = @PRODUCTGROUPID)
					BEGIN
						SET @RESULTSTRING = 'Contract Record CONTRACTNUMBER:' + @CONTRACTNUMBER
								+ ', PRODUCTGROUPID: ' + STR(@PRODUCTGROUPID) + ' already exists, no action'
						GOTO lblNoChange
					END 
				
			INSERT INTO  [dbo].[T_TheCompany_ContractData_JPSunrise_Products_In_Contracts]([CONTRACTID],[PRODUCTGROUPID],[Source],[MatchLevel],[DateAdded]) 
								values (@CONTRACTID, @PRODUCTGROUPID, @SOURCENAME, @MATCHLEVEL,GetDate())
				
				BEGIN
					SET @RESULTSTRING = 'Contract Record inserted successfully!'+
					(select CONTRACTNUMBER + ': '+[Name of Agreement] from [dbo].[T_TheCompany_ContractData_JP_Sunrise_ExecutedAgreements]
					where CONTRACTID = @CONTRACTID)
					GOTO lblEnd
				END


GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'
GOTO lblBlankLine

lblNoChange:
PRINT '--- Statement did not result in any changes'
GOTO lblBlankLine

lblEnd: 
PRINT '*** Record added Successfully'

lblBlankLine:
PRINT '     ' + @RESULTSTRING
PRINT CHAR(13) /* carriage return */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Reminders_Deactivate_ContractID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[TheCompany_Reminders_Deactivate_ContractID](
                  @CONTRACTID bigint
                /* , @XtPrefix as VARCHAR(255) /* Wave # 01 etc... !ARIBA_WXX */ */
                , @ExpiryDate as date /* e.g. 19 Dec 2017 for W1 */
)
AS

DECLARE @RESULTSTRING AS VARCHAR(255)

/* Contract ID must be valid */
	IF NOT EXISTS ( SELECT  1
					FROM    dbo.tcontract
					WHERE   Contractid = @CONTRACTID)
		BEGIN
			SET @RESULTSTRING = 'Contract ID does not exist: ' + (CASE WHEN @CONTRACTID IS NULL THEN 'NULL' ELSE STR(@CONTRACTID) END)
			GOTO lblTerminate 
		END

BEGIN

	/* TWARNING , review date only (maybe extend to all) */
		UPDATE TWARNING
			set ISACTIVE = 0
		WHERE 
			OBJECTID = @CONTRACTID
			AND ISACTIVE = 1 /* is never NULL */
		/* AND WARNINGFIELDNAME = 'REVIEWDATE' remove? we want all reminders gone */

	/* recurring reminders must also have recurrence info deleted */
	/* select * from twarning where objectid = 151058 */
		update twarning
		  set warningtypeid = 1 /* Single Date */
			, recurringnumber = null
			, recurringstart = null
			, RECURRENCEINTERVAL = null
			, recurrencexml = null
		where 
			OBJECTID = @CONTRACTID
			and warningtypeid = 3 /* recurring date */

			
	/* tperson_in_warning */

	/* select * from  tperson_in_warning where warningid in (select warningid from twarning w inner join TCONTRACT c on c.contractid = w.objectid
						WHERE w.OBJECTID = 151058) */

		/* ISTURNEDOFF */
		update tperson_in_warning
			set isturnedoff = 1 /* OFF */
		where 
			(isturnedoff = 0 /* ON */ 
				OR isturnedoff is null  /* ON */)
		AND warningid in (select warningid from twarning w inner join TCONTRACT c on c.contractid = w.objectid
						WHERE 
						w.OBJECTID = @CONTRACTID
						/* AND WARNINGFIELDNAME = 'REVIEWDATE' */)

	/* Turnedoffdate */
		update tperson_in_warning
			set turnedoffdate = @ExpiryDate /* getdate() */
		where 
			TURNEDOFFDATE is null
			and warningid in (select warningid 
								from twarning w inner join TCONTRACT c on c.contractid = w.objectid
								WHERE 
								w.OBJECTID = @CONTRACTID
								/* AND WARNINGFIELDNAME = 'REVIEWDATE' */)

	/* above is not enough - emailwarningflag too, and emailwarningsent ? H. Wagner received repeating reminder */

	/* EMAILWARNING flag */

	/* select * from tperson_in_warning 
	 where emailwarning = 1 and
	 warningid in (select warningid 
								from twarning w inner join TCONTRACT c on c.contractid = w.objectid
								WHERE 
								COUNTERPARTYNUMBER like '!ARIBA%'
								/* AND WARNINGFIELDNAME = 'REVIEWDATE' */) */
								 
		update tperson_in_warning
			set EMAILWARNING = 0 /* deactivated */
		where 
			emailwarning = 1
			AND warningid in (select warningid 
								from twarning w inner join TCONTRACT c on c.contractid = w.objectid
								WHERE 
								w.OBJECTID = @CONTRACTID)

	/* Emailwarningsent - better, EMAILWARNING = 0 */
	/*	update tperson_in_warning
			set EMAILWARNINGSENT = @ExpiryDate /* getdate() */
		where 
			EMAILWARNINGSENT is null
			and warningid in (select warningid 
								from twarning w inner join TCONTRACT c on c.contractid = w.objectid
								WHERE 
								w.OBJECTID = @CONTRACTID
								/* AND WARNINGFIELDNAME = 'REVIEWDATE' */) */

GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'
GOTO lblBlankLine

lblNoChange:
PRINT '--- Statement did not result in any changes'
GOTO lblBlankLine

lblEnd: 
PRINT '*** Record updated Successfully'

lblBlankLine:
PRINT '     ' + @RESULTSTRING
PRINT CHAR(13) /* carriage return */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Scheduled_Daily]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_Scheduled_Daily]

AS

DECLARE @JOBSTARTDATETIME as varchar(50)

BEGIN
/* status problems: manually run [dbo].[TheCompany_CORRECTION_STATUS] */

	SET @JOBSTARTDATETIME = CONVERT(VARCHAR(20), Getdate(), 113) /* if job runs more than once this stamp will identify which start belongs to which end */
	
	INSERT INTO T_TheCompany_JobLog values('Scheduled_Daily', getdate(),'SKIPPED' + @JOBSTARTDATETIME)

/*	INSERT INTO T_TheCompany_JobLog values('Scheduled_Daily', getdate(),'1_Start ' + @JOBSTARTDATETIME)
		
	INSERT INTO T_TheCompany_JobLog values('Scheduled_Daily', getdate(),'1b_HourlyJob ' + @JOBSTARTDATETIME) 
		
		EXEC TheCompany_Scheduled_Hourly /* while hourly job is deactivated on job runner */

	INSERT INTO T_TheCompany_JobLog values('Scheduled_Daily', getdate(),'2_TheCompany_0_DataLoad ' + @JOBSTARTDATETIME) 

		EXEC TheCompany_1DAILY_0DataLoad /* target completion time around 9 minutes */

	INSERT INTO T_TheCompany_JobLog values('Scheduled_Daily', getdate(),'3_TheCompany_0_EditDataLoad ' + @JOBSTARTDATETIME)

		EXEC TheCompany_1DAILY_0Edit_DataLoad

	INSERT INTO T_TheCompany_JobLog values('Scheduled_Daily', getdate(),'4_Permissions ' + @JOBSTARTDATETIME) 
		
		EXEC [dbo].[TheCompany_1DAILY_03DataLoad_KWS]

/* Auto Permissions */
 		EXEC TheCompany_1DAILY_AUTODELETE /* !AUTODELETE flag action */
		EXEC TheCompany_1DAILY_AUTODELETE_Deactivate_Reminders		
		EXEC TheCompany_1DAILY_AUTODELETE_RemovePermissions

		EXEC TheCompany_1DAILY_ConfidentialityFlag /* Confidential, Strictly Confidential, Top Secret Flags */

		EXEC TheCompany_1DAILY_ACL_AddMissingPermissions_AUTO
		EXEC TheCompany_1DAILY_ACL_AddRemoveAutoPermissions

		/* Public read permissions */
		EXEC TheCompany_1DAILY_PUBLIC_READ_Permissions

/* set strategytype to HCP if null for appropriate contract types */	
	
		EXEC TheCompany_2DAILY_UpdateStrategyTypeTakPhVertrieb

/* Sort Department fields */

		EXEC [TheCompany_2DAILY_AlphaSort_TDEPARTMENT]

	INSERT INTO T_TheCompany_JobLog values('Scheduled_Daily', getdate(),'9_End '+ @JOBSTARTDATETIME) 

END

/* User domain in title fields - deactivated because all is TheCompany now */

		/* use the title field to indicate a user's domain */
		/*	update p 
			set p.title = u.domainnetbiosusername + (CASE WHEN USERID IN
                             (SELECT        USERID
                               FROM            TUSER_IN_USERGROUP
                               WHERE        (USERGROUPID =
                                                             (SELECT        USERGROUPID
                                                               FROM            TUSERGROUP
                                                               WHERE        (USERGROUP = 'L-Shire')))) 
													THEN ' (L-Shire)' ELSE '' END)
			FROM Tperson p inner join Vuser as u 
				on p.personid = u.personid */
				/* where (p.title <> u.domainnetbiosusername or p.title is null)
				and u.DOMAINNETBIOSUSERNAME is not null */

				*/
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Scheduled_Hourly]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TheCompany_Scheduled_Hourly]
/* job now disabled again as of 07-Feb-19 because it could be that the job on the server 
	 daily job hourly and therefore we had issues */
AS

BEGIN

	INSERT INTO T_TheCompany_JobLog values('Sched_Hrly', getdate(),'0_Start_9End')
/*	/* due to a mess-up the hourly job ran the daily job hourly and we had to disable the hourly job
	it should be fixed and reenabled asap
	but in the meantime, this hourly job is run once a day via the scheduled_daily job */

		EXEC TheCompany_1HOURLY_CancelCheckoutAllPdfs /* run time 0 sec */
		/* to ensure that pdfs are not locked with a red padlock
		because checking out the document is the current default behaviour in the Windows client
		and people get a message that the file is locked when double clicking it
		and Irmgard cannot change the doucument property to 'archived' 
		Web viewer: issue is solved by not allowing checkouts for document type pdf 
		- unfortunately the same is not possible in Windows client*/

		EXEC TheCompany_1HOURLY_SetToAwarded_DeleteAwardedDate /* run time 0 sec */
		/* awarded date presence leads to funny errors when trying to add a date that is prior to the awarded date */
	
		/* TheCompany_489_NoReviewDateReminder no idea why this is commented out */

*/
	 INSERT INTO T_TheCompany_JobLog values('Sched_Hrly', getdate(),'9_End')

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Scheduled_Monthly]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_Scheduled_Monthly]

AS

BEGIN
	/* last run time on 6-Feb-19 was 26 seconds */

	INSERT INTO T_TheCompany_JobLog values('Scheduled_Monthly', getdate(),'SKIPPED') 
/*	INSERT INTO T_TheCompany_JobLog values('Scheduled_Monthly', getdate(),'0_Start') 
	EXEC [TheCompany_4MONTHLY_AlphaSort_TUSERGROUP] 
	/* EXEC [TheCompany_4MONTHLY_AlphaSort_TDEPARTMENT] now daily */
	EXEC [TheCompany_4MONTHLY_AlphaSort_AGREEMENT_TYPE]
	EXEC [TheCompany_4MONTHLY_DeleteDocsRecycleBin] /* CMA TheVendor script */
	EXEC MaintainSplitAuditTrail /* Coupa function to move all records older than 1 month to audit trail history */

		/* delete job log entries older than 60 days */
		DELETE FROM T_TheCompany_JobLog 
			WHERE (RunTime < GETDATE() - 30)

	INSERT INTO T_TheCompany_JobLog values('Scheduled_Monthly', getdate(),'9_End') 
*/
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Scheduled_SaturdayNight]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_Scheduled_SaturdayNight]

AS 

BEGIN
	/* the weekly table reindexing and update statistics also runs on weekends, we need to make sure it is not concurrent to this job */
	
	INSERT INTO T_TheCompany_JobLog values('Scheduled_SatNight', getdate(),'SKIPPED') 
/*	INSERT INTO T_TheCompany_JobLog values('Scheduled_SatNight', getdate(),'00_START') 
		EXEC TheCompany_3SATNIGHT_FlagNoFiles
		EXEC TheCompany_3SATNIGHT_RemapTT_AlphaToRegion
		EXEC TheCompany_3SATNIGHT_AddCurrentIP_ForActiveContracts
		EXEC TheCompany_3SATNIGHT_FlagBlank_CountryCityStreet
		EXEC TheCompany_3SATNIGHT_Reminders_Deactivate_ExpIntercompany /* deactivate reminders if contract has expiry date or is intercompany, or CDA */
		EXEC TheCompany_3SATNIGHT_AddDocumentTag_FullText

	INSERT INTO T_TheCompany_JobLog values('Scheduled_SatNight', getdate(),'01_ContractStatus') 

		EXEC TheCompany_3SATNIGHT_CorrectContractStatus

	INSERT INTO T_TheCompany_JobLog values('Scheduled_SatNight', getdate(),'06_FTxt_S') 
		
		EXEC [TheCompany_3SATNIGHT_PrdGrpUpload_CNT_FullText] /* dynavit */ /* takes about 5 min after revision and improvement */

	/* Description prod group upload moved from weekly to sat night due to long run time from 1 hr to 6 hrs */
	INSERT INTO T_TheCompany_JobLog values('Scheduled_SatNight', getdate(),'7_Prod_Desc') 

		EXEC TheCompany_3SATNIGHT_PrdGrpUpload_CNT_Description /* Last run time on 28-Oct-2018 was 1:10 */			
				
	INSERT INTO T_TheCompany_JobLog values('Scheduled_SatNight', getdate(),'08_FTxt_CNKT_E')

		EXEC [TheCompany_3SATNIGHT_PrdGrpUpload_ARB_Description]
		EXEC [TheCompany_3SATNIGHT_PrdGrpUpload_JPS_Description]

	INSERT INTO T_TheCompany_JobLog values('Scheduled_SatNight', getdate(),'08_FTxt_ARIBA_E')

	INSERT INTO T_TheCompany_JobLog values('Scheduled_SatNight', getdate(),'09_END') 
	*/
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Scheduled_Weekly]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_Scheduled_Weekly]

AS

BEGIN

	INSERT INTO T_TheCompany_JobLog values('Scheduled_Weekly', getdate(),'SKIPPED') 
/*	INSERT INTO T_TheCompany_JobLog values('Scheduled_Weekly', getdate(),'1Start') 
		EXEC TheCompany_2WEEKLY_Maintenance_AgreementTypes
		EXEC TheCompany_2WEEKLY_RemapTT_IPToTT
		EXEC TheCompany_2WEEKLY_HardcopyArchiving_DeleteTTEntries
		EXEC TheCompany_2WEEKLY_ReplaceUnderscoresWithDashes
		EXEC TheCompany_2WEEKLY_CompanyCleanup_TheCompanyIntercompany

		EXEC [TheCompany_2WEEKLY_RenameDTitleToCTitle]

/*	INSERT INTO T_TheCompany_JobLog values('Scheduled_Weekly', getdate(),'6_Prod_Desc') 

		EXEC TheCompany_2WEEKLY (now3SATNIGHT)_ProductGroupUpload_Description 		/* Last run time on 28-Oct-2018 was 1:10 */		MOVED due to 6:00:44 run time length on 03-Apr-2020
*/
	INSERT INTO T_TheCompany_JobLog values('Scheduled_Weekly', getdate(),'9_END') 
	*/
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_TablesColumnsAddNewItems]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_TablesColumnsAddNewItems]

AS

begin
/* find table */
select * from INFORMATION_SCHEMA.COLUMNS where [COLUMN_NAME] like '%eadin%'

	/* add new table */
	 insert into [dbo].[T_TheCompany_TheVendorTables] ([TblVwObjectID]
	, [TblVwName]
	, [TblVwComments]
	, [TblVwRelationship]
	, [TblVwBaseTableName]) 

	select distinct 
	objectid
		, tableviewname 
		, NULL /* comments */
		, NULL /* Relationship 1:1 etc. */
		, tableviewname /* [TblVwBaseTableName] */
	from V_TheCompany_TheVendorTablesColumns
	where tableviewname in (
		'TFILE'
		 ) 

	/* Add New Columns */
		insert into T_TheCompany_TheVendorTablesColumns
		( 
      [TableName]
      ,[ColumnName]
      ,[MigrateYN]
      ,[TVObjectID]
      ,[TVColumnID]
      ,[IsBlank]
      ,[ColComment]
      /*,[ColFieldID] */
		)
			select 
			 [TableViewName]
			, m.[ColumnName]
			, 1 /* include */
			,m.[ObjectID]
			, [ColumnID]
			, null /* is blank */
			, NULL /* col comment */
			/*, m.ColFieldID */
			from 
			[dbo].[V_TheCompany_TheVendorTablesColumns] m /* all tables */
			where m.objectid in (select [TblVwObjectID] from V_TheCompany_TheVendorTables)
			AND m.ObjectID not in (select TVobjectid from T_TheCompany_TheVendorTablesColumns )	

	/* update object ids */

	update c
	set [TVObjectID] = tc.[ObjectID]
	, [TVColumnID] = tc.[ColumnID]
	from [dbo].[T_TheCompany_TheVendorTablesColumns] c inner join 
	[dbo].[V_TheCompany_TheVendorTablesColumns] tc on C.[TableName] = tc.TableViewName 
	and c.columnname = tc.ColumnName
	where c.[TVObjectID] is null

	/* add sample values */

		SELECT DISTINCT 'SELECT MAX(CAST(' + column_name  /* MAX eliminates NULL values but we don't need those anyway */
		+ (case when character_maximum_length is not null then ' COLLATE SQL_Latin1_General_CP1_CI_AS ' ELSE '' END) + '  as varchar(255))), '''
		+ isc.table_name + '''  As TableName, '''  + isc.column_name + ''' As ColumnName, -1 AS IncludeFlag  FROM '
		+ isc.table_name + /*' WHERE ' + isc.column_name + IS NOT NULL*/ ' UNION ALL '
		FROM INFORMATION_SCHEMA.COLUMNS isc
		inner join V_TheCompany_TheVendorTablesColumns m on isc.TABLE_NAME = m.TableViewName
		inner join [dbo].[T_TheCompany_TheVendorTables] t on t.[TblVwName] = m.TableViewName
		left join [dbo].[T_TheCompany_TheVendorTablesColumns] c on isc.TABLE_NAME = c.tablename 
		and isc.COLUMN_NAME = C.[ColumnName]
		WHERE m.tableviewname in (
		'TTENDERER')
		/*
		where c.ValueTop1 is null */


	/* add into sample value table */
		INSERT INTO 
		T_TheCompany_TheVendorTablesColumns_SampleValue

		SELECT MAX(CAST(ADJUSTEDVALUEAMOUNTID  as varchar(255))), 'TTENDERER'  As TableName, 'ADJUSTEDVALUEAMOUNTID' As 
		ColumnName, -1 AS IncludeFlag  FROM TTENDERER 


	/* update column table with sample values for new colunmns */
		update t
		set t.[ValueTop1] = ts.[ValueTop1]
		from [dbo].[T_TheCompany_TheVendorTablesColumns] t inner join [dbo].[T_TheCompany_TheVendorTablesColumns_SampleValue] ts
		on t.[TableName] = ts.[TableName] and t.columnname = ts.ColumnName
		where t.[ValueTop1] is null and ts.[ValueTop1] is not null	

	
		delete from [dbo].[T_TheCompany_TheVendorTablesColumns_SampleValue]

		update [dbo].[T_TheCompany_TheVendorTablesColumns] set isblank = -1 where [ValueTop1] =''


/* gold std value */
		SELECT DISTINCT 'SELECT DISTINCT SUBSTRING(STUFF((SELECT DISTINCT '', '' + convert(varchar(255), ' 
		+ column_name  /* MAX eliminates NULL values but we don't need those anyway */
		+')'
		+ (case when character_maximum_length is not null then ' COLLATE SQL_Latin1_General_CP1_CI_AS ' 
			ELSE '' END) 
		+ ' FROM ' + isc.table_name + ' s WHERE s.'
		+ t.TblVwObject_FK + ' = d.'+ t.TblVwObject_FK 
		+ (CASE WHEN t.[TblVwOBJECTTYPEID] = 'OBJECTTYPEID' 
			THEN ' AND s.OBJECTTYPEID = d.OBJECTTYPEID ' ELSE '' END)
		+' FOR XML PATH('''')),1,1,''''),0,255) As ValGldStd, '''
		+ isc.table_name + '''  As TableName, '''  
		+ isc.column_name + ''' As ColumnName, -1 AS IncludeFlag  FROM '
		+ isc.table_name + /*' d WHERE ' + isc.column_name + IS NOT NULL*/ 
		+ ' d WHERE d.'+ t.TblVwObject_FK + ' = 148186 /* contractnumber = ''TEST-00000080'' */'
		+ ' UNION ALL '
		FROM INFORMATION_SCHEMA.COLUMNS isc
		inner join V_TheCompany_TheVendorTablesColumns m on isc.TABLE_NAME = m.TableViewName
		inner join [dbo].[V_TheCompany_TheVendorTables] t on t.[TblVwName] = m.TableViewName
		left join [dbo].[T_TheCompany_TheVendorTablesColumns] c on isc.TABLE_NAME = c.tablename 
		and isc.COLUMN_NAME = C.[ColumnName]
		/* WHERE m.tableviewname in (
		'TTENDERER') */
		WHERE c.ValueGoldStd is null
		

		 INSERT INTO 
		T_TheCompany_TheVendorTablesColumns_GoldStd	
		
SELECT DISTINCT SUBSTRING(STUFF((SELECT DISTINCT ', ' + convert(varchar(255), COUNTRY) COLLATE SQL_Latin1_General_CP1_CI_AS  
FROM VCONTRACT s WHERE s.CONTRACTID = d.CONTRACTID FOR XML PATH('')),1,1,''),0,255) As ValGldStd, 'VCONTRACT'  
As TableName, 'COUNTRY' As ColumnName, -1 AS IncludeFlag  FROM VCONTRACT d 
/* contractnumber = 'TEST-00000080' */ 


	/* update column table with sample values for new colunmns */
		update t
		set t.[ValueGoldStd] = LTRIM(ts.[ValueTopGst])
		from [dbo].[T_TheCompany_TheVendorTablesColumns] t inner join [dbo].[T_TheCompany_TheVendorTablesColumns_GoldStd] ts
		on t.[TableName] = ts.[TableName] and t.columnname = ts.ColumnName
		where t.[ValueGoldStd] is null and ts.[ValueTopGst] is not null	

		update t
		set t.[ValueGoldStd] = 'NULL'
		from [dbo].[T_TheCompany_TheVendorTablesColumns] t inner join [dbo].[T_TheCompany_TheVendorTablesColumns_GoldStd] ts
		on t.[TableName] = ts.[TableName] and t.columnname = ts.ColumnName
		where t.[ValueGoldStd] is null 
		
		delete from [dbo].[T_TheCompany_TheVendorTablesColumns_GoldStd]

		/* update [dbo].[T_TheCompany_TheVendorTablesColumns] set isblank = -1 where [ValueGoldStd] ='' */

	
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_TagUpload_DocumentID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_TagUpload_DocumentID](
                @TAGID bigint
				,@OBJECTTYPEID bigint /* 7 = Document */
				,@DOCUMENTID bigint   /* OBJECTID */
)
AS

/* Run Wrapper: TheCompany_3SATNIGHT_AddDocumentTag_FullText */

DECLARE @RESULTSTRING AS VARCHAR(255)

/* Product Group Must Be Valid */

	IF NOT EXISTS ( SELECT  1
					FROM    dbo.TTAG
					WHERE   tagid = @TAGID)

		BEGIN
			SET @RESULTSTRING = 'Tag ID does not exist: ' + (CASE WHEN @TAGID IS NULL 
				THEN 'NULL' 
				ELSE STR(@TAGID) 
				END)
			GOTO lblTerminate 
		END

/* Contracts */
		
IF NOT EXISTS ( SELECT  1
                FROM    dbo.tdocument
                WHERE   DOCUMENTID = @DOCUMENTID)
	BEGIN
		SET @RESULTSTRING = 'DOCUMENTID ID does not exist: ' + (CASE WHEN @DOCUMENTID IS NULL 
			THEN 'NULL' 
			ELSE STR(@DOCUMENTID) 
			END)
		GOTO lblTerminate 
	END

/*IF NOT EXISTS ( SELECT  1
                FROM    dbo.tobjecttype
                WHERE   objecttypeid = @OBJECTTYPEID)
	BEGIN
		SET @RESULTSTRING = 'ObjecttypeID invalid or not supported (7 = document: ' + (CASE WHEN @OBJECTTYPEID IS NULL THEN 'NULL' ELSE STR(@OBJECTTYPEID) END)
		GOTO lblTerminate 
	END */

IF EXISTS (SELECT 1 FROM TTAG_IN_OBJECT where 
						OBJECTID = @DOCUMENTID
						AND objecttypeid = @OBJECTTYPEID
						AND TAGID = @TAGID)
				BEGIN
					SET @RESULTSTRING = 'Tag Record already exists, no action'
					GOTO lblNoChange
				END 

PRINT 'check OBJECTID' + str(@DOCUMENTID)
PRINT 'OBJECTTYPEID' + str(@OBJECTTYPEID)
PRINT 'TAGID' + str(@TAGID)

BEGIN

	if (@OBJECTTYPEID = 7) /* 7 = Document , 1 = Contract */

		BEGIN /* @OBJECTTYPEID = 1 */

				
			INSERT INTO TTAG_IN_OBJECT (TAGID, OBJECTTYPEID, OBJECTID) 
			values (@TAGID, @OBJECTTYPEID, @DOCUMENTID)
				
				BEGIN
					SET @RESULTSTRING = 'Document tag Record inserted successfully'
					GOTO lblEnd
				END
		END /* @OBJECTTYPEID = 7 */
		

		
GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'
GOTO lblBlankLine

lblNoChange:
PRINT '--- Statement did not result in any changes'
GOTO lblBlankLine

lblEnd: 
PRINT '*** Record added Successfully'

lblBlankLine:
PRINT '     ' + @RESULTSTRING
PRINT CHAR(13) /* carriage return */

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_UTILITY_Remap_AgreementTypes]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[TheCompany_UTILITY_Remap_AgreementTypes]

as 

BEGIN

/* Instructions:
0. SQL Server, run this command: truncate table T_TheCompany_Remap_AgreementType
1. Access Adhoc DB: Paste data into Adhoc.accdb table tbl_AgreementTypeRemap_DataINPUT
2. Access Adhoc DB: Open qry_T_TheCompany_Remap_AgreementType for append script
2. Notepad: Remove quotation marks " with notepad from append script, replace with nothing
3. SQL Server: run append script to append rows
4. SQL Server: run this procedure
5. Access: qry_T_TheCompany_Remap_AgreementType_FINALCHECK shows results
*/


update r
set r.ContractIDInput = c.contractid
from T_TheCompany_Remap_AgreementType r inner join tcontract c 
on r.contractnumberinput = c.CONTRACTNUMBER
where r.ContractIDInput is null

update r 
set r.agreement_typeid_o = c.AGREEMENT_TYPEID
from T_TheCompany_Remap_AgreementType r inner join tcontract c 
on r.ContractIDInput = c.contractid
where r.agreement_typeid_o is null

update r 
set r.agreement_type_o = a.AGREEMENT_TYPE
from T_TheCompany_Remap_AgreementType r inner join TAGREEMENT_TYPE a 
on r.agreement_typeid_o = a.AGREEMENT_TYPEID
where r.agreement_type_o is null

update r 
set r.Agreement_TypeID_N = a.agreement_typeid
, r.Agreement_Type_N = a.AGREEMENT_TYPE
from T_TheCompany_Remap_AgreementType r inner join tagreement_type a 
on dbo.TheCompany_RemoveNonAlphaCharacters(r.agreementtypeinput_N) 
= dbo.TheCompany_RemoveNonAlphaCharacters(a.AGREEMENT_TYPE)
where (r.Agreement_TypeID_N is null or r.Agreement_TypeID_N <> a.agreement_typeid)

/* check */
select * from dbo.T_TheCompany_Remap_AgreementType
where ContractIDInput is null or Agreement_TypeID_N is null

/* update if check is ok */

update C
set c.agreement_typeid = r.Agreement_TypeID_N
from tcontract c inner join T_TheCompany_Remap_AgreementType r 
on c.contractid = r.contractidinput
where r.Agreement_TypeID_N is not null
and (c.AGREEMENT_TYPEID is null or c.AGREEMENT_TYPEID  <> r.Agreement_TypeID_N)

END



GO
/****** Object:  StoredProcedure [dbo].[TheCompany_VENDORSCRIPT_MaintenanceCheck_MissingACL]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[TheCompany_VENDORSCRIPT_MaintenanceCheck_MissingACL]

as

DECLARE	@ObjectTypeID	BIGINT,
		@UserId			BIGINT,
		@GroupId		BIGINT

SELECT	@ObjectTypeID	= OBJECTTYPEID	
FROM	TOBJECTTYPE
WHERE	FIXED = N'CONTRACT'

SELECT	@UserId	= USERID
FROM	TUSER
WHERE	USERINITIAL = 'systemservice'
		AND MIK_VALID = 1

IF	@@ROWCOUNT != 1 GOTO	ERROR_NO_USER

SELECT	@UserId	AS [systemservice user id]

SELECT	@GroupId	= USERGROUPID
FROM	TUSERGROUP
WHERE	FIXED = N'SYSTEMINTERNAL'

IF	@@ROWCOUNT != 1 GOTO	ERROR_NO_GROUP

SELECT @GroupId as [SYSTEM group Id]

SELECT	C.CONTRACTID,
		C.CONTRACTNUMBER	as [NUMBER-BEFORE], 
		P.PRIVILEGEID		as [MISSING-PRIVILEGE]
INTO	#t
FROM	TCONTRACT C 
		CROSS JOIN TPRIVILEGE P
WHERE	P.PRIVILEGEID IN (1,2)
		AND NOT EXISTS (	SELECT 1 
							FROM	TACL 
							WHERE	TACL.OBJECTID IS NOT NULL 
									AND TACL.OBJECTTYPEID = @ObjectTypeID 
									AND TACL.OBJECTID = C.CONTRACTID 
									AND TACL.PRIVILEGEID = P.PRIVILEGEID 
									AND (TACL.GROUPID = @GroupId OR TACL.USERID = @UserId)
									)

SELECT  *
FROM	#t

BEGIN TRAN

INSERT INTO	TACL(
	OBJECTTYPEID,
	OBJECTID,
	GROUPID,
	USERID,
	PRIVILEGEID,
	INHERITFROMPARENTOBJECT,
	PARENTOBJECTTYPEID,
	PARENTOBJECTID,
	NONHERITABLE)
SELECT	@ObjectTypeID,
		#t.CONTRACTID,
		@GroupId,
		NULL,
		#t.[MISSING-PRIVILEGE],
		0,
		NULL,
		NULL,
		0
FROM	#t

IF	@@ERROR != 0	GOTO	ERROR_INSERT

--	FOR READ
IF	NOT EXISTS(	SELECT	1
				FROM	TDEFAULTPRIVILEGE
				WHERE	OBJECTTYPEID = @ObjectTypeID
						AND [ACTION] = N'ONCREATE'
						AND GROUPID = @GroupId 
						AND ACTIVEROLE = 0
						AND ACTIVEUSER = 0
						AND PRIVILEGEID = 1	--READ
						)	BEGIN

	INSERT INTO	TDEFAULTPRIVILEGE(
		OBJECTTYPEID,         
		[ACTION]    ,                                         
		GROUPID     ,         
		ACTIVEROLE ,
		ACTIVEUSER ,
		PRIVILEGEID ,         
		INHERITFROMPARENTOBJECT, 
		PARENTOBJECTTYPEID   ,
		NONHERITABLE )
	SELECT			
		@ObjectTypeID,
		N'ONCREATE'    ,                                         
		@GroupId ,         
		0 ,
		0,
		1,         -- READ
		NULL, 
		NULL,
		0

	IF	@@ERROR != 0	GOTO	ERROR_INSERT
END
--	FOR WRITE
IF	NOT EXISTS(	SELECT	1
				FROM	TDEFAULTPRIVILEGE
				WHERE	OBJECTTYPEID = @ObjectTypeID
						AND [ACTION] = N'ONCREATE'
						AND GROUPID = @GroupId 
						AND ACTIVEROLE = 0
						AND ACTIVEUSER = 0
						AND PRIVILEGEID = 2	-- WRITE
						)	BEGIN

	INSERT INTO	TDEFAULTPRIVILEGE(
		OBJECTTYPEID,         
		[ACTION]    ,                                         
		GROUPID     ,         
		ACTIVEROLE ,
		ACTIVEUSER ,
		PRIVILEGEID ,         
		INHERITFROMPARENTOBJECT, 
		PARENTOBJECTTYPEID   ,
		NONHERITABLE )
	SELECT			
		@ObjectTypeID,
		N'ONCREATE'    ,                                         
		@GroupId ,         
		0 ,
		0,
		2,         -- WRITE
		NULL, 
		NULL,
		0

	IF	@@ERROR != 0	GOTO	ERROR_INSERT
END

COMMIT

SELECT	C.CONTRACTID,
		C.CONTRACTNUMBER	as [NUMBER-AFTER], 
		P.PRIVILEGEID		as [MISSING-PRIVILEGE]
FROM	TCONTRACT C 
		CROSS JOIN TPRIVILEGE P
WHERE	P.PRIVILEGEID IN (1,2)
		AND NOT EXISTS (	SELECT 1 
							FROM	TACL 
							WHERE	TACL.OBJECTID IS NOT NULL 
									AND TACL.OBJECTTYPEID = @ObjectTypeID 
									AND TACL.OBJECTID = C.CONTRACTID 
									AND TACL.PRIVILEGEID = P.PRIVILEGEID 
									AND (TACL.GROUPID = @GroupId OR TACL.USERID = @UserId)
									)
									
GOTO	THE_END

ERROR_INSERT:
	PRINT( 'ROLLBACK !!!')
	ROLLBACK
	GOTO	THE_END

ERROR_NO_USER:
	RAISERROR('There is no user [systemservice]',10,0)

	GOTO	THE_FINAL_END
	
ERROR_NO_GROUP:
	RAISERROR('There is no group [SYSTEMINTERNAL]',10,0)

	GOTO	THE_FINAL_END
	
THE_END:
	DROP TABLE	#t

THE_FINAL_END:
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_VENDORSCRIPT_RebuildIndicesStats]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*----------------------------------------------------------------------------*\
	DATE:	 21.01.2011
	PURPOSE: REBUILD ALL INDEXES ON TABLES AND INDEXED VIEWS, UPDATE STATISTICS INFORMATION	
	AUTHOR:  VITALIY KSENZHUK
\*----------------------------------------------------------------------------*/

CREATE procedure [dbo].[TheCompany_VENDORSCRIPT_RebuildIndicesStats]

as

/*----------------------------------------------------------------------------*\
	DATE:	 21.01.2011
	PURPOSE: REBUILD ALL INDEXES ON TABLES AND INDEXED VIEWS, UPDATE STATISTICS INFORMATION	
	AUTHOR:  VITALIY KSENZHUK
\*----------------------------------------------------------------------------*/
SET NOCOUNT ON
DECLARE @STMT NVARCHAR(4000)
DECLARE @TABLE NVARCHAR(1024)
DECLARE TABLES CURSOR FOR
SELECT '['+TABLE_SCHEMA+']'+'.'+'['+TABLE_NAME+']' FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME in('TheVendor_app', 'TheVendor_wf')
ORDER BY TABLE_NAME
OPEN TABLES
FETCH NEXT FROM TABLES INTO @TABLE
WHILE @@FETCH_STATUS = 0
BEGIN
BEGIN TRY
PRINT 'STARTING REINDEX ON TABLE:                           '+@TABLE
SET @STMT = 'ALTER INDEX ALL ON '+@TABLE+' REBUILD WITH (SORT_IN_TEMPDB = ON, STATISTICS_NORECOMPUTE = OFF)'
EXECUTE SP_EXECUTESQL @STMT
PRINT 'THE REINDEX OPERATION WAS SUCCESSFULL FOR TABLE : '+@TABLE
PRINT '----------------------------------------------------------'
END TRY
BEGIN CATCH
SELECT  'THE ERROR OCCURED:' AS MESSAGE, ERROR_NUMBER() AS ERROR_NUMBER, ERROR_MESSAGE() AS ERROR_MESSAGE
END CATCH
FETCH NEXT FROM TABLES INTO @TABLE
END
CLOSE TABLES
DEALLOCATE TABLES
SET NOCOUNT OFF
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_z_174_HourlySetWfUsersToActiveWhereUserActive]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create PROCEDURE [dbo].[TheCompany_z_174_HourlySetWfUsersToActiveWhereUserActive]


AS

/* Must be run until upgrading to V6.12 where the bug fix for this is included */

BEGIN

  update w
  set w.mik_valid = 1
  from [TheVendor_wf].[dbo].[TWorkflowUser] w 
  inner join  [TheVendor_app].[dbo].[TUSER] u on u.userid = w.externaluserid
  where u.mik_valid = 1 and w.mik_valid <>1

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_z2WEEKLY_ProductGroupUpload_Description_OLD]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[TheCompany_z2WEEKLY_ProductGroupUpload_Description_OLD]
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

DECLARE @PRODUCTGROUP AS VARCHAR(255)
DECLARE @CONTRACTNUMBER AS VARCHAR(20)
DECLARE @DESCRIPTION AS VARCHAR(255)
DECLARE @PRODUCTGROUP_LEFTBLANK AS VARCHAR(300)
DECLARE @PRODUCTGROUP_MID AS VARCHAR(300)
DECLARE @PRODUCTGROUP_RIGHTBLANK AS VARCHAR(300)
DECLARE @PRODUCTGROUPID SMALLINT
DECLARE @OBJECTID bigint 
DECLARE @SQLOBJECTIDS as VARCHAR (1000)
DECLARE @DATEREGISTERED as datetime

BEGIN

	DECLARE curProducts CURSOR LOCAL FAST_FORWARD FOR

	SELECT PRODUCTGROUPID, PRODUCTGROUP 
	FROM V_TheCompany_VPRODUCTGROUP 
	WHERE PRODUCTGROUPNOMENCLATUREID IN('2' /* AI */,'3','7' /* Project ID */) 
		/* AND MIK_VALID = 1 */
		and [blnNumHashes]<2 /* one hash or no hash */
		AND LEN(PRODUCTGROUP)>2 /* GEM to be included */ 
		/* and Productgroupid in (6431) */

	OPEN curProducts

	FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
	WHILE @@FETCH_STATUS = 0 BEGIN

			SET @PRODUCTGROUP_RIGHTBLANK = @PRODUCTGROUP + '[^a-z]%' 

			SET @PRODUCTGROUP_MID = '%[^a-z]' + @PRODUCTGROUP + '[^a-z]%'

			SET @PRODUCTGROUP_LEFTBLANK = '%[^a-z]' + @PRODUCTGROUP


				PRINT 'Product Group: '  + @PRODUCTGROUP 
				PRINT @PRODUCTGROUPID
	
			IF EXISTS (
				SELECT 1
				FROM tcontract c 
				WHERE (c.CONTRACT like @PRODUCTGROUP_LEFTBLANK 
					OR c.CONTRACT like @PRODUCTGROUP_MID 
					OR c.CONTRACT like @PRODUCTGROUP_RIGHTBLANK)
				AND CONTRACTID NOT IN (SELECT contractid 
						from TPROD_GROUP_IN_CONTRACT 
						WHERE PRODUCTGROUPID = @PRODUCTGROUPID)
				AND CONTRACTTYPEID not in(/* '11' /*Case*/ */
											'6' /* Access */ /* 
											, '5' Test Old */ /* ,'102'Test New */
											,'13' /* DELETE */ 
											,'103' /*file*/
											,'104' /*corp file*/)
					AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!AUTODELETE')
					AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!ARIBA%')
				)
			
				BEGIN
	
				PRINT ' exists at least 1 record'
					/* sub loop contract upload */
				
					DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR

					SELECT @PRODUCTGROUPID AS PRD 
						, @PRODUCTGROUP AS PRDGRP 
						, CONTRACTID
						, c.contractnumber
						, c.contractdate
						, c.CONTRACT
					FROM tcontract c 
					WHERE (c.CONTRACT like @PRODUCTGROUP_LEFTBLANK 
								OR c.CONTRACT like @PRODUCTGROUP_MID 
								OR c.CONTRACT like @PRODUCTGROUP_RIGHTBLANK)
					AND CONTRACTTYPEID not in(/* '11' /*Case*/ */
												'6' /* Access */ /* 
												, '5' Test Old */ /* ,'102'Test New */
												,'13' /* DELETE */ 
												,'103' /*file*/
												,'104' /*corp file*/)
					AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!AUTODELETE')
					AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!ARIBA%')
					GROUP BY CONTRACTID, c.contractnumber, c.contractdate, c.contract

					OPEN curContracts
					
					FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @OBJECTID, @CONTRACTNUMBER, @DATEREGISTERED, @DESCRIPTION
					WHILE @@FETCH_STATUS = 0 BEGIN
						PRINT @PRODUCTGROUP
						PRINT @CONTRACTNUMBER
						PRINT @DESCRIPTION
							EXEC TheCompany_ProductGroupUpload_ObjectidProductgroupID @OBJECTID, @PRODUCTGROUPID, 1 /* OBJECTTYPEID */
							INSERT INTO T_TheCompany_Product_Upload ( PRODUCTGROUPID       
								   ,PRODUCTGROUP  
								   ,OBJECTID 
								   ,[CONTRACT_DESCRIPTION]
								   ,DOCTITLE         
								   ,CONTRACTNUMBER
								   ,DATEREGISTERED
								   , [Uploaded_DateTime]) 
							   VALUES (@PRODUCTGROUPID
								   , @PRODUCTGROUP
								   , @OBJECTID
								   , @DESCRIPTION
								   , '' /* DOCTITLE */
								   , @CONTRACTNUMBER
								   , @DATEREGISTERED
								   , GetDate())
			   
							FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @OBJECTID, @CONTRACTNUMBER, @DATEREGISTERED, @DESCRIPTION
					END
					/* loop 2 */
					CLOSE curContracts
					DEALLOCATE curContracts
	
			END
			ELSE PRINT 'No records for : '  + @PRODUCTGROUP

			FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
	END

		CLOSE curProducts
		DEALLOCATE curProducts
		SET @RESULTSTRING = 'Success'

	GOTO lblEnd

	lblTerminate: 
	PRINT '!!! Statement did not execute due to invalid input values!'


	lblEnd: 
	PRINT '*** END'



END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_z2WEEKLY_ProductGroupUpload_Description_ProdNameOver6Char]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_z2WEEKLY_ProductGroupUpload_Description_ProdNameOver6Char]
AS

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

DECLARE @PRODUCTGROUP AS VARCHAR(255)
DECLARE @CONTRACTNUMBER AS VARCHAR(20)
DECLARE @DESCRIPTION AS VARCHAR(255)
DECLARE @PRODUCTGROUP_LEFTBLANK AS VARCHAR(300)
DECLARE @PRODUCTGROUP_MID AS VARCHAR(300)
DECLARE @PRODUCTGROUP_RIGHTBLANK AS VARCHAR(300)
DECLARE @PRODUCTGROUPID SMALLINT
DECLARE @OBJECTID bigint 
DECLARE @SQLOBJECTIDS as VARCHAR (1000)
DECLARE @DATEREGISTERED as datetime

BEGIN

DECLARE curProducts CURSOR LOCAL FAST_FORWARD FOR

select PRODUCTGROUPID, PRODUCTGROUP 
from V_TheCompany_VPRODUCTGROUP 
WHERE PRODUCTGROUPNOMENCLATUREID IN('2','3') 
AND ProductGroup_MIK_VALID = 1
and [blnNumHashes]<2 /* one hash or no hash */
AND LEN(PRODUCTGROUP)>6 /* GEM to be included */ 
/* and Productgroupid in (6431) */
 AND PRODUCTGROUP = 'Paracetamol'

OPEN curProducts

FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
WHILE @@FETCH_STATUS = 0 BEGIN

		SET @PRODUCTGROUP_RIGHTBLANK = @PRODUCTGROUP + '%' 

		SET @PRODUCTGROUP_MID = '%' + @PRODUCTGROUP + '%'

		SET @PRODUCTGROUP_LEFTBLANK = '%' + @PRODUCTGROUP


			PRINT 'Product Group: '  + @PRODUCTGROUP 
			PRINT @PRODUCTGROUPID
	
		IF EXISTS (
			SELECT 1
			FROM tcontract c 
			WHERE (c.CONTRACT like @PRODUCTGROUP_LEFTBLANK 
				OR c.CONTRACT like @PRODUCTGROUP_MID 
				OR c.CONTRACT like @PRODUCTGROUP_RIGHTBLANK)
			AND CONTRACTID NOT IN (SELECT contractid 
					from TPROD_GROUP_IN_CONTRACT 
					WHERE PRODUCTGROUPID = @PRODUCTGROUPID)
			AND CONTRACTTYPEID not in(/* '11' /*Case*/ */
										'6' /* Access */ /* 
										, '5' Test Old */ /* ,'102'Test New */
										,'13' /* DELETE */ 
										,'103' /*file*/
										,'104' /*corp file*/)
				AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!AUTODELETE')
				AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!ARIBA%')
			)
			
			BEGIN
	
			PRINT ' exists at least 1 record'
				/* sub loop contract upload */
				
				DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR

				SELECT @PRODUCTGROUPID AS PRD 
					, @PRODUCTGROUP AS PRDGRP 
					, CONTRACTID
					, c.contractnumber
					, c.contractdate
					, c.CONTRACT
				FROM tcontract c 
				WHERE (c.CONTRACT like @PRODUCTGROUP_LEFTBLANK 
							OR c.CONTRACT like @PRODUCTGROUP_MID 
							OR c.CONTRACT like @PRODUCTGROUP_RIGHTBLANK)
				AND CONTRACTTYPEID not in(/* '11' /*Case*/ */
											'6' /* Access */ /* 
											, '5' Test Old */ /* ,'102'Test New */
											,'13' /* DELETE */ 
											,'103' /*file*/
											,'104' /*corp file*/)
				AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!AUTODELETE')
				AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER <> '!ARIBA%')
				GROUP BY CONTRACTID, c.contractnumber, c.contractdate, c.contract

				OPEN curContracts
					
				FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @OBJECTID, @CONTRACTNUMBER, @DATEREGISTERED, @DESCRIPTION
				WHILE @@FETCH_STATUS = 0 BEGIN
					PRINT @PRODUCTGROUP
					PRINT @CONTRACTNUMBER
					PRINT @DESCRIPTION
						EXEC TheCompany_ProductGroupUpload_ObjectidProductgroupID @OBJECTID, @PRODUCTGROUPID, 1 /* OBJECTTYPEID */
						INSERT INTO T_TheCompany_Product_Upload ( PRODUCTGROUPID       
							   ,PRODUCTGROUP  
							   ,OBJECTID 
							   ,[CONTRACT_DESCRIPTION]
							   ,DOCTITLE         
							   ,CONTRACTNUMBER
							   ,DATEREGISTERED
							   , [Uploaded_DateTime]) 
						   VALUES (@PRODUCTGROUPID
							   , @PRODUCTGROUP
							   , @OBJECTID
							   , @DESCRIPTION
							   , '' /* DOCTITLE */
							   , @CONTRACTNUMBER
							   , @DATEREGISTERED
							   , GetDate())
			   
						FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @OBJECTID, @CONTRACTNUMBER, @DATEREGISTERED, @DESCRIPTION
				END
				/* loop 2 */
				CLOSE curContracts
				DEALLOCATE curContracts
	
		END
		ELSE PRINT 'No records for : '  + @PRODUCTGROUP

		FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
END

	CLOSE curProducts
	DEALLOCATE curProducts
	SET @RESULTSTRING = 'Success'

GOTO lblEnd

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'


lblEnd: 
PRINT '*** END'



END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_zHourly_zFlagNoFiles]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_zHourly_zFlagNoFiles] 

AS

BEGIN

print 'disabled'
 
/* 6 '*NO FILES*' Flag SEE TheCompany_319_FlagNoFiles */

/* 6a remove flag ' *NO FILES*' from contracts that have a document attached */

/*
	update [TCONTRACT]
	set [CONTRACT]=  RTRIM(REPLACE([CONTRACT], '*NO FILES*', '')) /* remove flag */
	where 
	[CONTRACT] LIKE ('%*NO FILES*%') /* has flag */
	AND [CONTRACT] NOT LIKE ('%DELETE (NO FILES FOR OVER 2 YEARS): %')
	AND CONTRACTID IN (SELECT OBJECTID from TDOCUMENT WHERE MIK_VALID = 1) /* has attachment */

	/* remove flag if AUTODELETE */
	update [TCONTRACT]
	set [CONTRACT]=  RTRIM(REPLACE([CONTRACT], '*NO FILES*', '')) /* remove flag */
	where 
	[CONTRACT] LIKE ('%*NO FILES*%') /* has flag */
	AND ([COUNTERPARTYNUMBER] = ('!AUTODELETE') /* autodelete */
		OR 	contracttypeid IN ('6' /*Access*/,'11'  /*Case*/, '13' /* DELETE */, '102' /* TEST */) 
		)

	
/* 6b add flag ' *NO FILES*' to contracts that have no document attached */

	update [TCONTRACT]
	set [CONTRACT]= [CONTRACT] +' *NO FILES*'
	where 
	[CONTRACT] NOT LIKE ('%*NO FILES*%') /* flag not already set */
	AND [CONTRACT] NOT LIKE ('%DELETE (NO FILES FOR OVER 2 YEARS): %')
	AND [CONTRACT] NOT LIKE ('%AUTODELETE%')
	AND CONTRACTID NOT IN (SELECT OBJECTID from TDOCUMENT) /* does not have attachment */
	AND LEN([CONTRACT] +' *NO FILES*') <=255 /* would not exceed field size */
	AND contracttypeid NOT IN ('6' /*Access*/,'11'  /*Case*/, '13' /* DELETE */, '102' /* TEST */) /* junk */
	and getdate() > dateadd(hh,+27,contractdate)   /* has been registered for more than 1 day */

/* 6c add flag ' *DELETE* *NO FILES*' to contracts that have no document attached */
	update [TCONTRACT]
	set [CONTRACT]= SUBSTRING('DELETE (NO FILES FOR OVER 2 YEARS): '+[CONTRACT],1,255)
	where 
	[CONTRACT] NOT LIKE ('%DELETE (NO FILES FOR OVER 2 YEARS): %') /* flag not already set */
	AND CONTRACTID NOT IN (SELECT OBJECTID from TDOCUMENT where MIK_VALID = 1) /* does not have attachment */
	AND contracttypeid NOT IN ('11' /*Case*/, '13' /* DELETE */, '102' /* TEST */)
	and getdate() > dateadd(yy,+2,contractdate)   /* has been registered for more than 2 years */

	/* AUTODELETE if older than 2 years */
		update [TCONTRACT]
		set [COUNTERPARTYNUMBER]= '!AUTODELETE'
		where 
		CONTRACTID NOT IN (SELECT OBJECTID from TDOCUMENT where MIK_VALID = 1) /* does not have attachment */
		AND contracttypeid = 12 /* Contract */
		and getdate() > dateadd(yy,+2,contractdate)   /* has been registered for more than 2 years */
		AND ([COUNTERPARTYNUMBER]<> '!AUTODELETE' 
				OR [COUNTERPARTYNUMBER] is null)
	*/			
END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_zOneTimeFix_479_AddNumberSeriesPrefix]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[TheCompany_zOneTimeFix_479_AddNumberSeriesPrefix]

as

BEGIN

/*Add number series Prefix to contract numbers so that ACL Uploader works and people can see to which number series the contracts belong - S. Joest 2014-Apr-28*/

/*Access*/

/*
UPDATE TCONTRACT 
SET CONTRACTNUMBER = 'Access-'+[CONTRACTNUMBER]
WHERE [CONTRACTTYPEID] = 6 /*Access*/
AND CONTRACTNUMBER LIKE '0%'

UPDATE TCONTRACTNUMBER 
SET CONTRACTNUMBER = 'Access-'+[CONTRACTNUMBER]
WHERE [CONTRACTTYPEID] = 6 /*Access*/
AND CONTRACTNUMBER LIKE '0%'
*/

/*NycoContract*/

UPDATE TCONTRACT 
SET CONTRACTNUMBER = 'NycoContract-'+[CONTRACTNUMBER]
WHERE [CONTRACTTYPEID] = 7 /*NycoContract*/
AND CONTRACTNUMBER LIKE '0%'

UPDATE TCONTRACTNUMBER 
SET CONTRACTNUMBER = 'NycoContract-'+[CONTRACTNUMBER]
WHERE [CONTRACTTYPEID] = 7 /*NycoContract*/
AND CONTRACTNUMBER LIKE '0%'

/*Nycomed*/

UPDATE TCONTRACT 
SET CONTRACTNUMBER = 'NycomedContract-'+[CONTRACTNUMBER]
WHERE [CONTRACTTYPEID] = 8 /*Nycomed*/
AND CONTRACTNUMBER LIKE '0%'

UPDATE TCONTRACTNUMBER 
SET CONTRACTNUMBER = 'Nycomed-'+[CONTRACTNUMBER]
WHERE [CONTRACTTYPEID] = 8 /*Nycomed*/
AND CONTRACTNUMBER LIKE '0%'

/* one time
UPDATE TCONTRACTNUMBER 
SET CONTRACTNUMBER = REPLACE([CONTRACTNUMBER],'Nycomed-','NycomedContract-')
WHERE [CONTRACTTYPEID] = 8 /*NycomedContract*/
AND CONTRACTNUMBER LIKE 'Nycomed-%' */

/*Yoda*/

UPDATE TCONTRACT 
SET CONTRACTNUMBER = 'Yoda-'+[CONTRACTNUMBER]
WHERE [CONTRACTTYPEID] = 100 /*Yoda*/
AND CONTRACTNUMBER LIKE '0%'

UPDATE TCONTRACTNUMBER 
SET CONTRACTNUMBER = 'Yoda-'+[CONTRACTNUMBER]
WHERE [CONTRACTTYPEID] = 100 /*Yoda*/
AND CONTRACTNUMBER LIKE '0%'

/*FranceContract*/

/* update tcontract already done */

UPDATE TCONTRACTNUMBER 
SET CONTRACTNUMBER = REPLACE([CONTRACTNUMBER],'TF-','FranceContract-')
WHERE [CONTRACTTYPEID] = 101 /*FranceContract*/
AND CONTRACTNUMBER LIKE 'TF-%'

END
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_zzz486_UpdatePdfFromPendingToCompleted]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_zzz486_UpdatePdfFromPendingToCompleted]

as

/* #361: Hardcopy Archiving Location - Delete Territory Entries */

BEGIN

/* 
UPDATE TDOCUMENT 
SET ARCHIVEID =  3 /* Completed */
WHERE ARCHIVEID = 1 /* Pending */
  AND DOCUMENTTYPEID = 1 /* Signed Contracts */
  and documentid in (SELECT DOCUMENTID FROM TFILEINFO WHERE fileType = '.pdf')
 */

UPDATE TDOCUMENT 
SET ARCHIVEID =  1 /* Signed / Fixed PENDING */
WHERE ARCHIVEID = 3 /* Completed */ 
  AND DOCUMENTTYPEID = 1 /* Signed Contracts */
  and documentid in (SELECT DOCUMENTID FROM TFILEINFO WHERE fileType = '.pdf')
END
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Amendment]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_Amendment]
as
select distinct
am.ContractID,
am.AmendmentId,
am.amendmentnumber as [Number (Amendment)],
am.amendment as [Description (Amendment)],
am.revision as [Revision (Amendment)],
am.referencenumber as [Reference number (Amendment)],
s.status as [Status (Amendment)],
cast(dateadd(hour, 12,am.datecreated) as date)   as [Date registered (Amendment)],
cast(dateadd(hour, 12,am.signeddate) as date) as [Signed date (Amendment)],
cast(dateadd(hour, 12,am.fromdate) as date) as [Start date (Amendment)],
cast(dateadd(hour, 12,am.todate) as date)as [End date (Amendment)],
datediff(dd,am.fromdate,am.todate) as [Duration in days (Amendment)],
l.mik_language as [Language (Amendment)],
round(ea.amount,0) as [Estimated value (Amendment)],
round(evc.amount,0) as [Estimated value (Display currency) (Amendment)],
ec.currency_code as [Estimated value currency (Amendment)],
round(aa.amount,0) as  [Value (Amendment)],
round(avc.amount,0) as [Value (Display currency) (Amendment)],
ac.currency_code as [Value currency (Amendment)],
am.comments as [Comments (Amendment)],
stuff((
select top 50 '; ' + gn.productgroupnomenclature + ': '+stuff((
	select top 50 ', ' + isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
	from tproductgroup g inner join tprod_group_in_amendment gc
	on g.productgroupid = gc.productgroupid
	where g.productgroupnomenclatureid = gn.productgroupnomenclatureid  and gc.amendmentid = am.amendmentid
    order by isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
from tproductgroupnomenclature gn
order by gn.productgroupnomenclature
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Product and service groups (Amendment)]
from tamendment am 
left join tlanguage l on am.languageid = l.languageid
left join tstatus s on   am.statusid = s.statusid
left join tamount ea on  am.estimatedamountid=ea.amountid
left join vamountindefaultcurrency evc on evc.amountid =ea.amountid
left join tcurrency ec   on ea.currencyid = ec.currencyid
left join tamount aa on  am.amountid=aa.amountid
left join vamountindefaultcurrency avc on avc.amountid =aa.amountid
left join tcurrency ac   on aa.currencyid = ac.currencyid
GO
/****** Object:  StoredProcedure [dbo].[usp_get_AssessmentTemplate]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_AssessmentTemplate]
as
select distinct description as [Template (Assessment)]  from  tcriterion_template
where 	criteriontemplateid > 0 
and 	description is not null and  description !='' and parentid is null
GO
/****** Object:  StoredProcedure [dbo].[usp_get_AssessmentTemplateGroup]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_AssessmentTemplateGroup]
as
select ASSESSMENTTEMPLATETYPE as [Template group (Assessment)]  from tassessmenttemplatetype
where 	assessmenttemplatetypeid > 0 and mik_valid > 0
and 	ASSESSMENTTEMPLATETYPE is not null and  ASSESSMENTTEMPLATETYPE !=''
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Company]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_Company]
as
;with parent_company_cte as (
  select companyid, parentcompanyid, company, 0 level, convert(nvarchar(4000), company) as path, companyid as root from tcompany where parentcompanyid is null
  union all
  select t.companyid, t.parentcompanyid, t.company, e.level + 1 as level, convert(nvarchar(4000),e.path + '\'+ convert(nvarchar(4000),t.company)) as path, e.root
  from parent_company_cte e
  join tcompany t on t.parentcompanyid=e.companyid
)
select
c.CompanyID,
cast(c.Company as nvarchar(4000)) as [Company (Company)],
cast(c.CompanyNo as nvarchar(4000)) as [Company number (Company)],
cast(c.ExternalNumber as nvarchar(4000)) as [External number (Company)],
cast(c.Dunsnumber as nvarchar(4000)) as [DUNS number (Company)],
(select top 1 cast(CompanyNo+' '+Company as nvarchar(4000)) from tcompany where companyid = c.ParentCompanyId) as [Parent company (Company)],
stuff((
select top 50 '; ' + gn.externalkey+'('+reg.companyregistry+')'
from tcompany_in_companyregistry gn inner join tcompanyregistry reg on gn.companyregistryid = reg.companyregistryid
where gn.companyid = c.companyid
order by gn.externalkey
for xml path(''), root('mystring'), type).value('/mystring[1]','nvarchar(4000)'), 1, 2, '')
as [Number in external system (Company)],
stuff((select '; '+isnull(companyno,'')+' '+company from tcompany where parentcompanyid = c.companyid order by companyno for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')  as [Child companies (Company)],
cast(pcte.path as nvarchar(4000)) as  [Path to top parent company (Company)],
cast(cur.currency_code as nvarchar(4000)) as [Default currency (Company)],
case when c.isVendor = 1 then N'Yes' else N'No'   end as [Is supplier (Company)],
case when c.isCustomer = 1 then N'Yes' else N'No' end as [Is customer (Company)],
case when c.isPartner = 1 then N'Yes' else N'No'  end as [Is partner (Company)],
case when c.isInternal = 1 then N'Yes' else N'No' end as [Is internal (Company)],
cast(dateadd(hour, 12,c.CreateDate) as date)  as [Date created (Company)],
cast(dateadd(mi, datediff(mi, getutcdate(), getdate()), c.ModifiedDate) as date)  as [Date modified (Company)],
stuff((
select top 50 '; ' + gn.productgroupnomenclature + ': '+stuff((
	select top 50 ', ' + isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
	from tproductgroup g inner join tprod_group_in_company gc
	on g.productgroupid = gc.productgroupid
	where g.productgroupnomenclatureid = gn.productgroupnomenclatureid  and gc.companyid = c.companyid
    order by isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
from tproductgroupnomenclature gn
order by gn.productgroupnomenclature
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Product and service groups (Company)],
(select cast(dateadd(hour, 12,max(con.awarddate)) as date) from tcontract con inner join ttenderer ten on con.contractid = ten.contractid and ten.isawarded =1 and ten.companyid = c.companyid) as [Date awarded last time (Company)],
(select count(distinct con.contractid) from tcontract con inner join ttenderer ten on con.contractid = ten.contractid and ten.isawarded =1 and ten.companyid = c.companyid) as [Number of awarded contracts (Company)],
(select count(distinct con.contractid) from tcontract con inner join ttenderer ten on con.contractid = ten.contractid and ten.isawarded =1 and ten.companyid = c.companyid inner join tstatus s on s.statusid= con.statusid and s.fixed in ('ACTIVE','UNASIGNED_ACTIVE')) as [Number of active contracts (Company)],
(select count(distinct con.contractid) from tcontract con inner join ttenderer ten on con.contractid = ten.contractid and ten.isawarded =1 and ten.companyid = c.companyid inner join tstatus s on s.statusid= con.statusid and s.fixed in ('EXPIRED')) as [Number of expired contracts (Company)],
(select count(distinct ten.contractid) from ttenderer ten  where ten.companyid = c.companyid and ten.contractid is not null ) +
(select count(distinct ten.rfxid) from ttenderer ten inner join trfx r on ten.rfxid=r.rfxid inner join trfxtype rt on r.rfxtypeid = rt.rfxtypeid and rt.fixed in ('RFP')
 where ten.companyid = c.companyid and ten.contractid is null ) as [Number of times as bidder(Company)],
(select count(distinct con.contractid) from tcontract con inner join ttenderer ten on con.contractid = ten.contractid and ten.isawarded=1 and ten.companyid <> c.companyid
 and exists (select * from ttenderer where contractid = ten.contractid and companyid = ten.companyid and isawarded <> 1) ) as [Number of contracts lost (Company)],
(select count(distinct bid.rfxid) from ttenderer bid inner join trfx r on bid.rfxid=r.rfxid inner join tstatus s on r.statusid = s.statusid and s.fixed in ('UNDERPREPARATION','AWAITINGVENDORRESPONSE','UNDERASSESSMENT','AWAITING_BID_OPENING') where bid.companyid = c.companyid)
 + (select count(distinct bid.rfxid) from trfxinterest bid inner join trfx r on bid.rfxid=r.rfxid inner join tstatus s on r.statusid = s.statusid and s.fixed in ('UNDERPREPARATION','AWAITINGVENDORRESPONSE','UNDERASSESSMENT','AWAITING_BID_OPENING') where bid.companyid = c.companyid)
 as [Number of ongoing RFxes (Company)],
 (select count(distinct v.vorid) from tvor v inner join ttenderer ten on v.contractid = ten.contractid where ten.isawarded=1 and ten.companyid = c.companyid ) as [Number of VORs (Company)],

--Estimated value of VORs (Company)
--Estimated value of VORs currency (Company)
--Estimated value of VORs (display currency) (Company)

--Number of unhandled VORs (Company)
--Estimated value of unhandled VORs (Company)
--Estimated value of unhandled VORs currency (Company)
--Estimated value of unhandled VORs (display currency) (Company)

--Number of disputed VORs (Company)
--Estimated value of disputed VORs (Company)
--Estimated value of disputed VORs currency (Company)
--Estimated value of disputed VORs (display currency) (Company)

--Number of handled VORs (Company)
--Estimated value of handled VORs (Company)
--Estimated value of handled VORs currency (Company)
--Estimated value of handled VORs (display currency) (Company)

--Estimated value of agreed VOs (Company)
--Estimated value of agreed VOs currency (Company)
--Estimated value of agreed VOs (display currency) (Company)

--Total commitment of active contracts (Company)
--Total commitment of active contracts currency (Company)
--Total commitment of active contracts (display currency) (Company)

--Total commitment of all contracts (Company)
--Total commitment of all contracts currency (Company)
--Total commitment of all contracts (display currency) (Company)

cast(((select count(distinct contractid) from ttenderer where isawarded = 1 and rfxid is not null and companyid = c.companyid)/(select nullif(count(distinct contractid),0) from ttenderer where rfxid is not null and companyid = c.companyid))*100 as decimal(38,2)) as [Contract win rate (%) (Company)],
round((select count(distinct v.vorid) from tvor v inner join ttenderer ten on v.contractid = ten.contractid where ten.isawarded=1 and ten.companyid = c.companyid )/(select nullif(count(distinct contractid),0) from ttenderer where isawarded = 1 and companyid = c.companyid),1) as [Average number of VORs per contract (Company)],
cast(((select count(distinct v.vorid) from tvor v inner join tvo vo on v.void=vo.void inner join ttenderer ten on v.contractid = ten.contractid  inner join tstatus s on vo.statusid = s.statusid and s.fixed = 'AGREED' where ten.isawarded=1 and ten.companyid = c.companyid )/(select nullif(count(distinct v.vorid),0) from tvor v inner join ttenderer ten on v.contractid = ten.contractid where ten.isawarded=1 and ten.companyid = c.companyid)) * 100  as decimal(38,2)) as [Agreed VORs in % (Company)],
cast(((select count(distinct v.vorid) from tvor v inner join tvo vo on v.void=vo.void inner join ttenderer ten on v.contractid = ten.contractid  inner join tstatus s on vo.statusid = s.statusid and s.fixed = 'DISPUTED' where ten.isawarded=1 and ten.companyid = c.companyid )/(select nullif(count(distinct v.vorid),0) from tvor v inner join ttenderer ten on v.contractid = ten.contractid where ten.isawarded=1 and ten.companyid = c.companyid)) * 100  as decimal(38,2)) as [Disputed VORs in % (Company)],
cast(((select count(distinct v.vorid) from tvor v inner join ttenderer ten on v.contractid = ten.contractid left join tvo vo on v.void=vo.void  where vo.void is null and ten.isawarded=1 and ten.companyid = c.companyid )/(select nullif(count(distinct v.vorid),0) from tvor v inner join ttenderer ten on v.contractid = ten.contractid where ten.isawarded=1 and ten.companyid = c.companyid)) * 100  as decimal(38,2)) as [Unhandled VORs in % (Company)],
(
select count(distinct a.assessmentid)  from tassessment a inner join tevaluationtype t on a.evaluationtypeid = t.evaluationtypeid 
where t.fixed = 'SUPPLIER_PERFORMANCE'
and a.ownerobjectid = c.companyid
and a.ownerobjecttypeid in (select objecttypeid from tobjecttype where fixed = 'COMPANY')
) as [Number of contractor performance assessments (Company)],
(
select count(distinct a.assessmentid)  from tassessment a inner join tevaluationtype t on a.evaluationtypeid = t.evaluationtypeid 
where t.fixed = 'TENDER_EVALUATION'
and a.ownerobjectid = c.companyid
and a.ownerobjecttypeid in (select objecttypeid from tobjecttype where fixed = 'COMPANY')
) as [Number of evaluations (Company)],
(
select count(distinct a.assessmentid)  from tassessment a inner join tevaluationtype t on a.evaluationtypeid = t.evaluationtypeid 
where t.fixed = 'TENDER_PREQUALIFICATION'
and a.ownerobjectid = c.companyid
and a.ownerobjecttypeid in (select objecttypeid from tobjecttype where fixed = 'COMPANY')
) as [Number of pre-qualifications (Company)],
stuff((
select top 50 '; ' + gn.productgroupnomenclature + ': '+stuff((
	select top 50 ', ' + isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
	from tproductgroup g inner join tprod_group_in_assessment gc
	on g.productgroupid = gc.productgroupid
	inner join tassessment a on a.assessmentid = gc.assessmentid
	inner join tevaluationtype t on a.evaluationtypeid = t.evaluationtypeid
	where g.productgroupnomenclatureid = gn.productgroupnomenclatureid 
	and a.ownerobjectid = c.companyid
	and a.ownerobjecttypeid in (select objecttypeid from tobjecttype where fixed = 'COMPANY')
	and a.qualified = 1
	and cast(dateadd(hour, 12,a.expiry_date) as date) > cast(getdate() as date)
	and t.fixed = 'TENDER_PREQUALIFICATION'
	order by isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
from tproductgroupnomenclature gn
order by gn.productgroupnomenclature
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Pre-qualified for product and service groups (Company)]
from tcompany c 
left join tcurrency cur on c.currencyid = cur.currencyid
left join parent_company_cte pcte on pcte.companyid = c.companyid
GO
/****** Object:  StoredProcedure [dbo].[usp_get_CompanyInContract]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_CompanyInContract]
as
select distinct companyid,contractid from ttenderer
where isawarded = 1 and contractid is not null
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Contract]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_Contract]
as
declare @ma_statusid int
set @ma_statusid = (select statusid from tstatus where fixed = N'AWARDED_TO_MULTIPLE')
declare @dislpay_currency nvarchar(20)
select @dislpay_currency= settingvalue  from tprofilesetting
where profilekeyid in (select profilekeyid  from tprofilekey where fixed = 'default_presentation_currency_code')
and userid is null
and usergroupid is null;
with vw_estimated_amount (contractid, Value, [Value currency],[Value (display currency)])
as
(
select 
co.contractid, 
round(a.Amount,0) as Value,
c.currency_code as [Value currency],
round(d.Amount,0) as [Value (display currency)]
from tcontract co
inner join tamount a
on a.amountid=co.estimatedvalueamountid
inner join tcurrency c
on a.currencyid=c.currencyid
inner join vamountindefaultcurrency d
on a.amountid=d.amountid
),
vw_Approved_budget (contractid, Value, [Value currency],[Value (display currency)])
as
(
select 
co.contractid, 
round(a.Amount,0) as Value,
c.currency_code as [Value currency],
round(d.Amount,0) as [Value (display currency)]
from tcontract co
inner join tamount a
on a.amountid=co.approvedvalueamountid
inner join tcurrency c
on a.currencyid=c.currencyid
inner join vamountindefaultcurrency d
on a.amountid=d.amountid
),
vw_LumpSum (contractid, Value, [Value currency],[Value (display currency)])
as
(
select 
co.contractid, 
round(a.Amount,0) as Value,
c.currency_code as [Value currency],
round(d.Amount,0) as [Value (display currency)]
from tcontract co
inner join tamount a
on a.amountid=co.LumpSumAmountid
inner join tcurrency c
on a.currencyid=c.currencyid
inner join vamountindefaultcurrency d
on a.amountid=d.amountid
),
vw_Invoiced (contractid, Value, [Value currency],[Value (display currency)])
as
(
select 
co.contractid, 
round(a.Amount,0) as Value,
c.currency_code as [Value currency],
round(d.Amount,0) as [Value (display currency)]
from tcontract co
inner join tamount a
on a.amountid=co.InvoicedValueAmountid
inner join tcurrency c
on a.currencyid=c.currencyid
inner join vamountindefaultcurrency d
on a.amountid=d.amountid
),
vw_ParentCompanyGuarantee (contractid, Value, [Value currency],[Value (display currency)])
as
(
select 
co.contractid, 
round(a.Amount,0) as Value,
c.currency_code as [Value currency],
round(d.Amount,0) as [Value (display currency)]
from tcontract co
inner join tamount a
on a.amountid=co.ParentCompanyGuaranteeAmountID
inner join tcurrency c
on a.currencyid=c.currencyid
inner join vamountindefaultcurrency d
on a.amountid=d.amountid
),
vw_Bankguarantee (contractid, Value, [Value currency],[Value (display currency)])
as
(
select 
co.contractid, 
round(a.Amount,0) as Value,
c.currency_code as [Value currency],
round(d.Amount,0) as [Value (display currency)]
from tcontract co
inner join tamount a
on a.amountid=co.BankGuaranteeAmountID
inner join tcurrency c
on a.currencyid=c.currencyid
inner join vamountindefaultcurrency d
on a.amountid=d.amountid
),
vw_SumOrders (contractid, Value, [Value currency],[Value (display currency)])
as
(
select o.contractid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(max(vc.SumApprovedOrders),0) as [Value (display currency)]
from tamount a inner join torder o on a.amountid=o.amountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =o.contractid
where 
o.statusid in (select statusid from tstatus where fixed in ('active', 'ordered', 'deliveredexpired'))
group by o.contractid
),
vw_SumVO (contractid, Value, [Value currency],[Value (display currency)])
as
(
select o.contractid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(max(vc.SumApprovedVO),0) as  [Value (display currency)]
from tamount a inner join tvo o on a.amountid=o.settlementamountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =o.contractid
where 
o.statusid not in (select statusid from tstatus where fixed in ('CANCELLED'))
group by o.contractid
),
vw_SumApprovedAmendments (contractid, Value, [Value currency],[Value (display currency)])
as
(
select o.contractid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(max(vc.SumApprovedAmendments),0) as [Value (display currency)]
from tamount a inner join TAMENDMENT o on a.amountid=o.AmountID
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =o.contractid
where 
o.statusid in (select statusid from tstatus where fixed in ('ACTIVE', 'SIGNED', 'EXPIRED'))
group by o.contractid
),
vw_SumOptionalExtentionAmount (contractid, Value, [Value currency],[Value (display currency)])
as
(
select o.contractid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(max(vc.SumOptionalExtentionAmount),0) as [Value (display currency)]
from tamount a inner join toption o on a.amountid=o.estimatedamountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =o.contractid
where 
o.declared =1
group by o.contractid
),
vw_SumNextOptionalExtentionAmount (contractid, Value, [Value currency],[Value (display currency)])
as
(
select o.contractid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(sum(d.amount),0) as [Value (display currency)]
from tamount a inner join toption o on a.amountid=o.estimatedamountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join tcontract ic  on ic.contractid = o.contractid
inner join vamountindefaultcurrency d
on a.amountid=d.amountid
where 
o.fromdate > ic.expirydate or o.fromdate > ic.rev_expirydate
group by o.contractid
),

vw_Reimb(contractid, Value, [Value currency],[Value (display currency)])
as
(
select 
co.contractid, 
round(a.Amount,0) as Value,
c.currency_code as [Value currency],
round(d.Amount,0) as [Value (display currency)]
from tcontract co
inner join tamount a
on a.amountid=co.ProvisionalSumAmountID
inner join tcurrency c
on a.currencyid=c.currencyid
inner join vamountindefaultcurrency d
on a.amountid=d.amountid
),
vw_InvCommit(contractid,[Value (display currency)])
as
(
select contractid,round(InvoiceableCommitment,0) as [Value (display currency)] from VCOMMERCIAL
),
vw_option (contractid, option_count)
as
(
select contractid, count(optionid) option_count from toption 
group by contractid
),
vw_option_declared (contractid,option_count)
as
(
select contractid, count(optionid) option_count from toption
where declared =1 
group by contractid
),
vw_option_notdeclared (contractid,enddate,option_count)
as
(
select contractid, max(todate),count(optionid) enddate from  toption
where declared =0 
group by contractid
),
vw_worklocation (contractid,worksite)
as
(
select contractid,
  stuff((
			   select '; '+worklocation from tworklocation
                inner join tworklocation_in_contract 
				on  tworklocation_in_contract.worklocationid = tworklocation.worklocationid
                where tworklocation_in_contract.contractid=tcontract.contractid    
				order by worklocation
     for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') 
	 as worksite from tcontract
),
vw_summary (contractid,heading,ingress,summarybody)
as
(
select contractid,heading,ingress,summarybody from tcontractsummary
),
vw_contract_info (contractid, comments, terminationperiod,terminationconditions,definedenddate,strategytype,language,prevcontractnumber,allowvorupload,currency_code,publish,supplier,[Counterpart contact],[Counterpart contact email],[Counterpart contact phone 1],[Counterpart contact phone 2],productgroups)
as
(
select
c.contractid,
c.comments,
c.terminationperiod,
c.terminationconditions,
c.definedenddate,
tstrategytype.strategytype,
tlanguage .mik_language as [language],
(select top 1 con.contractnumber  from tcontract con
 inner join tcontractnumber num 
 on con.contractid=num.prevcontractnumberid 
 where num.contractid = c.contractid 
) as prevcontractnumber,
allowvorupload,
currency_code,
publish,
stuff((
	select '; '+ com.company from ttenderer ten
	inner join tcompany com
	on ten.companyid = com.companyid
	where ten.isawarded = 1
	and 	ten.contractid in  
	(select ccc.contractid  from tcontract ccc  
	 where (ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	 or   ccc.contractid = c.contractid 
	 )
	order by com.company
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as supplier,
case 
when (select COUNT(COMPANYID) FROM TTENDERER TT where CONTRACTID = c.contractid and TT.ISAWARDED = 1) = 1
then
	stuff((
				   select '; '+ vcc.FirstName + ' '+vcc.LastName from ttenderer ten
				   inner join VCompanyContact vcc
				   on ten.companyid = vcc.companyid and ten.PRIMARYCOMPANYCONTACTID = vcc.CompanyContactID
		where ten.isawarded = 1
		and ten.contractid in 
		(select ccc.contractid  from tcontract ccc 
		  where ((ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	            or   ccc.contractid = c.contractid ))
		and ISNULL(ten.PRIMARYCOMPANYCONTACTID, -1) > 0
		order by vcc.company
	for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')

when (select COUNT(COMPANYID) FROM TTENDERER TT where CONTRACTID = c.contractid and TT.ISAWARDED = 1) = 0
then
stuff((
			   select '; '+ vcc.FirstName + ' '+vcc.LastName+' ('+vcc.company+')' from ttenderer ten
               inner join VCompanyContact vcc
			   on ten.companyid = vcc.companyid and ten.PRIMARYCOMPANYCONTACTID = vcc.CompanyContactID
		where ten.isawarded = 1 
		and ten.contractid in 
		(select ccc.contractid  from tcontract ccc  
		 where ((ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	            or   ccc.contractid = c.contractid ))
		        and ISNULL(ten.PRIMARYCOMPANYCONTACTID, -1) > 0
		
	order by vcc.company
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')

END [Counterpart contact],
case 
when (select COUNT(COMPANYID) FROM TTENDERER TT where CONTRACTID = c.contractid  and TT.ISAWARDED = 1) = 1
then
	stuff((
				   select '; ' + vcc.Email from ttenderer ten
				   inner join VCompanyContact vcc
				   on ten.companyid = vcc.companyid and ten.PRIMARYCOMPANYCONTACTID = vcc.CompanyContactID
		where ten.isawarded = 1
		and ten.contractid in 
		(select ccc.contractid  from tcontract ccc
		where ((ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	            or   ccc.contractid = c.contractid ))
		        and ISNULL(ten.PRIMARYCOMPANYCONTACTID, -1) > 0
				order by vcc.company
	for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')

when (select COUNT(COMPANYID) FROM TTENDERER TT where CONTRACTID = c.contractid and TT.ISAWARDED = 1) = 0
then
		stuff((
					   select '; ' + vcc.Email +' (' + vcc.company + ')' from ttenderer ten
					   inner join VCompanyContact vcc
					   on ten.companyid = vcc.companyid and ten.PRIMARYCOMPANYCONTACTID = vcc.CompanyContactID
			where ten.isawarded = 1
			and ten.contractid in
			(select ccc.contractid  from tcontract ccc
			 where ((ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	            or   ccc.contractid = c.contractid ))
			  and ISNULL(ten.PRIMARYCOMPANYCONTACTID, -1) > 0
			  order by vcc.company
		for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')

END [Counterpart contact email],
case 
when (select COUNT(COMPANYID) FROM TTENDERER TT where CONTRACTID = c.contractid  and TT.ISAWARDED = 1) = 1
then
stuff((
			   select '; ' + p.Phone1 from ttenderer ten
               inner join VCompanyContact vcc
			   on ten.companyid = vcc.companyid and ten.PRIMARYCOMPANYCONTACTID = vcc.CompanyContactID
			   inner join tperson p on vcc.PersonID = p.personid
    where ten.isawarded = 1
	and	ten.contractid in  
	(select ccc.contractid  from tcontract ccc
	where ((ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	            or   ccc.contractid = c.contractid ))
	and ISNULL(ten.PRIMARYCOMPANYCONTACTID, -1) > 0	
	order by vcc.company
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')

when (select COUNT(COMPANYID) FROM TTENDERER TT where CONTRACTID = c.contractid and TT.ISAWARDED = 1) = 0
then
stuff((
			   select '; ' + p.Phone1 +' (' + vcc.company + ')' from ttenderer ten
               inner join VCompanyContact vcc
			   on ten.companyid = vcc.companyid and ten.PRIMARYCOMPANYCONTACTID = vcc.CompanyContactID
			   inner join tperson p on vcc.PersonID = p.personid
    where ten.isawarded = 1
	and ten.contractid in
	  (select ccc.contractid  from tcontract ccc
	   where ((ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	            or   ccc.contractid = c.contractid ))
		and ISNULL(ten.PRIMARYCOMPANYCONTACTID, -1) > 0
	order by vcc.company
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')

END as [Counterpart contact phone1],

case 
when (select COUNT(COMPANYID) FROM TTENDERER TT where CONTRACTID = c.contractid  and TT.ISAWARDED = 1) = 1
then
stuff((
			   select '; ' + p.Phone2  from ttenderer ten
               inner join VCompanyContact vcc
			   on ten.companyid = vcc.companyid and ten.PRIMARYCOMPANYCONTACTID = vcc.CompanyContactID
			   inner join tperson p on vcc.PersonID = p.personid
    where ten.isawarded = 1
	and	ten.contractid in  
	(select ccc.contractid  from tcontract ccc 
	where ((ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	            or   ccc.contractid = c.contractid ))
		and ISNULL(ten.PRIMARYCOMPANYCONTACTID, -1) > 0
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')

when (select COUNT(COMPANYID) FROM TTENDERER TT where CONTRACTID = c.contractid and TT.ISAWARDED = 1) = 0
then
stuff((
			   select '; ' + p.PHONE2 +' (' + vcc.company + ')' from ttenderer ten
               inner join VCompanyContact vcc
			   on ten.companyid = vcc.companyid and ten.PRIMARYCOMPANYCONTACTID = vcc.CompanyContactID
			   inner join tperson p on vcc.PersonID = p.personid
    where ten.isawarded = 1
	and 	ten.contractid in  
	(select ccc.contractid  from tcontract ccc  
	where ((ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	            or   ccc.contractid = c.contractid ))
	and ISNULL(ten.PRIMARYCOMPANYCONTACTID, -1) > 0
	order by vcc.company
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')

END as [Counterpart contact phone2],
stuff((
select '; ' + gn.productgroupnomenclature + ': '+stuff((
	select ', ' + isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
	from tproductgroup g inner join tprod_group_in_contract gc
	on g.productgroupid = gc.productgroupid
	where g.productgroupnomenclatureid = gn.productgroupnomenclatureid  and gc.contractid = c.contractid
    order by isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
from tproductgroupnomenclature gn
order by gn.productgroupnomenclature
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as productgroups
from tcontract c
left join tstrategytype
on c.strategytypeid = tstrategytype.strategytypeid
left join tlanguage 
on tlanguage.languageid = c.languageid
left join tcurrency
on tcurrency.currencyid = c.currencyid
),
vw_project (contractid, projectname)
as
(
select	contractid,
stuff((
 			   select '; '+project from tproject
                inner join tcontract_in_project 
				on  tcontract_in_project.projectid = tproject.projectid
                where tcontract_in_project.contractid=tcontract.contractid    
				order by project
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as projectname from tcontract
)
select distinct
c.contractid as [ContractID],
c.contractnumber as [Number],
c.contract as [Description],
c.status as [Status],
CAST(DateAdd(hour, 12, c.startdate) as Date)  as [Start date],
CAST(DateAdd(hour, 12, c.expirydate) as Date)  as [Original end date],
CAST(DateAdd(hour, 12, c.revexpirydate) as Date)  as [New end date],
CAST(DateAdd(hour, 12,coalesce(c.revexpirydate,c.expirydate)) as Date)   as [Actual end date],
c.agreementtype as [Contract type],
c.contractrelation as [Contract relation],
c.ApprovalStatus as [Approval status],
CAST(DateAdd(hour, 12, c.AwardDate) as Date)  as [Awarded date],
c.Counterpartynumber as [Awarded counterpart/partner number],
c.lastchangedtime  as [Last edited],
c.lasttaskcompleted  as [Last task completed],
c.linkedtonumber as [Linked to number],
c.contracttype as [Number series],
c.referencenumber as [Reference number],
cast(cinfo.productgroups as nvarchar(4000)) as [Product and service groups],
CAST(DateAdd(hour, 12, c.contractdate) as Date)  as [Registered date],
CAST(DateAdd(hour, 12, c.reviewdate) as Date)  as [Review date],
CAST(DateAdd(hour, 12, c.signeddate) as Date)  as [Signed date],
c.country as [Awarded counterpart/partner country],
opnd.option_count  as [Number of remaining options],
opd.option_count as [Number of declared options],
cast(wl.worksite as nvarchar(4000))  as [Work or delivery site],
summ.heading as [Heading],
summ.ingress as [Ingress],
summ.summarybody as [Summary],
cinfo.strategytype as [Procedure],
cinfo.comments as [Comment],
cinfo.terminationperiod as [Term of notice (days)],
cinfo.terminationconditions as [Conditions for termination],
cinfo.Supplier as [Awarded counterpart/partner],
case 
when cinfo.definedenddate = 1 then N'Yes' 
when cinfo.definedenddate = 0 then N'No'
else null
end  as [Defined end date],
cast(p.projectname as nvarchar(4000)) as [Associated projects],
cinfo.language as [Language],
c.referencecontractnumber as [Previous number],
case
when c.sharedwithsupplier = 1 then N'Yes'
when c.sharedwithsupplier = 0 then N'No'
else null
end as [Shared with counterpart],
case 
when cinfo.allowvorupload = 1 then N'Yes'
when cinfo.allowvorupload = 0 then N'No'
else null 
end as [VOR handling through portal],
cinfo.currency_code as  [Default currency],
@dislpay_currency   as  [Display currency],
case 
when cinfo.publish = 1 then N'Yes'
when cinfo.publish = 0 then N'No'
else null
end as [Show on intranet (CIS)],
--Amounts
ea.[Value] as [Estimated amount],
ea.[Value currency] as [Estimated amount currency],
ea.[Value (display currency)] as [Estimated amount (display currency)],
ab.[Value] as [Approved budget],
ab.[Value currency] as [Approved budget currency],
ab.[Value (display currency)] as [Approved budget (display currency)],
ls.[Value] as [Lump sum],
ls.[Value currency] as [Lump sum currency],
ls.[Value (display currency)] as [Lump sum (display currency)],
i.[Value]  as [Invoiced value],
i.[Value currency] as [Invoiced value currency],
i.[Value (display currency)] as [Invoiced value (display currency)],
pcg.[Value] as [Parent company guarantee],
pcg.[Value currency] as [Parent company guarantee currency],
pcg.[Value (display currency)] as [Parent company guarantee (display currency)],
bg.[Value] as [Bank guarantee],
bg.[Value currency] as [Bank guarantee currency],
bg.[Value (display currency)] as [Bank guarantee (display currency)],
so.[Value] as [Sum of orders],
so.[Value currency] as [Sum of orders currency],
so.[Value (display currency)] as [Sum of orders (display currency)],
svo.[Value] as [Sum approved variation orders],
svo.[Value currency] as [Sum approved variation orders currency],
svo.[Value (display currency)] as [Sum approved variation orders (display currency)],
saa.[Value] as [Sum approved amendments],
saa.[Value currency] as [Sum approved amendments currency],
saa.[Value (display currency)] as [Sum approved amendments (display currency)],
(ISNULL(ls.[Value],0) +  ISNULL(saa.[Value],0) + ISNULL(svo.[Value],0) + ISNULL(soex.[Value],0) + ISNULL(re.[Value],0)) AS [Invoiceable commitment],
ls.[Value currency] as [Invoiceable commitment currency],
invc.[Value (display currency)] as [Invoiceable commitment (display currency)],
soex.[Value]    [Sum declared optional extensions],
soex.[Value currency] as [Sum declared optional extensions currency],
soex.[Value (display currency)] as [Sum declared optional extensions (display currency)],
snoe.[Value]  as  [Estimated value next option],
snoe.[Value currency] as [Estimated value next option currency],
snoe.[Value (display currency)] as [Estimated value next option (display currency)],
re.[Value]  as  [Reimbursible expense limit],
re.[Value currency] as [Reimbursible expense limit currency],
re.[Value (display currency)] as [Reimbursible expense limit (display currency)],
re.[Value]  as  [Original contract value],
re.[Value currency] as [Original contract value currency],
re.[Value (display currency)] as [Original contract value (display currency)],
cinfo.[Counterpart contact] as [Counterpart primary contact name],
cinfo.[Counterpart contact email] as [Counterpart primary contact email],
cinfo.[Counterpart contact phone 1] as [Counterpart primary contact phone 1],
cinfo.[Counterpart contact phone 2] as [Counterpart primary contact phone 2],
opnd.enddate as [End date next option]
from  vsearchsimplecontract c   
inner join vw_contract_info cinfo
on c.contractid = cinfo.contractid
left join vw_estimated_amount  ea
on c.contractid = ea.contractid
left join  vw_Approved_budget ab
on c.contractid = ab.contractid
left join vw_LumpSum ls
on  c.contractid = ls.contractid
left join vw_Invoiced i
on c.contractid = i.contractid
left join vw_ParentCompanyGuarantee pcg
on c.contractid = pcg.contractid
left join vw_Bankguarantee bg
on c.contractid = bg.contractid
left join vw_option op
on op.contractid = c.contractid
left join vw_option_declared opd
on opd.contractid = c.contractid
left join vw_worklocation wl
on wl.contractid = c.contractid
left join vw_summary summ
on summ.contractid = c.contractid
left join vw_project p
on p.contractid = c.contractid
left join  vw_SumOrders so
on so.contractid = c.contractid
left join vw_SumVO svo
on svo.contractid = c.contractid
left join vw_SumApprovedAmendments saa
on saa.contractid = c.contractid
left join vw_SumOptionalExtentionAmount soex
on soex.contractid=c.contractid
left join vw_Reimb re
on re.contractid=c.contractid
left join vw_InvCommit invc
on invc.contractid=c.contractid
left join vw_SumNextOptionalExtentionAmount snoe
on snoe.contractid=c.contractid
left join vw_option_notdeclared opnd
on opnd.contractid=c.contractid
GO
/****** Object:  StoredProcedure [dbo].[usp_get_ContractACL]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_ContractACL] 
as 
select ta.objectid as contractid,ta.userid,tu.domainnetbiosusername
from tacl ta (nolock)
inner join tuser tu
on  ta.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null
and tu.mik_valid = 1 
where 
ta.objecttypeid in (select tobjecttype.objecttypeid
                                    from   tobjecttype
                                    where  fixed = 'contract'
									)
and ta.privilegeid = 1
and ta.userid is not null
union 
select objectid as contractid,ug.userid,tu.domainnetbiosusername
from tacl ta (nolock)
inner join tuser_in_usergroup ug (nolock)
on ug.usergroupid = ta.groupid
inner join tuser tu
on ug.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null            
and tu.mik_valid = 1 
where 
ta.objecttypeid in (select tobjecttype.objecttypeid
                                    from   tobjecttype
                                    where  fixed = 'contract'
									)
and ta.privilegeid = 1
and ug.userid is not null
GO
/****** Object:  StoredProcedure [dbo].[usp_get_ContractInProject]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_ContractInProject]
as
select distinct contractid,projectid  from tcontract_in_project
GO
/****** Object:  StoredProcedure [dbo].[usp_get_ContractorPerformance]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_ContractorPerformance]
as
with cte_contract 
as 
(
select distinct t.contractid, t.companyid from ttenderer t 
inner join tcontract c on t.contractid = c.contractid 
inner join tstatus s on c.statusid=s.statusid 
where t.isawarded = 1 
and s.fixed not in ('AWARDED_TO_MULTIPLE') 
)
select distinct
a.AssessmentID as [ContractorPerformanceID],
ctec.companyid  as CompanyID,
ctec.contractid as ContractID,
ct.description as [Template (Contractor performance)],
(select description from tassessmentcriterion where assessmentid = a.assessmentid and criterionlevel = 0) as [Assessment name (Contractor performance)],
cast(a.assessmentdate as date)  as [Assessment date (Contractor performance)],
case 
when a.ownerobjecttypeid = 1 then (select isnull(contractnumber,'')+'-'+isnull(contract,'') from tcontract where contractid = a.ownerobjectid)
else null
end as [Contract (Contractor performance)],
a.comments as [Comment (Contractor performance)],
vab.minscore as [Min. score (Contractor performance)],
vab.MaxScore as [Max score (Contractor performance)],
vab.score [Score (Contractor performance)],
isnull(vu.firstname,'')+' '+isnull(vu.lastname,'') as [Owner (Contractor performance)],
s.status as  [Status (Contractor performance)],
att.assessmenttemplatetype as [Template group (Contractor performance)] 
from tassessment a
inner join tevaluationtype ev on a.evaluationtypeid = ev.evaluationtypeid and ev.fixed = N'SUPPLIER_PERFORMANCE'
inner join cte_contract ctec  on ctec.contractid = a.ownerobjectid
left join tstatus s on s.statusid = a.statusid
left join tassessmentcriterion ac on a.assessmentid = ac.assessmentid
left join vuser vu on a.userid_owner = vu.userid 
left join tassessment_template at on at.assessmenttemplateid = a.assessmenttemplateid
left join tassessmenttemplatetype att on att.assessmenttemplatetypeid = at.assessmenttemplatetypeid
left join vassessment_base vab on vab.assessmentid = a.assessmentid
left join tcriterion_template ct on ct.assessmenttemplateid = at.assessmenttemplateid  and ct.parentid is null
where a.ownerobjecttypeid in (select objecttypeid from tobjecttype where fixed in (N'Contract')) 
order by a.assessmentid
GO
/****** Object:  StoredProcedure [dbo].[usp_get_ContractRelation]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_ContractRelation]
as
select distinct contractrelation from Tcontractrelation
where contractrelationid > 0 and mik_valid > 0
and contractrelation is not null and contractrelation !=''
GO
/****** Object:  StoredProcedure [dbo].[usp_get_ContractType]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_ContractType]
as
select distinct agreement_type  as contracttype from tagreement_type
where 	agreement_typeid > 0 and mik_valid > 0
and 	agreement_type is not null and  agreement_type !=''
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Country]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_Country]
as
select distinct country  as 	country from tcountry
where 	countryid > 0 and mik_valid > 0
and 	country is not null and  country !=''
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Currency]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_Currency]
as
select distinct currency_code  as 	currencycode from tcurrency
where 	currencyid > 0 and mik_valid > 0
and 	currency_code is not null and  currency_code !=''
GO
/****** Object:  StoredProcedure [dbo].[usp_get_CustomProcess]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_CustomProcess]
as
select 
p.ContractID,
p.rprocessid as CustomProcessID,
pt.rprocesstype as  [Type (Custom process)],
p.rprocessnumber as [Number (Custom process)],
p.description as [Description (Custom process)],
p.comments as [Comments (Custom process)]
from trprocess p 
inner join trprocesstype pt on p.rprocesstypeid = pt.rprocesstypeid 
where p.mik_valid = 1 
GO
/****** Object:  StoredProcedure [dbo].[usp_get_CustomProcessACL]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_CustomProcessACL] 
as 
declare @Read bigint
select  @Read=privilegeid from tprivilege where privilege = N'Read'

select ta.objectid as CustomProcessid,ta.userid,tu.domainnetbiosusername
from tacl ta (nolock)
inner join tuser tu
on  ta.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null
and tu.mik_valid = 1 
where 
ta.objecttypeid in (select tobjecttype.objecttypeid
                                    from   tobjecttype
                                    where  fixed = N'RPROCESS'
									)
and ta.privilegeid = @Read
and ta.userid is not null
union 
select objectid as CustomProcessid,ug.userid,tu.domainnetbiosusername
from tacl ta (nolock)
inner join tuser_in_usergroup ug (nolock)
on ug.usergroupid = ta.groupid
inner join tuser tu
on ug.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null            
and tu.mik_valid = 1 
where 
ta.objecttypeid in (select tobjecttype.objecttypeid
                                    from   tobjecttype
                                    where  fixed = N'RPROCESS'
									)
and ta.privilegeid = @Read
and ug.userid is not null

--Inherit from contract
union
select r.rprocessid as CustomProcessid, ta.userid, tu.domainnetbiosusername from tacl ta (nolock)
inner join trprocess r 
on r.contractid = ta.objectid and ta.objecttypeid = 1 and ta.privilegeid = @Read and ta.nonheritable = 0
inner join tuser tu
on  ta.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null and tu.mik_valid = 1 
where 
exists (
        select aclid from tacl 
		where tacl.objectid =r.rprocessid
		and tacl.objecttypeid = (select objecttypeid from tobjecttype where fixed = 'RPROCESS') and privilegeid = 3 and 
		parentobjecttypeid =  1 and parentobjectid = r.contractid and inheritfromparentobject = 1
		) 
and ta.userid is not null
union 
select  r.rprocessid as CustomProcessid ,ug.userid,tu.domainnetbiosusername from tacl ta (nolock)
inner join trprocess r 
on r.contractid = ta.objectid and ta.objecttypeid = 1 and ta.privilegeid = @Read and ta.nonheritable = 0
inner join tuser_in_usergroup ug (nolock)
on ug.usergroupid = ta.groupid
inner join tuser tu
on ug.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null            
and tu.mik_valid = 1 
where 
exists (
        select aclid from tacl 
		where tacl.objectid =r.rprocessid
		and tacl.objecttypeid = (select objecttypeid from tobjecttype where fixed = 'RPROCESS') and privilegeid = 3 and 
		parentobjecttypeid =  1 and parentobjectid = r.contractid and inheritfromparentobject = 1
		) 
and ug.userid is not null
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Department]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_Department]
as
with depts (parentid, departmentid, mik_sequence, department_code, department, level, sortkey) 
as (
	select d.parentid, d.departmentid, d.mik_sequence, d.department_code, d.department, 0 as level, 
			replicate('0',10-len(cast(d.mik_sequence as nvarchar))) + cast(d.mik_sequence as nvarchar) as sortkey
	from   tdepartment d
	where  (d.mik_valid is null or d.mik_valid = 1) and d.parentid is null
    union all
	select d.parentid, d.departmentid, d.mik_sequence, d.department_code, d.department, level + 1,
			sortkey + '.' + replicate('0',10-len(cast(d.mik_sequence as nvarchar))) + cast(d.mik_sequence as nvarchar) as sortkey
	from   tdepartment d
	inner join depts on depts.departmentid = d.parentid
	where  d.mik_valid is null or d.mik_valid = 1
)
select d.departmentid as departmentid, d.department as department, d.department_code as code, d.parentid as parentid, depts.level
from depts
inner join tdepartment d on d.departmentid = depts.departmentid
order by depts.sortkey
GO
/****** Object:  StoredProcedure [dbo].[usp_get_DisputeType]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_DisputeType]
as
select distinct disputed_type  as disputetype from tdisputed_type
where 	disputed_typeid > 0 and mik_valid = 1 and disputed_type is not null

GO
/****** Object:  StoredProcedure [dbo].[usp_get_EvaluationContract]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_EvaluationContract]
as
select distinct
a.AssessmentID   as [EvaluationContractID],
a.ownerobjectid  as ContractID,
ct.description as [Template (Contract Evaluation)],
(select description from tassessmentcriterion where assessmentid = a.assessmentid and criterionlevel = 0) as [Assessment name (Contract Evaluation)],
cast(a.assessmentdate as date)  as [Assessment date (Contract Evaluation)],
(select isnull(contractnumber,'')+'-'+isnull(contract,'') from tcontract where contractid  = a.ownerobjectid) as [Contract (Contract Evaluation)],
a.comments as [Comment (Contract Evaluation)],
(select min(minscore) from vassessment_base where assessmentid = a.assessmentid) as [Min. score (Contract Evaluation)],
(select max(maxscore) from vassessment_base where assessmentid = a.assessmentid) as [Max score (Contract Evaluation)],
stuff((
	select top 50 '; '+isnull(company,'')+':'+isnull(cast(score as varchar(20)),'') from vassessment_base
	where assessmentid = a.assessmentid  and company is not null and score is not null order by isnull(company,'')
    for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, ''
	) as [Score (Contract Evaluation)],
isnull(vu.firstname,'')+' '+isnull(vu.lastname,'') as [Owner (Contract Evaluation)],
s.status as  [Status (Contract Evaluation)],
att.assessmenttemplatetype as [Template group (Contract Evaluation)] 
from tassessment a
inner join tevaluationtype ev on a.evaluationtypeid = ev.evaluationtypeid and ev.fixed = N'TENDER_EVALUATION'
left join tstatus s on s.statusid = a.statusid
left join tassessmentcriterion ac on a.assessmentid = ac.assessmentid
left join vuser vu on a.userid_owner = vu.userid 
left join tassessment_template at on at.assessmenttemplateid = a.assessmenttemplateid
left join tassessmenttemplatetype att on att.assessmenttemplatetypeid = at.assessmenttemplatetypeid
left join tcriterion_template ct on ct.assessmenttemplateid = at.assessmenttemplateid  and ct.parentid is null
where a.ownerobjecttypeid in (select objecttypeid from tobjecttype where fixed in (N'Contract')) 
and exists (select * from tcontract where contractid = a.ownerobjectid)
order by a.assessmentid
GO
/****** Object:  StoredProcedure [dbo].[usp_get_EvaluationRFx]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_EvaluationRFx]
as
select distinct
a.AssessmentID   as [EvaluationRFxID],
a.ownerobjectid  as RFxID,
ct.description as [Template (RFx Evaluation)],
(select description from tassessmentcriterion where assessmentid = a.assessmentid and criterionlevel = 0) as [Assessment name (RFx Evaluation)],
cast(a.assessmentdate as date)  as [Assessment date (RFx Evaluation)],
(select isnull(contractnumber,'')+'-'+isnull(contract,'') from tcontract where contractid in (select contractid from trfx where rfxid = a.ownerobjectid)) as [Contract (RFx Evaluation)],
a.comments as [Comment (RFx Evaluation)],
(select min(minscore) from vassessment_base where assessmentid = a.assessmentid) as [Min. score (RFx Evaluation)],
(select max(maxscore) from vassessment_base where assessmentid = a.assessmentid) as [Max score (RFx Evaluation)],
stuff((
	select top 50 '; '+isnull(company,'')+':'+isnull(cast(score as varchar(20)),'') from vassessment_base
	where assessmentid = a.assessmentid  and company is not null and score is not null order by isnull(company,'')
    for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, ''
	) as [Score (RFx Evaluation)],
isnull(vu.firstname,'')+' '+isnull(vu.lastname,'') as [Owner (RFx Evaluation)],
s.status as  [Status (RFx Evaluation)],
att.assessmenttemplatetype as [Template group (RFx Evaluation)] 
from tassessment a
inner join tevaluationtype ev on a.evaluationtypeid = ev.evaluationtypeid and ev.fixed = N'TENDER_EVALUATION'
left join tstatus s on s.statusid = a.statusid
left join tassessmentcriterion ac on a.assessmentid = ac.assessmentid
left join vuser vu on a.userid_owner = vu.userid 
left join tassessment_template at on at.assessmenttemplateid = a.assessmenttemplateid
left join tassessmenttemplatetype att on att.assessmenttemplatetypeid = at.assessmenttemplatetypeid
left join tcriterion_template ct on ct.assessmenttemplateid = at.assessmenttemplateid  and ct.parentid is null
where a.ownerobjecttypeid in (select objecttypeid from tobjecttype where fixed in (N'RFx')) 
and exists (select * from trfx where rfxid = a.ownerobjectid)
order by a.assessmentid
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Language]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_Language]
as
select distinct mik_language  as [language] from tlanguage
where 	languageid > 0 and mik_valid > 0
and 	mik_language  is not null and  mik_language  !=''
GO
/****** Object:  StoredProcedure [dbo].[usp_get_NumberSeries]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_NumberSeries]
as
select distinct contracttype  as NumberSeries from Tcontracttype
where contracttypeid > 0 and mik_valid > 0
and contracttype is not null and contracttype !=''
GO
/****** Object:  StoredProcedure [dbo].[usp_get_OptionalExtension]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_OptionalExtension]
as
select 
o.contractid as ContractID,
o.optionnumber as [Number (Option)],
o.optionname as [Description (Option)],
cast(dateadd(hour, 12, o.fromdate) as date) as [Start date (Option)],
cast(dateadd(hour, 12, o.todate) as date) as   [End date (Option)],
datediff(dd,o.fromdate,o.todate) as [Duration in days (Option)],
round(a.amount,0) as [Estimated value (Option)],
c.currency_code  as [Estimated value currency (Option)],
round(vc.Amount,0) as [Estimated value (Display currency) (Option)],
case
when o.declared = 1 then N'Yes'
else N'No'
end  as [Declared (Option)]
from toption o left join tamount a on a.amountid=o.estimatedamountid
left join tcurrency c   on a.currencyid = c.currencyid
left join vamountindefaultcurrency vc on vc.amountid =a.amountid
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Order]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_Order]
as
with vw_worklocation (orderid,worksite)
as
(
select orderid,
  stuff((
			   select top 50 '; '+worklocation from tworklocation
                inner join tworklocation_in_object
				on  tworklocation_in_object.worklocationid = tworklocation.worklocationid
                where tworklocation_in_object.objectid = orderid
				and   tworklocation_in_object.objecttypeid in (select objecttypeid from tobjecttype where fixed = 'Order')
				order by worklocation
     for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') 
	 as worksite from torder
),
vw_productgroup (orderid,productgroup)
as
(
select orderid,
stuff((
select top 50 '; ' + gn.productgroupnomenclature + ': '+stuff((
	select top 50 ', ' + isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
	from tproductgroup g inner join tproductgroup_in_object gino
	on g.productgroupid = gino.productgroupid
	where  gino.objectid = orderid	and   gino.objecttypeid in (select objecttypeid from tobjecttype where fixed = 'Order')
	       and 	g.productgroupnomenclatureid = gn.productgroupnomenclatureid  
    order by isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
from tproductgroupnomenclature gn
order by gn.productgroupnomenclature
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') as productgroup from torder
)
select 
o.ContractID,
o.OrderID,
ot.Ordertype as [Type (Order)],
o.OrderName as [Description (Order)],
o.OrderNumber as [Number (Order)],
o.OrderRevision as [Revision (Order)],
s.Status as [Status (Order)],
o.CounterPartyNumber as   [Counter party number (Order)],
o.Internalnumber as [Internal number (Order)],
o.Externalnumber as [External number (Order)],
pr.firstname+' '+pr.lastname as [Their representative (Order)],
pr.email as [Their representative email (Order)],
pr.phone1 as [Their representative phone 1 (Order)],
pr.phone2 as [Their representative phone 2 (Order)],
cast(dateadd(hour, 12, o.Createddate) as date)  as [Established date (Order)],
cast(dateadd(hour, 12, o.Orderdate)   as date)  as [Order date (Order)],
cast(dateadd(hour, 12, o.StartDate)   as date)  as [Start date (Order)],
cast(dateadd(hour, 12, o.Enddate)     as date)  as [End date (Order)],
cast(dateadd(hour, 12, o.Deliverbydate) as date) as [Deliverd by date (Order)],
round(a.amount,0)  as [Value (Order)],
round(vc.amount,0) as [Value (display currency) (Order)],
c.currency_code    as [Value currency (Order)],
cast(dateadd(hour, 12, o.Rateescalationdate) as date)   as [Rate escalation date (Order)],
cast(dateadd(hour, 12, o.Insuranceexpirydate) as date)  as [Insurance expiry date (Order)],
p.Project as [Project (Order)],
o.Scope as [Scope (Order)],
(select count(orderlineitemid) from torderlineitem where orderid = o.orderid) as [Line items count (Order)],
w.worksite as  [Work or delivery sites (Order)],
pg.productgroup as [Product and service groups (Order)],

stuff((
			   select top 50 '; '+cast(oo.ordernumber as nvarchar(50)) +' - ' +oo.ordername from torder oo
               inner join trfx r on oo.rfxid = r.rfxid 
               inner join trfxtype rt on r.rfxtypeid = rt.rfxtypeid and rt.fixed = 'mini_competition'
			   where oo.orderid = o.orderid
			   order by r.rfx
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') as [Linked mini-competition]
from torder o 
left join tordertype ot on o.ordertypeid = ot.ordertypeid
left join tstatus s on o.statusid = s.statusid 
left join tproject p on o.projectid = p.projectid 
left join  tamount a on  o.amountid =a.amountid
left join  vamountindefaultcurrency vc on vc.amountid =a.amountid
left join  tcurrency c   on a.currencyid = c.currencyid
left join  vw_worklocation w on w.orderid = o.orderid
left join  vw_productgroup pg on pg.orderid = o.orderid
left join  tcompanycontact cc on cc.companycontactid = o.companycontactid
left join  tperson pr on pr.personid = cc.personid
where o.mik_valid = 1
GO
/****** Object:  StoredProcedure [dbo].[usp_get_OrderType]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_OrderType]
as
select distinct ordertype  from tordertype
where 	ordertypeid > 0 and mik_valid = 1 and ordertype is not null

GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase0_Contract]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_Phase0_Contract]
as
declare @ma_statusid int
set @ma_statusid = (select statusid from tstatus where fixed = N'AWARDED_TO_MULTIPLE')
declare @dislpay_currency nvarchar(20)
select @dislpay_currency= settingvalue  from tprofilesetting
where profilekeyid in (select profilekeyid  from tprofilekey where fixed = 'default_presentation_currency_code')
and userid is null
and usergroupid is null;
with vw_estimated_amount (contractid, Value, [Value currency],[Value (display currency)])
as
(
select 
co.contractid, 
round(a.Amount,0) as Value,
c.currency_code as [Value currency],
round(d.Amount,0) as [Value (display currency)]
from tcontract co
inner join tamount a
on a.amountid=co.estimatedvalueamountid
inner join tcurrency c
on a.currencyid=c.currencyid
inner join vamountindefaultcurrency d
on a.amountid=d.amountid
),
vw_Approved_budget (contractid, Value, [Value currency],[Value (display currency)])
as
(
select 
co.contractid, 
round(a.Amount,0) as Value,
c.currency_code as [Value currency],
round(d.Amount,0) as [Value (display currency)]
from tcontract co
inner join tamount a
on a.amountid=co.approvedvalueamountid
inner join tcurrency c
on a.currencyid=c.currencyid
inner join vamountindefaultcurrency d
on a.amountid=d.amountid
),
vw_LumpSum (contractid, Value, [Value currency],[Value (display currency)])
as
(
select 
co.contractid, 
round(a.Amount,0) as Value,
c.currency_code as [Value currency],
round(d.Amount,0) as [Value (display currency)]
from tcontract co
inner join tamount a
on a.amountid=co.LumpSumAmountid
inner join tcurrency c
on a.currencyid=c.currencyid
inner join vamountindefaultcurrency d
on a.amountid=d.amountid
),
vw_Invoiced (contractid, Value, [Value currency],[Value (display currency)])
as
(
select 
co.contractid, 
round(a.Amount,0) as Value,
c.currency_code as [Value currency],
round(d.Amount,0) as [Value (display currency)]
from tcontract co
inner join tamount a
on a.amountid=co.InvoicedValueAmountid
inner join tcurrency c
on a.currencyid=c.currencyid
inner join vamountindefaultcurrency d
on a.amountid=d.amountid
),
vw_ParentCompanyGuarantee (contractid, Value, [Value currency],[Value (display currency)])
as
(
select 
co.contractid, 
round(a.Amount,0) as Value,
c.currency_code as [Value currency],
round(d.Amount,0) as [Value (display currency)]
from tcontract co
inner join tamount a
on a.amountid=co.ParentCompanyGuaranteeAmountID
inner join tcurrency c
on a.currencyid=c.currencyid
inner join vamountindefaultcurrency d
on a.amountid=d.amountid
),
vw_Bankguarantee (contractid, Value, [Value currency],[Value (display currency)])
as
(
select 
co.contractid, 
round(a.Amount,0) as Value,
c.currency_code as [Value currency],
round(d.Amount,0) as [Value (display currency)]
from tcontract co
inner join tamount a
on a.amountid=co.BankGuaranteeAmountID
inner join tcurrency c
on a.currencyid=c.currencyid
inner join vamountindefaultcurrency d
on a.amountid=d.amountid
),
vw_SumOrders (contractid, Value, [Value currency],[Value (display currency)])
as
(
select o.contractid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(max(vc.SumApprovedOrders),0) as [Value (display currency)]
from tamount a inner join torder o on a.amountid=o.amountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =o.contractid
where 
o.statusid in (select statusid from tstatus where fixed in ('active', 'ordered', 'deliveredexpired'))
group by o.contractid
),
vw_SumVO (contractid, Value, [Value currency],[Value (display currency)])
as
(
select o.contractid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(max(vc.SumApprovedVO),0) as  [Value (display currency)]
from tamount a inner join tvo o on a.amountid=o.settlementamountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =o.contractid
where 
o.statusid not in (select statusid from tstatus where fixed in ('CANCELLED'))
group by o.contractid
),
vw_SumApprovedAmendments (contractid, Value, [Value currency],[Value (display currency)])
as
(
select o.contractid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(max(vc.SumApprovedAmendments),0) as [Value (display currency)]
from tamount a inner join TAMENDMENT o on a.amountid=o.AmountID
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =o.contractid
where 
o.statusid in (select statusid from tstatus where fixed in ('ACTIVE', 'SIGNED', 'EXPIRED'))
group by o.contractid
),
vw_SumOptionalExtentionAmount (contractid, Value, [Value currency],[Value (display currency)])
as
(
select o.contractid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(max(vc.SumOptionalExtentionAmount),0) as [Value (display currency)]
from tamount a inner join toption o on a.amountid=o.estimatedamountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =o.contractid
where 
o.declared =1
group by o.contractid
),
vw_NextOptionalExtentionAmount (contractid, Value, [Value currency],[Value (display currency)])
as
(
select distinct o.contractid, round(a.amount,0) as Value, c.currency_code as [Value currency], round(d.amount,0) as [Value (display currency)]
from tamount a inner join toption o on a.amountid=o.estimatedamountid and o.declared = 0 
inner join tcurrency c   on a.currencyid = c.currencyid
inner join tcontract ic  on ic.contractid = o.contractid
inner join vamountindefaultcurrency d
on a.amountid=d.amountid
where 
o.fromdate = (select min(fromdate) from toption where contractid = o.contractid and declared = 0 )
),
vw_Reimb(contractid, Value, [Value currency],[Value (display currency)])
as
(
select 
co.contractid, 
round(a.Amount,0) as Value,
c.currency_code as [Value currency],
round(d.Amount,0) as [Value (display currency)]
from tcontract co
inner join tamount a
on a.amountid=co.ProvisionalSumAmountID
inner join tcurrency c
on a.currencyid=c.currencyid
inner join vamountindefaultcurrency d
on a.amountid=d.amountid
),
vw_InvCommit(contractid,[Value (display currency)])
as
(
select contractid,round(InvoiceableCommitment,0) as [Value (display currency)] from VCOMMERCIAL
),
vw_Remaining(contractid,[Value (display currency)])
as
(
select contractid,round(RemainingValue,0) as [Value (display currency)] from VCOMMERCIAL  
),
vw_option (contractid, option_count)
as
(
select contractid, count(optionid) option_count from toption 
group by contractid
),
vw_option_declared (contractid,option_count)
as
(
select contractid, count(optionid) option_count from toption
where declared =1 
group by contractid
),
vw_option_notdeclared (contractid,enddate,option_count)
as
(
select contractid, min(todate),count(optionid) enddate from  toption
where declared =0 
group by contractid
),
vw_worklocation (contractid,worksite)
as
(
select contractid,
  stuff((
			   select top 50 '; '+worklocation from tworklocation
                inner join tworklocation_in_contract 
				on  tworklocation_in_contract.worklocationid = tworklocation.worklocationid
                where tworklocation_in_contract.contractid=tcontract.contractid    
				order by worklocation
     for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') 
	 as worksite from tcontract
),
vw_summary (contractid,searchwords,ingress,summarybody,cqsummarybody)
as
(
select contractid,searchwords,ingress,summarybody,cqsummarybody from tcontractsummary
),
vw_contract_info (contractid, comments, terminationperiod,terminationconditions,definedenddate,strategytype,language,prevcontractnumber,allowvorupload,currency_code,publish,supplier,supplierno,[Counterpart contact],[Counterpart contact email],[Counterpart contact phone 1],[Counterpart contact phone 2],productgroups)
as
(
select
c.contractid,
c.comments,
c.terminationperiod,
c.terminationconditions,
c.definedenddate,
tstrategytype.strategytype,
tlanguage .mik_language as [language],
(select top 1 con.contractnumber  from tcontract con
 inner join tcontractnumber num 
 on con.contractid=num.prevcontractnumberid 
 where num.contractid = c.contractid 
) as prevcontractnumber,
allowvorupload,
currency_code,
publish,
stuff((
	select top 50 '; '+ com.company from ttenderer ten
	inner join tcompany com
	on ten.companyid = com.companyid
	where ten.isawarded = 1
	and 	ten.contractid in  
	(select ccc.contractid  from tcontract ccc  
	 where (ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	 or   ccc.contractid = c.contractid 
	 )
	order by com.company
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as supplier,
stuff((
	select top 50 '; '+ com.companyno from ttenderer ten
	inner join tcompany com
	on ten.companyid = com.companyid
	where ten.isawarded = 1
	and 	ten.contractid in  
	(select ccc.contractid  from tcontract ccc  
	 where (ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	 or   ccc.contractid = c.contractid 
	 )
	order by com.company
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as supplierno,
case 
when (select COUNT(COMPANYID) FROM TTENDERER TT where CONTRACTID = c.contractid and TT.ISAWARDED = 1) = 1
then
	stuff((
				   select top 50 '; '+ vcc.FirstName + ' '+vcc.LastName from ttenderer ten
				   inner join VCompanyContact vcc
				   on ten.companyid = vcc.companyid and ten.PRIMARYCOMPANYCONTACTID = vcc.CompanyContactID
		where ten.isawarded = 1
		and ten.contractid in 
		(select ccc.contractid  from tcontract ccc 
		  where ((ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	            or   ccc.contractid = c.contractid ))
		and ISNULL(ten.PRIMARYCOMPANYCONTACTID, -1) > 0
		order by vcc.company
	for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')

when (select COUNT(COMPANYID) FROM TTENDERER TT where CONTRACTID = c.contractid and TT.ISAWARDED = 1) = 0
then
stuff((
			   select top 50 '; '+ vcc.FirstName + ' '+vcc.LastName+' ('+vcc.company+')' from ttenderer ten
               inner join VCompanyContact vcc
			   on ten.companyid = vcc.companyid and ten.PRIMARYCOMPANYCONTACTID = vcc.CompanyContactID
		where ten.isawarded = 1 
		and ten.contractid in 
		(select ccc.contractid  from tcontract ccc  
		 where ((ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	            or   ccc.contractid = c.contractid ))
		        and ISNULL(ten.PRIMARYCOMPANYCONTACTID, -1) > 0
		
	order by vcc.company
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')

END [Counterpart contact],
case 
when (select COUNT(COMPANYID) FROM TTENDERER TT where CONTRACTID = c.contractid  and TT.ISAWARDED = 1) = 1
then
	stuff((
				   select top 50 '; ' + vcc.Email from ttenderer ten
				   inner join VCompanyContact vcc
				   on ten.companyid = vcc.companyid and ten.PRIMARYCOMPANYCONTACTID = vcc.CompanyContactID
		where ten.isawarded = 1
		and ten.contractid in 
		(select ccc.contractid  from tcontract ccc
		where ((ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	            or   ccc.contractid = c.contractid ))
		        and ISNULL(ten.PRIMARYCOMPANYCONTACTID, -1) > 0
				order by vcc.company
	for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')

when (select COUNT(COMPANYID) FROM TTENDERER TT where CONTRACTID = c.contractid and TT.ISAWARDED = 1) = 0
then
		stuff((
					   select top 50 '; ' + vcc.Email +' (' + vcc.company + ')' from ttenderer ten
					   inner join VCompanyContact vcc
					   on ten.companyid = vcc.companyid and ten.PRIMARYCOMPANYCONTACTID = vcc.CompanyContactID
			where ten.isawarded = 1
			and ten.contractid in
			(select ccc.contractid  from tcontract ccc
			 where ((ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	            or   ccc.contractid = c.contractid ))
			  and ISNULL(ten.PRIMARYCOMPANYCONTACTID, -1) > 0
			  order by vcc.company
		for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')

END [Counterpart contact email],
case 
when (select COUNT(COMPANYID) FROM TTENDERER TT where CONTRACTID = c.contractid  and TT.ISAWARDED = 1) = 1
then
stuff((
			   select top 50 '; ' + p.Phone1 from ttenderer ten
               inner join VCompanyContact vcc
			   on ten.companyid = vcc.companyid and ten.PRIMARYCOMPANYCONTACTID = vcc.CompanyContactID
			   inner join tperson p on vcc.PersonID = p.personid
    where ten.isawarded = 1
	and	ten.contractid in  
	(select ccc.contractid  from tcontract ccc
	where ((ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	            or   ccc.contractid = c.contractid ))
	and ISNULL(ten.PRIMARYCOMPANYCONTACTID, -1) > 0	
	order by vcc.company
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')

when (select COUNT(COMPANYID) FROM TTENDERER TT where CONTRACTID = c.contractid and TT.ISAWARDED = 1) = 0
then
stuff((
			   select top 50 '; ' + p.Phone1 +' (' + vcc.company + ')' from ttenderer ten
               inner join VCompanyContact vcc
			   on ten.companyid = vcc.companyid and ten.PRIMARYCOMPANYCONTACTID = vcc.CompanyContactID
			   inner join tperson p on vcc.PersonID = p.personid
    where ten.isawarded = 1
	and ten.contractid in
	  (select ccc.contractid  from tcontract ccc
	   where ((ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	            or   ccc.contractid = c.contractid ))
		and ISNULL(ten.PRIMARYCOMPANYCONTACTID, -1) > 0
	order by vcc.company
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')

END as [Counterpart contact phone1],

case 
when (select COUNT(COMPANYID) FROM TTENDERER TT where CONTRACTID = c.contractid  and TT.ISAWARDED = 1) = 1
then
stuff((
			   select top 50 '; ' + p.Phone2  from ttenderer ten
               inner join VCompanyContact vcc
			   on ten.companyid = vcc.companyid and ten.PRIMARYCOMPANYCONTACTID = vcc.CompanyContactID
			   inner join tperson p on vcc.PersonID = p.personid
    where ten.isawarded = 1
	and	ten.contractid in  
	(select ccc.contractid  from tcontract ccc 
	where ((ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	            or   ccc.contractid = c.contractid ))
		and ISNULL(ten.PRIMARYCOMPANYCONTACTID, -1) > 0
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')

when (select COUNT(COMPANYID) FROM TTENDERER TT where CONTRACTID = c.contractid and TT.ISAWARDED = 1) = 0
then
stuff((
			   select top 50 '; ' + p.PHONE2 +' (' + vcc.company + ')' from ttenderer ten
               inner join VCompanyContact vcc
			   on ten.companyid = vcc.companyid and ten.PRIMARYCOMPANYCONTACTID = vcc.CompanyContactID
			   inner join tperson p on vcc.PersonID = p.personid
    where ten.isawarded = 1
	and 	ten.contractid in  
	(select ccc.contractid  from tcontract ccc  
	where ((ccc.referencecontractid = c.contractid and c.statusid = @ma_statusid)
	            or   ccc.contractid = c.contractid ))
	and ISNULL(ten.PRIMARYCOMPANYCONTACTID, -1) > 0
	order by vcc.company
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')

END as [Counterpart contact phone2],
stuff((
select top 50 '; ' + gn.productgroupnomenclature + ': '+stuff((
	select top 50 ', ' + isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
	from tproductgroup g inner join tprod_group_in_contract gc
	on g.productgroupid = gc.productgroupid
	where g.productgroupnomenclatureid = gn.productgroupnomenclatureid  and gc.contractid = c.contractid
    order by isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
from tproductgroupnomenclature gn
order by gn.productgroupnomenclature
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as productgroups
from tcontract c
left join tstrategytype
on c.strategytypeid = tstrategytype.strategytypeid
left join tlanguage 
on tlanguage.languageid = c.languageid
left join tcurrency
on tcurrency.currencyid = c.currencyid
),
vw_project (contractid, projectname)
as
(
select	contractid,
stuff((
 			   select top 50 '; '+project from tproject
                inner join tcontract_in_project 
				on  tcontract_in_project.projectid = tproject.projectid
                where tcontract_in_project.contractid=tcontract.contractid    
				order by project
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as projectname from tcontract
)
select distinct
c.contractid as [ContractID],
c.contractnumber as [Number],
c.contract as [Description],
c.status as [Status],
CAST(DateAdd(hour, 12, c.startdate) as Date)  as [Start date],
CAST(DateAdd(hour, 12, c.expirydate) as Date)  as [Original end date],
CAST(DateAdd(hour, 12, c.revexpirydate) as Date)  as [New end date],
CAST(DateAdd(hour, 12,coalesce(c.revexpirydate,c.expirydate)) as Date)   as [Actual end date],
c.agreementtype as [Contract type],
c.contractrelation as [Contract relation],
c.ApprovalStatus as [Approval status],
CAST(DateAdd(hour, 12, c.AwardDate) as Date)  as [Awarded date],
c.Counterpartynumber as [Counterparty reference number],
c.lastchangedtime  as [Last edited],
c.lasttaskcompleted  as [Last task completed],
c.linkedtonumber as [Linked to number],
c.contracttype as [Number series],
c.referencenumber as [Reference number],
cast(cinfo.productgroups as nvarchar(4000)) as [Product and service groups],
CAST(DateAdd(hour, 12, c.contractdate) as Date)  as [Registered date],
CAST(DateAdd(hour, 12, c.reviewdate) as Date)  as [Review date],
CAST(DateAdd(hour, 12, c.signeddate) as Date)  as [Signed date],
c.country as [Awarded counterpart/partner country],
opnd.option_count  as [Number of remaining options],
opd.option_count as [Number of declared options],
cast(wl.worksite as nvarchar(4000))  as [Work or delivery site],
summ.searchwords as [Search words],
summ.ingress as [Ingress],
cast (summ.cqsummarybody as nvarchar(4000)) as [Summary],
cinfo.strategytype as [Procedure],
cinfo.comments as [Comment],
cinfo.terminationperiod as [Term of notice (days)],
cinfo.terminationconditions as [Conditions for termination],
cinfo.Supplier as [Awarded counterpart/partner],
cinfo.SupplierNo as [Awarded counterpart/partner number],
case 
when cinfo.definedenddate = 1 then N'Yes' 
when cinfo.definedenddate = 0 then N'No'
else null
end  as [Defined end date],
cast(p.projectname as nvarchar(4000)) as [Associated projects],
cinfo.language as [Language],
c.referencecontractnumber as [Previous number],
case
when c.sharedwithsupplier = 1 then N'Yes'
when c.sharedwithsupplier = 0 then N'No'
else null
end as [Shared with counterpart],
case 
when cinfo.allowvorupload = 1 then N'Yes'
when cinfo.allowvorupload = 0 then N'No'
else null 
end as [VOR handling through portal],
cinfo.currency_code as  [Default currency],
@dislpay_currency   as  [Display currency],
case 
when cinfo.publish = 1 then N'Yes'
when cinfo.publish = 0 then N'No'
else null
end as [Show on intranet (CIS)],
--Amounts
ea.[Value] as [Estimated amount],
ea.[Value currency] as [Estimated amount currency],
ea.[Value (display currency)] as [Estimated amount (display currency)],
ab.[Value] as [Approved budget],
ab.[Value currency] as [Approved budget currency],
ab.[Value (display currency)] as [Approved budget (display currency)],
ls.[Value] as [Lump sum],
ls.[Value currency] as [Lump sum currency],
ls.[Value (display currency)] as [Lump sum (display currency)],
i.[Value]  as [Invoiced value],
i.[Value currency] as [Invoiced value currency],
i.[Value (display currency)] as [Invoiced value (display currency)],
pcg.[Value] as [Parent company guarantee],
pcg.[Value currency] as [Parent company guarantee currency],
pcg.[Value (display currency)] as [Parent company guarantee (display currency)],
bg.[Value] as [Bank guarantee],
bg.[Value currency] as [Bank guarantee currency],
bg.[Value (display currency)] as [Bank guarantee (display currency)],
so.[Value] as [Sum of orders],
so.[Value currency] as [Sum of orders currency],
so.[Value (display currency)] as [Sum of orders (display currency)],
svo.[Value] as [Sum approved variation orders],
svo.[Value currency] as [Sum approved variation orders currency],
svo.[Value (display currency)] as [Sum approved variation orders (display currency)],
saa.[Value] as [Sum approved amendments],
saa.[Value currency] as [Sum approved amendments currency],
saa.[Value (display currency)] as [Sum approved amendments (display currency)],
case 
when saa.[Value]=-1 or svo.[Value]=-1 or soex.[Value]=-1 then -1
else (ISNULL(ls.[Value],0) +  ISNULL(saa.[Value],0) + ISNULL(svo.[Value],0) + ISNULL(soex.[Value],0) + ISNULL(re.[Value],0)) 
end as [Invoiceable commitment],
ls.[Value currency] as [Invoiceable commitment currency],
invc.[Value (display currency)] as [Invoiceable commitment (display currency)],
case 
when saa.[Value]=-1 or svo.[Value]=-1 or soex.[Value]=-1 or so.[Value]=-1 then -1
else (ISNULL(ls.[Value],0) +  ISNULL(saa.[Value],0) + ISNULL(svo.[Value],0) + ISNULL(soex.[Value],0) + ISNULL(re.[Value],0) - ISNULL(so.[Value],0)) 
end as [Remaining value],
ls.[Value currency] as [Remaining value currency],
remv.[Value (display currency)] as [Remaining value (display currency)],
soex.[Value]    [Sum declared optional extensions],
soex.[Value currency] as [Sum declared optional extensions currency],
soex.[Value (display currency)] as [Sum declared optional extensions (display currency)],
snoe.[Value]  as  [Estimated value next option],
snoe.[Value currency] as [Estimated value next option currency],
snoe.[Value (display currency)] as [Estimated value next option (display currency)],

re.[Value]  as  [Reimbursable expense limit],
re.[Value currency] as [Reimbursable expense limit currency],
re.[Value (display currency)] as [Reimbursable expense limit (display currency)],
(isnull(re.[Value],0) + isnull(ls.[Value],0))  as  [Original contract value],
re.[Value currency] as [Original contract value currency],
(isnull(re.[Value (display currency)],0) + isnull(ls.[Value (display currency)],0)) as [Original contract value (display currency)],
cinfo.[Counterpart contact] as [Counterpart primary contact name],
cinfo.[Counterpart contact email] as [Counterpart primary contact email],
cinfo.[Counterpart contact phone 1] as [Counterpart primary contact phone 1],
cinfo.[Counterpart contact phone 2] as [Counterpart primary contact phone 2],
CAST(DateAdd(hour, 12, opnd.enddate) as Date)  as [End date next option],
datediff(dd,startdate,expirydate)+1 as [Original duration]
from  vsearchsimplecontract c   
inner join vw_contract_info cinfo
on c.contractid = cinfo.contractid
left join vw_estimated_amount  ea
on c.contractid = ea.contractid
left join  vw_Approved_budget ab
on c.contractid = ab.contractid
left join vw_LumpSum ls
on  c.contractid = ls.contractid
left join vw_Invoiced i
on c.contractid = i.contractid
left join vw_ParentCompanyGuarantee pcg
on c.contractid = pcg.contractid
left join vw_Bankguarantee bg
on c.contractid = bg.contractid
left join vw_option op
on op.contractid = c.contractid
left join vw_option_declared opd
on opd.contractid = c.contractid
left join vw_worklocation wl
on wl.contractid = c.contractid
left join vw_summary summ
on summ.contractid = c.contractid
left join vw_project p
on p.contractid = c.contractid
left join  vw_SumOrders so
on so.contractid = c.contractid
left join vw_SumVO svo
on svo.contractid = c.contractid
left join vw_SumApprovedAmendments saa
on saa.contractid = c.contractid
left join vw_SumOptionalExtentionAmount soex
on soex.contractid=c.contractid
left join vw_Reimb re
on re.contractid=c.contractid
left join vw_InvCommit invc
on invc.contractid=c.contractid
left join vw_NextOptionalExtentionAmount snoe
on snoe.contractid=c.contractid
left join vw_option_notdeclared opnd
on opnd.contractid=c.contractid
left join vw_Remaining remv 
on remv.contractid=c.contractid
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase0_ContractACL]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_Phase0_ContractACL] 
as 
select ta.objectid as contractid,ta.userid,tu.domainnetbiosusername
from tacl ta (nolock)
inner join tuser tu
on  ta.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null
and tu.mik_valid = 1 
where 
ta.objecttypeid in (select tobjecttype.objecttypeid
                                    from   tobjecttype
                                    where  fixed = 'contract'
									)
and ta.privilegeid = 1
and ta.userid is not null
union 
select objectid as contractid,ug.userid,tu.domainnetbiosusername
from tacl ta (nolock)
inner join tuser_in_usergroup ug (nolock)
on ug.usergroupid = ta.groupid
inner join tuser tu
on ug.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null            
and tu.mik_valid = 1 
where 
ta.objecttypeid in (select tobjecttype.objecttypeid
                                    from   tobjecttype
                                    where  fixed = 'contract'
									)
and ta.privilegeid = 1
and ug.userid is not null
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase0_RFx]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_Phase0_RFx]
as
declare @RFxObjectTypeID bigint
select  @RFxObjectTypeID=objecttypeid from tobjecttype where fixed = N'RFx'
declare @BidderObjectTypeID bigint
select  @BidderObjectTypeID = objecttypeid from tobjecttype where fixed = N'TENDERER'

declare @RFxPublishedDocumentFolderFixed varchar(50)
declare @RFxPublishedDocumentFolderRootId int
select  @RFxPublishedDocumentFolderFixed= settingvalue from tprofilesetting 
where 
profilekeyid in (select  profilekeyid from tprofilekey where FIXED = 'RFX_PUBLISHED_DOCUMENTS_FOLDER')
select @RFxPublishedDocumentFolderRootId = documenttypeid from tdocumenttype
where fixed = @RFxPublishedDocumentFolderFixed;
with invited 
as 
(
select i.rfxid,ip.companyname,s.status,ip.firstname+' '+ip.lastname as primcontact,ip.country,sl.comment as declinecomment,ip.companyno as companynumber,sl.logdate from trfxinterest i 
left join trfxinterestedparty ip on i.rfxinterestedpartyid = ip.rfxinterestedpartyid
left join trfxintereststatuslog sl on i.rfxinterestid = sl.rfxinterestid
left join tstatus s on s.statusid = sl.statusid
where 
i.rfxinterestedpartyid is not null 
--and i.rfxid = @rfxid 
and (sl.logdate = (select max(logdate) from trfxintereststatuslog where rfxinterestid = i.rfxinterestid) or sl.logdate is null)
union 
select i.rfxid,c.company as companyname,s.status,u.firstname+' '+u.lastname as primcontact,co.country,sl.comment as declinecomment,c.companyno as companynumber,sl.logdate from trfxinterest i 
left join tcompany c on i.companyid = c.companyid
left join trfxintereststatuslog sl on i.rfxinterestid = sl.rfxinterestid
left join tstatus s on s.statusid = sl.statusid
left join vuser u on u.userid = i.primarycompanycontactuserid
left join tcompanyaddress ca on c.companyid = ca.companyid
left join tcountry co on ca.countryid=co.countryid
left join taddresstype at on ca.addresstypeid = at.addresstypeid
where 
at.fixed = 'MAINADDRESS' and
i.rfxinterestedpartyid is null 
--and i.rfxid = @rfxid 
and (sl.logdate = (select max(logdate) from trfxintereststatuslog where rfxinterestid = i.rfxinterestid) or sl.logdate is null)
),
bidders
as
(
select t.rfxid,c.company as companyname,c.companyno as companynumber,p.displayname as primcontact,con.country,
round(am.amount,0) as [Bidders commercial value (RFx)],
round(evc.amount,0)  as [Bidders commercial value (display currency) (RFx)],
ec.currency_code  as [Bidders commercial value currency code (RFx)],
s.status as status,
(select top 1  score from tassessmentscore 
 where assessmentcriterionid in (
                           select  assessmentcriterionid from tassessmentcriterion 
						   where parentid is null and 
                           assessmentid in (
                                           select ass.assessmentid from tassessment ass inner join tevaluationtype et on ass.evaluationtypeid = et.evaluationtypeid
				                           where et.fixed = 'TENDER_EVALUATION'
				                           and ass.ownerobjecttypeid = @RFxObjectTypeID --rfxtype
				                           and ass.ownerobjectid = t.rfxid --rfx
                                            )

                                )
and assessmentobjectid in (
								select  assessmentobjectid from tassessmentobject aso
								where  aso.assessmentid in
								(
												 select ass.assessmentid from tassessment ass inner join tevaluationtype et on ass.evaluationtypeid = et.evaluationtypeid
												 where et.fixed = 'TENDER_EVALUATION'
												 and ass.ownerobjecttypeid = @RFxObjectTypeID --rfxtype
												 and ass.ownerobjectid = t.rfxid --rfx
												 )
								and assessedobjectid     = t.tendererid          --tendererid
								and assessedobjecttypeid = @BidderObjectTypeID    --tenderertype


                          )) as Score,
(
select count(d.documentid) from tdocument d inner join tdocumenttype dt on d.documenttypeid = dt.documenttypeid
where 
d.objecttypeid = @BidderObjectTypeID  and d.objectid = t.tendererid and 
d.documenttypeid in (select documenttypeid from tdocumenttype where fixed = N'RFX_UPLOADEDBIDDOCUMENTS' and objecttypeid = @BidderObjectTypeID )
) as DocumentCount
from ttenderer t
left join tcompany c on t.companyid = c.companyid
left join tstatus s on t.statusid = s.statusid
left join tcompanyaddress ca on ca.companyid = t.companyid and addresstypeid = 1 
left join tcountry con on con.countryid = ca.countryid
left join tcompanycontact cc on t.primarycompanycontactid = cc.companycontactid and t.companyid=cc.companyid
left join tperson p on cc.personid = p.personid
left join tamount am on am.amountid = t.totalvalueamountid
left join vamountindefaultcurrency evc on evc.amountid =am.amountid
left join tcurrency ec   on ec.currencyid = am.currencyid
),
QA
as
(
select rfx.rfxid,q.rfxquestionandanswerid,qt.fixed qatype,st.fixed as statementtype,s.ispublished, s.isprivate, s.iscancelled  from trfxquestionandanswer q 
inner join tqatype qt on q.qatypeid= qt.qatypeid 
inner join tstatement s on s.rfxquestionandanswerid = q.rfxquestionandanswerid
inner join tstatementtype st on s.statementtypeid = st.statementtypeid 
inner join (select rfxinterestid,rfxid from trfxinterest) rfx on q.objectid = rfx.rfxinterestid and q.objecttypeid in (select objecttypeid from tobjecttype where fixed = N'RFXINTEREST')
union
select rfx.rfxid,q.rfxquestionandanswerid,qt.fixed qatype,st.fixed as statementtype,s.ispublished, s.isprivate, s.iscancelled  from trfxquestionandanswer q 
inner join tqatype qt on q.qatypeid= qt.qatypeid 
inner join tstatement s on s.rfxquestionandanswerid = q.rfxquestionandanswerid
inner join tstatementtype st on s.statementtypeid = st.statementtypeid 
inner join trfx rfx on q.objectid = rfx.rfxid and q.objecttypeid in (select objecttypeid from tobjecttype where fixed = N'RFx')
),
RFxHideList as 
(
select rfxid from trfx
where bidlocked = 1 and bidopeningcountdown > 0
union
select rfxid from trfx
where dateadd(hh,timezoneutcoffset,responsedeadline) > getutcdate()
and (select ps.SETTINGVALUE from TPROFILEKEY pk inner join TPROFILESETTING ps on pk.PROFILEKEYID = ps.PROFILEKEYID where pk.fixed ='HIDE_BIDDERS_NODE_ON_RFX_FROM_PROCESS_START_UNTIL_DUE_DATE') in ('True')
)
select 
r.ContractID,
r.RFxID,
r.rfx as [Title (RFx)],
r.shortdescription as [Desciption (RFx)],
rt.rfxtype as [Type of request (RFx)],
st.strategytype as [Procedure (RFx)],       
at.agreement_type as [Contract type (RFx)], 
case
when r.frameworkcontract = 1 then N'Yes'
else N'No'
end as [Framework contract (RFx)],
r.externalnumber as [RFx Number (RFx)],
r.othernumber as [Other reference number (RFx)],
case
when r.isopen = 1 then N'Yes'
else N'No'
end as [Open/Public (RFx)],
s.status as [Status (RFx)],
r.timezonedisplayname as [Time zone (RFx)],
r.publicationdate as [Publication date (RFx)],
r.confirminterestdate  as [Deadline confirmation of interest (RFx)],
r.clarificationdeadline  as [Deadline for Q&A (RFx)],
r.responsedeadline as [Response due date/time (RFx)],
case
when r.bidlocked =1 then N'Yes'
else N'No'
end as [Bid locking used (RFx)],
r.formalopeningdate as [Formal opening date/time (RFx)],
r.formalopeningplace as [Place (RFx)],
r.minimumtendervalidity  as [Minimum validity (RFx)],
r.plannedawarddate as [Planned award date (RFx)],
r.plannedeffectivedate as [Planned start date (RFx)],
r.plannedexpirydate as    [Planned expiry date (RFx)],
(select  datediff(dd,startdate,coalesce(rev_expirydate,expirydate))  from tcontract where contractid = r.contractid) + 1 as  [Planned contract duration in days (RFx)],
r.rfxurl as [Internet address (URL) (RFx)],
r.rfxinfoemail as [Email address for info (RFx)],
w.worklocation  as [Work or delivery site (RFx)],
stuff((
	select top 50 '; ' + isnull(l.mik_language,'')
	from tlanguage_in_rfx linr inner join tlanguage l
	on linr.languageid = l.languageid
	where linr.rfxid = r.rfxid
    order by isnull(l.mik_language,'')
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Accepted languages (RFx)],
r.longdescription as  [Description of acquisition (RFx)],
stuff((
select top 50 '; ' + gn.productgroupnomenclature + ': '+stuff((
	select top 50 ', ' + isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
	from tproductgroup g inner join tprod_group_in_rfx gc 
	on g.productgroupid = gc.productgroupid
	where g.productgroupnomenclatureid = gn.productgroupnomenclatureid  and gc.rfxid = r.rfxid
    order by isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
from tproductgroupnomenclature gn
order by gn.productgroupnomenclature
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Product and service groups (RFx)],
case
when r.awardtomostattractive = 1 then N'Overall most attractive'
else N'Lowest price'
end as [Award criteria type (RFx)],
r.awardcriteria as [Award criterias (RFx)],
cast(txt.clausetext as nvarchar(4000)) as [Payment conditions/form (RFx)], 
c.currency as [Preferred currency (RFx)],
case 
when exists (select * from ttenderer where contractid > 0 and rfxid = r.rfxid)  then N'Yes'
else N'No'
end as [Current (RFx)],
case 
when r.ispublished = 1 then N'Yes'
else N'No'
end as  [Is published (RFx)],

stuff((
	select top 50 '; ' + i.companyname from invited i
	where i.rfxid = r.rfxid
    order by i.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Invited/interested parties company name (RFx)],
stuff((
	select top 50 '; ' + i.status + ' ('+ i.companyname+')' from invited i
	where i.rfxid = r.rfxid
    order by i.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Invited/interested parties status (RFx)],

stuff((
	select top 50 '; ' + i.primcontact + ' ('+ i.companyname+')' from invited i
	where i.rfxid = r.rfxid
    order by i.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Invited/interested parties primary contact (RFx)],
stuff((
	select top 50 '; ' + i.country + ' ('+ i.companyname+')' from invited i
	where i.rfxid = r.rfxid
    order by i.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Invited/interested parties country (RFx)],
stuff((
	select top 50 '; ' + i.declinecomment + ' ('+ i.companyname+')' from invited i
	where i.rfxid = r.rfxid
    order by i.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Invited/interested parties decline comment (RFx)],
stuff((
	select top 50 '; ' + i.companynumber + ' ('+ i.companyname+')' from invited i
	where i.rfxid = r.rfxid
    order by i.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Invited/interested parties company number (RFx)],
stuff((
	select top 50 '; ' + cast(i.logdate as varchar(20)) + ' ('+ i.companyname+')' from invited i
	where i.rfxid = r.rfxid
    order by i.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Invited/interested parties status change (RFx)],


case 
when r.isopen = 1 then (select count(vrfi.rfxinterestid) from vrfxinterest vrfi where vrfi.rfxid = r.rfxid and vrfi.fixed in ('DECLAREDINTENTIONTOBID', 'BIDDELIVEREDANDCONFIRMED', 'CONTRACT_DRAFTING'))
else (select count(vrfi.rfxinterestid) from vrfxinterest vrfi where vrfi.rfxid = r.rfxid )
end as [Number of invited/interested parties (RFx)],
(select count(vrfi.rfxinterestid) from vrfxinterest vrfi where vrfi.rfxid = r.rfxid and vrfi.confirmedinterest = 1) as [Number of participants confirmed interest (RFx)],
(select count(vrfi.rfxinterestid) from vrfxinterest vrfi where vrfi.rfxid = r.rfxid and vrfi.fixed = 'DECLINEDTOBID') as [Number of participants declined (RFx)],

(select count(a.AuctionId) from tauction a where a.PublishStatus = 0 and a.rfxid = r.rfxid) as [Number of planned reverse auctions (RFx)],
(
 select count(a.Auctionid) from tauction a
 inner join trfx rf on a.rfxid=rf.rfxid
 where 
 a.rfxid = r.rfxid   and
 a.PublishStatus = 1 and
 a.EndTime < dateadd(hh,-(rf.TIMEZONEUTCOFFSET),GETUTCDATE())
 ) as [Number of completed reverse auctions (RFx)],
  datediff(dd,(select cast(dateadd(hour, 12, min(time)) as date) from taudittrail where objectid = r.rfxid and objecttypeid = @RFxObjectTypeID) ,r.publicationdate) + 1 as [Duration in days from RFx creation to RFx published (RFx)],
(select datediff(dd,dateadd(hh,r.timezoneutcoffset,r.responsedeadline),awarddate) from tcontract where contractid = r.contractid) + 1 as [Duration in days from RFx due date to contract award (RFx)],
 datediff(dd,r.publicationdate,r.responsedeadline) + 1 as [Duration in days from RFx publication to due date (RFx)],
(select datediff(dd,(select min(time) from taudittrail where objectid = r.rfxid and objecttypeid = @RFxObjectTypeID),awarddate) from tcontract where contractid = r.contractid) + 1 as [Duration in days from RFx creation to contract award (RFx)], 

--(select count(rfxquestionandanswerid) from trfxquestionandanswer 
-- where  objectid = r.rfxid 
-- and    objecttypeid in (select objecttypeid from tobjecttype where fixed = N'RFx')
-- ) as [Number of questions and answers (RFx)],

(select datediff(dd,awarddate,startdate) + 1  from tcontract where contractid = r.contractid) as [Duration in days from contract award to active (RFx)],

case when hl.rfxid is null then (select count(bid.rfxid) from bidders bid where bid.rfxid = r.rfxid) else null end as [Number of bidders (RFx)],
case when hl.rfxid is null then 
stuff((
	select top 50 '; ' + bid.companyname from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.companyname is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Bidders company name (RFx)],
case when hl.rfxid is null then 
stuff((
	select top 50 '; ' + bid.companynumber+' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.companynumber is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end 
as [Bidders company number (RFx)],
case when hl.rfxid is null then 
stuff((
	select top 50 '; ' + bid.primcontact+' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.primcontact is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Bidders primary contact (RFx)],
case when hl.rfxid is null then
stuff((
	select top 50 '; ' + bid.country+' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.country is not null      
	order by bid.country
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Bidders country (RFx)],
case when hl.rfxid is null then
stuff((
	select top 50 '; ' + cast(bid.[Bidders commercial value (RFx)] as varchar(20))+' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.[Bidders commercial value (RFx)] is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Bidders commercial value (RFx)],
case when hl.rfxid is null then 
stuff((
	select top 50 '; ' + cast(bid.[Bidders commercial value (display currency) (RFx)] as varchar(20))+' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.[Bidders commercial value (display currency) (RFx)] is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Bidders commercial value (display currency) (RFx)],
case when hl.rfxid is null then 
stuff((
	select top 50 '; ' + bid.[Bidders commercial value currency code (RFx)] +' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.[Bidders commercial value currency code (RFx)] is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Bidders commercial value currency code (RFx)],
case when hl.rfxid is null then 
stuff((
	select top 50 '; ' + bid.status +' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.status is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Bidders status (RFx)],
case when hl.rfxid is null then 
stuff((
	select top 50 '; ' + cast(bid.score as varchar(20)) +' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.score is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Bidders score (RFx)],
case when hl.rfxid is null then 
stuff((
	select top 50 '; ' + cast(bid.DocumentCount as varchar(20)) +' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.DocumentCount is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Number of documents delivered in response (RFx)],
case when hl.rfxid is null then 
stuff((
	select top 50 '; ' + ten.comment +' ('+com.company +')'
	from ttenderer ten inner join tcompany com
	on   ten.companyid = com.companyid
	where ten.rfxid = r.rfxid
	and   ten.comment is not null
    order by com.company
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Comment (RFx)],
(select  count(rfxquestionandanswerid) from QA where qatype = N'QUESTION_AND_ANSWER' and statementtype = N'QUESTION' and rfxid = r.rfxid)                    as [Number of questions (RFx)],
(select  count(rfxquestionandanswerid) from QA where qatype = N'QUESTION_AND_ANSWER' and statementtype = N'QUESTION' and iscancelled = 1 and rfxid = r.rfxid) as [Number of questions rejected (RFx)],
(select  count(rfxquestionandanswerid) from QA where qatype = N'QUESTION_AND_ANSWER' and statementtype = N'ANSWER'   and isprivate  = 1 and rfxid = r.rfxid) as [Number of private answers (RFx)],
(select  count(rfxquestionandanswerid) from QA where qatype = N'QUESTION_AND_ANSWER' and statementtype = N'ANSWER'   and isprivate  = 0 and rfxid = r.rfxid) as [Number of public answers (RFx)],
(select  count(rfxquestionandanswerid) from QA where qatype = N'QUESTION_AND_ANSWER' and statementtype = N'ANSWER'   and ispublished =1 and rfxid = r.rfxid) as [Number of published answers (RFx)],
(select  count(rfxquestionandanswerid) from QA where qatype = N'QUESTION_AND_ANSWER' and statementtype = N'ANSWER'   and ispublished =0 and rfxid = r.rfxid) as [Number of unpublished answers (RFx)],
(select  count(rfxquestionandanswerid) from QA where qatype = N'CLARIFICATION'       and statementtype = N'ANSWER'                      and rfxid = r.rfxid) as [Number of answered response clarifications (RFx)],
(
  select count(rfxquestionandanswerid) from 
	(
	select  rfxquestionandanswerid from QA where qatype = N'QUESTION_AND_ANSWER' and statementtype = N'QUESTION' and rfxid = r.rfxid
	except
	select  rfxquestionandanswerid from QA where qatype = N'QUESTION_AND_ANSWER' and statementtype = N'ANSWER'   and rfxid = r.rfxid
	) a
) as [Number of unanswered questions (RFx)],
(
  select count(rfxquestionandanswerid) from 
	(
	select  rfxquestionandanswerid from QA where qatype = N'CLARIFICATION' and statementtype = N'QUESTION' and rfxid = r.rfxid
	except
	select  rfxquestionandanswerid from QA where qatype = N'CLARIFICATION' and statementtype = N'ANSWER'   and rfxid = r.rfxid
	) a
) as [Number of unanswered response clarifications (RFx)],

(	select 	sum(ISNULL(TAB.InitialBid - TAB.LastBid, 0)) from  trfx tr 
	inner join 	tauction ta on tr.rfxid = ta.rfxid
	inner join 	tauctionbidder tab on ta.auctionid = tab.auctionid
	inner join  ttenderer tt on tab.tendererid = tt.tendererid 
	where 	tab.iswinner = 1 and ta.publishstatus = 1 and tr.rfxid = r.rfxid
) as [Auction savings (RFx)],
(	select 	avg(ISNULL(((TAB.InitialBid-TAB.LastBid)/TAB.InitialBid)*100,0)) from  trfx tr 
	inner join 	tauction ta on tr.rfxid = ta.rfxid
	inner join 	tauctionbidder tab on ta.auctionid = tab.auctionid
	inner join  ttenderer tt on tab.tendererid = tt.tendererid 
	where 	tab.iswinner = 1 and ta.publishstatus = 1 and tr.rfxid = r.rfxid
) as [Auction savings in % (RFx)],
(
 select count(d.documentid) from tdocument d 
 inner join tdocumenttype dt on d.documenttypeid = dt.documenttypeid
 where (dt.documenttypeid = @RFxPublishedDocumentFolderRootId or dt.RootID = @RFxPublishedDocumentFolderRootId)
 and d.objecttypeid = @RFxObjectTypeID 
 and d.objectid = r.rfxid
) as [Number of RFx document to be published (RFx)],
stuff((
select top 50 '; '+c.contractnumber+' - '+cm.company+' - '+cast(o.ordernumber as nvarchar(50)) +' - ' +o.ordername from torder o 
inner join trfx rr on o.rfxid = rr.rfxid 
inner join trfxtype rt on rr.rfxtypeid = rt.rfxtypeid and rt.fixed = 'mini_competition'
inner join tcontract c on rr.contractid = c.contractid 
inner join ttenderer t on t.rfxid = rr.rfxid
inner join tcompany cm on cm.companyid = t.companyid
where rr.rfxid = r.rfxid
order by c.contractnumber,cm.company,o.ordernumber,o.ordername
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')  as [Linked orders]
from trfx r
left join tstatus s on r.statusid = s.statusid
left join trfxtype rt on r.rfxtypeid = rt.rfxtypeid
left join tstrategytype st on r.strategytypeid = st.strategytypeid
left join tagreement_type at on r.agreement_typeid = at.agreement_typeid
left join tworklocation w on r.worklocationid = w.worklocationid
left join tcurrency c on c.currencyid = r.currencyid
left join tclausetext txt on r.paymentformclausetextid = txt.clausetextid
left join RFxHideList hl on r.rfxid=hl.rfxid
where r.ContractID is not null
--where r.rfxid = 3773
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase0_RFxACL]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_Phase0_RFxACL] 
as 
declare @Read bigint
select  @Read=privilegeid from tprivilege where privilege = N'Read'

select ta.objectid as rfxid,ta.userid,tu.domainnetbiosusername
from tacl ta (nolock)
inner join tuser tu
on  ta.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null
and tu.mik_valid = 1 
where 
ta.objecttypeid in (select tobjecttype.objecttypeid
                                    from   tobjecttype
                                    where  fixed = N'RFx'
									)
and ta.privilegeid = @Read
and ta.userid is not null
and exists(select 1 from trfx r where r.RfxID = ta.objectid and r.ContractID is not null)
union 
select objectid as rfxid,ug.userid,tu.domainnetbiosusername
from tacl ta (nolock)
inner join tuser_in_usergroup ug (nolock)
on ug.usergroupid = ta.groupid
inner join tuser tu
on ug.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null            
and tu.mik_valid = 1 
where 
ta.objecttypeid in (select tobjecttype.objecttypeid
                                    from   tobjecttype
                                    where  fixed = N'RFx'
									)
and ta.privilegeid = @Read
and ug.userid is not null
and exists(select 1 from trfx r where r.RfxID = ta.objectid and r.ContractID is not null)

--Inherit from contract
union
select r.rfxid, ta.userid, tu.domainnetbiosusername from tacl ta (nolock)
inner join trfx r 
on r.contractid = ta.objectid and ta.objecttypeid = 1 and ta.privilegeid = @Read and ta.nonheritable = 0
inner join tuser tu
on  ta.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null and tu.mik_valid = 1 
where 
exists (
        select aclid from tacl 
		where tacl.objectid =r.rfxid
		and tacl.objecttypeid = (select objecttypeid from tobjecttype where fixed = 'RFx') and privilegeid = 3 and 
		parentobjecttypeid =  1 and parentobjectid = r.contractid and inheritfromparentobject = 1
		) 
and ta.userid is not null
and r.ContractID is not null
union 
select  r.rfxid,ug.userid,tu.domainnetbiosusername from tacl ta (nolock)
inner join trfx r 
on r.contractid = ta.objectid and ta.objecttypeid = 1 and ta.privilegeid = @Read and ta.nonheritable = 0
inner join tuser_in_usergroup ug (nolock)
on ug.usergroupid = ta.groupid
inner join tuser tu
on ug.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null            
and tu.mik_valid = 1 
where 
exists (
        select aclid from tacl 
		where tacl.objectid =r.rfxid
		and tacl.objecttypeid = (select objecttypeid from tobjecttype where fixed = 'RFx') and privilegeid = 3 and 
		parentobjecttypeid =  1 and parentobjectid = r.contractid and inheritfromparentobject = 1
		) 
and ug.userid is not null
and r.ContractID is not null
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_AmendmentDepartmentRole]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_Phase1_AmendmentDepartmentRole]
as
select distinct 
am.ContractID,
am.AmendmentID,
cast(replace(left(r.role,100),']','|') as nvarchar(4000)) as Role,
cast(r.fixed as nvarchar(4000)) as [Role fixed],
cast(d.department as nvarchar(4000)) as [Department],
cast(d.department_code as nvarchar(4000)) as [Code]
from tamendment am
inner join tdepartmentrole_in_object tdo on am.amendmentid = tdo.objectid and tdo.objecttypeid in (select objecttypeid from tobjecttype where fixed = N'Amendment')
inner join trole r on tdo.roleid = r.roleid and r.isdepartmentrole = 1
inner join tdepartment d on d.departmentid = tdo.departmentid
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_AmendmentPersonRole]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_Phase1_AmendmentPersonRole]
as
select distinct 
am.ContractID,
am.AmendmentID,
cast(replace(left(r.role,100),']','|') as nvarchar(4000)) as Role,
cast(r.fixed as nvarchar(4000)) as [Role fixed],
cast(vp.firstname as nvarchar(4000))+' '+cast(vp.lastname as nvarchar(4000)) as [Name],
cast(vp.email as nvarchar(4000)) as [Email],
cast(vp.phone1 as nvarchar(4000)) as [Phone 1],
cast(vp.phone2 as nvarchar(4000)) as [Phone 2]
from tamendment am
inner join tpersonrole_in_object tpo on am.amendmentid = tpo.objectid and tpo.objecttypeid in (select objecttypeid from tobjecttype where fixed = N'Amendment')
inner join trole r on tpo.roleid = r.roleid and r.ispersonrole = 1
inner join vperson vp on tpo.personid = vp.personid
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_CompanyAddress]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_Phase1_CompanyAddress]
as
select distinct 
addr.CompanyId,
Addresstype,
AddressLine1,
(SELECT   cast(SettingValue as nvarchar(4000)) FROM	TProfileSetting		PS
WHERE	PS.ProfileKeyID		in (SELECT	ProfileKeyID FROM TProfileKey WHERE	FIXED = 'ADDRESSLINE1')
AND	PS.UserGroupID		IS NULL
AND	PS.UserID			IS NULL
) as AddressLine1_Description,
AddressLine2,
(SELECT   cast(SettingValue as nvarchar(4000)) FROM	TProfileSetting		PS
WHERE	PS.ProfileKeyID		in (SELECT	ProfileKeyID FROM TProfileKey WHERE	FIXED = 'ADDRESSLINE2')
AND	PS.UserGroupID		IS NULL
AND	PS.UserID			IS NULL
) as AddressLine2_Description,
AddressLine3,
(SELECT   cast(SettingValue as nvarchar(4000)) FROM	TProfileSetting		PS
WHERE	PS.ProfileKeyID		in (SELECT	ProfileKeyID FROM TProfileKey WHERE	FIXED = 'ADDRESSLINE3')
AND	PS.UserGroupID		IS NULL
AND	PS.UserID			IS NULL
) as AddressLine3_Description,
AddressLine4,
(SELECT   cast(SettingValue as nvarchar(4000))  FROM	TProfileSetting		PS
WHERE	PS.ProfileKeyID		in (SELECT	ProfileKeyID FROM TProfileKey WHERE	FIXED = 'ADDRESSLINE4')
AND	PS.UserGroupID		IS NULL
AND	PS.UserID			IS NULL
) as AddressLine4_Description,
AddressLine5,
(SELECT   cast(SettingValue as nvarchar(4000))  FROM	TProfileSetting		PS
WHERE	PS.ProfileKeyID		in (SELECT	ProfileKeyID FROM TProfileKey WHERE	FIXED = 'ADDRESSLINE5')
AND	PS.UserGroupID		IS NULL
AND	PS.UserID			IS NULL
) as AddressLine5_Description,
Phone,
Fax,
Www,
Email,
Country
from tcompanyaddress addr
inner join tcompany com  on addr.companyid = com.companyid and com.mik_valid = 1 
inner join taddresstype at on addr.addresstypeid = at.addresstypeid
left join tcountry con on addr.countryid = con.countryid
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_CompanyContact]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_Phase1_CompanyContact]
as
select distinct
c.CompanyID,
cast(p.firstname + ' '+ p.lastname as nvarchar(4000)) as Name,
cast(p.email as nvarchar(4000)) as Email,
cast(p.phone1 as nvarchar(4000)) as Phone1, 
cast(p.phone2 as nvarchar(4000)) as Phone2 
from tcompanycontact c inner join tperson p on p.personid = c.personid
where c.mik_valid = 1
order by c.companyid
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_CompanyCustomField]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_Phase1_CompanyCustomField]
as
set nocount on
declare @A table
(pk_id bigint identity(1,1) primary key,
 Companyid bigint,
 FieldId bigint,
 Field nvarchar(4000),
 [Field fixed] nvarchar(4000),
 Value nvarchar(4000),
 Row int,
 UNIQUE CLUSTERED (field,pk_id)
 )
 declare @B table 
(
pk_id bigint identity(1,1) primary key,
Companyid bigint,
Field nvarchar(4000),
[Field fixed] nvarchar(4000),
Value nvarchar(4000),
FieldId bigint,
UNIQUE CLUSTERED (Companyid,fieldid,field,pk_id)
);
with cte (Companyid,FieldId,Field,[Field fixed],Value,Row)
as
(
select Companyid,
FieldId,
replace(left(FieldName,100),']','|') as Field,
Fixed as [Field fixed],
--FieldType,
FieldValue as Value,
--Level1,Level2,Level3,Level4,mik_valid
dense_rank() over(partition by replace(left(FieldName,100),']','|') order by Fieldid desc) AS Row
from 
(
		select  companyid, fieldtype as fieldtype, field_name as fieldname,fieldid, fixed,fieldvalue as fieldvalue, level1 as level1, level2 as level2, level3 as level3, 
							  level4 as level4, mik_valid
		from  (
			   select distinct 
						cfic_1.companyid,
						'client field' as fieldtype,
						cfic_1.clientfieldid as fieldid, 
						cfic_1.fixed as fixed,
						cfic_1.clientfield as field_name,
						cfic_1.clientfieldrangeincompanyid as fieldincompanyid,
						cfic_1.multivalue as fieldvalue, 
						cfic_1.level1id, 
						cfic_1.level1,
						cfic_1.level2id,
						cfic_1.level2,
						cfic_1.level3id,
						cfic_1.level3, 
						cfic_1.level4id,
						cfic_1.level4, 
						cfic_1.mik_valid
			from         
			(
			select     clf.clientfieldid,
			clf.clientfield,
			clf.fixed,
			cfic.companyid,
			cfic.clientfieldrangeincompanyid,
			isnull(l1.level1, '') + isnull(', ' + l2.level2, '') + isnull(', ' + l3.level3, '') + isnull(', ' + l4.level4, '') as multivalue, 
			cfic.level1id, l1.level1, 
			cfic.level2id, l2.level2,
			cfic.level3id, l3.level3,
			cfic.level4id, l4.level4,
			clf.mik_valid
			from  tclientfield as clf 
			inner join    tobjecttype as ot on clf.objecttypeid = ot.objecttypeid and ot.fixed = 'Company'
			left outer join
			tclientfieldrange_in_company as cfic
			on clf.clientfieldid = cfic.clientfieldid
			left outer join
			tlevel1 as l1 on cfic.level1id = l1.level1id left outer join
			tlevel2 as l2 on cfic.level2id = l2.level2id left outer join
			tlevel3 as l3 on cfic.level3id = l3.level3id left outer join
			tlevel4 as l4 on cfic.level4id = l4.level4id
			) as cfic_1 
			union
			select distinct 
						efic.companyid, 
					   'extra field' as fieldtype,
						efic.extra_fieldid as fieldid, 
						ef.fixed,
						ef.mik_label_text as fieldname,
						efic.extrafieldincompanyid as fieldincompanyid, 
						efic.mik_edit_value as fieldvalue,
						null as expr1,
						null as expr2,
						null as expr3,
						null as expr4,
						null as expr5,
						null as expr6, 
						null as expr7,
						null as expr8,
						ef.mik_valid
		   from   textra_field_in_company as efic 
		   inner join
		   textra_field as ef on ef.extra_fieldid = efic.extra_fieldid 
		  ) as custom_fields_records
) as custom_fields
)
insert @A (Companyid,FieldId,Field,[Field fixed],Value,Row)
select Companyid,FieldId,Field,[Field fixed],Value,Row from cte;
with ext (Companyid,Field,[Field fixed],Value,FieldId)
as
(select 
c.Companyid,
case
when exists (select cc.* from @A cc where c.Field = cc.Field and cc.Row > 1)
  then c.Field + ' '+'ID'+cast(c.FieldId as varchar(20))
else   c.Field
end as   Field,
	   c.[Field fixed],
	   c.Value, 
	   c.FieldId
	   --c.Row
	   from @A c
) 
insert @B (Companyid,Field,[Field fixed],Value,FieldId)
select  Companyid,Field,[Field fixed],Value,FieldId  from ext
where   Companyid is not null
select distinct e.Companyid,e.Field,e.[Field fixed],
stuff((
select top 50 '; '+i.Value from @B i
         where i.companyid = e.companyid
		 and i.Fieldid= e.Fieldid
		 and i.Field= e.Field
         order by i.Value
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as Value
from @B e
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_CompanyFlag]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_Phase1_CompanyFlag]
as
select distinct c.companyid as CompanyID,c.flagvalue   as Value,c.flagcomments as Comments,
replace(left(t.flagtype ,100),']','|')  as Flag,
t.fixed as [Flag fixed] from tflagtype t
inner join tcompanyflags c
on
t.flagtypeid = c.flagtypeid
where c.companyid is not null
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_ContractCustomField]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_Phase1_ContractCustomField]
as
set nocount on
declare @A table
(pk_id bigint identity(1,1) primary key,
 Contractid bigint,
 FieldId bigint,
 Field nvarchar(4000),
 [Field fixed] nvarchar(4000),
 Value nvarchar(4000),
 Row int,
 UNIQUE CLUSTERED (field,pk_id)
 )
 declare @B table 
(
pk_id bigint identity(1,1) primary key,
Contractid bigint,
Field nvarchar(4000),
[Field fixed] nvarchar(4000),
Value nvarchar(4000),
FieldId bigint,
UNIQUE CLUSTERED (Contractid,fieldid,field,pk_id)
);
with cte (Contractid,FieldId,Field,[Field fixed],Value,Row)
as
(
select Contractid,
FieldId,
replace(left(FieldName,100),']','|') as Field,
Fixed as [Field fixed],
--FieldType,
FieldValue as Value,
--Level1,Level2,Level3,Level4,mik_valid
dense_rank() over(partition by replace(left(FieldName,100),']','|') order by Fieldid desc) AS Row
from 
(
		select  contractid, fieldtype as fieldtype, field_name as fieldname,fieldid, fixed,fieldvalue as fieldvalue, level1 as level1, level2 as level2, level3 as level3, 
							  level4 as level4, mik_valid
		from  (
			   select distinct 
						cfic_1.contractid,
						'client field' as fieldtype,
						cfic_1.clientfieldid as fieldid, 
						cfic_1.fixed as fixed,
						cfic_1.clientfield as field_name,
						cfic_1.clientfieldrangeincontractid as fieldincontractid,
						cfic_1.multivalue as fieldvalue, 
						cfic_1.level1id, 
						cfic_1.level1,
						cfic_1.level2id,
						cfic_1.level2,
						cfic_1.level3id,
						cfic_1.level3, 
						cfic_1.level4id,
						cfic_1.level4, 
						cfic_1.mik_valid
			from         
			(
			select     clf.clientfieldid,
			clf.clientfield,
			clf.fixed,
			cfic.contractid,
			cfic.clientfieldrangeincontractid,
			isnull(l1.level1, '') + isnull(', ' + l2.level2, '') + isnull(', ' + l3.level3, '') + isnull(', ' + l4.level4, '') as multivalue, 
			cfic.level1id, l1.level1, 
			cfic.level2id, l2.level2,
			cfic.level3id, l3.level3,
			cfic.level4id, l4.level4,
			clf.mik_valid
			from  tclientfield as clf 
			inner join    tobjecttype as ot on clf.objecttypeid = ot.objecttypeid and ot.fixed = 'contract'
			left outer join
			tclientfieldrange_in_contract as cfic
			on clf.clientfieldid = cfic.clientfieldid
			left outer join
			tlevel1 as l1 on cfic.level1id = l1.level1id left outer join
			tlevel2 as l2 on cfic.level2id = l2.level2id left outer join
			tlevel3 as l3 on cfic.level3id = l3.level3id left outer join
			tlevel4 as l4 on cfic.level4id = l4.level4id
			) as cfic_1 
			union
			select distinct 
						efic.contractid, 
					   'extra field' as fieldtype,
						efic.extra_fieldid as fieldid, 
						ef.fixed,
						ef.mik_label_text as fieldname,
						efic.extrafieldincontractid as fieldincontractid, 
						efic.mik_edit_value as fieldvalue,
						null as expr1,
						null as expr2,
						null as expr3,
						null as expr4,
						null as expr5,
						null as expr6, 
						null as expr7,
						null as expr8,
						ef.mik_valid
		   from   textra_field_in_contract as efic 
		   inner join
		   textra_field as ef on ef.extra_fieldid = efic.extra_fieldid 
		  ) as custom_fields_records
) as custom_fields
)
insert @A (Contractid,FieldId,Field,[Field fixed],Value,Row)
select Contractid,FieldId,Field,[Field fixed],Value,Row from cte;
with ext (Contractid,Field,[Field fixed],Value,FieldId)
as
(select 
c.Contractid,
case
when exists (select cc.* from @A cc where c.Field = cc.Field and cc.Row > 1)
  then c.Field + ' '+'ID'+cast(c.FieldId as varchar(20))
else   c.Field
end as   Field,
	   c.[Field fixed],
	   c.Value, 
	   c.FieldId
	   --c.Row
	   from @A c
) 
insert @B (Contractid,Field,[Field fixed],Value,FieldId)
select  Contractid,Field,[Field fixed],Value,FieldId  from ext
where   Contractid is not null
select distinct e.Contractid,e.Field,e.[Field fixed],
stuff((
select top 50 '; '+i.Value from @B i
         where i.contractid = e.contractid
		 and i.Fieldid= e.Fieldid
		 and i.Field= e.Field
         order by i.Value
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as Value
from @B e
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_ContractDepartmentRole]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_Phase1_ContractDepartmentRole]
as
select distinct 
ContractID,
cast(replace(left(departmentrole,100),']','|') as nvarchar(4000)) as Role,
cast(departmentrolefixed as nvarchar(4000)) as [Role fixed],
cast(department as nvarchar(4000)) as [Department],
cast(departmentcode as nvarchar(4000)) as [Code]
from vsearchsimplecontract 
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_ContractFlag]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_Phase1_ContractFlag]
as
select distinct c.contractid as ContractID,c.flagvalue   as Value,c.flagcomments as Comments,
replace(left(t.flagtype ,100),']','|')  as Flag,
t.fixed as [Flag fixed] from tflagtype t
inner join tcontractflags c
on
t.flagtypeid = c.flagtypeid
where c.contractid is not null
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_ContractMilestone]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_Phase1_ContractMilestone]
as
select distinct g.contractid as ContractID,
replace(left(t.Guaranteetemplatename,100),']','|') as Milestone, t.Fixed as [Milestone fixed],
CAST(DateAdd(hour, 12, g.GUARANTEEDATE) as Date)  as [Milestone date],
g.GUARANTEECOMMENT as Comment,
g.ESCALATION as [Escalation %],
round(a.Amount,0) as Value,
c.CURRENCY_CODE as [Value currency],
round(d.Amount,0) as [Value (display currency)]
from TGUARANTEETEMPLATE t
inner join TGUARANTEE g
on t.guaranteetemplateid = g.guaranteetemplateid
left join tamount a
on a.AmountId=g.AmountID
left join TCURRENCY c
on a.CurrencyId=c.CURRENCYID
left join VAmountInDefaultCurrency d
on a.AmountId=d.AmountId
where g.contractid is not null
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_ContractPersonRole]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_Phase1_ContractPersonRole]
as
select distinct 
ContractID,
cast(replace(left(personrole,100),']','|') as nvarchar(4000)) as Role,
cast(personrolefixed as nvarchar(4000)) as [Role fixed],
cast(tperson.firstname as nvarchar(4000))+' '+cast(tperson.lastname as nvarchar(4000)) as [Name],
cast(personemail as nvarchar(4000)) as [Email],
cast(personphone1 as nvarchar(4000)) as [Phone 1],
cast(personphone2 as nvarchar(4000)) as [Phone 2]
from vsearchsimplecontract 
inner join tperson 
on vsearchsimplecontract.personid = tperson.PERSONID
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_CustomProcessDepartmentRole]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_Phase1_CustomProcessDepartmentRole]
as
select distinct 
am.ContractID,
am.rprocessid as CustomProcessID,
cast(replace(left(r.role,100),']','|') as nvarchar(4000)) as Role,
cast(r.fixed as nvarchar(4000)) as [Role fixed],
cast(d.department as nvarchar(4000)) as [Department],
cast(d.department_code as nvarchar(4000)) as [Code]
from trprocess am
inner join tdepartmentrole_in_object tdo on am.rprocessid = tdo.objectid and tdo.objecttypeid in (select objecttypeid from tobjecttype where fixed = N'RPROCESS')
inner join trole r on tdo.roleid = r.roleid and r.isdepartmentrole = 1
inner join tdepartment d on d.departmentid = tdo.departmentid
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_CustomProcessPersonRole]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_Phase1_CustomProcessPersonRole]
as
select distinct 
am.ContractID,
am.rprocessid as CustomProcessID,
cast(replace(left(r.role,100),']','|') as nvarchar(4000)) as Role,
cast(r.fixed as nvarchar(4000)) as [Role fixed],
cast(vp.firstname as nvarchar(4000))+' '+cast(vp.lastname as nvarchar(4000)) as [Name],
cast(vp.email as nvarchar(4000)) as [Email],
cast(vp.phone1 as nvarchar(4000)) as [Phone 1],
cast(vp.phone2 as nvarchar(4000)) as [Phone 2]
from trprocess am
inner join tpersonrole_in_object tpo on am.rprocessid = tpo.objectid and tpo.objecttypeid in (select objecttypeid from tobjecttype where fixed = N'RPROCESS')
inner join trole r on tpo.roleid = r.roleid and r.ispersonrole = 1
inner join vperson vp on tpo.personid = vp.personid
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_OrderDepartmentRole]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_Phase1_OrderDepartmentRole]
as
select distinct 
o.ContractID,
o.OrderID,
cast(replace(left(r.role,100),']','|') as nvarchar(4000)) as Role,
cast(r.fixed as nvarchar(4000)) as [Role fixed],
cast(d.department as nvarchar(4000)) as [Department],
cast(d.department_code as nvarchar(4000)) as [Code]
from torder o
inner join tdepartmentrole_in_object tdo on o.orderid = tdo.objectid and tdo.objecttypeid in (select objecttypeid from tobjecttype where fixed = N'Order')
inner join trole r on tdo.roleid = r.roleid and r.isdepartmentrole = 1
inner join tdepartment d on d.departmentid = tdo.departmentid
where o.mik_valid = 1 
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_OrderPersonRole]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_Phase1_OrderPersonRole]
as
select distinct 
o.ContractID,
o.OrderID,
cast(replace(left(r.role,100),']','|') as nvarchar(4000)) as Role,
cast(r.fixed as nvarchar(4000)) as [Role fixed],
cast(vp.firstname as nvarchar(4000))+' '+cast(vp.lastname as nvarchar(4000)) as [Name],
cast(vp.email as nvarchar(4000)) as [Email],
cast(vp.phone1 as nvarchar(4000)) as [Phone 1],
cast(vp.phone2 as nvarchar(4000)) as [Phone 2]
from torder o 
inner join tpersonrole_in_object tpo on o.orderid = tpo.objectid and tpo.objecttypeid in (select objecttypeid from tobjecttype where fixed = N'Order')
inner join trole r on tpo.roleid = r.roleid and r.ispersonrole = 1
inner join vperson vp on tpo.personid = vp.personid
where o.mik_valid = 1
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_ProjectDepartmentRole]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_Phase1_ProjectDepartmentRole]
as
select distinct 
p.ProjectID,
cast(replace(left(r.role,100),']','|') as nvarchar(4000)) as Role,
cast(r.fixed as nvarchar(4000)) as [Role fixed],
cast(d.department as nvarchar(4000)) as [Department],
cast(d.department_code as nvarchar(4000)) as [Code]
from tproject p
inner join tdepartmentrole_in_object tdo on p.projectid = tdo.objectid and tdo.objecttypeid in (select objecttypeid from tobjecttype where fixed = N'Project')
inner join trole r on tdo.roleid = r.roleid and r.isdepartmentrole = 1
inner join tdepartment d on d.departmentid = tdo.departmentid
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_ProjectPersonRole]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_Phase1_ProjectPersonRole]
as
select distinct 
ProjectID,
cast(replace(left(personrole,100),']','|') as nvarchar(4000)) as Role,
cast(personrolefixed as nvarchar(4000)) as [Role fixed],
cast(tperson.firstname as nvarchar(4000))+' '+cast(tperson.lastname as nvarchar(4000)) as [Name],
cast(personemail as nvarchar(4000)) as [Email],
cast(personphone1 as nvarchar(4000)) as [Phone 1],
cast(personphone2 as nvarchar(4000)) as [Phone 2]
from vsearchsimpleproject
inner join tperson 
on vsearchsimpleproject.personid = tperson.PERSONID
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_RFxDepartmentRole]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_Phase1_RFxDepartmentRole]
as
select distinct 
rfx.ContractID,
rfx.RFxID,
cast(replace(left(r.role,100),']','|') as nvarchar(4000)) as Role,
cast(r.fixed as nvarchar(4000)) as [Role fixed],
cast(d.department as nvarchar(4000)) as [Department],
cast(d.department_code as nvarchar(4000)) as [Code]
from trfx rfx
inner join tdepartmentrole_in_object tdo on rfx.rfxid = tdo.objectid and tdo.objecttypeid in (select objecttypeid from tobjecttype where fixed = N'RFx')
inner join trole r on tdo.roleid = r.roleid and r.isdepartmentrole = 1
inner join tdepartment d on d.departmentid = tdo.departmentid
where rfx.ContractID is not null
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Phase1_RFxPersonRole]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_Phase1_RFxPersonRole]
as
select distinct 
rfx.ContractID,
rfx.RFxID,
cast(replace(left(r.role,100),']','|') as nvarchar(4000)) as Role,
cast(r.fixed as nvarchar(4000)) as [Role fixed],
cast(vp.firstname as nvarchar(4000))+' '+cast(vp.lastname as nvarchar(4000)) as [Name],
cast(vp.email as nvarchar(4000)) as [Email],
cast(vp.phone1 as nvarchar(4000)) as [Phone 1],
cast(vp.phone2 as nvarchar(4000)) as [Phone 2]
from trfx rfx
inner join tpersonrole_in_object tpo on rfx.rfxid = tpo.objectid and tpo.objecttypeid in (select objecttypeid from tobjecttype where fixed = N'RFx')
inner join trole r on tpo.roleid = r.roleid and r.ispersonrole = 1
inner join vperson vp on tpo.personid = vp.personid
where rfx.ContractID is not null
GO
/****** Object:  StoredProcedure [dbo].[usp_get_PreQualification]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_PreQualification]
as
select distinct
a.AssessmentID as [Pre-qualificationID],
a.ownerobjectid as [CompanyID],
ct.description as [Template (Pre-qualification)],
(select description from tassessmentcriterion where assessmentid = a.assessmentid and criterionlevel = 0) as [Assessment name (Pre-qualification)],
cast(a.assessmentdate as date)  as [Assessment date (Pre-qualification)],
stuff((
select top 50 '; ' + gn.productgroupnomenclature + ': '+stuff((
	select top 50 ', ' + isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
	from tproductgroup g inner join tprod_group_in_assessment gc
	on g.productgroupid = gc.productgroupid
	where g.productgroupnomenclatureid = gn.productgroupnomenclatureid  and gc.assessmentid = a.assessmentid
    order by isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
from tproductgroupnomenclature gn
order by gn.productgroupnomenclature
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Product and service groups (Pre-qualification)],
a.comments as [Comment (Pre-qualification)],
vab.minscore as [Min. score (Pre-qualification)],
vab.MaxScore as [Max score (Pre-qualification)],
vab.score [Score (Pre-qualification)],
isnull(vu.firstname,'')+' '+isnull(vu.lastname,'') as [Owner (Pre-qualification)],
cast(dateadd(hour, 12,a.expiry_date) as date) as  [Expiry date (Pre-qualification)],
case when a.qualified = 1 then N'Yes' else N'No' end as [Qualified (Pre-qualification)],
s.status as  [Status (Pre-qualification)],
att.assessmenttemplatetype as [Template group (Pre-qualification)] 
from tassessment a
inner join tevaluationtype ev on a.evaluationtypeid = ev.evaluationtypeid and ev.fixed = N'TENDER_PREQUALIFICATION'
left join tstatus s on s.statusid = a.statusid
left join tassessmentcriterion ac on a.assessmentid = ac.assessmentid
left join vuser vu on a.userid_owner = vu.userid 
left join tassessment_template at on at.assessmenttemplateid = a.assessmenttemplateid
left join tassessmenttemplatetype att on att.assessmenttemplatetypeid = at.assessmenttemplatetypeid
left join vassessment_base vab on vab.assessmentid = a.assessmentid
left join tcriterion_template ct on ct.assessmenttemplateid = at.assessmenttemplateid  and ct.parentid is null
where a.ownerobjecttypeid in (select objecttypeid from tobjecttype where fixed = N'Company')
and exists (select * from tcompany where companyid = a.ownerobjectid)
order by a.assessmentid
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Procedure]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_Procedure]
as
select distinct strategytype  as [procedure] from tstrategytype
where 	strategytypeid > 0 and mik_valid > 0
and 	strategytype is not null and  strategytype !=''
GO
/****** Object:  StoredProcedure [dbo].[usp_get_ProductGroup]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_ProductGroup]
as
select distinct 
	p.productgroupid as productgroupid,
	p.productgroup   as productgroup,
	p.productgroupcode as code,
	n.productgroupnomenclatureid as	nomenclatureid,
	n.productgroupnomenclature   as	nomenclature
 from tproductgroup p
inner join tproductgroupnomenclature n
on p.productgroupnomenclatureid = n.productgroupnomenclatureid
where 	p.productgroupid > 0 and p.mik_valid > 0 and n.mik_valid > 0
and 	p.productgroup  is not null and  p.productgroup  !=''
order by n.productgroupnomenclatureid,p.productgroupcode
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Project]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_Project]
as
;with parent_project_cte as (
  select projectid, parentid, project, 0 level, convert(nvarchar(4000), project) as path, projectid as root from tproject where parentid is null
  union all
  select t.projectid, t.parentid, t.project, e.level + 1 as level, convert(nvarchar(4000),e.path + '\'+ convert(nvarchar(4000),t.project)) as path, e.root
  from parent_project_cte e
  join tproject t on t.parentid=e.projectid
),
vw_ContractEstimatedValue (projectid, Value, [Value currency],[Value (display currency)],ContractRelation)
as
(
select coinpro.projectid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(sum(vc.EstimatedValue),0) as  [Value (display currency)],
N'PURCHASE' as ContractRelation
from tamount a inner join tcontract co on a.amountid=co.estimatedvalueamountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =co.contractid
inner join tcontract_in_project coinpro on coinpro.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
where cr.fixed = N'PURCHASE'
group by coinpro.projectid
union all
select coinpro.projectid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(sum(vc.EstimatedValue),0) as  [Value (display currency)],
N'SALES' as ContractRelation
from tamount a inner join tcontract co on a.amountid=co.estimatedvalueamountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =co.contractid
inner join tcontract_in_project coinpro on coinpro.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
where cr.fixed = N'SALES'
group by coinpro.projectid
),
vw_ContractApprovedBudget (projectid, Value, [Value currency],[Value (display currency)],ContractRelation)
as
(
select coinpro.projectid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(sum(vc.ApprovedBudget),0) as  [Value (display currency)],
N'PURCHASE' as ContractRelation
from tamount a inner join tcontract co on a.amountid=co.approvedvalueamountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =co.contractid
inner join tcontract_in_project coinpro on coinpro.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
where cr.fixed = N'PURCHASE'
group by coinpro.projectid
union all
select coinpro.projectid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(sum(vc.ApprovedBudget),0) as  [Value (display currency)],
N'SALES' as ContractRelation
from tamount a inner join tcontract co on a.amountid=co.approvedvalueamountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =co.contractid
inner join tcontract_in_project coinpro on coinpro.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
where cr.fixed = N'SALES'
group by coinpro.projectid
),
vw_ContractOriginal (projectid, Value, [Value currency],[Value (display currency)],ContractRelation)
as
(
select coinpro.projectid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(sum(vc.ReimbExpenseLimit),0) as  [Value (display currency)],
N'PURCHASE' as ContractRelation
from tamount a inner join tcontract co on a.amountid=co.ProvisionalSumAmountID
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =co.contractid
inner join tcontract_in_project coinpro on coinpro.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
where cr.fixed = N'PURCHASE'
group by coinpro.projectid
union all
select coinpro.projectid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(sum(vc.ReimbExpenseLimit),0) as  [Value (display currency)],
N'SALES' as ContractRelation
from tamount a inner join tcontract co on a.amountid=co.ProvisionalSumAmountID
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =co.contractid
inner join tcontract_in_project coinpro on coinpro.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
where cr.fixed = N'SALES'
group by coinpro.projectid
),
vw_SumAmendments (projectid, Value, [Value currency],[Value (display currency)],ContractRelation)
as
(
select coinpro.projectid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(sum(vc.SumApprovedAmendments),0) as  [Value (display currency)],
N'PURCHASE' as ContractRelation
from tamount a inner join tamendment am  on a.amountid=am.AmountID
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =am.contractid
inner join tcontract_in_project coinpro on coinpro.contractid = am.contractid
inner join tcontract co on am.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
where cr.fixed = N'PURCHASE' and am.statusid in (select statusid from tstatus where fixed in ('ACTIVE', 'SIGNED', 'EXPIRED'))
group by coinpro.projectid
union all
select coinpro.projectid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(sum(vc.SumApprovedAmendments),0) as  [Value (display currency)],
N'SALES' as ContractRelation
from tamount a inner join tamendment am  on a.amountid=am.AmountID
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =am.contractid
inner join tcontract_in_project coinpro on coinpro.contractid = am.contractid
inner join tcontract co on am.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
where cr.fixed = N'SALES' and am.statusid in (select statusid from tstatus where fixed in ('ACTIVE', 'SIGNED', 'EXPIRED'))
group by coinpro.projectid
),
vw_SumVOs (projectid, Value, [Value currency],[Value (display currency)],ContractRelation)
as
(
select coinpro.projectid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(sum(vc.SumApprovedVO),0) as  [Value (display currency)],
N'PURCHASE' as ContractRelation
from tamount a inner join tvo am  on a.amountid=am.settlementamountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =am.contractid
inner join tcontract_in_project coinpro on coinpro.contractid = am.contractid
inner join tcontract co on am.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
where cr.fixed = N'PURCHASE' and am.statusid not in (select statusid from tstatus where fixed in ('CANCELLED'))
group by coinpro.projectid
union all
select coinpro.projectid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(sum(vc.SumApprovedVO),0) as  [Value (display currency)],
N'SALES' as ContractRelation
from tamount a inner join tvo am  on a.amountid=am.settlementamountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =am.contractid
inner join tcontract_in_project coinpro on coinpro.contractid = am.contractid
inner join tcontract co on am.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
where cr.fixed = N'SALES' and am.statusid not in (select statusid from tstatus where fixed in ('CANCELLED'))
group by coinpro.projectid
),
vw_SumDeclaredOptions (projectid, Value, [Value currency],[Value (display currency)],ContractRelation)
as
(
select coinpro.projectid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(sum(vc.SumOptionalExtentionAmount),0) as  [Value (display currency)],
N'PURCHASE' as ContractRelation
from tamount a inner join toption am  on a.amountid=am.estimatedamountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =am.contractid
inner join tcontract_in_project coinpro on coinpro.contractid = am.contractid
inner join tcontract co on am.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
where cr.fixed = N'PURCHASE' and am.declared =1
group by coinpro.projectid
union all
select coinpro.projectid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(sum(vc.SumOptionalExtentionAmount),0) as  [Value (display currency)],
N'SALES' as ContractRelation
from tamount a inner join toption am  on a.amountid=am.estimatedamountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =am.contractid
inner join tcontract_in_project coinpro on coinpro.contractid = am.contractid
inner join tcontract co on am.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
where cr.fixed = N'SALES' and am.declared =1
group by coinpro.projectid
),
vw_SumOrders (projectid, Value, [Value currency],[Value (display currency)],ContractRelation)
as
(
select coinpro.projectid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(sum(vc.SumApprovedOrders),0) as  [Value (display currency)],
N'PURCHASE' as ContractRelation
from tamount a inner join torder am  on a.amountid=am.amountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =am.contractid
inner join tcontract_in_project coinpro on coinpro.contractid = am.contractid
inner join tcontract co on am.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
where cr.fixed = N'PURCHASE' and am.statusid in (select statusid from tstatus where fixed in ('active', 'ordered', 'deliveredexpired'))
group by coinpro.projectid
union all
select coinpro.projectid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(sum(vc.SumApprovedOrders),0) as  [Value (display currency)],
N'SALES' as ContractRelation
from tamount a inner join torder am  on a.amountid=am.amountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =am.contractid
inner join tcontract_in_project coinpro on coinpro.contractid = am.contractid
inner join tcontract co on am.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
where cr.fixed = N'SALES' and am.statusid in (select statusid from tstatus where fixed in ('active', 'ordered', 'deliveredexpired'))
group by coinpro.projectid
),
vw_LumpSum (projectid, Value, [Value currency],[Value (display currency)],ContractRelation)
as
(
select coinpro.projectid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(sum(vc.LumpSum),0) as  [Value (display currency)],
N'PURCHASE' as ContractRelation
from tamount a inner join tcontract co on a.amountid=co.LumpSumAmountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =co.contractid
inner join tcontract_in_project coinpro on coinpro.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
where cr.fixed = N'PURCHASE'
group by coinpro.projectid
union all
select coinpro.projectid,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as Value,
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [Value currency],
round(sum(vc.LumpSum),0) as  [Value (display currency)],
N'SALES' as ContractRelation
from tamount a inner join tcontract co on a.amountid=co.LumpSumAmountid
inner join tcurrency c   on a.currencyid = c.currencyid
inner join vcommercial vc on vc.contractid =co.contractid
inner join tcontract_in_project coinpro on coinpro.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
where cr.fixed = N'SALES'
group by coinpro.projectid
),
vw_InvoiceableCommitment (projectid, Value, [Value currency],[Value (display currency)],ContractRelation)
as
(
select coinpro.projectid,
case when 
          count(distinct ls.[Value currency])  > 1
       or count(distinct saa.[Value currency]) > 1
	   or count(distinct svo.[Value currency]) > 1
	   or count(distinct soex.[Value currency])> 1
	   or count(distinct re.[Value currency])  > 1
then -1 
 else round(sum(isnull(ls.[value],0)+isnull(saa.[value],0)+isnull(svo.[value],0)+isnull(soex.[value],0)+isnull(re.[value],0)),0) 
end as Value,
case when 
          count(distinct ls.[Value currency])  > 1
       or count(distinct saa.[Value currency]) > 1
	   or count(distinct svo.[Value currency]) > 1
	   or count(distinct soex.[Value currency])> 1
	   or count(distinct re.[Value currency])  > 1
then 'MULTI'
 else min(coalesce(ls.[Value currency],saa.[Value currency],svo.[Value currency],soex.[Value currency],re.[Value currency]))
end as [Value currency],
round(sum(vc.InvoiceableCommitment),0) as  [Value (display currency)],
N'PURCHASE' as ContractRelation
from  tcontract_in_project coinpro
inner join tcontract co  on coinpro.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
left  join vcommercial vc on vc.contractid = co.contractid
left join vw_LumpSum ls on ls.projectid = coinpro.projectid
left join vw_SumAmendments saa on saa.projectid = coinpro.projectid
left join vw_SumVOs svo on svo.projectid = coinpro.projectid
left join vw_SumDeclaredOptions soex on soex.projectid = coinpro.projectid
left join vw_ContractOriginal re on re.projectid = coinpro.projectid
where cr.fixed = N'PURCHASE'
group by coinpro.projectid
union
select coinpro.projectid,
case when
          count(distinct ls.[Value currency])  > 1
       or count(distinct saa.[Value currency]) > 1
	   or count(distinct svo.[Value currency]) > 1
	   or count(distinct soex.[Value currency])> 1
	   or count(distinct re.[Value currency])  > 1
then -1 
 else round(sum(isnull(ls.[value],0)+isnull(saa.[value],0)+isnull(svo.[value],0)+isnull(soex.[value],0)+isnull(re.[value],0)),0) 
end as Value,
case when
          count(distinct ls.[Value currency])  > 1
       or count(distinct saa.[Value currency]) > 1
	   or count(distinct svo.[Value currency]) > 1
	   or count(distinct soex.[Value currency])> 1
	   or count(distinct re.[Value currency])  > 1

then 'MULTI'
 else min(coalesce(ls.[Value currency],saa.[Value currency],svo.[Value currency],soex.[Value currency],re.[Value currency]))
end as [Value currency],
round(sum(vc.InvoiceableCommitment),0) as  [Value (display currency)],
N'SALES' as ContractRelation
from  tcontract_in_project coinpro
inner join tcontract co  on coinpro.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
left  join vcommercial vc on vc.contractid = co.contractid
left join vw_LumpSum ls on ls.projectid = coinpro.projectid
left join vw_SumAmendments saa on saa.projectid = coinpro.projectid
left join vw_SumVOs svo on svo.projectid = coinpro.projectid
left join vw_SumDeclaredOptions soex on soex.projectid = coinpro.projectid
left join vw_ContractOriginal re on re.projectid = coinpro.projectid
where cr.fixed = N'SALES'
group by coinpro.projectid
),
vw_Remaining (projectid, Value, [Value currency],[Value (display currency)],ContractRelation)
as
(
select coinpro.projectid,
case when
          count(distinct ls.[Value currency])  > 1
       or count(distinct saa.[Value currency]) > 1
	   or count(distinct svo.[Value currency]) > 1
	   or count(distinct soex.[Value currency])> 1
	   or count(distinct re.[Value currency])  > 1
	   or count(distinct so.[Value currency])  > 1
then -1 
 else round(sum(isnull(ls.[value],0)+isnull(saa.[value],0)+isnull(svo.[value],0)+isnull(soex.[value],0)+isnull(re.[value],0)-isnull(so.[value],0)),0) 
end as Value,
case when 
   count(distinct ls.[Value currency])  > 1
       or count(distinct saa.[Value currency]) > 1
	   or count(distinct svo.[Value currency]) > 1
	   or count(distinct soex.[Value currency])> 1
	   or count(distinct re.[Value currency])  > 1
	   or count(distinct so.[Value currency])  > 1
then 'MULTI'
 else min(coalesce(ls.[Value currency],saa.[Value currency],svo.[Value currency],soex.[Value currency],re.[Value currency]))
end as [Value currency],
round(sum(vc.RemainingValue),0) as  [Value (display currency)],
N'PURCHASE' as ContractRelation
from  tcontract_in_project coinpro
inner join tcontract co  on coinpro.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
left join vcommercial vc on vc.contractid = co.contractid
left join vw_LumpSum ls on ls.projectid = coinpro.projectid
left join vw_SumAmendments saa on saa.projectid = coinpro.projectid
left join vw_SumVOs svo on svo.projectid = coinpro.projectid
left join vw_SumDeclaredOptions soex on soex.projectid = coinpro.projectid
left join vw_ContractOriginal re on re.projectid = coinpro.projectid
left join vw_SumOrders so on so.projectid = coinpro.projectid
where cr.fixed = N'PURCHASE'
group by coinpro.projectid
union
select coinpro.projectid,
case when
   count(distinct ls.[Value currency])  > 1
       or count(distinct saa.[Value currency]) > 1
	   or count(distinct svo.[Value currency]) > 1
	   or count(distinct soex.[Value currency])> 1
	   or count(distinct re.[Value currency])  > 1
	   or count(distinct so.[Value currency])  > 1
then -1 
 else round(sum(isnull(ls.[value],0)+isnull(saa.[value],0)+isnull(svo.[value],0)+isnull(soex.[value],0)+isnull(re.[value],0)),0) 
end as Value,
case when
   count(distinct ls.[Value currency])  > 1
       or count(distinct saa.[Value currency]) > 1
	   or count(distinct svo.[Value currency]) > 1
	   or count(distinct soex.[Value currency])> 1
	   or count(distinct re.[Value currency])  > 1
	   or count(distinct so.[Value currency])  > 1
then 'MULTI'
 else min(coalesce(ls.[Value currency],saa.[Value currency],svo.[Value currency],soex.[Value currency],re.[Value currency]))
end as [Value currency],
round(sum(vc.RemainingValue),0) as  [Value (display currency)],
N'SALES' as ContractRelation
from  tcontract_in_project coinpro
inner join tcontract co  on coinpro.contractid = co.contractid
inner join tcontractrelation cr on cr.contractrelationid = co.contractrelationid
left join vcommercial vc on vc.contractid = co.contractid
left join vw_LumpSum ls on ls.projectid = coinpro.projectid
left join vw_SumAmendments saa on saa.projectid = coinpro.projectid
left join vw_SumVOs svo on svo.projectid = coinpro.projectid
left join vw_SumDeclaredOptions soex on soex.projectid = coinpro.projectid
left join vw_ContractOriginal re on re.projectid = coinpro.projectid
left join vw_SumOrders so on so.projectid = coinpro.projectid
where cr.fixed = N'SALES'
group by coinpro.projectid
)
select 
p.ProjectID,
p.ParentID,
p.project as [Name (Project)],
p.project_number as [Number (Project)],
p.project_description as [Description (Project)],
CAST(DateAdd(hour, 12, p.project_start_date) as Date)  as  [Start date (Project)],
CAST(DateAdd(hour, 12, p.project_end_date) as Date)  as [End date (Project)],
pt.projecttype as [Type (Project)],
s.status as [Status (Project)],
p.referencenumber as [Reference number (Project)],
case when p.ParentID is null then N'No' else N'Yes' end as [Subproject (Project)],
(select count(projectid) from tproject where parentid = p.projectid) as [Number of subprojects (Project)],
stuff((select top 50 '; '+isnull(project_number,'')+' '+project from tproject where parentid = p.projectid order by project_number for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')  as [List of subprojects (Project)],
(select isnull(project_number,'')+' '+project from tproject where projectid = p.parentid) as [Parent project (Project)],
 pcte.path as  [Path to top project (Project)]

--vw_ContractEstimatedValue_Purshase.Value as [Estimated value of purchasing contracts (Project)],
--vw_ContractEstimatedValue_Purshase.[Value currency] as [Estimated value currency of purchasing contracts (Project)],
--vw_ContractEstimatedValue_Purshase.[Value (display currency)] as [Estimated value (display currency) of purchasing contracts (Project)],
--vw_ContractEstimatedValue_Sales.Value as [Estimated value of sales contracts (Project)],
--vw_ContractEstimatedValue_Sales.[Value currency] as [Estimated value currency of sales contracts (Project)],
--vw_ContractEstimatedValue_Sales.[Value (display currency)] as [Estimated value (display currency) of sales contracts (Project)],
--vw_ContractApprovedBudget_Purshase.Value as [Budget of purchasing contracts (Project)],
--vw_ContractApprovedBudget_Purshase.[Value currency] as [Budget currency of purchasing contracts (Project)],
--vw_ContractApprovedBudget_Purshase.[Value (display currency)] as [Budget (display currency) of purchasing contracts (Project)],
--vw_ContractApprovedBudget_Sales.Value as [Budget of sales contracts (Project)],
--vw_ContractApprovedBudget_Sales.[Value currency] as  [Budget currency of sales contracts (Project)],
--vw_ContractApprovedBudget_Sales.[Value (display currency)] as  [Budget (display currency) of sales contracts (Project)],
--vw_ContractOriginal_Purshase.Value as  [Original contract value of purchasing contracts (Project)],
--vw_ContractOriginal_Purshase.[Value currency] as [Original contract value currency of purchasing contracts (Project)],
--vw_ContractOriginal_Purshase.[Value (display currency)] as  [Original contract value (display currency) of purchasing contracts (Project)],
--vw_ContractOriginal_Sales.Value as [Original contract value of sales contracts (Project)],
--vw_ContractOriginal_Sales.[Value currency] as [Original contract value currency of sales contracts (Project)],
--vw_ContractOriginal_Sales.[Value (display currency)] as [Original contract value (display currency) of sales contracts (Project)],
--vw_SumAmendments_Purshase.Value as [Sum of amendments of purchasing contracts (Project)],
--vw_SumAmendments_Purshase.[Value currency] as [Sum of amendments currency of purchasing contracts (Project)],
--vw_SumAmendments_Purshase.[Value (display currency)] as [Sum of amendments (display currency) of purchasing contracts (Project)],
--vw_SumAmendments_Sales.Value as [Sum of amendments of sales contracts (Project)],
--vw_SumAmendments_Sales.[Value currency] as [Sum of amendments currency of sales contracts (Project)],
--vw_SumAmendments_Sales.[Value (display currency)] as [Sum of amendments (display currency) of sales contracts (Project)],
--vw_SumVOs_Purshase.Value as [Sum of VOs of purchasing contracts (Project)],
--vw_SumVOs_Purshase.[Value currency] as [Sum of VOs currency of purchasing contracts (Project)],
--vw_SumVOs_Purshase.[Value (display currency)] as [Sum of VOs (display currency) of purchasing contracts (Project)],
--vw_SumVOs_Sales.Value as [Sum of VOs of sales contracts (Project)],
--vw_SumVOs_Sales.[Value currency] as [Sum of VOs currency of sales contracts (Project)],
--vw_SumVOs_Sales.[Value (display currency)] as [Sum of VOs (display currency) of sales contracts (Project)],
--vw_SumDeclaredOptions_Purshase.Value as [Sum of declared options of purchasing contracts (Project)],
--vw_SumDeclaredOptions_Purshase.[Value currency] as [Sum of declared options currency of purchasing contracts (Project)],
--vw_SumDeclaredOptions_Purshase.[Value (display currency)] as [Sum of declared options (display currency) of purchasing contracts (Project)],
--vw_SumDeclaredOptions_Sales.Value as [Sum of declared options of sales contracts (Project)],
--vw_SumDeclaredOptions_Sales.[Value currency] as [Sum of declared options currency of sales contracts (Project)],
--vw_SumDeclaredOptions_Sales.[Value (display currency)] as [Sum of declared options (display currency) of sales contracts (Project)],
--vw_InvoiceableCommitment_Purshase.Value as [Invoiceable commitment of purchasing contracts (Project)],
--vw_InvoiceableCommitment_Purshase.[Value currency] as [Invoiceable commitment currency of purchasing contracts (Project)],
--vw_InvoiceableCommitment_Purshase.[Value (display currency)] as [Invoiceable commitment (display currency) of purchasing contracts (Project)],
--vw_InvoiceableCommitment_Sales.Value as [Invoiceable commitment of sales contracts (Project)],
--vw_InvoiceableCommitment_Sales.[Value currency] as [Invoiceable commitment currency of sales contracts (Project)],
--vw_InvoiceableCommitment_Sales.[Value (display currency)] as [Invoiceable commitment (display currency) of sales contracts (Project)],
--vw_SumOrders_Purshase.Value as [Sum of orders of purchasing contracts (Project)],
--vw_SumOrders_Purshase.[Value currency] as [Sum of orders currency of purchasing contracts (Project)],
--vw_SumOrders_Purshase.[Value (display currency)] as [Sum of orders (display currency) of purchasing contracts (Project)],
--vw_SumOrders_Sales.Value as [Sum of orders of sales contracts (Project)],
--vw_SumOrders_Sales.[Value currency] as [Sum of orders currency of sales contracts (Project)],
--vw_SumOrders_Sales.[Value (display currency)] as [Sum of orders (display currency) of sales contracts (Project)],
--vw_Remaining_Purshase.Value as [Remaining value of purchasing contracts (Project)],
--vw_Remaining_Purshase.[Value currency] as [Remaining value currency of purchasing contracts (Project)],
--vw_Remaining_Purshase.[Value (display currency)] as [Remaining value (display currency) of purchasing contracts (Project)],
--vw_Remaining_Sales.Value as [Remaining value of sales contracts (Project)],
--vw_Remaining_Sales.[Value currency] as  [Remaining value currency of sales contracts (Project)],
--vw_Remaining_Sales.[Value (display currency)] as [Remaining value (display currency) of sales contracts (Project)]

from tproject p
left join tprojecttype pt on p.projecttypeid = pt.projecttypeid 
left join tstatus s on p.statusid = s.statusid 
left join parent_project_cte pcte on pcte.projectid = p.parentid

left join vw_ContractEstimatedValue vw_ContractEstimatedValue_Purshase on vw_ContractEstimatedValue_Purshase.projectid = p.projectid and vw_ContractEstimatedValue_Purshase.ContractRelation = 'Purchase'
left join vw_ContractEstimatedValue vw_ContractEstimatedValue_Sales on    vw_ContractEstimatedValue_Sales.projectid = p.projectid and vw_ContractEstimatedValue_Sales.ContractRelation = 'Sales'

left join vw_ContractApprovedBudget vw_ContractApprovedBudget_Purshase on vw_ContractApprovedBudget_Purshase.projectid = p.projectid and vw_ContractApprovedBudget_Purshase.ContractRelation = 'Purchase'
left join vw_ContractApprovedBudget vw_ContractApprovedBudget_Sales    on vw_ContractApprovedBudget_Sales.projectid = p.projectid and vw_ContractApprovedBudget_Sales.ContractRelation = 'Sales'

left join vw_ContractOriginal vw_ContractOriginal_Purshase on vw_ContractOriginal_Purshase.projectid = p.projectid and vw_ContractOriginal_Purshase.ContractRelation = 'Purchase'
left join vw_ContractOriginal vw_ContractOriginal_Sales    on vw_ContractOriginal_Sales.projectid = p.projectid and vw_ContractOriginal_Sales.ContractRelation = 'Sales'

left join vw_SumAmendments vw_SumAmendments_Purshase on vw_SumAmendments_Purshase.projectid = p.projectid and vw_SumAmendments_Purshase.ContractRelation = 'Purchase'
left join vw_SumAmendments vw_SumAmendments_Sales    on vw_SumAmendments_Sales.projectid = p.projectid    and vw_SumAmendments_Sales.ContractRelation = 'Sales'

left join vw_SumVOs vw_SumVOs_Purshase on vw_SumVOs_Purshase.projectid = p.projectid and vw_SumVOs_Purshase.ContractRelation = 'Purchase'
left join vw_SumVOs vw_SumVOs_Sales    on vw_SumVOs_Sales.projectid = p.projectid    and vw_SumVOs_Sales.ContractRelation = 'Sales'

left join vw_SumDeclaredOptions vw_SumDeclaredOptions_Purshase on vw_SumDeclaredOptions_Purshase.projectid = p.projectid and vw_SumDeclaredOptions_Purshase.ContractRelation = 'Purchase'
left join vw_SumDeclaredOptions vw_SumDeclaredOptions_Sales    on vw_SumDeclaredOptions_Sales.projectid = p.projectid    and vw_SumDeclaredOptions_Sales.ContractRelation = 'Sales'

left join vw_SumOrders vw_SumOrders_Purshase on vw_SumOrders_Purshase.projectid = p.projectid and vw_SumOrders_Purshase.ContractRelation = 'Purchase'
left join vw_SumOrders vw_SumOrders_Sales    on vw_SumOrders_Sales.projectid = p.projectid    and vw_SumOrders_Sales.ContractRelation = 'Sales'

left join vw_InvoiceableCommitment vw_InvoiceableCommitment_Purshase on vw_InvoiceableCommitment_Purshase.projectid = p.projectid and vw_InvoiceableCommitment_Purshase.ContractRelation = 'Purchase'
left join vw_InvoiceableCommitment vw_InvoiceableCommitment_Sales    on vw_InvoiceableCommitment_Sales.projectid = p.projectid    and vw_InvoiceableCommitment_Sales.ContractRelation = 'Sales'

left join vw_Remaining vw_Remaining_Purshase on vw_Remaining_Purshase.projectid = p.projectid and vw_Remaining_Purshase.ContractRelation = 'Purchase'
left join vw_Remaining vw_Remaining_Sales    on vw_Remaining_Sales.projectid = p.projectid    and vw_Remaining_Sales.ContractRelation = 'Sales'
GO
/****** Object:  StoredProcedure [dbo].[usp_get_ProjectACL]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_ProjectACL] 
as 
select ta.objectid as projectid,ta.userid,tu.domainnetbiosusername from tacl ta (nolock)
inner join tuser tu
on  ta.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null
and tu.mik_valid = 1 
where 
ta.objecttypeid in (select tobjecttype.objecttypeid
                                    from   tobjecttype
                                    where  fixed = 'project'
									)
and ta.privilegeid = 1
and ta.userid is not null
union 
select objectid as projectid,ug.userid,tu.domainnetbiosusername
from tacl ta (nolock)
inner join tuser_in_usergroup ug (nolock)
on ug.usergroupid = ta.groupid
inner join tuser tu
on ug.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null            
and tu.mik_valid = 1 
where 
ta.objecttypeid in (select tobjecttype.objecttypeid
                                    from   tobjecttype
                                    where  fixed = 'project'
									)
and ta.privilegeid = 1
and ug.userid is not null
GO
/****** Object:  StoredProcedure [dbo].[usp_get_ProjectType]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_ProjectType]
as
select distinct ProjectType   from tprojecttype
where 	projecttypeid > 0 and mik_valid > 0
and 	projecttype is not null and  projecttype !=''
GO
/****** Object:  StoredProcedure [dbo].[usp_get_RFx]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_RFx]
as
declare @RFxObjectTypeID bigint
select  @RFxObjectTypeID=objecttypeid from tobjecttype where fixed = N'RFx'
declare @BidderObjectTypeID bigint
select  @BidderObjectTypeID = objecttypeid from tobjecttype where fixed = N'TENDERER'

declare @RFxPublishedDocumentFolderFixed varchar(50)
declare @RFxPublishedDocumentFolderRootId int
select  @RFxPublishedDocumentFolderFixed= settingvalue from tprofilesetting 
where 
profilekeyid in (select  profilekeyid from tprofilekey where FIXED = 'RFX_PUBLISHED_DOCUMENTS_FOLDER')
select @RFxPublishedDocumentFolderRootId = documenttypeid from tdocumenttype
where fixed = @RFxPublishedDocumentFolderFixed;
with invited 
as 
(
select i.rfxid,ip.companyname,s.status,ip.firstname+' '+ip.lastname as primcontact,ip.country,sl.comment as declinecomment,ip.companyno as companynumber,sl.logdate from trfxinterest i 
left join trfxinterestedparty ip on i.rfxinterestedpartyid = ip.rfxinterestedpartyid
left join trfxintereststatuslog sl on i.rfxinterestid = sl.rfxinterestid
left join tstatus s on s.statusid = sl.statusid
where 
i.rfxinterestedpartyid is not null 
--and i.rfxid = @rfxid 
and (sl.logdate = (select max(logdate) from trfxintereststatuslog where rfxinterestid = i.rfxinterestid) or sl.logdate is null)
union 
select i.rfxid,c.company as companyname,s.status,u.firstname+' '+u.lastname as primcontact,co.country,sl.comment as declinecomment,c.companyno as companynumber,sl.logdate from trfxinterest i 
left join tcompany c on i.companyid = c.companyid
left join trfxintereststatuslog sl on i.rfxinterestid = sl.rfxinterestid
left join tstatus s on s.statusid = sl.statusid
left join vuser u on u.userid = i.primarycompanycontactuserid
left join tcompanyaddress ca on c.companyid = ca.companyid
left join tcountry co on ca.countryid=co.countryid
left join taddresstype at on ca.addresstypeid = at.addresstypeid
where 
at.fixed = 'MAINADDRESS' and
i.rfxinterestedpartyid is null 
--and i.rfxid = @rfxid 
and (sl.logdate = (select max(logdate) from trfxintereststatuslog where rfxinterestid = i.rfxinterestid) or sl.logdate is null)
),
bidders
as
(
select t.rfxid,c.company as companyname,c.companyno as companynumber,p.displayname as primcontact,con.country,
round(am.amount,0) as [Bidders commercial value (RFx)],
round(evc.amount,0)  as [Bidders commercial value (display currency) (RFx)],
ec.currency_code  as [Bidders commercial value currency code (RFx)],
s.status as status,
(select top 1  score from tassessmentscore 
 where assessmentcriterionid in (
                           select  assessmentcriterionid from tassessmentcriterion 
						   where parentid is null and 
                           assessmentid in (
                                           select ass.assessmentid from tassessment ass inner join tevaluationtype et on ass.evaluationtypeid = et.evaluationtypeid
				                           where et.fixed = 'TENDER_EVALUATION'
				                           and ass.ownerobjecttypeid = @RFxObjectTypeID --rfxtype
				                           and ass.ownerobjectid = t.rfxid --rfx
                                            )

                                )
and assessmentobjectid in (
								select  assessmentobjectid from tassessmentobject aso
								where  aso.assessmentid in
								(
												 select ass.assessmentid from tassessment ass inner join tevaluationtype et on ass.evaluationtypeid = et.evaluationtypeid
												 where et.fixed = 'TENDER_EVALUATION'
												 and ass.ownerobjecttypeid = @RFxObjectTypeID --rfxtype
												 and ass.ownerobjectid = t.rfxid --rfx
												 )
								and assessedobjectid     = t.tendererid          --tendererid
								and assessedobjecttypeid = @BidderObjectTypeID    --tenderertype


                          )) as Score,
(
select count(d.documentid) from tdocument d inner join tdocumenttype dt on d.documenttypeid = dt.documenttypeid
where 
d.objecttypeid = @BidderObjectTypeID  and d.objectid = t.tendererid and 
d.documenttypeid in (select documenttypeid from tdocumenttype where fixed = N'RFX_UPLOADEDBIDDOCUMENTS' and objecttypeid = @BidderObjectTypeID )
) as DocumentCount
from ttenderer t
left join tcompany c on t.companyid = c.companyid
left join tstatus s on t.statusid = s.statusid
left join tcompanyaddress ca on ca.companyid = t.companyid and addresstypeid = 1 
left join tcountry con on con.countryid = ca.countryid
left join tcompanycontact cc on t.primarycompanycontactid = cc.companycontactid and t.companyid=cc.companyid
left join tperson p on cc.personid = p.personid
left join tamount am on am.amountid = t.totalvalueamountid
left join vamountindefaultcurrency evc on evc.amountid =am.amountid
left join tcurrency ec   on ec.currencyid = am.currencyid
),
QA
as
(
select rfx.rfxid,q.rfxquestionandanswerid,qt.fixed qatype,st.fixed as statementtype,s.ispublished, s.isprivate, s.iscancelled  from trfxquestionandanswer q 
inner join tqatype qt on q.qatypeid= qt.qatypeid 
inner join tstatement s on s.rfxquestionandanswerid = q.rfxquestionandanswerid
inner join tstatementtype st on s.statementtypeid = st.statementtypeid 
inner join (select rfxinterestid,rfxid from trfxinterest) rfx on q.objectid = rfx.rfxinterestid and q.objecttypeid in (select objecttypeid from tobjecttype where fixed = N'RFXINTEREST')
union
select rfx.rfxid,q.rfxquestionandanswerid,qt.fixed qatype,st.fixed as statementtype,s.ispublished, s.isprivate, s.iscancelled  from trfxquestionandanswer q 
inner join tqatype qt on q.qatypeid= qt.qatypeid 
inner join tstatement s on s.rfxquestionandanswerid = q.rfxquestionandanswerid
inner join tstatementtype st on s.statementtypeid = st.statementtypeid 
inner join trfx rfx on q.objectid = rfx.rfxid and q.objecttypeid in (select objecttypeid from tobjecttype where fixed = N'RFx')
),
RFxHideList as 
(
select rfxid from trfx
where bidlocked = 1 and bidopeningcountdown > 0
union
select rfxid from trfx
where dateadd(hh,timezoneutcoffset,responsedeadline) > getutcdate()
and (select ps.SETTINGVALUE from TPROFILEKEY pk inner join TPROFILESETTING ps on pk.PROFILEKEYID = ps.PROFILEKEYID where pk.fixed ='HIDE_BIDDERS_NODE_ON_RFX_FROM_PROCESS_START_UNTIL_DUE_DATE') in ('True')
)
select 
r.ContractID,
r.RFxID,
r.rfx as [Title (RFx)],
r.shortdescription as [Desciption (RFx)],
rt.rfxtype as [Type of request (RFx)],
st.strategytype as [Procedure (RFx)],       
at.agreement_type as [Contract type (RFx)], 
case
when r.frameworkcontract = 1 then N'Yes'
else N'No'
end as [Framework contract (RFx)],
r.externalnumber as [RFx Number (RFx)],
r.othernumber as [Other reference number (RFx)],
case
when r.isopen = 1 then N'Yes'
else N'No'
end as [Open/Public (RFx)],
s.status as [Status (RFx)],
r.timezonedisplayname as [Time zone (RFx)],
r.publicationdate as [Publication date (RFx)],
r.confirminterestdate  as [Deadline confirmation of interest (RFx)],
r.clarificationdeadline  as [Deadline for Q&A (RFx)],
r.responsedeadline as [Response due date/time (RFx)],
case
when r.bidlocked =1 then N'Yes'
else N'No'
end as [Bid locking used (RFx)],
r.formalopeningdate as [Formal opening date/time (RFx)],
r.formalopeningplace as [Place (RFx)],
r.minimumtendervalidity  as [Minimum validity (RFx)],
r.plannedawarddate as [Planned award date (RFx)],
r.plannedeffectivedate as [Planned start date (RFx)],
r.plannedexpirydate as    [Planned expiry date (RFx)],
(select  datediff(dd,startdate,coalesce(rev_expirydate,expirydate))  from tcontract where contractid = r.contractid) + 1 as  [Planned contract duration in days (RFx)],
r.rfxurl as [Internet address (URL) (RFx)],
r.rfxinfoemail as [Email address for info (RFx)],
w.worklocation  as [Work or delivery site (RFx)],
stuff((
	select '; ' + isnull(l.mik_language,'')
	from tlanguage_in_rfx linr inner join tlanguage l
	on linr.languageid = l.languageid
	where linr.rfxid = r.rfxid
    order by isnull(l.mik_language,'')
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Accepted languages (RFx)],
r.longdescription as  [Description of acquisition (RFx)],
stuff((
select '; ' + gn.productgroupnomenclature + ': '+stuff((
	select ', ' + isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
	from tproductgroup g inner join tprod_group_in_rfx gc 
	on g.productgroupid = gc.productgroupid
	where g.productgroupnomenclatureid = gn.productgroupnomenclatureid  and gc.rfxid = r.rfxid
    order by isnull(g.productgroupcode,'')+' '+isnull(g.productgroup,'')
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
from tproductgroupnomenclature gn
order by gn.productgroupnomenclature
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Product and service groups (RFx)],
case
when r.awardtomostattractive = 1 then N'Overall most attractive'
else N'Lowest price'
end as [Award criteria type (RFx)],
r.awardcriteria as [Award criterias (RFx)],
cast(txt.clausetext as nvarchar(4000)) as [Payment conditions/form (RFx)], 
c.currency as [Preferred currency (RFx)],
case 
when exists (select * from ttenderer where contractid > 0 and rfxid = r.rfxid)  then N'Yes'
else N'No'
end as [Current (RFx)],
case 
when r.ispublished = 1 then N'Yes'
else N'No'
end as  [Is published (RFx)],

stuff((
	select '; ' + i.companyname from invited i
	where i.rfxid = r.rfxid
    order by i.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Invited/interested parties company name (RFx)],
stuff((
	select '; ' + i.status + ' ('+ i.companyname+')' from invited i
	where i.rfxid = r.rfxid
    order by i.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Invited/interested parties status (RFx)],

stuff((
	select '; ' + i.primcontact + ' ('+ i.companyname+')' from invited i
	where i.rfxid = r.rfxid
    order by i.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Invited/interested parties primary contact (RFx)],
stuff((
	select '; ' + i.country + ' ('+ i.companyname+')' from invited i
	where i.rfxid = r.rfxid
    order by i.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Invited/interested parties country (RFx)],
stuff((
	select '; ' + i.declinecomment + ' ('+ i.companyname+')' from invited i
	where i.rfxid = r.rfxid
    order by i.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Invited/interested parties decline comment (RFx)],
stuff((
	select '; ' + i.companynumber + ' ('+ i.companyname+')' from invited i
	where i.rfxid = r.rfxid
    order by i.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Invited/interested parties company number (RFx)],
stuff((
	select '; ' + cast(i.logdate as varchar(20)) + ' ('+ i.companyname+')' from invited i
	where i.rfxid = r.rfxid
    order by i.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Invited/interested parties status change (RFx)],


case 
when r.isopen = 1 then (select count(vrfi.rfxinterestid) from vrfxinterest vrfi where vrfi.rfxid = r.rfxid and vrfi.fixed in ('DECLAREDINTENTIONTOBID', 'BIDDELIVEREDANDCONFIRMED', 'CONTRACT_DRAFTING'))
else (select count(vrfi.rfxinterestid) from vrfxinterest vrfi where vrfi.rfxid = r.rfxid )
end as [Number of invited/interested parties (RFx)],
(select count(vrfi.rfxinterestid) from vrfxinterest vrfi where vrfi.rfxid = r.rfxid and vrfi.confirmedinterest = 1) as [Number of participants confirmed interest (RFx)],
(select count(vrfi.rfxinterestid) from vrfxinterest vrfi where vrfi.rfxid = r.rfxid and vrfi.fixed = 'DECLINEDTOBID') as [Number of participants declined (RFx)],

(select count(a.AuctionId) from tauction a where a.PublishStatus = 0 and a.rfxid = r.rfxid) as [Number of planned reverse auctions (RFx)],
(
 select count(a.Auctionid) from tauction a
 inner join trfx rf on a.rfxid=rf.rfxid
 where 
 a.rfxid = r.rfxid   and
 a.PublishStatus = 1 and
 a.EndTime < dateadd(hh,-(rf.TIMEZONEUTCOFFSET),GETUTCDATE())
 ) as [Number of completed reverse auctions (RFx)],
  datediff(dd,(select cast(dateadd(hour, 12, min(time)) as date) from taudittrail where objectid = r.rfxid and objecttypeid = @RFxObjectTypeID) ,r.publicationdate) + 1 as [Duration in days from RFx creation to RFx published (RFx)],
(select datediff(dd,dateadd(hh,r.timezoneutcoffset,r.responsedeadline),awarddate) from tcontract where contractid = r.contractid) + 1 as [Duration in days from RFx due date to contract award (RFx)],
 datediff(dd,r.publicationdate,r.responsedeadline) + 1 as [Duration in days from RFx publication to due date (RFx)],
(select datediff(dd,(select min(time) from taudittrail where objectid = r.rfxid and objecttypeid = @RFxObjectTypeID),awarddate) from tcontract where contractid = r.contractid) + 1 as [Duration in days from RFx creation to contract award (RFx)], 

--(select count(rfxquestionandanswerid) from trfxquestionandanswer 
-- where  objectid = r.rfxid 
-- and    objecttypeid in (select objecttypeid from tobjecttype where fixed = N'RFx')
-- ) as [Number of questions and answers (RFx)],

(select datediff(dd,awarddate,startdate) + 1  from tcontract where contractid = r.contractid) as [Duration in days from contract award to active (RFx)],

case when hl.rfxid is null then (select count(bid.rfxid) from bidders bid where bid.rfxid = r.rfxid) else null end as [Number of bidders (RFx)],
case when hl.rfxid is null then 
stuff((
	select '; ' + bid.companyname from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.companyname is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Bidders company name (RFx)],
case when hl.rfxid is null then 
stuff((
	select '; ' + bid.companynumber+' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.companynumber is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end 
as [Bidders company number (RFx)],
case when hl.rfxid is null then 
stuff((
	select '; ' + bid.primcontact+' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.primcontact is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Bidders primary contact (RFx)],
case when hl.rfxid is null then
stuff((
	select '; ' + bid.country+' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.country is not null      
	order by bid.country
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Bidders country (RFx)],
case when hl.rfxid is null then
stuff((
	select '; ' + cast(bid.[Bidders commercial value (RFx)] as varchar(20))+' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.[Bidders commercial value (RFx)] is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Bidders commercial value (RFx)],
case when hl.rfxid is null then 
stuff((
	select '; ' + cast(bid.[Bidders commercial value (display currency) (RFx)] as varchar(20))+' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.[Bidders commercial value (display currency) (RFx)] is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Bidders commercial value (display currency) (RFx)],
case when hl.rfxid is null then 
stuff((
	select '; ' + bid.[Bidders commercial value currency code (RFx)] +' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.[Bidders commercial value currency code (RFx)] is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Bidders commercial value currency code (RFx)],
case when hl.rfxid is null then 
stuff((
	select '; ' + bid.status +' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.status is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Bidders status (RFx)],
case when hl.rfxid is null then 
stuff((
	select '; ' + cast(bid.score as varchar(20)) +' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.score is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Bidders score (RFx)],
case when hl.rfxid is null then 
stuff((
	select '; ' + cast(bid.DocumentCount as varchar(20)) +' ('+bid.companyname+')' from bidders bid
	where bid.rfxid = r.rfxid and 
	bid.DocumentCount is not null      
	order by bid.companyname
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Number of documents delivered in response (RFx)],
case when hl.rfxid is null then 
stuff((
	select '; ' + ten.comment +' ('+com.company +')'
	from ttenderer ten inner join tcompany com
	on   ten.companyid = com.companyid
	where ten.rfxid = r.rfxid
	and   ten.comment is not null
    order by com.company
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '') else null end
as [Comment (RFx)],
(select  count(rfxquestionandanswerid) from QA where qatype = N'QUESTION_AND_ANSWER' and statementtype = N'QUESTION' and rfxid = r.rfxid)                    as [Number of questions (RFx)],
(select  count(rfxquestionandanswerid) from QA where qatype = N'QUESTION_AND_ANSWER' and statementtype = N'QUESTION' and iscancelled = 1 and rfxid = r.rfxid) as [Number of questions rejected (RFx)],
(select  count(rfxquestionandanswerid) from QA where qatype = N'QUESTION_AND_ANSWER' and statementtype = N'ANSWER'   and isprivate  = 1 and rfxid = r.rfxid) as [Number of private answers (RFx)],
(select  count(rfxquestionandanswerid) from QA where qatype = N'QUESTION_AND_ANSWER' and statementtype = N'ANSWER'   and isprivate  = 0 and rfxid = r.rfxid) as [Number of public answers (RFx)],
(select  count(rfxquestionandanswerid) from QA where qatype = N'QUESTION_AND_ANSWER' and statementtype = N'ANSWER'   and ispublished =1 and rfxid = r.rfxid) as [Number of published answers (RFx)],
(select  count(rfxquestionandanswerid) from QA where qatype = N'QUESTION_AND_ANSWER' and statementtype = N'ANSWER'   and ispublished =0 and rfxid = r.rfxid) as [Number of unpublished answers (RFx)],
(select  count(rfxquestionandanswerid) from QA where qatype = N'CLARIFICATION'       and statementtype = N'ANSWER'                      and rfxid = r.rfxid) as [Number of answered response clarifications (RFx)],
(
  select count(rfxquestionandanswerid) from 
	(
	select  rfxquestionandanswerid from QA where qatype = N'QUESTION_AND_ANSWER' and statementtype = N'QUESTION' and rfxid = r.rfxid
	except
	select  rfxquestionandanswerid from QA where qatype = N'QUESTION_AND_ANSWER' and statementtype = N'ANSWER'   and rfxid = r.rfxid
	) a
) as [Number of unanswered questions (RFx)],
(
  select count(rfxquestionandanswerid) from 
	(
	select  rfxquestionandanswerid from QA where qatype = N'CLARIFICATION' and statementtype = N'QUESTION' and rfxid = r.rfxid
	except
	select  rfxquestionandanswerid from QA where qatype = N'CLARIFICATION' and statementtype = N'ANSWER'   and rfxid = r.rfxid
	) a
) as [Number of unanswered response clarifications (RFx)],

(	select 	sum(ISNULL(TAB.InitialBid - TAB.LastBid, 0)) from  trfx tr 
	inner join 	tauction ta on tr.rfxid = ta.rfxid
	inner join 	tauctionbidder tab on ta.auctionid = tab.auctionid
	inner join  ttenderer tt on tab.tendererid = tt.tendererid 
	where 	tab.iswinner = 1 and ta.publishstatus = 1 and tr.rfxid = r.rfxid
) as [Auction savings (RFx)],
(	select 	avg(ISNULL(((TAB.InitialBid-TAB.LastBid)/TAB.InitialBid)*100,0)) from  trfx tr 
	inner join 	tauction ta on tr.rfxid = ta.rfxid
	inner join 	tauctionbidder tab on ta.auctionid = tab.auctionid
	inner join  ttenderer tt on tab.tendererid = tt.tendererid 
	where 	tab.iswinner = 1 and ta.publishstatus = 1 and tr.rfxid = r.rfxid
) as [Auction savings in % (RFx)],
(
 select count(d.documentid) from tdocument d 
 inner join tdocumenttype dt on d.documenttypeid = dt.documenttypeid
 where (dt.documenttypeid = @RFxPublishedDocumentFolderRootId or dt.RootID = @RFxPublishedDocumentFolderRootId)
 and d.objecttypeid = @RFxObjectTypeID 
 and d.objectid = r.rfxid
) as [Number of RFx document to be published (RFx)]
from trfx r
left join tstatus s on r.statusid = s.statusid
left join trfxtype rt on r.rfxtypeid = rt.rfxtypeid
left join tstrategytype st on r.strategytypeid = st.strategytypeid
left join tagreement_type at on r.agreement_typeid = at.agreement_typeid
left join tworklocation w on r.worklocationid = w.worklocationid
left join tcurrency c on c.currencyid = r.currencyid
left join tclausetext txt on r.paymentformclausetextid = txt.clausetextid
left join RFxHideList hl on r.rfxid=hl.rfxid
where r.ContractID is not null
GO
/****** Object:  StoredProcedure [dbo].[usp_get_RFxACL]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_RFxACL] 
as 
declare @Read bigint
select  @Read=privilegeid from tprivilege where privilege = N'Read'

select ta.objectid as rfxid,ta.userid,tu.domainnetbiosusername
from tacl ta (nolock)
inner join tuser tu
on  ta.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null
and tu.mik_valid = 1 
where 
ta.objecttypeid in (select tobjecttype.objecttypeid
                                    from   tobjecttype
                                    where  fixed = N'RFx'
									)
and ta.privilegeid = @Read
and ta.userid is not null
and exists(select 1 from trfx r where r.RfxID = ta.objectid and r.ContractID is not null)
union 
select objectid as rfxid,ug.userid,tu.domainnetbiosusername
from tacl ta (nolock)
inner join tuser_in_usergroup ug (nolock)
on ug.usergroupid = ta.groupid
inner join tuser tu
on ug.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null            
and tu.mik_valid = 1 
where 
ta.objecttypeid in (select tobjecttype.objecttypeid
                                    from   tobjecttype
                                    where  fixed = N'RFx'
									)
and ta.privilegeid = @Read
and ug.userid is not null
and exists(select 1 from trfx r where r.RfxID = ta.objectid and r.ContractID is not null)

--Inherit from contract
union
select r.rfxid, ta.userid, tu.domainnetbiosusername from tacl ta (nolock)
inner join trfx r 
on r.contractid = ta.objectid and ta.objecttypeid = 1 and ta.privilegeid = @Read and ta.nonheritable = 0
inner join tuser tu
on  ta.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null and tu.mik_valid = 1 
where 
exists (
        select aclid from tacl 
		where tacl.objectid =r.rfxid
		and tacl.objecttypeid = (select objecttypeid from tobjecttype where fixed = 'RFx') and privilegeid = 3 and 
		parentobjecttypeid =  1 and parentobjectid = r.contractid and inheritfromparentobject = 1
		) 
and ta.userid is not null
and r.ContractID is not null
union 
select  r.rfxid,ug.userid,tu.domainnetbiosusername from tacl ta (nolock)
inner join trfx r 
on r.contractid = ta.objectid and ta.objecttypeid = 1 and ta.privilegeid = @Read and ta.nonheritable = 0
inner join tuser_in_usergroup ug (nolock)
on ug.usergroupid = ta.groupid
inner join tuser tu
on ug.userid = tu.userid and tu.isexternaluser = 0 and tu.domainnetbiosusername is not null            
and tu.mik_valid = 1 
where 
exists (
        select aclid from tacl 
		where tacl.objectid =r.rfxid
		and tacl.objecttypeid = (select objecttypeid from tobjecttype where fixed = 'RFx') and privilegeid = 3 and 
		parentobjecttypeid =  1 and parentobjectid = r.contractid and inheritfromparentobject = 1
		) 
and ug.userid is not null
and r.ContractID is not null
GO
/****** Object:  StoredProcedure [dbo].[usp_get_RFxType]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_RFxType]
as
select distinct rfxtype  from trfxtype
where 	rfxtypeid > 0 and mik_valid = 1 and rfxtype is not null

GO
/****** Object:  StoredProcedure [dbo].[usp_get_Status]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_Status]
as
select s.status, o.fixed as objecttype from tstatus s
inner join tstatus_in_objecttype so
on s.statusid = so.statusid
inner join tobjecttype o
on so.objecttypeid = o.objecttypeid
where 	s.statusid > 0 and s.mik_valid > 0
and 	s.status  is not null and  s.status  !=''
union
select case when vo.vonumber is null then N'Unhandled' else s.status + N' VO'  end as status, N'VOR' as objecttype
from tvor vor 
left join tvo vo on vor.void=vo.void
left join tstatus s on vo.statusid = s.statusid



GO
/****** Object:  StoredProcedure [dbo].[usp_get_TerminationConditions]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_TerminationConditions]
as
select distinct terminationconditions  as [terminationconditions] from tterminationconditions
where 	terminationconditionsid > 0 and mik_valid > 0
and 	terminationconditions  is not null and  terminationconditions  !=''
GO
/****** Object:  StoredProcedure [dbo].[usp_get_User]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_get_User] 
as 
select distinct v.UserId,v.Firstname,v.Middlename,v.LastName,  v.Firstname+' '+v.LastName as DisplayName,v.Email,v.UserInitial,v.DOMAINNETBIOSUSERNAME,
case 
when prole.role is null then cast(0 as bit)
else cast(1 as bit)
end as IsAdmin
from vuser v
left join 
(select r.role, po.personid from
 tpersonrole_in_objecttype   po
 inner join trole r 
 on r.roleid = po.roleid and r.fixed = N'COMPANY_QUERY_ADMINISTRATOR'
) prole
on v.personid = prole.personid
where 
v.user_mik_valid = 1 and v.isexternaluser = 0 and v.domainnetbiosusername is not null
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Vo]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_Vo]
as
with cte (void,[VOR value sum (VO)],[VOR value sum currency (VO)],[VOR value sum (display currency) (VO)])
as 
(select vo.void,
case when count(distinct c.currency_code) > 1 then -1 else round(sum(a.amount),0) end as [VOR value sum (VO)],
case when count(distinct c.currency_code) > 1 then 'MULTI'else min(c.currency_code) end as [VOR value sum currency (VO)],
round(max(vc.amount),0) as [VOR value sum (display currency) (VO)]
from tvo vo
left join tvor vor on vo.void = vor.void
left join  tamount a on  vor.claimamountid=a.amountid
left join  vamountindefaultcurrency vc on vc.amountid =a.amountid
left join  tcurrency c   on a.currencyid = c.currencyid
group by vo.void
)
select
vo.contractid,
vo.void,
vo.vonumber as [Number (VO)],
vo.revision as [Revision (VO)],
vo.vo as [Description (VO)],
s.status as [Status (VO)],
cte.[VOR value sum (VO)],
cte.[VOR value sum (display currency) (VO)],
cte.[VOR value sum currency (VO)],
round(a.amount,0)   as [Offer (VO)],
round(vc.amount,0)  as [Offer (display currency) (VO)],
c.currency_code     as [Offer currency (VO)],
round(aa.amount,0) as [Settlement (VO)],
round(avc.amount,0) as [Settlement (display currency) (VO)],
ac.currency_code as [Settlement currency (VO)],
cast(dateadd(hour, 12, vo.datecreated) as date)  as [Created date (VO)],
cast(dateadd(hour, 12, vo.fromdate)    as date)  as [Start date (VO)],
cast(dateadd(hour, 12, vo.todate)    as date)    as [End date (VO)],
case 
when s.status = 'Disputed' then s.status  + isnull('-'+dt.disputed_type,'') 
else null
end as [Dispute (VO)],
d.department as [Responsible department (VO)],
cast(dateadd(hour, 12, vo.received_signed) as date)  as [Received signature (VO)],
vo.comments as [Comments (VO)],
stuff((
	select top 50 '; ' + isnull(cast(vor.vornumber as varchar(20)),'') + '-' + isnull(vor,'')
	from tvor vor
	where vor.void = vo.void
    order by isnull(vor.vornumber,'')
for xml path(''), root('MyString'), type).value('/MyString[1]','nvarchar(4000)'), 1, 2, '')
as [Handled VORs (VO)]
from tvo vo 
left join tstatus s on vo.statusid = s.statusid
left join tdepartment d on vo.departmentid = d.departmentid
left join  tamount a on  vo.offeramountid=a.amountid
left join  vamountindefaultcurrency vc on vc.amountid =a.amountid
left join  tcurrency c   on a.currencyid = c.currencyid
left join tamount aa on  vo.settlementamountid=aa.amountid
left join vamountindefaultcurrency avc on avc.amountid =aa.amountid
left join tcurrency ac   on aa.currencyid = ac.currencyid
left join tdisputed_type dt on disputedtypeid = vo.disputedtypeid
left join cte  on vo.void = cte.void
GO
/****** Object:  StoredProcedure [dbo].[usp_get_Vor]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_get_Vor]
as
select 
vor.contractid,
vor.vorid,
vor.void,
vor.vornumber as [Number (VOR)],
vor.revision as [Revision (VOR)],
vor.vor as [Description (VOR)],
round(a.amount,0) as [Value (VOR)],
round(vc.amount,0) as [Value (Display Currency) (VOR)],
c.currency_code as [Value currency (VOR)],
cast(dateadd(hour, 12,vor.date_received) as date)  as [Date received (VOR)],
cast(dateadd(hour, 12,vor.fromdate) as date)  as [Start date (VOR)],
cast(dateadd(hour, 12,vor.todate) as date)  as [End date (VOR)],
vor.description as [Description of the change (VOR)],
vor.reason as [Background/reason for the change (VOR)],
cast(vo.vonumber as varchar(20))+'-'+vo.vo as [Handled by VO (VOR)],
case when vor.sharedwithsupplier = 0 then N'No' else N'Yes' end as  [Shared with counterpart (VOR)],
case when vo.vonumber is null then N'Unhandled' else s.status + N' VO'  end as [Status (VOR)]
from tvor vor 
left join tvo vo on vor.void=vo.void
left join tstatus s on vo.statusid = s.statusid
left join tamount a on  vor.claimamountid=a.amountid
left join vamountindefaultcurrency vc on vc.amountid =a.amountid
left join tcurrency c   on a.currencyid = c.currencyid
GO
/****** Object:  StoredProcedure [dbo].[usp_get_WorkLocation]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure  [dbo].[usp_get_WorkLocation]
as
select distinct worklocation  as [worklocation] from tworklocation
where 	worklocationid > 0 and mik_valid > 0
and 	worklocation  is not null and  worklocation  !=''
GO
/****** Object:  StoredProcedure [dbo].[usp_TheCompany_zSendTextEmailTEST]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_TheCompany_zSendTextEmailTEST]  @ServerAddr nvarchar(128),
@From nvarchar(128),
@To nvarchar(1024),
@Subject nvarchar(256),
@Bodytext nvarchar(max) = 'This is a test text email from MS SQL server, do not reply.',
@User nvarchar(128) = '',
@Password nvarchar(128) = '',
@SSLConnection int = 0,
@ServerPort int = 25

AS

DECLARE @hr int
DECLARE @oSmtp int
DECLARE @result int
DECLARE @description nvarchar(255)

EXEC @hr = sp_OACreate 'EASendMailObj.Mail',@oSmtp OUT 
If @hr <> 0 
BEGIN
    PRINT 'Please make sure you have EASendMail Component installed!'
    EXEC @hr = sp_OAGetErrorInfo @oSmtp, NULL, @description OUT
    IF @hr = 0
    BEGIN
        PRINT @description
    END
    RETURN
End

EXEC @hr = sp_OASetProperty @oSmtp, 'LicenseCode', 'TryIt'
EXEC @hr = sp_OASetProperty @oSmtp, 'ServerAddr', @ServerAddr
EXEC @hr = sp_OASetProperty @oSmtp, 'ServerPort', @ServerPort

EXEC @hr = sp_OASetProperty @oSmtp, 'UserName', @User
EXEC @hr = sp_OASetProperty @oSmtp, 'Password', @Password

EXEC @hr = sp_OASetProperty @oSmtp, 'FromAddr', @From

EXEC @hr = sp_OAMethod @oSmtp, 'AddRecipientEx', NULL,  @To, 0

EXEC @hr = sp_OASetProperty @oSmtp, 'Subject', @Subject 
EXEC @hr = sp_OASetProperty @oSmtp, 'BodyText', @BodyText 


If @SSLConnection > 0 
BEGIN
    EXEC @hr = sp_OAMethod @oSmtp, 'SSL_init', NULL
END

/* you can also add an attachment like this */
/*EXEC @hr = sp_OAMethod @oSmtp, 'AddAttachment', @result OUT, 'd:\test.jpg'*/
/*If @result <> 0 */
/*BEGIN*/
/*   EXEC @hr = sp_OAMethod @oSmtp, 'GetLastErrDescription', @description OUT*/
/*    PRINT 'failed to add attachment with the following error:'*/
/*    PRINT @description*/
/*END*/

PRINT 'Start to send email ...' 

EXEC @hr = sp_OAMethod @oSmtp, 'SendMail', @result OUT 

If @hr <> 0 
BEGIN
    EXEC @hr = sp_OAGetErrorInfo @oSmtp, NULL, @description OUT
    IF @hr = 0
    BEGIN
        PRINT @description
    END
    RETURN
End

If @result <> 0 
BEGIN
    EXEC @hr = sp_OAMethod @oSmtp, 'GetLastErrDescription', @description OUT
    PRINT 'failed to send email with the following error:'
    PRINT @description
END
ELSE 
BEGIN
    PRINT 'Email was sent successfully!'
END

EXEC @hr = sp_OADestroy @oSmtp

GO
/****** Object:  StoredProcedure [dbo].[WF_CreateDbOptions]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[WF_CreateDbOptions] 
		@databaseName sysname
	AS
	exec sp_dboption @databaseName, N'autoclose', N'false'
	exec sp_dboption @databaseName, N'bulkcopy', N'false'
	exec sp_dboption @databaseName, N'trunc. log', N'false'
	exec sp_dboption @databaseName, N'torn page detection', N'true'
	exec sp_dboption @databaseName, N'read only', N'false'
	exec sp_dboption @databaseName, N'dbo use', N'false'
	exec sp_dboption @databaseName, N'single', N'false'
	exec sp_dboption @databaseName, N'autoshrink', N'false'
	exec sp_dboption @databaseName, N'ANSI null default', N'false'
	exec sp_dboption @databaseName, N'recursive triggers', N'false'
	exec sp_dboption @databaseName, N'ANSI nulls', N'false'
	exec sp_dboption @databaseName, N'concat null yields null', N'false'
	exec sp_dboption @databaseName, N'cursor close on commit', N'false'
	exec sp_dboption @databaseName, N'default to local cursor', N'false'
	exec sp_dboption @databaseName, N'quoted identifier', N'false'
	exec sp_dboption @databaseName, N'ANSI warnings', N'false'
	exec sp_dboption @databaseName, N'auto create statistics', N'true'
	exec sp_dboption @databaseName, N'auto update statistics', N'true'
	if( ( (@@microsoftversion / power(2, 24) = 8) and (@@microsoftversion & 0xffff >= 724) ) or ( (@@microsoftversion / power(2, 24) = 7) and (@@microsoftversion & 0xffff >= 1082) ) )
		exec sp_dboption @databaseName, N'db chaining', N'false'
GO
/****** Object:  StoredProcedure [dbo].[zzzTheCompany_ProductGroupUpload_FullText_Backup]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[zzzTheCompany_ProductGroupUpload_FullText_Backup]
AS
/* Notes:
Currently excluding lots of names with special chars to be sure
retest
*/

/* Check if valid input parameters passed */

DECLARE @RESULTSTRING AS VARCHAR(255)

DECLARE @PRODUCTGROUP AS VARCHAR(255)
DECLARE @CONTRACTNUMBER AS VARCHAR(20)
DECLARE @DOCTITLE AS VARCHAR(255)
DECLARE @PRODUCTGROUPQUOTE AS VARCHAR(300)
DECLARE @PRODUCTGROUPID SMALLINT
DECLARE @OBJECTID bigint 
DECLARE @SQLOBJECTIDS as VARCHAR (1000)
DECLARE @DATEREGISTERED as datetime

BEGIN


	DECLARE curProducts CURSOR LOCAL FAST_FORWARD FOR

	select PRODUCTGROUPID, PRODUCTGROUP from V_TheCompany_AUTO_ProductGroupsToUpload where 
	blnNumHashes = 0 /* no hash, include in full text search */
	/* AND PRODUCTGROUP IN('ADCETRIS','OMNARIS') */
	AND PRODUCTGROUP LIKE '%[a-z]%' 
	AND PRODUCTGROUP NOT LIKE '% %'
	AND PRODUCTGROUP NOT LIKE '%-%'

	OPEN curProducts

	FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
	WHILE @@FETCH_STATUS = 0 BEGIN

		SET @PRODUCTGROUPQUOTE = '"' + @PRODUCTGROUP + '"' 
		PRINT @PRODUCTGROUPQUOTE
		PRINT 'Product Group: '  + @PRODUCTGROUP

			IF EXISTS (SELECT 1
			FROM tcontract c inner join [V_SEARCHENGINE_SEARCHSIMPLEDOCUMENT] t on c.contractid = t.objectid 
			INNER JOIN TFILE f ON f.FileId = t.FileId
			WHERE f.FileId IN (SELECT KEY_TBL.[KEY] FROM CONTAINSTABLE(TFILE, [File], @PRODUCTGROUPQUOTE ) AS KEY_TBL WHERE KEY_TBL.RANK > 10) AND t.MIKVALID = N'1' AND t.FileType NOT LIKE '%.xl%' /* exclude registration form */ AND c.CONTRACTTYPEID  NOT IN  (103,104,101, 13, 5, 102, 6) 
			AND OBJECTID NOT IN (SELECT contractid from TPROD_GROUP_IN_CONTRACT WHERE PRODUCTGROUPID = @PRODUCTGROUPID))
		
			BEGIN /* IF EXISTS */

				DECLARE curContracts CURSOR LOCAL FAST_FORWARD FOR

				SELECT @PRODUCTGROUPID AS PRD 
				, @PRODUCTGROUP AS PRDGRP 
				, OBJECTID
				, max(t.title)
				, c.contractnumber
				, c.contractdate
				FROM tcontract c inner join [V_SEARCHENGINE_SEARCHSIMPLEDOCUMENT] t 
				on c.contractid = t.objectid 
				INNER JOIN TFILE f ON f.FileId = t.FileId
				WHERE f.FileId IN (SELECT KEY_TBL.[KEY] FROM CONTAINSTABLE(TFILE, [File], @PRODUCTGROUPQUOTE ) AS KEY_TBL WHERE KEY_TBL.RANK > 10) AND t.MIKVALID = N'1' AND t.FileType NOT LIKE '%.xl%' /* exclude registration form */ AND c.CONTRACTTYPEID  NOT IN  (103,104,101, 13, 5, 102, 6) 
				AND OBJECTID NOT IN (SELECT contractid from TPROD_GROUP_IN_CONTRACT WHERE PRODUCTGROUPID = @PRODUCTGROUPID)
				GROUP BY OBJECTID, c.contractnumber, c.contractdate

				OPEN curContracts

				FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @OBJECTID, @DOCTITLE, @CONTRACTNUMBER, @DATEREGISTERED
				WHILE @@FETCH_STATUS = 0 
				BEGIN

					 EXEC TheCompany_ProductGroupUpload_ObjectidProductgroupID @OBJECTID, @PRODUCTGROUPID

					INSERT INTO T_TheCompany_Product_Upload ( PRODUCTGROUPID       
					   ,PRODUCTGROUP  
					   ,OBJECTID 
					   ,DOCTITLE         
					   ,CONTRACTNUMBER
					   ,DATEREGISTERED
					   , Uploaded_DateTime)
					VALUES (@PRODUCTGROUPID 
					, @PRODUCTGROUP
					, @OBJECTID
					, @DOCTITLE
					, @CONTRACTNUMBER
					, @DATEREGISTERED
					, GetDate() )
		
				FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, @PRODUCTGROUP, @OBJECTID, @DOCTITLE, @CONTRACTNUMBER, @DATEREGISTERED

				END /* curContracts */
				CLOSE curContracts
				DEALLOCATE curContracts

			END /* IF EXISTS */

	FETCH NEXT FROM curProducts INTO @PRODUCTGROUPID, @PRODUCTGROUP
				
	END /* curProducts */

/* delete from T_TheCompany_Product_Upload */
	CLOSE curProducts
	DEALLOCATE curProducts

	SET @RESULTSTRING = 'Success' 

GOTO lblEnd 

lblTerminate: 
PRINT '!!! Statement did not execute due to invalid input values!'


lblEnd: 
PRINT '*** END'



END 
GO
