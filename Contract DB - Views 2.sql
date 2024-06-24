/****** Object:  View [dbo].[V_TheCompany_VPERSONROLE_IN_OBJECT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view

[dbo].[V_TheCompany_VPERSONROLE_IN_OBJECT]

AS

SELECT 
	P.PERSONROLE_IN_OBJECTID /*PK*/
	, P.PERSONID
	, P.OBJECTID as CONTRACTID
	/* , p.OBJECTTYPEID as OBJECTTYPEID_1 */
	, r.* 
	, u.DISPLAYNAME
	, u.USERID
	, u.FIRSTNAME  /* 23-feb */
	, u.EMAIL /* for LINC */
	, 	(CASE 
		WHEN p.ROLEID IN(1,19,20,34,23 /*Super User*/) THEN 'US'
		WHEN p.ROLEID IN(2 /* Contract Owner*/) THEN 'UO'
		WHEN p.ROLEID IN(15 /* Contract responsible */, 36 /* 36 = Contract Responsible - AMD */) THEN 'UR'
		WHEN p.ROLEID IN(0,6/*ENTITY*/,100 /*INTERNAL PARTNER*/) THEN 'IP'
		WHEN p.ROLEID IN(3 /*TERRITORY*/) THEN 'TT'
		WHEN p.ROLEID IN(103 /* HARDCOPY ARCHIVING */) THEN 'HA'
		WHEN p.ROLEID IN(109 /* Additional Departments Involved (OPTIONAL) */) THEN 'DI'	
		WHEN p.ROLEID IN(110 /* Signatory (mandatory, single value */) THEN 'CS'		 
		ELSE '' END)
		AS Roleid_Cat2Letter
	 , u.PRIMARYUSERGROUP
	, u.DEPARTMENT_CODE
	 , u.DEPARTMENT
FROM TPERSONROLE_IN_OBJECT p 
	inner join [dbo].[V_TheCompany_TROLE] r 
		on p.ROLEID = r.ROLEID
		and p.OBJECTTYPEID = 1 /* contract */
	inner join V_TheCompany_VUSER u 
		on p.PERSONID = u.PERSONID 
			and p.PERSONID >0 /* now also in v_TheCompany_vuser, but 10 entries that are duplicates, userid 1 = personid 1 is default for unpopulated so 0 can be excluded */
			and u.USERID >0
WHERE OBJECTTYPEID = 1 /* contract */
GO
/****** Object:  View [dbo].[V_TheCompany_ALL_Bak2]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_ALL_Bak2]

as

SELECT 
	c.[Number]
      ,c.[CONTRACTID]
/*    ,(case when c.[Title] like '%TOP SECRET%' THEN '*** TOP SECRET ***' ELSE c.[Title] END) as Title
	,c.[Title] as Title_InclTopSecret
      ,c.[CONTRACTTYPE]
      ,c.[CONTRACTTYPEID]

	  /* Agreement type hierarchy */
			, (CASE WHEN cr.AgrType_Top25Flag =1 THEN c.AGREEMENT_TYPE ELSE 'Other' END) 
			  as Agreement_Type_Top25WithOther
			  , cr.AgrType_Top25Flag as Agreement_Type_Top25Flag

      , c.[REFERENCENUMBER]
      , c.CONTRACTDATE

      , convert(varchar(7), CONTRACTDATE, 121) as RegisteredDate_YYYY_MM
      , (CASE 
			WHEN DATEDIFF(mm,c.contractdate,GetDate()) <=3 THEN '0-3 Months'
			WHEN DATEDIFF(mm,c.contractdate,GetDate()) Between 4 and 11 THEN '04-11 Months'
			WHEN DATEDIFF(mm,c.contractdate,GetDate()) Between 12 and 36 THEN '12-36 Months'
			WHEN DATEDIFF(mm,c.contractdate,GetDate()) > 36 THEN '36+ Months'
		END) as RegisteredDateNumMthCat
      ,  c.[AWARDDATE] /* AWARDDATE is converted in view to add one hour */
      ,   c.[STARTDATE] /*,106) as STARTDATE */
      ,  c.[EXPIRYDATE] /*,106) as EXPIRYDATE */
      ,  c.[REV_EXPIRYDATE] /*,106) as REV_EXPIRYDATE */
      ,  c.[FINAL_EXPIRYDATE] /*,106) as FINAL_EXPIRYDATE */
      ,  c.[REVIEWDATE] /*,106) as REVIEWDATE */
/* Review date */
      , rd.RD_ReviewDate_Warning /*,106) as RD_ReviewDate_Warning */

      , null as [CHECKEDOUTDATE] 
      ,c.[DEFINEDENDDATE]
      ,c.[STATUS]
      ,c.[ContractRelations]

      ,c.[NUMBEROFFILES]
      ,null as  [EXECUTORID] /* removed from vcontract 22-feb */
      ,null as  [OWNERID]
      ,null as  [TECHCOORDINATORID]
      ,c.[STATUSID]
      ,c.[StatusFixed]
      ,c.[REFERENCECONTRACTNUMBER]
      ,c.[COUNTERPARTYNUMBER]
      ,c.[AGREEMENT_TYPE]
      ,c.[AGREEMENT_TYPEID]
      ,c.[AGREEMENT_FIXED]
	  ,c.[STRATEGYTYPE] /* AS AGREEMENT_SUBTYPE HCP HCO */
 /* Company */
      /* all Contract view items have their ISNULL in the source query */

	  , ISNULL(t.[CompanyList],'') AS 'CompanyList' /* otherwise it is not available as a filter field in BO due to being long text */
      ,t.CompanyIDList
      ,t.[CompanyIDAwardedCount]
      ,t.[CompanyIDUnawardedCount]
      ,t.CompanyIDCount
/* Confidentiality Flag */
      , 'N/A' /*(select [MIK_EDIT_VALUE] 
		FROM [TEXTRA_FIELD_IN_CONTRACT] ef
		WHERE [EXTRA_FIELDID] = 100002 /* Confidentiality Flag */
		AND ef.contractid = c.contractid) */ as ConfidentialityFlag /* heading field replaced, empty string '' field was deleted as of V6.15, no replacement */
   
/* User Roles */
      , us.*
      , uo.*
      , ur.*
            
/* Department Roles */
		
	, ISNULL(d.[Dpt_SuperUserDpt],'') AS 'Dpt_Name_US' /* nvarchar 4000 for some reason */
      ,ISNULL(d.[Dpt_SuperUserDpt_ID],'') AS 'Dpt_ID_US'
      ,ISNULL(d.[Dpt_SuperUserDpt_Code],'') AS 'Dpt_Code_US'
 
	 , ISNULL(d.[InternalPartners],'') AS 'InternalPartners'
 
      ,ISNULL(d.[InternalPartners_IDs],'') AS 'InternalPartners_IDs'
      ,ISNULL(d.[InternalPartners_COUNT],0) AS 'InternalPartners_COUNT'
      , ISNULL(d.[Territories],'')  AS 'Territories' /* LEN capped at 255 in concat statement but turns into varchar(4000) in T_TheCompany_ALL */
      ,ISNULL(d.[Territories_IDs],'') AS 'Territories_IDs' /* becomes varchar(max), max len is around 400 odd char */
      ,ISNULL(d.[Territories_COUNT],0) AS 'Territories_COUNT'

/* Products */ /* optimized to use CAST and LEFT */
      , ISNULL(p.[VP_ProductGroups],'') AS 'VP_ProductGroups'
      , ISNULL(p.[VP_ProductGroups_IDs],'') AS 'VP_ProductGroups_IDs'
      , ISNULL(p.[VP_ProductGroups_COUNT],0) AS 'VP_ProductGroups_COUNT'
      , ISNULL(p.[VP_ActiveIngredients],'')  AS [VP_ActiveIngredients]
      , ISNULL(p.[VP_TradeNames],'')  AS [VP_TradeNames]
      , ISNULL(p.[VP_DirectProcurement],'') AS [VP_DirectProcurement]
      , ISNULL(p.[VP_IndirectProcurement],'') AS [VP_IndirectProcurement] /* mark entries where this is longer than 255 char?*/
   
/* Commercial - Lump Sum */
      , ISNULL(vc.LumpSum,0) as LumpSum
      , ISNULL(vc.LUMPSUM_CURRCODE,0) as LumpSumCurrency

/* HIERARCHY */
      /* , h.* */
      , ISNULL(h.[REGION],'Other') as Region
      ,h.[DEPARTMENTID]
      ,h.[LEVEL]
      ,ISNULL(h.[L0],'No Department entered') as L0
      , h.[L1] 
      , h.[L2]  
      , h.[L3] 
      , h.[L4]  
      , h.[L5] 
      , h.[L6]  
      , h.[L7]  
      ,h.[DEPARTMENT]
      ,h.[DEPARTMENT_CONCAT]
      ,h.[DPT_LOWEST_ID_TO_SHOW]
      ,h.[DEPARTMENT_CODE]
      ,h.[DPT_CODE_2Digit_InternalPartner]
      ,h.[DPT_CODE_2Digit_TerritoryRegion]
      ,h.[DPT_CODE_2Digit]
      ,h.[DPT_CODE_FirstChar]
      ,h.[FieldCategory]
      ,h.[NodeType]
      ,h.[NodeRole]
      ,h.[NodeMajorFlag]
      ,h.[PARENTID]
     
      , GETDATE() as DateTableRefreshed
      , 'http://des80040.nycomed.local/ccs/builtin_modules/Contract.aspx?id=' + CAST(c.contractid as varchar(255)) as LinkToContractURL

	  /* Procurement Base Flag 1 for Agreement type, is needed as a basis for V_TheCompany_Mig_0ProcNetFlag (based on T_TheCompany_ALL) */
	, (CASE 
				WHEN COUNTERPARTYNUMBER like '%!ARIBA_W01%' 
					 OR COUNTERPARTYNUMBER like '%!ARIBA_W02%' THEN 9 /* already migrated to Ariba */
				WHEN CompanyIDList = '1' /* intercompany */ THEN 4 /* Intercompany agreements always attributed to Legal no matter which other properties */
				WHEN title like '%GxP%' THEN 6 /* Gxp is also LEGAL, manually review */

				ELSE cr.[TargetSystem_AgTypeFLAG]	/*(0,1,2,7,8)	*/
				END) as Procurement_AgTypeFlag
	  /* Procurement Base Flag 2 for Role, is needed as a basis for V_TheCompany_Mig_0ProcNetFlag (based on T_TheCompany_ALL) */
			/* User role department is Global Procurement or IT -> Procurement Role Flag is populated with GP or IT */
	, (CASE WHEN (substring(UO.UO_DPT_CODE,0,4) ='-GP' /* contract owner is in Global Procurement */
				OR substring(ur.UR_DPT_CODE,0,4) = '-GP' /* contract responsible */
				OR substring(us.US_DPT_CODE,0,4) = '-GP'  /* super user */)
				THEN 'GP' 
			WHEN (substring(uo.UO_DPT_CODE,0,4) ='-IT'  /* contract owner is IT, which is attributed to Global Procurement */
				OR substring(ur.UR_DPT_CODE,0,4) = '-IT' /* contract responsible */
				OR substring(us.US_DPT_CODE,0,4) = '-IT' /* super user */)
				THEN 'IT' 
			ELSE '' END)   as Procurement_RoleFlag 

 ,CAST(STUFF(
	(SELECT DISTINCT ',' + tg.TAG /*+ ' ('+tg.TagCategory+')'*/
		FROM ttag /*V_TheCompany_TTag_Detail*/ tg
		inner join TTAG_IN_OBJECT tj on tg.tagid = tj.tagid
		 inner join tdocument d on tj.OBJECTID = d.documentid 
		WHERE c.CONTRACTID =d.OBJECTID
		FOR XML PATH('')),1,1,'') AS VARCHAR(255)) AS Tags	
 
	, cr.[AgrIsDivestment] as AgreementTypeDivestment
	, cast(rd.[ReviewDate_Reminder_RecipientList] as varchar(255)) as ReviewDate_Reminder_RecipientList /* somehow still nvarchar max */

/* Company - uses CAST */
	, CompanyCountryList
	, CompanyCountry_IsUS
	, CompanyActivityDateMax

	, c.COMMENTS_255 /* if not truncated: nvarchar 2000 , orig. value is 4000*/
/*Documents */
	,  doc.[DocTitlesFileTypeConcatTSRedacted_255] as DocumentFileTitlesConcat /* Redacted */

	 , ISNULL([InternalPartners_DptCodeList],'') AS InternalPartners_DptCodeList
	 , [TERMINATIONPERIOD]
	, CAST(left([TERMINATIONCONDITIONS],255) as varchar(255)) as TERMINATIONCONDITIONS /* nvarchar 512 */
	, REFERENCECONTRACTID

	, cr.Agr_IsMaterial_Flag
	, cr.AgrIsMaterial
	*/
FROM 
 V_TheCompany_VCONTRACT c
/* this view turns TCONTRACT nulls into empty strings etc., custom version of VCONTRACT */
/* fields like agreement_type etc  */

	inner join (SELECT 
		Contractid as US_Contractid
		, userid as US_Userid
	, displayname as US_DisplayName
	, EMAIL as US_Email
	, FIRSTNAME as US_Firstname
	, PRIMARYUSERGROUP as US_PrimaryUserGroup /* field size in TUSERGROUP is 450 char */
	, MIK_VALID US_USER_MIK_VALID 
	, DEPARTMENT_CODE as US_DPT_CODE
	, DEPARTMENT as US_DPT_NAME
	 from dbo.V_TheCompany_VPERSONROLE_IN_OBJECT where [Roleid_Cat2Letter]='US' ) us on c.contractid = us.US_Contractid

	left join (SELECT 
		Contractid  as UO_Contractid
		, userid as UO_Userid
	, displayname as UO_DisplayName
	, EMAIL as UO_Email
	, FIRSTNAME as UO_Firstname 
	, PRIMARYUSERGROUP as UO_PrimaryUserGroup /* field size in TUSERGROUP is 450 char */
	, MIK_VALID as UO_USER_MIK_VALID 
	, DEPARTMENT_CODE as UO_DPT_CODE
	, DEPARTMENT as UO_DPT_NAME
	  FROM dbo.V_TheCompany_VPERSONROLE_IN_OBJECT  where [Roleid_Cat2Letter]='UO') uo on c.contractid = uo.UO_Contractid

	left join (SELECT 
		Contractid as UR_Contractid
		, userid as UR_Userid
	, displayname as UR_DisplayName
	, EMAIL as UR_Email
	,  FIRSTNAME as UR_Firstname /*, FIRSTNAME */
	, PRIMARYUSERGROUP as UR_PrimaryUserGroup /* field size in TUSERGROUP is 450 char */
	, MIK_VALID as UR_USER_MIK_VALID 
	, DEPARTMENT_CODE as UR_DPT_CODE 
	, DEPARTMENT as UR_DPT_NAME
	  FROM dbo.V_TheCompany_VPERSONROLE_IN_OBJECT where [Roleid_Cat2Letter]='UR') ur on c.contractid = ur.UR_Contractid

	inner join [dbo].[V_TheCompany_VCONTRACT_DPTROLES_FLAT] d /* 5 SECONDS - made inner join 22-feb */
		on c.contractid = d.Dpt_contractid
				/* NOT NEEDED left join dbo.V_TheCompany_VCONTRACT_PERSONROLES_FLAT pf on c.CONTRACTID = pf.Prs_contractid */
				inner join dbo.T_TheCompany_Hierarchy h /* 16 seconds together with d table ; delete from then insert into in mktbl query */
			/* in the daily data load, the hierarchy is refreshed first, so this table is up to date */
			on d.Dpt_ContractOwnerDpt_ID = h.departmentid_link

	left join [dbo].[V_TheCompany_VPRODUCTS_FLAT] p /* 1 SECOND - optimized to use CAST and LEFT */
		on c.contractid = p.vp_contractid
				/* NOT NEEDED left join dbo.VCOMMERCIAL vc on c.CONTRACTID = vc.ContractId */

	left join dbo.VCONTRACT_LUMPSUM vc on c.LUMPSUMAMOUNTID = vc.LUMPSUMAMOUNTID /* 1 SECOND */

	left join [dbo].[V_TheCompany_REVIEWDATE_ACTIVE] rd /* 1 SECOND, optimized */
		on c.contractid = rd.RD_Contractid

	inner join V_TheCompany_AgreementType cr  /* 1 SECOND - made inner join 22-feb */
		on c.AGREEMENT_TYPEID = cr.[AgrTypeID]

	left join T_TheCompany_TTENDERER_FLAT /* V_TheCompany_TTENDERER_FLAT */ t /* 1 second */
		on c.contractid = t.CONTRACTID
/*
	/* NOT working because t_TheCompany_all is used in view left join V_TheCompany_Mig_0ProcNetFlag m on c.contractid = m.Contractid_Proc /* for procurement flag */*/
	left join [dbo].[V_TheCompany_Docs_FLAT] doc /* 1 sec, added 09-Dec-2020 */
		on c.contractid = doc.CONTRACTID 


	*/
	WHERE c.contracttypeid NOT IN (	  5 /* Test Old */
									, 6 /* Access SAKSNR number Series*/		
									/*,  11	Case */					
									, 13 /* DELETE */
									, 102 /* Test New */								
									, 103, 104, 105 /* Lists */
									, 106 /* AutoDelete */
									)
									
/* and c.CONTRACTID = 148186 /* contractnumber = 'TEST-00000080' */  */
  
GO
/****** Object:  UserDefinedFunction [dbo].[tudf_get_companyid]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[tudf_get_companyid] (@contractid bigint)
returns table
as
return

select companyid from 
	(
		select r.companyid,
		count(r.companyid) over (partition by r.contractid) as company_count
		from  ttenderer r
		where  r.isawarded = 1 and r.contractid = @contractid
     ) ci where ci.company_count = 1 

GO
/****** Object:  View [dbo].[VSEARCHCONTRACTCUSTOMFIELDS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VSEARCHCONTRACTCUSTOMFIELDS]
AS
	
	SELECT DISTINCT

		C.CONTRACTID,
		C.CONTRACTNUMBER,

		C.CONTRACT, 
		C.STARTDATE, 
		C.EXPIRYDATE, 
		C.REV_EXPIRYDATE AS REVEXPIRYDATE, 
		C.AWARDDATE, 
		C.STATUSID, 
		C.REFERENCECONTRACTNUMBER, 
		C.COUNTERPARTYNUMBER, 
		C.REFERENCECONTRACTID, 
		C.STRATEGYTYPEID, 
		C.CONTRACTTYPEID, 
		vcompany.companyid as COMPANYID, 
		C.CONTRACTRELATIONID, 
		C.REVIEWDATE, 
		C.DEFINEDENDDATE, 
		C.SIGNEDDATE, 
		C.CONTRACTDATE, 
		C.REFERENCENUMBER,
		C.PUBLISH,

		CR.FIXED AS 'CONTRACTRELATIONFIXED',
		CR.CONTRACTRELATION AS 'CONTRACTRELATION',
		(SELECT CONTRACTTYPE FROM dbo.TCONTRACTTYPE WHERE CONTRACTTYPEID = C.CONTRACTTYPEID) AS 'CONTRACTTYPE',
		S.FIXED AS 'STATUSFIXED',
		S.STATUS AS 'STATUS',
		(SELECT AGREEMENT_TYPE FROM dbo.TAGREEMENT_TYPE WHERE AGREEMENT_TYPEID = C.AGREEMENT_TYPEID) AS 'AGREEMENTTYPE',
		vcompanylist.AwardedCompanyNames  AS 'COMPANY',
		(SELECT
			COUNTRY
		 FROM
			dbo.TCOUNTRY AS CO
				INNER JOIN
				dbo.TCOMPANYADDRESS AS CA ON (CO.COUNTRYID = CA.COUNTRYID)
					INNER JOIN
					dbo.TADDRESSTYPE AS ADT ON (CA.ADDRESSTYPEID = ADT.ADDRESSTYPEID AND ADT.FIXED = 'MAINADDRESS')
		 WHERE
			CA.COMPANYID = vcompany.companyid) AS 'COUNTRY',
		'MAINADDRESS' AS 'ADDRESSTYPEFIXED',
		(SELECT STRATEGYTYPE FROM dbo.TSTRATEGYTYPE WHERE STRATEGYTYPEID = C.STRATEGYTYPEID) AS 'STRATEGYTYPE',
		(SELECT CONTRACTNUMBER FROM dbo.TCONTRACT WHERE CONTRACTID = C.REFERENCECONTRACTID) AS 'LINKEDTONUMBER',

		'CLIENT FIELD' AS 'FIELDTYPE',
		CFIC.CLIENTFIELDID AS 'FIELDID',
		CFIC.CLIENTFIELD AS 'FIELDNAME',
		CFIC.CLIENTFIELDRANGEINCONTRACTID AS 'FIELDINCONTRACTID',
		CFIC.MULTIVALUE AS 'FIELDVALUE',
		CFIC.LEVEL1ID,
		CFIC.LEVEL1,
		CFIC.LEVEL2ID,
		CFIC.LEVEL2,
		CFIC.LEVEL3ID,
		CFIC.LEVEL3,
		CFIC.LEVEL4ID,
		CFIC.LEVEL4,
		PERSON.DISPLAYNAME		
	FROM
		dbo.TCONTRACT AS C
			INNER JOIN
			dbo.TCONTRACTRELATION AS CR ON (C.CONTRACTRELATIONID = CR.CONTRACTRELATIONID)
	
			INNER JOIN
			dbo.TSTATUS AS S ON (C.STATUSID = S.STATUSID)


			INNER JOIN
			(SELECT
				CLF.CLIENTFIELDID,
				CLF.CLIENTFIELD,
				CFIC.CONTRACTID,
				CFIC.CLIENTFIELDRANGEINCONTRACTID,
				(ISNULL(L1.LEVEL1, '') + ISNULL(', ' + L2.LEVEL2, '') + ISNULL(', ' + L3.LEVEL3, '') + ISNULL(', ' + L4.LEVEL4, '')) AS MULTIVALUE,
				CFIC.LEVEL1ID,
				L1.LEVEL1,
				CFIC.LEVEL2ID,
				L2.LEVEL2,
				CFIC.LEVEL3ID,
				L3.LEVEL3,
				CFIC.LEVEL4ID,
				L4.LEVEL4
			FROM
				dbo.TCLIENTFIELD AS CLF 

					INNER JOIN
					dbo.TOBJECTTYPE AS OT ON (CLF.OBJECTTYPEID = OT.OBJECTTYPEID AND OT.FIXED = N'CONTRACT')
			
					LEFT JOIN
					dbo.TCLIENTFIELDRANGE_IN_CONTRACT AS CFIC ON (CLF.CLIENTFIELDID = CFIC.CLIENTFIELDID)
			
						LEFT JOIN
						dbo.TLEVEL1 AS L1 ON (CFIC.LEVEL1ID = L1.LEVEL1ID)
			
						LEFT JOIN
						dbo.TLEVEL2 AS L2 ON (CFIC.LEVEL2ID = L2.LEVEL2ID)
			
						LEFT JOIN
						dbo.TLEVEL3 AS L3 ON (CFIC.LEVEL3ID = L3.LEVEL3ID)
			
						LEFT JOIN
						dbo.TLEVEL4 AS L4 ON (CFIC.LEVEL4ID = L4.LEVEL4ID)
		
			WHERE
				CLF.MIK_VALID = 1) AS CFIC ON (C.CONTRACTID = CFIC.CONTRACTID)

            OUTER APPLY dbo.tudf_get_companyid(c.contractid)  vcompany
			OUTER APPLY dbo.TVF_GetContractAwardedCompanyNames(c.contractid) vcompanylist 

			LEFT JOIN	(
						SELECT	PIO.OBJECTID	,
							P.DISPLAYNAME	,
							P.FIRSTNAME	,
							P.MIDDLENAME	,
							P.LASTNAME
						FROM	TPERSON	P
						JOIN	TPERSONROLE_IN_OBJECT PIO
						ON	P.PERSONID	 	= PIO.PERSONID
						AND	PIO.OBJECTTYPEID	= 
							( SELECT OBJECTTYPEID FROM TOBJECTTYPE WHERE FIXED = 'CONTRACT')
						JOIN	TROLE	R
						ON	R.ROLEID	= PIO.ROLEID
						AND	R.FIXED		= (
SELECT	ISNULL( PS.SETTINGVALUE, PK.DEFAULTVALUE)
				AS	SETTINGVALUE
FROM	TPROFILESETTING		PS
JOIN	TPROFILEKEY	PK
ON	PS.PROFILEKEYID	= PK.PROFILEKEYID
AND	PK.FIXED	= 'CONTRACT_DISPLAY_PERSON_ROLE'
AND	PS.USERID	IS NULL
AND	PS.USERGROUPID	IS NULL
AND	PS.MIK_VALID	= 1
							)
						AND	R.MIK_VALID	= 1
						AND	R.ISPERSONROLE	= 1) AS PERSON
			ON PERSON.OBJECTID	= C.CONTRACTID

			
	
	WHERE
		NOT CFIC.CONTRACTID IS NULL

	UNION
	
	SELECT DISTINCT
		C.CONTRACTID,
		C.CONTRACTNUMBER,

		C.CONTRACT, 
		C.STARTDATE, 
		C.EXPIRYDATE, 
		C.REV_EXPIRYDATE AS REVEXPIRYDATE, 
		C.AWARDDATE, 
		C.STATUSID, 
		C.REFERENCECONTRACTNUMBER, 
		C.COUNTERPARTYNUMBER, 
		C.REFERENCECONTRACTID, 
		C.STRATEGYTYPEID, 
		C.CONTRACTTYPEID, 
		vcompany.companyid as COMPANYID, 
		C.CONTRACTRELATIONID, 
		C.REVIEWDATE, 
		C.DEFINEDENDDATE, 
		C.SIGNEDDATE, 
		C.CONTRACTDATE, 
		C.REFERENCENUMBER,
		C.PUBLISH,

		CR.FIXED AS 'CONTRACTRELATIONFIXED',
		CR.CONTRACTRELATION AS 'CONTRACTRELATION',
		
		(SELECT CONTRACTTYPE FROM dbo.TCONTRACTTYPE WHERE CONTRACTTYPEID = C.CONTRACTTYPEID) AS 'CONTRACTTYPE',
		S.FIXED AS 'STATUSFIXED',
		S.STATUS AS 'STATUS',
		(SELECT AGREEMENT_TYPE FROM dbo.TAGREEMENT_TYPE WHERE AGREEMENT_TYPEID = C.AGREEMENT_TYPEID) AS 'AGREEMENTTYPE',
		vcompanylist.AwardedCompanyNames  AS 'COMPANY',
		(SELECT
			COUNTRY
		 FROM
			dbo.TCOUNTRY AS CO
				INNER JOIN
				dbo.TCOMPANYADDRESS AS CA ON (CO.COUNTRYID = CA.COUNTRYID)
					INNER JOIN
					dbo.TADDRESSTYPE AS ADT ON (CA.ADDRESSTYPEID = ADT.ADDRESSTYPEID AND ADT.FIXED = 'MAINADDRESS')
		 WHERE
			CA.COMPANYID = vcompany.companyid) AS 'COUNTRY',
		'MAINADDRESS' AS 'ADDRESSTYPEFIXED',
		(SELECT STRATEGYTYPE FROM dbo.TSTRATEGYTYPE WHERE STRATEGYTYPEID = C.STRATEGYTYPEID) AS 'STRATEGYTYPE',
		(SELECT CONTRACTNUMBER FROM dbo.TCONTRACT WHERE CONTRACTID = C.REFERENCECONTRACTID) AS 'LINKEDTONUMBER',

		'EXTRA FIELD' AS 'FIELDTYPE',
		EFIC.EXTRA_FIELDID AS 'FIELDID',
		EF.MIK_LABEL_TEXT AS 'FIELDNAME',
		EFIC.EXTRAFIELDINCONTRACTID AS 'FIELDINCONTRACTID',
		EFIC.MIK_EDIT_VALUE AS 'FIELDVALUE',
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		PERSON.DISPLAYNAME
	FROM
		dbo.TCONTRACT AS C
			INNER JOIN
			dbo.TCONTRACTRELATION AS CR ON (C.CONTRACTRELATIONID = CR.CONTRACTRELATIONID)

			INNER JOIN
			dbo.TSTATUS AS S ON (C.STATUSID = S.STATUSID)

	
			INNER JOIN
			dbo.TEXTRA_FIELD_IN_CONTRACT AS EFIC ON (C.CONTRACTID = EFIC.CONTRACTID)
	
				INNER JOIN
				dbo.TEXTRA_FIELD AS EF ON (EF.EXTRA_FIELDID = EFIC.EXTRA_FIELDID)

			OUTER APPLY dbo.tudf_get_companyid(c.contractid)  vcompany
			OUTER APPLY dbo.TVF_GetContractAwardedCompanyNames(c.contractid) vcompanylist 

			LEFT JOIN	(
						SELECT	PIO.OBJECTID	,
							P.DISPLAYNAME	,
							P.FIRSTNAME	,
							P.MIDDLENAME	,
							P.LASTNAME
						FROM	TPERSON	P
						JOIN	TPERSONROLE_IN_OBJECT PIO
						ON	P.PERSONID	 	= PIO.PERSONID
						AND	PIO.OBJECTTYPEID	= 
							( SELECT OBJECTTYPEID FROM TOBJECTTYPE WHERE FIXED = 'CONTRACT')
						JOIN	TROLE	R
						ON	R.ROLEID	= PIO.ROLEID
						AND	R.FIXED		= (

SELECT	ISNULL( PS.SETTINGVALUE, PK.DEFAULTVALUE)
				AS	SETTINGVALUE
FROM	TPROFILESETTING		PS
JOIN	TPROFILEKEY	PK
ON	PS.PROFILEKEYID	= PK.PROFILEKEYID
AND	PK.FIXED	= 'CONTRACT_DISPLAY_PERSON_ROLE'
AND	PS.USERID	IS NULL
AND	PS.USERGROUPID	IS NULL
AND	PS.MIK_VALID	= 1
							)
						AND	R.MIK_VALID	= 1
						AND	R.ISPERSONROLE	= 1) AS PERSON
			ON PERSON.OBJECTID	= C.CONTRACTID

		  

	WHERE
		EF.MIK_VALID = 1 AND
		NOT EFIC.CONTRACTID IS NULL



GO
/****** Object:  View [dbo].[V_TheCompany_TheVendorTablesColumns]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_TheVendorTablesColumns] as

	SELECT 
		(case when t.name is not null then t.name else v.name END) AS TableViewName
		,(case when t.name is not null then 'Table' else 'View' END) AS TableOrView
		, c.name as ColumnName
	/*	, TC.ValueTop1 as SampleValueTop1TruncVarchar255 */
		, ci.DATA_TYPE
		, ci.CHARACTER_MAXIMUM_LENGTH AS CHAR_MAX_LEN
		, ci.NUMERIC_PRECISION AS NUM_PRECISION
		, ci.NUMERIC_SCALE AS NUM_SCALE
		, c.is_nullable
		, c.is_identity 
		/* , fk_cols.constraint_column_id */
		, pk_tab.name as FK_TableName
		, cf.name as FK_TableColName
		, (CASE WHEN t.object_id is not null then t.object_id else v.object_id END) AS ObjectID
		, t.object_id AS TableObjectID
		, c.column_id as ColumnID

	From sys.columns c 
		LEFT JOIN sys.tables t
			on t.object_id = c.object_id
		left outer join sys.foreign_key_columns fk_cols
			on fk_cols.parent_object_id = t.object_id
			and fk_cols.parent_column_id = c.column_id
		left outer join sys.foreign_keys fk
			on fk.object_id = fk_cols.constraint_object_id
		left outer join sys.tables pk_tab
			on pk_tab.object_id = fk_cols.referenced_object_id
		left outer join sys.columns pk_col
			on pk_col.column_id = fk_cols.referenced_column_id
			and pk_col.object_id = fk_cols.referenced_object_id

		LEFT JOIN sys.views v 
			 on v.object_id = c.object_id
			LEFT JOIN INFORMATION_SCHEMA.COLUMNS ci
				on (t.name  = ci.TABLE_NAME or v.name = ci.TABLE_NAME) and c.name = ci.column_name

		left join sys.columns cf on
			fk_cols.referenced_object_id = cf.object_id
				and fk_cols.referenced_column_id = cf.column_id
	/*
		LEFT JOIN [dbo].[T_TheCompany_TheVendorTablesColumns] tc on 
		(t.Name = TC.tablename and c.name = TC.columnname) OR (v.Name = TC.tablename and c.name = TC.columnname)
		*/
	WHERE  t.name is not null OR v.name is not null

GO
/****** Object:  View [dbo].[V_TheCompany_TheVendorTables]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_TheVendorTables]

as 

	select 
		* 
		,  (CASE WHEN [TblVwName] like 'T%' then 'T' ELSE 'V' END) AS TblVwIsTblOrVw

		, (select ColumnName from [dbo].[V_TheCompany_TheVendorTablesColumns] 
		where ObjectID = [TblVwObjectID] AND is_identity = 1) as TblVwColumnIdentity

		, (select ColumnName from [dbo].[V_TheCompany_TheVendorTablesColumns] 
		where ObjectID = [TblVwObjectID] AND ColumnName in ('OBJECTID', 'CONTRACTID')) as TblVwObject_FK

		, (select ColumnName from [dbo].[V_TheCompany_TheVendorTablesColumns] 
		where ObjectID = [TblVwObjectID] AND ColumnName ='OBJECTTYPEID') as TblVwOBJECTTYPEID

	from [dbo].[T_TheCompany_TheVendorTables]

GO
/****** Object:  View [dbo].[V_TheCompany_VDepartment_Territories]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[V_TheCompany_VDepartment_Territories]

AS 
/* TheCompany_Maintenance_TerritoryHashTags for #gem etc */
	SELECT TOP 1000
      
      [L0]
	  , h.[Dpt_Concat_List] /* as DEPARTMENT_CONCAT */
	  , d.[DEPARTMENT]	
	   ,d.[NodeType]	  	       
	       
      ,[L1]
      ,[L2]
      ,[L3]
      ,[L4]
   , [LEVEL]
      ,d.[DEPARTMENT_CODE]
      /* ,d.[DEPARTMENTLEVEL] use level */

      ,d.[MIK_SEQUENCE]    
      ,d.[DPT_CODE_2Digit_TerritoryRegion]

     
      ,d.[NodeRole]
      ,d.[NodeMajorFlag]

      , [DPT_LOWEST_ID_TO_SHOW]
	  
      ,d.[PARENTID]
      ,d.[ISROOT]
	  ,d.[FieldCategory] /* dupe */
	  ,d.[MIK_VALID]
	   ,d.departmentid
	   , h.Parent_Department
	/*, (case when departmentlevel = 1 then 'Active' Else 'Inactive' end) as Territory */
	FROM V_TheCompany_VDepartment_Parsed d 
		inner join T_TheCompany_Hierarchy h on d.departmentid = h.DEPARTMENTID
	WHERE  MIK_VALID = 1 AND
		h.[L0]= 'Territories - Region'
	ORDER BY h.[Dpt_Concat_List] asc

GO
/****** Object:  View [dbo].[V_TheCompany_Edit_VUSER_ActiveUsersWithoutADLink]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_Edit_VUSER_ActiveUsersWithoutADLink]

as

select 
[USERID]
, [DISPLAYNAME]
, [PRIMARYUSERGROUP]
, [UserProfile]

from V_TheCompany_VUSER
where 
[DOMAINNETBIOSUSERNAME] is null
and USER_MIK_VALID = 1
GO
/****** Object:  View [dbo].[V_TheCompany_VCONTRACT_PERSONROLES_FLAT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_VCONTRACT_PERSONROLES_FLAT]

as

	SELECT
		'' /*max([Number]) */as Prs_ContractNumber
		, [CONTRACTID] AS Prs_contractid

	/* All Roles */

			, convert(varchar(255),Replace(STUFF(
		(SELECT ',' + s.DISPLAYNAME
		FROM V_TheCompany_VPERSONROLE_IN_OBJECT s
		WHERE s.CONTRACTID = p.contractid 
		/* AND s.ROLEID IN(1,19,20,34,23 /*Super User*/
			,2 /* Contract Owner*/
			,15,36 /* Contract Responsible*/  ) */
		FOR XML PATH('')),1,1,''),'&amp;','&') )
	AS Dpt_AllPersonNameList

	/* SUPER USER */

		, (SELECT s.DISPLAYNAME
		FROM V_TheCompany_VPERSONROLE_IN_OBJECT s
		WHERE s.CONTRACTID = p.contractid
			AND s.ROLEID IN(1,19,20,34,23 /*Super User*/)
			and personid > 0 /* all employees */
			)
		AS Prs_SuperUserDisplayName

		, (SELECT s.DISPLAYNAME
			FROM V_TheCompany_VPERSONROLE_IN_OBJECT s
			WHERE 
			s.CONTRACTID = p.CONTRACTID 
			AND s.ROLEID = 2 /* Contract Owner*/
		) AS Prs_ContractOwnerDisplayName /* contract owner name */

		, (SELECT s.EMAIL
			FROM V_TheCompany_VPERSONROLE_IN_OBJECT s
			WHERE 
			s.CONTRACTID = p.CONTRACTID 
			AND s.ROLEID = 2 /* Contract Owner*/
		) AS Prs_ContractOwnerEMAIL /* contract owner name */
		
		, (SELECT s.EMAIL
			FROM V_TheCompany_VPERSONROLE_IN_OBJECT s
			WHERE 
			s.CONTRACTID = p.CONTRACTID 
			AND s.ROLEID = 110 /* Signatory */
		) AS Prs_ContractSignatoryEMAIL /* contract owner name */

	FROM V_TheCompany_VPERSONROLE_IN_OBJECT  /*[V_TheCompany_VCONTRACT_PERSONROLES] */ p
	/* WHERE p.CONTRACTID not in(select CONTRACTID from tcontract where CONTRACTTYPEID  IN  ('6' /* Access SAKSNR number Series*/, '5' /* Test Old */,'102' /* Test New */,'13' /* DELETE */ )) */

	GROUP BY 
		[CONTRACTID]


GO
/****** Object:  View [dbo].[V_TheCompany_Mig_2T_TheCompany_AllUp]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view

[dbo].[V_TheCompany_Mig_2T_TheCompany_AllUp]
as

select * from dbo.T_TheCompany_ALL a 
inner join dbo.V_TheCompany_Mig_0ProcNetFlag p on a.Contractid = p.Contractid_Proc




GO
/****** Object:  View [dbo].[V_TheCompany_VCompare_T1_0Raw]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_VCompare_T1_0Raw]

/* 
[dbo].[TheCompany_KeyWordSearch]
- elminiate double spaces
- ltrim, rtrim
*/
as

	select 
		* 
		, dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([Name1]) as Name1_LettersNumbersOnly
		, replace(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([Name1]),'  ',' ') as Name1_LettersNumbersSpacesOnly /* e.g. Hansen & Rosenthal */
		, LEN(replace(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([Name1]),'  ',' '))
				-LEN(dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([Name1])) 
				as Name1_LettersNumbersOnly_NumSpacesWords
	from [dbo].[T_TheCompany_Compare_T1]
	/* where [KeyWordVarchar255] like 'Si%' */
	/* where dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([KeyWordVarchar255]) like '%  %' */

GO
/****** Object:  View [dbo].[V_TheCompany_VCompare_T1_1Final]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_VCompare_T1_1Final]
/* refreshed via TheCompany_Name1_Search */
as

	select 
		c.*
		, len([Name1]) as Name1_Length

		/*	, SUBSTRING(Name1_LettersNumbersSpacesOnly,1,(CHARINDEX(' ',Name1_LettersNumbersSpacesOnly + ' ')-1)) 
		as Name1_FirstWord */
			, Upper([dbo].[TheCompany_GetFirstWordInString](Name1_LettersNumbersSpacesOnly))
		as Name1_FirstWord

	/*		,SUBSTRING([Name1_LettersNumbersOnly],1,(CHARINDEX(' ',[Name1_LettersNumbersOnly] + ' ')-1))
		as Name1_FirstWord_LettersOnly */
			, Upper([dbo].[TheCompany_GetFirstWordInString]([Name1_LettersNumbersOnly]))
		as Name1_FirstWord_LettersOnly

			, LEN([dbo].[TheCompany_GetFirstWordInString]([Name1])) 
		as Name1_FirstWord_LEN

		/* two words or more */
		, Upper((CASE WHEN [Name1_LettersNumbersOnly_NumSpacesWords] = 1 
					THEN [Name1_LettersNumbersSpacesOnly] /* one space */
				WHEN Name1_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN SUBSTRING([Name1_LettersNumbersSpacesOnly],0,CHARINDEX(' ', [Name1_LettersNumbersSpacesOnly],
						CHARINDEX(' ', [Name1_LettersNumbersSpacesOnly],
									   CHARINDEX(' ', [Name1_LettersNumbersSpacesOnly],+1)+1)) )	/* e.g. SI Group */	
				ELSE NULL /* no space */ END)		)	
		as Name1_FirstTwoWords

		, (CASE WHEN [Name1_LettersNumbersOnly_NumSpacesWords] = 1 /* two words, one space */
					THEN [Name1_LettersNumbersOnly]
				WHEN Name1_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(SUBSTRING([Name1_LettersNumbersSpacesOnly],0,CHARINDEX(' ', [Name1_LettersNumbersSpacesOnly],
						CHARINDEX(' ', [Name1_LettersNumbersSpacesOnly],
									   CHARINDEX(' ', [Name1_LettersNumbersSpacesOnly],+1)+1)) ))	/* e.g. SI Group */	
				ELSE NULL /* no space */ END)			
		as Name1_FirstTwoWords_LettersOnly

			,  LEN((CASE WHEN [Name1_LettersNumbersOnly_NumSpacesWords] = 1 /* two words, one space */
					THEN [Name1_LettersNumbersOnly]
				WHEN Name1_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(SUBSTRING([Name1_LettersNumbersSpacesOnly],0,CHARINDEX(' ', [Name1_LettersNumbersSpacesOnly],
						CHARINDEX(' ', [Name1_LettersNumbersSpacesOnly],
									   CHARINDEX(' ', [Name1_LettersNumbersSpacesOnly],+1)+1)) ))	/* e.g. SI Group */	
				ELSE NULL /* no space */ END)	)	
		as Name1_FirstTwoWords_LettersOnly_LEN

		, (CASE WHEN LEN(dbo.TheCompany_GetFirstLetterOfEachWord([Name1_LettersNumbersSpacesOnly])) >=3 
			 THEN 
				/* dbo.TheCompany_GetFirstLetterOfEachWord([Name1_LettersNumbersOnly])
			WHEN LEN(dbo.TheCompany_GetFirstLetterOfEachWord([Name1_LettersNumbersOnly]))<3 
				and len(left([[Name1_LettersNumbersOnly],3)) >=3 THEN */
				left([Name1_LettersNumbersOnly],3)
			ELSE NULL END
			) 
			as Name1_FirstLetterOfEachWord

	from V_TheCompany_VCompare_T1_0Raw c

GO
/****** Object:  View [dbo].[V_TheCompany_VCompare_Results_5_NoMatches_Name1]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View [dbo].[V_TheCompany_VCompare_Results_5_NoMatches_Name1]

as 

	select 'Name1' as MatchLevel
		, '9None' as MatchKind
		, Name1
		, '' as Name2
		, [Name1_FirstWord]
		, '' as [Name2_FirstWord]
		,  [Name1_LettersNumbersSpacesOnly] 
		, '' as [Name2_LettersNumbersSpacesOnly] 

	FROM
		[dbo].[V_TheCompany_VCompare_T1_1Final] 
	WHERE 
		[Name1] not in (select [Name1] from T_TheCompany_VCompare_Results_0Exact)
		and [Name1] not in (select [Name1] from T_TheCompany_VCompare_Results_1LikeFull)
		and [Name1] not in (select [Name1] from T_TheCompany_VCompare_Results_2FirstWord)
		and [Name1] not in (select [Name1] from T_TheCompany_VCompare_Results_3LikeLeft8)

GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_NoTS_STD]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[V_T_TheCompany_ALL_NoTS_STD]

as

SELECT 

	/* [ContractRelationFIXED] */
		  [Number] as 'Contract Number'

		  /* ,[Title] as 'Contract Description' */
		  , [Title] as 'Contract Description' /*  no top secret descriptions */
		  ,[AGREEMENT_TYPE] as 'Agreement Type'
		  , [AgreementTypeDivestment] 
				as 'Agreement Type Divestment'
		  ,[ContractRelations] as 'Contract Relation'
		  ,[CONTRACTTYPE] as 'Contract Type'
		  , STRATEGYTYPE as 'HCP/HCO Flag'
		  /* ,[COMMENTS] */
		  ,[STATUS] as 'Status'
		  ,[CONTRACTDATE] AS 'Registered Date'
		  , RegisteredDateNumMthCat as 'Reg Date Cat'
	/*  ,[AWARDDATE] as 'Award Date' */
		  ,[STARTDATE] AS 'Start Date'
		  /* ,[EXPIRYDATE] AS 'Original End Date'
		  ,[REV_EXPIRYDATE] AS 'New End Date' */
		  ,[FINAL_EXPIRYDATE] AS 'End Date'
		  , [DEFINEDENDDATE] as 'End Date - Defined Flag'		
		  ,[REVIEWDATE] AS 'Review Date'
		, [RD_ReviewDate_Warning] as 'Review Date Reminder'
		, ReviewDate_Reminder_RecipientList
	/*  ,[CHECKEDOUTDATE] */


		  /* ,[STATUSID] */
		  /* ,[StatusFixed] */
		  ,[NUMBEROFFILES]  as 'Number of Attachments'
		  , DocumentFileTitlesConcat as 'Attachment Titles'

		  ,[REFERENCENUMBER] AS 'Reference Number'
		  ,[COUNTERPARTYNUMBER] as 'Counter Party Reference' /* e.g. needed for procurement wave */
		  /* ,[REFERENCECONTRACTID] */
		  ,[REFERENCECONTRACTNUMBER] as 'Linked Contract Number'

		  /* ,[StatusMikSequence] */

		  /* ,[AGREEMENT_TYPEID] */
		  /* ,[AGREEMENT_MIK_VALID] */
		  ,[CompanyList] as 'Company Names'
		  , CompanyCountryList as 'Company Country List'
		  ,[CompanyIDAwardedCount] as 'Company Count'
		  /* , [CompanyIDUnawardedCount] as 'Company Count (Unawarded)' */
		   , [ConfidentialityFlag] as 'Confidentiality Flag'
		  /* ,[INGRESS] */
		 /*  ,[SUMMARYBODY] */
		  /* ,[US_Userid] */
		  ,[US_DisplayName] as 'Super User Name'
		  ,[US_Email] as 'Super User Email'
		 /* ,[US_Firstname] as 'Super User First Name' */
		  ,[US_PrimaryUserGroup] as 'Super User Primary User Group'
		  ,[US_USER_MIK_VALID] as 'Super User Active Flag'
		  /* ,[UO_employeeid] */
		  ,[UO_DisplayName] as 'Owner Name'
		  ,[UO_Email] as 'Owner Email'
		  ,[UO_Firstname] as 'Owner First Name'
		  ,[UO_PrimaryUserGroup] as 'Owner Primary User Group'
		  ,[UO_USER_MIK_VALID] as 'Owner Active Flag'
		  /* ,[UR_employeeid] */
		  ,[UR_DisplayName] as 'Responsible Name'
		  ,[UR_Email] as 'Contract Responsible Email'
		   ,[UR_Firstname] as 'Responsible First Name'
		  ,[UR_PrimaryUserGroup] as 'Responsible Primary User Group'
		  ,[UR_USER_MIK_VALID] as 'Responsible Active Flag'
  

		 /*     ,[SuperUserDpt]
		 ,[SuperUserDpt_ID] 
		   ,[ContractOwnerDpt]
		  ,[ContractOwnerDpt_ID]
		  ,[ContractResponsibleDpt]
		  ,[ContractResponsibleDpt_ID] */
		  ,[InternalPartners] as 'Internal Partners'
		  /* ,[InternalPartners_IDs] */
		  , [InternalPartners_COUNT] as 'Internal Partners Count'
		  , [InternalPartners_DptCodeList] as 'Internal Partner Dpt Codes'

		  ,[Territories]
		  /* ,[Territories_IDs] */
		  ,[Territories_COUNT] as 'Territories Count'

		  ,[VP_ProductGroups] as 'All Products'
		  ,[VP_ProductGroups_COUNT] as 'Product Group Count'
		  ,[VP_ActiveIngredients] as 'Active Ingredients'
		  ,[VP_TradeNames] as 'Trade Names'
		  /* ,[VP_DirectProcurement]
		  ,[VP_IndirectProcurement] */

		, [LumpSum] as 'Lump Sum'
		, LumpSumCurrency

		, Tags

		  , L0
			, L1
			, L2
			, L3
			, L4		
		/*	, p.TargetSystem_AgType
			, p.TargetSystem_AgTypeFLAG	
			, p.TargetSystem_MigrateTo */
			 
			, [Proc_NetLabel] as ProcAribaOrTheVendor
			, [Proc_RoleDptName] as Proc_RoleDptName


		  , [CONTRACTID]
		   , [CONTRACTTYPEID] /* as 'Contract Type ID'  needed to filter out cases etc. */
		   , AGREEMENT_TYPEID

		   , DateTableRefreshed /* second last field */
		   , LinkToContractURL /* last field ! */

	FROM
		V_T_TheCompany_ALL a 
	/*	inner join V_TheCompany_Mig_0ProcNetFlag p /* is based on T_TheCompany_ALL */
			on a.CONTRACTID = p.Contractid_Proc /* T_TheCompany_ALL with procurement flags */
			*/

GO
/****** Object:  View [dbo].[V_TheCompany_EcmProdCitrixADGroupMembers]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view
[dbo].[V_TheCompany_EcmProdCitrixADGroupMembers]

as 

select FullString 
,len(FullString ) as len
, (CASE WHEN FullString LIKE '%<%'
	THEN SUBSTRING(FullString
	,CHARINDEX('<',FullString)+1 
	,(CHARINDEX('>',FullString))-CHARINDEX('<',FullString)-1) 
		ELSE '' END) as ParsedEmail

from T_TheCompany_EcmProdCitrixADGroupMembers
where fullstring not like '%AA-%' /* No AD Groups */

GO
/****** Object:  View [dbo].[V_TheCompany_VUSER_SUPER]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_VUSER_SUPER]

as 

select * from V_TheCompany_VUSER
where UserProfileGroup = 'Super User'

GO
/****** Object:  View [dbo].[V_TheCompany_EcmProdCitrixADGroupMembers_Surplus]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view
[dbo].[V_TheCompany_EcmProdCitrixADGroupMembers_Surplus]

as 

select ParsedEmail
, u.email
, u.USER_MIK_VALID
FROM V_TheCompany_EcmProdCitrixADGroupMembers m 
left join dbo.V_TheCompany_VUSER_SUPER u on m.parsedEmail = u.email
where (u.user_mik_valid = 0 
or u.email is null)
and parsedemail <> 'Client.Deployment@TheCompany.com'

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_7_CNT_ContractID_SummaryByContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view

[dbo].[V_TheCompany_KWS_7_CNT_ContractID_SummaryByContractID]

as 
/* EXEC [dbo].[TheCompany_KeyWordSearch] */
	SELECT  
		u.contractid /* as ContractID_KWS */

/* COMPANY */
	
	/* EXACT */

		, COnvert(varchar(255),LEFT(LTRIM(Replace(STUFF(
			(SELECT DISTINCT ',' + c.[CompanyMatch_Exact] 
			FROM [T_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended] c
			WHERE  c.contractid = u.contractid 
				AND c.companyMatch_Exact_Flag > 0 /* can be e.g. 6 */
			FOR XML PATH('')),1,1,''),'&amp;','&')),255))
			AS [CompanyMatch_Exact]

		,
			(SELECT max(CompanyMatch_Exact_Flag)
			FROM [T_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended] c
			WHERE  c.contractid = u.contractid)
			 AS [CompanyMatch_Exact_FLAG]

	/* LIKE */
			,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + c.[CompanyMatch_LIKE] /*+': ' 
				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM [T_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended] c
			where  c.contractid = u.contractid   
				/* and [CompanyMatch_Like_FLAG]  > 0 */
				and [CompanyMatch_Exact_FLAG] = 0
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [CompanyMatch_Like]	

		,
			(SELECT max(CompanyMatch_LIKE_Flag)
			FROM [T_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended] c
			WHERE  c.contractid = u.contractid)
			 AS [CompanyMatch_LIKE_FLAG]

	/* Company ANY */
						,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + c.[KeyWordVarchar255] /*+': ' 
				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM [T_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended] c
			where  c.contractid = u.contractid   
				and [CompanyMatch_Like_FLAG] = 0
				and [CompanyMatch_Exact_FLAG] = 0
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [CompanyMatch_NotExactNotLike]	

						,convert(varchar(1),LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + c.[Companytype] /*+': ' 
				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM [T_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended] c
			where  c.contractid = u.contractid   
			FOR XML PATH('')),1,1,''),'&amp;','&'))) AS CompanyType

	/* Level - Company Match */
	
			, (SELECT MIN( 
				(CASE WHEN [CompanyMatch_Exact_Flag] > 0 THEN '1 - EXACT' 
					WHEN [CompanyMatch_Like_FLAG] > 0 THEN '2a - LIKE' /* begins with keyword */
					WHEN [CompanyMatch_FirstTwoWords_FLAG] > 0 THEN '2b - First Two Words'
					WHEN [CompanyMatch_FirstWord_FLAG] > 0 THEN '3 - First Word'

					WHEN [CompanyMatch_REV_LIKE_FLAG] > 0 THEN '4a - LIKE Rev' /* keyword compared to company instead of vice versa, higher # of char */
					WHEN [CompanyMatch_LIKE2Way_FLAG] > 0 THEN '4b - LIKE 2 Way'
					WHEN [CompanyMatch_REV_LIKE2Way_FLAG] > 0 THEN '4c - LIKE 2 Way Rev'	
					/* WHEN [CompanyMatch_Abbreviation_Flag] > 0 THEN '7 - Abbr. (3 Letters)'	*/	  	
					WHEN [CompanyMatch_FirstWord2Way_FLAG] > 0 THEN '4d - First Word 2-W'
					WHEN [CompanyMatch_FirstWord2Way_REV_FLAG] > 0 THEN '4e - First Word 2-W REV'
					ELSE '' END) 
					)
				FROM T_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid)
					AS [CompanyMatch_Level]

	/* Level - Company Match Category */

			, (SELECT MIN( /* 1 first */
				(CASE WHEN 
						[CompanyMatch_Exact_Flag] > 0 
						THEN 'Company(1-Exact)' 
					WHEN [CompanyMatch_Like_FLAG] > 0 
							OR [CompanyMatch_FirstTwoWords_FLAG] > 0 
						THEN 'Company(2-Like)' 
					WHEN [CompanyMatch_FirstWord_FLAG] > 0
						THEN 'Company(3-FirstWord)' 
					WHEN
							 [CompanyMatch_REV_LIKE_FLAG] > 0 
							OR [CompanyMatch_LIKE2Way_FLAG] > 0 
							OR [CompanyMatch_REV_LIKE2Way_FLAG] > 0 
							/* WHEN [CompanyMatch_Abbreviation_Flag] > 0 THEN '7 - Abbr. (3 Letters)'	*/	  	
								OR [CompanyMatch_FirstWord2Way_FLAG] > 0 
							OR [CompanyMatch_FirstWord2Way_REV_FLAG] > 0 
						THEN 'Company(4-Any)'
					ELSE '' END) 
					)
				FROM T_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid)
					AS [CompanyMatch_LevelCategory]

	/* SCORE - Company Match */
			, (SELECT MAX( 
				(CASE WHEN [CompanyMatch_Exact_Flag] > 0 THEN [CompanyMatch_Exact_Flag]

				WHEN [CompanyMatch_Like_FLAG] > 0 THEN [CompanyMatch_Like_FLAG] /* begins with keyword */
				WHEN [CompanyMatch_FirstTwoWords_FLAG] > 0 THEN [CompanyMatch_FirstTwoWords_FLAG]

				WHEN [CompanyMatch_FirstWord_FLAG] > 0 THEN [CompanyMatch_FirstWord_FLAG]

				WHEN [CompanyMatch_REV_LIKE_FLAG] > 0 THEN [CompanyMatch_REV_LIKE_FLAG] /* keyword compared to company instead of vice versa, higher # of char */
				WHEN [CompanyMatch_LIKE2Way_FLAG] > 0 THEN [CompanyMatch_LIKE2Way_FLAG]
				WHEN [CompanyMatch_REV_LIKE2Way_FLAG] > 0 THEN [CompanyMatch_REV_LIKE2Way_FLAG]
			/*	WHEN [CompanyMatch_Abbreviation_Flag] > 0 THEN [CompanyMatch_Abbreviation_Flag]		*/	 	

				WHEN [CompanyMatch_FirstWord2Way_FLAG] > 0 THEN CompanyMatch_FirstWord2Way_FLAG
				WHEN [CompanyMatch_FirstWord2Way_REV_FLAG] > 0 THEN CompanyMatch_FirstWord2Way_REV_FLAG
				ELSE 0 END)
					)
				FROM T_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid)
					AS [CompanyMatch_Score]

	/* SCORE - Company Name  */
			, convert(nvarchar(255),left((SELECT MAX( 
				(CASE WHEN [CompanyMatch_Exact_Flag] > 0 THEN [CompanyMatch_Exact]
				WHEN [CompanyMatch_Like_FLAG] > 0 THEN [CompanyMatch_Like] /* begins with keyword */
				WHEN [CompanyMatch_REV_LIKE_FLAG] > 0 THEN [CompanyMatch_REV_LIKE] /* keyword compared to company instead of vice versa, higher # of char */
				WHEN [CompanyMatch_LIKE2Way_FLAG] > 0 THEN [CompanyMatch_LIKE2Way]
				WHEN [CompanyMatch_REV_LIKE2Way_FLAG] > 0 THEN [CompanyMatch_REV_LIKE2Way]
			/*	WHEN [CompanyMatch_Abbreviation_Flag] > 0 THEN [CompanyMatch_Abbreviation]		*/			  	
				WHEN [CompanyMatch_FirstTwoWords_FLAG] > 0 THEN [CompanyMatch_FirstTwoWords]
				WHEN [CompanyMatch_FirstWord_FLAG] > 0 THEN [CompanyMatch_FirstWord]
				WHEN [CompanyMatch_FirstWord2Way_FLAG] > 0 THEN CompanyMatch_FirstWord2Way
				WHEN [CompanyMatch_FirstWord2Way_REV_FLAG] > 0 THEN CompanyMatch_FirstWord2Way_REV
				ELSE '' END)
					)
				FROM T_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid),255))
					AS [CompanyMatch_Name]
/* 
idea

/* SCORE - Company Name  */

			, RTRIM((SELECT MAX( 
				(CASE WHEN [CompanyMatch_Exact_Flag] > 0 THEN [CompanyMatch_Exact] + ' ' ELSE '' END)

				+ (CASE WHEN [CompanyMatch_FirstTwoWords_FLAG] > 0 THEN [CompanyMatch_FirstTwoWords] + '; ' ELSE '' END)
				+ (CASE WHEN [CompanyMatch_Like_FLAG] > 0 THEN [CompanyMatch_Like] + ' ' ELSE '' END)

				+ (CASE WHEN [CompanyMatch_REV_LIKE_FLAG] > 0 THEN [CompanyMatch_REV_LIKE] + ' ' ELSE '' END)
				+ (CASE WHEN [CompanyMatch_LIKE2Way_FLAG] > 0 THEN [CompanyMatch_LIKE2Way] + ' ' ELSE '' END)
*/
			, (SELECT MAX([KeyWordVarchar255]) from T_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid) 
					as CompanyMatch_KeyWord

			, (SELECT MAX([KeyWordVarchar255_UPPER]) from T_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid) 
					as CompanyMatch_KeyWord_UPPER	
										   
	/* COUNTRY - Company */

						,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordVarchar255] /*+': ' 
				+ rs.[CompanyMatch_Name]  + ' (Keyword: '+ rs.keywordvarchar255 
				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM T_TheCompany_KWS_2_CNT_TCOMPANYCountry_ContractID rs
			where  rs.contractid = u.contractid   
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [CompanyCountryMatch]	
			

/* CUSTOM FIELDS */

		,Replace(STUFF(
			(
			SELECT DISTINCT ',' + rs.[KeyWordCustom1]
			FROM (select [KeyWordCustom1], contractid from T_TheCompany_KWS_2_CNT_TPRODUCT_ContractID
					UNION
					select [KeyWordCustom1], contractid from T_TheCompany_KWS_2_CNT_TCompany_ContractID
					) rs
			where  rs.contractid = u.contractid
				AND rs.[KeyWordCustom1] IS NOT NULL

			/* and rs.ProductExact_Flag = 1 */
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Custom1_Lists

		,Replace(STUFF(
			(SELECT DISTINCT ',' + rs.[KeyWordCustom2]
			FROM T_TheCompany_KWS_2_CNT_TPRODUCT_ContractID rs
			where  rs.contractid = u.contractid
			AND rs.[KeyWordCustom2] IS NOT NULL
			/* and rs.ProductExact_Flag = 1 */
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Custom2_Lists

	/* DESCRIPTION */

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[DescriptionKeyword]
			FROM [T_TheCompany_KWS_5c_CNT_DESCRIPTION_ContractID] rs
			where  rs.contractid = u.contractid
			/* only include records that are not a company match */
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS Description_Match

	/* INTERNAL PARTNER */

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordVarchar255]
			FROM [T_TheCompany_KWS_2_CNT_InternalPartner_ContractID] rs
			where  rs.contractid = u.contractid
			/* only include records that are not a company match */
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS InternalPartner_Match

	/* TERRITORIES */

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordVarchar255]
			FROM [T_TheCompany_KWS_2_CNT_Territories_ContractID] rs
			where  rs.contractid = u.contractid
			/* only include records that are not a company match */
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS Territory_Match

	/* PRODUCTS */

		,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and p.[ProductMatch_TN] = 1
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_TradeName

						 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and p.[ProductMatch_AI] = 1
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_ActiveIngredients

		 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup
		FROM [dbo].[T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and p.[ProductMatch_Exact] = 1
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Product_EXACT

		 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and p.[ProductMatch_NotExact] = 1
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Product_NotExact

			 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and (p.[ProductMatch_AI] = 1 OR p.[ProductMatch_TN] = 1)
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Product_AIorTN

				 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup 
			+ (CASE WHEN PrdGrpMatch_EXACT_FLAG = 1 THEN '' ELSE ' ('+ p.keywordvarchar255 + ')' END)
		FROM [dbo].[T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid 
		/* and (p.[ProductMatch_AI] = 1 OR p.[ProductMatch_TN] = 1) */
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS ProductKeyword_Any

	/* TAG */
				 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.tagcategory
		FROM [dbo].[T_TheCompany_KWS_2_CNT_Tag_ContractID] p 
		where  p.CONTRACTID = u.contractid 
		and P.keywordtype = 'TagCategory'
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS TagCategory_Match

		/*
				 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.tag
		FROM [dbo].[T_TheCompany_KWS_2_CNT_Tag_ContractID] p 
		where  p.CONTRACTID = u.contractid 
		and P.keywordtype = 'Tag'
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS Tag_Match */

				 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.FieldContent
		FROM [dbo].[V_TheCompany_KWS_1_CNT_MiscMetadataFields] p 
		where  p.CONTRACTID = u.contractid 
		and P.keywordtype = 'AgreementType'
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS AgreementType_Match

	FROM 
		T_TheCompany_KWS_6_CNT_ContractID_UNION  u /* product, company, description */
	group by 
		u.contractid


GO
/****** Object:  View [dbo].[V_TheCompany_VCompare_T2_0Raw]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_VCompare_T2_0Raw]

/* 
[dbo].[TheCompany_KeyWordSearch]
- elminiate double spaces
- ltrim, rtrim
*/
as

	select 
		* 
		, dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([Name2]) as Name2_LettersNumbersOnly
		, replace(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([Name2]),'  ',' ') 
			as Name2_LettersNumbersSpacesOnly /* e.g. Hansen & Rosenthal */
		, LEN(replace(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([Name2]),'  ',' '))
				-LEN(dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([Name2])) 
				as Name2_LettersNumbersOnly_NumSpacesWords
	from [dbo].[T_TheCompany_Compare_T2]
	/* where [KeyWordVarchar255] like 'Si%' */
	/* where dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([KeyWordVarchar255]) like '%  %' */

GO
/****** Object:  View [dbo].[V_TheCompany_VCompare_T2_1Final]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_VCompare_T2_1Final]
/* refreshed via TheCompany_Name2_Search */
as

	select 
		c.*
		, len([Name2]) as Name2_Length

		/*	, SUBSTRING(Name2_LettersNumbersSpacesOnly,1,(CHARINDEX(' ',Name2_LettersNumbersSpacesOnly + ' ')-1)) 
		as Name2_FirstWord */
			, Upper([dbo].[TheCompany_GetFirstWordInString](Name2_LettersNumbersSpacesOnly))
		as Name2_FirstWord

	/*		,SUBSTRING([Name2_LettersNumbersOnly],1,(CHARINDEX(' ',[Name2_LettersNumbersOnly] + ' ')-1))
		as Name2_FirstWord_LettersOnly */
			, Upper([dbo].[TheCompany_GetFirstWordInString]([Name2_LettersNumbersOnly]))
		as Name2_FirstWord_LettersOnly

			, LEN([dbo].[TheCompany_GetFirstWordInString]([Name2])) 
		as Name2_FirstWord_LEN

		/* two words or more */
		, Upper((CASE WHEN [Name2_LettersNumbersOnly_NumSpacesWords] = 1 
					THEN [Name2_LettersNumbersSpacesOnly] /* one space */
				WHEN Name2_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN SUBSTRING([Name2_LettersNumbersSpacesOnly],0,CHARINDEX(' ', [Name2_LettersNumbersSpacesOnly],
						CHARINDEX(' ', [Name2_LettersNumbersSpacesOnly],
									   CHARINDEX(' ', [Name2_LettersNumbersSpacesOnly],+1)+1)) )	/* e.g. SI Group */	
				ELSE NULL /* no space */ END)		)	
		as Name2_FirstTwoWords

		, (CASE WHEN [Name2_LettersNumbersOnly_NumSpacesWords] = 1 /* two words, one space */
					THEN [Name2_LettersNumbersOnly]
				WHEN Name2_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(SUBSTRING([Name2_LettersNumbersSpacesOnly],0,CHARINDEX(' ', [Name2_LettersNumbersSpacesOnly],
						CHARINDEX(' ', [Name2_LettersNumbersSpacesOnly],
									   CHARINDEX(' ', [Name2_LettersNumbersSpacesOnly],+1)+1)) ))	/* e.g. SI Group */	
				ELSE NULL /* no space */ END)			
		as Name2_FirstTwoWords_LettersOnly

			,  LEN((CASE WHEN [Name2_LettersNumbersOnly_NumSpacesWords] = 1 /* two words, one space */
					THEN [Name2_LettersNumbersOnly]
				WHEN Name2_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(SUBSTRING([Name2_LettersNumbersSpacesOnly],0,CHARINDEX(' ', [Name2_LettersNumbersSpacesOnly],
						CHARINDEX(' ', [Name2_LettersNumbersSpacesOnly],
									   CHARINDEX(' ', [Name2_LettersNumbersSpacesOnly],+1)+1)) ))	/* e.g. SI Group */	
				ELSE NULL /* no space */ END)	)	
		as Name2_FirstTwoWords_LettersOnly_LEN

		, (CASE WHEN LEN(dbo.TheCompany_GetFirstLetterOfEachWord([Name2_LettersNumbersSpacesOnly])) >=3 
			 THEN 
				/* dbo.TheCompany_GetFirstLetterOfEachWord([Name2_LettersNumbersOnly])
			WHEN LEN(dbo.TheCompany_GetFirstLetterOfEachWord([Name2_LettersNumbersOnly]))<3 
				and len(left([[Name2_LettersNumbersOnly],3)) >=3 THEN */
				left([Name2_LettersNumbersOnly],3)
			ELSE NULL END
			) 
			as Name2_FirstLetterOfEachWord

	from V_TheCompany_VCompare_T2_0Raw c

GO
/****** Object:  View [dbo].[V_TheCompany_VCompare_Results_5_NoMatches_Name2]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View [dbo].[V_TheCompany_VCompare_Results_5_NoMatches_Name2]

as 

	select 'Name2' as MatchLevel
		, '9None' as MatchKind
		,'' as  Name1
		, Name2
		, '' as [Name1_FirstWord]
		, [Name2_FirstWord]
		, '' as  [Name1_LettersNumbersSpacesOnly] 
		, [Name2_LettersNumbersSpacesOnly] 

	FROM
		[dbo].[V_TheCompany_VCompare_T2_1Final] 
	WHERE 
		[Name2] not in (select [Name2] from T_TheCompany_VCompare_Results_0Exact)
		and [Name2] not in (select [Name2] from T_TheCompany_VCompare_Results_1LikeFull)
		and [Name2] not in (select [Name2] from T_TheCompany_VCompare_Results_2FirstWord)
		and [Name2] not in (select [Name2] from T_TheCompany_VCompare_Results_3LikeLeft8)

GO
/****** Object:  View [dbo].[V_TheCompany_TTag_Summary_TagCategory]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE view [dbo].[V_TheCompany_TTag_Summary_TagCategory]

as

select 
	/* t.tagid 
	, t.tag */
	 DOCUMENTID
	 
	,  [TagCatID]
	, max(TagCategory) as TagCategory
	/*, td.tagid as custtagid */
	/*, td.keyword , f.FileType */
	/*	,CAST(rtrim( Replace(STUFF(
			(SELECT ', ' + s.Tag
			FROM V_TheCompany_TTag_Detail_TagID s
			WHERE s.DOCUMENTID =d.DOCUMENTID and s.[TagCategory] = d.[TagCategory]
			FOR XML PATH('')),1,1,''),'&#x0D' /* carriage return */,'')) as varchar(100))
		AS TagID_List*/
	, count(distinct TagID) as CountTagID
	/* , count(distinct TagCatID) as CountTagCatID	- is always 1 */
from [dbo].[V_TheCompany_TTag_Detail_TagID] d
/* where documentid = 102503 */
group by 
	DOCUMENTID,  [TagCatID]
/* left join vdocument f on t.OBJECTID = f.DOCUMENTID */
/* where TagCategory is not null - shoul dnot happen */

GO
/****** Object:  View [dbo].[V_TheCompany_VCONTRACT_DPTROLES_FLAT_TPC]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_VCONTRACT_DPTROLES_FLAT_TPC]

as


SELECT
Number as Dpt_ContractNumber
, CONTRACTID AS Dpt_contractid

/* All Roles */

,Replace(STUFF(
(SELECT ',' + s.ROLE_DEPARTMENT
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.contractid =d.contractid
AND s.ROLEID IN(1,19,20,34,23 /*Super User*/
	,2 /* Contract Owner*/
	,15,36 /* Contract Responsible*/ ) 
FOR XML PATH('')),1,1,''),'&amp;','&') AS Dpt_AllUserDpts

/* SUPER USER */

,
Replace((SELECT s.ROLE_DEPARTMENT
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.contractid =d.contractid AND s.ROLEID IN(1,19,20,34,23 /*Super User*/) 
),'&amp;','&') AS Dpt_SuperUserDpt

,(SELECT s.ROLE_DEPARTMENTID
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.contractid =d.contractid AND s.ROLEID IN(1,19,20,34,23 /*Super User*/)
) AS Dpt_SuperUserDpt_ID

,(SELECT s.ROLE_DEPARTMENT_CODE
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.contractid =d.contractid AND s.ROLEID IN(1,19,20,34,23 /*Super User*/)
) AS Dpt_SuperUserDpt_Code

/* CONTRACT OWNER */

,Replace(STUFF(
(SELECT ',' + s.ROLE_DEPARTMENT
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.CONTRACTID =d.CONTRACTID AND s.ROLEID = 2 /* Contract Owner*/
FOR XML PATH('')),1,1,''),'&amp;','&') AS Dpt_ContractOwner

,(SELECT top 1 ROLE_DEPARTMENTID
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.contractid =d.contractid AND s.ROLEID = 2 /* Contract Owner*/ 
)
AS Dpt_ContractOwnerDpt_ID

,Replace(STUFF(
(SELECT ',' + s.ROLE_DEPARTMENT_CODE
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.CONTRACTID =d.CONTRACTID AND s.ROLEID = 2 /* Contract Owner*/
FOR XML PATH('')),1,1,''),'&amp;','&') AS Dpt_ContractOwnerDpt_Code

/* old owner code
,
Replace((SELECT s.ROLE_DEPARTMENT
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.contractid =d.contractid AND s.ROLEID IN(2 /* Contract Owner*/) 
),'&amp;','&') AS Dpt_ContractOwner

,(SELECT s.ROLE_DEPARTMENTID
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.Number =d.Number AND s.ROLEID IN(2 /* Contract Owner*/)
) AS Dpt_ContractOwnerDpt_ID

,(SELECT s.ROLE_DEPARTMENT_CODE
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.Number =d.Number AND s.ROLEID IN(2 /* Contract Owner*/)
) AS Dpt_ContractOwnerDpt_Code
*/

/* CONTRACT RESPONSIBLE */

,Replace(STUFF(
(SELECT ',' + s.ROLE_DEPARTMENT
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.CONTRACTID =d.CONTRACTID AND s.ROLEID IN(15 /* Contract responsible */, 36 /* 36 = Contract Responsible - AMD */) 
FOR XML PATH('')),1,1,''),'&amp;','&') AS Dpt_ContractResponsible


,(SELECT top 1 ROLE_DEPARTMENTID
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.contractid =d.contractid AND s.ROLEID = 15 /* Contract responsible */
)
AS Dpt_ContractResponsibleDpt_ID


,Replace(STUFF(
(SELECT ',' + s.ROLE_DEPARTMENT_CODE
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.CONTRACTID =d.CONTRACTID AND s.ROLEID IN(15 /* Contract responsible */, 36 /* 36 = Contract Responsible - AMD */) 
FOR XML PATH('')),1,1,''),'&amp;','&') AS Dpt_ContractResponsibleDpt_Code

/* old role dpt created duplicate issue, can be bypassed with Select top 1
,
Replace((SELECT s.ROLE_DEPARTMENT
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.contractid =d.contractid AND s.ROLEID = 15 /* Contract responsible *//* 36 = Contract Responsible - AMD */
),'&amp;','&') AS Dpt_ContractResponsible

,(SELECT ROLE_DEPARTMENTID
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.contractid =d.contractid AND s.ROLEID = 15 /* Contract responsible *//* 36 = Contract Responsible - AMD */
)
AS Dpt_ContractResponsibleDpt_ID

,(SELECT TOP 1 ROLE_DEPARTMENT_CODE
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.contractid =d.contractid AND s.ROLEID = 15 /* Contract responsible *//* 36 = Contract Responsible - AMD */
)
AS Dpt_ContractResponsibleDpt_Code
*/ 

/* INTERNAL PARTNERS */

,Replace(STUFF(
(SELECT ',' + s.ROLE_DEPARTMENT
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.CONTRACTID =d.CONTRACTID AND s.ROLEID IN(0,6/*ENTITY*/,100 /*INTERNAL PARTNER*/) 
FOR XML PATH('')),1,1,''),'&amp;','&') AS InternalPartners

,CONVERT(nvarchar(255), STUFF(
(SELECT ',' + Convert(nvarchar(10),s.ROLE_DEPARTMENTID)
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.CONTRACTID =d.CONTRACTID AND s.ROLEID IN(0,6/*ENTITY*/,100 /*INTERNAL PARTNER*/) 
FOR XML PATH('')),1,1,'')) AS InternalPartners_IDs

,Replace(STUFF(
(SELECT DISTINCT ',' + SUBSTRING(s.ROLE_DEPARTMENT_CODE,2,2)
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.CONTRACTID =d.CONTRACTID AND s.ROLEID IN(0,6/*ENTITY*/,100 /*INTERNAL PARTNER*/) 
FOR XML PATH('')),1,1,''),'&amp;','&') AS InternalPartners_Countries

,(SELECT COUNT(s.ROLEID)
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.CONTRACTID =d.CONTRACTID AND s.ROLEID IN(0,6/*ENTITY*/,100 /*INTERNAL PARTNER*/)
GROUP BY s.number) 
AS InternalPartners_COUNT

/* TPC */
	,
	(SELECT s.ROLE_DEPARTMENT
	FROM VCONTRACT_DEPARTMENTROLES s
	WHERE s.CONTRACTID =d.CONTRACTID 
	AND s.ROLEID IN(0,6/*ENTITY*/,100 /*INTERNAL PARTNER*/)
	AND s.ROLE_DEPARTMENT_CODE =',JPT(TP-JP)#JP' 
	) AS IP_TPC

/* TCI */
	,(SELECT s.ROLE_DEPARTMENT
	FROM VCONTRACT_DEPARTMENTROLES s
	WHERE s.CONTRACTID =d.CONTRACTID 
	AND s.ROLEID IN(0,6/*ENTITY*/,100 /*INTERNAL PARTNER*/)
	AND s.ROLE_DEPARTMENT_CODE =',JPC#JP') AS IP_TCI

/* TPIZ */
	,Replace(STUFF(
	(SELECT ',' + s.ROLE_DEPARTMENT
	FROM VCONTRACT_DEPARTMENTROLES s
	WHERE s.CONTRACTID =d.CONTRACTID 
	AND s.ROLEID IN(0,6/*ENTITY*/,100 /*INTERNAL PARTNER*/) AND s.ROLE_DEPARTMENT_CODE not like ',JP%' 
	AND s.ROLE_DEPARTMENT_CODE LIKE ',CHI%'
	FOR XML PATH('')),1,1,''),'&amp;','&') AS IP_CHI

/* IP Other */
,Replace(STUFF(
(SELECT ',' + s.ROLE_DEPARTMENT
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.CONTRACTID =d.CONTRACTID 
AND s.ROLEID IN(0,6/*ENTITY*/,100 /*INTERNAL PARTNER*/) 
AND s.ROLE_DEPARTMENT_CODE not like ',JP%' 
AND s.ROLE_DEPARTMENT_CODE not like ',CHI%'
FOR XML PATH('')),1,1,''),'&amp;','&') AS IP_Other

/* TERRITORIES */

,Replace(STUFF(
(SELECT ',' + Convert(nvarchar(10),s.ROLE_DEPARTMENTID)
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.CONTRACTID =d.CONTRACTID AND s.ROLEID IN(3 /*TERRITORY*/) 
FOR XML PATH('')),1,1,''),'&amp;','&') AS Territories_IDs

,Replace(CONVERT(nvarchar(255), STUFF(
(SELECT ',' + s.ROLE_DEPARTMENT
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.CONTRACTID =d.CONTRACTID AND s.ROLEID IN(3 /*TERRITORY*/) 
FOR XML PATH('')),1,1,'')),'&amp;','&') AS Territories


,(SELECT COUNT(s.ROLEID)
FROM VCONTRACT_DEPARTMENTROLES s
WHERE s.CONTRACTID =d.CONTRACTID AND s.ROLEID IN(3 /*TERRITORY*/) 
GROUP BY s.number) AS Territories_COUNT


FROM VCONTRACT_DEPARTMENTROLES d
/* WHERE d.CONTRACTID not in(select CONTRACTID from tcontract where CONTRACTTYPEID  IN  ('6' /* Access SAKSNR number Series*/, '5' /* Test Old */,'102' /* Test New */,'13' /* DELETE */ )) */

GROUP BY 
Number
, CONTRACTID





GO
/****** Object:  View [dbo].[VACLOBJECTNAME]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VACLOBJECTNAME]
AS
SELECT     dbo.TACL.OBJECTTYPEID, dbo.TACL.OBJECTID, dbo.VOBJECTNAME.OBJECTNAME, dbo.VOBJECTNAME.OBJECTTYPE, 
                      dbo.VOBJECTNAME.OBJECTTYPEFIXED, dbo.TACL.GROUPID, dbo.TACL.USERID, dbo.TACL.PRIVILEGEID, dbo.TPRIVILEGE.PRIVILEGE, 
                      dbo.TACL.ACLID, dbo.VUSER.DISPLAYNAME, dbo.VUSER.ISEXTERNALUSER, dbo.TUSERGROUP.USERGROUP, 
                      dbo.VUSER.USER_MIK_VALID AS USERMIKVALID, dbo.TUSERGROUP.FIXED AS USERGROUPFIXED, 
                      dbo.TUSERGROUP.MIK_VALID AS USERGROUPMIKVALID
FROM         dbo.TPRIVILEGE INNER JOIN
                      dbo.TACL ON dbo.TPRIVILEGE.PRIVILEGEID = dbo.TACL.PRIVILEGEID INNER JOIN
                      dbo.TUSERGROUP ON dbo.TACL.GROUPID = dbo.TUSERGROUP.USERGROUPID INNER JOIN
                      dbo.VOBJECTNAME ON dbo.TACL.OBJECTTYPEID = dbo.VOBJECTNAME.OBJECTTYPEID INNER JOIN
                      dbo.VUSER ON dbo.TACL.USERID = dbo.VUSER.USERID





GO
/****** Object:  View [dbo].[VASSESSMENT_BASE]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VASSESSMENT_BASE] 
AS
SELECT TOP (100) PERCENT 
	dbo.TASSESSMENT.ASSESSMENTID, 
	dbo.TASSESSMENT.COMMENTS, 
	dbo.TEVALUATIONTYPE.EVALUATIONTYPEID, 
	dbo.TEVALUATIONTYPE.EVALUATIONTYPE, 
	dbo.TEVALUATIONTYPE.FIXED AS EvaluationTypeFixed, 
	dbo.TASSESSMENT.USERID_OWNER AS OwnerUserId, 
	dbo.TASSESSMENT_TEMPLATE.ASSESSMENTTEMPLATEID AS TemplateId, 
	dbo.TCRITERION_TEMPLATE.DESCRIPTION AS Template, 
	dbo.TASSESSMENTTEMPLATETYPE.ASSESSMENTTEMPLATETYPEID AS TemplateTypeId, 
	dbo.TASSESSMENTTEMPLATETYPE.ASSESSMENTTEMPLATETYPE AS TemplateType, 
	dbo.TASSESSMENT.STATUSID, 
	dbo.TASSESSMENT.ASSESSMENTDATE, 
	dbo.TASSESSMENT.QUALIFIED AS PreQualified, 
	dbo.TASSESSMENT.EXPIRY_DATE AS ExpiryDate, 
	dbo.TASSESSMENTCRITERION.DESCRIPTION AS AssessmentName, 
	dbo.TASSESSMENTCRITERION.MAX_VALUE AS MaxScore, 
	dbo.TASSESSMENTCRITERION.MINSCORE,
	dbo.TCRITERIONTYPE.CRITERIONTYPEID,  
	dbo.TCRITERIONTYPE.CRITERIONTYPE, 
	dbo.TCOMPANY.COMPANY, 
	dbo.TASSESSMENTSCORE.SCORE, 
	dbo.TCONTRACT.CONTRACT, 
	dbo.TCRITERIONCLASS.CRITERIONCLASS, 
	dbo.TPERSON.DISPLAYNAME, 
	dbo.TTENDERER.TENDERERID, 
	dbo.TCONTRACT.CONTRACTID, 
	dbo.TCOMPANY.COMPANYID, 
	dbo.TPERSON.PERSONID, 
	dbo.TCONTRACT.CONTRACTNUMBER
FROM dbo.TASSESSMENTCRITERION 
INNER JOIN dbo.TASSESSMENTOBJECT 
INNER JOIN dbo.TASSESSMENT 
	ON dbo.TASSESSMENTOBJECT.ASSESSMENTID = dbo.TASSESSMENT.ASSESSMENTID 
	ON dbo.TASSESSMENTCRITERION.ASSESSMENTID = dbo.TASSESSMENT.ASSESSMENTID 
INNER JOIN dbo.TEVALUATIONTYPE ON dbo.TASSESSMENT.EVALUATIONTYPEID = dbo.TEVALUATIONTYPE.EVALUATIONTYPEID 
LEFT OUTER JOIN	dbo.TUSER 
INNER JOIN dbo.TEMPLOYEE ON dbo.TUSER.EMPLOYEEID = dbo.TEMPLOYEE.EMPLOYEEID 
INNER JOIN dbo.TPERSON 
	ON dbo.TEMPLOYEE.PERSONID = dbo.TPERSON.PERSONID 
	ON dbo.TASSESSMENT.USERID_OWNER = dbo.TUSER.USERID 
LEFT OUTER JOIN	dbo.TASSESSMENTTEMPLATETYPE 
INNER JOIN dbo.TCRITERION_TEMPLATE 
INNER JOIN dbo.TASSESSMENT_TEMPLATE 
	ON dbo.TCRITERION_TEMPLATE.ASSESSMENTTEMPLATEID = dbo.TASSESSMENT_TEMPLATE.ASSESSMENTTEMPLATEID 
	ON dbo.TASSESSMENTTEMPLATETYPE.ASSESSMENTTEMPLATETYPEID = dbo.TASSESSMENT_TEMPLATE.ASSESSMENTTEMPLATETYPEID 
	ON dbo.TASSESSMENT.ASSESSMENTTEMPLATEID = dbo.TASSESSMENT_TEMPLATE.ASSESSMENTTEMPLATEID 
LEFT OUTER JOIN	dbo.TCONTRACT 
INNER JOIN dbo.TTENDERER 
	ON dbo.TCONTRACT.CONTRACTID = dbo.TTENDERER.CONTRACTID 
	ON dbo.TASSESSMENTOBJECT.ASSESSEDOBJECTID = dbo.TTENDERER.TENDERERID 
		AND TASSESSMENTOBJECT.ASSESSEDOBJECTTYPEID = (SELECT TOP 1 OBJECTTYPEID FROM TOBJECTTYPE WHERE FIXED = 'TENDERER')
LEFT OUTER JOIN	dbo.TCOMPANY ON dbo.TTENDERER.COMPANYID = dbo.TCOMPANY.COMPANYID 
LEFT OUTER JOIN	dbo.TCRITERIONCLASS 
INNER JOIN dbo.TCRITERIONTYPE 
	ON dbo.TCRITERIONCLASS.CRITERIONCLASSID = dbo.TCRITERIONTYPE.CRITERIONCLASSID 
	ON dbo.TASSESSMENTCRITERION.CRITERIONTYPEID = dbo.TCRITERIONTYPE.CRITERIONTYPEID 
LEFT OUTER JOIN dbo.TASSESSMENTSCORE ON dbo.TASSESSMENTCRITERION.ASSESSMENTCRITERIONID = dbo.TASSESSMENTSCORE.ASSESSMENTCRITERIONID 
	AND dbo.TASSESSMENTOBJECT.ASSESSMENTOBJECTID = dbo.TASSESSMENTSCORE.ASSESSMENTOBJECTID
WHERE     
	(dbo.TASSESSMENTCRITERION.PARENTID IS NULL) 
	AND (dbo.TCRITERION_TEMPLATE.PARENTID IS NULL) 
	

GO
/****** Object:  View [dbo].[VASSESSMENT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VASSESSMENT] 
AS
SELECT TOP (100) PERCENT 
	A.ASSESSMENTID, 
	A.COMMENTS, 
	A.EVALUATIONTYPEID, 
	A.EVALUATIONTYPE, 
	A.EvaluationTypeFixed, 
	A.OwnerUserId, 
	A.TemplateId, 
	A.Template, 
	A.TemplateTypeId,
	A.TemplateType, 
	A.STATUSID, 
	A.ASSESSMENTDATE, 
	A.PreQualified, 
	A.ExpiryDate, 
	A.AssessmentName, 
	A.MaxScore, 
	A.MINSCORE, 
	A.CRITERIONTYPEID,
	A.CRITERIONTYPE, 
	A.COMPANY, 
	A.SCORE, 
	A.CONTRACT, 
	A.CRITERIONCLASS, 
	A.DISPLAYNAME, 
	A.TENDERERID, 
	A.CONTRACTID, 
	A.COMPANYID, 
	A.PERSONID, 
	A.CONTRACTNUMBER
FROM VASSESSMENT_BASE A
where A.EvaluationTypeFixed <> 'TENDER_PREQUALIFICATION' AND A.EvaluationTypeFixed NOT LIKE 'VM%'
ORDER BY 
	A.ASSESSMENTID

GO
/****** Object:  View [dbo].[V_TheCompany_Mig_2T_TheCompany_AllUp_UserInfoTable]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view

[dbo].[V_TheCompany_Mig_2T_TheCompany_AllUp_UserInfoTable]
as

select 
	[Number]
      /* ,[CONTRACTID] */
      ,[Title]
      /* ,[Title_InclTopSecret] */
      /*,[CONTRACTTYPE] 
      ,[CONTRACTTYPEID]*/
      ,[AGREEMENT_TYPE]
      /* ,[Agreement_Type_Top25Flag] */
      ,[REFERENCENUMBER]
      ,[CONTRACTDATE] as DateRegistered
      /*,[RegisteredDate_YYYY_MM]
      ,[RegisteredDateNumMthCat] */
      ,[AWARDDATE]
      ,[STARTDATE]
      ,[EXPIRYDATE]
      ,[REV_EXPIRYDATE]
      ,[FINAL_EXPIRYDATE]
      ,[REVIEWDATE]
      ,[RD_ReviewDate_Warning]
      /*,[CHECKEDOUTDATE]
       ,[DEFINEDENDDATE] */
      ,[STATUS]
      
      ,[NUMBEROFFILES]
      /*,[EXECUTORID]
      ,[OWNERID]
      ,[TECHCOORDINATORID]
      ,[STATUSID] 
      ,[StatusFixed]*/
      ,[REFERENCECONTRACTNUMBER]
      ,[COUNTERPARTYNUMBER]
      
      /* ,[AGREEMENT_TYPEID] 
      ,[AGREEMENT_FIXED]*/
      ,[CompanyList]
      /*,[CompanyIDList]
      ,[CompanyIDAwardedCount]
      ,[CompanyIDUnawardedCount]
      ,[CompanyIDCount]
      ,[HEADING]
      ,[US_Userid] 
      ,[US_DisplayName]*/
      ,[US_Email]
      /* ,[US_Firstname] */
      ,[US_PrimaryUserGroup]
      ,[US_USER_MIK_VALID]
      /* ,[US_DPT_CODE] */
      ,[US_DPT_NAME]
      /*,[UO_employeeid] 
      ,[UO_DisplayName] */
      ,[UO_Email]
      /* ,[UO_Firstname] */
      ,[UO_PrimaryUserGroup]
      ,[UO_USER_MIK_VALID]
      ,[UO_DPT_CODE]
      ,[UO_DPT_NAME]
      /*,[UR_employeeid]
      ,[UR_DisplayName]*/
      ,[UR_Email]
      /*,[UR_Firstname] */
      ,[UR_PrimaryUserGroup]
      ,[UR_USER_MIK_VALID]
      /* ,[UR_DPT_CODE] */
      ,[UR_DPT_NAME]
      /*,[Dpt_Name_US]
      ,[Dpt_ID_US]
      ,[Dpt_Code_US] */
      ,[InternalPartners]
      /*,[InternalPartners_IDs]
      ,[InternalPartners_COUNT] */
      ,[Territories]
      /*,[Territories_IDs] 
      ,[Territories_COUNT]
      ,[VP_ProductGroups]
      ,[VP_ProductGroups_IDs] 
      ,[VP_ProductGroups_COUNT]
      ,[VP_ActiveIngredients]
      ,[VP_TradeNames]
      ,[VP_DirectProcurement]
      ,[VP_IndirectProcurement]
      ,[LumpSum]
      ,[LumpSumCurrency]
      ,[Region]
      ,[DEPARTMENTID]
      ,[LEVEL]
      ,[L0]
      ,[L1]
      ,[L2]
      ,[L3]
      ,[L4]
      ,[L5]
      ,[L6]
      ,[L7]
      ,[DEPARTMENT]
      ,[DEPARTMENT_CONCAT]
      ,[DPT_LOWEST_ID_TO_SHOW]
      ,[DEPARTMENT_CODE]
      ,[DPT_CODE_2Digit_InternalPartner]
      ,[DPT_CODE_2Digit_TerritoryRegion]
      ,[DPT_CODE_2Digit]
      ,[DPT_CODE_FirstChar]
      ,[FieldCategory]
      ,[NodeType]
      ,[NodeRole]
      ,[NodeMajorFlag]
      ,[PARENTID] 
      ,[ContractRelations]
      ,[DateTableRefreshed]
      ,[LinkToContractURL]
      ,[Procurement_AgTypeFlag]
      ,[Procurement_RoleFlag] */
      , p.Proc_NetLabel
from dbo.T_TheCompany_ALL a 
inner join dbo.V_TheCompany_Mig_0ProcNetFlag p on a.Contractid = p.Contractid_Proc




GO
/****** Object:  View [dbo].[V_TheCompany_Mig_z0ProcNetFlag]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[V_TheCompany_Mig_z0ProcNetFlag]

as

select 
	contractid as Contractid_Proc
	, UO_DPT_CODE as UO_DPT_CODE_Proc /* contract owner department code is procurement */
	, substring(UO_DPT_CODE,0,5) as GPROCSubstring /* first 4 characters of department code */

	/* user role department is attributed to Ariba - GP/IT */
	, (CASE WHEN Procurement_RoleFlag in ('GP','IT')
		THEN 'Y' ELSE 'N' END) as Proc_RoleFlag /* Procurement user department role - yes or no */

	, (CASE WHEN Procurement_AgTypeFlag = 3 /* $DPT */ then 
			(case when Procurement_RoleFlag in ('GP','IT')
				THEN 'Ariba by Dpt' ELSE 'Legal by Dpt' 
				END)  
			ELSE 'No $DPT Flag' end) 
		as Proc_RoleDptName

		/* Numeric flag for AGREEMENT_FIXED field without taking IC into account */
		, [Procurement_AgTypeFlag] as Proc_AgFixedFlag		
		
		, Procurement_AgTypeFlag as Proc_AgTypeICFlag /* no longer needed, can delete but first needs removing in reports */

		/* Friendly labels for all numeric flags including intercompany */
		, (CASE 
				WHEN Procurement_AgTypeFlag = 9 /* already migrated to Ariba */ THEN 'ARIBA (Migrated)'
				WHEN Procurement_AgTypeFlag = 4 /* intercompany */ THEN 'Intercompany'
				WHEN Procurement_AgTypeFlag = 3 THEN '$DPT' 
					+ (CASE WHEN Procurement_RoleFlag >'' THEN  '-' + Procurement_RoleFlag ELSE '' END)
				WHEN Procurement_AgTypeFlag = 6 THEN 'GxP' /* Gxp in contract title */
				WHEN Procurement_AgTypeFlag IN(0,1,2,5) then t.[TargetSystem_AgType] /* Agreement type only */
				ELSE 'N/A' /* no flag */
			END) as Proc_AgTypeICLabel

		/* Friendly labels with Legal/Intercompany combined in one flag Legal/IC */
		, (CASE 
				WHEN Procurement_AgTypeFlag = 9 /* already migrated to Ariba */ THEN 'ARIBA (Migrated)'
				WHEN Procurement_AgTypeFlag IN (1,2,5,7,8) THEN t.[TargetSystem_AgType] /* $ARIBA */
				WHEN Procurement_AgTypeFlag IN(0 /* Legal */, 4 /* Intercompany' */) THEN 'Legal/IC'
			/*	WHEN Procurement_AgTypeFlag = 2 THEN '$SPLIT'
				WHEN Procurement_AgTypeFlag = 3 THEN  '$DPT'
				WHEN Procurement_AgTypeFlag = 7 THEN  '$LG_MM' /* matter management */
				WHEN Procurement_AgTypeFlag = 8 THEN  '$IP_LIC'/* IP/Licensing */ */
				ELSE 'N/A'
			END) as Proc_AgTypeLabel

		, (CASE 
			/* WHEN COUNTERPARTYNUMBER like '!ARIBA%' THEN 'OTHER' /* Ariba, already migrated */ */
			WHEN Procurement_AgTypeFlag IN (0 /* LEGAL */, 4 /*IC*/, 6 /*GxP*/) THEN 'LINC'
			WHEN Procurement_AgTypeFlag IN ( 1 /* ARIBA */, 2 /* SPLIT */
											, 3 /* dpt*/, 5 /*other*/,7 ,8, 9 /* already migrated */ ) THEN 'OTHER'
			ELSE 'OTHER'	
			END)
		AS  MigrateToSystem_LNCCategory

		, (CASE 
			/* Prioritized */	
			WHEN Procurement_AgTypeFlag  = 9 /* already migrated */  THEN 'ARIBA'
			WHEN Procurement_AgTypeFlag = 1 THEN 'ARIBA' 

			WHEN Procurement_AgTypeFlag = 4 /* Intercompany*/ THEN 'LINC'
			/* WHEN TargetSystem_AgTypeFLAG = 0 /* LEGAL */ THEN 'LINC' */
			WHEN Procurement_AgTypeFlag  = 6 /* Gxp is also LEGAL, manually review */ THEN 'LINC'			
			WHEN Procurement_AgTypeFlag in ( 
					0 /* LEGAL */					
					) THEN 'LINC'

			
			WHEN Procurement_AgTypeFlag IN (2 /* split */, 3 /* dpt */, 5 /*other*/) THEN 'TBD' /* no HCX flag */
			WHEN Procurement_AgTypeFlag = 7 THEN 'iManage' /* matter management */
			WHEN Procurement_AgTypeFlag = 8 THEN 'IP/TM' /* IP/Licensing */		
			ELSE 'TBD'	
			END)
		AS  MigrateToSystem

		, (CASE	
			/* Prioritized */
			WHEN Procurement_AgTypeFlag  = 9 /* already migrated */  THEN 'ARIBA (already migrated)'
			WHEN Procurement_AgTypeFlag  = 4 /* Intercompany*/  THEN 'LINC (Intercompany)'
			WHEN Procurement_AgTypeFlag  = 6 /* Gxp is also LEGAL, manually review */ THEN 'LINC (GxP)'
			/* WHEN AgrType_IsHCX_Flag = 1 /* HCP/HCO */ THEN 'ARIBA (HCX)' */
			WHEN Procurement_AgTypeFlag = 0 /* LEGAL */ THEN 'LINC (Legal)' 	
			WHEN Procurement_AgTypeFlag = 1 /* ARIBA */ THEN 'ARIBA (HCX)'
			 	
			WHEN Procurement_AgTypeFlag = 2 /* Split */ THEN 'TBD' /* no HCX flag yet */
			WHEN Procurement_AgTypeFlag= 5 /* OTHER */ THEN 'TBD'/* 5 = other */ 
			WHEN Procurement_AgTypeFlag = 3 /* department */ THEN 'TBD' /* no HCX flag yet */

			WHEN Procurement_AgTypeFlag = 7 THEN 'iManage' /* matter management */
			WHEN Procurement_AgTypeFlag = 8 THEN 'IP/TM' /* IP/Licensing */		

			ELSE 'TBD'	
			END) + (case when [ConfidentialityFlag] = 'TOP SECRET' THEN ' - TOP SECRET?' else '' end)
		AS  MigrateToSystem_Detail

/* master flag showing if contract is Ariba or Legal */	
	, (CASE WHEN Procurement_AgTypeFlag = 1 /* Ariba agreement type, excl. intercompany and GxP */ 
				OR (Procurement_AgTypeFlag = 3 /* $DPT split */  
					AND Procurement_RoleFlag in ('GP','IT'))  /* $DPT department split flag AND any user role is procurement*/ 
				THEN 1 /* Ariba */ ELSE 0 /* Legal */ END)  				
		as  Proc_NetFlag

/* master flag LABEL showing if contract is Ariba or Legal */		
	, (CASE WHEN Procurement_AgTypeFlag = 1 /* Ariba agreement type */ 
				OR (Procurement_AgTypeFlag = 3 /* $Dpt split */
					AND Procurement_RoleFlag in ('GP','IT')) /* $DPT department split flag AND any user role is procurement*/ 
				THEN 'ARIBA' ELSE 'LEGAL' END)  				
		as  Proc_NetLabel
		
/*	if agreement type has department split, suffix it with ' - Procurement' in the field AGREEMENT_TYPE_WithProcurement */
			
	, (CASE WHEN Procurement_AgTypeFlag = 2 /* $DPT */
		THEN AGREEMENT_TYPE + 
			(case when Procurement_RoleFlag in ('GP','IT')
			THEN ' - Procurement' ELSE '' END) 
		ELSE AGREEMENT_TYPE END) as AGREEMENT_TYPE_WithProcurement
	
/* a procurement related product group was selected or applies according to the contract title */			
	, (CASE WHEN VP_IndirectProcurement>'' then 
			'Y'
			ELSE 'N' end) as Proc_HasProcProdGroupFlag
	, t.TargetSystem_AgType
	, t.TargetSystem_AgTypeFLAG
		, t.TargetSystem_AgType
	AS TargetSystem_MigrateTo

FROM T_TheCompany_ALL a
	left join [V_TheCompany_AgreementType] t on a.AGREEMENT_TYPEID = t.AgrTypeID

	/* must not filter with WHERE, used in V_TheCompany_ALL */
/* WHERE
	CONTRACTTYPEID not in (11 /* Legal matter / Case */
						, 13 /* Test old */
						, 106 /* Test new*/) 
	AND NUMBER not like 'Xt%' /* divested products or sites */ */


GO
/****** Object:  View [dbo].[VCONTRACT_SUMEXPENDITURE]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACT_SUMEXPENDITURE]
AS
SELECT     dbo.TAMOUNT.Amount AS SUMEXPENDITURE, dbo.TAMOUNT.ExchangeDate AS SUMEXPENDITURE_EXDATE, 
                      dbo.TAMOUNT.CurrencyId AS SUMEXPENDITURE_CURRID, dbo.TCURRENCY.CURRENCY_CODE AS SUMEXPENDITURE_CURRCODE, 
                      dbo.TCURRENCY.CURRENCY_SYMBOL AS SUMEXPENDITURE_CURRSYM, dbo.TCONTRACT.SumExpenditureAmountID
FROM         dbo.TAMOUNT INNER JOIN
                      dbo.TCURRENCY ON dbo.TAMOUNT.CurrencyId = dbo.TCURRENCY.CURRENCYID INNER JOIN
                      dbo.TCONTRACT ON dbo.TAMOUNT.AmountId = dbo.TCONTRACT.SumExpenditureAmountID



GO
/****** Object:  View [dbo].[VCONTRACT_TRANSPORTATION]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACT_TRANSPORTATION]
AS
SELECT     dbo.TAMOUNT.Amount AS TRANSPORTATION, dbo.TAMOUNT.ExchangeDate AS TRANSPORTATION_EXDATE, 
                      dbo.TAMOUNT.CurrencyId AS TRANSPORTATION_CURRID, dbo.TCURRENCY.CURRENCY_CODE AS TRANSPORTATION_CURRCODE, 
                      dbo.TCURRENCY.CURRENCY_SYMBOL AS TRANSPORTATION_CURRSYM, dbo.TCONTRACT.TransportationAmountID
FROM         dbo.TAMOUNT INNER JOIN
                      dbo.TCURRENCY ON dbo.TAMOUNT.CurrencyId = dbo.TCURRENCY.CURRENCYID INNER JOIN
                      dbo.TCONTRACT ON dbo.TAMOUNT.AmountId = dbo.TCONTRACT.TransportationAmountID



GO
/****** Object:  View [dbo].[VCONTRACT_TREND]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACT_TREND]
AS
SELECT     dbo.TAMOUNT.Amount AS TREND, dbo.TAMOUNT.ExchangeDate AS TREND_EXDATE, dbo.TAMOUNT.CurrencyId AS TREND_CURRID, 
                      dbo.TCURRENCY.CURRENCY_CODE AS TREND_CURRCODE, dbo.TCURRENCY.CURRENCY_SYMBOL AS TREND_CURRSYM, 
                      dbo.TCONTRACT.TrendAmountID
FROM         dbo.TAMOUNT INNER JOIN
                      dbo.TCURRENCY ON dbo.TAMOUNT.CurrencyId = dbo.TCURRENCY.CURRENCYID INNER JOIN
                      dbo.TCONTRACT ON dbo.TAMOUNT.AmountId = dbo.TCONTRACT.TrendAmountID



GO
/****** Object:  View [dbo].[VCONTRACT_APPROVEDVALUE]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACT_APPROVEDVALUE]
AS
SELECT     dbo.TAMOUNT.Amount AS APPROVEDVALUE, dbo.TAMOUNT.ExchangeDate AS APPROVEDVALUE_EXDATE, 
                      dbo.TAMOUNT.CurrencyId AS APPROVEDVALUE_CURRID, dbo.TCURRENCY.CURRENCY_CODE AS APPROVEDVALUE_CURRCODE, 
                      dbo.TCURRENCY.CURRENCY_SYMBOL AS APPROVEDVALUE_CURRSYM, dbo.TCONTRACT.ApprovedValueAmountID
FROM         dbo.TAMOUNT INNER JOIN
                      dbo.TCURRENCY ON dbo.TAMOUNT.CurrencyId = dbo.TCURRENCY.CURRENCYID INNER JOIN
                      dbo.TCONTRACT ON dbo.TAMOUNT.AmountId = dbo.TCONTRACT.ApprovedValueAmountID



GO
/****** Object:  View [dbo].[VCONTRACT_AWARDVALUE]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACT_AWARDVALUE]
AS
SELECT     dbo.TAMOUNT.Amount AS AWARDVALUE, dbo.TAMOUNT.ExchangeDate AS AWARDVALUE_EXDATE, 
                      dbo.TAMOUNT.CurrencyId AS AWARDVALUE_CURRID, dbo.TCURRENCY.CURRENCY_CODE AS AWARDVALUE_CURRCODE, 
                      dbo.TCURRENCY.CURRENCY_SYMBOL AS AWARDVALUE_CURRSYM, dbo.TCONTRACT.AwardValueAmountID
FROM         dbo.TAMOUNT INNER JOIN
                      dbo.TCURRENCY ON dbo.TAMOUNT.CurrencyId = dbo.TCURRENCY.CURRENCYID INNER JOIN
                      dbo.TCONTRACT ON dbo.TAMOUNT.AmountId = dbo.TCONTRACT.AwardValueAmountID



GO
/****** Object:  View [dbo].[VCONTRACT_BANKGUARANTEE]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACT_BANKGUARANTEE]
AS
SELECT     dbo.TAMOUNT.Amount AS BANKGUARANTEE, dbo.TAMOUNT.ExchangeDate AS BANKGUARANTEE_EXDATE, 
                      dbo.TAMOUNT.CurrencyId AS BANKGUARANTEE_CURRID, dbo.TCURRENCY.CURRENCY_CODE AS BANKGUARANTEE_CURRCODE, 
                      dbo.TCURRENCY.CURRENCY_SYMBOL AS BANKGUARANTEE_CURRSYM, dbo.TCONTRACT.BankGuaranteeAmountID
FROM         dbo.TAMOUNT INNER JOIN
                      dbo.TCURRENCY ON dbo.TAMOUNT.CurrencyId = dbo.TCURRENCY.CURRENCYID INNER JOIN
                      dbo.TCONTRACT ON dbo.TAMOUNT.AmountId = dbo.TCONTRACT.BankGuaranteeAmountID




GO
/****** Object:  View [dbo].[VCONTRACT_CONTINGENCY]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACT_CONTINGENCY]
AS
SELECT     dbo.TAMOUNT.Amount AS CONTINGENCY, dbo.TAMOUNT.ExchangeDate AS CONTINGENCY_EXDATE, 
                      dbo.TAMOUNT.CurrencyId AS CONTINGENCY_CURRID, dbo.TCURRENCY.CURRENCY_CODE AS CONTINGENCY_CURRCODE, 
                      dbo.TCURRENCY.CURRENCY_SYMBOL AS CONTINGENCY_CURRSYM, dbo.TCONTRACT.ContingencyAmountID
FROM         dbo.TAMOUNT INNER JOIN
                      dbo.TCURRENCY ON dbo.TAMOUNT.CurrencyId = dbo.TCURRENCY.CURRENCYID INNER JOIN
                      dbo.TCONTRACT ON dbo.TAMOUNT.AmountId = dbo.TCONTRACT.ContingencyAmountID



GO
/****** Object:  View [dbo].[VCONTRACT_ESCALATION]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACT_ESCALATION]
AS
SELECT     dbo.TAMOUNT.Amount AS ESCALATION, dbo.TAMOUNT.ExchangeDate AS ESCALATION_EXDATE, dbo.TAMOUNT.CurrencyId AS ESCALATION_CURRID, 
                      dbo.TCURRENCY.CURRENCY_CODE AS ESCALATION_CURRCODE, dbo.TCURRENCY.CURRENCY_SYMBOL AS ESCALATION_CURRSYM, 
                      dbo.TCONTRACT.EscalationAmountID
FROM         dbo.TAMOUNT INNER JOIN
                      dbo.TCURRENCY ON dbo.TAMOUNT.CurrencyId = dbo.TCURRENCY.CURRENCYID INNER JOIN
                      dbo.TCONTRACT ON dbo.TAMOUNT.AmountId = dbo.TCONTRACT.EscalationAmountID



GO
/****** Object:  View [dbo].[VCONTRACT_ESTIMATEDVALUE]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACT_ESTIMATEDVALUE]
AS
SELECT     dbo.TAMOUNT.Amount AS ESTIMATEDVALUE, dbo.TAMOUNT.ExchangeDate AS ESTIMATEDVALUE_EXDATE, 
                      dbo.TAMOUNT.CurrencyId AS ESTIMATEDVALUE_CURRID, dbo.TCURRENCY.CURRENCY_CODE AS ESTIMATEDVALUE_CURRCODE, 
                      dbo.TCURRENCY.CURRENCY_SYMBOL AS ESTIMATEDVALUE_CURRSYM, 
                      dbo.TCONTRACT.EstimatedValueAmountID AS ESTIMATEDVALUEAMOUNTID
FROM         dbo.TAMOUNT INNER JOIN
                      dbo.TCURRENCY ON dbo.TAMOUNT.CurrencyId = dbo.TCURRENCY.CURRENCYID INNER JOIN
                      dbo.TCONTRACT ON dbo.TAMOUNT.AmountId = dbo.TCONTRACT.EstimatedValueAmountID



GO
/****** Object:  View [dbo].[VCONTRACT_INSURANCE]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACT_INSURANCE]
AS
SELECT     dbo.TAMOUNT.Amount AS INSURANCE, dbo.TAMOUNT.ExchangeDate AS INSURANCE_EXDATE, dbo.TAMOUNT.CurrencyId AS INSURANCE_CURRID, 
                      dbo.TCURRENCY.CURRENCY_CODE AS INSURANCE_CURRCODE, dbo.TCURRENCY.CURRENCY_SYMBOL AS INSURANCE_CURRSYM, 
                      dbo.TCONTRACT.InsuranceAmountID
FROM         dbo.TAMOUNT INNER JOIN
                      dbo.TCURRENCY ON dbo.TAMOUNT.CurrencyId = dbo.TCURRENCY.CURRENCYID INNER JOIN
                      dbo.TCONTRACT ON dbo.TAMOUNT.AmountId = dbo.TCONTRACT.InsuranceAmountID



GO
/****** Object:  View [dbo].[VCONTRACT_INVOICEDVALUE]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACT_INVOICEDVALUE]
AS
SELECT     dbo.TAMOUNT.Amount AS INVOICEDVALUE, dbo.TAMOUNT.ExchangeDate AS INVOICEDVALUE_EXDATE, 
                      dbo.TAMOUNT.CurrencyId AS INVOICEDVALUE_CURRID, dbo.TCURRENCY.CURRENCY_CODE AS INVOICEDVALUE_CURRCODE, 
                      dbo.TCURRENCY.CURRENCY_SYMBOL AS INVOICEDVALUE_CURRSYM, dbo.TCONTRACT.InvoicedValueAmountID
FROM         dbo.TAMOUNT INNER JOIN
                      dbo.TCURRENCY ON dbo.TAMOUNT.CurrencyId = dbo.TCURRENCY.CURRENCYID INNER JOIN
                      dbo.TCONTRACT ON dbo.TAMOUNT.AmountId = dbo.TCONTRACT.InvoicedValueAmountID



GO
/****** Object:  View [dbo].[VCONTRACT_OTHEREXPENSES]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACT_OTHEREXPENSES]
AS
SELECT     dbo.TAMOUNT.Amount AS OTHEREXPENSES, dbo.TAMOUNT.ExchangeDate AS OTHEREXPENSES_EXDATE, 
                      dbo.TAMOUNT.CurrencyId AS OTHEREXPENSES_CURRID, dbo.TCURRENCY.CURRENCY_CODE AS OTHEREXPENSES_CURRCODE, 
                      dbo.TCURRENCY.CURRENCY_SYMBOL AS OTHEREXPENSES_CURRSYM, dbo.TCONTRACT.OtherExpensesAmountID
FROM         dbo.TAMOUNT INNER JOIN
                      dbo.TCURRENCY ON dbo.TAMOUNT.CurrencyId = dbo.TCURRENCY.CURRENCYID INNER JOIN
                      dbo.TCONTRACT ON dbo.TAMOUNT.AmountId = dbo.TCONTRACT.OtherExpensesAmountID



GO
/****** Object:  View [dbo].[VCONTRACT_PARENTCOMPANYGUARANTEE]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACT_PARENTCOMPANYGUARANTEE]
AS
SELECT     dbo.TAMOUNT.Amount AS PARENTCOMPANYGUARANTEE, dbo.TAMOUNT.ExchangeDate AS PARENTCOMPANYGUARANTEEE_EXDATE, 
                      dbo.TAMOUNT.CurrencyId AS PARENTCOMPANYGUARANTEE_CURRID, 
                      dbo.TCURRENCY.CURRENCY_CODE AS PARENTCOMPANYGUARANTEE_CURRCODE, 
                      dbo.TCURRENCY.CURRENCY_SYMBOL AS PARENTCOMPANYGUARANTEE_CURRSYM, dbo.TCONTRACT.ParentCompanyGuaranteeAmountID
FROM         dbo.TAMOUNT INNER JOIN
                      dbo.TCURRENCY ON dbo.TAMOUNT.CurrencyId = dbo.TCURRENCY.CURRENCYID INNER JOIN
                      dbo.TCONTRACT ON dbo.TAMOUNT.AmountId = dbo.TCONTRACT.ParentCompanyGuaranteeAmountID



GO
/****** Object:  View [dbo].[VCONTRACT_PROVISIONALSUM]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACT_PROVISIONALSUM]
AS
SELECT     dbo.TAMOUNT.Amount AS PROVISIONALSUM, dbo.TAMOUNT.ExchangeDate AS PROVISIONALSUM_EXDATE, 
                      dbo.TAMOUNT.CurrencyId AS PROVISIONALSUM_CURRID, dbo.TCURRENCY.CURRENCY_CODE AS PROVISIONALSUM_CURRCODE, 
                      dbo.TCURRENCY.CURRENCY_SYMBOL AS PROVISIONALSUM_CURRSYM, 
                      dbo.TCONTRACT.ProvisionalSumAmountID AS PROVISIONALSUMAMOUNTID
FROM         dbo.TAMOUNT INNER JOIN
                      dbo.TCURRENCY ON dbo.TAMOUNT.CurrencyId = dbo.TCURRENCY.CURRENCYID INNER JOIN
                      dbo.TCONTRACT ON dbo.TAMOUNT.AmountId = dbo.TCONTRACT.ProvisionalSumAmountID



GO
/****** Object:  View [dbo].[VCONTRACT_ECONOMY]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACT_ECONOMY]
AS
SELECT     dbo.TCONTRACT.CONTRACTID, dbo.VCONTRACT_ESTIMATEDVALUE.ESTIMATEDVALUE, 
                      dbo.VCONTRACT_ESTIMATEDVALUE.ESTIMATEDVALUE_CURRCODE, dbo.TCONTRACT.CURRENCYID AS CONTRACT_CURRENCYID, 
                      dbo.VCONTRACT_LUMPSUM.LUMPSUM, dbo.VCONTRACT_LUMPSUM.LUMPSUM_CURRCODE, 
                      dbo.VCONTRACT_PROVISIONALSUM.PROVISIONALSUM, dbo.VCONTRACT_PROVISIONALSUM.PROVISIONALSUM_CURRCODE, 
                      dbo.VCONTRACT_AWARDVALUE.AWARDVALUE, dbo.VCONTRACT_AWARDVALUE.AWARDVALUE_CURRCODE, 
                      dbo.VCONTRACT_ESCALATION.ESCALATION, dbo.VCONTRACT_ESCALATION.ESCALATION_CURRCODE, 
                      dbo.VCONTRACT_SUMEXPENDITURE.SUMEXPENDITURE, dbo.VCONTRACT_SUMEXPENDITURE.SUMEXPENDITURE_CURRCODE, 
                      dbo.VCONTRACT_CONTINGENCY.CONTINGENCY, dbo.VCONTRACT_CONTINGENCY.CONTINGENCY_CURRCODE, 
                      dbo.VCONTRACT_APPROVEDVALUE.APPROVEDVALUE, dbo.VCONTRACT_APPROVEDVALUE.APPROVEDVALUE_CURRCODE, 
                      dbo.VCONTRACT_INVOICEDVALUE.INVOICEDVALUE, dbo.VCONTRACT_INVOICEDVALUE.INVOICEDVALUE_CURRCODE, 
                      dbo.VCONTRACT_BANKGUARANTEE.BANKGUARANTEE, dbo.VCONTRACT_BANKGUARANTEE.BANKGUARANTEE_CURRCODE, 
                      dbo.VCONTRACT_PARENTCOMPANYGUARANTEE.PARENTCOMPANYGUARANTEE, 
                      dbo.VCONTRACT_PARENTCOMPANYGUARANTEE.PARENTCOMPANYGUARANTEE_CURRCODE, dbo.VCONTRACT_TREND.TREND, 
                      dbo.VCONTRACT_TREND.TREND_CURRCODE, dbo.VCONTRACT_TRANSPORTATION.TRANSPORTATION, 
                      dbo.VCONTRACT_TRANSPORTATION.TRANSPORTATION_CURRCODE, dbo.VCONTRACT_INSURANCE.INSURANCE, 
                      dbo.VCONTRACT_INSURANCE.INSURANCE_CURRCODE, dbo.VCONTRACT_OTHEREXPENSES.OTHEREXPENSES, 
                      dbo.VCONTRACT_OTHEREXPENSES.OTHEREXPENSES_CURRCODE
FROM         dbo.TCONTRACT LEFT OUTER JOIN
                      dbo.VCONTRACT_OTHEREXPENSES ON 
                      dbo.TCONTRACT.OtherExpensesAmountID = dbo.VCONTRACT_OTHEREXPENSES.OtherExpensesAmountID LEFT OUTER JOIN
                      dbo.VCONTRACT_INSURANCE ON dbo.TCONTRACT.InsuranceAmountID = dbo.VCONTRACT_INSURANCE.InsuranceAmountID LEFT OUTER JOIN
                      dbo.VCONTRACT_TRANSPORTATION ON 
                      dbo.TCONTRACT.TransportationAmountID = dbo.VCONTRACT_TRANSPORTATION.TransportationAmountID LEFT OUTER JOIN
                      dbo.VCONTRACT_TREND ON dbo.TCONTRACT.TrendAmountID = dbo.VCONTRACT_TREND.TrendAmountID LEFT OUTER JOIN
                      dbo.VCONTRACT_PARENTCOMPANYGUARANTEE ON 
                      dbo.TCONTRACT.ParentCompanyGuaranteeAmountID = dbo.VCONTRACT_PARENTCOMPANYGUARANTEE.ParentCompanyGuaranteeAmountID LEFT OUTER
                       JOIN
                      dbo.VCONTRACT_BANKGUARANTEE ON 
                      dbo.TCONTRACT.BankGuaranteeAmountID = dbo.VCONTRACT_BANKGUARANTEE.BankGuaranteeAmountID LEFT OUTER JOIN
                      dbo.VCONTRACT_INVOICEDVALUE ON 
                      dbo.TCONTRACT.InvoicedValueAmountID = dbo.VCONTRACT_INVOICEDVALUE.InvoicedValueAmountID LEFT OUTER JOIN
                      dbo.VCONTRACT_APPROVEDVALUE ON 
                      dbo.TCONTRACT.ApprovedValueAmountID = dbo.VCONTRACT_APPROVEDVALUE.ApprovedValueAmountID LEFT OUTER JOIN
                      dbo.VCONTRACT_CONTINGENCY ON 
                      dbo.TCONTRACT.ContingencyAmountID = dbo.VCONTRACT_CONTINGENCY.ContingencyAmountID LEFT OUTER JOIN
                      dbo.VCONTRACT_SUMEXPENDITURE ON 
                      dbo.TCONTRACT.SumExpenditureAmountID = dbo.VCONTRACT_SUMEXPENDITURE.SumExpenditureAmountID LEFT OUTER JOIN
                      dbo.VCONTRACT_ESCALATION ON dbo.TCONTRACT.EscalationAmountID = dbo.VCONTRACT_ESCALATION.EscalationAmountID LEFT OUTER JOIN
                      dbo.VCONTRACT_PROVISIONALSUM ON 
                      dbo.TCONTRACT.ProvisionalSumAmountID = dbo.VCONTRACT_PROVISIONALSUM.PROVISIONALSUMAMOUNTID LEFT OUTER JOIN
                      dbo.VCONTRACT_AWARDVALUE ON dbo.TCONTRACT.AwardValueAmountID = dbo.VCONTRACT_AWARDVALUE.AwardValueAmountID LEFT OUTER JOIN
                      dbo.VCONTRACT_LUMPSUM ON dbo.TCONTRACT.LumpSumAmountID = dbo.VCONTRACT_LUMPSUM.LUMPSUMAMOUNTID LEFT OUTER JOIN
                      dbo.VCONTRACT_ESTIMATEDVALUE ON 
                      dbo.TCONTRACT.EstimatedValueAmountID = dbo.VCONTRACT_ESTIMATEDVALUE.ESTIMATEDVALUEAMOUNTID



GO
/****** Object:  View [dbo].[VWorkflowProcessActivity]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE	VIEW [dbo].[VWorkflowProcessActivity] AS
	SELECT	PA.WorkflowProcessID,
			PA.GraphNodeKey,
			PA.WorkflowProcessActivityID,
			PAL.WorkflowProcessActivityLineID,
			PAL.StatusID,
			S.Status,
			PAL.TimeStarted,
			ISNULL(PAL.ActualTimeFinished, PAL.TimeFinished)	AS ActualTimeFinished,
			PAL.UserInformation
	  FROM	dbo.[TWorkflowProcessActivity]	PA
	  JOIN	dbo.[TWorkflowProcessActivityLine]	PAL
		ON	PA.WorkflowProcessActivityID = PAL.WorkflowProcessActivityID
	  JOIN	dbo.TSTATUS	S
		ON	S.StatusID	= PAL.StatusID

GO
/****** Object:  View [dbo].[VWorkflowProcessCrossActivity]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VWorkflowProcessCrossActivity]
AS
	SELECT	WorkflowProcessID,
			[1]		AS GraphNodeKey1,
			[2]		AS GraphNodeKey2,
			[3]		AS GraphNodeKey3,
			[4]		AS GraphNodeKey4,
			[5]		AS GraphNodeKey5,
			[6]		AS GraphNodeKey6,
			[7]		AS GraphNodeKey7,
			[8]		AS GraphNodeKey8,
			[9]		AS GraphNodeKey9,
			[10]	AS GraphNodeKey10,
			[11]	AS GraphNodeKey11,
			[12]	AS GraphNodeKey12,
			[13]	AS GraphNodeKey13,
			[14]	AS GraphNodeKey14,
			[15]	AS GraphNodeKey15,
			[16]	AS GraphNodeKey16,
			[17]	AS GraphNodeKey17,
			[18]	AS GraphNodeKey18,
			[19]	AS GraphNodeKey19,
			[20]	AS GraphNodeKey20,
			[21]	AS GraphNodeKey21,
			[22]	AS GraphNodeKey22,
			[23]	AS GraphNodeKey23,
			[24]	AS GraphNodeKey24,
			[25]	AS GraphNodeKey25,
			[26]	AS GraphNodeKey26,
			[27]	AS GraphNodeKey27,
			[28]	AS GraphNodeKey28,	
			[29]	AS GraphNodeKey29,
			[30]   	AS GraphNodeKey30,
			[31]   	AS GraphNodeKey31,
			[32]   	AS GraphNodeKey32,
			[33]   	AS GraphNodeKey33,
			[34]   	AS GraphNodeKey34,
			[35]   	AS GraphNodeKey35
	  FROM  (
			SELECT	PA.WorkflowProcessID,
					PA.GraphNodeKey,
					ROW_NUMBER() OVER (
							PARTITION BY PA.WorkflowProcessID
							ORDER BY PA.GraphNodeKey
					)		AS Sequence
			  FROM	dbo.[TWorkflowProcessActivity]				PA
			)		WPA_Pivot_Src
	  PIVOT	(
				MIN(GraphNodeKey)
				FOR Sequence IN (
					[1], [2], [3], [4], [5], [6], [7], [8], [9], [10],
					[11], [12], [13], [14], [15], [16], [17], [18], [19], [20],
					[21], [22], [23], [24], [25],[26],[27],[28],[29],[30],[31],[32],[33],[34],[35]
				)
			) AS WPA_Pivot_Tbl

GO
/****** Object:  View [dbo].[VWorkflowProcessPlanActivity]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE	VIEW [dbo].[VWorkflowProcessPlanActivity] AS
	SELECT  PPA.WorkflowProcessPlanID,
			PPA.GraphNodeKey,
			PPA.WorkflowProcessPlanActivityID,
			PPAL.WorkflowProcessPlanActivityLine,
			PPAL.PlannedTimeStarted,
			PPAL.PlannedTimeFinished
	  FROM  dbo.TWorkflowProcessPlanActivity PPA
	  JOIN	dbo.TWorkflowProcessPlanActivityLine PPAL
		ON	PPAL.WorkflowProcessPlanActivityID	= PPA.WorkflowProcessPlanActivityID

GO
/****** Object:  View [dbo].[VWorkflowProcessPlanCrossActivity]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VWorkflowProcessPlanCrossActivity]
AS
SELECT	WorkflowProcessPlanID,
		WorkflowProcessPlan,
		WorkflowDefinitionID,
		PlannedTimeStarted,
		PlannedTimeFinished,
		Duration,
		ResponsibleUserID,
		OwnerUserID,
		ObjectID,
		ObjectTypeID,
		[1] AS WorkflowProcessPlanActivityId1, 
		[2] AS WorkflowProcessPlanActivityId2, 
		[3] AS WorkflowProcessPlanActivityId3, 
		[4] AS WorkflowProcessPlanActivityId4, 
		[5] AS WorkflowProcessPlanActivityId5, 
		[6] AS WorkflowProcessPlanActivityId6, 
		[7] AS WorkflowProcessPlanActivityId7, 
		[8] AS WorkflowProcessPlanActivityId8, 
		[9] AS WorkflowProcessPlanActivityId9, 
		[10] AS WorkflowProcessPlanActivityId10,
		[11] AS WorkflowProcessPlanActivityId11, 
		[12] AS WorkflowProcessPlanActivityId12, 
		[13] AS WorkflowProcessPlanActivityId13, 
		[14] AS WorkflowProcessPlanActivityId14, 
		[15] AS WorkflowProcessPlanActivityId15, 
		[16] AS WorkflowProcessPlanActivityId16, 
		[17] AS WorkflowProcessPlanActivityId17, 
		[18] AS WorkflowProcessPlanActivityId18, 
		[19] AS WorkflowProcessPlanActivityId19, 
		[20] AS WorkflowProcessPlanActivityId20,
		[21] AS WorkflowProcessPlanActivityId21, 
		[22] AS WorkflowProcessPlanActivityId22, 
		[23] AS WorkflowProcessPlanActivityId23, 
		[24] AS WorkflowProcessPlanActivityId24, 
		[25] AS WorkflowProcessPlanActivityId25,
		[26] AS WorkflowProcessPlanActivityId26,
		[27] AS WorkflowProcessPlanActivityId27,
		[28] AS WorkflowProcessPlanActivityId28,
		[29] AS WorkflowProcessPlanActivityId29,
		[30] AS WorkflowProcessPlanActivityId30,
		[31] AS WorkflowProcessPlanActivityId31,
		[32] AS WorkflowProcessPlanActivityId32,
	    [33] AS WorkflowProcessPlanActivityId33,
		[34] AS WorkflowProcessPlanActivityId34,
		[35] AS WorkflowProcessPlanActivityId35
  FROM	(
		SELECT	PP.WorkflowProcessPlanID,
				PP.WorkflowProcessPlan,
				PP.WorkflowDefinitionID,
				PP.PlannedTimeStarted,
				PP.PlannedTimeFinished,
				PP.Duration,
				PP.ResponsibleUserID,
				PP.OwnerUserID,
				PP.ObjectID,
				PP.ObjectTypeID,
				PPA.WorkflowProcessPlanActivityId,
				ROW_NUMBER() OVER (
						PARTITION BY PPA.WorkflowProcessPlanId 
						ORDER BY PPA.WorkflowProcessPlanActivityId
				)		AS Sequence
		  FROM	dbo.TWorkflowProcessPlan PP
		  LEFT
		  JOIN	dbo.TWorkflowProcessPlanActivity PPA
			ON  PPA.WorkflowProcessPlanID = PP.WorkflowProcessPlanID
		)		AS PivotSource
  PIVOT	(
			MIN(WorkflowProcessPlanActivityId)
			FOR Sequence IN (
				[1], [2], [3], [4], [5], [6], [7], [8], [9], [10],
				[11], [12], [13], [14], [15], [16], [17], [18], [19], [20],
				[21], [22], [23], [24], [25],[26],[27],[28],[29],[30],[31],[32],[33],[34],[35]
			)
		) AS PivotTable
GO
/****** Object:  View [dbo].[VContractProcessPlanActivity]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  View [dbo].[VContractProcessPlanActivity]    Script Date: 08/20/2009 13:42:11 ******/
CREATE VIEW [dbo].[VContractProcessPlanActivity] AS

SELECT		C.ContractId, 
			C.ContractNumber, 
			C.Contract,
			LTC.WorkflowProcessActivityLine	AS LastTaskCompleted,
			LTC.TimeFinished				AS LastTaskCompletedDate,
			LTC.UserInformation				AS LastTaskCompletedUserComment,
			C.LastTaskCompletedID,
			PPCA.WorkflowProcessPlanID,
			PPCA.WorkflowProcessPlan,
			P.WorkflowProcess,
			PPCA.PlannedTimeFinished	AS ProcessPlanPlannedTimeFinished,
			PPCA.ObjectTypeid,
			PPCA.ObjectId,
			PPA1.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine1,
			PPA1.PlannedTimeStarted	AS ActivityPlannedTimeStarted1,
			PPA1.PlannedTimeFinished
									AS ActivityPlannedTimeFinished1,
			PA1.WorkflowProcessActivityLineID
									AS ActivityLineID1,
			PA1.StatusID			AS ActivityLineStatusID1,
			PA1.Status				AS ActivityLineStatus1,
			PA1.TimeStarted			AS ActualTimeStarted1,
			PA1.ActualTimeFinished	AS ActualTimeFinished1,
			PA1.UserInformation		AS UserInformation1,

			PPA2.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine2,
			PPA2.PlannedTimeStarted	AS ActivityPlannedTimeStarted2,
			PPA2.PlannedTimeFinished
									AS ActivityPlannedTimeFinished2,
			PA2.WorkflowProcessActivityLineID
									AS ActivityLineID2,
			PA2.StatusID			AS ActivityLineStatusID2,
			PA2.Status				AS ActivityLineStatus2,
			PA2.TimeStarted			AS ActualTimeStarted2,
			PA2.ActualTimeFinished	AS ActualTimeFinished2,
			PA2.UserInformation		AS UserInformation2,
		

	PPA3.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine3,
			PPA3.PlannedTimeStarted	AS ActivityPlannedTimeStarted3,
			PPA3.PlannedTimeFinished
									AS ActivityPlannedTimeFinished3,
			PA3.WorkflowProcessActivityLineID
									AS ActivityLineID3,
			PA3.StatusID			AS ActivityLineStatusID3,
			PA3.Status				AS ActivityLineStatus3,
			PA3.TimeStarted			AS ActualTimeStarted3,
			PA3.ActualTimeFinished	AS ActualTimeFinished3,
			PA3.UserInformation		AS UserInformation3,
			PPA4.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine4,
			PPA4.PlannedTimeStarted	AS ActivityPlannedTimeStarted4,
			PPA4.PlannedTimeFinished
									AS ActivityPlannedTimeFinished4,
			PA4.WorkflowProcessActivityLineID
									AS ActivityLineID4,
			PA4.StatusID			AS ActivityLineStatusID4,
			PA4.Status				AS ActivityLineStatus4,
			PA4.TimeStarted			AS ActualTimeStarted4,
			PA4.ActualTimeFinished	AS ActualTimeFinished4,
			PA4.UserInformation		AS UserInformation4,
			PPA5.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine5,
			PPA5.PlannedTimeStarted	AS ActivityPlannedTimeStarted5,
			PPA5.PlannedTimeFinished
									AS ActivityPlannedTimeFinished5,
			PA5.WorkflowProcessActivityLineID
									AS ActivityLineID5,
			PA5.StatusID			AS ActivityLineStatusID5,
			PA5.Status				AS ActivityLineStatus5,
			PA5.TimeStarted			AS ActualTimeStarted5,
			PA5.ActualTimeFinished	AS ActualTimeFinished5,
			PA5.UserInformation		AS UserInformation5,
			PPA6.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine6,
			PPA6.PlannedTimeStarted	AS ActivityPlannedTimeStarted6,
			PPA6.PlannedTimeFinished
									AS ActivityPlannedTimeFinished6,
			PA6.WorkflowProcessActivityLineID
									AS ActivityLineID6,
			PA6.StatusID			AS ActivityLineStatusID6,
			PA6.Status				AS ActivityLineStatus6,
			PA6.TimeStarted			AS ActualTimeStarted6,
			PA6.ActualTimeFinished	AS ActualTimeFinished6,
			PA6.UserInformation		AS UserInformation6,
			PPA7.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine7,
			PPA7.PlannedTimeStarted	AS ActivityPlannedTimeStarted7,
			PPA7.PlannedTimeFinished
									AS ActivityPlannedTimeFinished7,
			PA7.WorkflowProcessActivityLineID
									AS ActivityLineID7,
			PA7.StatusID			AS ActivityLineStatusID7,
			PA7.Status				AS ActivityLineStatus7,
			PA7.TimeStarted			AS ActualTimeStarted7,
			PA7.ActualTimeFinished	AS ActualTimeFinished7,
			PA7.UserInformation		AS UserInformation7,
			PPA8.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine8,
			PPA8.PlannedTimeStarted	AS ActivityPlannedTimeStarted8,
			PPA8.PlannedTimeFinished
									AS ActivityPlannedTimeFinished8,
			PA8.WorkflowProcessActivityLineID
									AS ActivityLineID8,
			PA8.StatusID			AS ActivityLineStatusID8,
			PA8.Status				AS ActivityLineStatus8,
			PA8.TimeStarted			AS ActualTimeStarted8,
			PA8.ActualTimeFinished	AS ActualTimeFinished8,
			PA8.UserInformation		AS UserInformation8,
			PPA9.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine9,
			PPA9.PlannedTimeStarted	AS ActivityPlannedTimeStarted9,
			PPA9.PlannedTimeFinished
									AS ActivityPlannedTimeFinished9,
			PA9.WorkflowProcessActivityLineID
									AS ActivityLineID9,
			PA9.StatusID			AS ActivityLineStatusID9,
			PA9.Status				AS ActivityLineStatus9,
			PA9.TimeStarted			AS ActualTimeStarted9,
			PA9.ActualTimeFinished	AS ActualTimeFinished9,
			PA9.UserInformation		AS UserInformation9,
			PPA10.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine10,
			PPA10.PlannedTimeStarted
									AS ActivityPlannedTimeStarted10,
			PPA10.PlannedTimeFinished
									AS ActivityPlannedTimeFinished10,
			PA10.WorkflowProcessActivityLineID
									AS ActivityLineID10,
			PA10.StatusID			AS ActivityLineStatusID10,
			PA10.Status				AS ActivityLineStatus10,
			PA10.TimeStarted		AS ActualTimeStarted10,
			PA10.ActualTimeFinished	AS ActualTimeFinished10,
			PA10.UserInformation	AS UserInformation10,
			PPA11.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine11,
			PPA11.PlannedTimeStarted
									AS ActivityPlannedTimeStarted11,
			PPA11.PlannedTimeFinished
									AS ActivityPlannedTimeFinished11,
			PA11.WorkflowProcessActivityLineID
									AS ActivityLineID11,
			PA11.StatusID			AS ActivityLineStatusID11,
			PA11.Status				AS ActivityLineStatus11,
			PA11.TimeStarted		AS ActualTimeStarted11,
			PA11.ActualTimeFinished	AS ActualTimeFinished11,
			PA11.UserInformation	AS UserInformation11,
			PPA12.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine12,
			PPA12.PlannedTimeStarted
									AS ActivityPlannedTimeStarted12,
			PPA12.PlannedTimeFinished
									AS ActivityPlannedTimeFinished12,
			PA12.WorkflowProcessActivityLineID
									AS ActivityLineID12,
			PA12.StatusID			AS ActivityLineStatusID12,
			PA12.Status				AS ActivityLineStatus12,
			PA12.TimeStarted		AS ActualTimeStarted12,
			PA12.ActualTimeFinished	AS ActualTimeFinished12,
			PA12.UserInformation	AS UserInformation12,
			PPA13.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine13,
			PPA13.PlannedTimeStarted
									AS ActivityPlannedTimeStarted13,
			PPA13.PlannedTimeFinished
									AS ActivityPlannedTimeFinished13,
			PA13.WorkflowProcessActivityLineID
									AS ActivityLineID13,
			PA13.StatusID			AS ActivityLineStatusID13,
			PA13.Status				AS ActivityLineStatus13,
			PA13.TimeStarted		AS ActualTimeStarted13,
			PA13.ActualTimeFinished	AS ActualTimeFinished13,
			PA13.UserInformation	AS UserInformation13,
			PPA14.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine14,
			PPA14.PlannedTimeStarted
									AS ActivityPlannedTimeStarted14,
			PPA14.PlannedTimeFinished
									AS ActivityPlannedTimeFinished14,
			PA14.WorkflowProcessActivityLineID
									AS ActivityLineID14,
			PA14.StatusID			AS ActivityLineStatusID14,
			PA14.Status				AS ActivityLineStatus14,
			PA14.TimeStarted		AS ActualTimeStarted14,
			PA14.ActualTimeFinished	AS ActualTimeFinished14,
			PA14.UserInformation	AS UserInformation14,
			PPA15.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine15,
			PPA15.PlannedTimeStarted
									AS ActivityPlannedTimeStarted15,
			PPA15.PlannedTimeFinished
									AS ActivityPlannedTimeFinished15,
			PA15.WorkflowProcessActivityLineID
									AS ActivityLineID15,
			PA15.StatusID			AS ActivityLineStatusID15,
			PA15.Status				AS ActivityLineStatus15,
			PA15.TimeStarted		AS ActualTimeStarted15,
			PA15.ActualTimeFinished	AS ActualTimeFinished15,
			PA15.UserInformation	AS UserInformation15,
			PPA16.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine16,
			PPA16.PlannedTimeStarted
									AS ActivityPlannedTimeStarted16,
			PPA16.PlannedTimeFinished
									AS ActivityPlannedTimeFinished16,
			PA16.WorkflowProcessActivityLineID
									AS ActivityLineID16,
			PA16.StatusID			AS ActivityLineStatusID16,
			PA16.Status				AS ActivityLineStatus16,
			PA16.TimeStarted		AS ActualTimeStarted16,
			PA16.ActualTimeFinished	AS ActualTimeFinished16,
			PA16.UserInformation	AS UserInformation16,
			PPA17.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine17,
			PPA17.PlannedTimeStarted
									AS ActivityPlannedTimeStarted17,
			PPA17.PlannedTimeFinished
									AS ActivityPlannedTimeFinished17,
			PA17.WorkflowProcessActivityLineID
									AS ActivityLineID17,
			PA17.StatusID			AS ActivityLineStatusID17,
			PA17.Status				AS ActivityLineStatus17,
			PA17.TimeStarted		AS ActualTimeStarted17,
			PA17.ActualTimeFinished	AS ActualTimeFinished17,
			PA17.UserInformation	AS UserInformation17,
			PPA18.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine18,
			PPA18.PlannedTimeStarted
									AS ActivityPlannedTimeStarted18,
			PPA18.PlannedTimeFinished
									AS ActivityPlannedTimeFinished18,
			PA18.WorkflowProcessActivityLineID
									AS ActivityLineID18,
			PA18.StatusID			AS ActivityLineStatusID18,
			PA18.Status				AS ActivityLineStatus18,
			PA18.TimeStarted		AS ActualTimeStarted18,
			PA18.ActualTimeFinished	AS ActualTimeFinished18,
			PA18.UserInformation	AS UserInformation18,
			PPA19.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine19,
			PPA19.PlannedTimeStarted
									AS ActivityPlannedTimeStarted19,
			PPA19.PlannedTimeFinished
									AS ActivityPlannedTimeFinished19,
			PA19.WorkflowProcessActivityLineID
									AS ActivityLineID19,
			PA19.StatusID			AS ActivityLineStatusID19,
			PA19.Status				AS ActivityLineStatus19,
			PA19.TimeStarted		AS ActualTimeStarted19,
			PA19.ActualTimeFinished	AS ActualTimeFinished19,
			PA19.UserInformation	AS UserInformation19,
			PPA20.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine20,
			PPA20.PlannedTimeStarted
									AS ActivityPlannedTimeStarted20,
			PPA20.PlannedTimeFinished
									AS ActivityPlannedTimeFinished20,
			PA20.WorkflowProcessActivityLineID
									AS ActivityLineID20,
			PA20.StatusID			AS ActivityLineStatusID20,
			PA20.Status				AS ActivityLineStatus20,
			PA20.TimeStarted		AS ActualTimeStarted20,
			PA20.ActualTimeFinished	AS ActualTimeFinished20,
			PA20.UserInformation	AS UserInformation20,
			PPA21.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine21,
			PPA21.PlannedTimeStarted
									AS ActivityPlannedTimeStarted21,
			PPA21.PlannedTimeFinished
									AS ActivityPlannedTimeFinished21,
			PA21.WorkflowProcessActivityLineID
									AS ActivityLineID21,
			PA21.StatusID			AS ActivityLineStatusID21,
			PA21.Status				AS ActivityLineStatus21,
			PA21.TimeStarted		AS ActualTimeStarted21,
			PA21.ActualTimeFinished	AS ActualTimeFinished21,
			PA21.UserInformation	AS UserInformation21,
			PPA22.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine22,
			PPA22.PlannedTimeStarted
									AS ActivityPlannedTimeStarted22,
			PPA22.PlannedTimeFinished
									AS ActivityPlannedTimeFinished22,
			PA22.WorkflowProcessActivityLineID
									AS ActivityLineID22,
			PA22.StatusID			AS ActivityLineStatusID22,
			PA22.Status				AS ActivityLineStatus22,
			PA22.TimeStarted		AS ActualTimeStarted22,
			PA22.ActualTimeFinished	AS ActualTimeFinished22,
			PA22.UserInformation	AS UserInformation22,
			PPA23.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine23,
			PPA23.PlannedTimeStarted
									AS ActivityPlannedTimeStarted23,
			PPA23.PlannedTimeFinished
									AS ActivityPlannedTimeFinished23,
			PA23.WorkflowProcessActivityLineID
									AS ActivityLineID23,
			PA23.StatusID			AS ActivityLineStatusID23,
			PA23.Status				AS ActivityLineStatus23,
			PA23.TimeStarted		AS ActualTimeStarted23,
			PA23.ActualTimeFinished	AS ActualTimeFinished23,
			PA23.UserInformation	AS UserInformation23,
			PPA24.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine24,
			PPA24.PlannedTimeStarted
									AS ActivityPlannedTimeStarted24,
			PPA24.PlannedTimeFinished
									AS ActivityPlannedTimeFinished24,
			PA24.WorkflowProcessActivityLineID
									AS ActivityLineID24,
			PA24.StatusID			AS ActivityLineStatusID24,
			PA24.Status				AS ActivityLineStatus24,
			PA24.TimeStarted		AS ActualTimeStarted24,
			PA24.ActualTimeFinished	AS ActualTimeFinished24,
			PA24.UserInformation	AS UserInformation24,

			PPA25.WorkflowProcessPlanActivityLine
									AS WorkflowProcessPlanActivityLine25,
			PPA25.PlannedTimeStarted
									AS ActivityPlannedTimeStarted25,
			PPA25.PlannedTimeFinished
									AS ActivityPlannedTimeFinished25,
			PA25.WorkflowProcessActivityLineID
									AS ActivityLineID25,
			PA25.StatusID			AS ActivityLineStatusID25,
			PA25.Status				AS ActivityLineStatus25,
			PA25.TimeStarted		AS ActualTimeStarted25,
			PA25.ActualTimeFinished	AS ActualTimeFinished25,
			PA25.UserInformation	AS UserInformation25,

			/*------------------------Expand to 35 steps---------------------------------------------------*/

			PPA26.WorkflowProcessPlanActivityLine AS WorkflowProcessPlanActivityLine26,
			PPA26.PlannedTimeStarted			AS ActivityPlannedTimeStarted26,
			PPA26.PlannedTimeFinished  			AS ActivityPlannedTimeFinished26,
			PA26.WorkflowProcessActivityLineID 	AS ActivityLineID26,
			PA26.StatusID			AS ActivityLineStatusID26,
			PA26.Status				AS ActivityLineStatus26,
			PA26.TimeStarted		AS ActualTimeStarted26,
			PA26.ActualTimeFinished	AS ActualTimeFinished26,
			PA26.UserInformation	AS UserInformation26,
			
			PPA27.WorkflowProcessPlanActivityLine AS WorkflowProcessPlanActivityLine27,
			PPA27.PlannedTimeStarted			AS ActivityPlannedTimeStarted27,
			PPA27.PlannedTimeFinished  			AS ActivityPlannedTimeFinished27,
			PA27.WorkflowProcessActivityLineID 	AS ActivityLineID27,
			PA27.StatusID			AS ActivityLineStatusID27,
			PA27.Status				AS ActivityLineStatus27,
			PA27.TimeStarted		AS ActualTimeStarted27,
			PA27.ActualTimeFinished	AS ActualTimeFinished27,
			PA27.UserInformation	AS UserInformation27,

			PPA28.WorkflowProcessPlanActivityLine AS WorkflowProcessPlanActivityLine28,
			PPA28.PlannedTimeStarted			AS ActivityPlannedTimeStarted28,
			PPA28.PlannedTimeFinished  			AS ActivityPlannedTimeFinished28,
			PA28.WorkflowProcessActivityLineID 	AS ActivityLineID28,
			PA28.StatusID			AS ActivityLineStatusID28,
			PA28.Status				AS ActivityLineStatus28,
			PA28.TimeStarted		AS ActualTimeStarted28,
			PA28.ActualTimeFinished	AS ActualTimeFinished28,
			PA28.UserInformation	AS UserInformation28,
			
			PPA29.WorkflowProcessPlanActivityLine AS WorkflowProcessPlanActivityLine29,
			PPA29.PlannedTimeStarted			AS ActivityPlannedTimeStarted29,
			PPA29.PlannedTimeFinished  			AS ActivityPlannedTimeFinished29,
			PA29.WorkflowProcessActivityLineID 	AS ActivityLineID29,
			PA29.StatusID			AS ActivityLineStatusID29,
			PA29.Status				AS ActivityLineStatus29,
			PA29.TimeStarted		AS ActualTimeStarted29,
			PA29.ActualTimeFinished	AS ActualTimeFinished29,
			PA29.UserInformation	AS UserInformation29,

			PPA30.WorkflowProcessPlanActivityLine AS WorkflowProcessPlanActivityLine30,
			PPA30.PlannedTimeStarted			AS ActivityPlannedTimeStarted30,
			PPA30.PlannedTimeFinished  			AS ActivityPlannedTimeFinished30,
			PA30.WorkflowProcessActivityLineID 	AS ActivityLineID30,
			PA30.StatusID			AS ActivityLineStatusID30,
			PA30.Status				AS ActivityLineStatus30,
			PA30.TimeStarted		AS ActualTimeStarted30,
			PA30.ActualTimeFinished	AS ActualTimeFinished30,
			PA30.UserInformation	AS UserInformation30,
			
			PPA31.WorkflowProcessPlanActivityLine AS WorkflowProcessPlanActivityLine31,
			PPA31.PlannedTimeStarted			AS ActivityPlannedTimeStarted31,
			PPA31.PlannedTimeFinished  			AS ActivityPlannedTimeFinished31,
			PA31.WorkflowProcessActivityLineID 	AS ActivityLineID31,
			PA31.StatusID			AS ActivityLineStatusID31,
			PA31.Status				AS ActivityLineStatus31,
			PA31.TimeStarted		AS ActualTimeStarted31,
			PA31.ActualTimeFinished	AS ActualTimeFinished31,
			PA31.UserInformation	AS UserInformation31,

			PPA32.WorkflowProcessPlanActivityLine AS WorkflowProcessPlanActivityLine32,
			PPA32.PlannedTimeStarted			AS ActivityPlannedTimeStarted32,
			PPA32.PlannedTimeFinished  			AS ActivityPlannedTimeFinished32,
			PA32.WorkflowProcessActivityLineID 	AS ActivityLineID32,
			PA32.StatusID			AS ActivityLineStatusID32,
			PA32.Status				AS ActivityLineStatus32,
			PA32.TimeStarted		AS ActualTimeStarted32,
			PA32.ActualTimeFinished	AS ActualTimeFinished32,
			PA32.UserInformation	AS UserInformation32,

			PPA33.WorkflowProcessPlanActivityLine AS WorkflowProcessPlanActivityLine33,
			PPA33.PlannedTimeStarted			AS ActivityPlannedTimeStarted33,
			PPA33.PlannedTimeFinished  			AS ActivityPlannedTimeFinished33,
			PA33.WorkflowProcessActivityLineID 	AS ActivityLineID33,
			PA33.StatusID			AS ActivityLineStatusID33,
			PA33.Status				AS ActivityLineStatus33,
			PA33.TimeStarted		AS ActualTimeStarted33,
			PA33.ActualTimeFinished	AS ActualTimeFinished33,
			PA33.UserInformation	AS UserInformation33,
	
			PPA34.WorkflowProcessPlanActivityLine AS WorkflowProcessPlanActivityLine34,
			PPA34.PlannedTimeStarted			AS ActivityPlannedTimeStarted34,
			PPA34.PlannedTimeFinished  			AS ActivityPlannedTimeFinished34,
			PA34.WorkflowProcessActivityLineID 	AS ActivityLineID34,
			PA34.StatusID			AS ActivityLineStatusID34,
			PA34.Status				AS ActivityLineStatus34,
			PA34.TimeStarted		AS ActualTimeStarted34,
			PA34.ActualTimeFinished	AS ActualTimeFinished34,
			PA34.UserInformation	AS UserInformation34,

			PPA35.WorkflowProcessPlanActivityLine AS WorkflowProcessPlanActivityLine35,
			PPA35.PlannedTimeStarted			AS ActivityPlannedTimeStarted35,
			PPA35.PlannedTimeFinished  			AS ActivityPlannedTimeFinished35,
			PA35.WorkflowProcessActivityLineID 	AS ActivityLineID35,
			PA35.StatusID			AS ActivityLineStatusID35,
			PA35.Status				AS ActivityLineStatus35,
			PA35.TimeStarted		AS ActualTimeStarted35,
			PA35.ActualTimeFinished	AS ActualTimeFinished35,
			PA35.UserInformation	AS UserInformation35

  FROM	TCONTRACT C
  LEFT
  JOIN	dbo.[TWorkflowProcessActivityLine]	LTC -- Last task completed
	ON	LTC.WorkflowProcessActivityLineID					= C.LastTaskCompletedID
  LEFT	
  JOIN	VWorkflowProcessPlanCrossActivity					PPCA
	ON	PPCA.OBJECTID										= C.CONTRACTID
   AND	PPCA.OBJECTTYPEID									= (
		SELECT	ObjectTypeID
		  FROM	TObjectType
		 WHERE	FIXED			= 'CONTRACT'
		)
  LEFT
  JOIN	dbo.[TWorkflowProcess]				P
	ON	P.WorkflowProcessPlanID								= PPCA.WorkflowProcessPlanID
  LEFT
  JOIN	VWorkflowProcessCrossActivity						PCA
	ON	PCA.WorkflowProcessID								= P.WorkflowProcessID
LEFT JOIN VWorkflowProcessPlanActivity PPA1 ON PPA1.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId1
LEFT JOIN VWorkflowProcessPlanActivity PPA2 ON PPA2.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId2
LEFT JOIN VWorkflowProcessPlanActivity PPA3 ON PPA3.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId3
LEFT JOIN VWorkflowProcessPlanActivity PPA4 ON PPA4.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId4
LEFT JOIN VWorkflowProcessPlanActivity PPA5 ON PPA5.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId5
LEFT JOIN VWorkflowProcessPlanActivity PPA6 ON PPA6.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId6
LEFT JOIN VWorkflowProcessPlanActivity PPA7 ON PPA7.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId7
LEFT JOIN VWorkflowProcessPlanActivity PPA8 ON PPA8.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId8
LEFT JOIN VWorkflowProcessPlanActivity PPA9 ON PPA9.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId9
LEFT JOIN VWorkflowProcessPlanActivity PPA10 ON PPA10.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId10
LEFT JOIN VWorkflowProcessPlanActivity PPA11 ON PPA11.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId11
LEFT JOIN VWorkflowProcessPlanActivity PPA12 ON PPA12.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId12
LEFT JOIN VWorkflowProcessPlanActivity PPA13 ON PPA13.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId13
LEFT JOIN VWorkflowProcessPlanActivity PPA14 ON PPA14.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId14
LEFT JOIN VWorkflowProcessPlanActivity PPA15 ON PPA15.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId15
LEFT JOIN VWorkflowProcessPlanActivity PPA16 ON PPA16.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId16
LEFT JOIN VWorkflowProcessPlanActivity PPA17 ON PPA17.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId17
LEFT JOIN VWorkflowProcessPlanActivity PPA18 ON PPA18.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId18
LEFT JOIN VWorkflowProcessPlanActivity PPA19 ON PPA19.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId19
LEFT JOIN VWorkflowProcessPlanActivity PPA20 ON PPA20.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId20
LEFT JOIN VWorkflowProcessPlanActivity PPA21 ON PPA21.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId21
LEFT JOIN VWorkflowProcessPlanActivity PPA22 ON PPA22.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId22
LEFT JOIN VWorkflowProcessPlanActivity PPA23 ON PPA23.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId23
LEFT JOIN VWorkflowProcessPlanActivity PPA24 ON PPA24.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId24
LEFT JOIN VWorkflowProcessPlanActivity PPA25 ON PPA25.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId25
/*---------------Expand to 35 steps--------------------------------------------------------------------------*/
LEFT JOIN VWorkflowProcessPlanActivity PPA26 ON PPA26.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId26
LEFT JOIN VWorkflowProcessPlanActivity PPA27 ON PPA27.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId27
LEFT JOIN VWorkflowProcessPlanActivity PPA28 ON PPA28.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId28
LEFT JOIN VWorkflowProcessPlanActivity PPA29 ON PPA29.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId29
LEFT JOIN VWorkflowProcessPlanActivity PPA30 ON PPA30.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId30
LEFT JOIN VWorkflowProcessPlanActivity PPA31 ON PPA31.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId31
LEFT JOIN VWorkflowProcessPlanActivity PPA32 ON PPA32.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId32
LEFT JOIN VWorkflowProcessPlanActivity PPA33 ON PPA33.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId33
LEFT JOIN VWorkflowProcessPlanActivity PPA34 ON PPA34.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId34
LEFT JOIN VWorkflowProcessPlanActivity PPA35 ON PPA35.WorkflowProcessPlanActivityId = PPCA.WorkflowProcessPlanActivityId35
/*----------------------------------------------------------------------------------------------------------*/
LEFT JOIN VWorkflowProcessActivity PA1 ON PA1.WorkflowProcessID = PCA.WorkflowProcessID AND PA1.GraphNodeKey = PCA.GraphNodeKey1
LEFT JOIN VWorkflowProcessActivity PA2 ON PA2.WorkflowProcessID = PCA.WorkflowProcessID AND PA2.GraphNodeKey = PCA.GraphNodeKey2
LEFT JOIN VWorkflowProcessActivity PA3 ON PA3.WorkflowProcessID = PCA.WorkflowProcessID AND PA3.GraphNodeKey = PCA.GraphNodeKey3
LEFT JOIN VWorkflowProcessActivity PA4 ON PA4.WorkflowProcessID = PCA.WorkflowProcessID AND PA4.GraphNodeKey = PCA.GraphNodeKey4
LEFT JOIN VWorkflowProcessActivity PA5 ON PA5.WorkflowProcessID = PCA.WorkflowProcessID AND PA5.GraphNodeKey = PCA.GraphNodeKey5
LEFT JOIN VWorkflowProcessActivity PA6 ON PA6.WorkflowProcessID = PCA.WorkflowProcessID AND PA6.GraphNodeKey = PCA.GraphNodeKey6
LEFT JOIN VWorkflowProcessActivity PA7 ON PA7.WorkflowProcessID = PCA.WorkflowProcessID AND PA7.GraphNodeKey = PCA.GraphNodeKey7
LEFT JOIN VWorkflowProcessActivity PA8 ON PA8.WorkflowProcessID = PCA.WorkflowProcessID AND PA8.GraphNodeKey = PCA.GraphNodeKey8
LEFT JOIN VWorkflowProcessActivity PA9 ON PA9.WorkflowProcessID = PCA.WorkflowProcessID AND PA9.GraphNodeKey = PCA.GraphNodeKey9
LEFT JOIN VWorkflowProcessActivity PA10 ON PA10.WorkflowProcessID = PCA.WorkflowProcessID AND PA10.GraphNodeKey = PCA.GraphNodeKey10
LEFT JOIN VWorkflowProcessActivity PA11 ON PA11.WorkflowProcessID = PCA.WorkflowProcessID AND PA11.GraphNodeKey = PCA.GraphNodeKey11
LEFT JOIN VWorkflowProcessActivity PA12 ON PA12.WorkflowProcessID = PCA.WorkflowProcessID AND PA12.GraphNodeKey = PCA.GraphNodeKey12
LEFT JOIN VWorkflowProcessActivity PA13 ON PA13.WorkflowProcessID = PCA.WorkflowProcessID AND PA13.GraphNodeKey = PCA.GraphNodeKey13
LEFT JOIN VWorkflowProcessActivity PA14 ON PA14.WorkflowProcessID = PCA.WorkflowProcessID AND PA14.GraphNodeKey = PCA.GraphNodeKey14
LEFT JOIN VWorkflowProcessActivity PA15 ON PA15.WorkflowProcessID = PCA.WorkflowProcessID AND PA15.GraphNodeKey = PCA.GraphNodeKey15
LEFT JOIN VWorkflowProcessActivity PA16 ON PA16.WorkflowProcessID = PCA.WorkflowProcessID AND PA16.GraphNodeKey = PCA.GraphNodeKey16
LEFT JOIN VWorkflowProcessActivity PA17 ON PA17.WorkflowProcessID = PCA.WorkflowProcessID AND PA17.GraphNodeKey = PCA.GraphNodeKey17
LEFT JOIN VWorkflowProcessActivity PA18 ON PA18.WorkflowProcessID = PCA.WorkflowProcessID AND PA18.GraphNodeKey = PCA.GraphNodeKey18
LEFT JOIN VWorkflowProcessActivity PA19 ON PA19.WorkflowProcessID = PCA.WorkflowProcessID AND PA19.GraphNodeKey = PCA.GraphNodeKey19
LEFT JOIN VWorkflowProcessActivity PA20 ON PA20.WorkflowProcessID = PCA.WorkflowProcessID AND PA20.GraphNodeKey = PCA.GraphNodeKey20
LEFT JOIN VWorkflowProcessActivity PA21 ON PA21.WorkflowProcessID = PCA.WorkflowProcessID AND PA21.GraphNodeKey = PCA.GraphNodeKey21
LEFT JOIN VWorkflowProcessActivity PA22 ON PA22.WorkflowProcessID = PCA.WorkflowProcessID AND PA22.GraphNodeKey = PCA.GraphNodeKey22
LEFT JOIN VWorkflowProcessActivity PA23 ON PA23.WorkflowProcessID = PCA.WorkflowProcessID AND PA23.GraphNodeKey = PCA.GraphNodeKey23
LEFT JOIN VWorkflowProcessActivity PA24 ON PA24.WorkflowProcessID = PCA.WorkflowProcessID AND PA24.GraphNodeKey = PCA.GraphNodeKey24
LEFT JOIN VWorkflowProcessActivity PA25 ON PA25.WorkflowProcessID = PCA.WorkflowProcessID AND PA25.GraphNodeKey = PCA.GraphNodeKey25
/*-----------------------------------Expand to 35 steps-----------------------------------------------*/
LEFT JOIN VWorkflowProcessActivity PA26 ON PA26.WorkflowProcessID = PCA.WorkflowProcessID AND PA26.GraphNodeKey = PCA.GraphNodeKey26
LEFT JOIN VWorkflowProcessActivity PA27 ON PA27.WorkflowProcessID = PCA.WorkflowProcessID AND PA27.GraphNodeKey = PCA.GraphNodeKey27
LEFT JOIN VWorkflowProcessActivity PA28 ON PA28.WorkflowProcessID = PCA.WorkflowProcessID AND PA28.GraphNodeKey = PCA.GraphNodeKey28
LEFT JOIN VWorkflowProcessActivity PA29 ON PA29.WorkflowProcessID = PCA.WorkflowProcessID AND PA29.GraphNodeKey = PCA.GraphNodeKey29
LEFT JOIN VWorkflowProcessActivity PA30 ON PA30.WorkflowProcessID = PCA.WorkflowProcessID AND PA30.GraphNodeKey = PCA.GraphNodeKey30
LEFT JOIN VWorkflowProcessActivity PA31 ON PA31.WorkflowProcessID = PCA.WorkflowProcessID AND PA31.GraphNodeKey = PCA.GraphNodeKey31
LEFT JOIN VWorkflowProcessActivity PA32 ON PA32.WorkflowProcessID = PCA.WorkflowProcessID AND PA32.GraphNodeKey = PCA.GraphNodeKey32
LEFT JOIN VWorkflowProcessActivity PA33 ON PA33.WorkflowProcessID = PCA.WorkflowProcessID AND PA33.GraphNodeKey = PCA.GraphNodeKey33
LEFT JOIN VWorkflowProcessActivity PA34 ON PA34.WorkflowProcessID = PCA.WorkflowProcessID AND PA34.GraphNodeKey = PCA.GraphNodeKey34
LEFT JOIN VWorkflowProcessActivity PA35 ON PA35.WorkflowProcessID = PCA.WorkflowProcessID AND PA35.GraphNodeKey = PCA.GraphNodeKey35
/*---------------------------------------------------------------------------------------------------*/

GO
/****** Object:  View [dbo].[V_TheCompany_VPRODUCTGROUP_TN_AI_INCL_INACTIVE]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_VPRODUCTGROUP_TN_AI_INCL_INACTIVE]

as

	SELECT p.PRODUCTGROUPID
	, (case when p.PRODUCTGROUPNOMENCLATUREID = '2' then 'AI'
			when p.PRODUCTGROUPNOMENCLATUREID ='3' then 'TN'
			else 'Other' END) as TN_or_AI

	,(REPLACE(p.[PRODUCTGROUP], '#', '')) AS PRODUCTGROUP
	, p.PRODUCTGROUPCODE
	,p.PRODUCTGROUPNOMENCLATUREID 
	, (CASE WHEN CHARINDEX('###',p.PRODUCTGROUPCODE) >0 THEN 3 /* exclude junk */ 
			WHEN CHARINDEX('##',p.PRODUCTGROUPCODE) >0 THEN 2 
			WHEN CHARINDEX('#',p.PRODUCTGROUPCODE) >0 THEN 1 
			ELSE 0 END) as blnNumHashes
	/* is used flag */
	,(CASE WHEN p.PRODUCTGROUPID IN(select PRODUCTGROUPID 
			from dbo.VPRODUCTGROUPS_IN_CONTRACT) THEN 1 ELSE 0 END) 
		as ProductGroup_IsUsed
	, (select count(contractid) 
			from TPROD_GROUP_IN_CONTRACT pc 
			where pc.productgroupid = p.productgroupid
			group by pc.PRODUCTGROUPID	
			) as Product_ContractCount	
	, (select count(contractid) 
			from TPROD_GROUP_IN_CONTRACT pc 
			where pc.productgroupid = p.productgroupid
			and pc.CONTRACTID in (select contractid from tcontract where statusid = 5 /* active */)
			group by pc.PRODUCTGROUPID	
			) as Product_ContractCountActive			
	,LEN(p.PRODUCTGROUP) as ProductGroup_LEN
	,  p.MIK_VALID as ProductGroup_MIK_VALID
	, p.PRODUCTGROUP AS PRODUCTGROUP_WITHHASH
	, p.PARENTID
	, pp.PRODUCTGROUP as ParentProductGroup

	FROM TPRODUCTGROUP p 
		left join  TPRODUCTGROUP pp on p.parentid = pp.PRODUCTGROUPID
	WHERE 
		p.PRODUCTGROUPNOMENCLATUREID IN('2' /* API */,'3' /* TN */) 

GO
/****** Object:  View [dbo].[V_TheCompany_UserID_CountractRoleCount_ADSynch]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_UserID_CountractRoleCount_ADSynch]

as

select u.EMAIL
, u.USERINITIAL
, u.DISPLAYNAME
, u.PRIMARYUSERGROUP
, u.STARTDATE
, MIK_VALID
, r.NumTotalRoles
, r.NumTotalRolesActive
  FROM [TheVendor_app].[dbo].[V_TheCompany_UserID_CountractRoleCount] r 
  inner join VUSER u on r.userid = u.userid
  where MIK_VALID = 1
  and EMAIL <>'TheVendor@TheCompany.com'
  and u.PRIMARYUSERGROUP not like 'Departments\Legal\TheVendor Sys%'
  and u.PRIMARYUSERGROUP not like '%Administrat%'
GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_ARB_TPRODUCT_ContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view

[dbo].[V_TheCompany_KWS_2_ARB_TPRODUCT_ContractID]
/* to do: include spaces with Productgroup name */
as 

	SELECT DISTINCT 
		s.*

		, t.ContractInternalID as ContractID

		, c.PRODUCTGROUP /* only exact match, first match */
		, c.PRODUCTGROUP_UPPER /* user for exact match */
		, c.[PRODUCTGROUPID] /* same ID for same contract #, handle in next level */
		, c.[PRODUCTGROUPNOMENCLATUREID]
		, c.[Product_LettersNumbersOnly]
		, c.[Product_LettersNumbersSpacesOnly]

		, (case when (c.Productgroup_UPPER =  s.KeyWordVarchar255_UPPER 
			OR c.[Product_LettersNumbersSpacesOnly] = s.KeyWordLettersNumbersSpacesOnly_UPPER /* if more than 6 char */) /* - . etc. do not count and compare UPPER */
			OR (c.[Product_LettersNumbersOnly] = s.KeyWordLettersNumbersOnly_UPPER AND s.[KeyWordLength] > 7 ) /*ESON PAC AB = Esonpac AB*/
			THEN s.KeyWordVarchar255_UPPER 
				ELSE '' END) as PrdGrpMatch_EXACT

		, (case when (c.Productgroup_UPPER =  s.KeyWordVarchar255_UPPER 
			OR c.[Product_LettersNumbersSpacesOnly] = s.KeyWordLettersNumbersSpacesOnly_UPPER /* if more than 6 char */) /* - . etc. do not count and compare UPPER */
			OR (c.[Product_LettersNumbersOnly] = s.KeyWordLettersNumbersOnly_UPPER AND s.[KeyWordLength] > 7 ) /*ESON PAC AB = Esonpac AB*/
			THEN 1 ELSE 0 END) as PrdGrpMatch_EXACT_FLAG

		, (case when c.[Product_LettersNumbersSpacesOnly] like KeyWordLettersNumbersSpacesOnly_UPPER +'%' 
				AND KeyWord_ExclusionFlag = 0
				THEN c.[Product_LettersNumbersSpacesOnly] ELSE null END) 
			as PrdGrpMatch_LIKE

	, (case WHEN c.[Product_LettersNumbersSpacesOnly] like KeyWordLettersNumbersSpacesOnly_UPPER +'%' 
			AND KeyWord_ExclusionFlag = 0
			THEN 1 ELSE 0 END) 
			as PrdGrpMatch_LIKE_FLAG

		, (case when c.[Product_LettersNumbersOnly] like [KeyWordLettersNumbersOnly_UPPER]+'%' 
			AND KeyWord_ExclusionFlag = 0
				THEN 1 ELSE 0 END) 
			as PrdGrpMatch_LettersNumbersOnly_FLAG

		, (case when c.[Product_LettersNumbersOnly] like [KeyWordFirstTwoWords_LettersOnly_UPPER]+'%' 
			AND KeyWord_ExclusionFlag = 0
				THEN 1 ELSE 0 END) 
			as PrdGrpMatch_FirstTwoWords_FLAG

		, (case when c.[Product_LettersNumbersOnly] like [KeyWordFirstWord_LettersOnly_UPPER]+'%' 
		/* AND [KeyWordFirstWord_LEN] > 4 */ 
			AND KeyWord_ExclusionFlag = 0
				THEN 1 ELSE 0 END) 
			as PrdGrpMatch_FirstWord_FLAG

	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		left join T_TheCompany_TPRODUCTGROUP c
			on  c.[Product_LettersNumbersOnly]
			LIKE (CASE WHEN UPPER(s.[KeyWordFirstWord_LettersOnly_UPPER]) 
				in ('xxx') /* noise words */ 
				/*	OR c.[ProductgroupType] = 'I'  /* Individual */*/
				THEN /* avoid three letter KMC */
						left(s.[KeyWordLettersNumbersOnly_UPPER],11)+'%' 
					WHEN [KeyWordFirstWord_LEN] <=4 THEN
						left(s.[KeyWordLettersNumbersOnly_UPPER],6)+'%' /* e.g. S. Goldmann */
					WHEN [KeyWordFirstWord_LEN] >4 THEN
						left(s.[KeyWordLettersNumbersOnly_UPPER],4)+'%' /* e.g. S. Goldmann */
					END)
				AND  c.[Product_LettersNumbersOnly] is not null /* e.g. customer id 232816 안유배 교수님 blanked out like in Ariba Chinese ones, leads to cartesian product */
				/* cannot set min keyword length to 6 since e.g. AS Productgroup would be excluded */
		inner join V_TheCompany_Ariba_Products_In_Contracts_UNION t on c.PRODUCTGROUPID = t.PRODUCTGROUPID
	WHERE /* g.[Contract Id] ='CW2548994'
		AND */ s.KeyWordType='Product' 
		AND (
			 /* c.Productgroup = s.KeyWordVarchar255 
			 OR */ c.[Product_LettersNumbersOnly]= s.[KeyWordLettersNumbersOnly_UPPER]
			/* First Word over 6 char */ 
			OR ([Product_FirstWord] /* 6 char and more */ = [KeyWordFirstWord_UPPER] 
				AND [KeyWordFirstWord_LEN] >6) /* 6 = 900 hits, 5 = 1300 with e.g. Deutsche Lanolin Gesellschaft */
			/*OR (c.[ProductgroupName_RemoveNonAlphaNonNumericChar] LIKE s.[KeyWordLettersNumbersOnly_UPPER]+'%' 
				AND s.[KeyWordLength] > 6)*/
			OR c.[Product_FirstTwoWords] LIKE [KeyWordFirstTwoWords_UPPER]+'%'
			OR c.[Product_LettersNumbersSpacesOnly] LIKE 
				(CASE WHEN s.KeyWordLength > 6 
				THEN [KeyWordLettersNumbersSpacesOnly_UPPER]+'%' 
				ELSE [KeyWordLettersNumbersSpacesOnly_UPPER]+'[ ]%' /* MYLANLDA (Mylan) */
				END)
			OR (c.[Product_LettersNumbersOnly] LIKE s.[KeyWordFirstTwoWords_LettersOnly_UPPER] +'%' 
				AND s.[KeyWordLength] > 8)
			)

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_3_ARB_TPRODUCT_ContractID_Extended]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_KWS_3_ARB_TPRODUCT_ContractID_Extended]
/* creates T_TheCompany_KWS_ProductID_ContractID */
as 

	SELECT  
		*

	, (case WHEN PrdGrpMatch_EXACT_FLAG = 1 
				AND PrdGrpMatch_LIKE_FLAG = 1 /* is like match */ 
			THEN 2 /* is like match but not relevant because direct match */ 
			/* when [KeyWord_ExclusionFlag] = 1 then 3 */
			ELSE PrdGrpMatch_LIKE_FLAG END) 
			as ProductgroupMatch_Like_FLAG

		, (case when PrdGrpMatch_LettersNumbersOnly_FLAG = 1	ANd PrdGrpMatch_EXACT_FLAG = 1	 THEN 2	 
			/* when [KeyWord_ExclusionFlag] = 1 then 3 */
				 ELSE PrdGrpMatch_LettersNumbersOnly_FLAG END) 
			as ProductgroupMatch_LettersNumbersOnly_FLAG

		, (case when PrdGrpMatch_FirstWord_FLAG = 1 AND PrdGrpMatch_EXACT_FLAG = 0 THEN 2
			when [KeyWord_ExclusionFlag] = 1 then 3
				 ELSE PrdGrpMatch_FirstWord_FLAG END) 
			as ProductgroupMatch_FirstWord_FLAG

		, (case when PrdGrpMatch_FirstTwoWords_FLAG = 1 AND PrdGrpMatch_EXACT_FLAG = 1 THEN 2
			/* when [KeyWord_ExclusionFlag] = 1 then 3 */
				 ELSE PrdGrpMatch_FirstTwoWords_FLAG END) 
			as ProductgroupMatch_FirstTwoWords_FLAG



	, (CASE WHEN u.PrdGrpMatch_EXACT_FLAG = 1
				and [PRODUCTGROUPNOMENCLATUREID] = 2 /* Active ingredients */
			THEN 2 /* exact */
			/* when [KeyWord_ExclusionFlag] = 1 then 3 */
			WHEN u.PrdGrpMatch_Like_FLAG = 1
							and [PRODUCTGROUPNOMENCLATUREID] = 2 /* Active ingredients */
			THEN 1 /* fuzzy */

			ELSE 0 END) 
			AS ProductMatch_AI

	, (CASE WHEN  u.PrdGrpMatch_EXACT_FLAG = 1
				and [PRODUCTGROUPNOMENCLATUREID] = 3 /* Trade Names */
				THEN 2 /* exact */
			/* when [KeyWord_ExclusionFlag] = 1 then 3 */
			WHEN u.PrdGrpMatch_LIKE_FLAG = 1
							and [PRODUCTGROUPNOMENCLATUREID] = 3 /* Trade Names */
				THEN 1 /* fuzzy */
			ELSE 0 END) 
			AS ProductMatch_TN
/*
	, (CASE WHEN u.ProductgroupMatch_Like_FLAG = 2
				and [PRODUCTGROUPNOMENCLATUREID] = 2 /* Active ingredients */
			THEN 2 /* exact */
			WHEN u.ProductgroupMatch_Like_FLAG = 1
							and [PRODUCTGROUPNOMENCLATUREID] = 2 /* Active ingredients */
			THEN 1 /* fuzzy */

			ELSE 0 END) 
			AS ProductMatch_AI
	, (CASE WHEN  u.ProductgroupMatch_Like_FLAG = 2
				and [PRODUCTGROUPNOMENCLATUREID] = 3 /* Trade Names */
			THEN 2 /* exact */
			WHEN u.ProductgroupMatch_Like_FLAG = 1
							and [PRODUCTGROUPNOMENCLATUREID] = 3 /* Trade Names */
			THEN 1 /* fuzzy */
			ELSE 0 END) 
			AS ProductMatch_TN
			*/

	, [PrdGrpMatch_EXACT_Flag] 
		AS ProductMatch_Exact
	, (CASE when [KeyWord_ExclusionFlag] = 1 then 0
		/* WHEN [PrdGrpMatch_EXACT_Flag]=0 THEN 1 		 */
		ELSE 0 END) 
		AS ProductMatch_NotExact
	, [KeyWordVarchar255]
		AS ProductKeyword_Any

	FROM V_TheCompany_KWS_2_ARB_TPRODUCT_ContractID u /* big definition query */
	WHERE u.ContractID > '' /* no NULLS */
	AND ( [KeyWord_ExclusionFlag] = 0 OR [PrdGrpMatch_EXACT_Flag] = 1) /* - only if exact match */
	/* ACTIVE CONTRACTS */
	/* and p.mik_valid = 1 */
	/*	and contractid = 13286 */

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_4_ARB_TPRODUCT_ContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_KWS_4_ARB_TPRODUCT_ContractID]

as

select

	 d.ContractID
		 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.keywordvarchar255 
		FROM [dbo].[T_TheCompany_KWS_2_ARB_TPRODUCT_ContractID] p 
		where p.ContractID = d.ContractID 
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Any

	,	Replace(STUFF(
		(SELECT  DISTINCT ',' + k.PRODUCTGROUP
		FROM [T_TheCompany_KWS_2_ARB_TPRODUCT_ContractID] k 	
		where k.ContractID = d.ContractID 
			and k.[PRODUCTGROUPNOMENCLATUREID]= 3 /* TN */ 
		FOR XML PATH('')),1,1,''),'&amp;','&') AS KeyWordMatch_TradeNames
	, 
		Replace(STUFF(
		(SELECT  DISTINCT ',' + k.PRODUCTGROUP
		FROM [T_TheCompany_KWS_2_ARB_TPRODUCT_ContractID] k 	
		where k.ContractID = d.ContractID 
			and k.[PRODUCTGROUPNOMENCLATUREID]= 2 /* AI */ 
		FOR XML PATH('')),1,1,''),'&amp;','&') AS KeyWordMatch_ActiveIngredient

			 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup
		FROM [dbo].[V_TheCompany_KWS_3_ARB_TProduct_ContractID_Extended] p 
		where p.ContractID = d.ContractID 
		and p.[ProductMatch_Exact] = 1 /* field only in extended table */
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Product_EXACT

		 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[V_TheCompany_KWS_3_ARB_TProduct_ContractID_Extended] p 
		where p.ContractID = d.ContractID 
		and p.[ProductMatch_NotExact] = 1
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Product_NotExact

			 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[V_TheCompany_KWS_3_ARB_TProduct_ContractID_Extended] p 
		where p.ContractID = d.ContractID 
		and (p.[ProductMatch_TN] = 1 OR p.[ProductMatch_AI] = 1) /* extended table */
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Product_AIorTN

			 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[V_TheCompany_KWS_3_ARB_TProduct_ContractID_Extended] p 
		where p.ContractID = d.ContractID 
		and p.[ProductMatch_Exact] = 0
		and p.[ProductMatch_NotExact] = 0
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Other

	, 
		Replace(STUFF(
		(SELECT  DISTINCT ',' + k.[KeyWordCustom1]
		FROM [T_TheCompany_KWS_2_ARB_TPRODUCT_ContractID] k 	
		where k.ContractID = d.ContractID 
		AND k.[KeyWordCustom1] IS NOT NULL
		FOR XML PATH('')),1,1,''),'&amp;','&') AS KeyWordCustom1_List
	, 
		Replace(STUFF(
		(SELECT  DISTINCT ',' + k.[KeyWordCustom2]
		FROM [T_TheCompany_KWS_2_ARB_TPRODUCT_ContractID] k 	
		where k.ContractID = d.ContractID 
		AND k.[KeyWordCustom2] IS NOT NULL
		FOR XML PATH('')),1,1,''),'&amp;','&') AS KeyWordCustom2_List
	, 
		Replace(STUFF(
		(SELECT  DISTINCT ',' + k.[KeyWordSource]
		FROM [T_TheCompany_KWS_2_ARB_TPRODUCT_ContractID] k 	
		where k.ContractID = d.ContractID 
		AND k.[KeyWordSource] IS NOT NULL
		FOR XML PATH('')),1,1,''),'&amp;','&') AS KeyWordSource_Lists

	FROM  [T_TheCompany_KWS_2_ARB_TPRODUCT_ContractID]  d
	GROUP BY ContractID

GO
/****** Object:  View [dbo].[VDOCUMENTINOBJECTS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VDOCUMENTINOBJECTS]
AS
SELECT	VD.OBJECTTYPE,
		VD.OBJECTTYPEFIXED,
		VD.TITLE,
		VD.VERSION,
		VD.MajorVersion,
		VD.MinorVersion,
		VD.STATUS,
		VD.OWNER,
		VD.TEMPLATETYPE,
		VD.CHECKEDOUTBY,
		VD.VERSIONDATE,
		VD.DATECREATED,
		VD.CHECKEDOUTDATE,
		VD.FILENAME,
		VD.FileSize,
		VD.ORIGINALFILENAME,
		VD.DOCUMENTOWNERID,
		VD.CHECKEDOUTBYID,
		VD.CHECKEDOUTSTATUS,
		VD.DOCUMENTTYPEID,
		VD.DOCUMENTID,
		VD.ARCHIVEID,
		VD.SOURCEFILEINFOID,
		VD.ARCHIVEFIXED,
		VD.MIKVALID,
		VD.FileID,
		VD.FileType,
		VD.OBJECTTYPEID,
		VD.OBJECTID,
		VD.CLAUSECOUNT,
		VD.CheckSum,
		VD.FILEINFOID,
		VD.MODULETYPEID,
		VD.MIK_SEQUENCE,
		VD.PUBLISH,
		VD.ApprovalStatus,
		VD.ApprovalStatusID,
		VD.ApprovalStatusFixed,
		VD.SCHEDULEDFORARCHIVING,
		VD.ARCHIVEDDATE,
		VD.ARCHIVEDOCUMENTKEY,
		VD.INDATE,
		VD.OUTDATE,
		VD.SHAREDWITHSUPPLIER,
		VD.CONTRACT_COMPANYID,
		VD.CONTRACT_SHAREDWITHSUPPLIER,
		VD.CONTRACT_STATUS_FIXED,
		VD.SUB_OBJECTTYPEID, 
		DP.PERSONS
  FROM	VDOCUMENTINOBJECTS_WO_ROLES VD
  JOIN	dbo.VDOCUMENTROLESCUMULATIVE DP
	ON	DP.DOCUMENTID = VD.DOCUMENTID


GO
/****** Object:  View [dbo].[V_TheCompany_KWS_4_ARB_TPRODUCT_Summary]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_KWS_4_ARB_TPRODUCT_Summary]
as

	SELECT  
		p.KeyWordVarchar255
		, p.PRODUCTGROUP /* duplicates products that are a match for more than one product such as Circadine/e */
		,p.PRODUCTGROUPID
		, p.PRODUCTGROUPNOMENCLATUREID

				,Replace(STUFF(
			(SELECT DISTINCT ',' + rs.[KeyWordSource]
			FROM [V_TheCompany_KeyWordSearch] rs
			where  rs.KeyWordVarchar255 = p.KeyWordVarchar255
			AND rs.[KeyWordSource] IS NOT NULL
			/* and rs.ProductExact_Flag = 1 */
			FOR XML PATH('')),1,1,''),'&amp;','&') AS KeyWordSource_List

		,Replace(STUFF(
			(SELECT DISTINCT ',' + rs.[KeyWordCustom1]
			FROM [V_TheCompany_KeyWordSearch] rs
			where  rs.KeyWordVarchar255 = p.KeyWordVarchar255
			AND rs.[KeyWordCustom1] IS NOT NULL
			/* and rs.ProductExact_Flag = 1 */
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Custom1_List

		,Replace(STUFF(
			(SELECT DISTINCT ',' + rs.[KeyWordCustom2]
			FROM [V_TheCompany_KeyWordSearch] rs
			where  rs.KeyWordVarchar255 = p.KeyWordVarchar255
			AND rs.[KeyWordCustom2] IS NOT NULL
			/* and rs.ProductExact_Flag = 1 */
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Custom2_List

		, count(/* DISTINCT */ p.ContractID) as ContractCount

	FROM [V_TheCompany_KWS_3_ARB_TPRODUCT_ContractID_Extended] p
	GROUP BY 
		p.KeyWordVarchar255
		, p.PRODUCTGROUP
		, p.PRODUCTGROUPID
		, p.PRODUCTGROUPNOMENCLATUREID

/*
	SELECT top 1000

		s.KeywordCategory /* sort order 1 */
		,s.[KeyWordVarchar255] /* sort order 2 */

		/*, max(Productgroupid) as ProductgroupIDMax */
		,Replace(STUFF(
			(SELECT DISTINCT ',' + pp.PRODUCTGROUP
			FROM [dbo].[V_TheCompany_KWS_2_ARB_TPRODUCT_ContractID] pp
			where  pp.KeyWordVarchar255 = s.KeyWordVarchar255
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Products
		, count([ContractInternalID]) as ContractCount
		, max(case when s.KeyWordSearchTag = 'TN' Then 'TN' ELSE '' END) as Product_TN_AI /* only returns tn */
	FROM [V_TheCompany_KeyWordSearch] s left join [V_TheCompany_KWS_2_ARB_TPRODUCT_ContractID] p 
		on s.KeyWordVarchar255 like '%'+p.KeyWordVarchar255+'%'
	WHERE  s.KeyWordType = 'Product'
	group by s.KeywordCategory, s.KeyWordVarchar255
	order by s.KeywordCategory, s.KeyWordVarchar255

	*/

GO
/****** Object:  View [dbo].[VDOCUMENTINOBJECTS_CHECKPERSONS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		rasputinge
-- Create date: 2013-05-28
-- Description:	Add "LastChanged" and "CheckedOutBy" person to VDOCUMENTINOBJECTS_CHECK fields (4966 story)
-- =============================================
CREATE VIEW [dbo].[VDOCUMENTINOBJECTS_CHECKPERSONS]
AS
SELECT	D.OBJECTTYPE,
	D.OBJECTTYPEFIXED,
	D.TITLE,
	D.VERSION,
	D.MajorVersion,
	D.MinorVersion,
	D.STATUS,
	D.OWNER,
	D.TEMPLATETYPE,
	D.CHECKEDOUTBY,
	D.VERSIONDATE,
	D.ChangeComment,
	D.LastInternalComment,
	D.LastChangedBy,
	D.DATECREATED,
	D.CHECKEDOUTDATE,
	D.FILENAME,
	D.FileSize,
	D.ORIGINALFILENAME,
	D.DOCUMENTOWNERID,
	D.CHECKEDOUTBYID,
	D.CHECKEDOUTSTATUS,
	D.DOCUMENTTYPEID,
	D.DOCUMENTID,
	D.ARCHIVEID,
	D.SOURCEFILEINFOID,
	D.ARCHIVEFIXED,
	D.MIKVALID,
	D.FileID,
	D.FileType,
	D.SmartTemplateBasedDocCanBeEdited,
	D.OBJECTTYPEID,
	D.OBJECTID,
	D.clausecount,
	D.checksum,
	D.FILEINFOID,
	D.MODULETYPEID,
	D.MIK_SEQUENCE,
	D.PUBLISH,
	D.ApprovalStatus,
	D.ApprovalStatusID,
	D.ApprovalStatusFixed,
	D.SCHEDULEDFORARCHIVING,
	D.ARCHIVEDDATE,
	D.ARCHIVEDOCUMENTKEY,
	D.INDATE,
	D.OUTDATE,
	D.SHAREDWITHSUPPLIER,
	D.CONTRACT_COMPANYID,
	D.CONTRACT_SHAREDWITHSUPPLIER,
	D.CONTRACT_STATUS_FIXED,
	D.SUB_OBJECTTYPEID,

	ULastChanged.LastName AS LastChangedLastName, 
	ULastChanged.FirstName AS LastChangedFirstName, 
	ULastChanged.MiddleName AS LastChangedMiddleName,
	
	UCheckedOutBy.LastName AS CheckedOutLastName, 
	UCheckedOutBy.FirstName AS CheckedOutFirstName, 
	UCheckedOutBy.MiddleName AS CheckedOutMiddleName
		
  FROM VDOCUMENTINOBJECTS_WO_ROLES D
  LEFT JOIN VUSER ULastChanged ON ULastChanged.UserID=D.LastChangedBy
  LEFT JOIN VUSER UCheckedOutBy ON UCheckedOutBy.UserID=D.CHECKEDOUTBYID


GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_DATA_IP]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_LNC_Mig_DATA_IP]

as 

	SELECT
		  [OBJECTID] as CONTRACTID
			, 'CTK-' + convert(varchar(50),r.[DEPARTMENTID]) AS INTERNALPARTNERID
			,  [DEPARTMENTROLE_IN_OBJECTID] as INTERNALPARTNERID_IN_OBJECTID
		  , i.IP_CostCenter
		  , i.[InternalPartnerStatus]
		  ,r.[DEPARTMENT] as InternalPartnerName
		  ,r.[DEPARTMENT_CODE]
		 /* , f.[InternalPartners_ACTIVE_MAX_DPTID] */
		 , (case when r.departmentid = f.[InternalPartners_ACTIVE_MAX_DPTID]
					then 1 else 0 end) as FirstEntityInContract_FLAG 

		 ,r.DEPARTMENTID
		, GETDATE() as DateRefreshed
	FROM
		[dbo].[V_TheCompany_VDEPARTMENTROLE_IN_OBJECT_Xt] r 
		inner join [dbo].[V_TheCompany_VDepartment_ParsedDpt_InternalPartner] i 
				on r.DEPARTMENTID = i.departmentid
		inner join [dbo].[V_TheCompany_VCONTRACT_DPTROLES_FLAT] f 
			on r.OBJECTID = f.Dpt_contractid
		inner join V_TheCompany_LNC_GoldStandard c /* was T_TheCompany_ALL */
			on r.OBJECTID = c.CONTRACTID
		
	WHERE [Roleid_Cat2Letter] = 'IP' 
		and i.InternalPartnerStatus = 'Active' /* remainder into comments */
		
GO
/****** Object:  View [dbo].[VLOGGEDINUSERS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VLOGGEDINUSERS] AS(
select TOP 100 PERCENT l.dt_logon LoggedOn, u.displayname DisplayName, l.appl Application, u.Phone1, u.Phone2, u.EMail, u.PrimaryUsergroup, u.UserInitial, u.UserId
from vuser u, tlogon l
where
u.userid=l.userid and
l.dt_logoff is null and
l.dt_logon>(GetDate()-1)
order by l.dt_logon desc, u.displayname asc
)




GO
/****** Object:  View [dbo].[VMODULE]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VMODULE] AS
SELECT     M.MODULEID, MT.DOCUMENTTYPEID, D.DOCUMENTTYPE, M.MIK_MODULE, M.COMMENTS, M.OLDFILENAME, M.NEWFILENAME, 
                      CONVERT(VARCHAR, TDF.MajorVersion) + '.' + CONVERT(VARCHAR, TDF.MinorVersion) AS VERSION, TDF.MajorVersion, TDF.MinorVersion, 
                      TDF.LastChangedDate, M.FILEINFOID, M.CHECKEDIN, M.CHECKEDOUTBY, U.USERID, U.DISPLAYNAME, L.LANGUAGEID, L.MIK_LANGUAGE, 
                      MT.MODULETYPEID, MT.MODULETYPE, MC.MODULECATEGORYID, MC.MODULECATEGORY, TDF.FileID, TDF.FileSize, TDF.CheckSum, 
                      TDF.LastChangedBy, P2.DISPLAYNAME AS LASTCHANGEDBYNAME, CR.CONTRACTRELATIONID, CR.CONTRACTRELATION, 
                      AGT.AGREEMENT_TYPEID AS AGREEMENTTYPEID, AGT.AGREEMENT_TYPE AS AGREEMENTTYPE, ST.STRATEGYTYPEID, ST.STRATEGYTYPE, 
                      TDF.FileType, M.MIK_VALID AS MIKVALID,
                          (SELECT     COUNT(CIM.CLAUSEID)
                            FROM          TCLAUSE_IN_MODULE CIM
                            WHERE      CIM.MODULEID = M.MODULEID) AS CLAUSECOUNT, TPERSON_1.DISPLAYNAME AS CHECKEDOUTBYNAME, M.PUBLISH,
					M.PDFFILEINFOID as PdfFileInfoId, PDF.FileID as PDFFILEID, PDF.CheckSum as PdfFileCheckSum, PDF.FileSize as PdfFileSize, PDF.FileType as PdfFileType
FROM         dbo.TPERSON P2 RIGHT OUTER JOIN
                      dbo.TUSER U2 LEFT OUTER JOIN
                      dbo.TEMPLOYEE E2 ON U2.EMPLOYEEID = E2.EMPLOYEEID ON P2.PERSONID = E2.PERSONID RIGHT OUTER JOIN
                      dbo.TMODULE M INNER JOIN
                      dbo.VUSER U ON M.USERID = U.USERID INNER JOIN
                      dbo.TLANGUAGE L ON M.LANGUAGEID = L.LANGUAGEID INNER JOIN
                      dbo.TMODULETYPE MT ON M.MODULETYPEID = MT.MODULETYPEID INNER JOIN
                      dbo.TMODULECATEGORY MC ON MT.MODULECATEGORYID = MC.MODULECATEGORYID LEFT OUTER JOIN
                      dbo.TDOCUMENTTYPE D ON D.DOCUMENTTYPEID = MT.DOCUMENTTYPEID INNER JOIN
                      dbo.TFILEINFO TDF ON TDF.FileInfoID = M.FILEINFOID LEFT OUTER JOIN
					  dbo.TFILEINFO PDF ON PDF.FileInfoID = M.PDFFILEINFOID LEFT OUTER JOIN
                      dbo.TCONTRACTRELATION CR ON CR.CONTRACTRELATIONID = M.CONTRACTRELATIONID LEFT OUTER JOIN
                      dbo.TAGREEMENT_TYPE AGT ON AGT.AGREEMENT_TYPEID = M.AGREEMENT_TYPEID LEFT OUTER JOIN
                      dbo.TSTRATEGYTYPE ST ON ST.STRATEGYTYPEID = M.STRATEGYTYPEID LEFT OUTER JOIN
                      dbo.TEMPLOYEE TEMPLOYEE_1 LEFT OUTER JOIN
                      dbo.TPERSON TPERSON_1 ON TEMPLOYEE_1.PERSONID = TPERSON_1.PERSONID RIGHT OUTER JOIN
                      dbo.TUSER TUSER_1 ON TEMPLOYEE_1.EMPLOYEEID = TUSER_1.EMPLOYEEID ON M.CHECKEDOUTBY = TUSER_1.USERID ON 
                      U2.USERID = M.USERID

GO
/****** Object:  View [dbo].[V_TheCompany_KWS__Ariba_TTAG_ContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_KWS__Ariba_TTAG_ContractID]

as 

	select 
		a.* 
		, t.TagCategory as Tag
		, t.TagCategory
	FROM 
		T_TheCompany_Ariba_TTAG_IN_ContractInternalID a 
			inner join V_TheCompany_TTag_Summary_TagCategory t 
			on a.TagID = t.TagCatID /* was Tagid, not sure if this is correct? May 2021*/
	WHERE a.ContractInternalID is not null /* can be the case if new records not yet in Ariba table */

GO
/****** Object:  View [dbo].[VRFXDOCUMENTINOBJECTS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VRFXDOCUMENTINOBJECTS]
AS
SELECT     
		dbo.VDOCUMENTINOBJECTS.OBJECTTYPE,
		dbo.VDOCUMENTINOBJECTS.OBJECTTYPEFIXED,
		dbo.VDOCUMENTINOBJECTS.TITLE,
		dbo.VDOCUMENTINOBJECTS.VERSION,
		dbo.VDOCUMENTINOBJECTS.MajorVersion,
		dbo.VDOCUMENTINOBJECTS.MinorVersion,
		dbo.VDOCUMENTINOBJECTS.STATUS,
		dbo.VDOCUMENTINOBJECTS.OWNER,
		dbo.VDOCUMENTINOBJECTS.TEMPLATETYPE,
		dbo.VDOCUMENTINOBJECTS.CHECKEDOUTBY,
		dbo.VDOCUMENTINOBJECTS.VERSIONDATE,
		dbo.VDOCUMENTINOBJECTS.DATECREATED,
		dbo.VDOCUMENTINOBJECTS.CHECKEDOUTDATE,
		dbo.VDOCUMENTINOBJECTS.FILENAME,
		dbo.VDOCUMENTINOBJECTS.FileSize,
		dbo.VDOCUMENTINOBJECTS.ORIGINALFILENAME,
		dbo.VDOCUMENTINOBJECTS.DOCUMENTOWNERID,
		dbo.VDOCUMENTINOBJECTS.CHECKEDOUTBYID,
		dbo.VDOCUMENTINOBJECTS.CHECKEDOUTSTATUS,
		dbo.VDOCUMENTINOBJECTS.DOCUMENTTYPEID,
		dbo.VDOCUMENTINOBJECTS.DOCUMENTID,
		dbo.VDOCUMENTINOBJECTS.ARCHIVEID,
		dbo.VDOCUMENTINOBJECTS.SOURCEFILEINFOID,
		dbo.VDOCUMENTINOBJECTS.ARCHIVEFIXED,
		dbo.VDOCUMENTINOBJECTS.MIKVALID,
		dbo.VDOCUMENTINOBJECTS.FileID,
		dbo.VDOCUMENTINOBJECTS.FileType,
		dbo.VDOCUMENTINOBJECTS.OBJECTTYPEID,
		dbo.VDOCUMENTINOBJECTS.OBJECTID,
		dbo.VDOCUMENTINOBJECTS.CLAUSECOUNT,
		dbo.VDOCUMENTINOBJECTS.CheckSum,
		dbo.VDOCUMENTINOBJECTS.FILEINFOID,
		dbo.VDOCUMENTINOBJECTS.MODULETYPEID,
		dbo.VDOCUMENTINOBJECTS.MIK_SEQUENCE,
		dbo.VDOCUMENTINOBJECTS.PUBLISH,
		dbo.VDOCUMENTINOBJECTS.ApprovalStatus,
		dbo.VDOCUMENTINOBJECTS.ApprovalStatusID,
		dbo.VDOCUMENTINOBJECTS.ApprovalStatusFixed,
		dbo.VDOCUMENTINOBJECTS.SCHEDULEDFORARCHIVING,
		dbo.VDOCUMENTINOBJECTS.ARCHIVEDDATE,
		dbo.VDOCUMENTINOBJECTS.ARCHIVEDOCUMENTKEY
FROM       VDOCUMENTINOBJECTS


GO
/****** Object:  View [dbo].[V_TheCompany_KWS_7z_ARB_ContractID_SummaryByContractID_BAK]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view

[dbo].[V_TheCompany_KWS_7z_ARB_ContractID_SummaryByContractID_BAK]

as 
/* EXEC [dbo].[TheCompany_KeyWordSearch] */
	SELECT  
		[ContractInternalID] as ContractInternalID_KWS
/* Company */
		, '' /*Min([Source])*/ as MinSource
		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ',' + rs.CompanyExact /* [CompanyMatch_Name] */
			FROM [T_TheCompany_KWS_2_ARB_TCompany_ContractID] rs
			where  rs.ContractInternalID = u.ContractInternalID and rs.companyExact_Flag = 1
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [CompanyMatch_Exact]

/*			,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[CompanyMatch_Like] /*+': ' 
				+ rs.[CompanyMatch_Name]   + ' (Keyword: '+ rs.keywordvarchar255 + ')' /**/
				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM [T_TheCompany_KWS_2_ARB_TCompany_ContractID] rs
			where  rs.ContractInternalID = u.ContractInternalID   
				and [CompanyMatch_Like] = 1
				and [CompanyExact_Flag] = 0 
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [CompanyMatch_Like]	
*/

			,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordVarchar255] /*+': ' 
				+ rs.[CompanyMatch_Name]  + ' (Keyword: '+ rs.keywordvarchar255 
				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM [T_TheCompany_KWS_2_ARB_TCompany_ContractID] rs
			where  rs.ContractInternalID = u.ContractInternalID   
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [CompanyMatch_Any]	

/* custom */
			,Replace(STUFF(
			(SELECT DISTINCT ',' + rs.KeyWordCustom1_List
			FROM (select [KeyWordCustom1_List], contractinternalid from T_TheCompany_KWS_4_ARB_TProduct_ContractID
					UNION
					select [KeyWordCustom1], contractinternalid from T_TheCompany_KWS_2_ARB_TCompany_ContractID
					) rs
			where  rs.ContractInternalID = u.ContractInternalID
			/* and rs.ProductExact_Flag = 1 */
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Custom1_Lists

			,Replace(STUFF(
			(SELECT DISTINCT ',' + rs.KeyWordCustom2_List
			FROM T_TheCompany_KWS_4_ARB_TProduct_ContractID rs
			where  rs.ContractInternalID_Product = u.ContractInternalID
			/* and rs.ProductExact_Flag = 1 */
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Custom2_Lists

/* fuzzier match */

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ',' + rs.[KeyWordFirstTwoWords] /* [CompanyMatch_Name] */
			FROM [T_TheCompany_KWS_2_ARB_TCompany_ContractID] rs
			where  rs.ContractInternalID = u.ContractInternalID 
				and [CompanyMatch_FirstTwoWords] = 1
				and [CompanyExact_Flag] = 0 
			FOR XML PATH('')),1,1,''),'&amp;','&'))  AS [CompanyMatch_FirstTwoWords]



				,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordFirstWord] /*+': ' 
				+ rs.[CompanyMatch_Name]  + ' (Keyword: '+ rs.keywordvarchar255 
				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM [T_TheCompany_KWS_2_ARB_TCompany_ContractID] rs
			where  rs.ContractInternalID = u.ContractInternalID   
				and [CompanyMatch_FirstWord] = 1
				and [CompanyMatch_FirstTwoWords] = 0
				and [CompanyExact_Flag] = 0
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [CompanyMatch_FirstWord]

						,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordVarchar255] /*+': ' 
				+ rs.[CompanyMatch_Name]  + ' (Keyword: '+ rs.keywordvarchar255 
				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM T_TheCompany_KWS_2_ARB_TCOMPANYCountry_ContractID rs
			where  rs.ContractInternalID = u.ContractInternalID
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [CompanyCountryMatch]	

/* DESCRIPTION */

		/* , max(r.[CompanyMatch_Name]) as [CompanyMatch_Name] */
		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordVarchar255]
			FROM [T_TheCompany_KWS_4_ARB_DESCRIPTION_ContractID] rs
			where  rs.ContractInternalID = u.ContractInternalID
			/* only include records that are not a company match */			
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS Description_Match

/*		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordVarchar255]
			FROM [V_TheCompany_KWS_2_ARB_InternalPartner_ContractID] rs
			where  rs.ContractInternalID = u.ContractInternalID
			/* only include records that are not a company match */			
			FOR XML PATH('')),1,1,''),'&amp;','&'))*/ ,'' AS InternalPartner_Match

	/*	,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordVarchar255]
			FROM [V_TheCompany_KWS_2_ARB_Territory_ContractID] rs
			where  rs.ContractInternalID = u.ContractInternalID
			/* only include records that are not a company match */			
			FOR XML PATH('')),1,1,''),'&amp;','&')) */ ,'' AS Territory_Match

/* PRODUCTS */

		 ,LTRIM(Replace(STUFF(
	(SELECT DISTINCT ', ' + p.KeyWordMatch_Product_NotExact + ' ('+ p.KeyWordMatch_Product_NotExact + ')' 
	FROM [V_TheCompany_KWS_4_ARB_TProduct_ContractID] p 
	where  p.ContractInternalID_Product = u.ContractInternalID and (p.KeyWordMatch_ActiveIngredient >'' OR p.[KeyWordMatch_TradeNames] >'')
	FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Product_AIorTN


			 ,LTRIM(Replace(STUFF(
	(SELECT DISTINCT ', ' +  p.KeyWordMatch_Any
	FROM [V_TheCompany_KWS_4_ARB_TProduct_ContractID] p 
	where  p.ContractInternalID_Product = u.ContractInternalID 
	/* and (p.[ProductMatch_AI] = 1 OR p.[ProductMatch_TN] = 1) */
	FOR XML PATH('')),1,1,''),'&amp;','&')) AS ProductKeyword_Any

				 ,LTRIM(Replace(STUFF(
	(SELECT DISTINCT ', ' +  p.TagCategory
	FROM [T_TheCompany_KWS_2_ARB_Tag_ContractInternalID] p 
	where  p.ContractInternalID = u.ContractInternalID 
	and P.keywordtype = 'TagCategory'
	FOR XML PATH('')),1,1,''),'&amp;','&')) AS TagCategory_Match

				 ,LTRIM(Replace(STUFF(
	(SELECT DISTINCT ', ' +  p.TagCategory
	FROM [T_TheCompany_KWS_2_ARB_Tag_ContractInternalID] p 
	where  p.ContractInternalID = u.ContractInternalID 
	and P.keywordtype = 'Tag'
	FOR XML PATH('')),1,1,''),'&amp;','&')) AS Tag_Match
	
	FROM 
		T_TheCompany_KWS_6_ARB_ContractID_UNION  u /* product, company, description */

	group by 
		[ContractInternalID]


GO
/****** Object:  View [dbo].[V_TheCompany_Edit_MSA_NoDoc]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[V_TheCompany_Edit_MSA_NoDoc]

 as

	SELECT *
	FROM V_TheCompany_ALL
	WHERE 
		/* Mandatory conditions */
			(
				AGREEMENT_TYPEID = 1 /*MSA with work orders*/
				AND CONTRACTTYPEID NOT in(
					   '6' /* Access SAKSNR number Series*/
					,  '5' /* Test Old */
					,'102' /* Test New */
					, '13' /* DELETE */ 
					, '11' /* CASE */) 
				AND CONTRACTDATE > '2014-07-07 00:00:00'		
				AND NUMBEROFFILES > 0
				AND [TITLE] NOT LIKE '%NOT AVAILABLE%' 
				AND [TITLE] NOT LIKE '%IN ARIBA%' /* e.g. MSA filed in Ariba */
				AND [TITLE] not like '% MISSING%'
			)
			AND
			(/* TITLE indicates non-MSA */
				TITLE like '%- Services Agreement -%'

			/* No MSA Document attached */

			OR CONTRACTID not in 
				(SELECT OBJECTID
				FROM TDOCUMENT 
				WHERE 
					MIK_VALID = '1'
					AND 
						([DESCRIPTION] LIKE '%MASTER%' 
						OR [DESCRIPTION] LIKE '%FRAMEWORK%'
						OR [DESCRIPTION] LIKE '%FRAME %'
						OR [DESCRIPTION] LIKE '% CADRE %' /* French = Contrat Cadre */
						OR [DESCRIPTION] LIKE '%[^A-Z]MSA[^A-Z]%'
						OR [DESCRIPTION] LIKE '%[^A-Z]FSA[^A-Z]%'

						OR [DESCRIPTION] LIKE 'MSA[^A-Z]%'
						OR [DESCRIPTION] LIKE 'FSA[^A-Z]%'

						OR [DESCRIPTION] LIKE '%MSA%'
						OR [DESCRIPTION] LIKE '%FSA%'

						OR [DESCRIPTION] LIKE '%[^A-Z]M_SA[^A-Z]%' /* e.g. MLSA for master logistics services agreement */
						OR [DESCRIPTION] LIKE '%[^A-Z]F_SA[^A-Z]%' /* e.g. FLSA for master fw services agreement */

						OR [DESCRIPTION] LIKE '%RAHMEN%VERTRAG%'
						OR [DESCRIPTION] LIKE '%RAHMEN%VEREINBARUNG%'
						)
			)

		)

GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_MASTER_Products]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[V_TheCompany_LNC_Mig_MASTER_Products]

as

select
/*
select productgroupid from [dbo].[V_TheCompany_LNC_Mig_PRODUCTGROUPID_CONTRACTID]
where PRODUCTGROUPID not in (select productgroupid [V_TheCompany_LNC_Products])
*/
     		'CTK-' + convert(varchar(50),[PRODUCTGROUPID]) as [PRODUCTGROUPID_CTK]
		  ,[TN_or_AI]
		  ,[PRODUCTGROUP]
		  ,[PRODUCTGROUPCODE]
		  ,[PRODUCTGROUPNOMENCLATUREID]
		  ,[blnNumHashes]
		  ,[ProductGroup_IsUsed]
		  ,[Product_ContractCount]
		  ,[Product_ContractCountActive]
		  ,[ProductGroup_LEN]
		  ,[ProductGroup_MIK_VALID]
		  ,[PRODUCTGROUP_WITHHASH]
		  ,[PARENTID]
		  ,[ParentProductGroup]
 , GETDATE() as DateRefreshed
		from
			V_TheCompany_VPRODUCTGROUP_ALL_NOMENCLATURES
			/* V_TheCompany_VPRODUCTGROUP_TN_AI_INCL_INACTIVE */
	/*	WHERE [ProductGroup_MIK_VALID] = 1
			OR  [ProductGroup_IsUsed] = 1*/

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_ARB_Tag_ContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view

[dbo].[V_TheCompany_KWS_2_ARB_Tag_ContractID]
/* to do: include spaces with Productgroup name */
as 

	SELECT DISTINCT 
		s.*

		, t.tagcategory
		, t.contractinternalid as ContractID


	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		inner join  V_TheCompany_KWS__Ariba_TTAG_ContractID t
			on t.tag = s.KeyWordVarchar255 or t.tagcategory = s.KeyWordVarchar255
	WHERE 
		s.KeyWordType in ('Tag','TagCategory')


GO
/****** Object:  View [dbo].[V_TheCompany_VACL_FLAT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_VACL_FLAT]

as 

SELECT 
		OBJECTID

	/* group */
		, Replace(STUFF(
		(SELECT ';' + s.USERGROUP
		FROM V_TheCompany_VACL_Contract_ReadPrivilege s
		WHERE s.objectid =p1.objectid
		FOR XML PATH('')),1,1,''),'&amp;','&') 
	AS ACL_AllPermissions_GroupList

	/* user */
		, Replace(STUFF(
		(SELECT ';' + s.[DISPLAYNAME]
		FROM V_TheCompany_VACL_Contract_ReadPrivilege s
		WHERE s.objectid =p1.objectid
		FOR XML PATH('')),1,1,''),'&amp;','&') 
	AS ACL_AllPermissions_UserList

	/* group and user */
		, 'GROUPS: ' 
		+ Replace(STUFF(
		(SELECT ';' + s.USERGROUP
		FROM V_TheCompany_VACL_Contract_ReadPrivilege s
		WHERE s.objectid =p1.objectid
		FOR XML PATH('')),1,1,''),'&amp;','&') 
		+ ', USERS: ' 
		+ replace(STUFF(
		(SELECT ';' + s.[DISPLAYNAME]
		FROM V_TheCompany_VACL_Contract_ReadPrivilege s
		WHERE s.objectid =p1.objectid
		FOR XML PATH('')),1,1,''),'&amp;','&') 
	AS ACL_AllPermissions_GroupAndUserList

		, (SELECT COUNT(DISTINCT ACLID) as CountACLID
		FROM V_TheCompany_VACL_Contract_ReadPrivilege s
		WHERE s.objectid =p1.objectid
		and USERID is not null
		)
	AS ACL_UserPermissions_Count

		, (SELECT COUNT(DISTINCT ACLID) as CountACLID
		FROM V_TheCompany_VACL_Contract_ReadPrivilege s
		WHERE s.objectid =p1.objectid
		and USERGROUPID is not null
		)
	AS ACL_GroupPermissions_Count

		, (SELECT COUNT(DISTINCT ACLID) as CountACLID
		FROM V_TheCompany_VACL_Contract_ReadPrivilege s
		WHERE s.objectid =p1.objectid			
		)
	AS ACL_GroupAndUserPermissions_Count

  FROM V_TheCompany_VACL_Contract_ReadPrivilege p1
  /*  WHERE 
	OBJECTID = 148186 /* contractnumber = 'TEST-00000080' */ */
	/* AND OBJECTTYPEID = 1 *//* already filtered in the view, contract only, since LINC does not have separate document permissions */
  group by OBJECTID

GO
/****** Object:  View [dbo].[V_TheCompany_Hierarchy_MakeTable]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  view [dbo].[V_TheCompany_Hierarchy_MakeTable]

as
	/* daily refresh via procedure [dbo].[TheCompany_Scheduled_Daily] */

  SELECT 

   vBase.DEPARTMENTID as Departmentid_Link
  , vBase.[DPT_CODE_2Digit] as DptCode2Digit_Link
	, vBase.department_code as DepartmentCode_Link
      ,vBase.[DEPARTMENTID]
      ,vTTRegion.[LEVEL]
            
	,(CASE 
		WHEN vbase.L1 IN('GEM', 'EUCAN' /*,'UNITED STATES', 'JAPAN' */) THEN vBase.L1
		WHEN vTTRegion.L1 IN('GEM', 'EUCAN' /*,'UNITED STATES', 'JAPAN' */) THEN vTTRegion.L1 
		/* WHEN vBase.L0 ='Departments' THEN 'Departments' */
	    ELSE 'Other' END) as 'REGION' 
      ,CAST((CASE WHEN vTTRegion.L0 IS null then vBase.L0 else vTTRegion.L0 END) as varchar(25)) as 'L0'
      ,CAST((CASE WHEN vTTRegion.L1 IS null then vBase.L1 else vTTRegion.L1 END) as varchar(25)) as 'L1'
      ,CAST((CASE WHEN vTTRegion.L2 IS null then vBase.L2 else vTTRegion.L2 END) as varchar(25)) as 'L2'
      ,CAST((CASE WHEN vTTRegion.L3 IS null then vBase.L3 else vTTRegion.L3 END) as varchar(25)) as 'L3'
      ,CAST((CASE WHEN vTTRegion.L4 IS null then vBase.L4 else vTTRegion.L4 END) as varchar(25)) as 'L4'
      ,CAST((CASE WHEN vTTRegion.L5 IS null then vBase.L5 else vTTRegion.L5 END) as varchar(25)) as 'L5'
      ,CAST((CASE WHEN vTTRegion.L6 IS null then vBase.L6 else vTTRegion.L6 END) as varchar(25)) as 'L6'
      ,CAST ((CASE WHEN vTTRegion.L7 IS null then vBase.L7 else vTTRegion.L7 END) as varchar(25)) as 'L7'
      , cast(vTTRegion.[DEPARTMENT] as varchar(50)) as DEPARTMENT
      , cast(vTTRegion.[DEPARTMENT_CONCAT] as varchar(25)) as DEPARTMENT_CONCAT

      ,vTTRegion.[DPT_LOWEST_ID_TO_SHOW]
      ,vTTRegion.[DEPARTMENT_CODE] as DEPARTMENT_CODE_TTREGION
      , vBase.DEPARTMENT_CODE as DEPARTMENT_CODE
      , CAST( vBase.DEPARTMENT_CODE as varchar(50)) as DEPARTMENT_CODE_BASE
      ,vTTRegion.[DPT_CODE_2Digit_InternalPartner]
      ,vTTRegion.[DPT_CODE_2Digit_TerritoryRegion]
      ,vTTRegion.[DPT_CODE_2Digit]
      ,vTTRegion.[DPT_CODE_FirstChar]
      ,(CASE WHEN vTTRegion.[FieldCategory] IS null then vBase.[FieldCategory] else vTTRegion.[FieldCategory] END) 
	  as 'FieldCategory'
      ,(CASE WHEN vTTRegion.[NodeType] IS null then vBase.[NodeType] else vTTRegion.[NodeType] END) 
	  as 'NodeType'
      ,(CASE WHEN vTTRegion.[NodeMajorFlag] IS null then vBase.[NodeMajorFlag] else vTTRegion.[NodeMajorFlag] END)
	   as 'NodeMajorFlag'
	,vbase.NodeRole
      
      /*
      ,vTTRegion.[FieldCategory]
      ,vTTRegion.[NodeType]
      ,vTTRegion.[NodeMajorFlag] */
      ,vTTRegion.[PARENTID]
	  	  , left(vTTRegion.[L1] 
			+ (CASE WHEN vTTRegion.[L2]>'' THEN ' - ' + vTTRegion.[L2] ELSE '' END)
			+ (CASE WHEN vTTRegion.[L3]>'' THEN ' - ' + vTTRegion.[L3] ELSE '' END)
			+ (CASE WHEN vTTRegion.[L4]>'' THEN ' - ' + vTTRegion.[L4] ELSE '' END)
			+ (CASE WHEN vTTRegion.[L5]>'' THEN ' - ' + vTTRegion.[L5] ELSE '' END)
			+ (CASE WHEN vTTRegion.[L6]>'' THEN ' - ' + vTTRegion.[L6] ELSE '' END)
			+ (CASE WHEN vTTRegion.[L7]>'' THEN ' - ' + vTTRegion.[L7] ELSE '' END)
			,255)
			 as Dpt_Concat_List
		, d.DEPARTMENT as Parent_Department
  FROM V_TheCompany_Hierarchy vBase 
	left join   V_TheCompany_Hierarchy vTTRegion 
		on vBase.departmentid = vTTRegion.DEPARTMENTID /* 9-Dec swapped ttregion */
	left join TDEPARTMENT d on vBase.PARENTID = d.DEPARTMENTID
	/* on vBase.[DPT_CODE_2Digit_TerritoryRegion] = vTTRegion.[DPT_CODE_2Digit_TerritoryRegion]  9-Dec swapped ttregion */

	
GO
/****** Object:  View [dbo].[V_TheCompany_Mig_TTENDERER_Proc]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_Mig_TTENDERER_Proc]
as
select contractid as ContractIDKey, t.TENDERERID, c.*
from TTENDERER t inner join TCOMPANY c on t.COMPANYID = c.COMPANYid
where
contractid in (select contractid_Proc 
from  dbo.V_TheCompany_Mig_0ProcNetFlag
where Proc_NetFlag = 1)






GO
/****** Object:  View [dbo].[V_TheCompany_Mig_TCOMPANY_Proc]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_Mig_TCOMPANY_Proc]
as
select c.*, a.*
from TCOMPANY c inner join V_TheCompany_VCOMPANYADDRESS a on c.COMPANYID = a.companyid_Add
where
c.companyid in (select companyid 
from dbo.V_TheCompany_Mig_0ProcNetFlag p 
inner join TTENDERER t on p.Contractid_Proc = t.contractid
where Proc_NetFlag = 1)






GO
/****** Object:  View [dbo].[V_TheCompany_Mig_VPERSONROLE_IN_OBJECT_Proc]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view
[dbo].[V_TheCompany_Mig_VPERSONROLE_IN_OBJECT_Proc]
as
Select o.objectid as ContractIDKey, o.PERSONROLE_IN_OBJECTID , r.ROLEID
, r.ROLE, r.ISPERSONROLE, r.ISDEPARTMENTROLE, u.USERID, u.USERINITIAL, u.DISPLAYNAME, u.PERSONID, u.EMPLOYEEID, u.EMAIL
from TPERSONROLE_IN_OBJECT o 
inner join VUSER u
on o.Personid = u.personid inner join TROLE r on o.ROLEID = r.ROLEid
WHERE OBJECTID in (select contractid_Proc 
from dbo.V_TheCompany_Mig_0ProcNetFlag
where Proc_NetFlag = 1)




GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_ARB_Territories_ContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view

[dbo].[V_TheCompany_KWS_2_ARB_Territories_ContractID]
/* to do: include spaces with Productgroup name */
as 

	SELECT DISTINCT 
		s.*

		, i.ContractID

	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		inner join V_TheCompany_kws_0_TheVendorView_ARB i 
			/* Exact flag makes no sense since TT are concatenated */
			on i.[Territories] like  '%'+ s.KeyWordVarchar255 +'%'
	WHERE 
		s.KeyWordType = 'Territory'
		

GO
/****** Object:  View [dbo].[V_TheCompany_VProductGroupIsUsed]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View
[dbo].[V_TheCompany_VProductGroupIsUsed]

as 

	select p.productgroupid
	, p.PRODUCTGROUP
	, p.mik_valid
	, (CASE WHEN p.PRODUCTGROUPID IN(select PRODUCTGROUPID 
				from dbo.VPRODUCTGROUPS_IN_CONTRACT) THEN 1 ELSE 0 END) as IsUsed
	from tproductgroup p

GO
/****** Object:  View [dbo].[V_TheCompany_AgreementType_HasRecords]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view 
[dbo].[V_TheCompany_AgreementType_HasRecords]

as

	SELECT 
		*
	FROM V_TheCompany_AgreementType a
	where [AgrType_ContractCount] > 0 or AgrMikValid = 1

GO
/****** Object:  View [dbo].[V_TheCompany_AribaDump_Xt]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view  [dbo].[V_TheCompany_AribaDump_Xt]

as 

	select 
	
		* 
		, [dbo].[TheCompany_RemoveNonAlphaNonSpace]([Contracting Legal Entity]) 
		as ContractingLegalEntity_NoCC
		, left(ltrim([Contracting Legal Entity]),4) 
		as ContractingLegalEntity_CC_Only
	  FROM T_TheCompany_AribaDump

GO
/****** Object:  View [dbo].[V_TheCompany_AribaDump_Xt_Unique_CostCenter4Digit]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view 

[dbo].[V_TheCompany_AribaDump_Xt_Unique_CostCenter4Digit]

as

	select 
		convert(varchar(255),[ContractingLegalEntity_NoCC]) as ContractingLegalEntity_NoCC
		, [ContractingLegalEntity_CC_Only]
		, convert(varchar(255), dbo.TheCompany_RemoveNonAlphaCharacters([ContractingLegalEntity_NoCC]))
			as ContractingLegalEntity_NoCC_LettersOnly
		, count(*) as Count
	FROM
		[dbo].[V_TheCompany_AribaDump_Xt]
	group by 
		[ContractingLegalEntity_NoCC]
		, [ContractingLegalEntity_CC_Only]
GO
/****** Object:  View [dbo].[V_TheCompany_Dpts_UserRoles_Flat]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_Dpts_UserRoles_Flat]

as

SELECT top 9999
h.L0
, h.L1
, h.L2
, h.L3
, H.l4
, H.L5
, d.department
, d.departmentid
, d.MIK_VALId

/* SUPER USER List */
,STUFF(
(SELECT '; ' + u.DISPLAYNAME
FROM VUSER u
WHERE u.departmentid =d.departmentid 
AND u.userprofileid in (2 /* SU */,3 /*Legal Super User*/, 4 /*TheVendor support team */, 10 /* admin su */)
and u.USER_MIK_VALID = 1 and u.EMPLOYEE_MIK_VALID = 1
FOR XML PATH('')),1,1,'') AS Dpt_SuperUsers

/* SUPER USER Count */
,
(SELECT COUNT(*)
FROM VUSER u
WHERE u.departmentid =d.departmentid 
AND u.userprofileid in (2 /* SU */,3 /*Legal Super User*/, 4 /*TheVendor support team */, 10 /* admin su */)
and u.USER_MIK_VALID = 1 and u.EMPLOYEE_MIK_VALID = 1
Group By u.departmentid
) AS Dpt_SuperUsers_COUNT

/* Basic USER */
,STUFF(
(SELECT '; ' + u.DISPLAYNAME
FROM VUSER u
WHERE u.departmentid =d.departmentid AND u.userprofileid in (1 /* basic user */, 5,8 /* read all basic */)
and u.USER_MIK_VALID = 1 and u.EMPLOYEE_MIK_VALID = 1
FOR XML PATH('')),1,1,'') AS Dpt_BasicUsers

/* Active Contracts Count*/
,(SELECT COUNT(c.contractid)
FROM TCONTRACT c inner join TDEPARTMENTROLE_IN_OBJECT r on c.CONTRACTID = r.OBJECTID
WHERE r.DEPARTMENTID =d.departmentid 
Group by r.departmentid) AS Dpt_ContractList_Active_COUNT

/* Active Contracts */
,SUBSTRING(STUFF(
(SELECT '; ' + c.Contractnumber
FROM TCONTRACT c inner join TDEPARTMENTROLE_IN_OBJECT r on c.CONTRACTID = r.OBJECTID
WHERE r.DEPARTMENTID =d.departmentid 
FOR XML PATH('')),1,1,''),0,255) AS Dpt_ContractList_Active_255Char

/* Contracts Reg By */
,SUBSTRING(STUFF(
(SELECT '; ' + c.US_DisplayName +  ' ('+CONVERT(nvarchar(255),COUNT(c.contractid))+')'
FROM T_TheCompany_ALL c inner join TDEPARTMENTROLE_IN_OBJECT r on c.CONTRACTID = r.OBJECTID
WHERE r.DEPARTMENTID =d.departmentid 
Group By c.US_Userid, c.US_DisplayName
FOR XML PATH('')),1,1,''),0,255) AS Dpt_ContractRegisteredBySU

/* Registered last 12 months Contracts Count*/
,(SELECT COUNT(c.contractid)
FROM TCONTRACT c inner join TDEPARTMENTROLE_IN_OBJECT r on c.CONTRACTID = r.OBJECTID
WHERE r.DEPARTMENTID =d.departmentid 
and c.CONTRACTDATE between DATEADD(year,-1,getdate()) and GETDATE()
Group by r.departmentid) AS Dpt_ContractList_RegLast12Mon_COUNT

FROM V_TheCompany_Hierarchy h left join TDEPARTMENT d  
on h.departmentid = d.DEPARTMENTID
left join TUSERGROUP g on d.DEPARTMENTID = g.DEPARTMENTID
where
h.L0 in ('Departments','Territories - Region')
order by h.L0, h.L1, h.L2, H.L3, H.L4, H.L5



GO
/****** Object:  View [dbo].[V_TheCompany_KWS_8_TCOMPANY_summary_Keyword_gap]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_KWS_8_TCOMPANY_summary_Keyword_gap]
as

	select top 10000 
		s.KeyWordVarchar255
		, s.KeyWordVarchar255_UPPER
	/*	, s.KeyWordLettersNumbersSpacesOnly */

		, r.CompanyMatch_KeyWord_Upper
		, r.[CompanyMatch_NameList]
		, r.[Custom1_Lists_Max]
		, r.[Custom2_Lists_Max]
		/* , r.CompanyCount_Exact is 1 */
		, r.ContractCount_Exact	

		, r.CompanyCount
		, r.[ContractCount]

		, r.[CompanyMatch_Level_Min]

	from T_TheCompany_KeyWordSearch s 
		left join V_TheCompany_KWS_7_AllSystems_CompanyKWSummary_Final  r 
		on s.KeyWordVarchar255_UPPER = r.CompanyMatch_KeyWord_UPPER
		where s.KeyWordType = 'Company'
	order by s.KeyWordVarchar255 ASC

GO
/****** Object:  View [dbo].[V_TheCompany_LNC_zAgreementTypes]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_LNC_zAgreementTypes]

as

select TOP 100 percent * 
from
V_TheCompany_AgreementType_HasRecords
order by AgrMikValid desc
, AgrType_ContractCount desc

GO
/****** Object:  View [dbo].[V_TheCompany_Mig_TCONTRACT_ADDITONALFIELDS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view


[dbo].[V_TheCompany_Mig_TCONTRACT_ADDITONALFIELDS]
as

select c.CONTRACTID
, c.CONTRACTNUMBER
, c.[contract]
, c.COUNTERPARTYNUMBER
, c.CONTRACTSUMMARY
, c.REFERENCENUMBER
, cr.CONTRACTNUMBER as Contractnumber_LinkedToNumber
, c.REFERENCECONTRACTNUMBER
, c.COMMENTS
, c.TERMINATIONCONDITIONS
, c.TERMINATIONPERIOD
, l.LANGUAGEID
, l.MIK_LANGUAGE /* table only has 15 languages or so, remainder not set up */
, s.[CQSUMMARYBODY] as HEADING /* removed in V6.15.*/
, s.INGRESS
, s.SUMMARYBODY
, f.*
, (CASE WHEN c.comments is not null then c.comments else '' END) + CHAR(13)+CHAR(10) /* CARRIAGE RETURN */ +
		(CASE WHEN c.REFERENCENUMBER >'' then 
		'Reference Number: ' + c.REFERENCENUMBER + CHAR(13)+CHAR(10) else '' END) + 
		(CASE WHEN c.COUNTERPARTYNUMBER >'' then 
		'Counterparty Number: ' + c.COUNTERPARTYNUMBER + CHAR(13)+CHAR(10) else '' END) 	
	AS Comments_Concatenated
from dbo.TCONTRACT c
	left join TCONTRACT cr on c.REFERENCECONTRACTID = cr.contractid
	inner join dbo.V_TheCompany_Mig_0ProcNetFlag p on c.Contractid = p.Contractid_Proc 
	left join TLANGUAGE l on c.LANGUAGEID = l.LANGUAGEID
	left join TCONTRACTSUMMARY s on c.CONTRACTID = s.CONTRACTID
	left join dbo.V_TheCompany_VPRODUCTS_FLAT f on c.CONTRACTID = f.VP_Contractid
where p.Proc_NetFlag = 1



GO
/****** Object:  View [dbo].[V_TheCompany_FullText_ChangeOfControl]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_FullText_ChangeOfControl]

as

	SELECT 'change of control' as txt_kwd, 1 as Relevance,
	t.* FROM [V_SEARCHENGINE_SEARCHSIMPLEDOCUMENT] t  INNER JOIN TFILE 
	ON TFILE.FileId = t.FileId 
	WHERE t.FileType = '.pdf'
	AND TFILE.FileId IN (SELECT KEY_TBL.[KEY] 
							FROM CONTAINSTABLE(TFILE, [File], '"change of control"' ) 
							AS KEY_TBL) 
							AND (t.MIKVALID = N'1') 

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_LNC_InternalPartner_ContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view

[dbo].[V_TheCompany_KWS_2_LNC_InternalPartner_ContractID]
/* to do: include spaces with Productgroup name */
as 

	SELECT DISTINCT 
		s.KeyWordVarchar255
		, s.KeyWordVarchar255_UPPER
		, s.KeyWordPrecision
		, s.[KeyWordCustom1]
		, s.[KeyWordCustom2]
		, s.KeyWordSource
		/* , s.KeyWordLettersNumbersSpacesOnly */
		/* , s.KeyWord_ExclusionFlag */

		, t.[Internal Partners]   as InternalPartners
		, t.CONTRACTID

	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		inner join V_TheCompany_KWS_0_TheVendorView_LNC t 
			on upper(t.[Internal Partners])   LIKE 
				(CASE WHEN keywordprecision = 'EXACT' THEN
					upper(s.KeyWordVarchar255)
					ELSE
					'%'+ s.KeyWordVarchar255 +'%'
					END)
	WHERE 
		s.KeyWordType = 'InternalPartner'
GO
/****** Object:  View [dbo].[V_TheCompany_TheVendorTablesColumns_Migration]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[V_TheCompany_TheVendorTablesColumns_Migration]

as 

	select  
	[TableViewName]
		, t.[TblVwComments]
      ,vc.[ColumnName]
      ,[ColComment] as ColumnComment
	  	,  [ValueTop1] AS ValueMaxValueTruncVarchar255
		, [ValueGoldStd] as ValueGoldStdConcatVarchar255
      ,[DATA_TYPE]
      ,[CHAR_MAX_LEN]
      ,[NUM_PRECISION]
      ,[NUM_SCALE]
      ,[is_nullable]
      ,[is_identity]
      ,[FK_TableName]
      ,[FK_TableColName]
      ,[ObjectID]
     /* ,[TableObjectID] */
      ,[ColumnID]
	  , Col_ID
     , convert(varchar,t.TblVwObjectID) + '_'+ convert(varchar,vc.columnid) as TblColUniqueID

/* Column table */

     /* ,[TableName]
      ,[ColumnName] */
      ,[MigrateYN] as ColMigrateYN
    /*  ,[TVObjectID]
      ,[TVColumnID] */
      ,[IsBlank]


	  /* Tables */
	/*, t.[TblVwObjectID]
      ,t.[TblVwName] */
	, t.[TblVwBaseTableName]
	, t.[TblVwRelationship]
      ,[TableOrView]
	from T_TheCompany_TheVendorTablesColumns  c 
	inner join [dbo].[T_TheCompany_TheVendorTables] t 
		on t.[TblVwObjectID] = c.[TVObjectID]
	inner join [dbo].[V_TheCompany_TheVendorTablesColumns] vc
		on c.[TVObjectID] = vc.[ObjectID]
			AND c.[TVColumnID] = vc.[ColumnID]


GO
/****** Object:  View [dbo].[VCONTRACT_PERSONROLES]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  VIEW [dbo].[VCONTRACT_PERSONROLES] AS
SELECT     TOP 100 PERCENT dbo.TCONTRACTRELATION.FIXED AS ContractRelationFIXED, dbo.TCONTRACT.CONTRACTNUMBER AS Number, 
                      dbo.TCONTRACT.CONTRACT AS Title, dbo.TCONTRACT.STARTDATE, dbo.TCONTRACT.EXPIRYDATE, 
                      dbo.TCONTRACT.REV_EXPIRYDATE AS RevisedExpiryDate, dbo.TSTATUS.STATUS, 
                      dbo.TCONTRACTRELATION.CONTRACTRELATION AS ContractRelations, dbo.TCONTRACTTYPE.CONTRACTTYPE, dbo.TCONTRACT.AWARDDATE, 
                      dbo.TCONTRACT.CHECKEDOUTDATE, TPERSON_1.DISPLAYNAME AS CheckedOutBy, TPERSON_1.DISPLAYNAME AS Executor, 
                      dbo.TCONTRACT.EXECUTORID, dbo.TCONTRACT.CHECKEDOUTBY AS CheckedOutByUserId, dbo.TCONTRACT.STATUSID, 
                      dbo.TSTATUS.FIXED AS StatusFixed, dbo.TSTATUS_IN_OBJECTTYPE.MIK_SEQUENCE AS StatusMikSequence, 
                      dbo.TAGREEMENT_TYPE.AGREEMENT_TYPE
					  , (SELECT AwardedCompanyNames from [dbo].[TVF_GetContractAwardedCompanyNames](dbo.TCONTRACT.CONTRACTID)) AS 'COMPANY'
					  , dbo.TCOUNTRY.COUNTRY, 
                      dbo.TADDRESSTYPE.FIXED AS AddressTypeFIXED, TUSER_2.USERID, dbo.TCOMPANY.COMPANYID, dbo.TCONTRACT.CONTRACTID,
                          (SELECT     MAX(A.AUDITTRAILID)
                            FROM          TAUDITTRAIL A, TOBJECTTYPE O10
                            WHERE      A.OBJECTTYPEID = O10.OBJECTTYPEID AND O10.FIXED = 'CONTRACT' AND A.OBJECTID = dbo.TCONTRACT.CONTRACTID) 
                      AS AUDITTRAILID, dbo.TSTRATEGYTYPE.STRATEGYTYPE AS Method, dbo.TSTRATEGYTYPE.FIXED AS MethodFIXED, 
                      TPERSON_2.FIRSTNAME AS CCFirstName, TPERSON_2.MIDDLENAME AS CCMiddleName, TPERSON_2.LASTNAME AS CCLastName, 
                      TPERSON_2.PHONE1 AS CCPhone1, TPERSON_2.PHONE2 AS CCPhone2, dbo.TCONTRACT.REFERENCECONTRACTNUMBER, 
                      dbo.TCONTRACT.COUNTERPARTYNUMBER, TPERSON_2.DISPLAYNAME AS CCDisplayName, dbo.TROLE.ROLE, dbo.TROLE.FIXED AS ROLE_FIXED, 
                      dbo.TPERSONROLE_IN_OBJECT.PERSONID AS ROLE_PERSONID, dbo.TPERSONROLE_IN_OBJECT.ROLEID, 
                      TPERSON_3.DISPLAYNAME AS ROLE_DISPLAYNAME, TSTATUS_1.STATUS AS ApprovalStatus, dbo.TCONTRACT.PUBLISH, dbo.TCONTRACT.SHAREDWITHSUPPLIER
FROM         dbo.TAGREEMENT_TYPE RIGHT OUTER JOIN
                      dbo.TCONTRACTRELATION RIGHT OUTER JOIN
                      dbo.TCONTRACT INNER JOIN
                      dbo.TPERSONROLE_IN_OBJECT INNER JOIN
                      dbo.TROLE ON dbo.TPERSONROLE_IN_OBJECT.ROLEID = dbo.TROLE.ROLEID INNER JOIN
                      dbo.TOBJECTTYPE ON dbo.TPERSONROLE_IN_OBJECT.OBJECTTYPEID = dbo.TOBJECTTYPE.OBJECTTYPEID ON 
                      dbo.TCONTRACT.CONTRACTID = dbo.TPERSONROLE_IN_OBJECT.OBJECTID INNER JOIN
                      dbo.TSTATUS_IN_OBJECTTYPE ON dbo.TOBJECTTYPE.OBJECTTYPEID = dbo.TSTATUS_IN_OBJECTTYPE.OBJECTTYPEID INNER JOIN
                      dbo.TSTATUS ON dbo.TSTATUS_IN_OBJECTTYPE.STATUSID = dbo.TSTATUS.STATUSID AND 
                      dbo.TCONTRACT.STATUSID = dbo.TSTATUS.STATUSID LEFT OUTER JOIN
                      dbo.TCOMPANY LEFT OUTER JOIN
                      dbo.TCOUNTRY RIGHT OUTER JOIN
                      dbo.TCOMPANYADDRESS INNER JOIN
                      dbo.TADDRESSTYPE ON dbo.TCOMPANYADDRESS.ADDRESSTYPEID = dbo.TADDRESSTYPE.ADDRESSTYPEID AND 
                      dbo.TADDRESSTYPE.FIXED = 'MAINADDRESS' ON dbo.TCOUNTRY.COUNTRYID = dbo.TCOMPANYADDRESS.COUNTRYID ON 
                      dbo.TCOMPANY.COMPANYID = dbo.TCOMPANYADDRESS.COMPANYID ON 
                      dbo.TCOMPANY.COMPANYID = dbo.udf_get_companyid(dbo.TCONTRACT.CONTRACTID)
					  LEFT OUTER JOIN
                      dbo.TCONTRACTTYPE ON dbo.TCONTRACT.CONTRACTTYPEID = dbo.TCONTRACTTYPE.CONTRACTTYPEID LEFT OUTER JOIN
                      dbo.TSTRATEGYTYPE ON dbo.TCONTRACT.STRATEGYTYPEID = dbo.TSTRATEGYTYPE.STRATEGYTYPEID ON 
                      dbo.TCONTRACTRELATION.CONTRACTRELATIONID = dbo.TCONTRACT.CONTRACTRELATIONID ON 
                      dbo.TAGREEMENT_TYPE.AGREEMENT_TYPEID = dbo.TCONTRACT.AGREEMENT_TYPEID LEFT OUTER JOIN
                      dbo.TOBJECTTYPE TOBJECTTYPE_1 INNER JOIN
                      dbo.TAPPROVALSTATUS_IN_OBJECTTYPE INNER JOIN
                      dbo.TSTATUS TSTATUS_1 ON dbo.TAPPROVALSTATUS_IN_OBJECTTYPE.APPROVALSTATUSID = TSTATUS_1.STATUSID ON 
                      TOBJECTTYPE_1.OBJECTTYPEID = dbo.TAPPROVALSTATUS_IN_OBJECTTYPE.OBJECTTYPEID AND TOBJECTTYPE_1.FIXED = N'CONTRACT' ON 
                      dbo.TCONTRACT.APPROVALSTATUSID = TSTATUS_1.STATUSID FULL OUTER JOIN
                      dbo.TPERSON TPERSON_3 ON dbo.TPERSONROLE_IN_OBJECT.PERSONID = TPERSON_3.PERSONID FULL OUTER JOIN
                      dbo.TUSER TUSER_1 FULL OUTER JOIN
                      dbo.TPERSON TPERSON_1 FULL OUTER JOIN
                      dbo.TEMPLOYEE TEMPLOYEE_1 ON TPERSON_1.PERSONID = TEMPLOYEE_1.PERSONID ON 
                      TUSER_1.EMPLOYEEID = TEMPLOYEE_1.EMPLOYEEID ON dbo.TCONTRACT.CHECKEDOUTBY = TUSER_1.USERID FULL OUTER JOIN
                      dbo.TUSER TUSER_2 FULL OUTER JOIN
                      dbo.TPERSON TPERSON_2 FULL OUTER JOIN
                      dbo.TEMPLOYEE TEMPLOYEE_2 ON TPERSON_2.PERSONID = TEMPLOYEE_2.PERSONID ON 
                      TUSER_2.EMPLOYEEID = TEMPLOYEE_2.EMPLOYEEID ON dbo.TCONTRACT.EXECUTORID = TUSER_2.USERID
WHERE     (dbo.TOBJECTTYPE.FIXED = N'CONTRACT')
ORDER BY dbo.TCONTRACT.CONTRACTID

GO
/****** Object:  View [dbo].[V_TheCompany_EDIT_TCONTRACT_EXECUTOR_OWNER_COORD_ID_Update]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_EDIT_TCONTRACT_EXECUTOR_OWNER_COORD_ID_Update]

as

SELECT	'EXECUTORID' AS UpdateFld, C.CONTRACTID,c.CONTRACTNUMBER,V.ROLE_FIXED,V.ROLE_PERSONID,PEXEC.PERSONID,C.CONTRACTDATE,vu.userid as KeyUserField
FROM	TCONTRACT	C
JOIN	VCONTRACT_PERSONROLES	V
	ON	V.CONTRACTID = C.CONTRACTID
LEFT JOIN	TUSER	UEXEC
	ON	UEXEC.USERID = C.EXECUTORID
LEFT JOIN	TEMPLOYEE	EEXEC
	ON	EEXEC.EMPLOYEEID = UEXEC.EMPLOYEEID
LEFT JOIN	TPERSON	PEXEC
	ON	PEXEC.PERSONID = EEXEC.PERSONID
	INNER JOIN VUSER vu on V.ROLE_PERSONID = vu.personid
WHERE	V.ROLE_FIXED = 'COMMERCIAL_CO_ORDINATOR'
	AND	(PEXEC.PERSONID != V.ROLE_PERSONID  OR PEXEC.PERSONID IS NULL)

UNION ALL

SELECT	'OWNERID' AS UpdateFld, C.CONTRACTID, C.CONTRACTNUMBER,V.ROLE_FIXED,V.ROLE_PERSONID,POWNER.PERSONID,C.CONTRACTDATE,vu.EMPLOYEEID as KeyUserField
FROM	TCONTRACT	C
JOIN	VCONTRACT_PERSONROLES	V
	ON	V.CONTRACTID = C.CONTRACTID

LEFT JOIN	TEMPLOYEE	EOWNER
	ON	EOWNER.EMPLOYEEID = C.OWNERID
LEFT JOIN	TPERSON	POWNER
	ON	POWNER.PERSONID = EOWNER.PERSONID
	INNER JOIN VUSER vu on V.ROLE_PERSONID = vu.personid
WHERE	V.ROLE_FIXED = 'BUDGET_OWNER'
	AND (POWNER.PERSONID != V.ROLE_PERSONID OR POWNER.PERSONID IS NULL)

UNION ALL

SELECT	'TECHCOORDINATORID' AS UpdateFld, C.CONTRACTID, C.CONTRACTNUMBER,V.ROLE_FIXED,V.ROLE_PERSONID,PTECH.PERSONID,C.CONTRACTDATE,vu.EMPLOYEEID as KeyUserField
FROM	TCONTRACT	C
JOIN	VCONTRACT_PERSONROLES	V
	ON	V.CONTRACTID = C.CONTRACTID

LEFT JOIN	TEMPLOYEE	ETECH
	ON	ETECH.EMPLOYEEID = C.TECHCOORDINATORID
LEFT JOIN	TPERSON	PTECH
	ON	PTECH.PERSONID = ETECH.PERSONID
	INNER JOIN VUSER vu on V.ROLE_PERSONID = vu.personid
WHERE	V.ROLE_FIXED = 'TECHNICAL_CO_ORDINATOR'
	AND (PTECH.PERSONID != V.ROLE_PERSONID OR PTECH.PERSONID IS NULL)
GO
/****** Object:  View [dbo].[V_TheCompany_Mig_VDEPARTMENT_VUSERGROUP_Proc]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view
[dbo].[V_TheCompany_Mig_VDEPARTMENT_VUSERGROUP_Proc]
as
Select 
h.[LEVEL]
      ,h.[L0]
      ,h.[L1]
      ,h.[L2]
      ,h.[L3]
      ,h.[L4]
      ,h.[L5]
      ,h.[L6]
      ,h.[L7]
      ,h.[DEPARTMENT]
      ,h.[DEPARTMENT_CONCAT]
      ,h.[DPT_LOWEST_ID_TO_SHOW]
      ,h.[DEPARTMENT_CODE]
      ,h.[DPT_CODE_2Digit_InternalPartner]
      ,h.[DPT_CODE_2Digit_TerritoryRegion]
      ,h.[DPT_CODE_2Digit]
      ,h.[DPT_CODE_FirstChar]
      ,h.[FieldCategory]
      ,h.[NodeType]
      ,h.[NodeRole]
      ,h.[NodeMajorFlag]
      ,h.[PARENTID]

, d.DEPARTMENT as DPT_NAME, d.MIK_VALID as Dtp_MIK_VALID
, g.* 
from TDEPARTMENT d inner join TUSERGROUP g on d.DEPARTMENTid = g.DEPARTMENTID
inner join dbo.V_TheCompany_Hierarchy h on d.DEPARTMENTID = h.DEPARTMENTID
where d.departmentid in (select departmentid from dbo.Tdepartmentrole_IN_OBJECT
where OBJECTID in (select contractid_Proc 
from  dbo.V_TheCompany_Mig_0ProcNetFlag
where Proc_NetFlag = 1)
)




GO
/****** Object:  View [dbo].[V_TheCompany_KWS_5c_CNT_DESCRIPTION_ContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view 
[dbo].[V_TheCompany_KWS_5c_CNT_DESCRIPTION_ContractID]

as 

	SELECT  DISTINCT
		s.KeyWordVarchar255 as DescriptionKeyword
		, s.KeyWordType
		, /*(case when */ p.CONTRACTID /* IS not  null then p.contractid else t.objectid  END)*/ as CONTRACTID
		, /*(case  when p.contractid IS not null and t.objectid IS not null then 1 - tag removed 
			when p.contractid IS not null and t.objectid IS null then 2
			when p.contractid IS null and t.objectid IS not null then 3
			end) */ 'N/A' as Src_ContractTitleOrFile
	FROM [V_TheCompany_KeyWordSearch] s 
		left join t_TheCompany_all p /* was left join leading to empty contract ids */
			on p.Title like 
				(CASE WHEN s.KeyWordLength < 4 THEN
				 '%[^a-z]'+s.KeyWordVarchar255+'[^a-z]%'
				 ELSE
				 '%'+s.KeyWordVarchar255+'%'
				 END)
		
	/*	left join V_TheCompany_TTag_Detail t
			on t.tagcategory = s.KeyWordVarchar255 /* , td.TagCategory = Privacy Shield Remediation */ removed may 21 - separate tag query */
			
WHERE CONTRACTID is not null
		AND
			s.KeyWordVarchar255 not in (
				select KeyWordVarchar255 from T_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended) /* avoid ACCENTURE (Company);  Accenture (Desc) */
		AND s.KeyWordVarchar255 not in (
				select KeyWordVarchar255 from T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended)
		AND s.KeyWordVarchar255 not in (
				select KeyWordVarchar255 from T_TheCompany_KWS_2_CNT_InternalPartner_ContractID)
		AND s.KeyWordVarchar255 not in (
				select KeyWordVarchar255 from T_TheCompany_KWS_2_CNT_Territories_ContractID)
		AND s.KeyWordVarchar255 not in (
				select KeyWordVarchar255 from T_TheCompany_KWS_2_CNT_TCOMPANYCountry_ContractID)
		AND s.KeyWordVarchar255 not in (
				select KeyWordVarchar255 from T_TheCompany_KWS_2_CNT_Tag_ContractID)
		
		
GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_DATA_COMPANY_TTENDERER_CONTRACTID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_LNC_Mig_DATA_COMPANY_TTENDERER_CONTRACTID]

as

	SELECT 
		'CTK-' + ltrim(str([Contractid_TT])) as CTK_CONTRACTID
		, [CompanyID_tt] as COMPANYID
 		, RowNoPartitionByCONTRACTID_OrderByTENDERERID
		  ,COMPANY_TT as [COMPANY]
		  , Strategytype_IsHcpHCO_1_0_NULL
		 , GETDATE() as DateRefreshed
		 , c.Number
		 , a.ContractTitle
		 , a.[CompanyType]
		 , c.CompanyList
		 , c.NUMBEROFFILES as DocumentCount

	  FROM [TheVendor_app].[dbo].[v_TheCompany_TTENDERER_CompanyAddress_Primary] a
		inner join [dbo].[V_TheCompany_LNC_GoldStandard] g on a.Contractid_TT = g.CONTRACTID
		inner join T_TheCompany_All c on a.contractid_tt = c.contractid
		/* WHERE RowNoPartitionByCONTRACTID_OrderByTENDERERID in (1,2) /* more than 2 not possible */*/

GO
/****** Object:  View [dbo].[V_TheCompany_Personroles_VarianceTcontractVContract_Personroles]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_Personroles_VarianceTcontractVContract_Personroles]

as

select a.CONTRACTID
, a.executorid
, ue.USERID

, a.OWNERID
, uo.EMPLOYEEID as UO_Employeeid

,a.TECHCOORDINATORID  
, ur.EMPLOYEEID as UE_EMPLOYEEID
/* super user */
	,ue.DISPLAYNAME as UE_Displayname
	, pe.ROLE_DISPLAYNAME as UE_ROLE_DISPLAYNAME
	, ue.personid as UE_PERSONID
	, pe.ROLE_PERSONID as UE_ROLE_PERSONID
/* owner */
	, uo.DISPLAYNAME as UO_Displayname
	, po.ROLE_DISPLAYNAME as UO_ROLE_DISPLAYNAME
	, uo.PERSONID as UO_PERSONID
	, po.ROLE_PERSONID as UO_ROLE_PERSONID
/* responsible */
	, ur.DISPLAYNAME as UR_Displayname
	, pr.ROLE_DISPLAYNAME as UR_ROLE_DISPLAYNAME
	, ur.PERSONID as UR_PERSONID
	, pr.ROLE_PERSONID as UR_ROLE_PERSONID
from tcontract a
left join VUSER ue on a.EXECUTORID = ue.userid
left join VUSER uo on a.OWNERID = uo.EMPLOYEEID
left join VUSER ur on a.TECHCOORDINATORID = ur.EMPLOYEEID
left join VCONTRACT_personroles pe on (a.contractid = pe.contractid and pe.ROLEID = 1 /* SU */)
left join VCONTRACT_personroles po on (a.contractid = po.contractid and po.ROLEID = 2)
left join VCONTRACT_personroles pr on (a.contractid = pr.contractid and pr.ROLEID = 15)
/* where a.CONTRACTNUMBER = 'Contract-11126054' */
WHERE ue.PERSONID = pe.role_personid
OR uo.personid <> po.role_personid
OR ur.personid  <> pr.role_personid
GO
/****** Object:  View [dbo].[V_TheCompany_TTENDERER_CONTRACT_COUNT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[V_TheCompany_TTENDERER_CONTRACT_COUNT]

as

	SELECT 
		t.companyid as Companyid_TT
		/*,v.company*/

		, count(case when c.statusid = 5 then null else c.contractid end) 
		as Contract_Count_Active

		, count(c.contractid) as Contract_Count
		, min(CONTRACTNUMBER) as Sample_ContractNumber_Min
		, max(CONTRACTNUMBER) as Sample_ContractNumber_Max

	FROM  TTENDERER t 
		inner join tcontract c 
			on t.contractid = c.contractid 
	/*	left join [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_ValidMatchedCompanies] s
			on t.COMPANYID = s.Sup_COMPANYID */
	GROUP BY t.companyid

GO
/****** Object:  View [dbo].[V_TheCompany_VCOMPANY_LettersNumbers]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_VCOMPANY_LettersNumbers]

/* 
[dbo].[TheCompany_KeyWordSearch]
- elminiate double spaces
- ltrim, rtrim
*/
as
	select 
		COMPANYID as companyid_LN
		/* , COMPANY */
		, MIK_VALID

		, UPPER(dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([COMPANY]))
		as Company_LettersNumbersOnly_UPPER

		, UPPER(replace(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([COMPANY]),'  ',' '))
		as Company_LettersNumbersSpacesOnly_UPPER /* e.g. Hansen & Rosenthal */

		, LEN(replace(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([COMPANY]),'  ',' '))
			- LEN(dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([COMPANY])) 
			as Company_LettersNumbersOnly_NumSpacesWords

	/*	, [dbo].[TheCompany_CompanyOrIndividual]([COMPANY]) AS CompanyType */

	from TCOMPANY
	/* where [KeyWordVarchar255] like 'Si%' */
	/* where dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([KeyWordVarchar255]) like '%  %' */

GO
/****** Object:  View [dbo].[V_TheCompany_VCOMPANY]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_VCOMPANY]
/* refreshed daily and via key words script on demand TheCompany_Company_Search */
as

	select 
		c.*
		, tc.COMPANY
		, (case when tc.EXTERNALNUMBER >'' or tc.ISVENDOR = 1 THEN 'C' /* company */
			/* when tc.ISVENDOR = 1 then 'T' */
			ELSE
			[dbo].[TheCompany_CompanyOrIndividual](tc.company) END) AS CompanyType
		, [dbo].[TheCompany_CompanyOrIndividual](tc.company) as CompanyType_unchanged
		, left(company,50) as Company_50Char
		, UPPER(left([COMPANY],50)) as Company_UPPER
		, a.COUNTRYID
		, a.COUNTRY
		, a.Country_IsUS
		
		, (CASE WHEN (COMPANYID IN (select companyid from TTENDERER) )
							THEN 1 ELSE 0 END) as TendererIDExists
			/* , dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(c.COMPANY) 
		as CompanyName_RemoveNonAlphaNonNumericChar /* leave numbers, e.g. 3M */ */

		, len([COMPANY]) as Company_LEN
		, LEN(dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(COMPANY)) 
		as Company_LettersNumbersOnly_LEN

		/*	, SUBSTRING(Company_LettersNumbersSpacesOnly,1,(CHARINDEX(' ',Company_LettersNumbersSpacesOnly + ' ')-1)) 
		as Company_FirstWord */
			, UPPER([dbo].[TheCompany_GetFirstWordInString](Company_LettersNumbersSpacesOnly_UPPER))
		as Company_FirstWord_UPPER

	/*		,SUBSTRING([Company_LettersNumbersOnly],1,(CHARINDEX(' ',[Company_LettersNumbersOnly] + ' ')-1))
		as Company_FirstWord_LettersOnly */
			,UPPER( [dbo].[TheCompany_GetFirstWordInString]([Company_LettersNumbersOnly_UPPER]))
		as Company_FirstWord_LettersOnly_UPPER

			, LEN([dbo].[TheCompany_GetFirstWordInString]([Company])) 
		as Company_FirstWord_LEN

		/* two words or more */
		, UPPER((CASE WHEN [Company_LettersNumbersOnly_NumSpacesWords] = 1 
					THEN [Company_LettersNumbersSpacesOnly_UPPER] /* one space */
				WHEN Company_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN SUBSTRING([Company_LettersNumbersSpacesOnly_UPPER],0,CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
						CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
									   CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],+1)+1)) )	/* e.g. SI Group */	
				ELSE NULL /* no space */ END)		)	
		as Company_FirstTwoWords_UPPER

		, UPPER((CASE WHEN [Company_LettersNumbersOnly_NumSpacesWords] = 1 /* two words, one space */
					THEN [Company_LettersNumbersOnly_UPPER]
				WHEN Company_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(SUBSTRING([Company_LettersNumbersSpacesOnly_UPPER],0,CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
						CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
									   CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],+1)+1)) ))	/* e.g. SI Group */	
				ELSE NULL /* no space */ END))			
		as Company_FirstTwoWords_LettersOnly_UPPER

			,  LEN((CASE WHEN [Company_LettersNumbersOnly_NumSpacesWords] = 1 /* two words, one space */
					THEN [Company_LettersNumbersOnly_UPPER]
				WHEN Company_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(SUBSTRING([Company_LettersNumbersSpacesOnly_UPPER],0,CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
						CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
									   CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],+1)+1)) ))	/* e.g. SI Group */	
				ELSE NULL /* no space */ END)	)	
		as Company_FirstTwoWords_LettersOnly_LEN

		, UPPER((CASE WHEN LEN(dbo.TheCompany_GetFirstLetterOfEachWord([Company_LettersNumbersSpacesOnly_UPPER])) >=3 
			/* AND c.CompanyType = 'C' */ THEN 
				/* dbo.TheCompany_GetFirstLetterOfEachWord([Company_LettersNumbersOnly])
			WHEN LEN(dbo.TheCompany_GetFirstLetterOfEachWord([Company_LettersNumbersOnly]))<3 
				and len(left([[Company_LettersNumbersOnly],3)) >=3 THEN */
				left([Company_LettersNumbersOnly_UPPER],3)
			ELSE 'N/A' /*c.CompanyType */ END
			))
			as Company_FirstLetterOfEachWord_UPPER
/* tenderer address */
		, A.email as CompanyEmail

		, (case when companyid = 1 /* Intercompany */
				then 'N/A' else s.[SupID_SAP] end) 
				as [Company_SAP_ID]
		, (case when companyid = 1 /* Intercompany */
				then 'N/A - INTERCOMPANY TheCompany' else s.[SupName_SAP] end) 
				as [Company_SAP_NAME]

		, a.[CtyCode2Letter]

		, cc.PrimaryCompanyContact_EmailAddressList as CompanyPrimaryContactEmailAddressList
		, tt.Contract_Count
		, tt.Contract_Count_Active
		, TT.Sample_ContractNumber_Min
		, TT.Sample_ContractNumber_Max

		/*, tc.[EXTERNALNUMBER] as Company_SAP_ID /* SAP number like Fette GmbH = 0000264881 */*/
		, tc.COMPANYNO /* select * from TCOMPANY where companyno >'' /* 2027 rows */ */
		, tc.DUNSNUMBER

		, tc.ISINTERNAL
		, tc.ISCUSTOMER
		, tc.ISPARTNER
		, tc.ISVENDOR
	from tcompany tc
		inner join V_TheCompany_VCOMPANY_LettersNumbers c /* uses TCOMPANY */
			on tc.COMPANYID = c.companyid_ln
		/* prerequisite is that every company has address */
		inner join [V_TheCompany_VCOMPANYADDRESS_PrimaryAddress] a /* [dbo].[v_TheCompany_TTENDERER_CompanyAddress_Primary] has dupe company id /* Primary Address = 1 */ a */
			on tc.COMPANYID = a.companyid_Add
		left join V_TheCompany_VCOMPANY_Contact_GroupByCompanyID cc
			on tc.COMPANYID = cc.companyid_cc
		left join [V_TheCompany_TTENDERER_CONTRACT_COUNT] tt
			on tc.COMPANYID = tt.companyid_tt
		left join [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_ValidMatchedCompanies] s
			 on tc.companyid = s.[Sup_COMPANYID]
	WHERE c.MIK_VALID = 1 /* and company = 'Svedberg, Agneta' */
	or c.companyid_LN in (select COMPANYID from TTENDERER) /* for migration and older contracts */

GO
/****** Object:  View [dbo].[V_TheCompany_VDEPARTMENTROLE_IN_OBJECT_xt_CountDptRoles]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view

[dbo].[V_TheCompany_VDEPARTMENTROLE_IN_OBJECT_xt_CountDptRoles]

as

select 
[OBJECTID]
, [Roleid_TT_IP_or_US_UO_UR]
, count(distinct departmentid) as CountDptID
, count([DEPARTMENTROLE_IN_OBJECTID]) as countID
from 
[dbo].[V_TheCompany_VDEPARTMENTROLE_IN_OBJECT_xt]
where
/* [Roleid_Cat2Letter] = 'DP' and  */
[Roleid_TT_IP_or_US_UO_UR] = 'P'
group by OBJECTID, [Roleid_TT_IP_or_US_UO_UR]
GO
/****** Object:  View [dbo].[V_TheCompany_EDIT_DocusignFullTextScannedFiles]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_EDIT_DocusignFullTextScannedFiles]

as

select * from [dbo].[T_TheCompany_EDIT_DocusignFullTextScannedFiles] e inner join VDOCUMENT d on e.file_name = d.FileID
GO
/****** Object:  View [dbo].[V_TheCompany_VCompare_Results_zFullJoin]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View [dbo].[V_TheCompany_VCompare_Results_zFullJoin]

as

	select distinct
	(CASE WHEN Name1_LettersNumbersSpacesOnly >'' AND Name2_LettersNumbersSpacesOnly >'' THEN 'Name1AndName2'
		WHEN Name1_LettersNumbersSpacesOnly >'' AND Name2_LettersNumbersSpacesOnly IS null then 'Name2'
		WHEN Name2_LettersNumbersSpacesOnly >'' AND Name1_LettersNumbersSpacesOnly IS null then 'Name1'
		ELSE 'OTHER' 
		END) as MatchLevel
		, 'Exact' as MatchKind
		, Name1
		, Name2
		, [Name1_FirstWord]
		, [Name2_FirstWord]
		,  [Name1_LettersNumbersSpacesOnly] 
		,  [Name2_LettersNumbersSpacesOnly] 
		
	FROM
	[dbo].[V_TheCompany_VCompare_T1_1Final] cn  full join 
	 [dbo].[V_TheCompany_VCompare_T2_1Final] co 
		on [Name1] = [Name2]
	WHERE Name1_LettersNumbersSpacesOnly >'' and Name2_LettersNumbersSpacesOnly >''

UNION

	select distinct
	(CASE WHEN Name1_LettersNumbersSpacesOnly >'' AND Name2_LettersNumbersSpacesOnly >'' THEN 'Name1AndName2'
		WHEN Name1_LettersNumbersSpacesOnly >'' AND Name2_LettersNumbersSpacesOnly IS null then 'Name2'
		WHEN Name2_LettersNumbersSpacesOnly >'' AND Name1_LettersNumbersSpacesOnly IS null then 'Name1'
		ELSE 'OTHER' 
		END) as MatchLevel
		, 'Like' as MatchKind
		, Name1
		, Name2
		, [Name1_FirstWord]
		, [Name2_FirstWord]
		,  [Name1_LettersNumbersSpacesOnly] 
		,  [Name2_LettersNumbersSpacesOnly] 

	FROM
	[dbo].[V_TheCompany_VCompare_T1_1Final] cn  full join 
	 [dbo].[V_TheCompany_VCompare_T2_1Final] co 

		on [Name2_LettersNumbersSpacesOnly] 
			like '%'+ [Name1_LettersNumbersSpacesOnly]+'%'
	WHERE 
	(Name1_LettersNumbersSpacesOnly >'' and Name2_LettersNumbersSpacesOnly >'')
	and [Name1] <> [Name2]

UNION

	select distinct
	(CASE WHEN Name1_LettersNumbersSpacesOnly >'' AND Name2_LettersNumbersSpacesOnly >'' THEN 'Name1AndName2'
		WHEN Name1_LettersNumbersSpacesOnly >'' AND Name2_LettersNumbersSpacesOnly IS null then 'Name2'
		WHEN Name2_LettersNumbersSpacesOnly >'' AND Name1_LettersNumbersSpacesOnly IS null then 'Name1'
		ELSE 'OTHER' 
		END) as MatchLevel
		, 'LikeLeft8' as MatchKind
		, Name1
		, Name2
		, [Name1_FirstWord]
		, [Name2_FirstWord]
		,  [Name1_LettersNumbersSpacesOnly] 
		,  [Name2_LettersNumbersSpacesOnly] 

	FROM
	[dbo].[V_TheCompany_VCompare_T1_1Final] cn  full join 
	 [dbo].[V_TheCompany_VCompare_T2_1Final] co 

		on left([Name2_LettersNumbersOnly],8)
			like '%'+ left([Name1_LettersNumbersOnly],8)+'%'
	WHERE 
	(Name1_LettersNumbersSpacesOnly >'' and Name2_LettersNumbersSpacesOnly >'')
	and [Name1] <> [Name2]
	and [Name2_LettersNumbersSpacesOnly] 
			not like '%'+ [Name1_LettersNumbersSpacesOnly]+'%'
GO
/****** Object:  View [dbo].[V_TheCompany_KWS_0_TheVendorView_QAL]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view  [dbo].[V_TheCompany_KWS_0_TheVendorView_QAL]

as 

select 

      [Name/Number] + (case when [Legacy Number] >'' then ' (Legacy: ' + [Legacy Number] +')' else '' END)
		 as [ContractNumber] /* LINC contracts are entered as e.g. LSHR_CON-20010346 */
      ,[Title] as [Contract Description]
	  , '' as [Contract Relation]
      , 'LEADS ' + [Sub Type] as [Agreement Type]
	  , 1 as 'Agreement Type Divestment'	 
      ,'Active' as [Status] /* State = 'Active', 'Completed' 
	  means [Contract Status] of Published, Draft, Draft Amendment, Pending, On Hold, or Expired */
      ,[Date] AS [Registered Date] /* for migrated contracts this seems to be the import date */
      ,'' AS [Reg Date Cat]
      ,[Date] as [Start Date] /*[EndDateDate]*/

	  /* Expiration date - can be 2099 etc. 
		ETL Ariba data load 2: 	update T_TheCompany_Ariba_Dump_Raw_FLAT  set [Expiration Date - Date] = null WHERE 
			[state] = 'Active' /* 'term type' perpetual overrides expiration date */
			and ([Expiration Date - Date] < [datetablerefreshed])*/
      , null as [End Date] /*[ExpirationDateDate]*/

      , null AS [Review Date]
      , null AS [Review Date Reminder]
	  /* , isnull([study number],'') as [Study Number] */
	  , '' as [All Products]
      /* ,isnull([Additional Comments],'') as [Comments] */
      , 0 AS [Number of Attachments]

      , '' as [Company Names] /* do not use all suppliers concat, since project name is also there */
      /* intercompany: not possible to pull out, attempts: select * from V_TheCompany_KWS_0_TheVendorView_ARB where 
[Company Names] like '%intercompany%'
OR [Contract Description] like '%intercompany%'
/* NOT OR [Company Names] like '%TheCompany%' since internal and external mixed */ */
	  ,0 AS [Company Count] , '' as [Company Countries] 
      ,'' as [Confidentiality Flag]
       ,'' AS [Super User Email]
      ,'' AS [Super User Primary User Group]
      ,0 as [Super User Active Flag]
      ,[Document Owner] as [Owner Name]
      ,'' as [Owner Email]
      ,[Business Unit] AS [Owner Primary User Group]
      , '' AS [Contract Responsible Email]
      ,[Document Management Department] AS [Responsible Primary User Group]
   
      ,[owning department] AS [Internal Partners]  
      ,0 AS [Internal Partners Count]
      ,[Impacted Department] AS [Territories]
      , 0 AS [Territories Count]
      ,'' AS [Active Ingredients]
      ,'' AS [Trade Names]
      , null as [Lump Sum]
      ,'' as [LumpSumCurrency]
      , '' as [Tags]
      ,'' as [L0]
      ,[Site Location] as[L1] /* not the owner region like in TheVendor but all we have */
      ,'' as [L2]
      ,'' as [L3]
      ,'' as [L4]
      ,'Contract' as [Contract Type (Contract Case)] /* do not mix up with agreement type */
	   	  , convert(varchar,[Name/Number] ) AS ContractID /* Letters */ 
		/*  	  , NULL as AGREEMENT_TYPEID */
		, '' AS [Company Country is US]
		, [Alternative Title] as Comments
		/* Link and Date Must be last 2 columns! */
      , 'LEADS' as [LinkToContractURL]
      ,  [DateTableRefreshed] 

  FROM [T_TheCompany_KWS_0_DATA_QA_LEADS_Active] d

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_QAL_QualityPharmacovigilance_ContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view

[dbo].[V_TheCompany_KWS_2_QAL_QualityPharmacovigilance_ContractID]
/* to do: include spaces with Productgroup name */
as 

	SELECT DISTINCT 
		s.*
		, i.ContractID
		/*, i.[Contract Description]
		, i.[Comments] */
	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		inner join [dbo].[V_TheCompany_KWS_0_TheVendorView_QAL] i 
			/* Exact flag makes no sense since TT are concatenated */
			on i.[Contract Description] like  '%'+ s.KeyWordVarchar255 +'%'
			/*	OR i.[Contract Description] like  '%'+ s.KeyWordfirstword_upper +'%' can be NULL */
			/*	OR (case when len(i.[Comments])>5 then i.[Comments] like  '%'+ s.KeyWordVarchar255 +'%' else 1=1 end) */

/*	WHERE 
		s.KeyWordType = 'Territory' */
		

GO
/****** Object:  View [dbo].[V_TheCompany_ContractData_LNC_0VCOMPANY_0RAW]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_ContractData_LNC_0VCOMPANY_0RAW]

/* 
[dbo].[TheCompany_KeyWordSearch]
- elminiate double spaces
- ltrim, rtrim
 - use all supplier field to capture legacy vendors
*/
as

	select 
		* 
		/*, [outside party] as Company*/
		, [Reference] as ContractID
		, [Reference] as ContractNumber
		, [Outside party] as Company
		/* supplier parsing */

		, UPPER(dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([Outside party]))
			as Company_LettersNumbersOnly_UPPER

		,  UPPER(replace(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([Outside party]),'  ',' '))
			as Company_LettersNumbersSpacesOnly_UPPER /* e.g. Hansen & Rosenthal */

		, LEN(replace(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([Outside party]),'  ',' '))
			- LEN(dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([Outside party])) 
				as Company_LettersNumbersOnly_NumSpacesWords

		, [dbo].[TheCompany_CompanyOrIndividual]([Outside party]) AS CompanyType

	from T_TheCompany_KWS_0_Data_LINC
	WHERE 
		[Outside party] is not null /* internal partner or company is populated */
		AND LEN( [Outside party] )>2
		AND [Outside party]>''
		AND [Outside party] NOT LIKE N'%[А-Я]%' /* not Cyrillic, erratic results */

GO
/****** Object:  View [dbo].[V_TheCompany_ContractData_LNC_1VCOMPANY]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[V_TheCompany_ContractData_LNC_1VCOMPANY]
/* refreshed via TheCompany_Company_Search */
as

	select 
		c.*
		, UPPER([COMPANY]) as Company_UPPER
		, len([COMPANY]) as Company_Length
			, UPPER([dbo].[TheCompany_GetFirstWordInString](Company_LettersNumbersSpacesOnly_UPPER))
		as Company_FirstWord_UPPER

			, UPPER([dbo].[TheCompany_GetFirstWordInString]([Company_LettersNumbersSpacesOnly_UPPER]))
		as Company_FirstWord_LettersOnly_UPPER

			, LEN([dbo].[TheCompany_GetFirstWordInString]([COMPANY])) 
		as Company_FirstWord_LEN

		/* two words or more */
		, UPPER((CASE WHEN [Company_LettersNumbersOnly_NumSpacesWords] = 1 
					THEN [Company_LettersNumbersSpacesOnly_UPPER] /* one space */
				WHEN Company_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN SUBSTRING([Company_LettersNumbersSpacesOnly_UPPER],0,CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
						CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
									   CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],+1)+1)) )	/* e.g. SI Group */	
				ELSE NULL /* no space */ END))			
		as Company_FirstTwoWords_UPPER

		, UPPER((CASE WHEN [Company_LettersNumbersOnly_NumSpacesWords] = 1 /* two words, one space */
					THEN [Company_LettersNumbersOnly_UPPER]
				WHEN Company_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(SUBSTRING([Company_LettersNumbersSpacesOnly_UPPER],0,CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
						CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
									   CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],+1)+1)) ))	/* e.g. SI Group */	
				ELSE NULL /* no space */ END))			
		as Company_FirstTwoWords_LettersOnly_UPPER

			,  LEN((CASE WHEN [Company_LettersNumbersOnly_NumSpacesWords] = 1 /* two words, one space */
					THEN [Company_LettersNumbersOnly_UPPER]
				WHEN Company_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(SUBSTRING([Company_LettersNumbersSpacesOnly_UPPER],0,CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
						CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
									   CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],+1)+1)) ))	/* e.g. SI Group */	
				ELSE NULL /* no space */ END)	)	
		as Company_FirstTwoWords_LettersOnly_LEN

		,UPPER( (CASE WHEN LEN(dbo.TheCompany_GetFirstLetterOfEachWord([Company_LettersNumbersSpacesOnly_UPPER])) >=3 
			AND c.CompanyType = 'C' THEN 
				/* dbo.TheCompany_GetFirstLetterOfEachWord([Company_LettersNumbersOnly_UPPER])
			WHEN LEN(dbo.TheCompany_GetFirstLetterOfEachWord([Company_LettersNumbersOnly_UPPER]))<3 
				and len(left([[Company_LettersNumbersOnly_UPPER],3)) >=3 THEN */
				left([Company_LettersNumbersOnly_UPPER],3)
			ELSE NULL END
			) )
			as Company_FirstLetterOfEachWord_UPPER

	from [dbo].[V_TheCompany_ContractData_LNC_0VCOMPANY_0RAW] c
	/* WHERE c.MIK_VALID = 1 /* and company = 'Svedberg, Agneta' */*/

GO
/****** Object:  View [dbo].[V_TheCompany_VCompare_Results_0Exact]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View [dbo].[V_TheCompany_VCompare_Results_0Exact]

as

	select distinct
	(CASE WHEN Name1_LettersNumbersSpacesOnly >'' AND Name2_LettersNumbersSpacesOnly >'' THEN 'Name1AndName2'
		WHEN Name1_LettersNumbersSpacesOnly >'' AND Name2_LettersNumbersSpacesOnly IS null then 'Name2'
		WHEN Name2_LettersNumbersSpacesOnly >'' AND Name1_LettersNumbersSpacesOnly IS null then 'Name1'
		ELSE 'OTHER' 
		END) as MatchLevel
		, '0Exact' as MatchKind
		, Name1
		, Name2
		, [Name1_FirstWord]
		, [Name2_FirstWord]
		,  [Name1_LettersNumbersSpacesOnly] 
		,  [Name2_LettersNumbersSpacesOnly] 
		
	FROM
	[dbo].[V_TheCompany_VCompare_T1_1Final] cn  inner join 
	 [dbo].[V_TheCompany_VCompare_T2_1Final] co 
		on upper([Name1]) = upper([Name2])
GO
/****** Object:  View [dbo].[V_TheCompany_VCompare_Results_1LikeFull]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE View [dbo].[V_TheCompany_VCompare_Results_1LikeFull]

as 

	select distinct
	(CASE WHEN Name1_LettersNumbersSpacesOnly >'' AND Name2_LettersNumbersSpacesOnly >'' THEN 'Name1AndName2'
		WHEN Name1_LettersNumbersSpacesOnly >'' AND Name2_LettersNumbersSpacesOnly IS null then 'Name2'
		WHEN Name2_LettersNumbersSpacesOnly >'' AND Name1_LettersNumbersSpacesOnly IS null then 'Name1'
		ELSE 'OTHER' 
		END) as MatchLevel
		, '1LikeFull' as MatchKind
		, Name1
		, Name2
		, [Name1_FirstWord]
		, [Name2_FirstWord]
		,  [Name1_LettersNumbersSpacesOnly] 
		,  [Name2_LettersNumbersSpacesOnly] 

	FROM
	[dbo].[V_TheCompany_VCompare_T1_1Final] cn  inner join 
	 [dbo].[V_TheCompany_VCompare_T2_1Final] co 

		on [Name2_LettersNumbersSpacesOnly] 
			like '%'+ [Name1_LettersNumbersSpacesOnly]+'%'
		or [Name1_LettersNumbersSpacesOnly] 
			like '%'+ [Name2_LettersNumbersSpacesOnly]+'%'
	where name1 not in (select name1 from V_TheCompany_VCompare_Results_0Exact)

GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_Territories_DATA]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_LNC_Mig_Territories_DATA]
/* 
select territoryid from  [dbo].[V_TheCompany_LNC_Mig_Territories_DATA]
where territoryid not in (select territoryid from V_TheCompany_LNC_Mig_MASTER_Territories)

select count(*) from  [dbo].[V_TheCompany_LNC_Mig_Territories_DATA]
 */

AS 

	select 
			r.OBJECTID as CONTRACTID
           , d.[departmentid] as TERRITORYID
      ,[DEPARTMENT]
		, [L0]
     /* ,[Dpt_Concat_List] */

      ,[NodeType]
      ,[L1]
      ,[L2]
      ,[L3]
      ,[L4]
      ,[LEVEL]
      ,[DEPARTMENT_CODE]
      ,[MIK_SEQUENCE]
      ,[DPT_CODE_2Digit_TerritoryRegion]
      , [NodeRole]
      , [NodeMajorFlag]
      , [DPT_LOWEST_ID_TO_SHOW]
      , [PARENTID]
      , [ISROOT]
      , [FieldCategory]
      , [MIK_VALID]

      , [Parent_Department]
	   , GETDATE() as DateRefreshed
	FROM V_TheCompany_VDepartment_territories d
		inner join TDEPARTMENTROLE_IN_OBJECT r 
			on d.DEPARTMENTID = r.DEPARTMENTID 
			and r.objecttypeid = 1 /* contract */
		inner join V_TheCompany_LNC_GoldStandard g 
			on g.contractid = r.OBJECTID
	where d.[departmentid] <> 203175 /* N/A */

GO
/****** Object:  View [dbo].[V_TheCompany_VCompare_Results_2FirstWord]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE View [dbo].[V_TheCompany_VCompare_Results_2FirstWord]

as 

	SELECT DISTINCT
		(CASE WHEN Name1_LettersNumbersSpacesOnly >'' AND Name2_LettersNumbersSpacesOnly >'' THEN 'Name1AndName2'
			WHEN Name1_LettersNumbersSpacesOnly >'' AND Name2_LettersNumbersSpacesOnly IS null then 'Name2'
			WHEN Name2_LettersNumbersSpacesOnly >'' AND Name1_LettersNumbersSpacesOnly IS null then 'Name1'
			ELSE 'OTHER' 
			END) as MatchLevel
		, '2FirstWord' as MatchKind
		, Name1
		, Name2
		, [Name1_FirstWord]
		, [Name2_FirstWord]
		,  [Name1_LettersNumbersSpacesOnly] 
		,  [Name2_LettersNumbersSpacesOnly] 

	FROM
		[dbo].[V_TheCompany_VCompare_T1_1Final] cn  inner join 
		 [dbo].[V_TheCompany_VCompare_T2_1Final] co 
		 on  [Name2_FirstWord] LIKE	(CASE WHEN LEN([Name2_FirstWord] )>5	
				AND LEN([Name1_FirstWord]) >5 
				THEN '%'+ [Name1_FirstWord]+'%' 
				ELSE '1=0' END)
	WHERE 
		[Name1] not in (select name1 from V_TheCompany_VCompare_Results_0Exact)
		AND name1 not in (select name1 from V_TheCompany_VCompare_Results_1LikeFull)
		AND [Name1_FirstWord] not in ('Pharma') /* junk results, noise word */
		AND [Name2_FirstWord] not in ('Pharma') /* junk results, noise word */

GO
/****** Object:  View [dbo].[V_TheCompany_VCompare_Results_3LikeLeft8]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View [dbo].[V_TheCompany_VCompare_Results_3LikeLeft8]

as 


	select distinct
	(CASE WHEN Name1_LettersNumbersSpacesOnly >'' AND Name2_LettersNumbersSpacesOnly >'' THEN 'Name1AndName2'
		WHEN Name1_LettersNumbersSpacesOnly >'' AND Name2_LettersNumbersSpacesOnly IS null then 'Name2'
		WHEN Name2_LettersNumbersSpacesOnly >'' AND Name1_LettersNumbersSpacesOnly IS null then 'Name1'
		ELSE 'OTHER' 
		END) as MatchLevel
		, '3LikeLeft8' as MatchKind
		, Name1
		, Name2
		, [Name1_FirstWord]
		, [Name2_FirstWord]
		,  [Name1_LettersNumbersSpacesOnly] 
		,  [Name2_LettersNumbersSpacesOnly] 

	FROM
	[dbo].[V_TheCompany_VCompare_T1_1Final] cn  inner join 
	 [dbo].[V_TheCompany_VCompare_T2_1Final] co 

		on left([Name2_LettersNumbersOnly],8)
			like '%'+ left([Name1_LettersNumbersOnly],8)+'%'
		or 		left([Name1_LettersNumbersOnly],8)
			like '%'+ left([Name2_LettersNumbersOnly],8)+'%'

	WHERE 
	 [Name1] not in (select name1 from V_TheCompany_VCompare_Results_0Exact)
	and name1 not in (select name1 from V_TheCompany_VCompare_Results_1LikeFull)
	and name1 not in (select name1 from V_TheCompany_VCompare_Results_2FirstWord)

GO
/****** Object:  View [dbo].[V_TheCompany_VUSER_DOMAIN_TOTALS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_VUSER_DOMAIN_TOTALS]

as

select 
	domainname
	, [UserProfileGroup]
	, UserProfileCategory
	, count(*) as COUNT_USERID 
	, max([DISPLAYNAME]) as DisplayNameMax
	, min([DISPLAYNAME]) as DisplayNameMin
	, USER_MIK_VALID
from V_TheCompany_VUSER
where USER_MIK_VALID = 1
AND UserProfileCategory <>'Administrator'
group by DOMAINNAME, [UserProfileGroup], userprofilecategory, USER_MIK_VALID

GO
/****** Object:  View [dbo].[V_TheCompany_ALL_EditRange]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_TheCompany_ALL_EditRange]

as

select * from T_TheCompany_ALL
WHERE 	
/* registered for at least 1 day */
getdate() > dateadd(dd,+1,contractdate)   
AND (CONTRACTDATE >= '01/01/2018' /* OR statusid = 5 Active */
		/* or (EXPIRYDATE is null and CONTRACTDATE >='01/01/2015') */)
AND CONTRACTTYPEID NOT IN (6 /* Access SAKSNR number Series*/
			, 5 /* Test Old */,102 /* Test New */
			,13 /* DELETE */
			,11 /* CASE */ )
AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER not like '!ARIBA%')


GO
/****** Object:  View [dbo].[V_TheCompany_EDIT_ITEMS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[V_TheCompany_EDIT_ITEMS]

as 

/* 1 - No pdf attached */
	SELECT CONTRACTID /*, NUMBEROFFILES, Title, CONTRACTDATE, contracttype , contractdate, dateadd(dd,+1,contractdate) as dt */
	,1  as EditNo
	FROM V_TheCompany_ALL_EditRange
	WHERE 
		/* NUMBEROFFILES = 0 do not use since an xls would also make the numberoffiles = 1 */
		Title Not Like '%NOT AVAILABLE%'
		AND Title Not Like '%NO FILES%'
		AND CONTRACTDATE > '2011-01-01 00:00:00'
		AND CONTRACTTYPE LIKE '%contract%'
		/* CONTRACTID in (select CONTRACTID from TCONTRACT where contractnumber = 'Contract-11144992') */
		/* must verify against tdocument since numberoffiles flag sometimes wrong */
		AND CONTRACTID not in (select Objectid from VDOCUMENT where MIK_VALID = 1
								and FileType = '.pdf') /* only pdf? */
		/* AND pdf not accidentally in the Partner folder */
		AND CONTRACTID not in (SELECT contractid							
							FROM VDOCUMENT d inner join TTENDERER t on d.objectid = t.TENDERERID
							WHERE
							MIK_VALID = 1 and DOCUMENTTYPEID in (141,142,160 /* Company */))
UNION ALL


/* 41 - pdf attached under TENDERER */

		SELECT MAX (t.contractid) AS CONTRACTID
		,41  as EditNo /*, DOCUMENTID should really be a column for this to be unique*/
		FROM vDOCUMENT d inner join TTENDERER t on d.OBJECTID = t.TENDERERID
		WHERE 
			MIK_VALID = 1 
			and OBJECTTYPEID =  30 /* Tenderer */
			AND DOCUMENTTYPEID in (29,142,160 /* Tenderer Doc Type ID under objecttype 30 anyway */)
		GROUP BY t.TENDERERID
		
UNION ALL

/* 46 - pdf attached under COMPANY */

		SELECT max(t.contractid) AS CONTRACTID
		,46  as EditNo /*, DOCUMENTID should really be a column for this to be unique*/
		FROM vDOCUMENT d inner join TCOMPANY c on d.OBJECTID = c.companyid
		inner join TTENDERER t on t.COMPANYID = c.companyid
		WHERE 
			d.MIK_VALID = 1 
			and OBJECTTYPEID =  19 /* Company */
			AND DOCUMENTTYPEID in (141 /* Company Doc Type ID under objecttype 19 anyway */)
		GROUP BY c.COMPANYID
		
UNION ALL

/* Start Date Null */
	SELECT CONTRACTID
	,2
	FROM V_TheCompany_ALL_EditRange
	WHERE 
		STARTDATE IS NULL
		AND CONTRACTTYPE LIKE '%contract%'

UNION ALL

/* 03 - Amendment, Addendum or Termination without Basic Agreement */

	SELECT CONTRACTID
	, 03
	FROM V_TheCompany_ALL_EditRange
	WHERE 
	TITLE Not Like '%NOT AVAILABLE%'
	/* AND CONTRACTID = 132872 */
	and AGREEMENT_TYPEID not in (100285 /* Preliminary Agreement */)
	AND
	(
		(TITLE Like '%Addend%' And 
			TITLE Not Like '%+%Addend%' 
			And TITLE Not Like '%incl.%Addend%' 
		)
		
		OR ((TITLE Like '% Termination%' 
			Or TITLE Like 'Termination%') And TITLE Not Like '%+%Termination%' And TITLE Not Like '%incl.%Termination%' )
		OR ((TITLE Like '% Amendment%' 
			Or TITLE Like 'Amendment%') And TITLE Not Like '%+ %Amendment%' And TITLE Not Like '%incl.%Amendment%' )
		OR ((TITLE Like '% Prolongation%' 
			Or TITLE Like 'Prolongation%') And TITLE Not Like '%incl.%Prolongation%' )
		OR ((TITLE Like '% side letter%' 
			Or TITLE Like 'side letter%') And TITLE Not Like '%incl. side letter%')
	)

UNION ALL

/* 05 - Missing Territory */
	SELECT CONTRACTID
	, 05
	FROM V_TheCompany_ALL_EditRange
	WHERE Territories_COUNT = 0

UNION ALL

/* 06 - Company not added */
	SELECT CONTRACTID
	, 06
	FROM V_TheCompany_ALL_EditRange
	WHERE CompanyIDCount = 0

UNION ALL
			
/* 07 - Missing Super user */
	SELECT CONTRACTID
	, 07
	FROM V_TheCompany_ALL_EditRange
	WHERE US_Userid IS NULL
		

UNION ALL

/* 08 - Missing Contract Owner*/
	SELECT CONTRACTID
	, 08
	FROM V_TheCompany_ALL_EditRange
	WHERE ownerid /* UO_employeeid */ IS NULL

UNION ALL

/* 09 - Missing Contract Responsible */
	SELECT CONTRACTID
	, 09
	FROM V_TheCompany_ALL_EditRange
	WHERE TECHCOORDINATORID /* UR_employeeid */ IS NULL
				
UNION ALL

/* 10 - Missing Internal Partner */
	SELECT CONTRACTID
	, 10
	FROM V_TheCompany_ALL_EditRange
	WHERE InternalPartners_COUNT = 0

UNION ALL
			
/* Duplicates, unique record for correction list 
	with Min duplicate as primary and max duplicate as suspected dupe */

	SELECT CONTRACTID_UNIQUE
	, 11
	FROM T_TheCompany_Duplicates_Final
	WHERE CONTRACTID_MIN = CONTRACTID_UNIQUE


/* 111 - Duplicates  - 111 is not an edit no but for the duplicate to show? 
not sure if needed so commenting out
T_TheCompany_Duplicates_Final serves this purpose already?
	SELECT CONTRACTID_UNIQUE
	, 111
	FROM T_TheCompany_Duplicates_Final
	WHERE CONTRACTID_MIN <> CONTRACTID_UNIQUE
	*/

UNION ALL

/* 12: Department incorrect - User Role */

	SELECT OBJECTID
	, 12 /* Department incorrect - User Role */
	FROM
	V_TheCompany_Edit_Wrong_DPTROLE_IN_OBJECT
	WHERE rolecategory = 'D'
	and 
	/* User is not incorrectly set up as an internal partner, that is caught in issue 43-45 */
	OBJECTID not in (select contractid from T_TheCompany_ALL 
				where US_PrimaryUserGroup like 'Internal P%'
				OR UO_PrimaryUserGroup like 'Internal P%'
				OR UR_PrimaryUserGroup like 'Internal P%')

UNION ALL

/* 43, 44, 45: Department incorrect - User Role */
/*
	SELECT OBJECTID
	, 12 /* Department incorrect - User Role */
	FROM
	V_TheCompany_Edit_Wrong_DPTROLE_IN_OBJECT
	WHERE rolecategory = 'D'
	and 
	/* User is not incorrectly set up as an internal partner, that is caught in issue 43-45 */
	OBJECTID not in (select contractid from T_TheCompany_ALL 
				where US_PrimaryUserGroup like 'Internal P%'
				OR UO_PrimaryUserGroup like 'Internal P%'
				OR UR_PrimaryUserGroup like 'Internal P%')
				


UNION ALL
*/

	SELECT OBJECTID
	, 14 /* incorrect internal partner, merge items */
	FROM
	V_TheCompany_Edit_Wrong_DPTROLE_IN_OBJECT
	WHERE rolecategory = 'I'

UNION ALL

/* 16 - Customer added not awarded */
	SELECT CONTRACTID
	,16
	FROM V_TheCompany_ALL_EditRange
	WHERE companyIDAwardedCount <> CompanyIDCount

	
UNION ALL

/* 17 - Review Date Expired or Null */
	SELECT CONTRACTID
	/* , dateadd(dd,-90,GETDATE()) as dd, dateadd(dd,-1,GETDATE()) as dd2, contractdate */
	,17
	FROM V_TheCompany_ALL_EditRange
	WHERE 
		(REVIEWDATE IS NULL OR
		dateadd(dd,+1,REVIEWDATE) < GETDATE())
		AND (DEFINEDENDDATE ='' OR DEFINEDENDDATE IS NULL)
		AND (REV_EXPIRYDATE ='' OR REV_EXPIRYDATE IS NULL)
		AND AGREEMENT_TYPEID NOT IN (5 /* CDA */)
		AND AGREEMENT_FIXED NOT LIKE '!AD%' /* Administration Agreement */
		AND CONTRACTDATE BETWEEN dateadd(dd,-90,GETDATE()) AND dateadd(dd,-1,GETDATE())
		AND CompanyList not like '%int%r%company%'
		
UNION ALL

/* 18 - Fictional End Date */
/*
SELECT CONTRACTID
,18
FROM T_TheCompany_ALL
WHERE [EXPIRYDATE] = '2020-12-30 23:00:00.000' 
UNION ALL
*/

	


/* 19 - Intercompany contracts must have at least two internal partners */

	SELECT CONTRACTID
	, 19
	/* , title, companylist, internalpartners, contractdate */
	FROM T_TheCompany_ALL
	WHERE 
		CompanyIDList = '1' /* CompanyList like '%intercompany%' */
	AND InternalPartners_COUNT <2 /* Less than two internal partners */
	AND (	(STATUSID = 5 /* active */ AND [CONTRACTDATE] > '2014-01-01 23:00:00.000') 
			OR [CONTRACTDATE] > '2015-01-01 23:00:00.000') 
	and CONTRACTTYPEID  <> 11 /* case */

UNION ALL



/* 20 - Intercompany contracts must have External Partner Intercompany Dummy assigned as the company */

	SELECT CONTRACTID
	, 20
	/* , title, companylist, internalpartners, contractdate */
	FROM V_TheCompany_ALL_EditRange
	WHERE 
	Title Like '%Intercompany%'
	and Title not like '%re: intercompany%' /* ist not just about the topic intercompany */
	AND companyList not like '%Intercompany%'
	/* and CompanyIDList ='' */ /* No counter party = intercompany */

UNION ALL

/* 24 - New Intercompany Entity created in customer setup 
	but the existing Dummy Company 'Intercompany TheCompany' should be used */

	SELECT CONTRACTID
	, 24
	/* , title, companylist, internalpartners, contractdate */
	FROM V_TheCompany_ALL_EditRange
	WHERE 
	CONTRACTID in (select t.CONTRACTID from 
				TTENDERER t inner join TCOMPANY c on t.COMPANYID = c.companyid where 
				c.MIK_VALID = 1 AND
				((c.company Like '%TheCompany%' 
				Or c.company Like '%Nycomed%' 
				Or c.company Like '%Altana%' 
				Or c.company Like '%Byk Gulden%')
				and c.COMPANYID not in (1 /* intercompany dummy */
										,224910 /* Intracompany TheCompany */))
				)
	
UNION ALL

/* 49 - company name not entered according to naming convention */

	SELECT e.CONTRACTID
	, 49
	FROM
	V_TheCompany_ALL_EditRange e inner join TTENDERER t on e.CONTRACTID = t.CONTRACTID
	inner join tcompany c on t.COMPANYID = c.companyid inner join V_TheCompany_VCOMPANYADDRESS a on c.COMPANYID = a.COMPANYID_Add
	where 
	c.MIK_VALID = 1 and
	c.COMPANY not like '% %'
	and (a.City ='' or a.country = '')
	
UNION ALL

/* 26 - MSA */

	SELECT [CONTRACTID]
	, 26 /* MSA */
	FROM V_TheCompany_Edit_MSA_NoDoc /* MSA in title but no MSA document found */

UNION ALL

/* 28 - incorrect internal partner, merge items */
	SELECT OBJECTID
	, 28 
	FROM
	V_TheCompany_Edit_Wrong_DPTROLE_IN_OBJECT
	WHERE rolecategory = 'T'

UNION ALL

/* 29 - underscores */
	SELECT CONTRACTID
	,29
	FROM T_TheCompany_ALL
	WHERE title Like '%[_]%'

UNION ALL

/* 30 - Territories Base Node */
	SELECT CONTRACTID
	,30
	FROM T_TheCompany_ALL
	WHERE Territories Like 'Territories%' /* Base Node */

UNION ALL

/* 31 - Missing Agreement Type */
	SELECT CONTRACTID
	,31
	FROM V_TheCompany_ALL_EditRange
	WHERE AGREEMENT_TYPEID IS NULL


	
UNION ALL


/* 32 - Admin agreement key word in contract */
	SELECT CONTRACTID
	,32
	FROM T_TheCompany_ALL
	WHERE 
	CONTRACTTYPE like '%contract%' 
	AND AGREEMENT_FIXED NOT LIKE '!AD%' /* Administration Agreement */
	and AGREEMENT_TYPE not like '%consult%' /* could be consulting agreement on the topic */
	AND
	(
	TITLE Like '%capital increase%' 
	Or TITLE Like '%change of name%' 
	Or TITLE Like '%board of directors%' 
	Or TITLE Like '%shareholder%' 
	Or TITLE Like '%corporate purpose%'
	)

UNION ALL

/* 33 - CDA Reminder set, show only for 1 week */
	SELECT CONTRACTID
	,33
	FROM V_TheCompany_ALL_EditRange
	WHERE RD_ReviewDate_Warning IS NOT NULL
		AND (AGREEMENT_TYPEID = 5 /* CDA */ /*OR CompanyIDList = '1' /* intercompany */ removed since intercompany reminder is decided to be optional */)
		AND CONTRACTDATE BETWEEN dateadd(dd,-7,GETDATE()) AND dateadd(dd,0,GETDATE())

UNION ALL

/* CANCELLED 34 - INTRAcompany must have exactly one internal partner 

	SELECT CONTRACTID
	, 34
	FROM V_TheCompany_ALL_EditRange
	WHERE 
	(CompanyList Like '%Intracompany%'
	OR Title Like '%Intracompany%'
	)
	AND InternalPartners_COUNT <>1

UNION ALL */

/* CANCELLED 35 - INTRAcompany must use Dummy 

	SELECT CONTRACTID
	, 35
	/* , title, companylist, internalpartners, contractdate */
	FROM V_TheCompany_ALL_EditRange
	WHERE 
	(Title Like '%Intracompany%'
	OR Title Like '%Intra%group%'
	OR Title like '%intra%company%' )
	AND 
	CompanyList not like '%Intracompany%'
	
UNION ALL */



/* 36 - Review date entered, but Reminder not set */
	SELECT CONTRACTID
	,36
	FROM V_TheCompany_ALL_EditRange
	WHERE RD_ReviewDate_Warning IS NULL
		AND AGREEMENT_TYPEID <> 5 /* NOT CDA */
		AND CompanyIDList <>'1' /* NOT Intercompany */
		AND CompanyIDList <> '224910' /* NOT Intracompany TheCompany */
		AND FINAL_EXPIRYDATE is null
		AND REVIEWDATE IS NOT NULL
		AND CONTRACTDATE BETWEEN dateadd(dd,-90,GETDATE()) AND dateadd(dd,-1,GETDATE())
		
UNION ALL

/* 37 - Contract owner is inactive disabled deleted user */
	SELECT CONTRACTID
	,37
	FROM T_TheCompany_ALL /* V_TheCompany_ALL_EditRange */
	WHERE UO_USER_MIK_VALID = 0
		and FINAL_EXPIRYDATE is null
		and CONTRACTDATE >= '01/01/2010'

UNION ALL

/* 38 - Contract responsible is inactive user */
	SELECT CONTRACTID
	,38
	FROM T_TheCompany_ALL
	WHERE UR_USER_MIK_VALID = 0
		and FINAL_EXPIRYDATE is null
		and CONTRACTDATE >= '01/01/2010'
	
/*
UNION ALL


/* CDA filed separately */
SELECT CONTRACTID,title,999 from T_TheCompany_ALL
WHERE agreement_typeid = 5 /* CDA */
AND CONTRACTDATE >= '2016-01-01 00:00:00'
and CompanyIDList in (Select CompanyIDList 
						from T_TheCompany_ALL 
						group by companyidlist 
						having COUNT(contractid) =2) 
						
*/


UNION ALL

/* 39 Duplicate companies*/

	SELECT c.CONTRACTID
	, 39
	FROM
	V_TheCompany_ALL_EditRange c inner join V_TheCompany_Edit_DupeCompanyContractIDs d 
	on c.CONTRACTID = d.CONTRACTID

		


UNION ALL

/* 42 Invalid contract type */

	SELECT CONTRACTID
	, 42
	FROM
	V_TheCompany_ALL_EditRange
	WHERE STATUSID = 5 /* Active */
	/* and agreement_typeid in(100182,100181) */
	AND agreement_typeid not in (select AGREEMENT_TYPEID 
									from TAGREEMENT_TYPE 
									where MIK_VALID = 1)
	AND AGREEMENT_TYPEID IS NOT NULL

/* user set up as internal partner */
/* change this to departments when all cco entries fixed */
UNION ALL
	select contractid
	, 43 from T_TheCompany_ALL where
	EXECUTORID in (select EMPLOYEEID from VUSER 
					where PRIMARYUSERGROUP like 'Internal Partner%'

					and user_mik_valid = 1)

/* 44 - Contract Owner incorrectly created in User Setup */
UNION ALL				
	select contractid
	, 44 from T_TheCompany_ALL where			
	OWNERID in (select EMPLOYEEID from VUSER 
					where PRIMARYUSERGROUP like 'Internal Partner%'
					and user_mik_valid = 1)
/* 45 - Contract Responsible incorrectly created in User Setup */
UNION ALL				
	select contractid
	, 45 from T_TheCompany_ALL where				
	TECHCOORDINATORID in (select EMPLOYEEID from VUSER 
					where PRIMARYUSERGROUP like 'Internal Partner%'
					and user_mik_valid = 1)


UNION ALL

/* 47 - pdf name too short */

	select contractid
	, 47 from vDOCUMENT d 
	inner join V_TheCompany_ALL_EditRange c on d.OBJECTID = c.contractid
	WHERE len(d.title) < 8
	and d.FileType = '.pdf'
	and d.DOCUMENTTYPEID = 1 /* Signed Contracts */
	and d.MIK_VALID = 1
	and c.AGREEMENT_TYPEID not in (12,24,25,100283 /* administration agreements Legal */)
	/* and c.NUMBER = 'Contract-11131984' */

	

/* 50 - inactive TheCompany entity on active contract,
 doing this properly will require a table with the entity end dates */

 UNION ALL

	select  contractid
		, 50
	from 
		T_TheCompany_ALL 
	where	
		InternalPartners like '%nycomed%'	
		/* AND STATUSID = 5  active NOT since it would then not catch contracts that expire immediately */	
		AND STARTDATE > '01-Jan-2018'
		AND CONTRACTDATE > '01-Jan-2018'
		AND contractid in (select o.OBJECTID
							from TDEPARTMENTROLE_IN_OBJECT o 
								inner join [V_TheCompany_VDepartment_InternalPartner_ParsedDpt] d
								on o.DEPARTMENTID = d.DEPARTMENTID
							WHERE InternalPartnerStatusFlag = 0 /* Inactive */)
/*
UNION ALL

	/* 48 - pdf filed in Signed contracts folder in a case */

	Select distinct CONTRACTID,
	48
	from TCONTRACT c inner join VDOCUMENT d on c.CONTRACTID = d.objectid
	where
		d.DOCUMENTTYPEID = 1 /* Signed Contracts */
		and c.CONTRACTTYPEID = 11 /* case */

*/

GO
/****** Object:  View [dbo].[V_TheCompany_VCompare_Results_9Combined]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE View [dbo].[V_TheCompany_VCompare_Results_9Combined]


as 

	/* make tables */
			select * from [dbo].[T_TheCompany_VCompare_Results_0Exact]
		UNION 
			select * from [dbo].[T_TheCompany_VCompare_Results_1LikeFull]
		UNION 
			select * from [dbo].[T_TheCompany_VCompare_Results_2FirstWord]
		UNION 
			select * from [dbo].[T_TheCompany_VCompare_Results_3LikeLeft8]

	/* dynamic, uses maketable tables */
		UNION
			select * from [dbo].[V_TheCompany_VCompare_Results_5_NoMatches_Name1]
		UNION
			select * from [dbo].[V_TheCompany_VCompare_Results_5_NoMatches_Name2]

GO
/****** Object:  View [dbo].[V_TheCompany_Hierarchy_AllCountries]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_Hierarchy_AllCountries]

as

	select top 300 
		  [DPT_CODE_2Digit_InternalPartner] as '2_Digit_ISO_Code'
		  ,[LEVEL]
		  ,[L0] as 'L0 - Root'
		  ,[L1] as 'L1 - Region'
		  ,[L2] as 'L2 - Area'
		  ,(CASE WHEN [L3]=h.[DEPARTMENT] THEN '' ELSE [L3] END) as 'L3 - SubArea1'
		  ,(CASE WHEN [L4]=h.[DEPARTMENT] THEN '' ELSE [L4] END) as 'L4 - SubArea2'
		  , h.[DEPARTMENT] as 'Country'
		  , h.[DEPARTMENTID]
	from dbo.V_TheCompany_Hierarchy h inner join TDEPARTMENT d on h.DEPARTMENT_CODE= d.DEPARTMENT_CODE
	where 
		L0 = 'Territories - Region'
		and NodeType = 'Country'
		and LEVEL >0
		and d.MIK_VALID = 1
		order by L1,L2,L3,l4

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_3_LNC_TCOMPANY_ContractID_Extended]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view 

[dbo].[V_TheCompany_KWS_3_LNC_TCOMPANY_ContractID_Extended]

as

SELECT 
	[ContractID]
	, [KeyWordVarchar255]
	, [KeyWordVarchar255_UPPER]
      ,[keywordlength]
      ,[keywordFirstWord_UPPER]
      ,[KeyWordFirstWord_LettersOnly_UPPER]
      ,[KeyWordLettersNumbersOnly_UPPER]
      ,[keywordFirstTwoWords_UPPER]
      ,[KeyWordFirstTwoWords_LettersOnly_UPPER]
      ,[KeyWordCustom1]
      ,[KeyWordCustom2]
      ,[KeyWordLettersNumbersSpacesOnly_UPPER]

	 /* Company */
	 /*  , [CompanyID] */
	  , [COMPANY] 	
	  , [CompanyType]

      , [Company_LettersNumbersOnly_UPPER]
      , [Company_LettersNumbersSpacesOnly_UPPER]

	/* Company Matches / Flags */
      , [CompanyMatch_Exact]
      , [CompanyMatch_Exact_Flag]

	/* LIKE */
		, (case when 
			[CompanyMatch_Exact_FLAG] = 0
			AND  [CompanyMatch_LIKE_FLAG] >= [CompanyMatch_FirstTwoWords_FLAG]
			 THEN [CompanyMatch_LIKE] 
			ELSE '' END) 
			as [CompanyMatch_LIKE]

		, (case when 
			[CompanyMatch_Exact_FLAG] = 0
			AND  [CompanyMatch_LIKE_FLAG] >= [CompanyMatch_FirstTwoWords_FLAG]
			 THEN [CompanyMatch_LIKE_FLAG] 
			ELSE 0 END) 
			as [CompanyMatch_LIKE_FLAG]

		/* REV Like */
		, (case when 
			[CompanyMatch_Exact_FLAG] = 0
			AND [CompanyMatch_Like_FLAG] = 0 
			AND [CompanyMatch_FirstWord_FLAG] = 0 /*< [CompanyMatch_REV_LIKE_FLAG] */
			AND [CompanyMatch_FirstTwoWords_FLAG] = 0
			THEN [CompanyMatch_REV_LIKE] 
			ELSE '' END) 
			as [CompanyMatch_REV_LIKE]

		, (case when 
			[CompanyMatch_Exact_FLAG] = 0
			AND [CompanyMatch_Like_FLAG] = 0 
			AND [CompanyMatch_FirstWord_FLAG] = 0 /*< [CompanyMatch_REV_LIKE_FLAG] */
			AND [CompanyMatch_FirstTwoWords_FLAG] = 0
			THEN [CompanyMatch_REV_LIKE_FLAG]
			ELSE 0 END) 
			as [CompanyMatch_REV_LIKE_FLAG]
		
		/* 2-Way LIKE */
			, (case WHEN 
					[CompanyMatch_Exact_FLAG] = 0
					AND [CompanyMatch_Like_FLAG] = 0
					AND [CompanyMatch_REV_LIKE_FLAG] = 0	
					AND [CompanyMatch_FirstWord_FLAG] < [CompanyMatch_LIKE2Way_FLAG]	
					AND [CompanyMatch_FirstTwoWords_FLAG] < [CompanyMatch_LIKE2Way_FLAG]				
				THEN [CompanyMatch_LIKE2Way] 
				ELSE '' END) 
				as [CompanyMatch_LIKE2Way]

			, (case WHEN 
					[CompanyMatch_Exact_FLAG] = 0
					AND [CompanyMatch_Like_FLAG] = 0
					AND [CompanyMatch_REV_LIKE_FLAG] = 0	
					AND [CompanyMatch_FirstWord_FLAG] < [CompanyMatch_LIKE2Way_FLAG]	
					AND [CompanyMatch_FirstTwoWords_FLAG] < [CompanyMatch_LIKE2Way_FLAG]	
				THEN [CompanyMatch_LIKE2Way_FLAG] 
				ELSE 0 END) 
				as [CompanyMatch_LIKE2Way_FLAG]

		/* 2 Way REV Like */
			, (case WHEN 
					[CompanyMatch_Exact_FLAG] = 0
					AND [CompanyMatch_Like_FLAG] = 0
					AND [CompanyMatch_REV_LIKE_FLAG] = 0	
					AND [CompanyMatch_FirstWord_FLAG] = 0
					AND [CompanyMatch_FirstTwoWords_FLAG] = 0
					AND [CompanyMatch_LIKE2Way_FLAG] = 0 
				THEN [CompanyMatch_REV_LIKE2Way] 
				ELSE '' END) 
				as [CompanyMatch_REV_LIKE2Way]

			, (case WHEN 
					[CompanyMatch_Exact_FLAG] = 0
					AND [CompanyMatch_Like_FLAG] = 0
					AND [CompanyMatch_REV_LIKE_FLAG] = 0	
					AND [CompanyMatch_FirstWord_FLAG] = 0
					AND [CompanyMatch_FirstTwoWords_FLAG] = 0
					AND [CompanyMatch_LIKE2Way_FLAG] = 0 
				THEN [CompanyMatch_REV_LIKE2Way_FLAG] 
				 ELSE 0 END) 
				as [CompanyMatch_REV_LIKE2Way_FLAG]

	/* First Two Words */
		, (CASE WHEN 
				[CompanyMatch_Exact_FLAG] = 0
				AND [CompanyMatch_Like_FLAG] < [CompanyMatch_FirstTwoWords_FLAG]
				THEN [CompanyMatch_FirstTwoWords] ELSE '' END)	
				AS [CompanyMatch_FirstTwoWords]

		, (CASE WHEN 
				[CompanyMatch_Exact_FLAG] = 0
				AND [CompanyMatch_Like_FLAG] < [CompanyMatch_FirstTwoWords_FLAG]
					THEN [CompanyMatch_FirstTwoWords_FLAG] ELSE 0 END)	
				AS [CompanyMatch_FirstTwoWords_FLAG]

	/* First Word */

		, (CASE WHEN [CompanyMatch_Exact_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
					AND CompanyMatch_LIKE_FLAG < [CompanyMatch_FirstWord_FLAG] /* more accurate than LIKE */
				THEN [CompanyMatch_FirstWord] 
				 ELSE '' END)
				AS [CompanyMatch_FirstWord]

		, (CASE WHEN [CompanyMatch_Exact_FLAG] = 0
					AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
					AND CompanyMatch_LIKE_FLAG < [CompanyMatch_FirstWord_FLAG]
				 THEN [CompanyMatch_FirstWord_FLAG]
				 ELSE 0 END)
				AS [CompanyMatch_FirstWord_FLAG]

		/* First Word 2-Way */
		, (CASE WHEN 
				[CompanyMatch_Like_FLAG] = 0
				AND [CompanyMatch_FirstWord_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
				and [CompanyMatch_LIKE2Way_FLAG] < [CompanyMatch_FirstWord2Way]
				THEN [CompanyMatch_FirstWord2Way] 
				 ELSE '' END)
				AS [CompanyMatch_FirstWord2Way]

		, (CASE WHEN 
				[CompanyMatch_Like_FLAG] = 0
				AND [CompanyMatch_FirstWord_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
				and [CompanyMatch_LIKE2Way_FLAG] < [CompanyMatch_FirstWord2Way]
				THEN [CompanyMatch_FirstWord2Way_FLAG]
				 ELSE 0 END)
				AS [CompanyMatch_FirstWord2Way_FLAG]
		
		/* First Word 2-Way Reverse */
		, (CASE WHEN 
						[CompanyMatch_Like_FLAG] = 0
				AND [CompanyMatch_FirstWord_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
				and [CompanyMatch_LIKE2Way_FLAG] < [CompanyMatch_FirstWord2Way]
				AND [CompanyMatch_FirstWord2Way_FLAG] = 0
				THEN [CompanyMatch_FirstWord2Way_REV]
				 ELSE '' END)
				AS [CompanyMatch_FirstWord2Way_REV]

		, (CASE WHEN 
						[CompanyMatch_Like_FLAG] = 0
				AND [CompanyMatch_FirstWord_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
				and [CompanyMatch_LIKE2Way_FLAG] < [CompanyMatch_FirstWord2Way]
				AND [CompanyMatch_FirstWord2Way_FLAG] = 0
				THEN [CompanyMatch_FirstWord2Way_REV_FLAG]
				 ELSE 0 END)
				AS [CompanyMatch_FirstWord2Way_REV_FLAG]
	
	/* Other */
	  , [CompanyMatch_EntireKeywordLike_FLAG]	 
	  ,  [CompanyMatch_Abbreviation_Flag]		
		, CompanyMatch_ContainsKeyword
		, CompanyMatch_BeginsWithKeyword

  FROM T_TheCompany_KWS_2_LNC_TCompany_ContractID
	/* from [dbo].[V_TheCompany_KWS_3_TCompany_ContractID] */ 

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_6_LNC_ContractID_UNION]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[V_TheCompany_KWS_6_LNC_ContractID_UNION]
as

	select distinct contractid /* ,'1' as 'Source' 
		, 'Company' as KeyWordType */
	from V_TheCompany_KWS_3_LNC_TCompany_ContractID_Extended

	/*
		UNION ALL /* Union returns nothing if one item has no records */

	select contractid /*,'2'
		, 'Product' /*, [KeyWordVarchar255] as KeyWord */ */
	from V_TheCompany_KWS_3_LNC_TProduct_ContractID_Extended /* does not yet exist */
	*/
	
	/*	UNION ALL /* Union returns nothing if one item has no records */

	select contractid 
	from V_TheCompany_KWS_5c_LNC_DESCRIPTION_ContractID
	*/

	/*
		UNION ALL /* Union returns nothing if one item has no records */

	select contractid
	from V_TheCompany_KWS_2_LNC_InternalPartner_ContractID
	*/
/*		UNION ALL /* Union returns nothing if one item has no records */

	select  contractid
	from T_TheCompany_KWS_2_LNC_Territories_ContractID

		UNION ALL /* Union returns nothing if one item has no records */

	/* select contractid
	from T_TheCompany_KWS_2_LNC_TCOMPANYCountry_ContractID

		UNION ALL /* Union returns nothing if one item has no records */ 

	select contractid
	from T_TheCompany_KWS_2_LNC_Tag_ContractID  */

		UNION ALL /* Union returns nothing if one item has no records */

	select ContractID 
	from V_TheCompany_KWS_1_LNC_MiscMetadataFields 
	*/
GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_MASTER_Vcompany]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[V_TheCompany_LNC_Mig_MASTER_Vcompany]

as

/*
select companyid
from [dbo].[V_TheCompany_LNC_Mig_DATA_COMPANY_TTENDERER_CONTRACTID]
where companyid not in (select companyid from [V_TheCompany_LNC_Mig_MASTER_Vcompany])

select * from TCOMPANY where COMPANYID = 220856
select * from TCOMPANYADDRESS where COMPANYID = 220856
select * from ttenderer where companyid = 220856
*/

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT /* TOP  100 percent */
	c.[COMPANY]

      ,(case 
		when [CompanyType] = 'C' then 'Company' 
		when [CompanyType] = 'I' then 'Individual' 
		when [CompanyType] = 'T' then 'Individual?' 
		when [CompanyType] = 'U' then 'Undetermined' 
		else '' END)

		as CompanyOrIndividual

	  , companyid_LN as companyid
      ,[Contract_Count]
      ,[Contract_Count_Active]
      ,[Company_SAP_ID]
	  		, COMPANYNO
		,DUNSNUMBER
		, [ISINTERNAL]
		, [ISCUSTOMER]
		, [ISPARTNER]
				, [ISVENDOR]

      ,[COMPANYADDRESSID]

      ,a.[Street]
      ,a.[POB]
      ,a.[PostalCode]
      ,a.[City]
      ,a.[County]
      ,a.[COUNTRY]
	  , a.[CtyCode2Letter]
      ,[CompanyAddressConcat]
      /* ,[COUNTRYID] */
	  /*, [CtyCode2Letter_Hfm] */
      ,a.[ADDRESSTYPE]
      ,a.[ADDRESSDESCRIPTION]

      ,c.[Country_IsUS]


	  /* contact details */
      ,[WWW]
      ,[EMAIL]
	, GETDATE() as DateRefreshed
  FROM [TheVendor_app].[dbo].[T_TheCompany_VCompany] c /* daily procedure, rerun to be current!!! */
	inner join [dbo].[V_TheCompany_VCOMPANYADDRESS_PrimaryAddress] a 
		on c.companyid_LN = a.companyid_add
WHERE companyid_LN in (select companyid from [V_TheCompany_LNC_Mig_DATA_COMPANY_TTENDERER_CONTRACTID])

/*  order by 
	c.companytype
	, c.company asc */

GO
/****** Object:  UserDefinedFunction [dbo].[CurrencyAmount]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[CurrencyAmount] ( @currencyId bigint, @exchangeDate datetime = null )
RETURNS TABLE 
AS
RETURN 
(
	SELECT
		a.AmountId,
		case when @currencyId is null or a.CurrencyId = @currencyId then a.Amount
			when r.FROM_DATE > r2.FROM_DATE then ISNULL(a.Amount * r.EXCHANGE_RATE * r.EXCHANGE_FACTOR_TO / r.EXCHANGE_FACTOR_FROM, -1)
			when r.FROM_DATE < r2.FROM_DATE then ISNULL(a.Amount * r2.EXCHANGE_FACTOR_FROM / (r2.EXCHANGE_RATE * r2.EXCHANGE_FACTOR_TO), -1)
			else						  ISNULL(ISNULL(a.Amount * r.EXCHANGE_RATE * r.EXCHANGE_FACTOR_TO / r.EXCHANGE_FACTOR_FROM,
														a.Amount * r2.EXCHANGE_FACTOR_FROM / (r2.EXCHANGE_RATE * r2.EXCHANGE_FACTOR_TO)), -1)

		end as Amount,
		ISNULL(@exchangeDate, a.ExchangeDate) as ExchangeDate,
		a.RealExchangeDate,
		case when @currencyId is null then a.CurrencyId else @currencyId end as CurrencyId

	from TAMOUNT a

	-- r = forward-calculation FROM --> TO
	left join TEXCHANGE_RATE r 
		on  @currencyId is not null
		and r.CURRENCYID_FROM = a.CurrencyId
		and r.CURRENCYID_TO   = @currencyId
		and	r.FROM_DATE       = (select MAX(x.FROM_DATE) from TEXCHANGE_RATE x 
								 where x.FROM_DATE      <=  ISNULL(@exchangeDate, a.ExchangeDate)
								   and x.CURRENCYID_FROM = r.CURRENCYID_FROM 
								   and x.CURRENCYID_TO   = r.CURRENCYID_TO)

	-- r2 = backward-calculation FROM <-- TO
	left join TEXCHANGE_RATE r2 
		on  @currencyId is not null
		and r2.CURRENCYID_FROM = @currencyId
		and r2.CURRENCYID_TO   = a.CurrencyId
		and	r2.FROM_DATE       = (select MAX(x.FROM_DATE) from TEXCHANGE_RATE x 
								  where x.FROM_DATE      <= ISNULL(@exchangeDate, a.ExchangeDate)
								   and x.CURRENCYID_FROM = r2.CURRENCYID_FROM 
								   and x.CURRENCYID_TO   = r2.CURRENCYID_TO)
)
GO
/****** Object:  View [dbo].[VAmountInDefaultCurrency]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[VAmountInDefaultCurrency]
as 
select * 
from CurrencyAmount(
	(select CURRENCYID from TCURRENCY where CURRENCY_CODE = 
	 (select SETTINGVALUE from TPROFILESETTING 
	  where PROFILEKEYID = (select PROFILEKEYID from TPROFILEKEY where FIXED = 'DEFAULT_PRESENTATION_CURRENCY_CODE')
	  and USERID is null 
	  and USERGROUPID is null)),
	default)

GO
/****** Object:  View [dbo].[V_TheCompany_Audittrail_WithHistory_SpecificNumber]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_Audittrail_WithHistory_SpecificNumber]

as 

	select 
		a.TIME
		, a.AUDITTRAILID
		, u.DISPLAYNAME
		,  e.EVENT  
		, a.xml	
	from TAUDITTRAIL a 
		INNER JOIN TAUDITTRAILEVENT e on a.eventid = e.AUDITTRAILEVENTID
		INNER JOIN v_TheCompany_vuser u on a.userid = u.userid
		INNER JOIN TContract c on a.objectid = c.contractid and a.objecttypeid = 1 /* contract */
		/* inner join T_TheCompany_ALL c on a.objectid = c.contractid */
		/* where objectid = 160284 */
		where 
		c.CONTRACTNUMBER = 'CTK-Contract-11119059'
		and eventid <> 4 /* view only */
		and ( /* filter out clutter */
			a.xml like '%expirydate%'
			OR a.xml like '%reviewdate%'
			or a.xml like '%statusid%'
			)

		union all /* Union without ALL fails */

	select 
		a.TIME
		, a.AUDITTRAILID
		, u.DISPLAYNAME
		,  e.EVENT  
		, a.xml	
	from TAUDITTRAIL_HISTORY a 
		INNER JOIN TAUDITTRAILEVENT e on a.eventid = e.AUDITTRAILEVENTID
		INNER JOIN v_TheCompany_vuser u on a.userid = u.userid
		INNER JOIN TContract c on a.objectid = c.contractid and a.objecttypeid = 1 /* contract */
		/* inner join T_TheCompany_ALL c on a.objectid = c.contractid */
		/* where objectid = 160284 */
		where 
		c.CONTRACTNUMBER = 'CTK-Contract-11119059'
		and eventid <> 4 /* view only */
		and ( /* filter out clutter */
			a.xml like '%expirydate%'
			OR a.xml like '%reviewdate%'
			or a.xml like '%statusid%'
			)


GO
/****** Object:  View [dbo].[V_TheCompany_DocsTop3PerContract]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View [dbo].[V_TheCompany_DocsTop3PerContract]
as
select DOCUMENTID,
       OBJECTID,
       DocRowNumber
from (
     select DOCUMENTID,
			OBJECTID,
            row_number() over(partition by T.OBJECTID order by T.DOCUMENTID desc) as DocRowNumber
     from dbo.TDOCUMENT as T
     where MIK_VALID = 1
     ) as T
where T.DocRowNumber <= 3;
GO
/****** Object:  View [dbo].[V_TheCompany_EditDocuments]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_EditDocuments]

as


SELECT 
d.CONTRACTID
, d.DOCUMENTID
, d.Title
, d.[Status]
, d.Datecreated
, d.VersionDate
, d.[FileName]
, d.DOCUMENTTYPE
, t.DocRowNumber
, (CASE WHEN e.CONTRACTID IS NULL THEN 0 ELSE 1 END) AS Edit_Item_Flag
, e.EditNoMax
, x.DupeMinDocIDNonAlpha
, x.DupeCountNonAlpha
FROM VDOCUMENTSCONTRACT d /* inner join TDOCUMENTTYPE dt on d.DOCUMENTTYPEID = dt.DOCUMENTTYPEID */
	LEFT JOIN (SELECT CONTRACTID
				, Max(EditNo) as EditNoMax
				, Count(EditNo) as EditCount 
				FROM T_TheCompany_EDIT_ITEMS /* was V */
				Group By CONTRACTID) e ON d.OBJECTID = e.CONTRACTID
	LEFT JOIN V_TheCompany_DocsTop3PerContract t on d.DOCUMENTID = t.documentid
	LEFT JOIN V_TheCompany_DuplicateDocuments x on d.DOCUMENTID = x.documentid 
WHERE 
	/* x.OBJECTID = 14427 AND */
	d.MIK_VALID=1 
	AND (d.Objectid in (SELECT CONTRACTID FROM  T_TheCompany_EDIT_ITEMS)
		OR d.CONTRACTID in (SELECT CONTRACTID_UNIQUE FROM T_TheCompany_Duplicates_Final))
	
	/* AND 
		/* has a duplicate count >1 */
		(
		(/*x.DupeCountNonAlpha >1 
			AND */ x.OBJECTID IN (SELECT CONTRACTID_UNIQUE /* was CONTRACTID_MIN */ 
													FROM dbo.T_TheCompany_Duplicates_Final))
		OR 
			/* or is edit item, then only top 3 docs */
			(e.CONTRACTID is not null and t.DocRowNumber between 1 and 3)
		) */

GO
/****** Object:  View [dbo].[V_TheCompany_LNC_RIM_DOCUMENTID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[V_TheCompany_LNC_RIM_DOCUMENTID]

as 
	select 
		d.[CONTRACTID]
      ,d.[DOCUMENTID_CTK]
      ,d.[FILEID]
      /*,[VersionDate]
      ,[DateCreated] */
	  ,d.[FileName]
      ,d.[Document_Title]
      ,d.[FileType_Format]
      /*,[FileSize]
      ,[Folder_Status_CannotMigrate]
      ,[OwnerEmail]
      ,[DocumentTags_GapID95]
      ,[CommentsInclFolderAndTags] */
      ,d.[DOCUMENTID]
     /* ,[LastUpdated] 
      ,[MigFolder]
      ,[MigFolder_Sub]
      ,[AgrType_IsHCX_Flag]
      ,[Agr_IsMaterial_Flag]
      ,[ContractStatus]*/
      ,d.[AGREEMENT_TYPE]
      ,d.[contract_type]
      /*,[IsContractOrAmendment]
      ,[DateRefreshed]
      ,[DocumentFileTitlesConcat]  */
      ,d.[Number] as Contract_Number

	  /* contract */
	 /* [CONTRACTID]
      ,[LegacyTheVendorContractNumber]*/
      ,[ContractTitle]
      ,[STATUS] as Contract_Status
      /*,[Created_CONTRACTDATE] 
      ,[STARTDATE]
      ,[EXPIRYDATE]
     /* ,[REVIEWDATE]
      ,[Contract_type]
      ,[Contract_subtype_AGREEMENT_TYPE]
      ,[INTERNALPARTNERID_FirstParty_MAX]
      ,[TheCompanyEntity_FirstPartyMAX]
      ,[Description_COMMENTS]
      ,[TotalMaxValue_LUMP_SUM_AMOUNT]
      ,[Currency_LUMP_SUM_CURRENCY]
      ,[REFERENCECONTRACTID]
      ,[REFERENCE_COUNTERPARTY_NUMBER]
      ,[BusinessUnit_TBD]
      ,[BusinessOwnerEmail_CONTRACT_OWNER]
      ,[ContractSignatoryEmail]
      ,[MaterialContractYN]
      ,[ContractLanguage]
      ,[TERMINATIONPERIOD]
      ,[ACL_AllPermissions_GroupAndUserList] */
      ,[ConfidentialityFlagNAME]
      /*,[LinkToContractRecord]
      ,[DateRefreshed]
      ,[NUMBEROFFILES]
      ,[DocumentFileTitlesConcat]
      ,[AOA_FLAG]
      ,[DELETE_FLAG]
      ,[IsMigratedToLINC_Flag] */*/
	  , c.InternalPartnerList
	  , CompanyList
	  , ConfidentialityFlagNAME

	from [dbo].[V_TheCompany_LNC_GoldStandard_Documents] d 
	inner join [dbo].[V_TheCompany_LNC_GoldStandard] c 
		on d.contractid = c.CONTRACTID

	
GO
/****** Object:  View [dbo].[V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig]

as

	select c.* 
		, Title as 'CONTRACT' /* used field */
		/*, a.AgreementType_IsPrivate_FLAG /* 1 = private */*/
		, a.AgreementType_IsPUBLIC_FLAG /* 1 = public */
	from t_TheCompany_all c /* 66007 vs 65986 rows vs tcontract */
		inner join [dbo].[V_TheCompany_AgreementType] a on c.agreement_typeid = a.agrtypeid
	where
	contractid NOT IN (SELECT CONTRACTID 
							FROM TCONTRACT 
							WHERE CONTRACTTYPEID in (
									/* 6 /* Access SAKSNR number Series*/ no records left Jan-2021 */
									 5 /* Test Old */
									/* INCLUDED: 11 /*Case*/ */
									, 13 /* DELETE */
									, 102 /* Test New */
									, 103 /*file*/
									, 104 /*corp file*/
									, 106 /* AutoDelete */ 
									))
	AND ([COUNTERPARTYNUMBER] IS NULL 
		OR ([COUNTERPARTYNUMBER] not like '!ARIBA%' 
		AND [COUNTERPARTYNUMBER] not like '!AUTODELETE%'))

GO
/****** Object:  View [dbo].[V_TheCompany_LNC_RIM_DATA_Territories]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[V_TheCompany_LNC_RIM_DATA_Territories]
/* 
select territoryid from  [dbo].[V_TheCompany_LNC_Mig_Territories_DATA]
where territoryid not in (select territoryid from V_TheCompany_LNC_Mig_MASTER_Territories)

select count(*) from  [dbo].[V_TheCompany_LNC_Mig_Territories_DATA]
 */

AS 

	select 
	DOCUMENTID
			/*,r.OBJECTID as CONTRACTID
           , d.[departmentid] as TERRITORYID */
      ,[DEPARTMENT] as TerritoryName
	/*	, [L0]
     /* ,[Dpt_Concat_List] */

      ,[NodeType]
      ,[L1]
      ,[L2]
      ,[L3]
      ,[L4]
      ,[LEVEL]
      ,[DEPARTMENT_CODE]
      ,[MIK_SEQUENCE]
      ,[DPT_CODE_2Digit_TerritoryRegion]
      , [NodeRole]
      , [NodeMajorFlag]
      , [DPT_LOWEST_ID_TO_SHOW]
      , [PARENTID]
      , [ISROOT]
      , [FieldCategory]
      , [MIK_VALID]

      , [Parent_Department]*/
	   , GETDATE() as DateRefreshed
	FROM V_TheCompany_VDepartment_territories t
		inner join TDEPARTMENTROLE_IN_OBJECT r 
			on t.DEPARTMENTID = r.DEPARTMENTID 
			and r.objecttypeid = 1 /* contract */
		inner join V_TheCompany_LNC_GoldStandard g 
			on g.contractid = r.OBJECTID 
				inner join V_TheCompany_LNC_GoldStandard_Documents d 
					on g.contractid = d.contractid
	where t.[departmentid] <> 203175 /* N/A */
		and d.[Folder_Status_CannotMigrate]='Signed' /* otherwise too much */
	and [Agr_IsMaterial_Flag] = 1 /* products only for material agreements */
	and d.documentid in (select documentid from [dbo].[V_TheCompany_LNC_RIM_DOCUMENTID])

GO
/****** Object:  View [dbo].[V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig_TSConfidential]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig_TSConfidential]

as

	select * /* 65795 */
	from 
		V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig
	WHERE 
		ConfidentialityFLAG_0123 = 0
		/* UPPER([CONTRACT]) not like '%TOP SECRET%' 
		AND UPPER([CONTRACT]) not like '%CONFIDENTIAL[*]%' */
		/* can now use mig flag since t_TheCompany_all used */
							
GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_DATA_PRODUCTGROUPID_CONTRACTID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view 
[dbo].[V_TheCompany_LNC_Mig_DATA_PRODUCTGROUPID_CONTRACTID]

as
/*
select productgroupid from [dbo].[V_TheCompany_LNC_Mig_PRODUCTGROUPID_CONTRACTID]
where PRODUCTGROUPID not in (select productgroupid [V_TheCompany_LNC_Mig_MASTER_Products])
*/

select
      [CONTRACTID]
	  , [PRODUCTGROUPID]
      ,[PRODUCTGROUP]
      ,[Nomenclature]
	, (case when p.PRODUCTGROUPNOMENCLATUREID = '2' then 'AI'
			when p.PRODUCTGROUPNOMENCLATUREID ='3' then 'TN'
			else 'Other' END) as TN_or_AI
      ,[PRODUCTGROUPCODE]
      ,[PRODUCTGROUPNOMENCLATUREID]
     /* ,[PUBLISH] */
      ,[STATUSID]
	   , GETDATE() as DateRefreshed
  FROM VPRODUCTGROUPS_IN_CONTRACT p
	where contractid in (select CONTRACTID from V_TheCompany_LNC_GoldStandard)

GO
/****** Object:  View [dbo].[V_TheCompany_LNC_RIM_Mig_DATA_PRODUCTGROUPID_DOCUMENTID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view 
[dbo].[V_TheCompany_LNC_RIM_Mig_DATA_PRODUCTGROUPID_DOCUMENTID]

as
/*
select productgroupid from [dbo].[V_TheCompany_LNC_Mig_PRODUCTGROUPID_CONTRACTID]
where PRODUCTGROUPID not in (select productgroupid [V_TheCompany_LNC_Mig_MASTER_Products])
*/

select 
      [DOCUMENTID]
      ,[PRODUCTGROUP]
	  /*
	  , [PRODUCTGROUPID]
      ,[Nomenclature]
	, (case when p.PRODUCTGROUPNOMENCLATUREID = '2' then 'AI'
			when p.PRODUCTGROUPNOMENCLATUREID ='3' then 'TN'
			else 'Other' END) as TN_or_AI
      ,[PRODUCTGROUPCODE]
      ,[PRODUCTGROUPNOMENCLATUREID]
     /* ,[PUBLISH] */
      ,[STATUSID]
	   
	   , d.[Folder_Status_CannotMigrate] as Folder
	   , d.[Agr_IsMaterial_Flag] */
	   , GETDATE() as DateRefreshed
  FROM VPRODUCTGROUPS_IN_CONTRACT p
	inner join  V_TheCompany_LNC_GoldStandard_Documents d on p.contractid = d.contractid
	WHERE p.PRODUCTGROUPNOMENCLATUREID in (2,3)
	and d.[Folder_Status_CannotMigrate]='Signed' /* otherwise too much */
	and [Agr_IsMaterial_Flag] = 1 /* products only for material agreements */
		and d.documentid in (select documentid from [dbo].[V_TheCompany_LNC_RIM_DOCUMENTID])
GO
/****** Object:  View [dbo].[V_TheCompany_LNC_TROLE]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_LNC_TROLE]

as 

select * from V_TheCompany_TROLE
WHERE RoleCategory is not null
GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_NoTS_CFN_CountryAreaRegion]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_T_TheCompany_ALL_NoTS_CFN_CountryAreaRegion]
/* usage: Country area region list workbooks 
\\nycomed.local\shares\AA-Data-Legal-Transfer\Contract_Lists
*/
as

select [Contract Number]
      ,[Contract Description]
	  ,[Agreement Type]
	  ,[Status]         
      ,[Registered Date]
      ,[Reg Date Cat]
      ,[Start Date]
      ,[End Date]
      ,[Review Date]
      ,[Review Date Reminder]
,[All Products]
      /*,[Defined End Date Flag] */
      ,[Number of Attachments]     
      ,[Company Names]
      ,[Company Count]
       , [Confidentiality Flag]
      /*,[Super User Name]*/
      ,[Super User Email]
      /*,[Super User First Name] */
      ,[Super User Primary User Group]
      ,[Super User Active Flag]
      ,[Owner Name]
      ,[Owner Email]
      /*,[Owner First Name]*/
      ,[Owner Primary User Group]
      /*,[Owner Active Flag]
      ,[Responsible Name]*/
      ,[Contract Responsible Email]
      /*,[Responsible First Name]*/
      ,[Responsible Primary User Group]
      /*,[Responsible Active Flag]*/
      ,[Internal Partners]
      ,[Internal Partners Count]
      ,[Territories]
      ,[Territories Count]

      ,[Active Ingredients]
      ,[Trade Names]
      ,[Lump Sum]
      ,[LumpSumCurrency]
	  ,[Tags]
      
      ,[L0]
      ,[L1]
      ,[L2]
      ,[L3]
      ,[L4]
		/*,[Contract Relation]*/
      ,[Contract Type] 
      /*,[Reference Number] */
      ,[Counter Party Reference] /* to see e.g. Procurement Wave flag */
      /* ,[Linked Contract Number]*/
	  ,[CONTRACTID] 
	,p.[Proc_NetFlag]
	,p.[Proc_NetLabel]
      /*,[Product Group Count] */
      ,[LinkToContractURL]
      ,[DateTableRefreshed]
  FROM 
	  V_T_TheCompany_ALL_NoTS_CFN /* [TheVendor_app].[dbo].[V_T_TheCompany_ALL_CommonFN] */ c 
	  inner join [dbo].[V_TheCompany_Mig_0ProcNetFlag] p 
	  /* inner join won't drop records since this table contains all records except for test etc. */
	  on c.contractid = p.contractid_proc



GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_MASTER_VUSER]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_LNC_Mig_MASTER_VUSER]

AS

select 

	[USERINITIAL]
	,[EMAIL]
,[MIK_VALID] 

  /*    ,[PATHID]
      ,[PATH]
      
      ,[EMPLOYEEID] */
     /* ,[COUNTRY] */
    /*  ,[PERSONID]
      ,[PERSONAL_CODE]
      ,[TITLE]
      ,[FIRSTNAME]
      ,[MIDDLENAME]
      ,[LASTNAME]
      ,[INITIALS] */
      ,[DISPLAYNAME]

    /*  ,[COUNTRYID]
      ,[STARTDATE]
      ,[PRIMARYUSERGROUPID] */
      ,[PRIMARYUSERGROUP]
    /*  ,[DEPARTMENTID]
      ,[DEPARTMENT]
      ,[DEPARTMENT_CODE]
      ,[ISEXTERNALUSER]
      ,[DOMAINNETBIOSUSERNAME] 
      ,[USERINITIAL_DOMAINUSERNAME]*/
     /* ,[DOMAINNAME] 
      ,[DOMAINUSERNAME]
      ,[DOMAINUSERSID]*/
    /*  ,[UserProfileID] */
      ,[UserProfile]
      ,[UserProfileGroup]
      ,[UserProfileCategory]
   /*   ,[MANAGEREMPLOYEEID]
      ,[MANAGERPERSONID] 
      ,[PRIMARYMANAGER]*/
     /* ,[USERCATEGORY] */
     /* ,[LegacyDomain] 
      ,[CustomUserGrp_List]*/
	  ,  [USERID]

      ,[NumTotalRolesActive]
	  , [NumTotalRoles_ExclTstDelMig]
	  , [NumTotalRoles_INCL_TstDelMig]
	  , RoleList
      ,[Count_ACL]
	  , GETDATE() as DateRefreshed
	  from [dbo].[V_TheCompany_UserID_CountractRoleCount_VUSER]

GO
/****** Object:  View [dbo].[VCOMMERCIAL]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCOMMERCIAL]
AS
SELECT	CONTRACTID											AS ContractId,
		CONTRACTNUMBER										AS ContractNumber,
		CONVERT(decimal(24, 2), EstimatedValue)				AS EstimatedValue,
		CONVERT(decimal(24, 2), ApprovedBudget)				AS ApprovedBudget,
		CONVERT(decimal(24, 2), LumpSum)					AS LumpSum,
		CONVERT(decimal(24, 2), ReimbExpenseLimit)			AS ReimbExpenseLimit,
		CONVERT(decimal(24, 2), TotalValueOnAward)			AS TotalValueOnAward,
		CONVERT(decimal(24, 2), InvoicedValue)				AS InvoicedValue, 
		CONVERT(decimal(24, 2), BankGuarantee)				AS BankGuarantee,
		CONVERT(decimal(24, 2), ParentCompanyGuarantee)		AS ParentCompanyGuarantee, 
		CONVERT(decimal(24, 2), SumApprovedAmendments)		AS SumApprovedAmendments,
		CONVERT(decimal(24, 2), SumApprovedVO)				AS SumApprovedVO, 
		CONVERT(decimal(24, 2), SumApprovedOrders)			AS SumApprovedOrders,
		CONVERT(decimal(24, 2), InvoiceableCommitment)		AS InvoiceableCommitment,
		case when InvoiceableCommitment = -1 or SumApprovedOrders = -1 
			then -1
			else CONVERT(decimal(24, 2), InvoiceableCommitment - SumApprovedOrders) end
															AS RemainingValue,
        CONVERT(decimal(24, 2), SumOptionalExtentionAmount)		AS SumOptionalExtentionAmount
  FROM	(
		SELECT	CONTRACTID,
				CONTRACTNUMBER,
				EstimatedValue,
				ApprovedBudget,
				LumpSum,
				ReimbExpenseLimit,
				case
					when LumpSum = -1 or ReimbExpenseLimit = -1 then -1
					else ISNULL(LumpSum,0) + ISNULL(ReimbExpenseLimit,0)
				end	as TotalValueOnAward,
				InvoicedValue, 
				BankGuarantee,
				ParentCompanyGuarantee,
				SumApprovedAmendments,
				SumApprovedVO,
				SumApprovedOrders, 
				case when LumpSum = -1 or ReimbExpenseLimit = -1  or SumApprovedAmendments = -1 or SumApprovedVO = -1 or SumOptionalExtentionAmount = -1
					then -1 
					else ISNULL(LumpSum,0) + ISNULL(ReimbExpenseLimit,0) + ISNULL(SumApprovedAmendments,0) + ISNULL(SumApprovedVO,0) + ISNULL(SumOptionalExtentionAmount,0) end AS InvoiceableCommitment,
				SumOptionalExtentionAmount
     		  FROM	(
				SELECT	TC.CONTRACTID,
						TC.CONTRACTNUMBER,
						(
						SELECT	Amount
						  FROM	VAmountInDefaultCurrency			A
						 WHERE	A.AmountID		= TC.EstimatedValueAmountID
						)						AS EstimatedValue,
						(
						SELECT	Amount
						  FROM	VAmountInDefaultCurrency			A
						 WHERE	A.AmountID		= TC.ApprovedValueAmountID
						)						AS ApprovedBudget,
						(
						SELECT	Amount
						  FROM	VAmountInDefaultCurrency			A
						 WHERE	A.AmountID		= TC.LumpSumAmountID
						)						AS LumpSum,
						(
						SELECT	Amount
						  FROM	VAmountInDefaultCurrency			A
						 WHERE	A.AmountID		= TC.ProvisionalSumAmountID
						)						AS ReimbExpenseLimit,
						(
						SELECT	Amount
						  FROM	VAmountInDefaultCurrency			A
						 WHERE	A.AmountID		= TC.InvoicedValueAmountID
						)						AS InvoicedValue,
						(
						SELECT	Amount
						  FROM	VAmountInDefaultCurrency			A
						 WHERE	A.AmountID		= TC.BankGuaranteeAmountID
						)						AS BankGuarantee,
						(
						SELECT	Amount
						  FROM	VAmountInDefaultCurrency			A
						 WHERE	A.AmountID		= TC.ParentCompanyGuaranteeAmountID
						)						AS ParentCompanyGuarantee,
						ISNULL((
						SELECT	case when MIN(VAmountInDefaultCurrency.Amount) = -1 then -1
								else SUM(dbo.VAmountInDefaultCurrency.Amount) end
						  FROM	TAMENDMENT
						  JOIN	VAmountInDefaultCurrency
							ON	VAmountInDefaultCurrency.AmountId	= TAMENDMENT.AmountID
						 WHERE	TC.CONTRACTID		= TAMENDMENT.CONTRACTID
						   AND	TAMENDMENT.STATUSID IN (
								SELECT	STATUSID
								  FROM	dbo.TSTATUS
								 WHERE	FIXED IN ('ACTIVE', 'SIGNED', 'EXPIRED')
								)
						 GROUP	BY
								dbo.TAMENDMENT.CONTRACTID
						), 0)					AS SumApprovedAmendments,
						ISNULL((
							SELECT	case when MIN(VAmountInDefaultCurrency.Amount) = -1 then -1
									else SUM(VAmountInDefaultCurrency.Amount) end
							  FROM	TVO
							  JOIN	TSTATUS S on S.STATUSID = TVO.STATUSID
							  JOIN	VAmountInDefaultCurrency
								ON	VAmountInDefaultCurrency.AmountId	= TVO.SETTLEMENTAMOUNTID
							 WHERE	TC.CONTRACTID		= TVO.CONTRACTID
							   AND  S.FIXED				<> 'CANCELLED'
							 GROUP	BY
									dbo.TVO.CONTRACTID
						), 0)					AS SumApprovedVO,
						ISNULL((
							SELECT	case when MIN(VAmountInDefaultCurrency.Amount) = -1 then -1
									else SUM(VAmountInDefaultCurrency.Amount) end
							  FROM	TORDER
							  JOIN	VAmountInDefaultCurrency
								ON	VAmountInDefaultCurrency.AmountId	= TORDER.AMOUNTID
							 WHERE	TC.CONTRACTID		= TORDER.CONTRACTID
							   AND	TORDER.STATUSID	IN	(
									SELECT	STATUSID
									  FROM	TSTATUS
									 WHERE	FIXED IN ('ACTIVE', 'ORDERED', 'DELIVEREDEXPIRED')
									)
							 GROUP	BY
									dbo.TORDER.CONTRACTID
						), 0)					AS SumApprovedOrders,
						ISNULL((
						SELECT
						     	case when MIN(VAmountInDefaultCurrency.Amount) = -1 then -1
								else SUM(dbo.VAmountInDefaultCurrency.Amount) end
						    	FROM	TOPTION
						  JOIN	VAmountInDefaultCurrency
							ON	VAmountInDefaultCurrency.AmountId	= TOPTION.EstimatedAmountId
						 WHERE	TC.CONTRACTID		= TOPTION.CONTRACTID
						 AND    TOPTION.DECLARED    = 1 
						 GROUP	BY
								TOPTION.CONTRACTID
						), 0)					AS SumOptionalExtentionAmount

				  FROM	dbo.TCONTRACT					TC 
				)										level1
		)												level2


GO
/****** Object:  View [dbo].[V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMigCaseAdmin]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMigCaseAdmin]

as

	select c.* 
		, a.AgreementType_IsPrivate_FLAG /* 1 = private */
		, a.AgreementType_IsPUBLIC_FLAG /* 1 = public */
	from TCONTRACT c inner join [dbo].[V_TheCompany_AgreementType] a on c.agreement_typeid = a.agrtypeid
	where
	contractid NOT IN (SELECT CONTRACTID 
							FROM TCONTRACT 
							WHERE CONTRACTTYPEID in (
									/* 6 /* Access SAKSNR number Series*/ no records left Jan-2021 */
									 5 /* Test Old */
									, 11 /*Case*/
									, 13 /* DELETE */
									, 102 /* Test New */
									, 103 /*file*/
									, 104 /*corp file*/
									, 106 /* AutoDelete */ 
									))
	AND AGREEMENT_TYPEID not in (23 /* Admin - Anti corruption etc. */
			,100283 /* Administration - auditors etc */
			,25 /* Admin - filing case */)
	AND ([COUNTERPARTYNUMBER] IS NULL 
		OR ([COUNTERPARTYNUMBER] not like '!ARIBA%' 
		AND [COUNTERPARTYNUMBER] not like '!AUTODELETE%'))

GO
/****** Object:  View [dbo].[V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMigCaseAdmin_TSConfidential]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMigCaseAdmin_TSConfidential]

as

	select * 
	from 
		V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMigCaseAdmin
	WHERE 
		UPPER([CONTRACT]) not like '%TOP SECRET%' 
		AND UPPER([CONTRACT]) not like '%CONFIDENTIAL[*]%'

GO
/****** Object:  View [dbo].[V_TheCompany_TTag_zzzDetail_TagCategory]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_TTag_zzzDetail_TagCategory]

as

	select top 10000
	
		DOCUMENTID
		/*, t.tagid as TagID */
		, d.TagCategory /* Privacy Shield Remediation */
		/*, d.TagCatShort */
		/*, t.Tag
		, td.Keyword /*, f.FileType */*/
		, d.Title as Document_Title
		/*, d.[filename] as FileName
		, d.Datecreated
		, d.objectid /* CONTRACTID */
		, d.OBJECTTYPEID /* Contract = 1 */*/
		/*, td.tagid as custtagid */
		, count(tagcatid) as CountTagCatID
		, count(tagid) as CountTagID
	from [dbo].[V_TheCompany_TTag_Detail_TagID]  d

	group by DOCUMENTID, TagCategory, Title

GO
/****** Object:  View [dbo].[VCONTRACT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACT]
AS
SELECT     TOP 100 PERCENT dbo.TCONTRACTRELATION.FIXED AS ContractRelationFIXED
	, dbo.TCONTRACT.CONTRACTNUMBER AS Number
	, dbo.TCONTRACT.CONTRACT AS Title
	, dbo.TCONTRACT.STARTDATE
	, dbo.TCONTRACT.EXPIRYDATE
	, dbo.TCONTRACT.REV_EXPIRYDATE AS RevisedExpiryDate
	, dbo.TSTATUS.STATUS
	, dbo.TCONTRACTRELATION.CONTRACTRELATION AS ContractRelations
	, dbo.TCONTRACTTYPE.CONTRACTTYPE
	, dbo.TCONTRACT.AWARDDATE
	, dbo.TCONTRACT.CHECKEDOUTDATE
	, TPERSON_1.DISPLAYNAME AS CheckedOutBy
	, TPERSON_1.DISPLAYNAME AS Executor
	, dbo.TCONTRACT.EXECUTORID
	, dbo.TCONTRACT.CHECKEDOUTBY AS CheckedOutByUserId
	, dbo.TCONTRACT.STATUSID
	, dbo.TSTATUS.FIXED AS StatusFixed
	, dbo.TSTATUS_IN_OBJECTTYPE.MIK_SEQUENCE AS StatusMikSequence
	, dbo.TAGREEMENT_TYPE.AGREEMENT_TYPE
	, (SELECT AwardedCompanyNames from [dbo].[TVF_GetContractAwardedCompanyNames](dbo.TCONTRACT.CONTRACTID)) AS 'COMPANY'
	, dbo.TCOUNTRY.COUNTRY
	, dbo.TADDRESSTYPE.FIXED AS AddressTypeFIXED
	, TUSER_2.USERID
	, dbo.TCOMPANY.COMPANYID
	, dbo.TCONTRACT.CONTRACTID
	, (SELECT     MAX(A.AUDITTRAILID)
		FROM          TAUDITTRAIL A, TOBJECTTYPE O10
		WHERE      A.OBJECTTYPEID = O10.OBJECTTYPEID AND O10.FIXED = 'CONTRACT' AND A.OBJECTID = dbo.TCONTRACT.CONTRACTID) 
    AS AUDITTRAILID
	, dbo.TSTRATEGYTYPE.STRATEGYTYPE AS Method
	, dbo.TSTRATEGYTYPE.FIXED AS MethodFIXED
	, TPERSON_2.FIRSTNAME AS CCFirstName
	, TPERSON_2.MIDDLENAME AS CCMiddleName
	, TPERSON_2.LASTNAME AS CCLastName
	, TPERSON_2.PHONE1 AS CCPhone1
	, TPERSON_2.PHONE2 AS CCPhone2
	, dbo.TCONTRACT.REFERENCECONTRACTNUMBER
	, dbo.TCONTRACT.COUNTERPARTYNUMBER
	, TPERSON_2.DISPLAYNAME AS CCDisplayName
	, dbo.TCONTRACT.PUBLISH
	, TSTATUS_1.STATUS AS ApprovalStatus
	, TSTATUS_1.STATUSID AS ApprovalStatusID
	, TSTATUS_1.FIXED AS ApprovalStatusFixed
	, dbo.TCONTRACT.LASTTASKCOMPLETED as LastTaskCompleted
	, dbo.TCONTRACT.SHAREDWITHSUPPLIER
	FROM         dbo.TPERSON TPERSON_2 
	RIGHT OUTER JOIN dbo.TSTRATEGYTYPE 
		RIGHT OUTER JOIN dbo.TUSER TUSER_2 
			LEFT OUTER JOIN  dbo.TEMPLOYEE ON TUSER_2.EMPLOYEEID = dbo.TEMPLOYEE.EMPLOYEEID 
			RIGHT OUTER JOIN dbo.TCONTRACT 
				LEFT OUTER JOIN  dbo.TSTATUS TSTATUS_1 
					INNER JOIN dbo.TAPPROVALSTATUS_IN_OBJECTTYPE ON TSTATUS_1.STATUSID = dbo.TAPPROVALSTATUS_IN_OBJECTTYPE.APPROVALSTATUSID 
					INNER JOIN dbo.TOBJECTTYPE TOBJECTTYPE_1 ON (dbo.TAPPROVALSTATUS_IN_OBJECTTYPE.OBJECTTYPEID = TOBJECTTYPE_1.OBJECTTYPEID AND TOBJECTTYPE_1.FIXED = N'CONTRACT') 
				ON dbo.TCONTRACT.APPROVALSTATUSID = TSTATUS_1.STATUSID 
				LEFT OUTER JOIN dbo.TSTATUS_IN_OBJECTTYPE 
					INNER JOIN dbo.TSTATUS ON dbo.TSTATUS_IN_OBJECTTYPE.STATUSID = dbo.TSTATUS.STATUSID 
					INNER JOIN dbo.TOBJECTTYPE ON dbo.TSTATUS_IN_OBJECTTYPE.OBJECTTYPEID = dbo.TOBJECTTYPE.OBJECTTYPEID 
				ON dbo.TCONTRACT.STATUSID = dbo.TSTATUS.STATUSID 
				LEFT OUTER JOIN dbo.TCOMPANY 
					LEFT OUTER JOIN dbo.TCOMPANYADDRESS 
						INNER JOIN dbo.TADDRESSTYPE ON dbo.TCOMPANYADDRESS.ADDRESSTYPEID = dbo.TADDRESSTYPE.ADDRESSTYPEID AND dbo.TADDRESSTYPE.FIXED = 'MAINADDRESS' 
						LEFT OUTER JOIN dbo.TCOUNTRY ON dbo.TCOMPANYADDRESS.COUNTRYID = dbo.TCOUNTRY.COUNTRYID 
					ON dbo.TCOMPANY.COMPANYID = dbo.TCOMPANYADDRESS.COMPANYID 
				ON dbo.TCOMPANY.COMPANYID = dbo.udf_get_companyid(dbo.TCONTRACT.CONTRACTID)
				LEFT OUTER JOIN dbo.TCONTRACTTYPE ON dbo.TCONTRACT.CONTRACTTYPEID = dbo.TCONTRACTTYPE.CONTRACTTYPEID 
			ON TUSER_2.USERID = dbo.TCONTRACT.EXECUTORID 
		ON dbo.TSTRATEGYTYPE.STRATEGYTYPEID = dbo.TCONTRACT.STRATEGYTYPEID 
		LEFT OUTER JOIN dbo.TCONTRACTRELATION ON dbo.TCONTRACT.CONTRACTRELATIONID = dbo.TCONTRACTRELATION.CONTRACTRELATIONID 
		LEFT OUTER JOIN dbo.TAGREEMENT_TYPE ON dbo.TCONTRACT.AGREEMENT_TYPEID = dbo.TAGREEMENT_TYPE.AGREEMENT_TYPEID 
	ON TPERSON_2.PERSONID = dbo.TEMPLOYEE.PERSONID 
	LEFT OUTER JOIN dbo.TEMPLOYEE TEMPLOYEE_1 
		RIGHT OUTER JOIN dbo.TUSER TUSER_1 ON TEMPLOYEE_1.EMPLOYEEID = TUSER_1.EMPLOYEEID 
		LEFT OUTER JOIN dbo.TPERSON TPERSON_1 ON TEMPLOYEE_1.PERSONID = TPERSON_1.PERSONID 
	ON dbo.TCONTRACT.CHECKEDOUTBY = TUSER_1.USERID
WHERE     (dbo.TOBJECTTYPE.FIXED = N'CONTRACT')
ORDER BY dbo.TCONTRACT.CONTRACTID


GO
/****** Object:  View [dbo].[V_TheCompany_AUTO_ACL_ContractIDs]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_AUTO_ACL_ContractIDs]

as

/* Internal Partners, 3-digit code */

	select contractid
		, substring([role_department_code],0,4) as Code /* e.g. ',PH' */
		, 3 as Digits
	from [VCONTRACT_DEPARTMENTROLES]
	where contractid in (select contractid 
							from [dbo].[V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMigCaseAdmin_TSConfidential] 
							WHERE AgreementType_IsPUBLIC_FLAG = 0 /* REMOVE IF EDIT PERMISSION BY IP NEEDED IN ADDITION TO READ */
							)
		and SUBSTRING(role_department_code,1,1) = (',') 
		AND role_department_code not like'%N/A%'
		AND UPPER(substring([role_department_code],4,1)) LIKE ('[A-Z]')
		/* AND contractid = 155023  */

		UNION

/* 3-Digit Department Role 4th Char 'A-Z' such as ',DET' - 1 */

	select contractid
		, substring([role_department_code],0,5) as Code /* e.g. ',DET' */
		, 3 as Digits
	from [VCONTRACT_DEPARTMENTROLES]
	where contractid in (select contractid 
							from [dbo].[V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMigCaseAdmin_TSConfidential] 
							WHERE AgreementType_IsPUBLIC_FLAG = 0 /* read only, no permissions needed if public */
							)
		and SUBSTRING(role_department_code,1,1) in (';','-','#','.',':') 
		AND role_department_code not like'%N/A%'
		AND UPPER(substring([role_department_code],4,1)) LIKE ('[A-Z]')
		/* AND contractid = 296959  */

union 

/* 2-Digit Department Role 3rd Char 'A-Z' such as '-MK'  */

	select contractid
	, substring([role_department_code],0,4) as Code /* e.g. '-MK' */
	, 2 as Digits
	from [VCONTRACT_DEPARTMENTROLES]
	where contractid in (select contractid 
							from [dbo].[V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMigCaseAdmin_TSConfidential] 
							WHERE AgreementType_IsPUBLIC_FLAG = 0 /* no permissions needed if public */
							)						
		and SUBSTRING(role_department_code,1,1) in ('-','#',':') 
		AND role_department_code not like';N/A%'
		AND UPPER(substring([role_department_code],3,1)) LIKE ('[A-Z]')
		AND UPPER(substring([role_department_code],4,1)) NOT LIKE ('[A-Z]') /* 3rd Char is not a letter */
		/* AND contractid = 296959 */
	
union 

/* attribute TERRITORY FIELDS to countries: 3-Digit Department Role such as ',EET' becomes ',EE' - 2 */

	select contractid 
	,substring([role_department_code],0,4) as Code
	, 2 as Digits
	from [VCONTRACT_DEPARTMENTROLES]
	where contractid in (select contractid 
							from [dbo].[V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMigCaseAdmin_TSConfidential] 
							WHERE AgreementType_IsPUBLIC_FLAG = 0 /* no permissions needed if public */
							)
		and SUBSTRING(role_department_code,1,1) in (',',';','.')
		AND role_department_code not like ';N/A%'
		AND LEN([role_department_code]) >2
		/* AND contractid = 137246 sample record ,EET */
	
union 

/* Read/Write by Agreement Type - 3 */

	SELECT      
	c.contractid
	, SUBSTRING(a.FIXED,1,3) as Code3Digit /* e.g. !MS */
	, 0 as Digits
	FROM [dbo].[V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMigCaseAdmin_TSConfidential] c 
		INNER JOIN  TAGREEMENT_TYPE a ON c.AGREEMENT_TYPEID = a.agreement_typeid
		INNER JOIN tusergroup u ON SUBSTRING(u.FIXED,6,3) = SUBSTRING(a.FIXED,1,3)
	WHERE  
		AgreementType_IsPUBLIC_FLAG = 0 /* no permissions needed if public */
		AND SUBSTRING(a.FIXED,1,1) = '!' /* active type, or flag for agreement types to tag? ??? */
	/* AND a.FIXED NOT LIKE '%PUBLIC%' cannot do this, as some permissions are 
	WRITE so public will not suffice */

	union 

/* Read/Write by Agreement Type OWNER ARIBA - 3b */
/* remaining issues: do we want Procurement to see our real estate contracts? */
 
	SELECT      
	c.contractid
	, '$AR' as Code3Digit
	, 0 as Digits
	FROM [dbo].[V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMigCaseAdmin_TSConfidential] c 
		INNER JOIN  TAGREEMENT_TYPE a ON c.AGREEMENT_TYPEID = a.agreement_typeid
	WHERE  
		a.FIXED like '%$ARIB%'
		AND AgreementType_IsPUBLIC_FLAG = 0 /* not needed if public */

union 

/* Read/Write by Company = Intercompany Dummy - 4 */

	SELECT      
	c.contractid
	, '!IC' as Code3Digit
	, 0 as Digits
	FROM [dbo].[V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMigCaseAdmin_TSConfidential] c /* not V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMigCaseAdmin since TS case etc. include */
		INNER JOIN  TTENDERER t ON c.contractid = t.CONTRACTID	 
	WHERE   
		t.COMPANYID = 1 /* Intercompany */
		AND AgreementType_IsPUBLIC_FLAG = 0 /* not needed if public */

GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_MASTER_Territories]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view 

[dbo].[V_TheCompany_LNC_Mig_MASTER_Territories]

as

select
      	'CTK-' + ltrim(STR([DEPARTMENTID])) as [TERRITORYID]
	  ,[DEPARTMENT] as TERRITORY_NAME
      ,[DEPARTMENT_CODE] as TERRITORY_CODE
 , [L0]
   /*   ,[Dpt_Concat_List] */

      ,[NodeType]
      ,[L1]
      ,[L2]
      ,[L3]
      ,[L4]
      ,[LEVEL]

      ,[MIK_SEQUENCE]
      ,[DPT_CODE_2Digit_TerritoryRegion]
      ,[NodeRole]
      ,[NodeMajorFlag]
      ,[DPT_LOWEST_ID_TO_SHOW]
      ,[PARENTID]
      ,[ISROOT]
      ,[FieldCategory]
      ,[MIK_VALID]

      ,[Parent_Department]
 , GETDATE() as DateRefreshed
	  from
V_TheCompany_VDepartment_Territories
GO
/****** Object:  View [dbo].[V_TheCompany_VDocumentContractSummary_TS_Included]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_VDocumentContractSummary_TS_Included]

as 

select 
	c.Number as 'ContractNumber'
	, c.Title_InclTopSecret as 'ContractTitle'
	, d.* 
from vdocument d inner join T_TheCompany_All c on d.objectid = c.contractid
/* where 
	c.[Title] not like '%TOP SECRET%' 
	and c.title not like '%STRICTLY CONFIDENTIAL%' */
GO
/****** Object:  View [dbo].[V_TheCompany_VCOMPANY_Contact_GroupByCONTRACTID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_VCOMPANY_Contact_GroupByCONTRACTID]

as 

	select 
		CONTRACTID
		, max(c.CompanyID) as CompanyID_CC_MAX
/*		, SUBSTRING(STUFF(
		(SELECT ',' + s.Email
		FROM VcompanyContact s
		WHERE s.companyid =c.companyid
			and s.email > '' /* otherwise ,,, */
		FOR XML PATH('')),1,1,''),1,255) AS PrimaryCompanyContact_EmailAddressList
		*/
		/*, 		(SELECT count(s.Email)
		FROM VcompanyContact s
		WHERE s.companyid =c.companyid
			and s.email > '') AS PrimaryCompanyContact_EmailAddressCount */
	from VcompanyContact c 
		inner join TTENDERER t 
			on c.CompanyID = t.companyid
	group by t.contractid

GO
/****** Object:  View [dbo].[V_TheCompany_ContractData_JPS_0VCOMPANY_0RAW]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[V_TheCompany_ContractData_JPS_0VCOMPANY_0RAW]

/* 
[dbo].[TheCompany_KeyWordSearch]
- elminiate double spaces
- ltrim, rtrim
*/
as

	select 
		* 
		, UPPER(dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([Company]))
			as Company_LettersNumbersOnly_UPPER

		,  UPPER(replace(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([COMPANY]),'  ',' '))
			as Company_LettersNumbersSpacesOnly_UPPER /* e.g. Hansen & Rosenthal */

		, LEN(replace(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([COMPANY]),'  ',' '))
			- LEN(dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([COMPANY])) 
				as Company_LettersNumbersOnly_NumSpacesWords
		
		, [dbo].[TheCompany_CompanyOrIndividual]([COMPANY]) AS CompanyType

	from T_TheCompany_ContractData_JP_Sunrise_ExecutedAgreements
	WHERE company is not null /* internal partner or company is populated */

GO
/****** Object:  View [dbo].[V_TheCompany_ContractData_JPS_1VCOMPANY]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[V_TheCompany_ContractData_JPS_1VCOMPANY]
/* refreshed via TheCompany_Company_Search */
as

	select 
		c.*
	/*	, [COMPANY] as Company */
		, UPPER([COMPANY]) as Company_UPPER
		, len([COMPANY]) as Company_Length
			, UPPER([dbo].[TheCompany_GetFirstWordInString](Company_LettersNumbersSpacesOnly_UPPER))
		as Company_FirstWord_UPPER

			, UPPER([dbo].[TheCompany_GetFirstWordInString]([Company_LettersNumbersSpacesOnly_UPPER]))
		as Company_FirstWord_LettersOnly_UPPER

			, LEN([dbo].[TheCompany_GetFirstWordInString]([COMPANY])) 
		as Company_FirstWord_LEN

		/* two words or more */
		, UPPER((CASE WHEN [Company_LettersNumbersOnly_NumSpacesWords] = 1 
					THEN [Company_LettersNumbersSpacesOnly_UPPER] /* one space */
				WHEN Company_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN SUBSTRING([Company_LettersNumbersSpacesOnly_UPPER],0,CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
						CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
									   CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],+1)+1)) )	/* e.g. SI Group */	
				ELSE NULL /* no space */ END))			
		as Company_FirstTwoWords_UPPER

		, UPPER((CASE WHEN [Company_LettersNumbersOnly_NumSpacesWords] = 1 /* two words, one space */
					THEN [Company_LettersNumbersOnly_UPPER]
				WHEN Company_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(SUBSTRING([Company_LettersNumbersSpacesOnly_UPPER],0,CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
						CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
									   CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],+1)+1)) ))	/* e.g. SI Group */	
				ELSE NULL /* no space */ END))			
		as Company_FirstTwoWords_LettersOnly_UPPER

			,  LEN((CASE WHEN [Company_LettersNumbersOnly_NumSpacesWords] = 1 /* two words, one space */
					THEN [Company_LettersNumbersOnly_UPPER]
				WHEN Company_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(SUBSTRING([Company_LettersNumbersSpacesOnly_UPPER],0,CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
						CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],
									   CHARINDEX(' ', [Company_LettersNumbersSpacesOnly_UPPER],+1)+1)) ))	/* e.g. SI Group */	
				ELSE NULL /* no space */ END)	)	
		as Company_FirstTwoWords_LettersOnly_LEN

		,UPPER( (CASE WHEN LEN(dbo.TheCompany_GetFirstLetterOfEachWord([Company_LettersNumbersSpacesOnly_UPPER])) >=3 
			AND c.CompanyType = 'C' THEN 
				/* dbo.TheCompany_GetFirstLetterOfEachWord([Company_LettersNumbersOnly_UPPER])
			WHEN LEN(dbo.TheCompany_GetFirstLetterOfEachWord([Company_LettersNumbersOnly_UPPER]))<3 
				and len(left([[Company_LettersNumbersOnly_UPPER],3)) >=3 THEN */
				left([Company_LettersNumbersOnly_UPPER],3)
			ELSE NULL END
			) )
			as Company_FirstLetterOfEachWord_UPPER

	from [dbo].[V_TheCompany_ContractData_JPS_0VCOMPANY_0RAW] c
	/* WHERE c.MIK_VALID = 1 /* and company = 'Svedberg, Agneta' */*/

GO
/****** Object:  View [dbo].[V_TheCompany_Edit_DocAutoRenameCTitle]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_Edit_DocAutoRenameCTitle]

as

	select d.DOCUMENTID
		, d.title as DocTitle
		, LEN(d.title) as DocLen
		, c.NUMBER
		, c.CONTRACTID
		, c.title as ContractTitle 
		, SUBSTRING(c.Title + (CASE WHEN (len(d.Title) = 0 or left(d.Title,8) like right(c.number,8) /* contract number */) 
								THEN '' ELSE ' (' + d.Title + ')' END),1,255) as CTitlePlusDTitle
	FROM VDOCUMENT d 
		inner join V_TheCompany_ALL c on d.OBJECTID = c.contractid
	WHERE len(d.Title) < 12
		and FileType = '.pdf'
		and d.DOCUMENTTYPEid = 1 /* Signed Contracts */
		and d.MIK_VALID = 1
		and CONTRACTID in (select OBJECTID from TDOCUMENT 
							where mik_valid = 1 
							and d.DOCUMENTTYPEID = 1 /* Signed Contracts */
							group by OBJECTID 
							having COUNT(*)=1)


GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_CNT_Tag_ContractID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view

[dbo].[V_TheCompany_KWS_2_CNT_Tag_ContractID]
/* to do: include spaces with Productgroup name */
as 

	SELECT DISTINCT 
		s.*

		, t.objectid as CONTRACTID
		, t.tagcategory
		/* , t.tag */ /* dupes? */


	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		inner join  V_TheCompany_TTag_Detail_TagID t /* OR Tag document id */
			on t.tag = s.KeyWordVarchar255 or t.tagcategory = s.KeyWordVarchar255
	WHERE 
		s.KeyWordType in ('Tag','TagCategory')
		AND OBJECTID is not null

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_3_JPS_TCOMPANY_ContractID_Extended]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view 

[dbo].[V_TheCompany_KWS_3_JPS_TCOMPANY_ContractID_Extended]

as

SELECT 
	[ContractID]
	, [KeyWordVarchar255]
	, [KeyWordVarchar255_UPPER]
      ,[keywordlength]
      ,[keywordFirstWord_UPPER]
      ,[KeyWordFirstWord_LettersOnly_UPPER]
      ,[KeyWordLettersNumbersOnly_UPPER]
      ,[keywordFirstTwoWords_UPPER]
      ,[KeyWordFirstTwoWords_LettersOnly_UPPER]
      ,[KeyWordCustom1]
      ,[KeyWordCustom2]
      ,[KeyWordLettersNumbersSpacesOnly_UPPER]

	 /* Company */
	 /*  , [CompanyID] */
	  , [COMPANY] 	
	  , [CompanyType]

      , [Company_LettersNumbersOnly_UPPER]
      , [Company_LettersNumbersSpacesOnly_UPPER]

	/* Company Matches / Flags */
      , [CompanyMatch_Exact]
      , [CompanyMatch_Exact_Flag]

	/* LIKE */
		, (case when 
			[CompanyMatch_Exact_FLAG] = 0
			AND  [CompanyMatch_LIKE_FLAG] >= [CompanyMatch_FirstTwoWords_FLAG]
			 THEN [CompanyMatch_LIKE] 
			ELSE '' END) 
			as [CompanyMatch_LIKE]

		, (case when 
			[CompanyMatch_Exact_FLAG] = 0
			AND  [CompanyMatch_LIKE_FLAG] >= [CompanyMatch_FirstTwoWords_FLAG]
			 THEN [CompanyMatch_LIKE_FLAG] 
			ELSE 0 END) 
			as [CompanyMatch_LIKE_FLAG]

		/* REV Like */
		, (case when 
			[CompanyMatch_Exact_FLAG] = 0
			AND [CompanyMatch_Like_FLAG] = 0 
			AND [CompanyMatch_FirstWord_FLAG] = 0 /*< [CompanyMatch_REV_LIKE_FLAG] */
			AND [CompanyMatch_FirstTwoWords_FLAG] = 0
			THEN [CompanyMatch_REV_LIKE] 
			ELSE '' END) 
			as [CompanyMatch_REV_LIKE]

		, (case when 
			[CompanyMatch_Exact_FLAG] = 0
			AND [CompanyMatch_Like_FLAG] = 0 
			AND [CompanyMatch_FirstWord_FLAG] = 0 /*< [CompanyMatch_REV_LIKE_FLAG] */
			AND [CompanyMatch_FirstTwoWords_FLAG] = 0
			THEN [CompanyMatch_REV_LIKE_FLAG]
			ELSE 0 END) 
			as [CompanyMatch_REV_LIKE_FLAG]
		
		/* 2-Way LIKE */
			, (case WHEN 
					[CompanyMatch_Exact_FLAG] = 0
					AND [CompanyMatch_Like_FLAG] = 0
					AND [CompanyMatch_REV_LIKE_FLAG] = 0	
					AND [CompanyMatch_FirstWord_FLAG] < [CompanyMatch_LIKE2Way_FLAG]	
					AND [CompanyMatch_FirstTwoWords_FLAG] < [CompanyMatch_LIKE2Way_FLAG]				
				THEN [CompanyMatch_LIKE2Way] 
				ELSE '' END) 
				as [CompanyMatch_LIKE2Way]

			, (case WHEN 
					[CompanyMatch_Exact_FLAG] = 0
					AND [CompanyMatch_Like_FLAG] = 0
					AND [CompanyMatch_REV_LIKE_FLAG] = 0	
					AND [CompanyMatch_FirstWord_FLAG] < [CompanyMatch_LIKE2Way_FLAG]	
					AND [CompanyMatch_FirstTwoWords_FLAG] < [CompanyMatch_LIKE2Way_FLAG]	
				THEN [CompanyMatch_LIKE2Way_FLAG] 
				ELSE 0 END) 
				as [CompanyMatch_LIKE2Way_FLAG]

		/* 2 Way REV Like */
			, (case WHEN 
					[CompanyMatch_Exact_FLAG] = 0
					AND [CompanyMatch_Like_FLAG] = 0
					AND [CompanyMatch_REV_LIKE_FLAG] = 0	
					AND [CompanyMatch_FirstWord_FLAG] = 0
					AND [CompanyMatch_FirstTwoWords_FLAG] = 0
					AND [CompanyMatch_LIKE2Way_FLAG] = 0 
				THEN [CompanyMatch_REV_LIKE2Way] 
				ELSE '' END) 
				as [CompanyMatch_REV_LIKE2Way]

			, (case WHEN 
					[CompanyMatch_Exact_FLAG] = 0
					AND [CompanyMatch_Like_FLAG] = 0
					AND [CompanyMatch_REV_LIKE_FLAG] = 0	
					AND [CompanyMatch_FirstWord_FLAG] = 0
					AND [CompanyMatch_FirstTwoWords_FLAG] = 0
					AND [CompanyMatch_LIKE2Way_FLAG] = 0 
				THEN [CompanyMatch_REV_LIKE2Way_FLAG] 
				 ELSE 0 END) 
				as [CompanyMatch_REV_LIKE2Way_FLAG]

	/* First Two Words */
		, (CASE WHEN 
				[CompanyMatch_Exact_FLAG] = 0
				AND [CompanyMatch_Like_FLAG] < [CompanyMatch_FirstTwoWords_FLAG]
				THEN [CompanyMatch_FirstTwoWords] ELSE '' END)	
				AS [CompanyMatch_FirstTwoWords]

		, (CASE WHEN 
				[CompanyMatch_Exact_FLAG] = 0
				AND [CompanyMatch_Like_FLAG] < [CompanyMatch_FirstTwoWords_FLAG]
					THEN [CompanyMatch_FirstTwoWords_FLAG] ELSE 0 END)	
				AS [CompanyMatch_FirstTwoWords_FLAG]

	/* First Word */

		, (CASE WHEN [CompanyMatch_Exact_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
					AND CompanyMatch_LIKE_FLAG < [CompanyMatch_FirstWord_FLAG] /* more accurate than LIKE */
				THEN [CompanyMatch_FirstWord] 
				 ELSE '' END)
				AS [CompanyMatch_FirstWord]

		, (CASE WHEN [CompanyMatch_Exact_FLAG] = 0
					AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
					AND CompanyMatch_LIKE_FLAG < [CompanyMatch_FirstWord_FLAG]
				 THEN [CompanyMatch_FirstWord_FLAG]
				 ELSE 0 END)
				AS [CompanyMatch_FirstWord_FLAG]

		/* First Word 2-Way */
		, (CASE WHEN 
				[CompanyMatch_Like_FLAG] = 0
				AND [CompanyMatch_FirstWord_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
				and [CompanyMatch_LIKE2Way_FLAG] < [CompanyMatch_FirstWord2Way]
				THEN [CompanyMatch_FirstWord2Way] 
				 ELSE '' END)
				AS [CompanyMatch_FirstWord2Way]

		, (CASE WHEN 
				[CompanyMatch_Like_FLAG] = 0
				AND [CompanyMatch_FirstWord_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
				and [CompanyMatch_LIKE2Way_FLAG] < [CompanyMatch_FirstWord2Way]
				THEN [CompanyMatch_FirstWord2Way_FLAG]
				 ELSE 0 END)
				AS [CompanyMatch_FirstWord2Way_FLAG]
		
		/* First Word 2-Way Reverse */
		, (CASE WHEN 
						[CompanyMatch_Like_FLAG] = 0
				AND [CompanyMatch_FirstWord_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
				and [CompanyMatch_LIKE2Way_FLAG] < [CompanyMatch_FirstWord2Way]
				AND [CompanyMatch_FirstWord2Way_FLAG] = 0
				THEN [CompanyMatch_FirstWord2Way_REV]
				 ELSE '' END)
				AS [CompanyMatch_FirstWord2Way_REV]

		, (CASE WHEN 
						[CompanyMatch_Like_FLAG] = 0
				AND [CompanyMatch_FirstWord_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
				and [CompanyMatch_LIKE2Way_FLAG] < [CompanyMatch_FirstWord2Way]
				AND [CompanyMatch_FirstWord2Way_FLAG] = 0
				THEN [CompanyMatch_FirstWord2Way_REV_FLAG]
				 ELSE 0 END)
				AS [CompanyMatch_FirstWord2Way_REV_FLAG]
	
	/* Other */
	  , [CompanyMatch_EntireKeywordLike_FLAG]	 
	  ,  [CompanyMatch_Abbreviation_Flag]		
		, CompanyMatch_ContainsKeyword
		, CompanyMatch_BeginsWithKeyword

  FROM T_TheCompany_KWS_2_JPS_TCompany_ContractID
	/* from [dbo].[V_TheCompany_KWS_3_TCompany_ContractID] */ 

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_6_JPS_ContractID_UNION]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_KWS_6_JPS_ContractID_UNION]

as

	select contractid /* ,'1' as 'Source' 
		, 'Company' as KeyWordType */
	from V_TheCompany_KWS_3_JPS_TCompany_ContractID_Extended

		UNION ALL /* Union returns nothing if one item has no records */

	select contractid /*,'2'
		, 'Product' /*, [KeyWordVarchar255] as KeyWord */ */
	from V_TheCompany_KWS_3_JPS_TProduct_ContractID_Extended

		UNION ALL /* Union returns nothing if one item has no records */

	select contractid 
	from V_TheCompany_KWS_5c_JPS_DESCRIPTION_ContractID 

		UNION ALL /* Union returns nothing if one item has no records */

	select contractid
	from V_TheCompany_KWS_2_JPS_InternalPartner_ContractID 

		UNION ALL /* Union returns nothing if one item has no records */

	select  contractid
	from T_TheCompany_KWS_2_JPS_Territories_ContractID

		UNION ALL /* Union returns nothing if one item has no records */

	select contractid
	from T_TheCompany_KWS_2_JPS_TCOMPANYCountry_ContractID

	/*	UNION ALL /* Union returns nothing if one item has no records */

	select contractid
	from T_TheCompany_KWS_2_JPS_Tag_ContractID 
	*/
		UNION ALL /* Union returns nothing if one item has no records */

	select ContractID 
	from V_TheCompany_KWS_1_JPS_MiscMetadataFields 

GO
/****** Object:  View [dbo].[V_TheCompany_VUSER_WITH_DPT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_VUSER_WITH_DPT]

as

SELECT
[USERID]
      ,[USERINITIAL]
      ,[USER_MIK_VALID]
      ,[EMPLOYEEID]
      ,NULL AS STARTDATE /* [STARTDATE] removed as of V6.16 */
      ,[LEAVEDATE]
      ,[EMPLOYEE_MIK_VALID]
      , NULL AS COUNTRY /* ,[COUNTRY] removed as of V6.16 */
      ,[PERSONID]
      ,[TITLE]
      ,[FIRSTNAME]
      ,[MIDDLENAME]
      ,[LASTNAME]
      ,[INITIALS]
      ,[DISPLAYNAME]
      ,[EMAIL]
      ,0 AS COUNTRYID /* ,[COUNTRYID] removed as of V6.16 */
      ,[PRIMARYUSERGROUPID]
      ,[PRIMARYUSERGROUP]
      ,u.[DEPARTMENTID]
      ,u.[DEPARTMENT]
      ,[UserProfile]
	, d.department_code
FROM
  VUSER u INNER JOIN TDEPARTMENT d ON d.DEPARTMENTID=u.DEPARTMENTID

GO
/****** Object:  View [dbo].[V_TheCompany_Diligent_zInternalPartners_CompareToCorporateDatasheet]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[V_TheCompany_Diligent_zInternalPartners_CompareToCorporateDatasheet]

as

Select 
	d.DEPARTMENT
	, d.MIK_VALID as Dpt_MIK_VALID
	, g.DptCode_Basic_Text
	, g.DptCode_Basic_LEN
	, d.DEPARTMENT_CODE
	, (CASE WHEN (LEN(p.code_basic)-1 = 3 AND d.MIK_VALID = 1) Then 1 
			WHEN (LEN(p.code_basic)-1 = 3 AND d.MIK_VALID = 0) Then 0
	ELSE NULL END) as CodeBasicValid
	, g.L1,g.L2
from dbo.V_TheCompany_VDEPARTMENT_VUSERGROUP g
	left join TDEPARTMENT d on g.DPT_DEPARTMENTID = d.DEPARTMENTid
	left join dbo.V_TheCompany_Hierarchy h on g.DEPARTMENTID = h.DEPARTMENTID
	left join [dbo].[V_TheCompany_VDepartment_ParsedDpt_InternalPartner] p on g.DEPARTMENTID = p.DEPARTMENTID
	/* left join dbo.V_TheCompany_AUTO_ACL_Upload u on g.USERGROUPID = u.USERGROUPID */
where d.DEPARTMENT_CODE like ',%'
	AND d.DEPARTMENT_CODE not like '%[_]%' /* no underscores, these are old sub departments such as ,BAT_GM */


GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_CNT_InternalPartner_ContractID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view

[dbo].[V_TheCompany_KWS_2_CNT_InternalPartner_ContractID]
/* to do: include spaces with Productgroup name */
as 

	SELECT DISTINCT 
		s.KeyWordVarchar255
		, s.KeyWordVarchar255_UPPER
		, s.KeyWordPrecision
		, s.[KeyWordCustom1]
		, s.[KeyWordCustom2]
		, s.KeyWordSource
		/* , s.KeyWordLettersNumbersSpacesOnly */
		/* , s.KeyWord_ExclusionFlag */

		, t.InternalPartners
		, t.CONTRACTID

	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		inner join t_TheCompany_all t 
			on upper(t.[InternalPartners]) LIKE 
				(CASE WHEN keywordprecision = 'EXACT' THEN
					upper(s.KeyWordVarchar255)
					ELSE
					'%'+ s.KeyWordVarchar255 +'%'
					END)
	WHERE 
		s.KeyWordType = 'InternalPartner'

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_6_CNT_ContractID_UNION]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_KWS_6_CNT_ContractID_UNION]

as

/* removes duplicates if a subquery returns no results */
/* use T_TheCompany_KeyWordSearch_INPUT to filter WHERE automatically */
	select distinct contractid 
	from V_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended

		UNION ALL /* Union returns nothing if one item has no records */
		/* removes records if products not used etc. */
	select DISTINCT contractid
	from V_TheCompany_KWS_2_CNT_InternalPartner_ContractID
	/*WHERE 
		contractid not in (select contractid 
			from V_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended)
		and contractid not in (select contractid 
			from V_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended)*/

UNION ALL /* Union returns nothing if one item has no records */

		/* V_TheCompany_KWS_5c_CNT_DESCRIPTION_ContractID must be edited to match!! */
	select DISTINCT contractid /* dupes 7/5/21*/
	from V_TheCompany_KWS_5c_CNT_DESCRIPTION_ContractID 
	/*  WHERE contractid not in (select contractid 
			from V_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended)
		/*AND contractid not in (select contractid 
			from V_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended)			*/
		AND contractid not in (select contractid 
			from V_TheCompany_KWS_2_CNT_InternalPartner_ContractID) 
			*/
	
			/*
		UNION ALL /* Union returns nothing if one item has no records */

	select  contractid
	from T_TheCompany_KWS_2_CNT_Territories_ContractID */
	
/*		UNION ALL /* Union returns nothing if one item has no records */

	select contractid
	from T_TheCompany_KWS_2_CNT_TCOMPANYCountry_ContractID 
	
		UNION ALL /* Union returns nothing if one item has no records */

/*	select contractid
	from T_TheCompany_KWS_2_CNT_Tag_ContractID 
		*/*/

	/*	UNION ALL /* Union returns nothing if one item has no records */
		
	select ContractID 
	from V_TheCompany_KWS_1_CNT_MiscMetadataFields */
	
GO
/****** Object:  View [dbo].[V_TheCompany_KWS_1_CNT_PROJECT_ContractID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view 
[dbo].[V_TheCompany_KWS_1_CNT_PROJECT_ContractID]

as 

	SELECT  
		s.KeyWordVarchar255
		, s.KeyWordType
		,p.CONTRACTID
		, (case when p.statusid = 5 /* active */ then contractid else null end) as ContractID_Active
	FROM [V_TheCompany_KeyWordSearch] s 
		left join tcontract p on (p.contract like '%[^a-z]'+s.KeyWordVarchar255+'[^a-z]%' 
			/*OR p.contract like '%[ ]'+s.KeyWordVarchar255+'[ ]%' */)
	where /* p.statusid = 5  active */
	s.KeyWordtype = 'Project'

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_CNT_PROJECT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view 
[dbo].[V_TheCompany_KWS_2_CNT_PROJECT]

as 

	SELECT  top 1000
		KeyWordVarchar255, keywordtype
		, count(CONTRACTID) as ContractCount
		, count(contractid_active) as ContractCountActive
	FROM [V_TheCompany_KWS_1_CNT_PROJECT_ContractID]
	group by KeyWordVarchar255, keywordtype
	order by KeyWordVarchar255

GO
/****** Object:  View [dbo].[V_TheCompany_UserID_CountractRoleCount]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_UserID_CountractRoleCount]
as

/* use tuser_in_UOntract table instead? */

select  
	u.userid
	, u.USERINITIAL
	, u.EMPLOYEEID
	, u.PERSONID 
	, u.DISPLAYNAME
	, u.USER_MIK_VALID as MIK_VALID
	, u.STARTDATE
	, u.LEAVEDATE
	, DATEDIFF(mm,startdate,getdate()) as StartDate_NumMths
	, DATEDIFF(mm,leavedate,getdate()) as LeaveDate_NumMths
	, u_SU.*
	, u_UO.*
	, u_UR.*

	, (ISNULL(ContractCount_SU,0) + ISNULL(ContractCount_UO,0) + ISNULL(ContractCount_UR,0)) 
as NumTotalRoles_ExclTstDelMig

, (ISNULL(ContractCountActive_SU,0) + ISNULL(ContractCountActive_UO,0) 
	+ ISNULL(ContractCountActive_UR,0)) 
	as NumTotalRolesActive

, (ISNULL(ContractCountTypeIDCONTRACTActive_SU,0) 
	+ ISNULL(ContractCountTypeIDCONTRACTActive_UO,0) 
	+ ISNULL(ContractCountTypeIDCONTRACTActive_UR,0)) 
	as NumTotalRolesTypeIDCONTRACTActive

,(SELECT COUNT(DISTINCT r.CONTRACTID)
	FROM  [dbo].[V_TheCompany_VPERSONROLE_IN_OBJECT] r
	WHERE r.userid = u.userid /* AND r.ROLEID IN(1,19,20,34,23 /*Super User*/) */
	group by userid
	) AS NumTotalRoles_INCL_TstDelMig

	, ltrim(Replace(STUFF(
		(SELECT '; ' +r.ROLE + ' ('+ltrim(STR(count(r.PERSONROLE_IN_OBJECTID)))+')'
		FROM [dbo].[V_TheCompany_VPERSONROLE_IN_OBJECT] r
		WHERE r.userid = u.userid
		group by r.userid	, r.role	
		FOR XML PATH('')),1,1,''),'&amp;','&') )
	AS RoleList

, Count_ACL

, isnull(Count_Warning,0) as Count_Warning
, isnull(Count_PersonInWarning,0) as Count_PersonInWarning

/* 
,(SELECT COUNT(DISTINCT r.OBJECTID)
	FROM  [dbo].[V_TheCompany_VPERSONROLE_IN_OBJECT] r
	WHERE r.PERSONID = u.personid /* AND r.ROLEID IN(1,19,20,34,23 /*Super User*/) */
	group by personid
	) AS Personid_Personrole_ContractIDCount
	*/
from vuser u left join  /* vuser is used in subsequent table */
	(select p.userid as userid_SU
	, max(c.number) as MaxContractNumber_SU
	, sum(CASE WHEN c.statusid = 5 /*Active*/ THEN 1 ELSE 0 END) as ContractCountActive_SU
	, sum(CASE WHEN c.statusid = 5 /*Active*/ AND c.contracttypeid NOT IN (	  5 /* Test Old */
								, 6 /* Access SAKSNR number Series*/		
								/*,  11	Case */					
								, 13 /* DELETE */
								, 102 /* Test New */								
								, 103, 104, 105 /* Lists */
								, 106 /* AutoDelete */
								) and (c.COUNTERPARTYNUMBER is null 
									or c.COUNTERPARTYNUMBER not like '%!ARIBA%') THEN 1 
									ELSE 0 END) as ContractCountTypeIDCONTRACTActive_SU
	, sum (CASE WHEN c.contractdate > getdate()-90 THEN 1 ELSE 0 END) 
	as ContractCount_Last03Months_SU
	, sum (CASE WHEN c.contractdate > getdate()-365 THEN 1 ELSE 0 END) 
	as ContractCount_Last12Months_SU
	, sum (CASE WHEN c.contractdate > getdate()-1095 THEN 1 ELSE 0 END) 
	as ContractCount_Last36Months_SU
	, count(*) as ContractCount_SU
	from V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig c 
		inner join  [dbo].[V_TheCompany_VPERSONROLE_IN_OBJECT] p 
			on c.CONTRACTID = p.CONTRACTID
			 and p.CONTRACTID = 1 /* contract */
			 and p.[Roleid_Cat2Letter] = 'US' /* super user */
	/* WHERE c.contracttypeid NOT IN (6 /* Access SAKSNR number Series*/
								, 5 /* Test Old */
								, 11 /* Case */
								,102 /* Test New */
								,13 /* DELETE */ 
								, 103, 104, 105 /* Lists */
								) */
	group by p.userid )
u_SU on u.userid = u_SU.userid_SU

left join 
	(select p.userid as userid_UO
	, max(c.number) as MaxContractNumber_UO
	, sum(CASE WHEN c.statusid = 5 /*Active*/ THEN 1 ELSE 0 END) as ContractCountActive_UO
	, sum(CASE WHEN c.statusid = 5 /*Active*/ AND c.contracttypeid NOT IN (	  5 /* Test Old */
								, 6 /* Access SAKSNR number Series*/		
								/*,  11	Case */					
								, 13 /* DELETE */
								, 102 /* Test New */								
								, 103, 104, 105 /* Lists */
								, 106 /* AutoDelete */
								) and (c.COUNTERPARTYNUMBER is null 
									or c.COUNTERPARTYNUMBER not like '%!ARIBA%') THEN 1 
									ELSE 0 END) as ContractCountTypeIDCONTRACTActive_UO
	, sum (CASE WHEN c.contractdate > getdate()-90 THEN 1 ELSE 0 END) 
	as ContractCount_Last03Months_UO
	, sum (CASE WHEN c.contractdate > getdate()-365 THEN 1 ELSE 0 END) 
	as ContractCount_Last12Months_UO
	, sum (CASE WHEN c.contractdate > getdate()-1095 THEN 1 ELSE 0 END) 
	as ContractCount_Last36Months_UO
	, count(*) as ContractCount_UO
	from V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig c 
		inner join  [dbo].[V_TheCompany_VPERSONROLE_IN_OBJECT] p 
			on c.CONTRACTID = p.CONTRACTID
			 and p.CONTRACTID = 1 /* contract */
			 and p.[Roleid_Cat2Letter] = 'US' /* super user */
	/* WHERE c.contracttypeid NOT IN (6 /* Access SAKSNR number Series*/
								, 5 /* Test Old */
								, 11 /* Case */
								,102 /* Test New */
								,13 /* DELETE */ 
								, 103, 104, 105 /* Lists */
								) */
	group by p.userid )
u_UO on u.userid = u_UO.userid_UO

left join 
	(select p.userid as userid_UR
	, max(c.number) as MaxContractNumber_UR
	, sum(CASE WHEN c.statusid = 5 /*Active*/ THEN 1 ELSE 0 END) as ContractCountActive_UR
	, sum(CASE WHEN c.statusid = 5 /*Active*/ AND c.contracttypeid NOT IN (	  5 /* Test Old */
								, 6 /* Access SAKSNR number Series*/		
								/*,  11	Case */					
								, 13 /* DELETE */
								, 102 /* Test New */								
								, 103, 104, 105 /* Lists */
								, 106 /* AutoDelete */
								) and (c.COUNTERPARTYNUMBER is null 
									or c.COUNTERPARTYNUMBER not like '%!ARIBA%') THEN 1 
									ELSE 0 END) as ContractCountTypeIDCONTRACTActive_UR
	, sum (CASE WHEN c.contractdate > getdate()-90 THEN 1 ELSE 0 END) 
	as ContractCount_Last03Months_UR
	, sum (CASE WHEN c.contractdate > getdate()-365 THEN 1 ELSE 0 END) 
	as ContractCount_Last12Months_UR
	, sum (CASE WHEN c.contractdate > getdate()-1095 THEN 1 ELSE 0 END) 
	as ContractCount_Last36Months_UR
	, isnull(count(*),0) as ContractCount_UR
	from V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig c 
		inner join  [dbo].[V_TheCompany_VPERSONROLE_IN_OBJECT] p 
			on c.CONTRACTID = p.CONTRACTID
			 and p.CONTRACTID = 1 /* contract */
			 and p.[Roleid_Cat2Letter] = 'US' /* super user */
	/* WHERE c.contracttypeid NOT IN (6 /* Access SAKSNR number Series*/
								, 5 /* Test Old */
								, 11 /* Case */
								,102 /* Test New */
								,13 /* DELETE */ 
								, 103, 104, 105 /* Lists */
								) */
	group by p.userid )
u_UR on u.userid = u_UR.userid_UR

left join
	(select userid as userid_ACL
	, max(a.OBJECTID) as MaxContractID_ACL
	, count(*) as Count_ACL
	from TACL a 
	group by userid ) 
u_ACL on u.userid = u_ACL.userid_ACL

left join
	(select userid as userid_Warning
	, max(w.OBJECTID) as MaxWarningID
	, count(*) as Count_Warning
	from TWARNING w 
	group by userid ) 
u_w on u.userid = u_w.userid_Warning

left join
	(select personid as personid_Warning
	, max(w.warningid) as MaxWarningID
	, count(*) as Count_PersonInWarning
	from TPERSON_IN_WARNING w 
	group by personid ) 
u_wp on u.personid = u_wp.personid_Warning
GO
/****** Object:  View [dbo].[V_TheCompany_KWS_4_CNT_PROJECT_summary]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view 
[dbo].[V_TheCompany_KWS_4_CNT_PROJECT_summary]

as 

	SELECT  KeyWordVarchar255
	/*	,Replace(STUFF(
		(SELECT ',' + rs.KeyWordVarchar255
		FROM V_TheCompany_KeyWordSearch_Results_PROJECT rs
		where  rs.contracti
		FOR XML PATH('')),1,1,''),'&amp;','&') AS Company_List */
	, sum(contractcount) as ContractCount 
	, sum(contractcountactive) as ContractCountActive
	FROM V_TheCompany_KWS_2_CNT_Project r
	group by r.[KeyWordVarchar255]

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_0Ariba_CompareVendorsToRawDump]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View

[dbo].[V_TheCompany_KWS_0Ariba_CompareVendorsToRawDump]

as

select distinct r.[Affected Parties - Common Supplier]
, (case when  CompanyCountry is null 
	or CompanyCountry = 'United States' 
	or CompanyCountry = ''
	or CompanyCountry like '%Unclassified%'
then 'USA or BLANK' else 'Non-US Country' END) as CompanyIsUS
, r.CompanyCountry
from T_TheCompany_Ariba_Dump_Raw r 
inner join [dbo].[V_TheCompany_KWS_2_ARB_TCOMPANY_ContractID] c 
on r.[Project - Project Id] = c.ContractID
/* WHERE CompanyCountry is null or CompanyCountry = 'United States' */
/* order by r.[Affected Parties - Common Supplier] ASC */


GO
/****** Object:  View [dbo].[V_TheCompany_KWS_ExternalList_ContractID_AddInFields]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create View [dbo].[V_TheCompany_KWS_ExternalList_ContractID_AddInFields]

as

SELECT [contractid]

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT '/ ' + rs.[Company Names] 
			FROM [T_TheCompany_KWS_JT_update] rs
			where  rs.contractid = u.contractid
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [Company Names]
		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT '/ ' + rs.[Status] 
			FROM [T_TheCompany_KWS_JT_update] rs
			where  rs.contractid = u.contractid
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [Status]

  FROM [TheVendor_app].[dbo].[T_TheCompany_KWS_JT_update] u
  group by [CONTRACTID]
GO
/****** Object:  View [dbo].[V_TheCompany_KWS_ContractIDCompareList]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_KWS_ContractIDCompareList]

as

select * from T_TheCompany_KWS_JT_AribaTheVendor_ContractIDs_2019_07
GO
/****** Object:  View [dbo].[V_TheCompany_KWS_9_Results_Frank]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_KWS_9_Results_Frank]
/* be sure to run procedure [TheCompany_KeyWordSearch] to update input tables */
as

	select
	
	 (CASE WHEN s.contractid_kws in (select contractid from V_TheCompany_KWS_ContractIDCompareList) THEN 1 ELSE 0 END) 
		as PreviousList_IsPresent
	, (select [Company Names] + ':  ' + [Status] from V_TheCompany_KWS_ExternalList_ContractID_AddInFields 
		where contractid = s.contractid_kws)
		as PreviousList_Comments

	  /*s.[ContractID_KWS]
      ,[Company_Count]
      ,[CompanyID_Max] */
      , s.[CompanyMatch_Exact]
      ,s.[Custom1_List]
      ,s.[Custom2_List]
      ,s.[CompanyMatch_Fuzzy]
      ,s.[CompanyMatch_All]
      ,s.[Description_Match]
      ,s.[KeyWordMatch_Product_EXACT]
      ,s.[KeyWordMatch_Product_NotExact]
	, d.*
	from [dbo].[V_TheCompany_KWS_4_ContractID_SummaryByContractID] s
		inner join [dbo].[V_T_TheCompany_ALL_CommonFN_StandardList] d 
		on s.contractid_kws = d.contractid
	
	/* WHERE 
		 /* d.[status] = 'Active'
		 and d.[Company Names] <> 'Intercompany TheCompany (Two or more TheCompany Entities)'
		 and d.[Agreement Type] not like '%confidentiality disclosure%'
		AND  */
			(
				/* d.contractid in (select contractid 
							from  [dbo].[V_TheCompany_KeyWordSearch_Results_TPRODUCT_ContractID]) 
				or */ d.contractid in (select contractid 
							from [dbo].[T_TheCompany_KeyWordSearch_Results_TCOMPANY_Contractid]) 
				 /* make sure to refresh T_TheCompany_KeyWordSearch_Results_Description_ContractID */			 
				OR d.contractid in (select contractid 
							from [dbo].[T_TheCompany_KeyWordSearch_Results_DESCRIPTION_ContractID])
						*/
				/* OR d.contractid in (select contractid 
							from [dbo].[V_TheCompany_KeyWordSearch_Results_PROJECT_ContractID]) */


GO
/****** Object:  View [dbo].[V_TheCompany_KWS_4_CNT_PROJECT_summary_gap]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_KWS_4_CNT_PROJECT_summary_gap]

as

	select top 1000 s.KeyWordVarchar255
	,r.ContractCount
	, r.ContractCountActive
	from T_TheCompany_KeyWordSearch s 
	left join V_TheCompany_KWS_4_CNT_PROJECT_summary  r 
	on s.KeyWordVarchar255 = r.KeyWordVarchar255
	where [KeyWordType] = 'Project'  
	order by s.KeyWordVarchar255

GO
/****** Object:  View [dbo].[V_TheCompany_UserID_CountractRoleCount_VUSER_CheckAccess]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_UserID_CountractRoleCount_VUSER_CheckAccess]

as 

SELECT 
	u.USERinitial
	, u.DISPLAYNAME
	, u.USER_MIK_VALID
	, u.DOMAINNETBIOSUSERNAME
		  , u.DOMAINUSERSID
	/*, (CASE WHEN l.LastLoggedInCCS > l.LastLoggedInWin then l.LastLoggedInCCS else l.LastLoggedInWin END) as Dt_Logoff_Max */
	 , (CASE WHEN l.LastLoggedInCCS IS null and l.LastLoggedInWin IS null then NULL
			WHEN l.LastLoggedInCCS is not null and lastloggedinwin is null then 'Web Viewer'
			WHEN l.Lastloggedinccs is null and lastloggedinwin is not null then 'Windows Client'
			WHEN l.Lastloggedinccs is not null and lastloggedinwin is not null then 'Web + Windows Client' 
		else NULL END) as LastAppUsed 
	, u.legacyDomain
      ,l.[CCSAccess]
      ,l.[Active]

      /* ,l.[DisplayName] */
      /* ,l.[UserInitial] */
      /* ,[UserId] 
      ,[Department]*/
      ,l.[LastLoggedInWin]
      ,l.[LastLoggedInCCS]
      ,l.[LoginsWin]
      ,l.[LoginsCCS]
 
      ,l.[ContractsCreated]
      /*,[ProjectsCreated] */
      ,[DocsEdited]
      ,[LastCreatedEditedDoc]
      /* ,[AssessmentsScored]
      ,[ApprovalsDone]
      ,[LastApprovalDone] */
      ,[CountLoginID]
      /* ,[LastAppUsed] */
      ,[Dt_Logon_Max]
      ,[Dt_Logoff_Max] 
      ,[Dt_Lastseen_Max]
  FROM [TheVendor_app].[dbo].[V_TheCompany_UserID_CountractRoleCount] r 
	left join V_TheCompany_VUSER u on r.userid = u.USERID /* inner join better , faster? */
	left join V_TheCompany_User_TLOGON_Last L on r.userid = l.userid
  /* where  MIK_VALID = 1 *//* User Mik Valid, Employee May Differ if 
				someone is still employed but not a TheVendor user anymore */
	where mik_valid = 1
	and PRIMARYUSERGROUP like 'Departments\Legal%'
	/* and LastLoggedInCCS is null 
	and lastloggedinwin is null */

GO
/****** Object:  View [dbo].[V_TheCompany_VDEPARTMENT_VUSERGROUP_MissingSuperUsers]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_VDEPARTMENT_VUSERGROUP_MissingSuperUsers]

as

select TOP 1000 USERGROUP
, dpt_name
, DEPARTMENT_CODE
, PrimaryGroupUserEmails
, PrimaryGroupUserCount
, PrimaryGroupUserSuperEmails
, PrimaryGroupUserSuperCount
, (case when DEPARTMENT_CODE like '%*%' Then '*' ELSE '' END) as DptHasStar1
, (case when DEPARTMENT_CODE like '%**%' Then '**' ELSE '' END) as DptHasStar2
, NodeMajorFlag
, NodeType
/* , MIK_VALID
, dpt_mik_valid */
from 
[dbo].[V_TheCompany_VDEPARTMENT_VUSERGROUP]
where dpt_MIK_VALID = 1 and MIK_VALID = 1
AND L0='Departments' /* and DEPARTMENT_CODE not like ':%' */
order by usergroup


GO
/****** Object:  View [dbo].[V_Jochen_FullJOIN]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View [dbo].[V_Jochen_FullJOIN]

as

	select 
	(CASE WHEN CompanyNew >'' AND CompanyOld >'' THEN 'OldAndNew'
		WHEN CompanyNew >'' AND CompanyOld IS null then 'New'
		WHEN CompanyOld >'' AND CompanyNew IS null then 'Old'
		ELSE 'OTHER' 
		END) as MatchLevel
	, *

	FROM
	[dbo].[T_TheCompany_Jochen2] cn  full join 
	 [dbo].[T_TheCompany_Jochen1] co on dbo.TheCompany_RemoveNonAlphaCharacters(CO.companyold) 
		like '%'+ dbo.TheCompany_RemoveNonAlphaCharacters(Cn.companynew)+'%'
GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_NoTS_CFN_Adhoc]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[V_T_TheCompany_ALL_NoTS_CFN_Adhoc]

as

select 
	 [Contract Number]
      ,[Contract Description] 

,[Agreement Type]
      ,[Company Names]
  , (Case when [Company Names] ='Intercompany TheCompany (Two or more TheCompany Entities)' Then 'Intercompany' ELSE 'Non-Intercompany' END) as IntercompanyFlag
	  ,[Status] 
     /* ,[Registered Date]
      ,[Reg Date Cat]*/
      ,[Start Date]
      ,[End Date]
      ,[Review Date]
      ,[Review Date Reminder]
	,[All Products]
      /*,[Defined End Date Flag] */
      ,[Number of Attachments]
      /*,[Company Count]
      ,[Contract Heading]*/
      /*,[Super User Name]*/
      ,[Super User Email]
      /*,[Super User First Name] */
      ,[Super User Primary User Group]
      ,[Super User Active Flag]
     /* ,[Owner Name] */
      ,[Owner Email]
      , [Owner Primary User Group]
      /*,[Owner First Name]*/


      /*,[Owner Active Flag]
      ,[Responsible Name]*/
      ,[Contract Responsible Email]
      /*,[Responsible First Name]*/
      ,[Responsible Primary User Group]
      /*,[Responsible Active Flag]*/
      ,[Internal Partners]
      ,[Internal Partners Count]
	      ,[Territories]
      ,[Territories Count]
      ,[Active Ingredients]
      ,[Trade Names]
      ,[Lump Sum]
      ,[LumpSumCurrency]
       , [Confidentiality Flag]
	  ,[Tags]
      
      ,[L0]
      ,[L1]
      ,[L2]
      ,[L3]
      ,[L4]
		/*,[Contract Relation]*/
      ,[Contract Type] 
      /*,[Reference Number]
      ,[Counter Party Reference]
      ,[Linked Contract Number]*/
	  ,[CONTRACTID] 
      /*,[Product Group Count] */
      ,[LinkToContractURL]
      ,CONVERT(VARCHAR, [DateTableRefreshed], 120) as DateTableRefreshed

  FROM [TheVendor_app].[dbo].[V_T_TheCompany_ALL_NoTS_CFN]


GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_NoTS_CFN_StandardList]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[V_T_TheCompany_ALL_NoTS_CFN_StandardList]
/* used for TheVendor Keyword search result and merged Ariba table */
as

select

 [Contract Number]
      ,[Contract Description]
	  , [Contract Relation] 
	  , [Agreement Type]
	  /* , [STRATEGYTYPE] */
	  ,[Status]          
      ,[Registered Date]
      ,[Reg Date Cat]
	  , [Reg Dt YYYY-MM]
	  , [Reg Dt Cat Yrs]
	, [Reg Dt Num Mth]
		  , left([Reg Dt YYYY-MM],4) as 'Reg Dt YYYY'
      ,[Start Date]
      ,[End Date]
      ,[Review Date]
      ,[Review Date Reminder]
,[All Products]
      /*,[Defined End Date Flag] */
      ,[Number of Attachments]      
      ,[Company Names]
      ,[Company Count]
       , [Confidentiality Flag]
      /*,[Super User Name]*/
       ,[Super User Email]
      /*,[Super User First Name] */
      ,[Super User Primary User Group]
      ,[Super User Active Flag]
      ,[Owner Name]
      ,[Owner Email]
      /*,[Owner First Name]*/
      ,[Owner Primary User Group]
      /*,[Owner Active Flag]
      ,[Responsible Name]*/
      ,[Contract Responsible Email]
      /*,[Responsible First Name]*/
      ,[Responsible Primary User Group]
      /*,[Responsible Active Flag]*/
     ,[Internal Partners] 
      ,[Internal Partners Count]
      ,[Territories]
      ,[Territories Count]

      ,[Active Ingredients]
      ,[Trade Names]
      ,[Lump Sum]
      ,[LumpSumCurrency]
	  ,[Tags]
      
      ,[L0]
      ,[L1]
      ,[L2]
      ,[L3]
      ,[L4]
		/*,[Contract Relation]*/
      ,[Contract Type] 
	   , convert(varchar, [CONTRACTID]) AS CONTRACTID
      ,[LinkToContractURL]
      ,[DateTableRefreshed]
  FROM [TheVendor_app].[dbo].[V_T_TheCompany_ALL_NoTS_CFN]
GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_TS_STD]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[V_T_TheCompany_ALL_TS_STD]

as

SELECT 

	/* [ContractRelationFIXED] */
		  [Number] as 'Contract Number'

		  /* ,[Title] as 'Contract Description' */
		  , [Title_InclTopSecret] as 'Contract Desc (incl. Top Secret)' /*  [Title_InclTopSecret] as 'Contract Description' */
		  ,[ContractRelations] as 'Contract Relation'

		  , AGREEMENT_TYPE as 'Agreement Type'
		  , [AgreementType_PublicPrivate] as 'Agreement Type Public or Private'
		  , [Agr_IsMaterial_FLAG] as 'Agreement Type Is Material'
		, [ConfidentialityFlagNAME] as 'Confidentiality Flag'
		, [STRATEGYTYPE] as 'HCX (HCP/HCO/PO)'
		  /* ,[CONTRACTTYPEID] as 'Contract Type ID' */
		  /* ,[COMMENTS] */
		  ,[STATUS] as 'Status'
		  , RegisteredDateNumMthCat as 'Reg Date Cat' /* first, so that other dates in sequence */
		,  [RegisteredDate_Within2Years_Label] /* registered in last 2 years */
		, [MigrateToSystem]
		, (case when MigrateYN_Flag = 1 then 'Migrate' else 'Do not migrate' end) as MigrateYN_Flag
		, MigrateYN_Detail
		  ,[CONTRACTDATE] AS 'Registered Date'

	/*  ,[AWARDDATE] as 'Award Date' */
		  ,[STARTDATE] AS 'Start Date'
		  , [STARTDATE_YYYY] as 'Start Dt YYYY'
		  /* ,[EXPIRYDATE] AS 'Original End Date'
		  ,[REV_EXPIRYDATE] AS 'New End Date' */
		  ,[FINAL_EXPIRYDATE] AS 'End Date'
		  ,[REVIEWDATE] AS 'Review Date'
		, [RD_ReviewDate_Warning] as 'Review Date Reminder'
	/*  ,[CHECKEDOUTDATE] */
		  ,[DEFINEDENDDATE] as 'Defined End Date Flag'

		  /* ,[STATUSID] */
		  /* ,[StatusFixed] */
		  ,[NUMBEROFFILES]  as 'Number of Attachments'
	 /* ,[EXECUTORID]
		  ,[OWNERID]
		  ,[TECHCOORDINATORID] */
		  /*  ,[LASTTASKCOMPLETED] as 'Last Task Completed' */
		  /* ,[EDIT_STARTDATE_BLANK]
		  ,[EDIT_EXPIRYDATE_BLANK]
		  ,[EDIT_REV_EXPIRYDATE_BLANK]
		  ,[EDIT_FINAL_EXPIRYDATE_BLANK]
		  ,[EDIT_REVIEWDATE_BLANK]
		  ,[EDIT_NO_ENDDATE_OR_REMINDER]
		  ,[EDIT_NO_PDF_ATTACHMENTS]
		  ,[EDIT_NO_COMPANYID]
		  ,[EDIT_VCONTRACT_FLAG] */
		  /* ,[CheckedOutByUserId] */
		  ,[REFERENCENUMBER] AS 'Reference Number'
		  ,[COUNTERPARTYNUMBER] as 'Counter Party Reference' /* e.g. needed for procurement wave */
		  /* ,[REFERENCECONTRACTID] */
		  ,[REFERENCECONTRACTNUMBER] as 'Linked Contract Number'

		  /* ,[StatusMikSequence] */

		  /* ,[AGREEMENT_TYPEID] */
		  /* ,[AGREEMENT_MIK_VALID] */
		  , [CompanyList] as 'Company Names'
		  /* ,[CompanyIDList] as 'Company IDs' */
		  , [CompanyIDAwardedCount] as 'Company Count'
		, Company_SAP_ID_List
		, Company_SAP_NAME_List
		  /* , [CompanyIDUnawardedCount] as 'Company Count (Unawarded)' */

		  /* ,[INGRESS] */
		 /*  ,[SUMMARYBODY] */
		  /* ,[US_Userid] */
		  ,[US_DisplayName] as 'Super User Name'
		  ,[US_Email] as 'Super User Email'
		  ,[US_Firstname] as 'Super User First Name'
		  ,[US_PrimaryUserGroup] as 'Super User Primary User Group'
		  ,[US_USER_MIK_VALID] as 'Super User Active Flag'
		  /* ,[UO_employeeid] */
		  ,[UO_DisplayName] as 'Owner Name'
		  ,[UO_Email] as 'Owner Email'
		  ,[UO_Firstname] as 'Owner First Name'
		  ,[UO_PrimaryUserGroup] as 'Owner Primary User Group'
		  ,[UO_USER_MIK_VALID] as 'Owner Active Flag'
		  /* ,[UR_employeeid] */
		  ,[UR_DisplayName] as 'Responsible Name'
		  ,[UR_Email] as 'Contract Responsible Email'
		   ,[UR_Firstname] as 'Responsible First Name'
		  ,[UR_PrimaryUserGroup] as 'Responsible Primary User Group'
		  ,[UR_USER_MIK_VALID] as 'Responsible Active Flag'
  

		 /*     ,[SuperUserDpt]
		 ,[SuperUserDpt_ID] 
		   ,[ContractOwnerDpt]
		  ,[ContractOwnerDpt_ID]
		  ,[ContractResponsibleDpt]
		  ,[ContractResponsibleDpt_ID] */
		  ,[InternalPartners] as 'Internal Partners'
		  /* ,[InternalPartners_IDs] */
		  ,[InternalPartners_COUNT] as 'Internal Partners Count'
		  , [InternalPartners_DptCodeList] as 'Internal Partner Dpt Codes'
		  ,[Territories]
		  /* ,[Territories_IDs] */
		  ,[Territories_COUNT] as 'Territories Count'
		  ,[VP_ProductGroups] as 'All Products'
		  ,[VP_ProductGroups_COUNT] as 'Product Group Count'
		  ,[VP_ActiveIngredients] as 'Active Ingredients'
		  ,[VP_TradeNames] as 'Trade Names'
		  /* ,[VP_DirectProcurement]
		  ,[VP_IndirectProcurement] */

		, [LumpSum] as 'Lump Sum'
		, LumpSumCurrency
			, Tags
		  , L0
			, L1
			, L2
			,L3
			, L4
		  ,[CONTRACTTYPE] as 'Contract Type'
			, LinkToContractURL
		  ,[CONTRACTID]
			, DateTableRefreshed

			/* , AGREEMENT_TYPEID */
	/* ,DptCode2Digit_Link */
	FROM
	T_TheCompany_ALL_xt
	where 
	(COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER not like '!ARIBA%') /* no migrated items */

GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_TS_WeeklyEditRpt]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [dbo].[V_T_TheCompany_ALL_TS_WeeklyEditRpt]

as 

select [Number]
      ,[CONTRACTID]
	  ,[Title]
      ,[Title_InclTopSecret]
      ,[CONTRACTTYPE]
      ,[CONTRACTTYPEID]
	  ,[STRATEGYTYPE]
      ,[REFERENCENUMBER]
      ,[CONTRACTDATE]
      ,[AWARDDATE]
      ,[STARTDATE]
      ,[EXPIRYDATE]
      ,[REV_EXPIRYDATE]
      ,[FINAL_EXPIRYDATE]
      ,[REVIEWDATE]
      ,[RD_ReviewDate_Warning]
      ,[STATUS]
      ,[ContractRelations]
      ,[NUMBEROFFILES]
      ,[EXECUTORID]
      ,[OWNERID]
      ,[TECHCOORDINATORID]
      ,[STATUSID]
      ,[StatusFixed]
      ,[REFERENCECONTRACTNUMBER]
      ,[COUNTERPARTYNUMBER]
      ,substring([AGREEMENT_TYPE],0,85) + (case when len(agreement_type)>85 then ' ...' else '' END) 
		as AGREEMENT_TYPE /* otherwise edit report agreement type box too long
		two lines are ok since the title is this long anyway */
      ,[AGREEMENT_TYPEID]
      ,[AGREEMENT_FIXED]
      ,[CompanyList]
      ,[CompanyIDList]
      ,[CompanyIDAwardedCount]
      ,[CompanyIDUnawardedCount]
      ,[CompanyIDCount]
        , [ConfidentialityFlag]
      ,[US_Userid]
      ,[US_DisplayName]
      ,[US_Email]
      ,[US_Firstname]
      ,[US_PrimaryUserGroup]
      ,[US_USER_MIK_VALID]
      ,[US_DPT_CODE]
      ,[US_DPT_NAME]
      ,[UO_employeeid]
      ,[UO_DisplayName]
      ,[UO_Email]
      ,[UO_Firstname]
      ,[UO_PrimaryUserGroup]
      ,[UO_USER_MIK_VALID]
      ,[UO_DPT_CODE]
      ,[UO_DPT_NAME]
      ,[UR_employeeid]
      ,[UR_DisplayName]
      ,[UR_Email]
      ,[UR_Firstname]
      ,[UR_PrimaryUserGroup]
      ,[UR_USER_MIK_VALID]
      ,[UR_DPT_CODE]
      ,[UR_DPT_NAME]
      ,[Dpt_Name_US]
      ,[Dpt_ID_US]
      ,[Dpt_Code_US]
      ,[InternalPartners]
      ,[InternalPartners_IDs]
      ,[InternalPartners_COUNT]
      ,[Territories]
      ,[Territories_IDs]
      ,[Territories_COUNT]
      ,[VP_ProductGroups]
      ,[VP_ProductGroups_IDs]
      ,[VP_ProductGroups_COUNT]
      ,[VP_ActiveIngredients]
      ,[VP_TradeNames]
      ,[VP_DirectProcurement]
      ,[VP_IndirectProcurement]
      ,[LumpSum]
      ,[LumpSumCurrency]
      ,[Region]
      ,[DEPARTMENTID]
      /*,[LEVEL]
      ,[L0]
      ,[L1]
      ,[L2]
      ,[L3]
      ,[L4]
      ,[L5]
      ,[L6]
      ,[L7] 
      ,[DEPARTMENT]
      ,[DEPARTMENT_CONCAT]
      ,[DPT_LOWEST_ID_TO_SHOW]
      ,[DEPARTMENT_CODE]
      ,[DPT_CODE_2Digit_InternalPartner]
      ,[DPT_CODE_2Digit_TerritoryRegion]
      ,[DPT_CODE_2Digit]
      ,[DPT_CODE_FirstChar]
      ,[FieldCategory]
      ,[NodeType]
      ,[NodeRole]
      ,[NodeMajorFlag]
      ,[PARENTID] */
      ,[DateTableRefreshed]
      ,[LinkToContractURL]
      /*,[Procurement_AgTypeFlag]
      ,[Procurement_RoleFlag]
      ,[Tags] */
  FROM [TheVendor_app].[dbo].[T_TheCompany_ALL]
GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_zKeyWordSearch_old]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[V_T_TheCompany_ALL_zKeyWordSearch_old]
/* used for TheVendor Keyword search result and merged Ariba table */
as

select

 [Contract Number]
      ,[Contract Description]
	  , [Contract Relation] 
	  , [Agreement Type]
	  , [Agreement Type Divestment]
	  ,[Status]          
      ,[Registered Date]
      ,[Reg Date Cat]
      ,[Start Date]
      ,[End Date]
      ,[Review Date]
      ,[Review Date Reminder]
	,[All Products]
      /*,[Defined End Date Flag] */
      ,[Number of Attachments]      
      ,[Company Names]
      ,[Company Count]
       , [Confidentiality Flag]
      /*,[Super User Name]*/
       ,[Super User Email]
      /*,[Super User First Name] */
      ,[Super User Primary User Group]
      ,[Super User Active Flag]
      ,[Owner Name]
      ,[Owner Email]
      /*,[Owner First Name]*/
      ,[Owner Primary User Group]
      /*,[Owner Active Flag]
      ,[Responsible Name]*/
      ,[Contract Responsible Email]
      /*,[Responsible First Name]*/
      ,[Responsible Primary User Group]
      /*,[Responsible Active Flag]*/
     ,[Internal Partners] 
      ,[Internal Partners Count]
      ,[Territories]
      ,[Territories Count]

      ,[Active Ingredients]
      ,[Trade Names]
      ,[Lump Sum]
      ,[LumpSumCurrency]
	  ,[Tags]
      
      ,[L0]
      ,[L1]
      ,[L2]
      ,[L3]
      ,[L4]
		/*,[Contract Relation]*/
      ,[Contract Type] 
	   , convert(varchar, [CONTRACTID]) AS CONTRACTID

      ,[LinkToContractURL]
      ,[DateTableRefreshed]

  FROM [TheVendor_app].[dbo].[V_T_TheCompany_ALL_CommonFieldNames] c

GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_zNoTS_CFN_Adhoc_Andrea]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_T_TheCompany_ALL_zNoTS_CFN_Adhoc_Andrea]

as

select 
	  [Agreement Type]
	      ,[Company Names]
	  ,[Contract Number]
      ,[Contract Description]

	  ,[Status]

     /* ,[Registered Date]
      ,[Reg Date Cat]*/
      ,[Start Date]
      ,[End Date]
      ,[Review Date]
      ,[Review Date Reminder]
,[All Products]
      /*,[Defined End Date Flag] */
      ,[Number of Attachments]

      
  
      /*,[Company Count]
      ,[Contract Heading]*/
      /*,[Super User Name]*/
      ,[Super User Email]
      /*,[Super User First Name] */
      ,[Super User Primary User Group]
      ,[Super User Active Flag]
      ,[Owner Name]
      ,[Owner Email]
      /*,[Owner First Name]*/
      ,[Owner Primary User Group]
      /*,[Owner Active Flag]
      ,[Responsible Name]*/
      ,[Contract Responsible Email]
      /*,[Responsible First Name]*/
      ,[Responsible Primary User Group]
      /*,[Responsible Active Flag]*/
      ,[Internal Partners]
      ,[Internal Partners Count]
      ,[Territories]
      ,[Territories Count]

      ,[Active Ingredients]
      ,[Trade Names]
      ,[Lump Sum]
      ,[LumpSumCurrency]
       , [Confidentiality Flag]
	  ,[Tags]
      
      ,[L0]
      ,[L1]
      ,[L2]
      ,[L3]
      ,[L4]
		/*,[Contract Relation]*/
      ,[Contract Type] 
      /*,[Reference Number]
      ,[Counter Party Reference]
      ,[Linked Contract Number]*/
	  ,[CONTRACTID] 
      /*,[Product Group Count] */
      ,[LinkToContractURL]
      ,[DateTableRefreshed]
  FROM [TheVendor_app].[dbo].[V_T_TheCompany_ALL_CommonFN]
GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_zNoTS_CFN_Adhoc_AndreaH]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_T_TheCompany_ALL_zNoTS_CFN_Adhoc_AndreaH]

as

select 
      [Owner Primary User Group]
,[Agreement Type]
      ,[Company Names]
	, [Contract Number]
      ,[Contract Description] 
	  ,[Status] 
     /* ,[Registered Date]
      ,[Reg Date Cat]*/
      ,[Start Date]
      ,[End Date]
      ,[Review Date]
      ,[Review Date Reminder]
,[All Products]
      /*,[Defined End Date Flag] */
      ,[Number of Attachments]
      /*,[Company Count]
      ,[Contract Heading]*/
      /*,[Super User Name]*/
      ,[Super User Email]
      /*,[Super User First Name] */
      ,[Super User Primary User Group]
      ,[Super User Active Flag]
      ,[Owner Name]
      ,[Owner Email]
      /*,[Owner First Name]*/


 	  , ( case when [Owner Primary User Group] not in (
'Departments\EUCAN',
'Departments\EUCAN\EUCAN Departments\Patient Value & Access (EUCAN)',
'Departments\EUCAN\EUCAN Departments\Operational Excellence (EUCAN)',
'Departments\EUCAN\EUCAN Departments\Insights & Analytics',
'Departments\EUCAN\EUCAN Departments\Oncology (EUCAN)',
'Departments\EUCAN\EUCAN Departments\Medical Affairs (EUCAN)') THEN 'EXCLUDE' ELSE 'INCLUDE' END) as FlagTpizInclude

      /*,[Owner Active Flag]
      ,[Responsible Name]*/
      ,[Contract Responsible Email]
      /*,[Responsible First Name]*/
      ,[Responsible Primary User Group]
      /*,[Responsible Active Flag]*/
      ,[Internal Partners]
      ,[Internal Partners Count]
      ,[Territories]
      ,[Territories Count]
      ,[Active Ingredients]
      ,[Trade Names]
      ,[Lump Sum]
      ,[LumpSumCurrency]
	  ,[Tags]
      
      ,[L0]
      ,[L1]
      ,[L2]
      ,[L3]
      ,[L4]
		/*,[Contract Relation]*/
      ,[Contract Type] 
      /*,[Reference Number]
      ,[Counter Party Reference]
      ,[Linked Contract Number]*/
	  ,[CONTRACTID] 
      /*,[Product Group Count] */
      ,[LinkToContractURL]
      ,CONVERT(VARCHAR, [DateTableRefreshed], 120) as DateTableRefreshed
	  , (Case when [Company Names] ='Intercompany TheCompany (Two or more TheCompany Entities)' Then 'Intercompany' ELSE 'Non-Intercompany' END) as IntercompanyFlag
  FROM [TheVendor_app].[dbo].[V_T_TheCompany_ALL_CommonFieldNames]
  where status in ('Active','Awarded')
  and ([Company Names] is null or [Company Names] <> 'Intercompany TheCompany (Two or more TheCompany Entities)')
 and [Owner Primary User Group] in (
	'Departments\EUCAN',
	'Departments\EUCAN\EUCAN Departments\Patient Value & Access (EUCAN)',
	'Departments\EUCAN\EUCAN Departments\Operational Excellence (EUCAN)',
	'Departments\EUCAN\EUCAN Departments\Insights & Analytics',
	'Departments\EUCAN\EUCAN Departments\Oncology (EUCAN)',
	'Departments\EUCAN\EUCAN Departments\Medical Affairs (EUCAN)')

GO
/****** Object:  View [dbo].[V_TheCompany_0IssueToFix_ACLPriv3Missing]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create View [dbo].[V_TheCompany_0IssueToFix_ACLPriv3Missing]

as


select objectid, OBJECTTYPEID 
, count(ACLID) as Count
, sum(CASE WHEN PRIVILEGEID = 3 THEN 1 ELSE 0 END) as CountPriv3
from tacl
group by objectid, OBJECTTYPEID
having sum(CASE WHEN PRIVILEGEID = 3 THEN 1 ELSE 0 END) = 0
GO
/****** Object:  View [dbo].[V_TheCompany_Adhoc_ContractsNoEndDate]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_Adhoc_ContractsNoEndDate]

as 

	select *
		, left([dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]([TheCompany entity/first party]),255) 
			as TheCompany_EntityNonFwSlash
		, left([dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash](upper([TheCompany entity/first party])),255) 
			as TheCompany_EntityNonFwSlash_UPPER
		, left(Replace([reference],'Nycomed','Nyco'),255) as ReferenceNycoClean
	from [dbo].[T_TheCompany_Adhoc_ContractsNoEndDate]
	 WHERE 
		(reference Like 'CTK%'
		or reference like 'CON%')
		AND Amendment = 'No' 
	
GO
/****** Object:  View [dbo].[V_TheCompany_Ariba_Dump_Raw_FLAT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_Ariba_Dump_Raw_FLAT]

as

	SELECT DISTINCT
	[Project - Project ID] as [ContractInternalID]
	,max([Contract Id]) AS ContractNumber
	, count([Project - Project Id]) as ContractID_Count
	, Max([Project - Project Name]) as [Project - Project Name]
	, Max(isnull([Description],'')) as [Contract Description]
	, Max([Hierarchy Type]) as [Hierarchy Type]

	, Max([Parent Agreement - Project Name]) as [Parent Agreement - Project Name]
	, Max([Parent Agreement - Project Id]) as [Parent Agreement - Project Id]

	/* , Max([Parent Project - Project Id]) as [Parent Project - Project Id] */ /* field does not exist */

	, MAX([Process - Process]) as [Process - Process] /* many 'unclassified' or e.g. 'approve and publish' */

	/* , Max([Storage Identifier]) as [Storage Identifier] */
	/* , Max([Storage Location]) as [Storage Location] */
	, Max([Study Number]) as [Study Number]

	, Max((case when [Contract Status]='Expired' THEN 'Expired' ELSE [State] END)) as [State] /* should not be used per Mark and Mitch, summarizes contract status column */
	, Max([Contract Status]) as [Contract Status]  /*   use state column, has value 'published' */

	/*, Max([Registered Date]) as [Registered Date]*/
	, (CASE WHEN isdate(max([Begin Date]))=1 THEN max([Begin Date]) ELSE NULL END) as [Begin Date] /* some dates have the value 'unclassified' */
	, (CASE WHEN isdate(max([Effective Date - Date]))=1 THEN max([Effective Date - Date]) ELSE NULL END) as [Effective Date - Date]
	, (CASE WHEN isdate(max([End Date - Date]))=1 THEN max([End Date - Date]) ELSE NULL END) as [End Date - Date]
	, (CASE WHEN isdate(max([Due Date - Date]))=1 THEN max([Due Date - Date]) ELSE NULL END) as [Due Date - Date]
	, (CASE WHEN isdate(max([Expiration Date - Date]))=1 THEN max([Expiration Date - Date]) ELSE NULL END) as [Expiration Date - Date]

	, Max([sum(Contract Amount)]) as [Amount_EUR]
	/*, 'EUR' as Currency*/
	, Max([Contract Type]) as [Contract Type]
	, Max([Additional Comments]) as [Additional Comments]

	/* CONTRACTING LEGAL ENTITY only one value possible in this field so it is not necessary to concatenate anything */
	/* for TheVendor legacy contracts that have two or more internal partners, the other entities are added to the 'Additional Comments' such as e.g. CNTK_Contract-00007897 */
		, Max([Contracting Legal Entity]) as [Contracting Legal Entity] 


		 /* [Contract Signatory - User] */
			,LTRIM(Replace(SUBSTRING(STUFF(
			(SELECT DISTINCT ', ' + s.[Contract Signatory - User]
			FROM [dbo].[T_TheCompany_Ariba_Dump_Raw] s
			WHERE s.[Project - Project Id]  =d.[Project - Project Id] 
			FOR XML PATH('')),1,1,''),1,255),'&amp;','&')) AS [Contract Signatory - User Concat]
	/*, Max([Contract Signatory - User]) as [Contract Signatory - User] */

		 /* , Max([Owner Name]) as [Owner Name] */
			,LTRIM(Replace(SUBSTRING(STUFF(
			(SELECT DISTINCT ', ' + s.[Owner Name]
			FROM [dbo].[T_TheCompany_Ariba_Dump_Raw] s
			WHERE s.[Project - Project Id]  =d.[Project - Project Id]
			FOR XML PATH('')),1,1,''),1,255),'&amp;','&')) AS [Owner Name Concat]

	/*, Max([Business Owner - User]) as [Business Owner - User] */
		 /* , Max([Owner Name]) as [Owner Name] */
			,LTRIM(Replace(SUBSTRING(STUFF(
			(SELECT DISTINCT ', ' + s.[Business Owner - User] 
			FROM [dbo].[T_TheCompany_Ariba_Dump_Raw] s
			WHERE s.[Project - Project Id]  =d.[Project - Project Id]
			FOR XML PATH('')),1,1,''),1,255),'&amp;','&')) AS [Business Owner - User] 

		 /* [Region - Region] */
			,LTRIM(Replace(SUBSTRING(STUFF(
			(SELECT DISTINCT ', ' + s.[Region - Region]
			FROM [dbo].[T_TheCompany_Ariba_Dump_Raw] s
			WHERE s.[Project - Project Id]  =d.[Project - Project Id]
			FOR XML PATH('')),1,1,''),1,255),'&amp;','&')) AS [Region - Region Concat]

			,(SELECT COUNT(DISTINCT s.[Region - Region])
			FROM [dbo].[T_TheCompany_Ariba_Dump_Raw] s
			WHERE s.[Project - Project Id]  =d.[Project - Project Id]
			GROUP BY s.[Project - Project Id]) AS [Region - Region Count]

					,LTRIM(Replace(SUBSTRING(STUFF(
			(SELECT DISTINCT ', ' + s.[Regional Department]
			FROM [dbo].[T_TheCompany_Ariba_Dump_Raw] s
			WHERE s.[Project - Project Id]  =d.[Project - Project Id]
			FOR XML PATH('')),1,1,''),1,255),'&amp;','&')) AS [Regional Department]

							,LTRIM(Replace(SUBSTRING(STUFF(
			(SELECT DISTINCT ', ' + s.[Organization - Department (L1)]
			FROM [dbo].[T_TheCompany_Ariba_Dump_Raw] s
			WHERE s.[Project - Project Id]  =d.[Project - Project Id]
			FOR XML PATH('')),1,1,''),1,255),'&amp;','&')) AS [Organization - Department (L1)]

		/* Commodity */
		
			,LTRIM(Replace(SUBSTRING(STUFF(
			(SELECT DISTINCT ', ' + s.[Commodity - Commodity]
			FROM [dbo].[T_TheCompany_Ariba_Dump_Raw] s
			WHERE s.[Project - Project Id]  =d.[Project - Project Id]
			FOR XML PATH('')),1,1,''),1,255),'&amp;','&')) AS [Commodity - Commodity Concat]

			,(SELECT COUNT(DISTINCT s.[Commodity - Commodity ID])
			FROM T_TheCompany_Ariba_Dump_Raw s
			WHERE s.[Project - Project Id]  =d.[Project - Project Id]
			GROUP BY s.[Project - Project Id]) AS [Commodity - Commodity ID Count]


			/* Affected Parties - Common Supplier
	Affected Parties - Common Supplier ID */

			,LTRIM(Replace(SUBSTRING(STUFF(
			(SELECT DISTINCT ', ' + s.AllSupplier /* was  [Affected Parties - Common Supplier Concat] */
			FROM T_TheCompany_Ariba_Dump_Raw s
			WHERE s.[Project - Project Id]  = d.[Project - Project Id]
				and s.[Affected Parties - Common Supplier]  NOT LIKE N'%[А-Я]%' /* Cyrillic, erratic results */
			FOR XML PATH('')),1,1,''),1,255),'&amp;','&')) AS [Affected Parties - Common Supplier Concat]

			,LTRIM(Replace(SUBSTRING(STUFF(
			(SELECT DISTINCT ', ' + s.[Affected Parties - Common Supplier ID]
			FROM T_TheCompany_Ariba_Dump_Raw s
			WHERE s.[Project - Project Id]  = d.[Project - Project Id] 
				and s.[Affected Parties - Common Supplier]  NOT LIKE N'%[А-Я]%' /* Cyrillic, erratic results */
			FOR XML PATH('')),1,1,''),1,255),'&amp;','&')) AS [Affected Parties - Common Supplier ID Concat]

			,(SELECT COUNT(DISTINCT s.[Affected Parties - Common Supplier])
			FROM T_TheCompany_Ariba_Dump_Raw s
			WHERE s.[Project - Project Id]  =d.[Project - Project Id]
				and s.[Affected Parties - Common Supplier]  NOT LIKE N'%[А-Я]%' /* Cyrillic, erratic results */
			GROUP BY s.[Project - Project Id]) AS [Affected Parties - Common Supplier Count]

			,LTRIM(Replace(SUBSTRING(STUFF(
			(SELECT DISTINCT ', ' + s.[AllSupplier]
			FROM T_TheCompany_Ariba_Dump_Raw s
			WHERE s.[Project - Project Id]  =d.[Project - Project Id]
				and s.[Affected Parties - Common Supplier]  NOT LIKE N'%[А-Я]%' /* Cyrillic, erratic results */
			FOR XML PATH('')),1,1,''),1,255),'&amp;','&')) AS [AllSupplier Concat]

	, max('https://s1.ariba.com/Sourcing/Main/ad/viewDocument?ID='+ convert(varchar,[Project - Project ID] )) as [LinkToContractURL]
	, GetDate() as [DateTableRefreshed]


		,LTRIM(Replace(SUBSTRING(STUFF(
			(SELECT DISTINCT ', ' + t.TAG
			FROM T_TheCompany_Ariba_TTAG_IN_ContractInternalID s
				inner join TTAG t on s.tagid = t.tagid
			WHERE s.[contractinternalid]  =d.[Project - Project Id]
			FOR XML PATH('')),1,1,''),1,255),'&amp;','&')) AS Tags
	FROM  [dbo].[T_TheCompany_Ariba_Dump_Raw] d
	GROUP BY d.[Project - Project Id]
	/* having count([Commodity - Commodity ID])>1 */

GO
/****** Object:  View [dbo].[V_TheCompany_Ariba_Suppliers_SAPID_Country_VALID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_Ariba_Suppliers_SAPID_Country_VALID]

as

select TOP 100 percent *
from [T_TheCompany_Ariba_Suppliers_SAPID_Country_AllFields]
WHERE [Sup_Name_ValidString_FLAG] = 1 /* no special char(63) Russian Chine Char found  */
order by [Sup_Name_SAP_LEN] desc
GO
/****** Object:  View [dbo].[V_TheCompany_AribaDump]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view  [dbo].[V_TheCompany_AribaDump]

as 

select 

 * 
  FROM V_TheCompany_AribaDump_ExcelListView
GO
/****** Object:  View [dbo].[V_TheCompany_AribaDump_ParentHierarchy_SOW_SubAgreement]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View [dbo].[V_TheCompany_AribaDump_ParentHierarchy_SOW_SubAgreement]

as
/* MSA and SOW Hierarchy parent/child */
select a.ContractInternalID, a.[Project - Project Name], a.[Contract Description] 
		, a.[Contract Type], a.[Hierarchy Type]

		 ,a2.ContractInternalID as L2ID, a2.[Project - Project Name] as L2ProjectName, a2.[Contract Description] as L2Description
		 , a2.[Contract Type] as L2ContractType , a2.[Hierarchy Type] as L2HierarchyType

		 ,a3.ContractInternalID as L3ID, a3.[Project - Project Name] as L3ProjectName, a3.[Contract Description] as L3Description
		 , a3.[Contract Type] as L3ContractType , a3.[Hierarchy Type] as L3HierarchyType
	from T_TheCompany_AribaDump a
		left join  T_TheCompany_AribaDump a2 on a.[Parent Agreement - Project Id] =a2.ContractInternalID
		left join  T_TheCompany_AribaDump a3 on a2.[Parent Agreement - Project Id] =a3.ContractInternalID
	where a.[Contract Type] like 'sow%'
		and a.[Hierarchy Type] = 'Sub Agreement'
GO
/****** Object:  View [dbo].[V_TheCompany_Audittrail_ModLast30DaysMin1DayOld]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_Audittrail_ModLast30DaysMin1DayOld]

as 

select DISTINCT OBJECTID, objecttypeid 
from TAUDITTRAIL
where 
	time between dateadd(dd,-30,GETDATE()) and dateadd(dd,-1,GETDATE()) /* older than one day so that no crashes while contract registered, but older than 30 days */
	and OBJECTTYPEID in (1,7)
	and eventid in ( 1 /* create */, 2 /* change */, 3 /* delete */)
GO
/****** Object:  View [dbo].[V_TheCompany_Audittrail_WithHistory]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_Audittrail_WithHistory]

as 

	select * from TAUDITTRAIL 

	union all 

	select * from TAUDITTRAIL_HISTORY
GO
/****** Object:  View [dbo].[V_TheCompany_AUTO_ACL_Upload]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_AUTO_ACL_Upload]

as
/* CONTRACT OWNER */

	/* CO READ Privilege 1*/
		SELECT USERGROUPID
		, USERGROUP
		, FIXED
		,'.'+(Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN substring([FIXED],7,3)  ELSE  substring([FIXED],7,2) END) AS Code3Digit
		, 'Code_Owner' as Field
		,'Contract Owner' as Role
		, (Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN '4Digit'  ELSE  '3Digit' END) as CodeNumber
		, cast(1 as varchar(1)) as Privilege
		FROM TUSERGROUP
		WHERE 
		MIK_VALID=1 
		AND FIXED like '%_co%'
		AND FIXED like 'AUTO%'

	UNION

	/* CO WRITE Privilege 2*/
	/* Commented out 29-01-2021 - no person permissions anymore and no edit right for owner , and contract owner is not super user
	SELECT USERGROUPID
	, USERGROUP
	, FIXED
	,'.'+(Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN substring([FIXED],7,3)  ELSE  substring([FIXED],7,2) END) AS Code3Digit
	, 'Code_Owner' as Field
	,'Contract Owner' as Role
	, (Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN '4Digit'  ELSE  '3Digit' END) as CodeNumber
	, cast(2 as varchar(1)) as Privilege
	FROM TUSERGROUP
	WHERE 
	MIK_VALID=1 
	AND FIXED like '%_co%'
	AND FIXED like 'AUTO%'
	

UNION */

/*INTERNAL PARTNER*/

	/*IP READ = 1 */
	SELECT USERGROUPID
	, USERGROUP
	, FIXED
	,','+(Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN substring([FIXED],7,3)  ELSE  substring([FIXED],7,2) END) AS Code3Digit
	, 'Code_Partner' as Field
	,'Internal Partner' as Role
	, (Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN '4Digit'  ELSE  '3Digit' END) as CodeNumber
	, cast(1 as varchar(1)) as Privilege
	FROM TUSERGROUP
	WHERE 
	MIK_VALID=1 
	AND FIXED like '%_ip%'
	AND FIXED like 'AUTO%'

	UNION 

	/*IP WRITE = 2 */
	SELECT USERGROUPID
	, USERGROUP
	, FIXED
	,','+(Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN substring([FIXED],7,3)  ELSE  substring([FIXED],7,2) END) AS Code3Digit
	, 'Code_Partner' as Field
	,'Internal Partner' as Role
	, (Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN '4Digit'  ELSE  '3Digit' END) as CodeNumber
	, cast(2 as varchar(1)) as Privilege
	FROM TUSERGROUP
	WHERE 
	MIK_VALID=1 
	AND FIXED like '%_ip%'
	AND FIXED like 'AUTO%'

UNION

/* TERRITORY */

	SELECT USERGROUPID
	, USERGROUP
	, FIXED
	,';'+substring([FIXED],7,2) AS Code3Digit
	, 'Code_Territory' as Field
	,'Territory_Country' as Role
	,'3Digit' as CodeNumber
	, cast(1 as varchar(1)) as Privilege
	FROM TUSERGROUP
	WHERE 
	MIK_VALID=1 
	AND FIXED like '%[_][t][t][_]%'
	AND FIXED like 'AUTO%'



UNION

/* DEPARTMENT */

	SELECT USERGROUPID
	, USERGROUP
	, FIXED
	,'-'+(Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN substring([FIXED],7,3)  ELSE  substring([FIXED],7,2) END) AS Code3Digit
	, 'Code_Department' as Field
	,'Contract Owner' as Role
	, (Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN '4Digit'  ELSE  '3Digit' END) as CodeNumber
	, cast(2 as varchar(1)) as Privilege
	FROM TUSERGROUP
	WHERE 
	MIK_VALID=1 
	AND FIXED like '%[_][dp]%'
	AND FIXED like 'AUTO%'

UNION

/* AREA*/

	SELECT USERGROUPID
	, USERGROUP
	, FIXED
	,'#'+(Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN substring([FIXED],7,3)  ELSE  substring([FIXED],7,2) END) AS Code3Digit
	, 'Area' as Field
	,'Territory_Area' as Role
	, (Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN '4Digit'  ELSE  '3Digit' END) as CodeNumber
	, cast(1 as varchar(1)) as Privilege
	FROM TUSERGROUP
	WHERE 
	MIK_VALID=1 
	AND FIXED like '%[_]ar[_]%'
	AND FIXED like 'AUTO%'

UNION

	/*AREA INDIVIDUAL COUNTRIES*/

	SELECT TUSERGROUP.USERGROUPID
	, TUSERGROUP.USERGROUP
	, TUSERGROUP.FIXED
	, substring(tbl_DPTS.department_code,1,3)  AS Code3Digit
	, 'Code_Area_Country' as Field
	,'Territory_Area' as Role
	, '3Digit' as CodeNumber
	, (case when SUBSTRING(TUSERGROUP.FIXED,12,1)='W' THEN 2 ELSE 1 /* READ */ END) as Privilege
	FROM TUSERGROUP INNER JOIN
		(SELECT TDEPARTMENT.DEPARTMENT_CODE AS PARENT_DPT_CODE, TDEPARTMENT_Child.*
		FROM TDEPARTMENT AS TDEPARTMENT_Child INNER JOIN TDEPARTMENT ON TDEPARTMENT_Child.PARENTID = TDEPARTMENT.DEPARTMENTID
		WHERE (TDEPARTMENT.DEPARTMENT_CODE Like '[#]%'))  tbl_DPTS ON substring([TUSERGROUP].[FIXED],7,2) = substring(tbl_DPTS.PARENT_DPT_CODE,2,2)
	WHERE 
	TUSERGROUP.MIK_VALID=1 
	AND TUSERGROUP.FIXED like '%[_]ar%' /* e.g. AUTO_:RC_arW */
	AND TUSERGROUP.FIXED like 'AUTO_:%'

UNION

	/* Contract Type READ */

	SELECT USERGROUPID
	, USERGROUP
	, FIXED
	,'!'+(Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN substring([FIXED],7,3)  ELSE  substring([FIXED],7,2) END) AS Code3Digit
	, 'Contract Type' as Field
	,'Contract_Type' as Role
	, (Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN '4Digit'  ELSE  '3Digit' END) as CodeNumber
	, cast(1 as varchar(1)) as Privilege
	FROM TUSERGROUP
	WHERE 
	MIK_VALID=1 
	AND FIXED like '%[_]ctR[_]%'
	AND FIXED like 'AUTO%'

UNION ALL

	/* Contract Ownership Ariba */
	/* not yet having any effect for ACL */
	SELECT USERGROUPID
	, USERGROUP
	, FIXED
	,'$AR'AS Code3Digit
	, 'Contract Type' as Field
	,'Contract_Type' as Role
	, (Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN '4Digit'  ELSE  '3Digit' END) as CodeNumber
	, cast(1 as varchar(1)) as Privilege
	FROM TUSERGROUP
	WHERE 
	MIK_VALID=1 
	AND FIXED like '%GPR_dp%'
	AND FIXED like 'AUTO%'


UNION


/* Contract Type WRITE */

	/* Type WRITE - Privilege 1 = Read */
	SELECT USERGROUPID
	, USERGROUP
	, FIXED
	,'!'+(Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN substring([FIXED],7,3)  ELSE  substring([FIXED],7,2) END) AS Code3Digit
	, 'Contract Type' as Field
	,'Contract_Type' as Role
	, (Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN '4Digit'  ELSE  '3Digit' END) as CodeNumber
	, cast(1 as varchar(1)) as Privilege
	FROM TUSERGROUP
	WHERE 
	MIK_VALID=1 
	AND FIXED like '%[_]ctW[_]%'
	AND FIXED like 'AUTO%'

	UNION

	/* Type WRITE - Privilege 2 = Write */
	SELECT USERGROUPID
	, USERGROUP
	, FIXED
	,'!'+(Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN substring([FIXED],7,3)  ELSE  substring([FIXED],7,2) END) AS Code3Digit
	, 'Contract Type' as Field
	,'Contract_Type' as Role
	, '1' as CodeNumber
	, cast(2 as varchar(1)) as Privilege
	FROM TUSERGROUP
	WHERE 
	MIK_VALID=1 
	AND FIXED like '%[_]ctW[_]%'
	AND FIXED like 'AUTO%'

	UNION
	
/* Company */

	/* Type WRITE - Privilege 2 = Write */
 SELECT USERGROUPID
	, USERGROUP
	, FIXED
	,'!'+(Case when UPPER(substring([FIXED],9,1)) LIKE ('[A-Z]') THEN substring([FIXED],7,3)  ELSE  substring([FIXED],7,2) END) AS Code3Digit
	, 'CompanyID' as Field
	, 'N/A' as Role
	, '1' as CodeNumber
	, cast(2 as varchar(1)) as Privilege
	FROM TUSERGROUP
	WHERE
	MIK_VALID=1 
	AND FIXED like '%[_]cpW[_]%'
	AND FIXED like 'AUTO%'

GO
/****** Object:  View [dbo].[V_TheCompany_AUTO_ProductGroupsToUpload]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[V_TheCompany_AUTO_ProductGroupsToUpload]
/* replaced by V_TheCompany_VProductgroup */
as

SELECT PRODUCTGROUPID
, PRODUCTGROUP AS PRODUCTGROUP_WITHHASH
,(REPLACE([PRODUCTGROUP], '#', '')) AS PRODUCTGROUP
,PRODUCTGROUPNOMENCLATUREID 
, (CASE WHEN CHARINDEX('#',PRODUCTGROUP) >0 THEN 1 ELSE 0 END) as blnNumHashes
FROM TPRODUCTGROUP 
WHERE PRODUCTGROUPNOMENCLATUREID IN('2','3') 
AND MIK_VALID = 1 
AND CHARINDEX('##',PRODUCTGROUP) = 0 AND LEN(PRODUCTGROUP)>2 
/* and Productgroupid in (6196) */





GO
/****** Object:  View [dbo].[V_TheCompany_TheVendorDataItems]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_TheVendorDataItems]

as select * from [dbo].[T_TheCompany_TheVendorDataItems]
GO
/****** Object:  View [dbo].[V_TheCompany_ContractData_JPSunrise_Products_In_Contracts]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_ContractData_JPSunrise_Products_In_Contracts] 
    
as

Select C.*, p.PRODUCTGROUP

  FROM [TheVendor_app].[dbo].[T_TheCompany_ContractData_JPSunrise_Products_In_Contracts] cp
  inner join TPRODUCTGROUP p on cp.PRODUCTGROUPID = p.PRODUCTGROUPID
  inner join [dbo].[T_TheCompany_ContractData_JP_Sunrise_ExecutedAgreements] c
	on C.contractid = cp.contractid
GO
/****** Object:  View [dbo].[V_TheCompany_DEL_Adhoc_ProcurementVendorList]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[V_TheCompany_DEL_Adhoc_ProcurementVendorList]

as

select 
p.IndirectProcurement_RoleFlag
, p.IndirectProcurement_AgreementTypeFlag
, a.*, t.* 
from T_TheCompany_All a inner join V_TheCompany_ALL_IndirectProcurement p 
on a.CONTRACTID = p.contractid_Proc
left join v_TheCompany_TTENDERER_CompanyAddress t on a.contractid = t.contractid_tt
where IndirectProcurement_RoleFlag = 'Y'
GO
/****** Object:  View [dbo].[V_TheCompany_DupeDocs_CustID_MinDocID_SameHash]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create view [dbo].[V_TheCompany_DupeDocs_CustID_MinDocID_SameHash]

as

		SELECT 
			DescRemNonAlphaHashbSHA1
			, COUNT(DISTINCT OBJECTID) as DupeObjectIDCount
			,COUNT(Documentid) as DocIDCountNonAlpha
			,MIN(Documentid) as DocIDMinDocIDNonAlpha
			,MAX(Documentid) as DocIDMaxDocIDNonAlpha
			, MIN(DescriptionFull) as DupeMinDescFull
			, MAX(DescriptionFull) as DupeMaxDescFull
			, (case when MIN(DescriptionFull) = MAX(DescriptionFull) THEN 1 ELSE 0 END) as SameDescFull
			/* ,COUNT(DescriptionFullHashbSHA1) as DupeCountFull */
			/* ALL IDs */
			,SUBSTRING(STUFF(
				(SELECT ',' + Convert(nvarchar(10),s.DOCUMENTID)
				FROM T_TheCompany_Docx s
				WHERE s.DescRemNonAlphaHashbSHA1 = r.DescRemNonAlphaHashbSHA1 AND s.CompanyIDList = r.CompanyIDList 
				FOR XML PATH('')),1,1,''),1,255) 
				AS DP_Doc_IDs
				/* ,SUBSTRING(STUFF(
				(SELECT ',' + Convert(nvarchar(10),s.DOCUMENTID)
				FROM T_TheCompany_Docx s
				WHERE s.DescriptionFull = r.DescriptionFull AND s.CompanyIDList = r.CompanyIDList 
				FOR XML PATH('')),1,1,''),1,255) 
				AS DP_DocExactMatch_IDs */
			,SUBSTRING(STUFF(
				(SELECT DISTINCT ', ' + Convert(nvarchar(10),s.objectid)
				FROM T_TheCompany_Docx s
				WHERE s.DescRemNonAlphaHashbSHA1 = r.DescRemNonAlphaHashbSHA1 AND s.CompanyIDList = r.CompanyIDList 
				FOR XML PATH('')),1,1,''),1,255) 
				AS DP_Object_IDs
			,SUBSTRING(STUFF(
				(SELECT DISTINCT ',' + c.CONTRACTNUMBER
				FROM T_TheCompany_Docx s inner join TCONTRACT c on s.OBJECTID = c.contractid
				WHERE s.DescRemNonAlphaHashbSHA1 = r.DescRemNonAlphaHashbSHA1 AND s.CompanyIDList = r.CompanyIDList 
				FOR XML PATH('')),1,1,''),1,255) 
				AS DP_Contract_Numbers
			, r.CompanyIDList
			
		FROM T_TheCompany_Docx r		
		GROUP BY
			/* Same company */
			r.CompanyIDList
			/* Same document name */
			, r.DescRemNonAlphaHashbSHA1
		HAVING 
			COUNT(*) >1
			/*  and MIN(Documentid)=197951  */

GO
/****** Object:  View [dbo].[V_TheCompany_Edit_ExpiredButFutureReviewDate]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view

[dbo].[V_TheCompany_Edit_ExpiredButFutureReviewDate]

as

select contractid,NUMBER, Title, EXPIRYDATE, REV_EXPIRYDATE, REVIEWDATE
from T_TheCompany_ALL
where
final_expirydate < GETDATE() 
and REVIEWDATE > GETDATE()
GO
/****** Object:  View [dbo].[V_TheCompany_Hierarchy_Summary]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_Hierarchy_Summary]

as

Select 
		Region
		, L1
		, L2
		, L3
		, len(L3) as lenl3
		, L4
		, FieldCategory
		, NodeType
		, NodeMajorFlag
		, COUNT(*) as NodeCount
		, MIN(DEPARTMENTID) as MinNode
	from t_TheCompany_Hierarchy
	group by
		Region
		, L1
		, L2
		, L3
		, L4
		, FieldCategory
		, NodeType
		, NodeMajorFlag

GO
/****** Object:  View [dbo].[V_TheCompany_JobLog]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_JobLog]

as 

SELECT TOp 100 *
  FROM [TheVendor_app].[dbo].[T_TheCompany_JobLog]
  order by RunTime desc
GO
/****** Object:  View [dbo].[V_TheCompany_KWS__Ariba_TheVendorUnion_FriendlyView]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [dbo].[V_TheCompany_KWS__Ariba_TheVendorUnion_FriendlyView]
AS

SELECT (CASE WHEN [SourceSystem] = 1 THEN 'TheVendor' ELSE 'Ariba' END) as SourceSystemName


/* [ContractRelationFIXED] */
      ,[Number] as 'Contract Number'

      /*,[Title] as 'Contract Description' */
      , [Title_InclTopSecret] as 'Contract Description'

      /* ,[CONTRACTTYPEID] as 'Contract Type ID' */
      /* ,[COMMENTS] */
      ,[STATUS] as 'Status'
      ,[CONTRACTDATE] AS 'Registered Date'
      , RegisteredDateNumMthCat as 'Reg Date Cat'
/*  ,[AWARDDATE] as 'Award Date' */
      ,[STARTDATE] AS 'Start Date'
      /* ,[EXPIRYDATE] AS 'Original End Date'
      ,[REV_EXPIRYDATE] AS 'New End Date' */
      ,[FINAL_EXPIRYDATE] AS 'End Date'
      ,[REVIEWDATE] AS 'Review Date'
	, [RD_ReviewDate_Warning] as 'Review Date Reminder'
/*  ,[CHECKEDOUTDATE] */
      ,[DEFINEDENDDATE] as 'Defined End Date Flag'

      /* ,[STATUSID] */
      /* ,[StatusFixed] */
      ,[NUMBEROFFILES]  as 'Number of Attachments'
 /* ,[EXECUTORID]
      ,[OWNERID]
      ,[TECHCOORDINATORID] */
      /*  ,[LASTTASKCOMPLETED] as 'Last Task Completed' */
      /* ,[EDIT_STARTDATE_BLANK]
      ,[EDIT_EXPIRYDATE_BLANK]
      ,[EDIT_REV_EXPIRYDATE_BLANK]
      ,[EDIT_FINAL_EXPIRYDATE_BLANK]
      ,[EDIT_REVIEWDATE_BLANK]
      ,[EDIT_NO_ENDDATE_OR_REMINDER]
      ,[EDIT_NO_PDF_ATTACHMENTS]
      ,[EDIT_NO_COMPANYID]
      ,[EDIT_VCONTRACT_FLAG] */
      /* ,[CheckedOutByUserId] */
      ,[REFERENCENUMBER] AS 'Reference Number'
      ,[COUNTERPARTYNUMBER] as 'Counter Party Reference' /* e.g. needed for procurement wave */
      /* ,[REFERENCECONTRACTID] */
      ,[REFERENCECONTRACTNUMBER] as 'Linked Contract Number'

      /* ,[StatusMikSequence] */
      ,[AGREEMENT_TYPE] as 'Agreement Type'
      ,[ContractRelations] as 'Contract Relation'
      ,[CONTRACTTYPE] as 'Contract Type'
      /* ,[AGREEMENT_TYPEID] */
      /* ,[AGREEMENT_MIK_VALID] */
      ,[CompanyList] as 'Company Names'
      /* ,[CompanyIDList] as 'Company IDs' */
      ,[CompanyIDAwardedCount] as 'Company Count'
      /* , [CompanyIDUnawardedCount] as 'Company Count (Unawarded)' */
       ,'' AS 'Contract Heading' 
      /* ,[INGRESS] */
     /*  ,[SUMMARYBODY] */
      /* ,[US_Userid] */
      ,[US_DisplayName] as 'Super User Name'
      ,[US_Email] as 'Super User Email'
      ,[US_Firstname] as 'Super User First Name'
      ,[US_PrimaryUserGroup] as 'Super User Primary User Group'
      ,[US_USER_MIK_VALID] as 'Super User Active Flag'
      /* ,[UO_employeeid] */
      ,[UO_DisplayName] as 'Owner Name'
      ,[UO_Email] as 'Owner Email'
      ,[UO_Firstname] as 'Owner First Name'
      ,[UO_PrimaryUserGroup] as 'Owner Primary User Group'
      ,[UO_USER_MIK_VALID] as 'Owner Active Flag'
      /* ,[UR_employeeid] */
      ,[UR_DisplayName] as 'Responsible Name'
      ,[UR_Email] as 'Contract Responsible Email'
       ,[UR_Firstname] as 'Responsible First Name'
      ,[UR_PrimaryUserGroup] as 'Responsible Primary User Group'
      ,[UR_USER_MIK_VALID] as 'Responsible Active Flag'
  

     /*     ,[SuperUserDpt]
     ,[SuperUserDpt_ID] 
       ,[ContractOwnerDpt]
      ,[ContractOwnerDpt_ID]
      ,[ContractResponsibleDpt]
      ,[ContractResponsibleDpt_ID] */
      ,[InternalPartners] as 'Internal Partners'
      /* ,[InternalPartners_IDs] */
      ,[InternalPartners_COUNT] as 'Internal Partners Count'
      ,[Territories]
      /* ,[Territories_IDs] */
      ,[Territories_COUNT] as 'Territories Count'
      ,[VP_ProductGroups] as 'All Products'
      ,[VP_ProductGroups_COUNT] as 'Product Group Count'
      ,[VP_ActiveIngredients] as 'Active Ingredients'
      ,[VP_TradeNames] as 'Trade Names'
      /* ,[VP_DirectProcurement]
      ,[VP_IndirectProcurement] */

	, [LumpSum] as 'Lump Sum'
	, LumpSumCurrency
      ,[CONTRACTID]
      , L0
		, L1
		, L2
		,L3
		, L4
		, LinkToContractURL
		, DateTableRefreshed
		, Tags
/* ,DptCode2Digit_Link */
  FROM [TheVendor_app].[dbo].[V_TheCompany_KWS_0_Ariba_TheVendorUnion]
GO
/****** Object:  View [dbo].[V_TheCompany_KWS__AribaDump_ExcelListView]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view

[dbo].[V_TheCompany_KWS__AribaDump_ExcelListView]

as

SELECT [ContractNumber] /* descriptory number */
      ,[Contract Description]
      ,[ContractInternalID] /* internal secret number */
	 /* ,[Parent Project - Project Id] */
      ,[Project - Project Name]
      /*,[ContractID_Count]
      ,[Contract Internal ID] */
      ,[Hierarchy Type]
      ,[State]
      ,[Contract Status]
      ,[Begin Date]
      ,[Effective Date - Date]
      ,[End Date - Date]
      ,[Due Date - Date]
      ,[Expiration Date - Date]
      ,[Amount_EUR]
	  /*,[Currency]*/
      ,[Contract Type]
      ,[Additional Comments]
      ,[Contracting Legal Entity] /* only one field value, no concat */
      ,[Contract Signatory - User Concat]
      ,[Owner Name Concat]
      ,[Business Owner - User]
      ,[Region - Region Concat]
     /* ,[Region - Region Count] */
      ,[Commodity - Commodity Concat]
      /*,[Commodity - Commodity ID Count] */
      ,[Affected Parties - Common Supplier Concat]
      /*,[Affected Parties - Common Supplier Count] */
	  , [LinkToContractURL]
		, [DateTableRefreshed]
		 ,[Parent Agreement - Project Id]
		  ,[Parent Agreement - Project Name]
	      ,[Process - Process]
      /* ,[Storage Identifier] */
      /* ,[Storage Location] */
      ,[Study Number]
  FROM [TheVendor_app].[dbo].[T_TheCompany_AribaDump]
GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_ARB_TCOMPANY_ContractID_BAK]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view 
[dbo].[V_TheCompany_KWS_2_ARB_TCOMPANY_ContractID_BAK]
/* run time 60 seconds 31-Oct-18, ca 3  min for Nick's 10 k records */
as 

	SELECT DISTINCT 
		s.KeyWordVarchar255
		, s.keywordlength
		, s.keywordFirstWord
		, s.[KeyWordLettersOnly]
		, s.KeyWordLettersNumbersSpacesOnly
		, s.[KeyWordFirstTwoWords_LettersOnly] as KeyWordFirstTwoWords
		, s.[KeyWordCustom1]
		, s.[KeyWordCustom2]

		, c.[contractInternalID]
		, c.[ContractNumber]

		, c.[Company]

		, c.[Company_LettersNumbersOnly]
		, c.[Company_LettersNumbersSpacesOnly]

		, 0 as COMPANYID

		/* Exact match */
		, (case when c.[Company] =  s.KeyWordVarchar255 
				OR c.Company_LettersNumbersOnly = [KeyWordLettersOnly]
				THEN s.KeyWordVarchar255 ELSE '' END) as CompanyExact
		, (case when c.[Company] =  s.KeyWordVarchar255 
				OR c.Company_LettersNumbersOnly = [KeyWordLettersOnly]
				THEN 1 ELSE 0 END) as CompanyExact_Flag

		, (case when c.[Company]
			like [KeyWordVarchar255]+'%' /* AND KeyWordLength > 5 */ 
			THEN 1 ELSE 0 END) 
			as CompanyMatch_Like
		, (case when c.[Company_LettersNumbersOnly] 
			like [KeyWordLettersOnly]+'%' THEN 1 ELSE 0 END) 
			as CompanyMatch_LettersNumbersOnly
		, (case when c.Company_LettersNumbersSpacesOnly 
			like [KeyWordLettersNumbersSpacesOnly]+'%' THEN 1 ELSE 0 END) 
			as CompanyMatch_LettersNumbersSpacesOnly
		, (case when c.[Company_LettersNumbersOnly] /* use first two words `?? */
			like [KeyWordFirstTwoWords_LettersOnly]+'%'  
			AND [KeyWordFirstTwoWords_LettersOnly_LEN] > 4 THEN 1 ELSE 0 END) 
			as CompanyMatch_FirstTwoWords
		, (case when c.[Company_LettersNumbersOnly] 
			like [KeyWordFirstWord_LettersOnly]+'%' AND [KeyWordFirstWord_LEN] > 4 THEN 1 ELSE 0 END) 
			as CompanyMatch_FirstWord
	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		left join [T_TheCompany_ContractData_ARB_1VCOMPANY] c 
			on  c.[Company_LettersNumbersOnly]
				LIKE (CASE WHEN c.[CompanyType] = 'I'  /* Individual */ THEN /* avoid three letter KMC */
							left(s.[KeyWordLettersOnly],11)+'%' 
						WHEN [KeyWordFirstWord_LEN] <=4 THEN
							left(s.[KeyWordLettersOnly],6)+'%' /* e.c. S. Goldmann */
						WHEN [KeyWordFirstWord_LEN] >5 THEN /* Abbott = 6 Char */
							'%' + left(s.[KeyWordLettersOnly],6) + '%' /* Tiefenbacher */
						WHEN [KeyWordFirstWord_LEN] >4 THEN
							left(s.[KeyWordLettersOnly],4)+'%' 
							/* e.c. S. Goldmann */
						END)
					AND  c.[Company_LettersNumbersOnly] is not null 
	WHERE 
	/* c.[Contract Id] ='CW2548994'
		AND */ s.KeyWordType='Company' 
		/* and c.[Company_LettersNumbersOnly] = (case when s.keywordprecision = 'EXACT' 
						then s.[KeyWordLettersOnly] else '%' END) */
		AND  (c.[Company] is not null) /* could also be internal partner */
		AND (
			c.[Company] = s.KeyWordVarchar255
			or c.company_lettersnumbersspacesonly = s.KeyWordLettersNumbersSpacesOnly

			OR (c.[Company_FirstWord] /* 6 char and more */ = [KeyWordFirstWord] 
				AND [KeyWordFirstWord_LEN] >6)
			OR (c.[Company] LIKE s.KeyWordVarchar255+'%' 
				AND s.[KeyWordLength] > 6)
			OR (c.[company_lettersnumbersspacesonly] LIKE [KeyWordLettersNumbersSpacesOnly]
				+ (case when s.[KeyWordLength] > 10 THEN '%' ELSE ' %' end) /* MEDAVANTEINC (Meda) */)
			OR (c.[Company_LettersNumbersOnly] LIKE s.[KeyWordFirstTwoWords_LettersOnly] +'%' 
				AND s.[KeyWordLength] > 6)
			)

		AND c.Company IS NOT NULL /* some records only have internal partners, intercompany */
		and c.Company >''

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_ARB_TCOMPANY_ContractID_BAK2]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view 
[dbo].[V_TheCompany_KWS_2_ARB_TCOMPANY_ContractID_BAK2]
/* run time 60 seconds 31-Oct-18, ca 3  min for Nick's 10 k records */
as 

	SELECT DISTINCT 
		s.KeyWordVarchar255
		, s.keywordlength
		, s.keywordFirstWord
		, s.[KeyWordLettersOnly]
		, s.KeyWordLettersNumbersSpacesOnly
		, s.[KeyWordFirstTwoWords_LettersOnly] as KeyWordFirstTwoWords
		, s.[KeyWordCustom1]
		, s.[KeyWordCustom2]

		, g.[contractInternalID]
		, g.[ContractNumber]

		, g.[Company]

		, g.[Company_LettersNumbersOnly]
		, g.[Company_LettersNumbersSpacesOnly]

		, 0 as COMPANYID

		/* Exact match */
		, (case when g.[Company] =  s.KeyWordVarchar255 
				OR g.Company_LettersNumbersOnly = [KeyWordLettersOnly]
				THEN s.KeyWordVarchar255 ELSE '' END) as CompanyExact
		, (case when g.[Company] =  s.KeyWordVarchar255 
				OR g.Company_LettersNumbersOnly = [KeyWordLettersOnly]
				THEN 1 ELSE 0 END) as CompanyExact_Flag

		, (case when g.[Company]
			like [KeyWordVarchar255]+'%' /* AND KeyWordLength > 5 */ THEN 1 ELSE 0 END) 
			as CompanyMatch_Like
		, (case when g.[Company_LettersNumbersOnly] 
			like [KeyWordLettersOnly]+'%' THEN 1 ELSE 0 END) 
			as CompanyMatch_LettersNumbersOnly
		, (case when g.Company_LettersNumbersSpacesOnly 
			like [KeyWordLettersNumbersSpacesOnly]+'%' THEN 1 ELSE 0 END) 
			as CompanyMatch_LettersNumbersSpacesOnly
		, (case when g.[Company_LettersNumbersOnly] /* use first two words `?? */
			like [KeyWordFirstTwoWords_LettersOnly]+'%'  
			AND [KeyWordFirstTwoWords_LettersOnly_LEN] > 4 THEN 1 ELSE 0 END) 
			as CompanyMatch_FirstTwoWords
		, (case when g.[Company_LettersNumbersOnly] 
			like [KeyWordFirstWord_LettersOnly]+'%' AND [KeyWordFirstWord_LEN] > 4 THEN 1 ELSE 0 END) 
			as CompanyMatch_FirstWord
	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		left join [T_TheCompany_ContractData_ARB_1VCOMPANY] g 
			on  g.Company_LettersNumbersOnly
			LIKE 
			(CASE WHEN LEN([KeyWordFirstWord_LettersOnly]) > 6 THEN
						'%'+s.[KeyWordFirstWord_LettersOnly]+'%' /* or an exact match */
					ELSE
						s.KeyWordLettersNumbersOnly + '%'
				END)
	WHERE 
	/* g.[Contract Id] ='CW2548994'
		AND */ s.KeyWordType='Company' 
		/* and g.[Company_LettersNumbersOnly] = (case when s.keywordprecision = 'EXACT' 
						then s.[KeyWordLettersOnly] else '%' END) */
		AND  (g.[Company] is not null) /* could also be internal partner */
		AND (
			g.[Company] = s.KeyWordVarchar255
			or g.company_lettersnumbersspacesonly = s.KeyWordLettersNumbersSpacesOnly

			OR (g.[Company_FirstWord] /* 6 char and more */ = [KeyWordFirstWord] 
				AND [KeyWordFirstWord_LEN] >6)
			OR (g.[Company] LIKE s.KeyWordVarchar255+'%' 
				AND s.[KeyWordLength] > 6)
			OR (g.[company_lettersnumbersspacesonly] LIKE [KeyWordLettersNumbersSpacesOnly]
				+ (case when s.[KeyWordLength] > 10 THEN '%' ELSE ' %' end) /* MEDAVANTEINC (Meda) */)
			OR (g.[Company_LettersNumbersOnly] LIKE s.[KeyWordFirstTwoWords_LettersOnly] +'%' 
				AND s.[KeyWordLength] > 6)
			)

		AND g.Company IS NOT NULL /* some records only have internal partners, intercompany */

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_ARB_TCOMPANYCountry_ContractID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view

[dbo].[V_TheCompany_KWS_2_ARB_TCOMPANYCountry_ContractID]
/* to do: include spaces with company name */
as 

	SELECT DISTINCT 
		s.KeyWordVarchar255
		, s.keywordlength
		, s.keywordFirstWord_UPPER
		, s.[KeyWordFirstWord_LettersOnly_UPPER]
		, s.[KeyWordLettersNumbersOnly_UPPER]
		, s.keywordFirstTwoWords_UPPER
		, s.[KeyWordFirstTwoWords_LettersOnly_UPPER] 

		, s.[KeyWordCustom1]
		, s.[KeyWordCustom2]
		, s.KeyWordLettersNumbersSpacesOnly_UPPER

		/*, c.company /* only exact match, first match */ */
		/*, c.COMPANYID /* same ID for same contract #, handle in next level */*/

		, [﻿Contract Id] as CONTRACTNumber
		, [Project - Project Id] as contractinternalid
		, c.CompanyCOUNTRY
		/*, c.Country_IsUS */
		, (case when c.Companycountry =  s.KeyWordVarchar255 
				THEN s.KeyWordVarchar255 
				ELSE '' END) as CompanyCountryExact
		, (case when (c.Companycountry =  s.KeyWordVarchar255 
			 ) /*ESON PAC AB = Esonpac AB*/
			THEN 1 ELSE 0 END) as CompanyCountryExact_Flag

		, (case when c.[Companycountry] like '%'  + s.KeyWordVarchar255 +'%' 
			THEN 1 ELSE 0 END) as CompanyCountryMatch_Like
		, /*(case when c.[country_isUS] ='US' and [KeyWordVarchar255] = 'United States' 
			THEN 1 ELSE 0 END) */ '' as CompanyCountry_IsUS


	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		left join T_TheCompany_Ariba_Dump_Raw c /* T_TheCompany_ContractData_JP_Sunrise_ExecutedAgreements */
			on  upper(c.[CompanyCountry]) =  upper(KeyWordVarchar255)
	WHERE 
		 s.KeyWordType='CompanyCountry' 
		 /*and c.companyCOUNTRYID is not null */

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_CNT_TCOMPANY_ContractID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_KWS_2_CNT_TCOMPANY_ContractID]

as

	SELECT DISTINCT 
		s.KeyWordVarchar255
		, s.KeyWordVarchar255_UPPER
		, s.keywordlength
		, s.keywordFirstWord_UPPER
		, s.[KeyWordFirstWord_LettersOnly_UPPER]
		, s.[KeyWordLettersNumbersOnly_UPPER]
		, s.keywordFirstTwoWords_UPPER
		, s.[KeyWordFirstTwoWords_LettersOnly_UPPER] 
		, isnull(s.[KeyWordCustom1],'') AS [KeyWordCustom1]
		, isnull(s.[KeyWordCustom2],'') AS [KeyWordCustom2]
		, s.KeyWordLettersNumbersSpacesOnly_UPPER

		, c.company /* only exact match, first match */
		, c.companyid_LN as COMPANYID /* same ID for same contract #, handle in next level */
		, c.CompanyType /* Individual, Company or Undefined */

		, t.[ContractID]
		/*, t.[ContractNumber] */

		, c.[Company_LettersNumbersOnly_UPPER]
		, c.[Company_LettersNumbersSpacesOnly_UPPER]
/* MATCH FLAGS */	
	/* Exact match */

		, (case when (c.Company_UPPER =  s.KeyWordVarchar255_UPPER
			OR c.[Company_LettersNumbersSpacesOnly_UPPER] = s.KeyWordLettersNumbersSpacesOnly_UPPER /* if more than 6 char */) /* - . etc. do not count and compare UPPER */
			OR (c.[Company_LettersNumbersOnly_UPPER] = s.KeyWordLettersNumbersOnly_UPPER AND s.[KeyWordLength] > 7 ) /*ESON PAC AB = Esonpac AB*/
			THEN s.KeyWordVarchar255 
				ELSE '' END) as CompanyMatch_Exact

		, (case when (c.Company_UPPER =  s.KeyWordVarchar255_UPPER
			OR c.[Company_LettersNumbersSpacesOnly_UPPER] = s.KeyWordLettersNumbersSpacesOnly_UPPER /* if more than 6 char */) /* - . etc. do not count and compare UPPER */
			OR (c.[Company_LettersNumbersOnly_UPPER] = s.KeyWordLettersNumbersOnly_UPPER AND s.[KeyWordLength] > 7 ) /*ESON PAC AB = Esonpac AB*/
			THEN LEN(s.KeyWordLettersNumbersOnly_UPPER)  ELSE 0 END) as CompanyMatch_Exact_FLAG

	/*		, (case when 
			c.company =  s.KeyWordVarchar255 
				OR c.[Company_LettersNumbersSpacesOnly_UPPER] = s.KeyWordLettersNumbersSpacesOnly_UPPER 
				/* if more than 6 char */ /* - . etc. do not count and compare UPPER */
				OR left(c.[Company_LettersNumbersOnly_UPPER], LEN(s.[KeyWordLettersNumbersOnly_UPPER]) )
					= s.KeyWordLettersNumbersOnly_UPPER /* short */					
				/* AND s.[KeyWordLength] > 7	*/
							 
				 /*ESON PAC AB = Esonpac AB*/
			THEN s.KeyWordVarchar255 
				ELSE '' END)
				 as CompanyMatch_Exact

		, (case when 
			c.company =  s.KeyWordVarchar255 
				OR c.[Company_LettersNumbersSpacesOnly_UPPER] = s.KeyWordLettersNumbersSpacesOnly_UPPER 
				/* if more than 6 char */ /* - . etc. do not count and compare UPPER */
				OR left(c.[Company_LettersNumbersOnly_UPPER], LEN(s.[KeyWordLettersNumbersOnly_UPPER]) )
					= s.KeyWordLettersNumbersOnly_UPPER /* short */					
				/* AND s.[KeyWordLength] > 7	*/
							 
				 /*ESON PAC AB = Esonpac AB*/
			THEN len(s.KeyWordVarchar255)
				ELSE 0 END)
			as CompanyMatch_Exact_FLAG */

	/* LIKE match */
		/* with spaces */
/*
		, (case when c.[Company_LettersNumbersSpacesOnly_UPPER] like KeyWordLettersNumbersSpacesOnly_UPPER +'%'		
			THEN [KeyWordLettersNumbersSpacesOnly_UPPER] ELSE '' END) 
			as CompanyMatch_LIKE_LNS

		, (case when c.[Company_LettersNumbersSpacesOnly_UPPER] like KeyWordLettersNumbersSpacesOnly_UPPER +'%' 
			THEN LEN([KeyWordLettersNumbersSpacesOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_Like_LNS_FLAG
*/
		/* no spaces */

		, (case when c.[Company_LettersNumbersOnly_UPPER] like [KeyWordLettersNumbersOnly_UPPER]+'%' 
			THEN [KeyWordLettersNumbersOnly_UPPER] ELSE '' END) 
			as CompanyMatch_LIKE

		, (case when c.[Company_LettersNumbersOnly_UPPER] like [KeyWordLettersNumbersOnly_UPPER]+'%' 
			THEN LEN([KeyWordLettersNumbersOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_LIKE_FLAG

	/* reverse LIKE */
		, (case when [KeyWordLettersNumbersOnly_UPPER] like c.[Company_LettersNumbersOnly_UPPER]+'%' 
			THEN c.[Company_LettersNumbersOnly_UPPER] ELSE '' END) 
			as CompanyMatch_REV_LIKE

		, (case when [KeyWordLettersNumbersOnly_UPPER] like c.[Company_LettersNumbersOnly_UPPER]+'%' 
			THEN len(c.[Company_LettersNumbersOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_REV_LIKE_FLAG

	/* 2-way Like - ONLY FOR WHOLE FIRST or FIRST TWO WORDS!!! */
		, (case when
				 c.[Company_LettersNumbersOnly_UPPER] like '%' +[keywordFirstTwoWords_UPPER]+'%' 
					AND KeyWordFirstWord_LEN > 6
					THEN [keywordFirstTwoWords_UPPER]
				WHEN
					c.[Company_LettersNumbersOnly_UPPER] like '%' +[keywordFirstWord_UPPER]+'%' 
					AND KeyWordFirstWord_LEN > 6 
					THEN [keywordFirstWord_UPPER] 
				ELSE '' END) 
			as CompanyMatch_LIKE2Way

		, (case when
				 c.[Company_LettersNumbersOnly_UPPER] like '%' +[keywordFirstTwoWords_UPPER]+'%' 
					THEN len([keywordFirstTwoWords_UPPER])
				WHEN
					c.[Company_LettersNumbersOnly_UPPER] like '%' +[keywordFirstWord_UPPER]+'%' 
					THEN len([keywordFirstWord_UPPER]) 
				ELSE 0 END) 
			as CompanyMatch_LIKE2Way_FLAG

	/* 2-way reverse LIKE */

		, (case when [KeyWordLettersNumbersOnly_UPPER] like '%' +c.[Company_LettersNumbersOnly_UPPER]+'%' 			
			THEN c.[Company_LettersNumbersOnly_UPPER] ELSE '' END) 
			as CompanyMatch_REV_LIKE2Way
		, (case when [KeyWordLettersNumbersOnly_UPPER] like '%' +c.[Company_LettersNumbersOnly_UPPER]+'%' 
			THEN LEN(c.[Company_LettersNumbersOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_REV_LIKE2Way_FLAG

	/* First TWO Words */

		, (case when c.[Company_FirstTwoWords_LettersOnly_UPPER] like [KeyWordFirstTwoWords_LettersOnly_UPPER]+'%' 
			THEN [KeyWordFirstTwoWords_LettersOnly_UPPER] ELSE '' END) 
			as CompanyMatch_FirstTwoWords

		, (case when c.[Company_FirstTwoWords_LettersOnly_UPPER] like [KeyWordFirstTwoWords_LettersOnly_UPPER]+'%' 
			THEN LEN([KeyWordFirstTwoWords_LettersOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_FirstTwoWords_FLAG

	/* First Word, 3 char or more (e.g. ADT - was 5 char, 26-oct-20) */
		, (case when c.[Company_FirstWord_LettersOnly_UPPER] like [KeyWordFirstWord_LettersOnly_UPPER]+'%' 
			AND [KeyWordFirstWord_LEN] > 2  
				THEN KeyWordFirstWord_LettersOnly_UPPER ELSE '' END) 
			as CompanyMatch_FirstWord

		, (case when c.[Company_FirstWord_LettersOnly_UPPER] like [KeyWordFirstWord_LettersOnly_UPPER]+'%' 
			AND [KeyWordFirstWord_LEN] > 2  
				THEN LEN(KeyWordFirstWord_LettersOnly_UPPER) ELSE 0 END) 
			as CompanyMatch_FirstWord_FLAG 

	/* First Word - Two Way, if 5 char or more */

		, (case when c.[Company_FirstWord_LettersOnly_UPPER] like '%' + [KeyWordFirstWord_LettersOnly_UPPER] + '%' 
			AND [KeyWordFirstWord_LEN] > 5 /* Abbott */ /* and c.Company_FirstWord_LEN > 5 /* CS */ must exclude in query below too if any	*/	
				THEN left(s.[KeyWordFirstWord_LettersOnly_UPPER],6) ELSE '' END) 
			as CompanyMatch_FirstWord2Way

		, (case when c.[Company_FirstWord_LettersOnly_UPPER] like '%' +[KeyWordFirstWord_LettersOnly_UPPER]+'%' 
			AND [KeyWordFirstWord_LEN] > 5 /*   and c.Company_FirstWord_LEN > 5 /* CS */	*/
				THEN LEN(KeyWordFirstWord_LettersOnly_UPPER) ELSE 0 END) 
			as CompanyMatch_FirstWord2Way_FLAG 

/* First word - Two Way - Rev, if 6 char or more */
		, (case when [KeyWordFirstWord_LettersOnly_UPPER] like '%'+c.[Company_FirstWord_LettersOnly_UPPER]+'%' 
			AND [KeyWordFirstWord_LEN] > 6  and c.Company_FirstWord_LEN > 6 /* CS */	
				THEN Company_FirstWord_LettersOnly_UPPER ELSE '' END) 
			as CompanyMatch_FirstWord2Way_REV

		, (case when [KeyWordFirstWord_LettersOnly_UPPER] like '%'+c.[Company_FirstWord_LettersOnly_UPPER]+'%' 
			AND [KeyWordFirstWord_LEN] > 6   and c.Company_FirstWord_LEN > 6 /* CS */	
				THEN len(Company_FirstWord_LettersOnly_UPPER) ELSE 0 END) 
			as CompanyMatch_FirstWord2Way_REV_FLAG 

	/* First part of Keywordsearch */
		, (case when  [KeyWordLettersNumbersOnly_UPPER] = 
			LEFT([Company_LettersNumbersOnly_UPPER], LEN([KeyWordLettersNumbersOnly_UPPER]))
			/* AND [KeyWordFirstWord_LEN] > 4 */ 
				THEN LEN([KeyWordLettersNumbersOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_EntireKeywordLike_FLAG 

	/* abbreviation match */
	/*, (case when KeyWordLength = 3 and left(c.Company_FirstLetterOfEachWord_UPPER,3) 
						= left(KeyWordLettersNumbersOnly_UPPER,3) then 1 else 0 AS Company_AbbreviationMatch_Flag */ /* match is the kwd */
	, (case when KeyWordLength = 3 and left(c.Company_FirstLetterOfEachWord_UPPER,3) 
						= left(KeyWordLettersNumbersOnly_UPPER,3) then 1 else 0 END) 
						AS CompanyMatch_Abbreviation_FLAG
	, (Select  case when Patindex ('%KeyWordLettersNumbersOnly_UPPER%',Company_LettersNumbersOnly_UPPER) >0 
		then 1 else 0 end)
		as CompanyMatch_ContainsKeyword

	, (Select  case when Charindex (KeyWordLettersNumbersOnly_UPPER,Company_LettersNumbersOnly_UPPER)=1 
		then 1 else 0 end )
		as CompanyMatch_BeginsWithKeyword


	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		left join T_TheCompany_VCOMPANY c
			on  c.[Company_LettersNumbersOnly_UPPER]
				LIKE (CASE 
						WHEN s.KeyWordFirstWord_LEN <= 4 THEN /* 4 - using first word in case surplus suffix information at back */
							left(s.[KeyWordLettersNumbersOnly_UPPER],6)+'%' /* 6 letters, e.g. S. Goldmann */
						WHEN [KeyWordFirstWord_LEN] > 6 THEN /* USE WHOLE WORD FOR TWO SIDED LIKES!! */
							'%' + s.KeyWordFirstWord_UPPER + '%' /* left(s.[KeyWordLettersNumbersOnly_UPPER],6) */
							/* 6 letters, e.g. Tiefenbacher, changed to 5 due to PT Abbott */
						WHEN [KeyWordFirstWord_LEN] > 4 THEN /* 4 - one sided if more than 4 char */
							left(s.[KeyWordLettersNumbersOnly_UPPER],4)+'%' /* 4 letters */
						END)
			/*	LIKE (CASE 
						WHEN s.KeyWordFirstWord_LEN <=4 THEN /* 4 - using first word in case surplus suffix information at back */
							left(s.[KeyWordLettersNumbersOnly_UPPER],6)+'%' /* 6 letters, e.g. S. Goldmann */
						WHEN [KeyWordFirstWord_LEN] >5 THEN /* 5 then 6, two sided LIKE if more than 6 char */
							'%' + left(s.[KeyWordLettersNumbersOnly_UPPER],6) + '%' 
							/* 6 letters, e.g. Tiefenbacher, changed to 5 due to PT Abbott */
						WHEN [KeyWordFirstWord_LEN] >4 THEN /* 4 - one sided if more than 4 char */
							left(s.[KeyWordLettersNumbersOnly_UPPER],4)+'%' /* 4 letters */
						END) */
	/*			OR /* reverse LIKE */
					s.KeyWordLettersNumbersOnly_UPPER 
					LIKE (CASE WHEN [Company_FirstWord_LEN] >6 THEN /* 6, two sided if more than 6 char */
							left(c.[Company_LettersNumbersOnly],6) + '%' /* NOT LEFT CUTS OFF must match first part of vendor,
							otherwise e.g. Abbott Laboratories matches Laboratories Silesa*/
						END)
					OR (KeyWordLength = 3 and left(c.Company_FirstLetterOfEachWord,3) 
						= left(KeyWordLettersNumbersOnly_UPPER,3)) /* 3 letter abbreviations KMC */ */
		/* inner join or companyn not null !!*/
		inner join ttenderer t on c.companyid_LN = t.companyid
	WHERE 	
	 s.KeyWordType='Company' 
	 and c.Company is not null /* data load requires not null and min 3 char */
		AND (
			c.[Company_UPPER] = s.KeyWordVarchar255_UPPER
			or c.Company_LettersNumbersSpacesOnly_UPPER = s.KeyWordLettersNumbersSpacesOnly_UPPER
			OR (c.[Company_FirstWord_LettersOnly_UPPER] /* 2 char and more */ = [KeyWordFirstWord_LettersOnly_UPPER] 
				AND [KeyWordFirstWord_LEN] >2) /* ADT */
			OR (c.[Company] LIKE s.KeyWordVarchar255+'%' 
				AND s.[KeyWordLength] > 6)
			OR (c.[Company] LIKE '%'+s.KeyWordVarchar255+'%' 
				AND s.[KeyWordLength] > 8) /* recordati was missing */
			OR (c.[Company_LettersNumbersSpacesOnly_UPPER] LIKE [KeyWordLettersNumbersSpacesOnly_UPPER]
				+ (case when s.[KeyWordLength] > 10 THEN '%' ELSE ' %' end) /* MEDAVANTEINC (Meda) */)
			OR (c.[Company_LettersNumbersOnly_UPPER] LIKE s.[KeyWordFirstTwoWords_LettersOnly_UPPER] +'%' 
				AND s.[KeyWordLength] > 6)
			)
			/* and t.CONTRACTID =  127569 */

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_CNT_TCOMPANY_ContractID_BAK]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view

[dbo].[V_TheCompany_KWS_2_CNT_TCOMPANY_ContractID_BAK]
/* to do: include spaces with company name */
as 

	SELECT DISTINCT 
		s.KeyWordVarchar255
		, s.keywordlength
		, s.keywordFirstWord
		, s.[KeyWordFirstWord_LettersOnly]
		, s.[KeyWordLettersOnly]
		, s.keywordFirstTwoWords
		, s.[KeyWordFirstTwoWords_LettersOnly] 
		, s.[KeyWordCustom1]
		, s.[KeyWordCustom2]
		, s.KeyWordLettersNumbersSpacesOnly

		, c.company /* only exact match, first match */
		, c.COMPANYID /* same ID for same contract #, handle in next level */

		, t.CONTRACTID
		, c.[Company_LettersNumbersOnly]
		, c.[Company_LettersNumbersSpacesOnly]
		, (case when (c.company =  s.KeyWordVarchar255 
			OR c.[Company_LettersNumbersSpacesOnly] = s.KeyWordLettersNumbersSpacesOnly /* if more than 6 char */) /* - . etc. do not count and compare UPPER */
			OR (c.[Company_LettersNumbersOnly] = s.KeyWordLettersNumbersOnly AND s.[KeyWordLength] > 7 ) /*ESON PAC AB = Esonpac AB*/
			THEN s.KeyWordVarchar255 
				ELSE '' END) as CompanyMatch_Exact
		, (case when (c.company =  s.KeyWordVarchar255 
			OR c.[Company_LettersNumbersSpacesOnly] = s.KeyWordLettersNumbersSpacesOnly /* if more than 6 char */) /* - . etc. do not count and compare UPPER */
			OR (c.[Company_LettersNumbersOnly] = s.KeyWordLettersNumbersOnly AND s.[KeyWordLength] > 7 ) /*ESON PAC AB = Esonpac AB*/
			THEN 1 ELSE 0 END) as CompanyMatch_Exact_FLAG

		, (case when c.[Company_LettersNumbersSpacesOnly] like KeyWordLettersNumbersSpacesOnly +'%' 
			THEN 1 ELSE 0 END) 
			as CompanyMatch_LIKE

		, (case when c.[Company_LettersNumbersSpacesOnly] like KeyWordLettersNumbersSpacesOnly +'%' 
			THEN 1 ELSE 0 END) 
			as CompanyMatch_Like_FLAG
		, (case when c.[Company_LettersNumbersOnly] like [KeyWordLettersOnly]+'%' 
			THEN 1 ELSE 0 END) 
			as CompanyMatch_LettersNumbersOnly_FLAG
		, (case when c.[Company_LettersNumbersOnly] like [KeyWordFirstTwoWords_LettersOnly]+'%' 
			THEN 1 ELSE 0 END) 
			as CompanyMatch_FirstTwoWords_FLAG
		, (case when c.[Company_LettersNumbersOnly] like [KeyWordFirstWord_LettersOnly]+'%' /* AND [KeyWordFirstWord_LEN] > 4 */ 
				THEN 1 ELSE 0 END) 
			as CompanyMatch_FirstWord_FLAG 

	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		left join T_TheCompany_VCOMPANY c
			on  c.[Company_LettersNumbersOnly]
				LIKE (CASE WHEN c.[CompanyType] = 'I'  /* Individual */ THEN /* avoid three letter KMC */
							left(s.[KeyWordLettersOnly],11)+'%' 
						WHEN [KeyWordFirstWord_LEN] <=4 THEN
							left(s.[KeyWordLettersOnly],6)+'%' /* e.g. S. Goldmann */
						WHEN [KeyWordFirstWord_LEN] >6 THEN
							'%' + left(s.[KeyWordLettersOnly],6) + '%' /* Tiefenbacher */
						WHEN [KeyWordFirstWord_LEN] >4 THEN
							left(s.[KeyWordLettersOnly],4)+'%' 
							/* e.g. S. Goldmann */
						END)
					AND  c.[Company_LettersNumbersOnly] is not null 
					/* e.g. customer id 232816 안유배 교수님 blanked out 
					like in Ariba Chinese ones, leads to cartesian product */
					/* cannot set min keyword length to 6 since e.g. AS company would be excluded */
		left join ttenderer t on c.companyid = t.companyid
	WHERE 	
	/* g.[Contract Id] ='CW2548994'
		AND */ s.KeyWordType='Company' 
		/* precision */
	/*	and c.[Company_LettersNumbersOnly] = (case when s.keywordprecision = 'Exact' 
						then s.[KeyWordLettersOnly] else '%' END) */
		AND (
			 /* c.company = s.KeyWordVarchar255 
			 OR */ c.[Company_LettersNumbersOnly]= s.[KeyWordLettersOnly]
			/* First Word over 6 char */ 
			OR ([Company_FirstWord] /* 6 char and more */ = [KeyWordFirstWord] 
				AND [KeyWordFirstWord_LEN] >6) /* 6 = 900 hits, 5 = 1300 with e.g. Deutsche Lanolin Gesellschaft */
			/*OR (c.[CompanyName_RemoveNonAlphaNonNumericChar] LIKE s.[KeyWordLettersOnly]+'%' 
				AND s.[KeyWordLength] > 6)*/
			OR c.[company_FirstTwoWords] LIKE [KeyWordFirstTwoWords]+'%'
			OR c.[Company_LettersNumbersSpacesOnly] LIKE 
				(CASE WHEN s.KeyWordLength > 6 
				THEN [KeyWordLettersNumbersSpacesOnly]+'%' 
				ELSE [KeyWordLettersNumbersSpacesOnly]+'[ ]%' /* MYLANLDA (Mylan) */
				END)
			OR (c.[Company_LettersNumbersOnly] LIKE /* '%'+ */ s.[KeyWordFirstTwoWords_LettersOnly] +'%' /* Tiefenbacher */
				AND s.[KeyWordLength] > 8)
			OR (c.COMPANY like '%'+ s.KeyWordVarchar255 + '%' /* Tiefenbacher */
				AND s.[KeyWordLength] > 6)
			)

			/* and t.contractid = 3595 */
			/* and s.KeyWordVarchar255 = 'ESON PAC AB' */
		

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_CNT_TCOMPANYCountry_ContractID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view

[dbo].[V_TheCompany_KWS_2_CNT_TCOMPANYCountry_ContractID]
/* to do: include spaces with company name */
as 

	SELECT DISTINCT 
		s.KeyWordVarchar255
		, s.keywordlength
		, s.keywordFirstWord_UPPER
		, s.[KeyWordFirstWord_LettersOnly_UPPER]
		, s.[KeyWordLettersNumbersOnly_UPPER]
		, s.keywordFirstTwoWords_UPPER
		, s.[KeyWordFirstTwoWords_LettersOnly_UPPER] 

		, s.[KeyWordCustom1]
		, s.[KeyWordCustom2]
		, s.KeyWordLettersNumbersSpacesOnly_UPPER

		, c.company /* only exact match, first match */
		, c.COMPANYID_LN as COMPANYID /* same ID for same contract #, handle in next level */

		, t.CONTRACTID
		, c.COUNTRY
		, c.Country_IsUS
		, (case when c.country =  s.KeyWordVarchar255 
				THEN s.KeyWordVarchar255 
				ELSE '' END) as CompanyCountryExact
		, (case when (c.country =  s.KeyWordVarchar255 
			 ) /*ESON PAC AB = Esonpac AB*/
			THEN 1 ELSE 0 END) as CompanyCountryExact_Flag

		, (case when c.[country] like '%'  + s.KeyWordVarchar255 +'%' 
			THEN 1 ELSE 0 END) as CompanyCountryMatch_Like
		, (case when c.[country_isUS] ='US' and [KeyWordVarchar255] = 'United States' 
			THEN 1 ELSE 0 END) as CompanyCountry_IsUS


	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		left join T_TheCompany_VCOMPANY c
			on  c.[COUNTRY]
				LIKE  '%' + KeyWordVarchar255 + '%'
		left join ttenderer t on c.companyid_LN = t.companyid

	WHERE 
	 s.KeyWordType='CompanyCountry' 
	 and c.COUNTRYID is not null


GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_CNT_Territories_ContractID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view

[dbo].[V_TheCompany_KWS_2_CNT_Territories_ContractID]
/* to do: include spaces with Productgroup name */
as 

	SELECT DISTINCT 
		s.*

		, i.ContractID

	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		inner join t_TheCompany_all i 
			on i.[Territories] like  '%'+ s.KeyWordVarchar255 +'%'
	WHERE 
	s.KeyWordType = 'Territory'
	/* AND ContractInternalID not in (select ContractInternalID 
			from  [V_TheCompany_KWS_2_ARB_InternalPartner_ContractID])
	*/

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_JPS_TCOMPANY_ContractID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view

[dbo].[V_TheCompany_KWS_2_JPS_TCOMPANY_ContractID]
/* to do: include spaces with company name */
as 

	SELECT DISTINCT 
		s.KeyWordVarchar255
		, s.KeyWordVarchar255_UPPER
		, s.keywordlength
		, s.keywordFirstWord_UPPER
		, s.[KeyWordFirstWord_LettersOnly_UPPER]
		, s.[KeyWordLettersNumbersOnly_UPPER]
		, s.keywordFirstTwoWords_UPPER
		, s.[KeyWordFirstTwoWords_LettersOnly_UPPER] 
		, isnull(s.[KeyWordCustom1],'') AS [KeyWordCustom1]
		, isnull(s.[KeyWordCustom2],'') AS [KeyWordCustom2]
		, s.KeyWordLettersNumbersSpacesOnly_UPPER

		, c.company /* only exact match, first match */
		, 0 as COMPANYID /* same ID for same contract #, handle in next level */
		, c.CompanyType /* Individual, Company or Undefined */


		, c.ContractID
		, c.[ContractNumber]

		, c.[Company_LettersNumbersOnly_UPPER]
		, c.[Company_LettersNumbersSpacesOnly_UPPER]
/* MATCH FLAGS */	
	/* Exact match */

		, (case when (c.Company_UPPER =  s.KeyWordVarchar255_UPPER
			OR c.[Company_LettersNumbersSpacesOnly_UPPER] = s.KeyWordLettersNumbersSpacesOnly_UPPER /* if more than 6 char */) /* - . etc. do not count and compare UPPER */
			OR (c.[Company_LettersNumbersOnly_UPPER] = s.KeyWordLettersNumbersOnly_UPPER AND s.[KeyWordLength] > 7 ) /*ESON PAC AB = Esonpac AB*/
			THEN s.KeyWordVarchar255 
				ELSE '' END) as CompanyMatch_Exact

		, (case when (c.Company_UPPER =  s.KeyWordVarchar255_UPPER
			OR c.[Company_LettersNumbersSpacesOnly_UPPER] = s.KeyWordLettersNumbersSpacesOnly_UPPER /* if more than 6 char */) /* - . etc. do not count and compare UPPER */
			OR (c.[Company_LettersNumbersOnly_UPPER] = s.KeyWordLettersNumbersOnly_UPPER AND s.[KeyWordLength] > 7 ) /*ESON PAC AB = Esonpac AB*/
			THEN LEN(s.KeyWordLettersNumbersOnly_UPPER)  ELSE 0 END) as CompanyMatch_Exact_FLAG

	/*		, (case when 
			c.company =  s.KeyWordVarchar255 
				OR c.[Company_LettersNumbersSpacesOnly_UPPER] = s.KeyWordLettersNumbersSpacesOnly_UPPER 
				/* if more than 6 char */ /* - . etc. do not count and compare UPPER */
				OR left(c.[Company_LettersNumbersOnly_UPPER], LEN(s.[KeyWordLettersNumbersOnly_UPPER]) )
					= s.KeyWordLettersNumbersOnly_UPPER /* short */					
				/* AND s.[KeyWordLength] > 7	*/
							 
				 /*ESON PAC AB = Esonpac AB*/
			THEN s.KeyWordVarchar255 
				ELSE '' END)
				 as CompanyMatch_Exact

		, (case when 
			c.company =  s.KeyWordVarchar255 
				OR c.[Company_LettersNumbersSpacesOnly_UPPER] = s.KeyWordLettersNumbersSpacesOnly_UPPER 
				/* if more than 6 char */ /* - . etc. do not count and compare UPPER */
				OR left(c.[Company_LettersNumbersOnly_UPPER], LEN(s.[KeyWordLettersNumbersOnly_UPPER]) )
					= s.KeyWordLettersNumbersOnly_UPPER /* short */					
				/* AND s.[KeyWordLength] > 7	*/
							 
				 /*ESON PAC AB = Esonpac AB*/
			THEN len(s.KeyWordVarchar255)
				ELSE 0 END)
			as CompanyMatch_Exact_FLAG */

	/* LIKE match */
		/* with spaces */
/*
		, (case when c.[Company_LettersNumbersSpacesOnly_UPPER] like KeyWordLettersNumbersSpacesOnly_UPPER +'%'		
			THEN [KeyWordLettersNumbersSpacesOnly_UPPER] ELSE '' END) 
			as CompanyMatch_LIKE_LNS

		, (case when c.[Company_LettersNumbersSpacesOnly_UPPER] like KeyWordLettersNumbersSpacesOnly_UPPER +'%' 
			THEN LEN([KeyWordLettersNumbersSpacesOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_Like_LNS_FLAG
*/
		/* no spaces */

		, (case when c.[Company_LettersNumbersOnly_UPPER] like [KeyWordLettersNumbersOnly_UPPER]+'%' 
			THEN [KeyWordLettersNumbersOnly_UPPER] ELSE '' END) 
			as CompanyMatch_LIKE

		, (case when c.[Company_LettersNumbersOnly_UPPER] like [KeyWordLettersNumbersOnly_UPPER]+'%' 
			THEN LEN([KeyWordLettersNumbersOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_LIKE_FLAG

	/* reverse LIKE */
		, (case when [KeyWordLettersNumbersOnly_UPPER] like c.[Company_LettersNumbersOnly_UPPER]+'%' 
			THEN c.[Company_LettersNumbersOnly_UPPER] ELSE '' END) 
			as CompanyMatch_REV_LIKE

		, (case when [KeyWordLettersNumbersOnly_UPPER] like c.[Company_LettersNumbersOnly_UPPER]+'%' 
			THEN len(c.[Company_LettersNumbersOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_REV_LIKE_FLAG

	/* 2-way Like - ONLY FOR WHOLE FIRST or FIRST TWO WORDS!!! */
		, (case when
				 c.[Company_LettersNumbersOnly_UPPER] like '%' +[keywordFirstTwoWords_UPPER]+'%' 
					AND KeyWordFirstWord_LEN > 6
					THEN [keywordFirstTwoWords_UPPER]
				WHEN
					c.[Company_LettersNumbersOnly_UPPER] like '%' +[keywordFirstWord_UPPER]+'%' 
					AND KeyWordFirstWord_LEN > 6 
					THEN [keywordFirstWord_UPPER] 
				ELSE '' END) 
			as CompanyMatch_LIKE2Way

		, (case when
				 c.[Company_LettersNumbersOnly_UPPER] like '%' +[keywordFirstTwoWords_UPPER]+'%' 
					THEN len([keywordFirstTwoWords_UPPER])
				WHEN
					c.[Company_LettersNumbersOnly_UPPER] like '%' +[keywordFirstWord_UPPER]+'%' 
					THEN len([keywordFirstWord_UPPER]) 
				ELSE 0 END) 
			as CompanyMatch_LIKE2Way_FLAG

	/* 2-way reverse LIKE */

		, (case when [KeyWordLettersNumbersOnly_UPPER] like '%' +c.[Company_LettersNumbersOnly_UPPER]+'%' 			
			THEN c.[Company_LettersNumbersOnly_UPPER] ELSE '' END) 
			as CompanyMatch_REV_LIKE2Way
		, (case when [KeyWordLettersNumbersOnly_UPPER] like '%' +c.[Company_LettersNumbersOnly_UPPER]+'%' 
			THEN LEN(c.[Company_LettersNumbersOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_REV_LIKE2Way_FLAG

	/* First TWO Words */

		, (case when c.[Company_FirstTwoWords_LettersOnly_UPPER] like [KeyWordFirstTwoWords_LettersOnly_UPPER]+'%' 
			THEN [KeyWordFirstTwoWords_LettersOnly_UPPER] ELSE '' END) 
			as CompanyMatch_FirstTwoWords

		, (case when c.[Company_FirstTwoWords_LettersOnly_UPPER] like [KeyWordFirstTwoWords_LettersOnly_UPPER]+'%' 
			THEN LEN([KeyWordFirstTwoWords_LettersOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_FirstTwoWords_FLAG

	/* First Word, 3 char or more (e.g. ADT - was 5 char, 26-oct-20) */
		, (case when c.[Company_FirstWord_LettersOnly_UPPER] like [KeyWordFirstWord_LettersOnly_UPPER]+'%' 
			AND [KeyWordFirstWord_LEN] > 2  
				THEN KeyWordFirstWord_LettersOnly_UPPER ELSE '' END) 
			as CompanyMatch_FirstWord

		, (case when c.[Company_FirstWord_LettersOnly_UPPER] like [KeyWordFirstWord_LettersOnly_UPPER]+'%' 
			AND [KeyWordFirstWord_LEN] > 2  
				THEN LEN(KeyWordFirstWord_LettersOnly_UPPER) ELSE 0 END) 
			as CompanyMatch_FirstWord_FLAG 

	/* First Word - Two Way, if 5 char or more */

		, (case when c.[Company_FirstWord_LettersOnly_UPPER] like '%' + [KeyWordFirstWord_LettersOnly_UPPER] + '%' 
			AND [KeyWordFirstWord_LEN] > 5 /* Abbott */ /* and c.Company_FirstWord_LEN > 5 /* CS */ must exclude in query below too if any	*/	
				THEN left(s.[KeyWordFirstWord_LettersOnly_UPPER],6) ELSE '' END) 
			as CompanyMatch_FirstWord2Way

		, (case when c.[Company_FirstWord_LettersOnly_UPPER] like '%' +[KeyWordFirstWord_LettersOnly_UPPER]+'%' 
			AND [KeyWordFirstWord_LEN] > 5 /*   and c.Company_FirstWord_LEN > 5 /* CS */	*/
				THEN LEN(KeyWordFirstWord_LettersOnly_UPPER) ELSE 0 END) 
			as CompanyMatch_FirstWord2Way_FLAG 

/* First word - Two Way - Rev, if 6 char or more */
		, (case when [KeyWordFirstWord_LettersOnly_UPPER] like '%'+c.[Company_FirstWord_LettersOnly_UPPER]+'%' 
			AND [KeyWordFirstWord_LEN] > 6  and c.Company_FirstWord_LEN > 6 /* CS */	
				THEN Company_FirstWord_LettersOnly_UPPER ELSE '' END) 
			as CompanyMatch_FirstWord2Way_REV

		, (case when [KeyWordFirstWord_LettersOnly_UPPER] like '%'+c.[Company_FirstWord_LettersOnly_UPPER]+'%' 
			AND [KeyWordFirstWord_LEN] > 6   and c.Company_FirstWord_LEN > 6 /* CS */	
				THEN len(Company_FirstWord_LettersOnly_UPPER) ELSE 0 END) 
			as CompanyMatch_FirstWord2Way_REV_FLAG 

	/* First part of Keywordsearch */
		, (case when  [KeyWordLettersNumbersOnly_UPPER] = 
			LEFT([Company_LettersNumbersOnly_UPPER], LEN([KeyWordLettersNumbersOnly_UPPER]))
			/* AND [KeyWordFirstWord_LEN] > 4 */ 
				THEN LEN([KeyWordLettersNumbersOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_EntireKeywordLike_FLAG 

	/* abbreviation match */
	/*, (case when KeyWordLength = 3 and left(c.Company_FirstLetterOfEachWord_UPPER,3) 
						= left(KeyWordLettersNumbersOnly_UPPER,3) then 1 else 0 AS Company_AbbreviationMatch_Flag */ /* match is the kwd */
	, (case when KeyWordLength = 3 and left(c.Company_FirstLetterOfEachWord_UPPER,3) 
						= left(KeyWordLettersNumbersOnly_UPPER,3) then 1 else 0 END) 
						AS CompanyMatch_Abbreviation_FLAG
	, (Select  case when Patindex ('%KeyWordLettersNumbersOnly_UPPER%',Company_LettersNumbersOnly_UPPER) >0 
		then 1 else 0 end)
		as CompanyMatch_ContainsKeyword

	, (Select  case when Charindex (KeyWordLettersNumbersOnly_UPPER,Company_LettersNumbersOnly_UPPER)=1 
		then 1 else 0 end )
		as CompanyMatch_BeginsWithKeyword


	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		inner join [T_TheCompany_ContractData_JPS_1VCOMPANY] c
			on  c.[Company_LettersNumbersOnly_UPPER]
				LIKE (CASE 
						WHEN s.KeyWordFirstWord_LEN <= 4 THEN /* 4 - using first word in case surplus suffix information at back */
							left(s.[KeyWordLettersNumbersOnly_UPPER],6)+'%' /* 6 letters, e.g. S. Goldmann */
						WHEN [KeyWordFirstWord_LEN] > 6 THEN /* USE WHOLE WORD FOR TWO SIDED LIKES!! */
							'%' + s.keywordFirstWord_UPPER + '%' /* left(s.[KeyWordLettersNumbersOnly_UPPER],6) */
							/* 6 letters, e.g. Tiefenbacher, changed to 5 due to PT Abbott */
						WHEN [KeyWordFirstWord_LEN] > 4 THEN /* 4 - one sided if more than 4 char */
							left(s.[KeyWordLettersNumbersOnly_UPPER],4)+'%' /* 4 letters */
						END)
		/*		OR /* reverse LIKE */
					s.KeyWordLettersNumbersOnly_UPPER 
					LIKE (CASE WHEN [Company_FirstWord_LEN] > 6 THEN /* 6, two sided if more than 6 char */
							c.[Company_LettersNumbersOnly_UPPER] + '%' /* must match first part of vendor,
							otherwise e.g. Abbott Laboratories matches Laboratories Silesa*/
						END)
					OR (KeyWordLength = 3 and left(c.Company_FirstLetterOfEachWord_UPPER,3) 
						= left(KeyWordLettersNumbersOnly_UPPER,3)) /* 3 letter abbreviations KMC */ 
		*/
	WHERE 	
	 s.KeyWordType='Company' 
	 and c.Company is not null /* data load requires not null and min 3 char */
		AND (
			c.[Company_UPPER] = s.KeyWordVarchar255_UPPER
			or c.Company_LettersNumbersSpacesOnly_UPPER = s.KeyWordLettersNumbersSpacesOnly_UPPER
			OR (c.[Company_FirstWord_LettersOnly_UPPER] /* 2 char and more */ = [KeyWordFirstWord_LettersOnly_UPPER] 
				AND [KeyWordFirstWord_LEN] >2) /* ADT */
			OR (c.[Company] LIKE s.KeyWordVarchar255+'%' 
				AND s.[KeyWordLength] > 6)
			OR (c.[Company_LettersNumbersSpacesOnly_UPPER] LIKE [KeyWordLettersNumbersSpacesOnly_UPPER]
				+ (case when s.[KeyWordLength] > 10 THEN '%' ELSE ' %' end) /* MEDAVANTEINC (Meda) */)
			OR (c.[Company_LettersNumbersOnly_UPPER] LIKE s.[KeyWordFirstTwoWords_LettersOnly_UPPER] +'%' 
				AND s.[KeyWordLength] > 6)
			)


GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_JPS_TCOMPANY_ContractID_BAK]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view 
[dbo].[V_TheCompany_KWS_2_JPS_TCOMPANY_ContractID_BAK]
/* run time 60 seconds 31-Oct-18 */
as 

	SELECT DISTINCT 
		s.KeyWordVarchar255
		, s.keywordlength
		, s.keywordFirstWord
		, s.[KeyWordLettersOnly]
		, s.KeyWordLettersNumbersSpacesOnly
		, s.[KeyWordFirstTwoWords_LettersOnly] as KeyWordFirstTwoWords
		, s.[KeyWordCustom1]
		, s.[KeyWordCustom2]

		/*, c.[ContractID] as [ContractID] */
		, c.[ContractNumber] as [ContractNumber]
		, c.contractid
		, c.[Company]

		, c.[Company_LettersNumbersOnly]
		, c.[Company_LettersNumbersSpacesOnly]

		, c.[Company] as COMPANYID

		, (case when c.[Company] =  s.KeyWordVarchar255 
			THEN s.KeyWordVarchar255 ELSE '' END) as CompanyExact
		, (case when c.[Company] =  s.KeyWordVarchar255 
			THEN 1 ELSE 0 END) as CompanyExact_Flag
		, (case when c.[Company]
			like [KeyWordVarchar255]+'%' /* AND KeyWordLength > 5 */ THEN 1 ELSE 0 END) 
			as CompanyMatch_Like
		, (case when c.[Company_LettersNumbersOnly] 
			like [KeyWordLettersOnly]+'%' THEN 1 ELSE 0 END) 
			as CompanyMatch_LettersNumbersOnly
		, (case when c.Company_LettersNumbersSpacesOnly 
			like [KeyWordLettersNumbersSpacesOnly]+'%' THEN 1 ELSE 0 END) 
			as CompanyMatch_LettersNumbersSpacesOnly
		, (case when c.[Company_LettersNumbersOnly] /* use first two words `?? */
			like [KeyWordFirstTwoWords_LettersOnly]+'%'  
			AND [KeyWordFirstTwoWords_LettersOnly_LEN] > 4 THEN 1 ELSE 0 END) 
			as CompanyMatch_FirstTwoWords
		, (case when c.[Company_LettersNumbersOnly] 
			like [KeyWordFirstWord_LettersOnly]+'%' AND [KeyWordFirstWord_LEN] > 4 THEN 1 ELSE 0 END) 
			as CompanyMatch_FirstWord 
	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		left join [T_TheCompany_ContractData_JPS_1VCOMPANY] c
			on  c.Company_LettersNumbersOnly
			LIKE 
			(CASE WHEN LEN([KeyWordFirstWord_LettersOnly]) > 6 THEN
				'%'+s.[KeyWordFirstWord_LettersOnly]+'%' /* or an exact match */
				ELSE
				s.KeyWordLettersNumbersOnly + 
				/* (CASE 
					WHEN [Company_LettersNumbersOnly_NumSpacesWords] >1 then 
					'[]%' ELSE */ '%' /* END) */ /* ELI LILLY Skipped */
				/* or an exact match */
				END)
	WHERE 
	/* c.[Contract Id] ='CW2548994'
		AND */ s.KeyWordType='Company' 
		AND  (c.[Company] is not null) /* could also be internal partner */
		AND (
			c.[Company] = s.KeyWordVarchar255
			or c.company_lettersnumbersspacesonly = s.KeyWordLettersNumbersSpacesOnly
			OR (c.[Company_FirstWord] /* 6 char and more */ = [KeyWordFirstWord] 
				AND [KeyWordFirstWord_LEN] >6)
			OR (c.[Company] LIKE s.KeyWordVarchar255+'%' 
				AND s.[KeyWordLength] > 6)
			OR (c.[company_lettersnumbersspacesonly] LIKE [KeyWordLettersNumbersSpacesOnly]+ (case when s.[KeyWordLength] > 10 THEN '%' ELSE ' %' end) /* MEDAVANTEINC (Meda) */)
			OR (c.[Company_LettersNumbersOnly] LIKE s.[KeyWordFirstTwoWords_LettersOnly] +'%' 
				AND s.[KeyWordLength] > 6)
			)

		and c.Company IS NOT NULL /* some records only have internal partners, intercompany */
		and c.Company > ''

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_JPS_TCOMPANYCountry_ContractID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view

[dbo].[V_TheCompany_KWS_2_JPS_TCOMPANYCountry_ContractID]
/* to do: include spaces with company name */
as 

	SELECT DISTINCT 
		s.KeyWordVarchar255
		, s.keywordlength
		, s.keywordFirstWord_UPPER
		, s.[KeyWordFirstWord_LettersOnly_UPPER]
		, s.[KeyWordLettersNumbersOnly_UPPER]
		, s.keywordFirstTwoWords_UPPER
		, s.[KeyWordFirstTwoWords_LettersOnly_UPPER] 

		, s.[KeyWordCustom1]
		, s.[KeyWordCustom2]
		, s.KeyWordLettersNumbersSpacesOnly_UPPER

		, c.company /* only exact match, first match */
		/*, c.COMPANYID /* same ID for same contract #, handle in next level */*/

		, c.CONTRACTNumber
		, c.contractid
		, c.CompanyCOUNTRY
		/*, c.Country_IsUS */
		, (case when c.Companycountry =  s.KeyWordVarchar255 
				THEN s.KeyWordVarchar255 
				ELSE '' END) as CompanyCountryExact
		, (case when (c.Companycountry =  s.KeyWordVarchar255 
			 ) /*ESON PAC AB = Esonpac AB*/
			THEN 1 ELSE 0 END) as CompanyCountryExact_Flag

		, (case when c.[Companycountry] like '%'  + s.KeyWordVarchar255 +'%' 
			THEN 1 ELSE 0 END) as CompanyCountryMatch_Like
		, /*(case when c.[country_isUS] ='US' and [KeyWordVarchar255] = 'United States' 
			THEN 1 ELSE 0 END) */ '' as CompanyCountry_IsUS


	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		left join T_TheCompany_ContractData_JP_Sunrise_ExecutedAgreements c /* T_TheCompany_ContractData_JP_Sunrise_ExecutedAgreements */
			on  c.[CompanyCountry] =  KeyWordVarchar255
	WHERE 
	 s.KeyWordType='CompanyCountry' 
	 and c.companyCOUNTRYID is not null


GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_LNC_TCOMPANY_ContractID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view

[dbo].[V_TheCompany_KWS_2_LNC_TCOMPANY_ContractID]
/* to do: include spaces with company name */
as 

	SELECT DISTINCT 
		s.KeyWordVarchar255
		, s.KeyWordVarchar255_UPPER
		, s.keywordlength
		, s.keywordFirstWord_UPPER
		, s.[KeyWordFirstWord_LettersOnly_UPPER]
		, s.[KeyWordLettersNumbersOnly_UPPER]
		, s.keywordFirstTwoWords_UPPER
		, s.[KeyWordFirstTwoWords_LettersOnly_UPPER] 
		, isnull(s.[KeyWordCustom1],'') AS [KeyWordCustom1]
		, isnull(s.[KeyWordCustom2],'') AS [KeyWordCustom2]
		, s.KeyWordLettersNumbersSpacesOnly_UPPER

		, c.company /* only exact match, first match */
		, 0 as COMPANYID /* same ID for same contract #, handle in next level */
		, c.CompanyType /* Individual, Company or Undefined */


		, c.ContractID
		, c.[ContractNumber]

		, c.[Company_LettersNumbersOnly_UPPER]
		, c.[Company_LettersNumbersSpacesOnly_UPPER]
/* MATCH FLAGS */	
	/* Exact match */

		, (case when (c.Company_UPPER =  s.KeyWordVarchar255_UPPER
			OR c.[Company_LettersNumbersSpacesOnly_UPPER] = s.KeyWordLettersNumbersSpacesOnly_UPPER /* if more than 6 char */) /* - . etc. do not count and compare UPPER */
			OR (c.[Company_LettersNumbersOnly_UPPER] = s.KeyWordLettersNumbersOnly_UPPER AND s.[KeyWordLength] > 7 ) /*ESON PAC AB = Esonpac AB*/
			THEN s.KeyWordVarchar255 
				ELSE '' END) as CompanyMatch_Exact

		, (case when (c.Company_UPPER =  s.KeyWordVarchar255_UPPER
			OR c.[Company_LettersNumbersSpacesOnly_UPPER] = s.KeyWordLettersNumbersSpacesOnly_UPPER /* if more than 6 char */) /* - . etc. do not count and compare UPPER */
			OR (c.[Company_LettersNumbersOnly_UPPER] = s.KeyWordLettersNumbersOnly_UPPER AND s.[KeyWordLength] > 7 ) /*ESON PAC AB = Esonpac AB*/
			THEN LEN(s.KeyWordLettersNumbersOnly_UPPER)  ELSE 0 END) as CompanyMatch_Exact_FLAG

	/*		, (case when 
			c.company =  s.KeyWordVarchar255 
				OR c.[Company_LettersNumbersSpacesOnly_UPPER] = s.KeyWordLettersNumbersSpacesOnly_UPPER 
				/* if more than 6 char */ /* - . etc. do not count and compare UPPER */
				OR left(c.[Company_LettersNumbersOnly_UPPER], LEN(s.[KeyWordLettersNumbersOnly_UPPER]) )
					= s.KeyWordLettersNumbersOnly_UPPER /* short */					
				/* AND s.[KeyWordLength] > 7	*/
							 
				 /*ESON PAC AB = Esonpac AB*/
			THEN s.KeyWordVarchar255 
				ELSE '' END)
				 as CompanyMatch_Exact

		, (case when 
			c.company =  s.KeyWordVarchar255 
				OR c.[Company_LettersNumbersSpacesOnly_UPPER] = s.KeyWordLettersNumbersSpacesOnly_UPPER 
				/* if more than 6 char */ /* - . etc. do not count and compare UPPER */
				OR left(c.[Company_LettersNumbersOnly_UPPER], LEN(s.[KeyWordLettersNumbersOnly_UPPER]) )
					= s.KeyWordLettersNumbersOnly_UPPER /* short */					
				/* AND s.[KeyWordLength] > 7	*/
							 
				 /*ESON PAC AB = Esonpac AB*/
			THEN len(s.KeyWordVarchar255)
				ELSE 0 END)
			as CompanyMatch_Exact_FLAG */

	/* LIKE match */
		/* with spaces */
/*
		, (case when c.[Company_LettersNumbersSpacesOnly_UPPER] like KeyWordLettersNumbersSpacesOnly_UPPER +'%'		
			THEN [KeyWordLettersNumbersSpacesOnly_UPPER] ELSE '' END) 
			as CompanyMatch_LIKE_LNS

		, (case when c.[Company_LettersNumbersSpacesOnly_UPPER] like KeyWordLettersNumbersSpacesOnly_UPPER +'%' 
			THEN LEN([KeyWordLettersNumbersSpacesOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_Like_LNS_FLAG
*/
		/* no spaces */

		, (case when c.[Company_LettersNumbersOnly_UPPER] like [KeyWordLettersNumbersOnly_UPPER]+'%' 
			THEN [KeyWordLettersNumbersOnly_UPPER] ELSE '' END) 
			as CompanyMatch_LIKE

		, (case when c.[Company_LettersNumbersOnly_UPPER] like [KeyWordLettersNumbersOnly_UPPER]+'%' 
			THEN LEN([KeyWordLettersNumbersOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_LIKE_FLAG

	/* reverse LIKE */
		, (case when [KeyWordLettersNumbersOnly_UPPER] like c.[Company_LettersNumbersOnly_UPPER]+'%' 
			THEN c.[Company_LettersNumbersOnly_UPPER] ELSE '' END) 
			as CompanyMatch_REV_LIKE

		, (case when [KeyWordLettersNumbersOnly_UPPER] like c.[Company_LettersNumbersOnly_UPPER]+'%' 
			THEN len(c.[Company_LettersNumbersOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_REV_LIKE_FLAG

	/* 2-way Like - ONLY FOR WHOLE FIRST or FIRST TWO WORDS!!! */
		, (case when
				 c.[Company_LettersNumbersOnly_UPPER] like '%' +[keywordFirstTwoWords_UPPER]+'%' 
					AND KeyWordFirstWord_LEN > 6
					THEN [keywordFirstTwoWords_UPPER]
				WHEN
					c.[Company_LettersNumbersOnly_UPPER] like '%' +[keywordFirstWord_UPPER]+'%' 
					AND KeyWordFirstWord_LEN > 6 
					THEN [keywordFirstWord_UPPER] 
				ELSE '' END) 
			as CompanyMatch_LIKE2Way

		, (case when
				 c.[Company_LettersNumbersOnly_UPPER] like '%' +[keywordFirstTwoWords_UPPER]+'%' 
					THEN len([keywordFirstTwoWords_UPPER])
				WHEN
					c.[Company_LettersNumbersOnly_UPPER] like '%' +[keywordFirstWord_UPPER]+'%' 
					THEN len([keywordFirstWord_UPPER]) 
				ELSE 0 END) 
			as CompanyMatch_LIKE2Way_FLAG

	/* 2-way reverse LIKE */

		, (case when [KeyWordLettersNumbersOnly_UPPER] like '%' +c.[Company_LettersNumbersOnly_UPPER]+'%' 			
			THEN c.[Company_LettersNumbersOnly_UPPER] ELSE '' END) 
			as CompanyMatch_REV_LIKE2Way
		, (case when [KeyWordLettersNumbersOnly_UPPER] like '%' +c.[Company_LettersNumbersOnly_UPPER]+'%' 
			THEN LEN(c.[Company_LettersNumbersOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_REV_LIKE2Way_FLAG

	/* First TWO Words */

		, (case when c.[Company_FirstTwoWords_LettersOnly_UPPER] like [KeyWordFirstTwoWords_LettersOnly_UPPER]+'%' 
			THEN [KeyWordFirstTwoWords_LettersOnly_UPPER] ELSE '' END) 
			as CompanyMatch_FirstTwoWords

		, (case when c.[Company_FirstTwoWords_LettersOnly_UPPER] like [KeyWordFirstTwoWords_LettersOnly_UPPER]+'%' 
			THEN LEN([KeyWordFirstTwoWords_LettersOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_FirstTwoWords_FLAG

	/* First Word, 3 char or more (e.g. ADT - was 5 char, 26-oct-20) */
		, (case when c.[Company_FirstWord_LettersOnly_UPPER] like [KeyWordFirstWord_LettersOnly_UPPER]+'%' 
			AND [KeyWordFirstWord_LEN] > 2  
				THEN KeyWordFirstWord_LettersOnly_UPPER ELSE '' END) 
			as CompanyMatch_FirstWord

		, (case when c.[Company_FirstWord_LettersOnly_UPPER] like [KeyWordFirstWord_LettersOnly_UPPER]+'%' 
			AND [KeyWordFirstWord_LEN] > 2  
				THEN LEN(KeyWordFirstWord_LettersOnly_UPPER) ELSE 0 END) 
			as CompanyMatch_FirstWord_FLAG 

	/* First Word - Two Way, if 5 char or more */

		, (case when c.[Company_FirstWord_LettersOnly_UPPER] like '%' + [KeyWordFirstWord_LettersOnly_UPPER] + '%' 
			AND [KeyWordFirstWord_LEN] > 5 /* Abbott */ /* and c.Company_FirstWord_LEN > 5 /* CS */ must exclude in query below too if any	*/	
				THEN left(s.[KeyWordFirstWord_LettersOnly_UPPER],6) ELSE '' END) 
			as CompanyMatch_FirstWord2Way

		, (case when c.[Company_FirstWord_LettersOnly_UPPER] like '%' +[KeyWordFirstWord_LettersOnly_UPPER]+'%' 
			AND [KeyWordFirstWord_LEN] > 5 /*   and c.Company_FirstWord_LEN > 5 /* CS */	*/
				THEN LEN(KeyWordFirstWord_LettersOnly_UPPER) ELSE 0 END) 
			as CompanyMatch_FirstWord2Way_FLAG 

/* First word - Two Way - Rev, if 6 char or more */
		, (case when [KeyWordFirstWord_LettersOnly_UPPER] like '%'+c.[Company_FirstWord_LettersOnly_UPPER]+'%' 
			AND [KeyWordFirstWord_LEN] > 6  and c.Company_FirstWord_LEN > 6 /* CS */	
				THEN Company_FirstWord_LettersOnly_UPPER ELSE '' END) 
			as CompanyMatch_FirstWord2Way_REV

		, (case when [KeyWordFirstWord_LettersOnly_UPPER] like '%'+c.[Company_FirstWord_LettersOnly_UPPER]+'%' 
			AND [KeyWordFirstWord_LEN] > 6   and c.Company_FirstWord_LEN > 6 /* CS */	
				THEN len(Company_FirstWord_LettersOnly_UPPER) ELSE 0 END) 
			as CompanyMatch_FirstWord2Way_REV_FLAG 

	/* First part of Keywordsearch */
		, (case when  [KeyWordLettersNumbersOnly_UPPER] = 
			LEFT([Company_LettersNumbersOnly_UPPER], LEN([KeyWordLettersNumbersOnly_UPPER]))
			/* AND [KeyWordFirstWord_LEN] > 4 */ 
				THEN LEN([KeyWordLettersNumbersOnly_UPPER]) ELSE 0 END) 
			as CompanyMatch_EntireKeywordLike_FLAG 

	/* abbreviation match */
	/*, (case when KeyWordLength = 3 and left(c.Company_FirstLetterOfEachWord_UPPER,3) 
						= left(KeyWordLettersNumbersOnly_UPPER,3) then 1 else 0 AS Company_AbbreviationMatch_Flag */ /* match is the kwd */
	, (case when KeyWordLength = 3 and left(c.Company_FirstLetterOfEachWord_UPPER,3) 
						= left(KeyWordLettersNumbersOnly_UPPER,3) then 1 else 0 END) 
						AS CompanyMatch_Abbreviation_FLAG
	, (Select  case when Patindex ('%KeyWordLettersNumbersOnly_UPPER%',Company_LettersNumbersOnly_UPPER) >0 
		then 1 else 0 end)
		as CompanyMatch_ContainsKeyword

	, (Select  case when Charindex (KeyWordLettersNumbersOnly_UPPER,Company_LettersNumbersOnly_UPPER)=1 
		then 1 else 0 end )
		as CompanyMatch_BeginsWithKeyword


	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		inner join [T_TheCompany_ContractData_LNC_1VCOMPANY] c
			on  c.[Company_LettersNumbersOnly_UPPER]
				LIKE (CASE 
						WHEN s.KeyWordFirstWord_LEN <= 4 THEN /* 4 - using first word in case surplus suffix information at back */
							left(s.[KeyWordLettersNumbersOnly_UPPER],6)+'%' /* 6 letters, e.g. S. Goldmann */
						WHEN [KeyWordFirstWord_LEN] > 6 THEN /* USE WHOLE WORD FOR TWO SIDED LIKES!! */
							'%' + s.keywordFirstWord_UPPER + '%' /* left(s.[KeyWordLettersNumbersOnly_UPPER],6) */
							/* 6 letters, e.g. Tiefenbacher, changed to 5 due to PT Abbott */
						WHEN [KeyWordFirstWord_LEN] > 4 THEN /* 4 - one sided if more than 4 char */
							left(s.[KeyWordLettersNumbersOnly_UPPER],4)+'%' /* 4 letters */
						END)
		/*		OR /* reverse LIKE */
					s.KeyWordLettersNumbersOnly_UPPER 
					LIKE (CASE WHEN [Company_FirstWord_LEN] > 6 THEN /* 6, two sided if more than 6 char */
							c.[Company_LettersNumbersOnly_UPPER] + '%' /* must match first part of vendor,
							otherwise e.g. Abbott Laboratories matches Laboratories Silesa*/
						END)
					OR (KeyWordLength = 3 and left(c.Company_FirstLetterOfEachWord_UPPER,3) 
						= left(KeyWordLettersNumbersOnly_UPPER,3)) /* 3 letter abbreviations KMC */ 
		*/
	WHERE 	
	 s.KeyWordType='Company' 
	 and c.Company is not null /* data load requires not null and min 3 char */
		AND (
			c.[Company_UPPER] = s.KeyWordVarchar255_UPPER
			or c.Company_LettersNumbersSpacesOnly_UPPER = s.KeyWordLettersNumbersSpacesOnly_UPPER
			OR (c.[Company_FirstWord_LettersOnly_UPPER] /* 2 char and more */ = [KeyWordFirstWord_LettersOnly_UPPER] 
				AND [KeyWordFirstWord_LEN] >2) /* ADT */
			OR (c.[Company] LIKE s.KeyWordVarchar255+'%' 
				AND s.[KeyWordLength] > 6)
			OR (c.[Company_LettersNumbersSpacesOnly_UPPER] LIKE [KeyWordLettersNumbersSpacesOnly_UPPER]
				+ (case when s.[KeyWordLength] > 10 THEN '%' ELSE ' %' end) /* MEDAVANTEINC (Meda) */)
			OR (c.[Company_LettersNumbersOnly_UPPER] LIKE s.[KeyWordFirstTwoWords_LettersOnly_UPPER] +'%' 
				AND s.[KeyWordLength] > 6)
			)


GO
/****** Object:  View [dbo].[V_TheCompany_KWS_3_ARB_TCOMPANY_ContractID_Extended]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view 

[dbo].[V_TheCompany_KWS_3_ARB_TCOMPANY_ContractID_Extended]

as

SELECT 
	[ContractID]
	, [KeyWordVarchar255]
	, [KeyWordVarchar255_UPPER]
      ,[keywordlength]
      ,[keywordFirstWord_UPPER]
      ,[KeyWordFirstWord_LettersOnly_UPPER]
      ,[KeyWordLettersNumbersOnly_UPPER]
      ,[keywordFirstTwoWords_UPPER]
      ,[KeyWordFirstTwoWords_LettersOnly_UPPER]
      ,[KeyWordCustom1]
      ,[KeyWordCustom2]
      ,[KeyWordLettersNumbersSpacesOnly_UPPER]

	 /* Company */
	 /*  , [CompanyID] */
	  , [COMPANY] 	
	  , [CompanyType]

      , [Company_LettersNumbersOnly_UPPER]
      , [Company_LettersNumbersSpacesOnly_UPPER]

	/* Company Matches / Flags */
      , [CompanyMatch_Exact]
      , [CompanyMatch_Exact_Flag]

	/* LIKE */
		, (case when 
			[CompanyMatch_Exact_FLAG] = 0
			AND  [CompanyMatch_LIKE_FLAG] >= [CompanyMatch_FirstTwoWords_FLAG]
			 THEN [CompanyMatch_LIKE] 
			ELSE '' END) 
			as [CompanyMatch_LIKE]

		, (case when 
			[CompanyMatch_Exact_FLAG] = 0
			AND  [CompanyMatch_LIKE_FLAG] >= [CompanyMatch_FirstTwoWords_FLAG]
			 THEN [CompanyMatch_LIKE_FLAG] 
			ELSE 0 END) 
			as [CompanyMatch_LIKE_FLAG]

		/* REV Like */
		, (case when 
			[CompanyMatch_Exact_FLAG] = 0
			AND [CompanyMatch_Like_FLAG] = 0 
			AND [CompanyMatch_FirstWord_FLAG] = 0 /*< [CompanyMatch_REV_LIKE_FLAG] */
			AND [CompanyMatch_FirstTwoWords_FLAG] = 0
			THEN [CompanyMatch_REV_LIKE] 
			ELSE '' END) 
			as [CompanyMatch_REV_LIKE]

		, (case when 
			[CompanyMatch_Exact_FLAG] = 0
			AND [CompanyMatch_Like_FLAG] = 0 
			AND [CompanyMatch_FirstWord_FLAG] = 0 /*< [CompanyMatch_REV_LIKE_FLAG] */
			AND [CompanyMatch_FirstTwoWords_FLAG] = 0
			THEN [CompanyMatch_REV_LIKE_FLAG]
			ELSE 0 END) 
			as [CompanyMatch_REV_LIKE_FLAG]
		
		/* 2-Way LIKE */
			, (case WHEN 
					[CompanyMatch_Exact_FLAG] = 0
					AND [CompanyMatch_Like_FLAG] = 0
					AND [CompanyMatch_REV_LIKE_FLAG] = 0	
					AND [CompanyMatch_FirstWord_FLAG] < [CompanyMatch_LIKE2Way_FLAG]	
					AND [CompanyMatch_FirstTwoWords_FLAG] < [CompanyMatch_LIKE2Way_FLAG]				
				THEN [CompanyMatch_LIKE2Way] 
				ELSE '' END) 
				as [CompanyMatch_LIKE2Way]

			, (case WHEN 
					[CompanyMatch_Exact_FLAG] = 0
					AND [CompanyMatch_Like_FLAG] = 0
					AND [CompanyMatch_REV_LIKE_FLAG] = 0	
					AND [CompanyMatch_FirstWord_FLAG] < [CompanyMatch_LIKE2Way_FLAG]	
					AND [CompanyMatch_FirstTwoWords_FLAG] < [CompanyMatch_LIKE2Way_FLAG]	
				THEN [CompanyMatch_LIKE2Way_FLAG] 
				ELSE 0 END) 
				as [CompanyMatch_LIKE2Way_FLAG]

		/* 2 Way REV Like */
			, (case WHEN 
					[CompanyMatch_Exact_FLAG] = 0
					AND [CompanyMatch_Like_FLAG] = 0
					AND [CompanyMatch_REV_LIKE_FLAG] = 0	
					AND [CompanyMatch_FirstWord_FLAG] = 0
					AND [CompanyMatch_FirstTwoWords_FLAG] = 0
					AND [CompanyMatch_LIKE2Way_FLAG] = 0 
				THEN [CompanyMatch_REV_LIKE2Way] 
				ELSE '' END) 
				as [CompanyMatch_REV_LIKE2Way]

			, (case WHEN 
					[CompanyMatch_Exact_FLAG] = 0
					AND [CompanyMatch_Like_FLAG] = 0
					AND [CompanyMatch_REV_LIKE_FLAG] = 0	
					AND [CompanyMatch_FirstWord_FLAG] = 0
					AND [CompanyMatch_FirstTwoWords_FLAG] = 0
					AND [CompanyMatch_LIKE2Way_FLAG] = 0 
				THEN [CompanyMatch_REV_LIKE2Way_FLAG] 
				 ELSE 0 END) 
				as [CompanyMatch_REV_LIKE2Way_FLAG]

	/* First Two Words */
		, (CASE WHEN 
				[CompanyMatch_Exact_FLAG] = 0
				AND [CompanyMatch_Like_FLAG] < [CompanyMatch_FirstTwoWords_FLAG]
				THEN [CompanyMatch_FirstTwoWords] ELSE '' END)	
				AS [CompanyMatch_FirstTwoWords]

		, (CASE WHEN 
				[CompanyMatch_Exact_FLAG] = 0
				AND [CompanyMatch_Like_FLAG] < [CompanyMatch_FirstTwoWords_FLAG]
					THEN [CompanyMatch_FirstTwoWords_FLAG] ELSE 0 END)	
				AS [CompanyMatch_FirstTwoWords_FLAG]

	/* First Word */

		, (CASE WHEN [CompanyMatch_Exact_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
					AND CompanyMatch_LIKE_FLAG < [CompanyMatch_FirstWord_FLAG] /* more accurate than LIKE */
				THEN [CompanyMatch_FirstWord] 
				 ELSE '' END)
				AS [CompanyMatch_FirstWord]

		, (CASE WHEN [CompanyMatch_Exact_FLAG] = 0
					AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
					AND CompanyMatch_LIKE_FLAG < [CompanyMatch_FirstWord_FLAG]
				 THEN [CompanyMatch_FirstWord_FLAG]
				 ELSE 0 END)
				AS [CompanyMatch_FirstWord_FLAG]

		/* First Word 2-Way */
		, (CASE WHEN 
				[CompanyMatch_Like_FLAG] = 0
				AND [CompanyMatch_FirstWord_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
				and [CompanyMatch_LIKE2Way_FLAG] < [CompanyMatch_FirstWord2Way]
				THEN [CompanyMatch_FirstWord2Way] 
				 ELSE '' END)
				AS [CompanyMatch_FirstWord2Way]

		, (CASE WHEN 
				[CompanyMatch_Like_FLAG] = 0
				AND [CompanyMatch_FirstWord_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
				and [CompanyMatch_LIKE2Way_FLAG] < [CompanyMatch_FirstWord2Way]
				THEN [CompanyMatch_FirstWord2Way_FLAG]
				 ELSE 0 END)
				AS [CompanyMatch_FirstWord2Way_FLAG]
		
		/* First Word 2-Way Reverse */
		, (CASE WHEN 
						[CompanyMatch_Like_FLAG] = 0
				AND [CompanyMatch_FirstWord_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
				and [CompanyMatch_LIKE2Way_FLAG] < [CompanyMatch_FirstWord2Way]
				AND [CompanyMatch_FirstWord2Way_FLAG] = 0
				THEN [CompanyMatch_FirstWord2Way_REV]
				 ELSE '' END)
				AS [CompanyMatch_FirstWord2Way_REV]

		, (CASE WHEN 
						[CompanyMatch_Like_FLAG] = 0
				AND [CompanyMatch_FirstWord_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
				and [CompanyMatch_LIKE2Way_FLAG] < [CompanyMatch_FirstWord2Way]
				AND [CompanyMatch_FirstWord2Way_FLAG] = 0
				THEN [CompanyMatch_FirstWord2Way_REV_FLAG]
				 ELSE 0 END)
				AS [CompanyMatch_FirstWord2Way_REV_FLAG]
	
	/* Other */
	  , [CompanyMatch_EntireKeywordLike_FLAG]	 
	  ,  [CompanyMatch_Abbreviation_Flag]		
		, CompanyMatch_ContainsKeyword
		, CompanyMatch_BeginsWithKeyword

  FROM T_TheCompany_KWS_2_ARB_TCompany_ContractID
	/* from [dbo].[V_TheCompany_KWS_3_TCompany_ContractID] */ 

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_3_CNT_TCOMPANY_CompanyID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view 
[dbo].[V_TheCompany_KWS_3_CNT_TCOMPANY_CompanyID]

as 

	SELECT  KeyWordVarchar255
	, company
	, companyid
	, CompanyMatch_Exact /* companymatchexact */
	, count(CONTRACTID) as ContractCount
	FROM [T_TheCompany_KWS_2_CNT_TCompany_ContractID]
	group by KeyWordVarchar255, company,companyid, CompanyMatch_Exact

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_4_CNT_TPRODUCT_ContractID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view

[dbo].[V_TheCompany_KWS_4_CNT_TPRODUCT_ContractID]

as 

	SELECT  
		u.contractid as ContractID_KWS_ProductgroupID
		
/* PRODUCTS */

	,LTRIM(Replace(STUFF(
	(SELECT DISTINCT ', ' + p.productgroup /*+ ' ('+ p.keywordvarchar255 + ')' */
	FROM T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended p 
	where  p.CONTRACTID = u.contractid and p.[ProductMatch_TN] = 1 /* fuzzy */
	FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_TradeName

					 ,LTRIM(Replace(STUFF(
	(SELECT DISTINCT ', ' + p.productgroup /*+ ' ('+ p.keywordvarchar255 + ')' */
	FROM T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended p 
	where  p.CONTRACTID = u.contractid and p.[ProductMatch_AI] = 1 /* fuzzy */
	FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_ActiveIngredients

	 ,LTRIM(Replace(STUFF(
	(SELECT DISTINCT ', ' + p.productgroup
	FROM T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended p 
	where  p.CONTRACTID = u.contractid 
	and p.[ProductMatch_Exact] = 1
	FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Product_EXACT

	 ,LTRIM(Replace(STUFF(
	(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
	FROM T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended p 
	where  p.CONTRACTID = u.contractid 
	and p.[ProductMatch_NotExact] = 1
	FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Product_NotExact

	 ,LTRIM(Replace(STUFF(
	(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
	FROM T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended p 
	where  p.CONTRACTID = u.contractid 
	and p.[ProductMatch_Exact] = 0
	and p.[ProductMatch_NotExact] = 0
	FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Other

	 ,LTRIM(Replace(STUFF(
	(SELECT DISTINCT ', ' + p.keywordvarchar255 
	FROM T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended p 
	where  p.CONTRACTID = u.contractid 
	and p.KeyWord_ExclusionFlag = 0
	FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Any

			,Replace(STUFF(
			(SELECT DISTINCT ',' + rs.[KeyWordCustom1]
			FROM T_TheCompany_KWS_2_CNT_TPRODUCT_ContractID rs
			where  rs.contractid = u.contractid
			AND rs.[KeyWordCustom1] is not null
			/* and rs.ProductExact_Flag = 1 */
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Custom1_Lists

		,Replace(STUFF(
			(SELECT DISTINCT ',' + rs.[KeyWordCustom2]
			FROM T_TheCompany_KWS_2_CNT_TPRODUCT_ContractID rs
			where  rs.contractid = u.contractid
			AND rs.[KeyWordCustom2] is not null
			/* and rs.ProductExact_Flag = 1 */
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Custom2_Lists

		,Replace(STUFF(
			(SELECT DISTINCT ',' + rs.[KeyWordSource]
			FROM T_TheCompany_KWS_2_CNT_TPRODUCT_ContractID rs
			where  rs.contractid = u.contractid
			AND rs.[KeyWordSource] is not null
			/* and rs.ProductExact_Flag = 1 */
			FOR XML PATH('')),1,1,''),'&amp;','&') AS KeyWordSource_Lists
	FROM 
		T_TheCompany_KWS_3_CNT_TProduct_ContractID_Extended u
	/* where u.KeyWord_ExclusionFlag = 0 no Vitamin etc. */
	group by 
		u.CONTRACTID


GO
/****** Object:  View [dbo].[V_TheCompany_KWS_5_CNT_TCOMPANY_summary_Keyword_CompanyID_gap]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_KWS_5_CNT_TCOMPANY_summary_Keyword_CompanyID_gap]
as

	select top 1000 
		s.KeyWordVarchar255
		, s.KeyWordLettersNumbersSpacesOnly
		, r.[Company_List]
		, r.[Custom1_List]
		, r.[Custom2_List]

		, r.[ContractCount]

		, r.[CompanyMatchLevel_Min]

	from T_TheCompany_KeyWordSearch s 
		left join V_TheCompany_KWS_4_CNT_TCOMPANY_summary_KeyWord_CompanyID  r 
		on s.KeyWordVarchar255 = r.KeyWordVarchar255
	where [KeyWordType] = 'Company'  
	order by s.KeyWordVarchar255 ASC, r.companymatchlevel_Min ASC

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_5c_ARB_DESCRIPTION_ContractID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view 
[dbo].[V_TheCompany_KWS_5c_ARB_DESCRIPTION_ContractID]

as 

	SELECT  
		s.KeyWordVarchar255 as DescriptionKeyword
		, s.KeyWordType
		,p.[ContractNumber]
		, p.ContractinternalID as ContractID /* uses RAW! */
	FROM T_TheCompany_KeyWordSearch s 
		/* was left */ inner join [T_TheCompany_AribaDump] p 
		on 
			 p.[contract description]  LIKE 
				(CASE WHEN s.KeyWordLength < 4 THEN
				 '%[^a-z]'+s.KeyWordVarchar255+'[^a-z]%'
				 ELSE
				 '%'+s.KeyWordVarchar255+'%'
				 END)
		/*where   p.state = 'Active' state */
		/* and s.KeyWordType = 'Project','Description' */
	WHERE /* see TheVendor for problem contents */
		p.contractinternalid not in  (
			select contractinternalid from T_TheCompany_KWS_3_ARB_TCompany_contractid_Extended
				/*UNION
			select contractinternalid from T_TheCompany_KWS_3_ARB_TProduct_contractid_Extended */
				UNION 
			select contractinternalid from T_TheCompany_KWS_2_ARB_InternalPartner_contractid
			/*	UNION 
			select  contractinternalid from T_TheCompany_KWS_2_ARB_Territories_contractid
				UNION
			select contractinternalid from T_TheCompany_KWS_2_ARB_TCOMPANYCountry_contractid
				UNION
			select contractinternalid from T_TheCompany_KWS_2_ARB_Tag_contractid */
			)
		
GO
/****** Object:  View [dbo].[V_TheCompany_kws_CompanyMatchFlagCheck]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_kws_CompanyMatchFlagCheck] as
SELECT TOP (10000) [ContractID]
    /*  ,[KeyWordVarchar255]
      ,[keywordlength]
      ,[keywordFirstWord]
      ,[KeyWordFirstWord_LettersOnly]
      ,[KeyWordLettersOnly]
      ,[keywordFirstTwoWords]
      ,[KeyWordFirstTwoWords_LettersOnly]
      ,[KeyWordCustom1]
      ,[KeyWordCustom2]
      ,[KeyWordLettersNumbersSpacesOnly]
      ,[CompanyID]
      ,[COMPANY]
      ,[CompanyType]
      ,[Company_LettersNumbersOnly]
      ,[Company_LettersNumbersSpacesOnly] */
      ,[CompanyMatch_Exact_Flag] as 'A'
      ,[CompanyMatch_LIKE_FLAG] as 'B'
      ,[CompanyMatch_REV_LIKE_FLAG] as 'C'
      ,[CompanyMatch_LIKE2Way_FLAG] as 'D'
      ,[CompanyMatch_REV_LIKE2Way_FLAG] as 'E'

        ,[CompanyMatch_FirstTwoWords_FLAG] as 'F'
      ,[CompanyMatch_FirstWord_FLAG] as 'G'
      ,[CompanyMatch_FirstWord2Way_FLAG] as 'H'
      ,[CompanyMatch_FirstWord2Way_REV_FLAG] as 'I'

  FROM [TheVendor_app].[dbo].[V_TheCompany_KWS_3_CNT_TCOMPANY_ContractID_Extended]
  WHERE [CompanyMatch_FirstWord2Way_REV_FLAG] >0
       AND 
	   ([CompanyMatch_REV_LIKE_FLAG] <> 0
       AND [CompanyMatch_LIKE_FLAG]  <> 0 
      AND [CompanyMatch_REV_LIKE_FLAG]  <> 0 
     AND [CompanyMatch_LIKE2Way_FLAG]  <> 0 
     AND [CompanyMatch_REV_LIKE2Way_FLAG]  <> 0
        AND [CompanyMatch_FirstTwoWords_FLAG]  <> 0
     AND [CompanyMatch_FirstWord_FLAG]  <> 0
       AND [CompanyMatch_FirstWord2Way_FLAG] <> 0
    /*   AND [CompanyMatch_FirstWord2Way_REV_FLAG]  <> 0*/ 
	  )
GO
/****** Object:  View [dbo].[V_TheCompany_KzWS_0z_Ariba_TheVendorUnion]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE view [dbo].[V_TheCompany_KzWS_0z_Ariba_TheVendorUnion]

as
/* note: comments missing but might add too much bulk */

SELECT 2 as SourceSystem,
 [ContractNumber] as [Number] /* cannot use internal id otherwise TheVendor numbers cannot be found by number e.g. matches pattern %11139903  */
      , 0 as [CONTRACTID]

      ,[Contract Description] as [Title]
      ,[Contract Description] as [Title_InclTopSecret]
      ,'' as [CONTRACTTYPE]
      , 12 /* Contract */ as [CONTRACTTYPEID] /* to make sure Ariba contracts not filtered out in BO on filter contracctypeid not test delete */
      ,'' as [Agreement_Type_Top25WithOther]
      ,'' as [Agreement_Type_Top25Flag]
      , [contractinternalid] as [REFERENCENUMBER] /* friendly Ariba number */
      , [Start Date] as [CONTRACTDATE]
      ,CONVERT(VARCHAR(7), [Start Date], 120) as [RegisteredDate_YYYY_MM]
	        , (CASE 
			WHEN DATEDIFF(mm,[Start Date],GetDate()) <=3 THEN '0-3 Months'
			WHEN DATEDIFF(mm,[Start Date],GetDate()) Between 4 and 11 THEN '04-11 Months'
			WHEN DATEDIFF(mm,[Start Date],GetDate()) Between 12 and 36 THEN '12-36 Months'
			WHEN DATEDIFF(mm,[Start Date],GetDate()) > 36 THEN '36+ Months'
		END) as [RegisteredDateNumMthCat]
      ,'' as [AWARDDATE]
      , [Start Date] as [STARTDATE]
      , [End Date] as [EXPIRYDATE]
      ,'' as [REV_EXPIRYDATE]
      , [End Date] as [FINAL_EXPIRYDATE]
      ,[Review Date]as [REVIEWDATE]
      ,[Review Date Reminder] as [RD_ReviewDate_Warning]
      ,NULL as [CHECKEDOUTDATE]
      ,NULL as [DEFINEDENDDATE]
      ,  [STATUS]
      ,'' as [ContractRelations]
      ,null as [NUMBEROFFILES]
      ,NULL as [EXECUTORID]
      ,NULL as [OWNERID]
      ,NULL as [TECHCOORDINATORID]
      ,NULL as [STATUSID]
      ,'' as [StatusFixed]
      , '' as [REFERENCECONTRACTNUMBER]
      ,'' as [COUNTERPARTYNUMBER]
      ,[Agreement Type] as [AGREEMENT_TYPE]
      ,NULL as [AGREEMENT_TYPEID]
      ,NULL as [AGREEMENT_FIXED]
	  , '' as STRATEGYTYPE
      ,[Company Names] as [CompanyList]
      ,'' as [CompanyIDList]
      ,'' as [CompanyIDAwardedCount]
      ,'' as [CompanyIDUnawardedCount]
      ,[Company Count] as [CompanyIDCount]
      ,'' as [Heading]
      ,'' as [US_Userid]
      ,'' as [US_DisplayName]
      ,'' as [US_Email]
      ,'' as [US_Firstname]
      ,'' as [US_PrimaryUserGroup]
      ,'' as [US_USER_MIK_VALID]
      ,'' as [US_DPT_CODE]
      ,'' as [US_DPT_NAME]
      ,'' as [UO_employeeid]
      ,[Owner Name] as [UO_DisplayName]
      ,[Owner Email] as [UO_Email]
      ,'' as [UO_Firstname]
      ,'' as [UO_PrimaryUserGroup]
      ,NULL as [UO_USER_MIK_VALID]
      ,'' as [UO_DPT_CODE]
      ,'' as [UO_DPT_NAME]
      ,'' as [UR_employeeid]
      ,'' as [UR_DisplayName]
      ,'' as [UR_Email]
      ,'' as [UR_Firstname]
      ,'' as [UR_PrimaryUserGroup]
      ,NULL as [UR_USER_MIK_VALID]
      ,'' as [UR_DPT_CODE]
      ,'' as [UR_DPT_NAME]
      ,'' as [Dpt_Name_US]
      ,NULL as [Dpt_ID_US]
      ,NULL as [Dpt_Code_US]
      ,[Internal Partners] as [InternalPartners]
      ,'' as [InternalPartners_IDs]
      ,[Internal Partners Count] as [InternalPartners_COUNT]
      ,[Territories] as [Territories]
      ,'' as [Territories_IDs]
      ,[Territories Count] as [Territories_COUNT]
      ,[All Products] as [VP_ProductGroups]
      ,'' as [VP_ProductGroups_IDs]
      ,'' as [VP_ProductGroups_COUNT]
      ,'' as [VP_ActiveIngredients]
      ,'' as [VP_TradeNames]
      ,'' as [VP_DirectProcurement]
      ,'' as [VP_IndirectProcurement]
      ,[Lump Sum] as [LumpSum]
      ,[LumpSumCurrency] as [LumpSumCurrency]
      ,'' as [Region] /* the Ariba 'region' are the territories, verbatim: 'region that the goods and/or services are received or utilized' */
      ,NULL as [DEPARTMENTID]
      ,'' as [LEVEL]
      ,'' as [L0]
      ,'' as [L1]
      ,'' as [L2]
      ,'' as [L3]
      ,'' as [L4]
      ,'' as [L5]
      ,'' as [L6]
      ,'' as [L7]
      ,'' as [DEPARTMENT]
      ,'' as [DEPARTMENT_CONCAT]
      ,NULL as [DPT_LOWEST_ID_TO_SHOW]
      ,'' as [DEPARTMENT_CODE]
      ,'' as [DPT_CODE_2Digit_InternalPartner]
      ,'' as [DPT_CODE_2Digit_TerritoryRegion]
      ,'' as [DPT_CODE_2Digit]
      ,'' as [DPT_CODE_FirstChar]
      ,'' as [FieldCategory]
      ,'' as [NodeType]
      ,'' as [NodeRole]
      ,'' as [NodeMajorFlag]
      ,NULL as [PARENTID]
      ,[DateTableRefreshed]
      ,[LinkToContractURL]
      ,NULL as [Procurement_AgTypeFlag]
      ,NULL as [Procurement_RoleFlag]
      ,NULL as [Tags]
  FROM V_TheCompany_AribaDump_TheVendorView
  UNION ALL
SELECT 
1 as SourceSystem,
* 
from T_TheCompany_ALL



GO
/****** Object:  View [dbo].[V_TheCompany_KzWSR_0_ARB_BAK]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_KzWSR_0_ARB_BAK]

as
/* EXEC [dbo].[TheCompany_KeyWordSearch] */
	select /* distinct not needed */

		 LTRIM((CASE WHEN u.ProductKeyword_Any >'' THEN ' Product' ELSE '' END)
		 + 	(CASE WHEN u.CompanyMatch_Exact >'' THEN ' Company(1-Exact)'
/*				  WHEN u.CompanyMatch_Like >'' THEN ' Company(2-LIKE)' */
				  WHEN u.CompanyMatch_Any >'' THEN ' Company(3-Any)' 
				  ELSE '' END)
		 + 	(CASE WHEN u.Description_Match >'' THEN ' ' + ' Description' ELSE '' END)
		 + 	(CASE WHEN u.InternalPartner_Match >'' THEN ' ' + ' InternalPartner' ELSE '' END)
		 + 	(CASE WHEN u.Territory_Match >'' THEN ' ' + ' Territory' ELSE '' END)	
		 + 	(CASE WHEN u.CompanyCountryMatch >'' THEN ' ' + ' Country(Company)' ELSE '' END)	
		 + 	(CASE WHEN u.TagCategory_Match >'' THEN ' ' + ' TagCategory' ELSE '' END)			 
		 )
			 as MatchLevel

		, LTRIM((CASE WHEN u.ProductKeyword_Any > '' 
			then u.ProductKeyword_Any + ' (Product); ' ELSE '' END)
			 + (CASE WHEN u.CompanyMatch_any >'' THEN  ' ' 
				+ u.CompanyMatch_any + ' (Company); ' ELSE '' END)
			 + (CASE WHEN u.Description_Match >'' THEN ' ' 
				+ u.Description_Match + ' (Desc); ' ELSE '' END)
			 + (CASE WHEN u.InternalPartner_Match >'' THEN ' ' 
				+ u.InternalPartner_Match + ' (IP); ' ELSE '' END)
			 + (CASE WHEN u.Territory_Match >'' THEN ' ' 
				+ u.Territory_Match + ' (TT); ' ELSE '' END) 
			 + (CASE WHEN u.CompanyCountryMatch >'' THEN ' ' 
				+ u.CompanyCountryMatch + ' (CompanyCty); ' ELSE '' END) 
			 + (CASE WHEN u.TagCategory_Match >'' THEN ' ' 
				+ u.TagCategory_Match + ' (TagCat); ' ELSE '' END) 
				)
			 as KeywordMatch_Any

		/* PRODUCT */
			, u.ProductKeyword_Any
			 /*, p.[KeyWordMatch_TradeName]
			 , p.[KeyWordMatch_ActiveIngredients] */

		 /* COMPANY */
			, NULL as CompanyMatch_Score
			, '' as companyMatch_Level
			, u.CompanyMatch_Any /* any */ as 'Company (Any)'
			, /* u.CompanyMatch_Like */ '' as 'Company (Like)'
			, u.CompanyMatch_Exact as 'Company (Exact)'

		/* COUNTRY */
			, /* u.CompanyCountryMatch */ '' as 'Company Country Match'

		/* DESCRIPTION */
			, u.Description_Match as DescriptionOnly 

		/* LISTS */
			, '' as KeyWordSource_Lists
			, u.[Custom1_Lists]
			, u.[Custom2_Lists]
		
		/* TERRITORIES, INTERNAL PARTNERS */
			, /* u.Territory_Match */ '' AS TerritoryMatch
			, /* u.InternalPartner_Match */ '' AS InternalPartner_Match
					 
		 /* ALL */
		 , s.*
	from  V_TheCompany_KWS_0_TheVendorView_Ariba s
		 inner join T_TheCompany_KWS_7_ARB_ContractID_SummaryByContractID u
			on s.ContractID = u.[ContractID]

GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_MASTER_AgreementTypes]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view 
[dbo].[V_TheCompany_LNC_Mig_MASTER_AgreementTypes]

as
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT  [AgrTypeID]
      ,[AgrType]
      ,[Agr_LINC_MainType_DefaultTheVendor]
      ,[Agr_LINC_SubType_DefaultTheVendor]
      ,[Agr_LINC_MainType]
      ,[Agr_LINC_SubType]
	  , [Agr_LNC_Comments]
      ,[AgrMikValid]
      ,[AgrFixed]
      ,[Agr_IsMaterial_Flag]
      ,[AgrIsMaterial]
      ,[Agr_IsDivestment_Flag]
      ,[AgrIsDivestment]
      ,[AgrType_Top25Flag]
      ,[AgreementType_IsPrivate_FLAG]
      ,[AgreementType_IsPUBLIC_FLAG]
      ,[AgreementType_PublicPrivate]
      ,[AgrType_IsHCX]
      ,[AgrType_IsHCX_Flag]
      ,[AgrType_LgArbSplitDptMtrTMIP_FLAG]
      ,[TargetSystem_AgTypeFLAG]
      ,[TargetSystem_AgType]
      ,[AgrType_ContractCount]
      ,[AgrType_DocumentCount]
      ,[AgrType_ActSampleContract]
 , GETDATE() as DateRefreshed
  FROM [TheVendor_app].[dbo].[V_TheCompany_AgreementType]
GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_MASTER_TCountries]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view

[dbo].[V_TheCompany_LNC_Mig_MASTER_TCountries]

as

select 
	c.COUNTRY
	, [CtyCode2Letter]
	, CtyIsSpecialItem
from 
	TCOUNTRY c 
		left join t_TheCompany_tcountries tc 
			on c.COUNTRY = TC.ctyname
		where 
		c.MIK_VALID = 1
GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_Tags]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view

[dbo].[V_TheCompany_LNC_Mig_Tags]
/* run data load first for current tags */
as 

	select 
		'CTK-' + ltrim(STR(t.DOCUMENTID)) as DOCUMENTID_CTK
		, t.TagCategory as TagCategory_Name

		, d.[TagCatIDCount]
		, d.tagCategory_List
		,g.Document_Title
		/*, g.number */
		, t.DOCUMENTID

		, getdate() as LastRefreshDate
	  FROM [TheVendor_app].[dbo].[T_TheCompany_TTag_Summary_TagCategory] t 
		inner join [dbo].[T_TheCompany_TTag_Summary_DOCUMENTID] d 
			on t.documentid = d.documentid 
	  /* WHERE t.documentid in (select DOCUMENTID from [dbo].[V_TheCompany_LNC_GoldStandard_Documents]) */
		inner join [dbo].[T_TheCompany_LNC_GoldStandard_Documents] g
			on t.documentid = g.documentid

GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_TSTATUS_Contract]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view

[dbo].[V_TheCompany_LNC_Mig_TSTATUS_Contract]

as 

	select 
	[STATUS] as ContractStatus
	, count(*) as CountID
	/* ALL IDs */

	,SUBSTRING(STUFF(
	(SELECT distinct ',' + s.CONTRACTTYPE
	FROM T_TheCompany_ALL s
	WHERE s.statusid =a.statusid
	FOR XML PATH('')),1,1,''),1,255) AS ContractTypeList_255

	,SUBSTRING(STUFF(
	(SELECT top 10 ',' + s.Number
	FROM T_TheCompany_ALL s
	WHERE s.statusid =a.statusid
	FOR XML PATH('')),1,1,''),1,255) AS Sample_ContractNumberList_255
	, STATUSID
	from 
		T_TheCompany_ALL a
	group by [STATUS], statusid


GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_zPersonrole_DATA]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[V_TheCompany_LNC_Mig_zPersonrole_DATA]

as 

SELECT 

      [OBJECTID] as CONTRACTID
       ,[ROLE]    
      /* ,[ROLEID] */
      ,[DISPLAYNAME]
      ,[USERID]
      ,[FIXED]
      ,[MIK_SEQUENCE]
      ,[MIK_VALID]
      ,[ISPERSONROLE]
      ,[ISDEPARTMENTROLE]
      ,[RoleCategory]
      ,[RoleCategoryFull]

      ,[Roleid_Cat2Letter] 
	, [PERSONROLE_IN_OBJECTID]
      ,[PERSONID]
	  , OBJECTTYPEID
FROM V_TheCompany_VPPERSONROLE_IN_OBJECT
GO
/****** Object:  View [dbo].[V_TheCompany_ProcurementAgreementTypes]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_ProcurementAgreementTypes]
as

select TOP 1000 * from (
select 
AGREEMENT_TYPE
, (CASE 
	WHEN FIXED LIKE '%$ARIBA' THEN '$ARIBA' 
	WHEN FIXED LIKE '%$LEGAL' THEN '$LEGAL' 
	WHEN FIXED LIKE '%$DPT' THEN '$DPT' 
	WHEN FIXED LIKE '%$SPLIT' THEN '$SPLIT' 
	ELSE '' END) AS FIXED_$TAG
, AGREEMENT_TYPEID
, MIK_SEQUENCE
, MIK_VALID
, FIXED

FROM TAGREEMENT_TYPE ) as tbl

order by agreement_type

GO
/****** Object:  View [dbo].[V_TheCompany_Product_Upload]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_Product_Upload]

as

select TOP 1000 * 
from T_TheCompany_Product_Upload 
order by Uploaded_DateTime desc
GO
/****** Object:  View [dbo].[V_TheCompany_ProductHierarchy_Sub]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_ProductHierarchy_Sub]

as

SELECT        p1.PRODUCTGROUP, p1.PARENTID

, p2.productgroup as Productgroup2
FROM            TPRODUCTGROUP p1 inner join TPRODUCTGROUP p2 on p2.PRODUCTGROUP like p1.PRODUCTGROUP+ '%'
WHERE        (p1.PRODUCTGROUPNOMENCLATUREID = 3) 
AND p1.mik_valid = 1
/*and PARENTID is null*/

and p2.PRODUCTGROUP like 'ABALGIN'+'%'
GO
/****** Object:  View [dbo].[V_TheCompany_RegForm_AgreemtType]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_RegForm_AgreemtType]

as

/* waiting for SSO for user joest */

select TOP 9999 
AGREEMENT_TYPE as 'AgreementType'
FROM TAGREEMENT_TYPE
where 
 MIK_VALID = 1
order by AGREEMENT_TYPE


GO
/****** Object:  View [dbo].[V_TheCompany_RegForm_ContractRelation]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_RegForm_ContractRelation]

as

/* waiting for SSO for user joest */

	select TOP 9999 
		[CONTRACTRELATION] as 'Contract_Relation'
	FROM TCONTRACTRELATION
	where 
	 MIK_VALID = 1
	order by [CONTRACTRELATION]


GO
/****** Object:  View [dbo].[V_TheCompany_RegForm_DptGroups]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_RegForm_DptGroups]

as

/* waiting for SSO for user joest */

select top 999 u.usergroup as 'PrimaryUserGroup'
, d.DEPARTMENT as Department
, d.DEPARTMENT_CODE as Department_Code 
, d.departmentid
, GETDATE() as Last_Updated
FROM TDEPARTMENT d inner join TUSERGROUP u on d.DEPARTMENTID = u.DEPARTMENTID
left join T_TheCompany_Hierarchy h on d.DEPARTMENTID = h.departmentid
where USERGROUP like 'Departments%' /* and USERGROUP <>'Territories' */
AND d.MIK_VALID = 1
order by usergroup



GO
/****** Object:  View [dbo].[V_TheCompany_RegForm_InternalPartners]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[V_TheCompany_RegForm_InternalPartners]

as

/* waiting for SSO for user joest */

select top 9999 
DEPARTMENT as Internal_Partner
, DEPARTMENT + ' - ' + InternalPartnerStatus as InternalPartner_WithStatus
, DEPARTMENT_CODE as Department_Code 
, Code_Shortcut as InternalPartner_Abbreviation
, InternalPartnerStatus
, GETDATE() as Last_Updated
FROM V_TheCompany_VDepartment_InternalPartner_ParsedDpt
where DEPARTMENTID is not null /* USERGROUP like 'Internal P%' and USERGROUP <>'Internal Partner' */
AND department_code like ',%'
AND DEPARTMENT_CODE <>','
/* AND MIK_VALID = 1  include inactive since there might be contracts for those too ?*/
order by DEPARTMENT




GO
/****** Object:  View [dbo].[V_TheCompany_RegForm_Territories]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_RegForm_Territories]

as

/* waiting for SSO for user joest */

select top 999 
	d.DEPARTMENT as Territory_Name
	, d.DEPARTMENT_CODE as Department_Code 
	,h.L1 as Area_Country_Folder
	, GETDATE() as Last_Updated
FROM TDEPARTMENT d inner join TUSERGROUP u on d.DEPARTMENTID = u.DEPARTMENTID
	left join T_TheCompany_Hierarchy h on d.DEPARTMENTID = h.departmentid
where USERGROUP like 'Territories%' /* and USERGROUP <>'Territories' */
	AND d.MIK_VALID = 1
	and d.DEPARTMENT not like 'Territories%'
order by h.L1, h.L2, h.L3


GO
/****** Object:  View [dbo].[V_TheCompany_Remap_AgreementType]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_Remap_AgreementType]

as 

Select dbo.TheCompany_RemoveNonAlphaCharacters(r.agreementtypeinput_N) as NewStripped
, dbo.TheCompany_RemoveNonAlphaCharacters(a.AGREEMENT_TYPE) as Oldstripped
from dbo.T_TheCompany_Remap_AgreementType r left join TAGREEMENT_TYPE a
on dbo.TheCompany_RemoveNonAlphaCharacters(r.agreementtypeinput_N) = dbo.TheCompany_RemoveNonAlphaCharacters(a.AGREEMENT_TYPE)

GO
/****** Object:  View [dbo].[V_TheCompany_TCONTRACT_CHECK]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_TCONTRACT_CHECK]
as

select 
 [CONTRACTID]
      ,[CONTRACTNUMBER]
      ,[CONTRACT]
	      ,[EXPIRYDATE]
		,[AGREEMENT_TYPEID]
		
	  from tcontract
GO
/****** Object:  View [dbo].[V_TheCompany_TcontractNumberParsedNumber]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view

[dbo].[V_TheCompany_TcontractNumberParsedNumber]

as 

select 

c.Contractid
, c.Contractnumber as ContractNumber_TContract
, n.CONTRACTNUMBER as ContractNumber_TContractNumber
, c.contracttypeid
,len(c.Contractnumber) as lenCN

, SUBSTRING(c.CONTRACTNUMBER
	,0
	,CHARINDEX('-',c.CONTRACTNUMBER)) 
	as ContractNum_Series
	
, SUBSTRING(c.CONTRACTNUMBER
	,CHARINDEX('-',c.CONTRACTNUMBER) +1
	,(LEN(c.CONTRACTNUMBER)+1)-CHARINDEX('-',c.CONTRACTNUMBER)) 
	as ContractNum_Numeric
, t.CONTRACTTYPE + '-' + SUBSTRING(c.CONTRACTNUMBER
	,CHARINDEX('-',c.CONTRACTNUMBER) +1
	,(LEN(c.CONTRACTNUMBER)+1)-CHARINDEX('-',c.CONTRACTNUMBER))  as ContractOriginalNum
	
from TCONTRACT c inner join TCONTRACTTYPE t on c.CONTRACTTYPEID = t.CONTRACTTYPEID
left join TCONTRACTNUMBER n on c.CONTRACTID = n.contractid


GO
/****** Object:  View [dbo].[V_TheCompany_tdepartmentrole_in_object_GroupedByDptID]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[V_TheCompany_tdepartmentrole_in_object_GroupedByDptID]

as

/* Cases are EXCLUDED */

select 
o.objectid as Dpt_Objectid
, h.Region as Dpt_Region
, h.L1 as Dpt_L1
, h.L2 as Dpt_L2
, h.L3 as Dpt_L3
, h.L4 as Dpt_L4
, h.Department as Dpt_DepartmentName
, h.NodeType as Dpt_NodeType
, h.NodeMajorFlag as Dpt_NodeMajorFlag
, COUNT(o.departmentid) as Dpt_IDCount
, max(o.DEPARTMENTROLE_IN_OBJECTID) as Dpt_DptroleObjectid_Max
, COUNT(o.DEPARTMENTROLE_IN_OBJECTID) as Dpt_DptroleObjectid_Count
, MAX(ROLEID ) as Dpt_RoleID_Max
, COUNT(o.ROLEID) as Dpt_RoleID_Count
from tdepartmentrole_in_object o 
inner join t_TheCompany_Hierarchy h on o.departmentid = h.Departmentid_Link
inner join TCONTRACT c on o.OBJECTID = c.contractid
where c.contractid not in ('6' /*Access*/, '13' /*Delete*/, '11' /*Case*/, '102', '5' /*Test*/,'4','104' /*Corporate Agreement*/)
and h.L1 not like '[_]%' /* Worldwide, N/A*/
and h.L2 not like '[_]%' /* Worldwide, N/A*/
/* and h.L2 not like 'NEMEA Departments' */
GROUP BY o.objectid
, h.Region
, h.L1
, h.L2
, h.L3
, h.L4
, h.department
, h.NodeType
, h.NodeMajorFlag







GO
/****** Object:  View [dbo].[V_TheCompany_tdepartmentrole_in_object_WithHierarchy]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_tdepartmentrole_in_object_WithHierarchy]

as

/* Grouped By ObjectID (no DepartmentID) */

	select 
		o.objectid as Dpt_Objectid
	/*	, h.DEPARTMENTID as Dpt_ID DO NOT INCLUDE otherwise way more records!! */
		, h.Region as Dpt_Region
		, h.L1 as Dpt_L1
		, h.L2 as Dpt_L2
		, h.L3 as Dpt_L3
		, h.L4 as Dpt_L4
		, h.Department as Dpt_DepartmentName
		, h.NodeType as Dpt_NodeType
		, h.NodeMajorFlag as Dpt_NodeMajorFlag

		, COUNT(o.departmentid) as Dpt_IDCount
		, max(o.DEPARTMENTROLE_IN_OBJECTID) as Dpt_DptroleObjectid_Max
		, COUNT(o.DEPARTMENTROLE_IN_OBJECTID) as Dpt_DptroleObjectid_Count
		, MAX(ROLEID ) as Dpt_RoleID_Max
		, COUNT(o.ROLEID) as Dpt_RoleID_Count
	from tdepartmentrole_in_object o 
		inner join t_TheCompany_Hierarchy h on o.departmentid = h.Departmentid_Link
		inner join TCONTRACT c on o.OBJECTID = c.contractid
	where c.contractid not in ('6' /*Access*/, '13' /*Delete*/, '11' /*Case*/, '102', '5' /*Test*/,'4','104' /*Corporate Agreement*/)
		and h.L1 not like '[_]%' /* Worldwide, N/A*/
		and h.L2 not like '[_]%' /* Worldwide, N/A*/
		/* and h.L2 not like 'NEMEA Departments' */
	GROUP BY o.objectid
		, h.Region
		, h.L1
		, h.L2
		, h.L3
		, h.L4
		, h.department
		, h.NodeType
		, h.NodeMajorFlag
	/*	, h.DEPARTMENTID - NO, blows up list */


GO
/****** Object:  View [dbo].[V_TheCompany_TTenderer_Tcompany]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_TTenderer_Tcompany]

as

/* waiting for SSO for user joest */

select t.*,c.COMPANY,c.CREATEDATE from 
ttenderer t inner join tcompany c on t.COMPANYID = c.COMPANYid




GO
/****** Object:  View [dbo].[V_TheCompany_UserProfilesAndUserGroups]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_UserProfilesAndUserGroups]

as


select top 1000
i.UserGroupInUserProfileID
, p.USERPROFILE,p.MIK_VALID
, g.usergroup
, g.FIXED
from dbo.TUserGroupInUserProfile i
inner join TUserProfile p on i.UserProfileID = p.USERPROFILEID
inner join TUSERGROUP g on i.UserGroupID = g.USERGROUPid
order by p.USERPROFILE, g.USERGROUP
GO
/****** Object:  View [dbo].[V_TheCompany_VCOMPANY_DUPLICATES]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_VCOMPANY_DUPLICATES]

as

	select 
	Company_LettersNumbersOnly_UPPER 
	, COUNTRY
	, MIN(companyid_LN) as Companyid_Min
	, MAX(companyid_LN) as Companyid_Max

	, '	update ttenderer set companyid = ' 
	+ 	convert(varchar(255),MAX(companyid_LN)) 
	+ ' WHERE companyid = ' + convert(varchar(255),MIN(companyid_LN))  as UpdateMax

	, '	update ttenderer set companyid = ' 
	+ 	convert(varchar(255),MIN(companyid_LN)) 
	+ ' WHERE companyid = ' + convert(varchar(255),MAX(companyid_LN))  as UpdateMin
/*	, min(Sample_ContractNumber_Min) as Sample_ContractNumber_Min
	, min(Sample_ContractNumber_Max) as Sample_ContractNumber_Max */
	from
		T_TheCompany_VCompany
	where LEN(Company_LettersNumbersOnly_UPPER) >3
	group by Company_LettersNumbersOnly_UPPER, COUNTRY
	having COUNT(*) >1

GO
/****** Object:  View [dbo].[V_TheCompany_VCONTRACTz]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[V_TheCompany_VCONTRACTz]

as

SELECT     
/* TCONTRACTRELATION.FIXED AS ContractRelationFIXED */
  TCONTRACT.CONTRACTNUMBER AS Number
, TCONTRACT.CONTRACTID
, TCONTRACT.[CONTRACT] AS Title
, TCONTRACTTYPE.CONTRACTTYPE
, TCONTRACT.CONTRACTTYPEID
, isnull(tcontract.STRATEGYTYPEID,10) AS STRATEGYTYPEID /* if blank, put 10 = BLANK so that it is not null */
, isnull(s.strategytype,'') AS STRATEGYTYPE /* if blank, put '' = BLANK so that it is not null */
/* ,TCONTRACT.COMMENTS */
      ,ISNULL(TCONTRACT.[REFERENCENUMBER],'') AS 'REFERENCENUMBER'
/*,TCONTRACT.CONTRACTSUMMARY*/
/* DATES */
	,  DATEADD(d,0,DATEADD(hh,1,TCONTRACT.CONTRACTDATE)) AS CONTRACTDATE
	,  DATEADD(d,0,DATEADD(hh,1,TCONTRACT.AWARDDATE)) AS AWARDDATE
	,  DATEADD(d,0,DATEADD(hh,1,TCONTRACT.STARTDATE)) AS STARTDATE
	,  DATEADD(d,0,DATEADD(hh,1,TCONTRACT.EXPIRYDATE)) AS EXPIRYDATE
	,  DATEADD(d,0,DATEADD(hh,1,TCONTRACT.REV_EXPIRYDATE)) AS REV_EXPIRYDATE
	, (CASE WHEN TCONTRACT.REV_EXPIRYDATE IS NULL 
		THEN  DATEADD(d,0,DATEADD(hh,1,TCONTRACT.EXPIRYDATE))
		ELSE DATEADD(d,0,DATEADD(hh,1,TCONTRACT.REV_EXPIRYDATE))
		END) AS FINAL_EXPIRYDATE
	,  DATEADD(d,0,DATEADD(hh,1,TCONTRACT.REVIEWDATE)) AS REVIEWDATE
	, TCONTRACT.CHECKEDOUTDATE
, DEFINEDENDDATE
, TSTATUS.STATUS
, TCONTRACTRELATION.CONTRACTRELATION AS ContractRelations


/* Edit Flags */
	
		,(CASE WHEN TCONTRACT.STARTDATE IS NULL THEN 1 ELSE 0 END) AS
	EDIT_STARTDATE_BLANK

		,(CASE WHEN TCONTRACT.EXPIRYDATE IS NULL THEN 1 ELSE 0 END) AS
	EDIT_EXPIRYDATE_BLANK

		,(CASE WHEN TCONTRACT.REV_EXPIRYDATE IS NULL THEN 1 ELSE 0 END) AS
	EDIT_REV_EXPIRYDATE_BLANK

		,(CASE WHEN TCONTRACT.REV_EXPIRYDATE IS NULL AND  TCONTRACT.EXPIRYDATE IS NULL THEN 1 ELSE 0 END) AS
	EDIT_FINAL_EXPIRYDATE_BLANK

		,(CASE WHEN TCONTRACT.REVIEWDATE IS NULL THEN 1 ELSE 0 END) AS
	EDIT_REVIEWDATE_BLANK

		, (CASE WHEN  (TCONTRACT.REV_EXPIRYDATE IS NULL AND  TCONTRACT.EXPIRYDATE IS NULL AND  TCONTRACT.REVIEWDATE IS NULL) THEN 1 ELSE 0 END) AS
		EDIT_NO_ENDDATE_OR_REMINDER
		,(CASE WHEN  TCONTRACT.NUMBEROFFILES = 0 THEN 1 ELSE 0 END) AS 
	EDIT_NO_PDF_ATTACHMENTS

		, (CASE WHEN V_TheCompany_TENDERER_FLAT.CompanyIDCount = 0 
		OR  V_TheCompany_TENDERER_FLAT.CompanyIDCount is null 
		THEN 1 ELSE 0 END) AS 
	EDIT_NO_COMPANYID

		, (CASE WHEN
		 TCONTRACT.STARTDATE IS NULL 
		OR  (TCONTRACT.REV_EXPIRYDATE IS NULL AND  TCONTRACT.EXPIRYDATE IS NULL AND  TCONTRACT.REVIEWDATE IS NULL)
		OR  TCONTRACT.NUMBEROFFILES = 0
		THEN 1 ELSE 0 END) AS
	EDIT_VCONTRACT_FLAG

, TCONTRACT.NUMBEROFFILES
, TCONTRACT.EXECUTORID
, TCONTRACT.OWNERID
, TCONTRACT.TECHCOORDINATORID
/* , TCONTRACT.LASTTASKCOMPLETED */
/* , TCONTRACT.CHECKEDOUTBY AS CheckedOutByUserId */
, TCONTRACT.STATUSID, 
                      TSTATUS.FIXED AS StatusFixed
/* , TCONTRACT.REFERENCECONTRACTID */

      ,ISNULL(TCONTRACT.[REFERENCECONTRACTNUMBER],'') AS 'REFERENCECONTRACTNUMBER'
      ,ISNULL(TCONTRACT.[COUNTERPARTYNUMBER],'') AS 'COUNTERPARTYNUMBER'

, TAGREEMENT_TYPE.AGREEMENT_TYPE
      ,ISNULL(TAGREEMENT_TYPE.[AGREEMENT_TYPEID],0) AS 'AGREEMENT_TYPEID'
, TAGREEMENT_TYPE.FIXED as AGREEMENT_FIXED
/* , TAGREEMENT_TYPE.MIK_VALID AGREEMENT_MIK_VALID */

/* , ISNULL(V_TheCompany_TENDERER_FLAT.CompanyList,'') AS CompanyList
 , ISNULL(V_TheCompany_TENDERER_FLAT.CompanyIDList,'') AS CompanyIDList
, ISNULL(V_TheCompany_TENDERER_FLAT.CompanyIDAwardedCount,0) AS CompanyIDAwardedCount
      ,ISNULL(V_TheCompany_TENDERER_FLAT.CompanyIDUnawardedCount,0) AS CompanyIDUnawardedCount
      ,ISNULL(V_TheCompany_TENDERER_FLAT.CompanyIDCount,0) AS CompanyIDCount*/
/* Contract Summary */      
	, '' /*ISNULL(TCONTRACTSUMMARY.HEADING,'') */ AS 'HEADING' /* field was deleted as of V6.15, no replacement */
	/*, ISNULL(TCONTRACTSUMMARY.INGRESS,'') AS SUMMARY_INGRESS /* nvarchar 2000, only a handful of records have data */*/
	/*, ISNULL(TCONTRACTSUMMARY.SEARCHWORDS,'') as SUMMARY_SEARCHWORDS /* nvarchar 255, but currently not used */*/
	/* the other available field, summarybody currently considered to be not needed */
, tcontract.LumpSumAmountID
,tcontract.COMMENTS
FROM         TAGREEMENT_TYPE RIGHT OUTER JOIN
	 TSTATUS_IN_OBJECTTYPE INNER JOIN
                      TSTATUS ON TSTATUS_IN_OBJECTTYPE.STATUSID = TSTATUS.STATUSID INNER JOIN
                      TOBJECTTYPE ON TSTATUS_IN_OBJECTTYPE.OBJECTTYPEID = TOBJECTTYPE.OBJECTTYPEID RIGHT OUTER JOIN
                      TCONTRACT LEFT OUTER JOIN
                      TCONTRACTSUMMARY ON TCONTRACT.CONTRACTID = TCONTRACTSUMMARY.CONTRACTID ON 
                      TSTATUS.STATUSID = TCONTRACT.STATUSID LEFT OUTER JOIN

                      TCONTRACTTYPE ON TCONTRACT.CONTRACTTYPEID = TCONTRACTTYPE.CONTRACTTYPEID LEFT OUTER JOIN
                      TCONTRACTRELATION ON TCONTRACT.CONTRACTRELATIONID = TCONTRACTRELATION.CONTRACTRELATIONID ON 
                      TAGREEMENT_TYPE.AGREEMENT_TYPEID = TCONTRACT.AGREEMENT_TYPEID 

	LEFT OUTER JOIN V_TheCompany_TENDERER_FLAT ON TCONTRACT.CONTRACTID = V_TheCompany_TENDERER_FLAT.CONTRACTID
	LEFT OUTER JOIN TSTRATEGYTYPE s on (tcontract.STRATEGYTYPEID = s.STRATEGYTYPEID and s.MIK_VALID = 1) /* HCP HCO */
WHERE     (TOBJECTTYPE.FIXED = N'CONTRACT')
   AND   TCONTRACT.CONTRACTTYPEID  NOT IN  ('6' /* Access SAKSNR number Series*/, '5' /* Test Old */,'102' /* Test New */,'13' /* DELETE */ )



GO
/****** Object:  View [dbo].[V_TheCompany_VDEPARTMENT_Entities_Diligent]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[V_TheCompany_VDEPARTMENT_Entities_Diligent]

as 

SELECT [EntityName] as DLE_EntityName
      , (case when [Country] = 'UK' then 'United Kingdom'
			when [Country] = 'US' then 'United States'
			else [Country]  end) /* mapping issues */
		as DLE_Country


      ,[SAP_Code] as DLE_SAP_Code
      ,[BP_QuickRef] as DLE_QuickRef
      ,[AliasName] as DLE_EntityNameAlias
	  , EntityName_LINC as [DLE_EntityName_LINC]
	  , EntityName_Clean
	  , EntityName_Suffix
	  , EntityName_Alias /* duplicate!*/
	  , EntityName as DLE_EntityName_Main

      ,[Status] as DLE_Status
      ,[Comments] as DLE_Comments
      ,[MaxNoSignatures] as DLE_MaxNoSignatures
      ,[SignatureRules] as DLE_SignatureRules
	  , left([dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]([EntityName]),255) as DLE_EntityName_NonFwSlash
	  , left([dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash](UPPER([EntityName])),255) as DLE_EntityName_NonFwSlash_UPPER

	, dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([EntityName]) as DLE_EntityName_NonAlphaNonNum
from
	T_TheCompany_Entities_DiligentData

GO
/****** Object:  View [dbo].[V_TheCompany_VDEPARTMENTROLE_IN_OBJECT_TT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_VDEPARTMENTROLE_IN_OBJECT_TT]
/* used in BO PROD Universe */
as 

select * from V_TheCompany_Departmentrole_In_Object where ROLEID = 3 /*TT*/
GO
/****** Object:  View [dbo].[V_TheCompany_VDocumentContractSummary_TS_Redacted]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_VDocumentContractSummary_TS_Redacted]

as 

select ContractSummary_TS_Redacted
	, [DocumentTitle_TS_Redacted]
      , [Version]
      , [Owner]
      , [VersionDate]
      , [Datecreated]
      , [FileName]
      , [FileSize]
      , [OriginalFileName]
      , [DocumentOwnerId]
      , [DOCUMENTTYPEID]
      , [DOCUMENTID]
      , [MIK_VALID]
      , [FileID]
      , [OBJECTTYPEID]
      , [OBJECTID]
      , [DOCUMENTTYPE]
      , [FileType]
	  , [DocumentTags]
  FROM [TheVendor_app].[dbo].[V_TheCompany_VDOCUMENT] d
		/* where 
	c.[Title] not like '%TOP SECRET%' 
	and c.title not like '%STRICTLY CONFIDENTIAL%' */

GO
/****** Object:  View [dbo].[VACL]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************\
	VACL view is showing ACL for each user. It is handy to be used (for instance in reports) to 
	get only objects, which particular user has privileges to read. Typical query might look like:

	SELECT	D.*,
			A.*
	  FROM	tdocument			D
	  JOIN	VACL				A
		ON	A.ObjectID			= D.DOcumentid
	   AND	A.ObjectTypeFixed	= 'document'
	 WHERE	A.UserID			= 7
	   AND	(		A.[Read]	= 1
			OR		A.[Write]	= 1
			OR		A.[Delete]	= 1
			OR		A.[Owner]	= 1
			)
	
	or similar.
\**************************************************************************************************/
CREATE VIEW [dbo].[VACL] AS
	SELECT	OBJECTID,
			OBJECTTYPEID,
			ObjectType,
			ObjectTypeFixed,
			UserID,
			UserInitial,
			[1]			AS [Read],
			[2]			AS [Write],
			[3]			AS [Create],
			[4]			AS [Delete],
			[5]			AS [Owner]
	  FROM	(
			SELECT	DISTINCT
					A.OBJECTID,
					A.OBJECTTYPEID,
					OT.ObjectType,
					OT.Fixed			AS ObjectTypeFixed,
					U.USERID,
					U.UserInitial,
					A.PrivilegeID
			  FROM	TACL				A
			  JOIN	TObjectType					OT
				ON	OT.ObjectTypeID				= A.ObjectTypeID
			  JOIN	TUSER				U
				ON	A.UserID			= U.UserID
				OR	A.GroupID		IN (
					SELECT	UserGroupID
					  FROM	TUser_In_UserGroup
					 WHERE	UserID		= U.UserID
					)
			)							ACL
	 PIVOT	(
			COUNT( PrivilegeID)
			FOR	PrivilegeID IN ([1],[2],[3],[4],[5])
			)							P

GO
/****** Object:  View [dbo].[VAclRead]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************\
	VAclRead view is showing ACL for each user. It is handy to be used (for instance in reports) to 
	get only objects, which particular user has privileges to read. Typical query might look like:

	SELECT	D.*
	  FROM	tdocument				D
	  JOIN	VAclRead				A
		ON	A.ObjectID				= D.Documentid
	   AND	A.ObjectTypeID			= 7						-- object type is "Document"
	 WHERE	A.DOMAINNETBIOSUSERNAME	= 'TheVendor\someuser'	-- from User!UserID in SSRS report
	
	or similar. This view differs from VACL one that it returns less information, but works slightly
	quicker.
\**************************************************************************************************/
CREATE VIEW [dbo].[VAclRead] AS
	SELECT	DISTINCT
			A.OBJECTID,
			A.OBJECTTYPEID,
			U.USERID,
			U.DOMAINNETBIOSUSERNAME
	  FROM	TACL				A
	  JOIN	TUSER				U
		ON	A.UserID			= U.UserID
		OR	A.GroupID		IN (
			SELECT	UserGroupID
			  FROM	TUser_In_UserGroup
			 WHERE	UserID		= U.UserID
			)
	 WHERE	A.PrivilegeID		!= 3

GO
/****** Object:  View [dbo].[VADDITIONAL_USERGROUP_PRIVILEGES]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VADDITIONAL_USERGROUP_PRIVILEGES]
AS
SELECT
	sq.OBJECTTYPEID,
	sq.OBJECTID,
	UG.USERGROUPID,
	sq.PRIVILEGEID,
	UG.DEPARTMENTID AS 'NEW_DEPARTMENT_ID',
	sq.DEPARTMENTID AS 'CURRENT_DEPARTMENT_ID',
	sq.USERGROUPID AS 'CURRENT_USERGROUP_ID',
	sq.NONHERITABLE
FROM
	TUSERGROUP AS UG
	CROSS JOIN
	(SELECT     
       A.ACLID, A.OBJECTTYPEID, A.OBJECTID, A.GROUPID, A.USERID, A.PRIVILEGEID, A.INHERITFROMPARENTOBJECT, 
       A.PARENTOBJECTTYPEID, A.PARENTOBJECTID, A.NONHERITABLE, UG2.USERGROUPID, UG2.USERGROUP, UG2.DEPARTMENTID, 
       UG2.COMPANYID, UG2.FIXED, UG2.MIK_VALID, UG2.MIK_SEQUENCE
	FROM
		TACL AS A
			INNER JOIN
			TUSERGROUP AS UG2 ON (A.GROUPID = UG2.USERGROUPID)) AS sq
WHERE
	NOT EXISTS 
		(SELECT
			1
		FROM
			TACL AS iacl
		WHERE
			iacl.OBJECTTYPEID = sq.OBJECTTYPEID AND
			iacl.OBJECTID = sq.OBJECTID AND
			iacl.GROUPID = UG.USERGROUPID AND
			iacl.PRIVILEGEID = sq.PRIVILEGEID)

GO
/****** Object:  View [dbo].[VAMENDMENT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VAMENDMENT]
AS
SELECT     dbo.TLANGUAGE.MIK_LANGUAGE AS [Language], dbo.TCURRENCY.CURRENCY_CODE AS AmountCode, dbo.TSTATUS.STATUS,
				dbo.TAMENDMENT.AMENDMENTID,
				dbo.TAMENDMENT.AMENDMENT,
				dbo.TAMENDMENT.AMENDMENTNUMBER,
				dbo.TAMENDMENT.REVISION,
				dbo.TAMENDMENT.DATECREATED,
				dbo.TAMENDMENT.FROMDATE,
				dbo.TAMENDMENT.TODATE,
				dbo.TAMENDMENT.STATUSID,
				dbo.TAMENDMENT.COMMENTS,
				dbo.TAMENDMENT.CONTRACTID,
				dbo.TAMENDMENT.CONFLICTSOLUTION,
				dbo.TAMENDMENT.AmountID,
				dbo.TAMENDMENT.REFERENCENUMBER,
				dbo.TAMENDMENT.SIGNEDDATE,
				dbo.TAMENDMENT.ESTIMATEDAMOUNTID,
				dbo.TAMENDMENT.LANGUAGEID,
				dbo.TAMENDMENT.APPROVALSTATUSID,
						  dbo.TAMOUNT.Amount AS Amount, TAMOUNT_1.Amount AS EstimatedAmount, TCURRENCY_1.CURRENCY AS EstimatedAmountCode, 
						  TSTATUS_1.STATUS AS ApprovalStatus
FROM         dbo.TAMOUNT RIGHT OUTER JOIN
                      dbo.TAMOUNT TAMOUNT_1 RIGHT OUTER JOIN
                      dbo.TSTATUS TSTATUS_1 INNER JOIN
                      dbo.TAPPROVALSTATUS_IN_OBJECTTYPE ON TSTATUS_1.STATUSID = dbo.TAPPROVALSTATUS_IN_OBJECTTYPE.APPROVALSTATUSID INNER JOIN
                      dbo.TOBJECTTYPE ON dbo.TAPPROVALSTATUS_IN_OBJECTTYPE.OBJECTTYPEID = dbo.TOBJECTTYPE.OBJECTTYPEID AND 
                      dbo.TOBJECTTYPE.FIXED = N'AMENDMENT' RIGHT OUTER JOIN
                      dbo.TAMENDMENT ON TSTATUS_1.STATUSID = dbo.TAMENDMENT.APPROVALSTATUSID LEFT OUTER JOIN
                      dbo.TSTATUS ON dbo.TAMENDMENT.STATUSID = dbo.TSTATUS.STATUSID ON TAMOUNT_1.AmountId = dbo.TAMENDMENT.ESTIMATEDAMOUNTID ON 
                      dbo.TAMOUNT.AmountId = dbo.TAMENDMENT.AmountID LEFT OUTER JOIN
                      dbo.TCURRENCY TCURRENCY_1 ON TAMOUNT_1.CurrencyId = TCURRENCY_1.CURRENCYID LEFT OUTER JOIN
                      dbo.TLANGUAGE ON dbo.TAMENDMENT.LANGUAGEID = dbo.TLANGUAGE.LANGUAGEID LEFT OUTER JOIN
                      dbo.TCURRENCY ON dbo.TAMOUNT.CurrencyId = dbo.TCURRENCY.CURRENCYID


GO
/****** Object:  View [dbo].[VAPPRAISAL]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VAPPRAISAL]
AS
SELECT     dbo.TAPPRAISAL.APPRAISALID, dbo.TAPPRAISAL.COMPLETED, dbo.TAPPRAISAL.CONTRACTID, dbo.TEVENT_IN_APPRAISAL.[VALUE], 
                      dbo.TEVENT_IN_APPRAISAL.NUMOCCURENCES, dbo.TEVENT_IN_APPRAISAL.COMMENTS, dbo.TEVENT_IN_APPRAISAL.LASTUPDATEDBY, 
                      dbo.TEVENT_IN_APPRAISAL.LASTUPDATED, dbo.TAPPRAISALEVENT.APPRAISALEVENT, dbo.TAPPRAISALEVENT.DESCRIPTION, 
                      dbo.TAPPRAISALEVENT.ENTERPRISE, dbo.TAPPRAISALEVENT.MANDATORY, dbo.TAPPRAISALEVENT.VISIBLE, dbo.TAPPRAISALEVENT.MIK_VALID, 
                      dbo.TAPPRAISALEVENT.FIXED, dbo.TEVENT_IN_APPRAISAL.APPRAISALEVENTID
FROM         dbo.TAPPRAISAL LEFT OUTER JOIN
                      dbo.TEVENT_IN_APPRAISAL ON dbo.TAPPRAISAL.APPRAISALID = dbo.TEVENT_IN_APPRAISAL.APPRAISALID RIGHT OUTER JOIN
                      dbo.TAPPRAISALEVENT ON dbo.TEVENT_IN_APPRAISAL.APPRAISALEVENTID = dbo.TAPPRAISALEVENT.APPRAISALEVENTID



GO
/****** Object:  View [dbo].[VAPPROVALSTEP]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VAPPROVALSTEP]
AS
SELECT     dbo.TAPPROVALSTEP.APPROVALSTEPID, dbo.TAPPROVALSTEP.APPROVALSTEP, dbo.TAPPROVAL.APPROVAL, dbo.TROLE.ROLE, 
                      dbo.TAPPROVALSTEP.USERID, dbo.TPERSON.DISPLAYNAME, dbo.TPERSON.EMAIL, dbo.TAPPROVALSTEP.DEADLINE, 
                      dbo.TAPPROVALSTEP.MESSAGETOUSER, dbo.TAPPROVALSTEP.MESSAGEFROMUSER, dbo.TSTATUS.STATUS, dbo.TSTATUS.FIXED, 
                      dbo.TAPPROVAL.OBJECTTYPEID, dbo.TAPPROVAL.OBJECTID, dbo.TAPPROVALSTEP.STEPNUMBER, dbo.TAPPROVALSTEP.APPROVALID, 
                      dbo.TAPPROVALSTEP.APPROVED, dbo.TAPPROVALSTEP.DELAYNOTIFIED, dbo.TAPPROVALSTEP.ACTIVATEDDATE, 
                      dbo.TAPPROVALSTEP.EXTERNALSTEPID, dbo.TAPPROVALSTEP.STATUSID, dbo.TAPPROVALSTEP.ROLEID, CurrentStep.CurrentStepNumber, 
                      NextStep.USERID AS NextStepUSERID, NextStep.DISPLAYNAME AS [Next step assigned to], CAST(NULL AS DATETIME) AS ENDDATE , dbo.TPERSON.FIRSTNAME+' '+dbo.TPERSON.LASTNAME as RECIPIENTNAME
FROM         dbo.TAPPROVALSTEP LEFT OUTER JOIN
                      dbo.TROLE ON dbo.TAPPROVALSTEP.ROLEID = dbo.TROLE.ROLEID LEFT OUTER JOIN
                      dbo.TUSER INNER JOIN
                      dbo.TEMPLOYEE ON dbo.TUSER.EMPLOYEEID = dbo.TEMPLOYEE.EMPLOYEEID INNER JOIN
                      dbo.TPERSON ON dbo.TEMPLOYEE.PERSONID = dbo.TPERSON.PERSONID ON dbo.TAPPROVALSTEP.USERID = dbo.TUSER.USERID INNER JOIN
                      dbo.TAPPROVAL ON dbo.TAPPROVALSTEP.APPROVALID = dbo.TAPPROVAL.APPROVALID LEFT OUTER JOIN
                      dbo.TSTATUS ON dbo.TAPPROVALSTEP.STATUSID = dbo.TSTATUS.STATUSID LEFT OUTER JOIN
                          (SELECT     APS.APPROVALID, S.STATUS, SQ.STEPNUMBER AS CurrentStepNumber
                            FROM          dbo.TAPPROVALSTEP AS APS LEFT OUTER JOIN
                                                   dbo.TSTATUS AS S ON APS.STATUSID = S.STATUSID INNER JOIN
                                                       (SELECT     MIN(APS.STEPNUMBER) AS STEPNUMBER, APS.APPROVALID
                                                         FROM          dbo.TAPPROVALSTEP AS APS LEFT OUTER JOIN
                                                                                dbo.TSTATUS AS S ON APS.STATUSID = S.STATUSID
                                                         WHERE      (S.FIXED <> N'COMPLETED') AND (S.FIXED <> N'BYPASSED')
                                                         GROUP BY APS.APPROVALID) AS SQ ON APS.APPROVALID = SQ.APPROVALID AND APS.STEPNUMBER = SQ.STEPNUMBER) 
                      AS CurrentStep ON dbo.TAPPROVAL.APPROVALID = CurrentStep.APPROVALID LEFT OUTER JOIN
                          (SELECT     U.USERID, P.DISPLAYNAME, APS.APPROVALID, APS.STEPNUMBER
                            FROM          dbo.TAPPROVALSTEP AS APS LEFT OUTER JOIN
                                                   dbo.TUSER AS U INNER JOIN
                                                   dbo.TEMPLOYEE AS E ON U.EMPLOYEEID = E.EMPLOYEEID INNER JOIN
                                                   dbo.TPERSON AS P ON E.PERSONID = P.PERSONID ON APS.USERID = U.USERID) AS NextStep ON 
                      CurrentStep.APPROVALID = NextStep.APPROVALID AND 
                      NextStep.STEPNUMBER = CurrentStep.CurrentStepNumber 
                      

GO
/****** Object:  View [dbo].[VCLARIFICATION]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE	 VIEW [dbo].[VCLARIFICATION] AS
SELECT 
		QNA.RFXQUESTIONANDANSWERID,
		QNA.MIK_SEQUENCE							AS MIK_SEQUENCE,
		QNA.MIK_VALID								AS MIK_VALID,
		RI.RFXINTERESTID,
		RI.RFXID,
		RI.PRIMARYCOMPANYCONTACTUSERID,
		CC.COMPANYCONTACTID							AS PRIMARYCOMPANYCONTACTID,
		C.COMPANYID,
		C.COMPANY, 
		C.COMPANYNO,
		T.TENDERERID,
		
		ORIGINALQUESTIONS.STATEMENTID				AS ORIGINALQUESTIONSTATEMENTID,
		ORIGINALQUESTIONS.[STATEMENT]				AS ORIGINALQUESTION,
		ORIGINALQUESTIONS.STATEMENTDATETIME			AS QUESTIONDATETIME,
		ORIGINALQUESTIONS.CREATEDBYPERSONID			AS ORIGINALQUESTIONCREATEDBYPERSONID,
		ORIGINALQUESTIONS.CREATEDDATE				AS ORIGINALQUESTIONCREATEDDATE,
		ORIGINALQUESTIONS.DUEDATE					AS ORIGINALQUESTIONDUEDATE,
		
		OPA.FIRSTNAME								AS ORIGINALQUESTIONCREATEDBYFIRSTNAME,
		OPA.LASTNAME								AS ORIGINALQUESTIONCREATEDBYLASTNAME,
		OPA.EMAIL									AS ORIGINALQUESTIONCREATEDBYEMAIL,
		
		CASE 
			WHEN ORIGINALQUESTIONS.ISPUBLISHED IS NULL
				THEN CAST(0 AS BIT)  
			ELSE ORIGINALQUESTIONS.ISPUBLISHED
		END											AS ORIGINALQUESTIONISPUBLISHED,
		PQ.PERSONID									AS ASKEDBYPERSONID,
		PQ.FIRSTNAME								AS ASKEDBYFIRSTNAME, 
		PQ.LASTNAME									AS ASKEDBYLASTNAME,
		PQ.EMAIL									AS ASKEDBYEMAIL,
		
		ANSWERS.STATEMENTID							AS ANSWERSTATEMENTID,
		ANSWERS.[STATEMENT]							AS ANSWER,
		ANSWERS.STATEMENTDATETIME					AS ANSWERDATETIME,
		ANSWERS.CREATEDBYPERSONID					AS ANSWERCREATEDBYPERSONID,
		ANSWERS.CREATEDDATE							AS ANSWERCREATEDDATE,
		
		APA.FIRSTNAME								AS ANSWERCREATEDBYFIRSTNAME,
		APA.LASTNAME								AS ANSWERCREATEDBYLASTNAME,
		APA.EMAIL									AS ANSWERCREATEDBYEMAIL,
		
		CASE 
			WHEN ANSWERS.ISPUBLISHED IS NULL
				THEN CAST(0 AS BIT)  
			ELSE ANSWERS.ISPUBLISHED
		END											AS ANSWERISPUBLISHED,						
		PA.PERSONID									AS ANSWEREDBYPERSONID,
		PA.FIRSTNAME								AS ANSWEREDBYFIRSTNAME, 
		PA.LASTNAME									AS ANSWEREDBYLASTNAME,
		PA.EMAIL									AS ANSWEREDBYEMAIL,
				
		ADoc.DOCUMENTID				AS ANSWERDOCUMENTID,
		ADoc.OBJECTTYPEID			AS ADOCOBJECTTYPEID,
		ADoc.OBJECTID				AS ADOCOBJECTID,
		ADoc.DOCUMENT				AS ADOCDOCUMENT,
		ADoc.[DESCRIPTION]			AS ADOCDESCRIPTION,

				
		QDoc.DOCUMENTID				AS QUESTIONDOCUMENTID,
		QDoc.OBJECTTYPEID			AS QDOCOBJECTTYPEID,
		QDoc.OBJECTID				AS QDOCOBJECTID,
		QDoc.DOCUMENT				AS QDOCDOCUMENT,
		QDoc.[DESCRIPTION]			AS QDOCDESCRIPTION,
		QNA.REFID					AS REFID

 FROM dbo.TRFXQUESTIONANDANSWER QNA
 
	 LEFT OUTER
	 JOIN 
	 (
		SELECT	
				TSTATEMENT.STATEMENTID				AS	STATEMENTID,
				TSTATEMENT.STATEMENTTYPEID			AS	STATEMENTTYPEID,
				TSTATEMENT.[STATEMENT]				AS	[STATEMENT],
				TSTATEMENT.STATEMENTDATETIME		AS	STATEMENTDATETIME,
				TSTATEMENT.RFXQUESTIONANDANSWERID	AS	RFXQUESTIONANDANSWERID,
				TSTATEMENT.PERSONID					AS	PERSONID,
				TSTATEMENT.ISPUBLISHED				AS	ISPUBLISHED,
				TSTATEMENT.PARENTSTATEMENTID		AS	PARENTSTATEMENTID,
				TSTATEMENT.CREATEDBYPERSONID		AS	CREATEDBYPERSONID,
				TSTATEMENT.CREATEDDATE				AS	CREATEDDATE,
				TSTATEMENT.DUEDATE					AS	DUEDATE
		FROM dbo.TSTATEMENT
			 LEFT JOIN dbo.TSTATEMENTTYPE
					ON TSTATEMENT.STATEMENTTYPEID = TSTATEMENTTYPE.STATEMENTTYPEID
				 WHERE TSTATEMENTTYPE.FIXED = 'QUESTION'
			 
	 )  ORIGINALQUESTIONS
	   
	 ON QNA.RFXQUESTIONANDANSWERID = ORIGINALQUESTIONS.RFXQUESTIONANDANSWERID  
	 
	 LEFT OUTER
	 JOIN 
	 (
		SELECT	
				TSTATEMENT.STATEMENTID				AS	STATEMENTID,
				TSTATEMENT.STATEMENTTYPEID			AS	STATEMENTTYPEID,
				TSTATEMENT.[STATEMENT]				AS	[STATEMENT],
				TSTATEMENT.STATEMENTDATETIME		AS	STATEMENTDATETIME,
				TSTATEMENT.RFXQUESTIONANDANSWERID	AS	RFXQUESTIONANDANSWERID,
				TSTATEMENT.PERSONID					AS	PERSONID,
				TSTATEMENT.ISPUBLISHED				AS	ISPUBLISHED,
				TSTATEMENT.PARENTSTATEMENTID		AS	PARENTSTATEMENTID,
				TSTATEMENT.CREATEDBYPERSONID		AS	CREATEDBYPERSONID,
				TSTATEMENT.CREATEDDATE				AS	CREATEDDATE,
				TSTATEMENT.DUEDATE					AS	DUEDATE
		FROM dbo.TSTATEMENT
			 LEFT JOIN dbo.TSTATEMENTTYPE
					ON TSTATEMENT.STATEMENTTYPEID = TSTATEMENTTYPE.STATEMENTTYPEID
				 WHERE TSTATEMENTTYPE.FIXED = 'ANSWER'
			 
	 ) ANSWERS
	   
	 ON QNA.RFXQUESTIONANDANSWERID = ANSWERS.RFXQUESTIONANDANSWERID
	 
	  LEFT OUTER
	  JOIN 	dbo.TPERSON					PQ
		ON	ORIGINALQUESTIONS.PERSONID	= PQ.PERSONID
	
	  LEFT OUTER
	  JOIN 	dbo.TPERSON					PA
		ON	ANSWERS.PERSONID			= PA.PERSONID	

	  JOIN	dbo.TOBJECTTYPE				OT
		ON	QNA.OBJECTTYPEID			= OT.OBJECTTYPEID
	  JOIN	dbo.TRFXINTEREST			RI
		ON	QNA.OBJECTID				= RI.RFXINTERESTID
	  LEFT	OUTER
	  JOIN	dbo.TUSER					U
		ON	RI.PRIMARYCOMPANYCONTACTUSERID = U.USERID
	  LEFT	OUTER
	  JOIN	dbo.TCOMPANYCONTACT			CC
		ON	U.PERSONID					= CC.PERSONID
	   AND	CC.COMPANYID				= RI.COMPANYID  
	  LEFT	OUTER
	  JOIN	dbo.TCOMPANY				C
		ON	CC.COMPANYID				= C.COMPANYID
	  LEFT	OUTER
	  JOIN	dbo.TTENDERER				T
		ON	CC.COMPANYID				= T.COMPANYID
	   AND	RI.RFXID					= T.RFXID
	  LEFT	OUTER
	  JOIN	dbo.TDOCUMENT				ADoc
		ON	ADoc.OBJECTID				= ANSWERS.STATEMENTID
	   AND	ADoc.OBJECTTYPEID			IN (SELECT OBJECTTYPEID FROM TOBJECTTYPE WHERE FIXED='STATEMENT')
	  LEFT	OUTER
	  JOIN	dbo.TDOCUMENT				QDoc
		ON	QDoc.OBJECTID				= ORIGINALQUESTIONS.STATEMENTID
	   AND	QDoc.OBJECTTYPEID			IN (SELECT OBJECTTYPEID FROM TOBJECTTYPE WHERE FIXED='STATEMENT')

	LEFT	OUTER 	
	JOIN dbo.TPERSON					OPA
		ON	ORIGINALQUESTIONS.CREATEDBYPERSONID			= OPA.PERSONID	
		
	LEFT	OUTER
  	JOIN dbo.TPERSON					APA
		ON	ANSWERS.CREATEDBYPERSONID			= APA.PERSONID			
	 	 	
	 WHERE	OT.FIXED	= 'RFXINTEREST'	
	   AND	QNA.QATYPEID IN 
							(
							 SELECT QATYPEID 
							 FROM TQATYPE
							 WHERE FIXED	= 'CLARIFICATION'
							)


GO
/****** Object:  View [dbo].[VCOMMERCIALPROJECT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  View [dbo].[VCOMMERCIALPROJECT]    Script Date: 01/29/2009 01:45:00 ******/
CREATE VIEW [dbo].[VCOMMERCIALPROJECT]
AS
SELECT	G.PROJECTID,
		CONVERT(DECIMAL(24, 2), SUM(G.IncomeEstimatedValue))		AS IncomeEstimatedValue,
		CONVERT(DECIMAL(24, 2), SUM(G.ExpenseEstimatedValue))		AS ExpenseEstimatedValue,
		CONVERT(DECIMAL(24, 2), SUM(G.IncomeApprovedBudget))		AS IncomeApprovedBudget,
		CONVERT(DECIMAL(24, 2), SUM(G.ExpenseApprovedBudget))		AS ExpenseApprovedBudget,
		CONVERT(DECIMAL(24, 2), SUM(G.IncomeLumpSum))				AS IncomeLumpSum,
		CONVERT(DECIMAL(24, 2), SUM(G.ExpenseLumpSum))				AS ExpenseLumpSum,
		CONVERT(DECIMAL(24, 2), SUM(G.IncomeReimbursableCost))		AS IncomeReimbursableCost,
		CONVERT(DECIMAL(24, 2), SUM(G.ExpenseReimbursableCost))		AS ExpenseREimbursableCost,
		CONVERT(DECIMAL(24, 2), SUM(G.IncomeTotalValueOnAward))		AS IncomeTotalValueOnAward,
		CONVERT(DECIMAL(24, 2), SUM(G.ExpenseTotalValueOnAward))	AS ExpenseTotalValueOnAward,
		CONVERT(DECIMAL(24, 2), SUM(G.IncomeInvoicedValue))			AS IncomeInvoicedValue,
		CONVERT(DECIMAL(24, 2), SUM(G.ExpenseInvoicedValue))		AS ExpenseInvoicedValue,
		CONVERT(DECIMAL(24, 2), SUM(G.IncomeBankGuarantee))			AS IncomeBankGuarantee,
		CONVERT(DECIMAL(24, 2), SUM(G.ExpenseBankGuarantee))		AS ExpenseBankGuarantee,
		CONVERT(DECIMAL(24, 2), SUM(G.IncomeParentCompanyGuarantee))
																	AS IncomeParentCompanyGuarantee,
		CONVERT(DECIMAL(24, 2), SUM(G.ExpenseParentCompanyGuarantee))
																	AS ExpenseParentCompanyGuarantee,
		CONVERT(DECIMAL(24, 2), SUM(G.IncomeApprovedAmendments))	AS IncomeApprovedAmendments,
		CONVERT(DECIMAL(24, 2), SUM(G.ExpenseApprovedAmendments))	AS ExpenseApprovedAmendments,
		CONVERT(DECIMAL(24, 2), SUM(G.IncomeApprovedVO))			AS IncomeApprovedVO,
		CONVERT(DECIMAL(24, 2), SUM(G.ExpenseApprovedVO))			AS ExpenseApprovedVO,
		CONVERT(DECIMAL(24, 2), SUM(G.IncomeApprovedOrders))		AS IncomeApprovedOrders,
		CONVERT(DECIMAL(24, 2), SUM(G.ExpenseApprovedOrders))		AS ExpenseApprovedOrders
  FROM	(
		SELECT	P.PROJECTID,
				ISNULL((
				SELECT	Amount
				  FROM	TAmount			A
				 WHERE	A.AmountID		= C.EstimatedValueAmountID
				   AND	CR.FIXED		= 'SALES'
				), 0)					AS IncomeEstimatedValue,
				ISNULL((
				SELECT	Amount
				  FROM	TAmount			A
				 WHERE	A.AmountID		= C.EstimatedValueAmountID
				   AND	CR.FIXED		!= 'SALES'
				), 0)					AS ExpenseEstimatedValue,
				ISNULL((
				SELECT	Amount
				  FROM	TAmount			A
				 WHERE	A.AmountID		= C.ApprovedValueAmountID
				   AND	CR.FIXED		= 'SALES'
				), 0)					AS IncomeApprovedBudget,
				ISNULL((
				SELECT	Amount
				  FROM	TAmount			A
				 WHERE	A.AmountID		= C.ApprovedValueAmountID
				   AND	CR.FIXED		!= 'SALES'
				), 0)					AS ExpenseApprovedBudget,
				ISNULL((
				SELECT	Amount
				  FROM	TAmount			A
				 WHERE	A.AmountID		= C.LumpSumAmountID
				   AND	CR.FIXED		= 'SALES'
				), 0)					AS IncomeLumpSum,
				ISNULL((
				SELECT	Amount
				  FROM	TAmount			A
				 WHERE	A.AmountID		= C.LumpSumAmountID
				   AND	CR.FIXED		!= 'SALES'
				), 0)					AS ExpenseLumpSum,
				ISNULL((
				SELECT	Amount
				  FROM	TAmount			A
				 WHERE	A.AmountID		= C.ProvisionalSumAmountID
				   AND	CR.FIXED		= 'SALES'
				), 0)					AS IncomeReimbursableCost,
				ISNULL((
				SELECT	Amount
				  FROM	TAmount			A
				 WHERE	A.AmountID		= C.ProvisionalSumAmountID
				   AND	CR.FIXED		!= 'SALES'
				), 0)					AS ExpenseReimbursableCost,
				ISNULL((
				SELECT	Amount
				  FROM	TAmount			A
				 WHERE	A.AmountID		= C.AwardValueAmountID
				   AND	CR.FIXED		= 'SALES'
				), 0)					AS IncomeTotalValueOnAward,
				ISNULL((
				SELECT	Amount
				  FROM	TAmount			A
				 WHERE	A.AmountID		= C.AwardValueAmountID
				   AND	CR.FIXED		!= 'SALES'
				), 0)					AS ExpenseTotalValueOnAward,
				ISNULL((
				SELECT	Amount
				  FROM	TAmount			A
				 WHERE	A.AmountID		= C.InvoicedValueAmountID
				   AND	CR.FIXED		= 'SALES'
				), 0)					AS IncomeInvoicedValue,
				ISNULL((
				SELECT	Amount
				  FROM	TAmount			A
				 WHERE	A.AmountID		= C.InvoicedValueAmountID
				   AND	CR.FIXED		!= 'SALES'
				), 0)					AS ExpenseInvoicedValue,
				ISNULL((
				SELECT	Amount
				  FROM	TAmount			A
				 WHERE	A.AmountID		= C.BankGuaranteeAmountID
				   AND	CR.FIXED		= 'SALES'
				), 0)					AS IncomeBankGuarantee,
				ISNULL((
				SELECT	Amount
				  FROM	TAmount			A
				 WHERE	A.AmountID		= C.BankGuaranteeAmountID
				   AND	CR.FIXED		!= 'SALES'
				), 0)					AS ExpenseBankGuarantee,
				ISNULL((
				SELECT	Amount
				  FROM	TAmount			A
				 WHERE	A.AmountID		= C.ParentCompanyGuaranteeAmountID
				   AND	CR.FIXED		= 'SALES'
				), 0)					AS IncomeParentCompanyGuarantee,
				ISNULL((
				SELECT	Amount
				  FROM	TAmount			A
				 WHERE	A.AmountID		= C.ParentCompanyGuaranteeAmountID
				   AND	CR.FIXED		!= 'SALES'
				), 0)					AS ExpenseParentCompanyGuarantee,
				ISNULL((
				SELECT	SUM(TAMOUNT.Amount)
				  FROM	TAMENDMENT
				  JOIN	TAMOUNT
					ON	TAMOUNT.AmountId	= TAMENDMENT.AmountID
				 WHERE	C.CONTRACTID		= TAMENDMENT.CONTRACTID
				   AND	CR.FIXED			= 'SALES'
				   AND	TAMENDMENT.STATUSID IN (
						SELECT	STATUSID
						  FROM	dbo.TSTATUS
						 WHERE	FIXED IN ('ACTIVE', 'SIGNED', 'EXPIRED')
						)
				 GROUP	BY
						dbo.TAMENDMENT.CONTRACTID
				), 0)					AS IncomeApprovedAmendments,
				ISNULL((
				SELECT	SUM(TAMOUNT.Amount)
				  FROM	TAMENDMENT
				  JOIN	TAMOUNT
					ON	TAMOUNT.AmountId	= TAMENDMENT.AmountID
				 WHERE	C.CONTRACTID		= TAMENDMENT.CONTRACTID
				   AND	CR.FIXED			!= 'SALES'
				   AND	TAMENDMENT.STATUSID IN (
						SELECT	STATUSID
						  FROM	dbo.TSTATUS
						 WHERE	FIXED IN ('ACTIVE', 'SIGNED', 'EXPIRED')
						)
				 GROUP	BY
						dbo.TAMENDMENT.CONTRACTID
				), 0)					AS ExpenseApprovedAmendments,
				ISNULL((
					SELECT	SUM(TAMOUNT.Amount)
					  FROM	TVO
					  JOIN	TAMOUNT
						ON	TAMOUNT.AmountId	= TVO.SETTLEMENTAMOUNTID
					 WHERE	C.CONTRACTID		= TVO.CONTRACTID
					   AND	CR.FIXED			= 'SALES'
					 GROUP	BY
							dbo.TVO.CONTRACTID
				), 0)					AS IncomeApprovedVO,
				ISNULL((
					SELECT	SUM(TAMOUNT.Amount)
					  FROM	TVO
					  JOIN	TAMOUNT
						ON	TAMOUNT.AmountId	= TVO.SETTLEMENTAMOUNTID
					 WHERE	C.CONTRACTID		= TVO.CONTRACTID
					   AND	CR.FIXED			!= 'SALES'
					 GROUP	BY
							dbo.TVO.CONTRACTID
				), 0)					AS ExpenseApprovedVO,
				ISNULL((
					SELECT	SUM(TAMOUNT.Amount)
					  FROM	TORDER
					  JOIN	TAMOUNT
						ON	TAMOUNT.AmountId	= TORDER.AMOUNTID
					 WHERE	C.CONTRACTID		= TORDER.CONTRACTID
					   AND	CR.FIXED			= 'SALES'
					   AND	TORDER.STATUSID	IN	(
							SELECT	STATUSID
							  FROM	TSTATUS
							 WHERE	FIXED IN ('ACTIVE', 'ORDERED', 'DELIVEREDEXPIRED')
							)
					 GROUP	BY
							dbo.TORDER.CONTRACTID
				), 0)					AS IncomeApprovedOrders,
				ISNULL((
					SELECT	SUM(TAMOUNT.Amount)
					  FROM	TORDER
					  JOIN	TAMOUNT
						ON	TAMOUNT.AmountId	= TORDER.AMOUNTID
					 WHERE	C.CONTRACTID		= TORDER.CONTRACTID
					   AND	CR.FIXED			!= 'SALES'
					   AND	TORDER.STATUSID	IN	(
							SELECT	STATUSID
							  FROM	TSTATUS
							 WHERE	FIXED IN ('ACTIVE', 'ORDERED', 'DELIVEREDEXPIRED')
							)
					 GROUP	BY
							dbo.TORDER.CONTRACTID
				), 0)					AS ExpenseApprovedOrders
		  FROM	TPROJECT				P
		  JOIN	TCONTRACT_IN_PROJECT	CP
			ON	CP.PROJECTID			= P.PROJECTID
		  JOIN	TCONTRACT				C
			ON	C.CONTRACTID			= CP.CONTRACTID
		  JOIN	TCONTRACTRELATION		CR
			ON	CR.CONTRACTRELATIONID	= C.CONTRACTRELATIONID
		)								G
 GROUP	BY
		G.PROJECTID

GO
/****** Object:  View [dbo].[VCONTRACT_ACL]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VCONTRACT_ACL]
AS
/*
Given this setting in system settings:

statoil.com=statoil-net,TheVendor.lan=TheVendor,cmaTheVendor.lan=cmaTheVendor
123456789012345678901234567890123456789012345678901234567890123456789
                                    ^(A)   ^(C)

And this username:
[--D----]
 1bjotor@TheVendor.lan
        [-----(B)---]


----- Domain -----					
Kode: /*(D:*/substring(acluser.domainusername, charindex('@',acluser.domainusername) + 1,1000)/*D)*/
Description: The domain name as it was extracted from the username. 
Sample: (B): 1bjotor@TheVendor.lan -> TheVendor.lan

----- IndexOfAliasToUse -----					
Kode: /*(IA:*/charindex(/*(D:*/substring(acluser.domainusername, charindex('@',acluser.domainusername) + 1,1000)/*D)*/, sv.settingvalue) +  len(/*(D:*/substring(acluser.domainusername, charindex('@',acluser.domainusername) + 1,1000)/*D)*/) +1/*IA)*/
Description: Index of first letter in the alias to translate Domain to
Sample: (A) = 47

----- IndexNextComma -----					
Kode: /*(IK:*/charindex(',',sv.settingvalue,charindex(/*(D:*/substring(acluser.domainusername, charindex('@',acluser.domainusername) + 1,1000)/*D)*/,sv.settingvalue))/*IK)*/
Description: Index of the comma after the IndexOfAliasToUse
Sample: (C) = 54

----- UserName -----					
Kode: /*(U:*/substring(acluser.domainusername, 0, charindex('@', acluser.domainusername))/*U)*/
Description: The username portion of domainusername.
Sample: (D): 1bjotor@TheVendor.lan -> 1bjotor


*/
SELECT DISTINCT 
	con.CONTRACTID,
	
	CASE WHEN 
		(charindex('=',sv.settingvalue)=0)-- If no setting in systemsetting for netbios alias
	THEN
		CASE WHEN acluser.domainusername IS NULL OR	charindex('@', acluser.domainusername) = 0 --if not SSO or if not a domain name 
		THEN NULL --return null
		ELSE 
			substring(
				acluser.domainusername, 
				charindex('@', acluser.domainusername) + 1, --Start index is index of @ +1
				CASE WHEN charindex('.', acluser.domainusername, charindex('@', acluser.domainusername) + 1) = 0 
					THEN len(acluser.domainusername) + 1 --rest of string if no '.'
					ELSE charindex('.', acluser.domainusername, charindex('@', acluser.domainusername) + 1) --to next '.' if '.' is present
					END - charindex('@', acluser.domainusername) - 1
			) 
			
		END
	ELSE
		CASE WHEN 
			(/*(IK:*/charindex(',',sv.settingvalue,charindex(/*(D:*/substring(acluser.domainusername, charindex('@',acluser.domainusername) + 1,1000)/*D)*/, sv.settingvalue))/*IK)*/=0)
			
		THEN
			substring
					(
						sv.settingvalue,
						/*(IA:*/charindex(/*(D:*/substring(acluser.domainusername, charindex('@',acluser.domainusername) + 1,1000)/*D)*/, sv.settingvalue)+len(/*(D:*/substring(acluser.domainusername, charindex('@',acluser.domainusername) + 1,1000)/*D)*/)+1/*IA)*/,
						1000
					)
		ELSE
			substring
					(
						sv.settingvalue,
						/*(IA:*/charindex(/*(D:*/substring(acluser.domainusername, charindex('@',acluser.domainusername) + 1,1000)/*D)*/, sv.settingvalue)+len(/*(D:*/substring(acluser.domainusername, charindex('@',acluser.domainusername) + 1,1000)/*D)*/)+1/*IA)*/,
						/*(IK:*/charindex(',',sv.settingvalue,charindex(/*(D:*/substring(acluser.domainusername, charindex('@',acluser.domainusername) + 1,1000)/*D)*/, sv.settingvalue))/*IK)*/
							-(charindex(/*(D:*/substring(acluser.domainusername, charindex('@',acluser.domainusername) + 1,1000)/*D)*/, sv.settingvalue)
							+len(/*(D:*/substring(acluser.domainusername, charindex('@',acluser.domainusername) + 1,1000)/*D)*/))
							-1
					)
		END 
	END + '\' + /*(U:*/substring(acluser.domainusername, 0, charindex('@', acluser.domainusername))/*U)*/ AS domainusername
FROM            TACL
INNER JOIN TPROFILESETTING sv on sv.profilekeyid in (select profilekeyid from tprofilekey where fixed='DNSDOMAINMAPPING')
INNER JOIN TCONTRACT AS con ON TACL.OBJECTID = con.CONTRACTID AND TACL.PRIVILEGEID = 1 AND TACL.OBJECTTYPEID IN
                             (SELECT        OBJECTTYPEID
                               FROM            TOBJECTTYPE
                               WHERE        (FIXED = N'CONTRACT')) 
INNER JOIN TUSER AS ACLUSER ON (TACL.USERID = ACLUSER.USERID OR
                         TACL.GROUPID IN
                             (SELECT        USERGROUPID
                               FROM            TUSER_IN_USERGROUP
                               WHERE        (USERID = ACLUSER.USERID))) AND TACL.PRIVILEGEID = 1
where acluser.domainusername is not null

GO
/****** Object:  View [dbo].[VDocumentTypes]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VDocumentTypes]
AS
SELECT     TOP 100 PERCENT dbo.TDOCUMENT.OBJECTID, dbo.TDOCUMENT.MIK_VALID, dbo.TDOCUMENTTYPE.FIXED AS DOCUMENTTYPE_FIXED, 
                      dbo.TDOCUMENTTYPE.DOCUMENTTYPEID, dbo.TDOCUMENTTYPE.DOCUMENTTYPE, dbo.TDOCUMENTTYPE.MIK_SEQUENCE, 
                      dbo.TDOCUMENTTYPE.ParentID, dbo.TDOCUMENTTYPE.RootID, dbo.TDOCUMENTTYPE.[Level], dbo.TDOCUMENTTYPE.ObjectTypeID, 
                      dbo.TOBJECTTYPE.FIXED AS OBJECTTYPE_FIXED, dbo.TOBJECTTYPE.OBJECTTYPE, dbo.TOBJECTTYPE.HASDOCUMENTS, 
                      dbo.TOBJECTTYPE.USEDBYMODEL, dbo.TDOCUMENT.DOCUMENTID, dbo.TDOCUMENTTYPE.SUB_OBJECTTYPEID
FROM         dbo.TDOCUMENT INNER JOIN
                      dbo.TOBJECTTYPE ON dbo.TDOCUMENT.OBJECTTYPEID = dbo.TOBJECTTYPE.OBJECTTYPEID LEFT OUTER JOIN
                      dbo.TDOCUMENTTYPE ON dbo.TDOCUMENT.DOCUMENTTYPEID = dbo.TDOCUMENTTYPE.DOCUMENTTYPEID
ORDER BY dbo.TDOCUMENTTYPE.DOCUMENTTYPEID, dbo.TDOCUMENT.DOCUMENTID



GO
/****** Object:  View [dbo].[VDocumentTypesAmendment]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VDocumentTypesAmendment]
AS
SELECT     TOP 100 PERCENT dbo.TDOCUMENTTYPE.DOCUMENTTYPEID, dbo.TDOCUMENTTYPE.DOCUMENTTYPE, dbo.TDOCUMENTTYPE.MIK_SEQUENCE, 
                      dbo.TDOCUMENT.DOCUMENTID, dbo.TDOCUMENTTYPE.ParentID, dbo.TDOCUMENTTYPE.[Level], dbo.TDOCUMENTTYPE.RootID, 
                      dbo.TDOCUMENT.MIK_VALID, dbo.TDOCUMENTTYPE.ObjectTypeID, dbo.TDOCUMENT.OBJECTID AS AmendmentId
FROM         dbo.TDOCUMENT INNER JOIN
                      dbo.TOBJECTTYPE ON dbo.TDOCUMENT.OBJECTTYPEID = dbo.TOBJECTTYPE.OBJECTTYPEID LEFT OUTER JOIN
                      dbo.TDOCUMENTTYPE ON dbo.TDOCUMENT.DOCUMENTTYPEID = dbo.TDOCUMENTTYPE.DOCUMENTTYPEID
WHERE     (dbo.TOBJECTTYPE.FIXED = N'AMENDMENT')
ORDER BY dbo.TDOCUMENTTYPE.DOCUMENTTYPEID, dbo.TDOCUMENT.DOCUMENTID



GO
/****** Object:  View [dbo].[VDocumentTypesContract]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VDocumentTypesContract]
AS
SELECT     TOP 100 PERCENT dbo.TDOCUMENTTYPE.DOCUMENTTYPEID, dbo.TDOCUMENTTYPE.DOCUMENTTYPE, dbo.TDOCUMENTTYPE.MIK_SEQUENCE, 
                      dbo.TDOCUMENT.DOCUMENTID, dbo.TDOCUMENTTYPE.ParentID, dbo.TDOCUMENTTYPE.[Level], dbo.TDOCUMENTTYPE.RootID, 
                      dbo.TDOCUMENT.OBJECTID AS ContractId, dbo.TDOCUMENT.MIK_VALID, dbo.TDOCUMENT.OBJECTTYPEID
FROM         dbo.TDOCUMENT INNER JOIN
                      dbo.TOBJECTTYPE ON dbo.TDOCUMENT.OBJECTTYPEID = dbo.TOBJECTTYPE.OBJECTTYPEID LEFT OUTER JOIN
                      dbo.TDOCUMENTTYPE ON dbo.TDOCUMENT.DOCUMENTTYPEID = dbo.TDOCUMENTTYPE.DOCUMENTTYPEID
WHERE     (dbo.TOBJECTTYPE.FIXED = N'CONTRACT')
ORDER BY dbo.TDOCUMENTTYPE.DOCUMENTTYPEID, dbo.TDOCUMENT.DOCUMENTID



GO
/****** Object:  View [dbo].[VDocumentTypesOptions]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VDocumentTypesOptions]
AS
SELECT     TOP 100 PERCENT dbo.TDOCUMENT.DOCUMENTID, dbo.TDOCUMENTTYPE.DOCUMENTTYPEID, dbo.TDOCUMENTTYPE.DOCUMENTTYPE, 
                      dbo.TDOCUMENTTYPE.MIK_SEQUENCE, dbo.TDOCUMENTTYPE.ParentID, dbo.TDOCUMENTTYPE.RootID, dbo.TDOCUMENTTYPE.[Level], 
                      dbo.TDOCUMENTTYPE.ObjectTypeID, dbo.TDOCUMENT.OBJECTID AS OptionID, dbo.TDOCUMENT.MIK_VALID
FROM         dbo.TDOCUMENT INNER JOIN
                      dbo.TOBJECTTYPE ON dbo.TDOCUMENT.OBJECTTYPEID = dbo.TOBJECTTYPE.OBJECTTYPEID LEFT OUTER JOIN
                      dbo.TDOCUMENTTYPE ON dbo.TDOCUMENT.DOCUMENTTYPEID = dbo.TDOCUMENTTYPE.DOCUMENTTYPEID
WHERE     (dbo.TOBJECTTYPE.FIXED = N'OPTION')
ORDER BY dbo.TDOCUMENTTYPE.DOCUMENTTYPEID, dbo.TDOCUMENT.DOCUMENTID



GO
/****** Object:  View [dbo].[VDocumentTypesTenderer]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VDocumentTypesTenderer]
AS
SELECT     TOP 100 PERCENT dbo.TDOCUMENTTYPE.DOCUMENTTYPEID, dbo.TDOCUMENTTYPE.DOCUMENTTYPE, dbo.TDOCUMENTTYPE.MIK_SEQUENCE, 
                      dbo.TDOCUMENT.DOCUMENTID, dbo.TDOCUMENTTYPE.ParentID, dbo.TDOCUMENTTYPE.[Level], dbo.TDOCUMENTTYPE.RootID, 
                      dbo.TDOCUMENT.OBJECTID AS TendererId, dbo.TDOCUMENT.MIK_VALID, dbo.TOBJECTTYPE.OBJECTTYPEID
FROM         dbo.TDOCUMENTTYPE RIGHT OUTER JOIN
                      dbo.TDOCUMENT INNER JOIN
                      dbo.TOBJECTTYPE ON dbo.TDOCUMENT.OBJECTTYPEID = dbo.TOBJECTTYPE.OBJECTTYPEID ON 
                      dbo.TDOCUMENTTYPE.DOCUMENTTYPEID = dbo.TDOCUMENT.DOCUMENTTYPEID
WHERE     (dbo.TOBJECTTYPE.FIXED = N'TENDERER')
ORDER BY dbo.TDOCUMENTTYPE.DOCUMENTTYPEID, dbo.TDOCUMENT.DOCUMENTID



GO
/****** Object:  View [dbo].[VEXTERNALUSERRFXUPCOMINGORRECENT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[VEXTERNALUSERRFXUPCOMINGORRECENT] as

SELECT * FROM
(
	SELECT 
	u.USERID,
	u.USERINITIAL,
	u.PERSONID,
	rfx.RFXID,
	con.CONTRACTID,
	cc.COMPANYID,
	rfx.ACTIVATEEXTERNALUSERSDATE AS ACTIVATEEXTERNALUSERSDATE,

	ISNULL(PLANNEDAWARDDATE, 
			CASE WHEN DATEADD(HOUR, TIMEZONEUTCOFFSET, RESPONSEDEADLINE) < GETUTCDATE() 
			THEN
				(SELECT DATEADD(D, 0, DATEDIFF(D, 0, GETUTCDATE())))
			ELSE
				DATEADD(HOUR, TIMEZONEUTCOFFSET, RESPONSEDEADLINE)
			END) AS EXTERNALUSERENDDATE,

	(SELECT TOP 1 EMAIL FROM 
		TPERSON P
			INNER JOIN TPERSONROLE_IN_OBJECT PRIO ON P.PERSONID = PRIO.PERSONID AND PRIO.OBJECTTYPEID = (SELECT TOP 1 OBJECTTYPEID FROM TOBJECTTYPE WHERE FIXED = 'RFX')
			INNER JOIN TROLE R ON PRIO.ROLEID = R.ROLEID AND R.FIXED = 'RFX_MAINCONTACT'
		WHERE
			PRIO.OBJECTID = rfx.RFXID) AS UserResponsibleEmail

	FROM TUSER u
	INNER JOIN TCOMPANYCONTACT_IN_RFXINTEREST TR ON TR.CompanyContactUserId = u.USERID
	INNER JOIN TRFXINTEREST I ON TR.RfxInterestId = I.RFXINTERESTID
	INNER JOIN TRFX rfx ON I.RFXID = rfx.RFXID
	INNER JOIN TCOMPANYCONTACT cc ON cc.PERSONID = u.PERSONID AND CC.MIK_VALID = 1
	INNER JOIN TCONTRACT con ON rfx.CONTRACTID = con.CONTRACTID
	INNER JOIN TSTATUS stat ON con.STATUSID = stat.STATUSID
	LEFT OUTER JOIN TCOMPANY CAC 
		ON CAC.COMPANYID = dbo.udf_get_companyid(CON.CONTRACTID)

	WHERE

	--Common rules
		u.ISEXTERNALUSER = 1
	AND	u.MIK_VALID = 1

	--eSourcing rules

	-- Procurement Responsible has elected to activate the external users on this RFx
	AND		RFX.ACTIVATEEXTERNALUSERS = 1

	-- The RFx must have a response deadline
	AND		RFX.RESPONSEDEADLINE IS NOT NULL

	-- RFx must not be cancelled
	AND		RFX.STATUSID != (SELECT TOP 1 STATUSID FROM TSTATUS WHERE FIXED = 'CANCELLED')

	-- RFx must be on a contract which is;
	AND		
	(
		-- Not awarded 
		(		CAC.COMPANYID IS NULL 
			AND	stat.FIXED != 'AWARDED_TO_MULTIPLE'
		)
		
		OR

		--Or the award date + grace period has not passed yet
		(		CON.AWARDDATE IS NOT NULL 
			AND	CON.AWARDDATE 
				> 
				DATEADD(DAY, - ISNULL((	SELECT CAST(SETTINGVALUE AS INT) 
										FROM TPROFILESETTING 
										WHERE PROFILEKEYID = (
												SELECT PROFILEKEYID 
												FROM TPROFILEKEY 
												WHERE FIXED = 'DAYS_NUMBER_RFX_USER_ACTIVE_AFTER_CONTRACT_AWARD_DATE')
											AND USERGROUPID is NULL and USERID is NULL)
										,0), (SELECT DATEADD(D, 0, DATEDIFF(D, 0, GETUTCDATE()))))
		)
	)
) AS InvitedParty
UNION
(
	SELECT 
	u.USERID,
	u.USERINITIAL,
	u.PERSONID,
	rfx.RFXID,
	con.CONTRACTID,
	cc.COMPANYID,
	rfx.ACTIVATEEXTERNALUSERSDATE AS ACTIVATEEXTERNALUSERSDATE,

	ISNULL(PLANNEDAWARDDATE, 
			CASE WHEN DATEADD(HOUR, TIMEZONEUTCOFFSET, RESPONSEDEADLINE) < GETUTCDATE() 
			THEN
				(SELECT DATEADD(D, 0, DATEDIFF(D, 0, GETUTCDATE())))
			ELSE
				DATEADD(HOUR, TIMEZONEUTCOFFSET, RESPONSEDEADLINE)
			END) AS EXTERNALUSERENDDATE,

	(SELECT TOP 1 EMAIL FROM 
		TPERSON P
			INNER JOIN TPERSONROLE_IN_OBJECT PRIO ON P.PERSONID = PRIO.PERSONID AND PRIO.OBJECTTYPEID = (SELECT TOP 1 OBJECTTYPEID FROM TOBJECTTYPE WHERE FIXED = 'RFX')
			INNER JOIN TROLE R ON PRIO.ROLEID = R.ROLEID AND R.FIXED = 'RFX_MAINCONTACT'
		WHERE
			PRIO.OBJECTID = rfx.RFXID) AS UserResponsibleEmail

	FROM TUSER u
	INNER JOIN TCOMPANYCONTACT cc ON cc.PERSONID = u.PERSONID AND CC.MIK_VALID = 1
	INNER JOIN TCOMPANYCONTACT_IN_TENDERER TT ON TT.CompanyContactId = cc.COMPANYCONTACTID
	INNER JOIN TTENDERER TEN ON TT.TendererId = TEN.TENDERERID
	INNER JOIN TRFX rfx ON TEN.RFXID = rfx.RFXID
	INNER JOIN TCONTRACT con ON rfx.CONTRACTID = con.CONTRACTID
	INNER JOIN TSTATUS stat ON con.STATUSID = stat.STATUSID
	LEFT OUTER JOIN TCOMPANY CAC 
		ON CAC.COMPANYID = dbo.udf_get_companyid(CON.CONTRACTID)

	WHERE

	--Common rules
		u.ISEXTERNALUSER = 1
	AND	u.MIK_VALID = 1

	--eSourcing rules

	-- Procurement Responsible has elected to activate the external users on this RFx
	AND		RFX.ACTIVATEEXTERNALUSERS = 1

	-- The RFx must have a response deadline
	AND		RFX.RESPONSEDEADLINE IS NOT NULL

	-- RFx must not be cancelled
	AND		RFX.STATUSID != (SELECT TOP 1 STATUSID FROM TSTATUS WHERE FIXED = 'CANCELLED')

	-- RFx must be on a contract which is;
	AND		
	(
		-- Not awarded 
		(		CAC.COMPANYID IS NULL 
			AND	stat.FIXED != 'AWARDED_TO_MULTIPLE'
		)
		
		OR

		--Or the award date + grace period has not passed yet
		(		CON.AWARDDATE IS NOT NULL 
			AND	CON.AWARDDATE 
				> 
				DATEADD(DAY, - ISNULL((	SELECT CAST(SETTINGVALUE AS INT) 
										FROM TPROFILESETTING 
										WHERE PROFILEKEYID = (
												SELECT PROFILEKEYID 
												FROM TPROFILEKEY 
												WHERE FIXED = 'DAYS_NUMBER_RFX_USER_ACTIVE_AFTER_CONTRACT_AWARD_DATE') 
											AND USERGROUPID is NULL and USERID is NULL)
										,0), (SELECT DATEADD(D, 0, DATEDIFF(D, 0, GETUTCDATE()))))
		)
	)
)
UNION
(
	--eContracting, ignoring RFx (All relevant fields are identical for both with and without RFx)

	SELECT
	u.USERID,
	u.USERINITIAL,
	u.PERSONID,
	rfx.RFXID,
	con.CONTRACTID,
	cc.COMPANYID AS COMPANYID,

	(SELECT DATEADD(D, 0, DATEDIFF(D, 0, GETUTCDATE()))) AS ACTIVATEEXTERNALUSERSDATE,

	ISNULL(CON.REV_EXPIRYDATE, 
		ISNULL(CON.EXPIRYDATE, 
		ISNULL(REVIEWDATE, 
		DATEADD(MONTH, 12, AWARDDATE)))) AS EXTERNALUSERENDDATE,

	CASE WHEN rfx.RFXID IS NOT NULL THEN
		(SELECT TOP 1 EMAIL FROM 
			TPERSON P
				INNER JOIN TPERSONROLE_IN_OBJECT PRIO ON P.PERSONID = PRIO.PERSONID AND PRIO.OBJECTTYPEID = (SELECT TOP 1 OBJECTTYPEID FROM TOBJECTTYPE WHERE FIXED = 'RFX')
				INNER JOIN TROLE R ON PRIO.ROLEID = R.ROLEID AND R.FIXED = 'RFX_MAINCONTACT'
			WHERE
				PRIO.OBJECTID = rfx.RFXID)
	ELSE
			(SELECT TOP 1 EMAIL FROM 
			TPERSON P
				INNER JOIN TPERSONROLE_IN_OBJECT PRIO ON P.PERSONID = PRIO.PERSONID AND PRIO.OBJECTTYPEID = (SELECT TOP 1 OBJECTTYPEID FROM TOBJECTTYPE WHERE FIXED = 'CONTRACT')
				INNER JOIN TROLE R ON PRIO.ROLEID = R.ROLEID AND R.FIXED = 'COMMERCIAL_CO_ORDINATOR'
			WHERE
				PRIO.OBJECTID = CON.CONTRACTID)
	END AS UserResponsibleEmail

	FROM TUSER u
	INNER JOIN TCOMPANYCONTACT cc ON cc.PERSONID = u.PERSONID
	INNER JOIN TCOMPANYCONTACT_IN_TENDERER cct ON cct.CompanyContactId = cc.COMPANYCONTACTID
	INNER JOIN TTENDERER ten ON cct.TendererId = ten.TENDERERID
	INNER JOIN TCONTRACT con ON ten.CONTRACTID = con.CONTRACTID
	INNER JOIN TSTATUS stat ON con.STATUSID = stat.STATUSID
	LEFT JOIN TRFX rfx on rfx.CONTRACTID = con.CONTRACTID
	LEFT OUTER JOIN TCOMPANY CAC 
		ON CAC.COMPANYID = dbo.udf_get_companyid(CON.CONTRACTID)

	WHERE

	--Common rules
		u.ISEXTERNALUSER = 1
	AND	u.MIK_VALID = 1

	--eContracting rules

	--Contract is awarded
	AND	cac.COMPANYID is not null

	--Contract is shared with supplier
	AND con.SHAREDWITHSUPPLIER = 1

	--Contract has a valid date
	AND ISNULL(CON.REV_EXPIRYDATE, ISNULL(CON.EXPIRYDATE, ISNULL(CON.REVIEWDATE, CON.AWARDDATE))) IS NOT NULL

	--Company is the awarded supplier
	AND cc.COMPANYID = cac.COMPANYID

	-- Contract has a status which is used in eContracting
	AND
	(
		SELECT SETTINGVALUE 
		FROM TPROFILESETTING
		WHERE PROFILEKEYID = 
		(
			SELECT PROFILEKEYID 
			FROM TPROFILEKEY 
			WHERE FIXED = 'ECONTRACTING_LIST_OF_STATUSES_FOR_DISPLAY'
		)
		AND USERGROUPID is NULL and USERID is NULL
	) Like '%' + STAT.FIXED + '%'
)

GO
/****** Object:  View [dbo].[VI_TPERSON_EXTERNALNUMBER]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Re-create indexed view and index
CREATE VIEW [dbo].[VI_TPERSON_EXTERNALNUMBER] ([EXTERNALNUMBER]) WITH SCHEMABINDING
AS
SELECT [EXTERNALNUMBER] FROM [DBO].[TPERSON] WHERE EXTERNALNUMBER IS NOT NULL AND EXTERNALNUMBER <> ''
GO
/****** Object:  View [dbo].[VLINK]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VLINK]
AS
SELECT     LG.LINKGROUP, L.LINK, L.LINKNAME, L.DESCRIPTION, LG.LINKGROUPID, LG.LINKICONID AS GROUPICONINDEX, LT.LINKTYPE, LT.LINKTYPEID, 
                      L.LINKID, LT.LINKICONID AS TYPEICONINDEX, L.MIK_VALID
FROM         dbo.TLINK L INNER JOIN
                      dbo.TLINKTYPE LT ON L.LINKTYPEID = LT.LINKTYPEID INNER JOIN
                      dbo.TLINK_IN_GROUP LIG INNER JOIN
                      dbo.TLINKGROUP LG ON LIG.LINKGROUPID = LG.LINKGROUPID ON L.LINKID = LIG.LINKID




GO
/****** Object:  View [dbo].[VLOGON]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VLOGON]
AS
SELECT     dbo.TLOGON.APPL, dbo.TLOGON.DT_LOGON, dbo.TLOGON.DT_LOGOFF, dbo.TLOGON.DT_LASTSEEN, dbo.TUSER.MIK_VALID AS UserIsValid, 
                      dbo.TPERSON.DISPLAYNAME, dbo.TEMPLOYEE.MIK_VALID AS EmployeeIsValid
FROM         dbo.TEMPLOYEE LEFT OUTER JOIN
                      dbo.TPERSON ON dbo.TEMPLOYEE.PERSONID = dbo.TPERSON.PERSONID RIGHT OUTER JOIN
                      dbo.TUSER ON dbo.TEMPLOYEE.EMPLOYEEID = dbo.TUSER.EMPLOYEEID RIGHT OUTER JOIN
                      dbo.TLOGON ON dbo.TUSER.USERID = dbo.TLOGON.USERID


GO
/****** Object:  View [dbo].[VMODEL]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VMODEL]
AS
SELECT 
dbo.TMODEL.MODELID,
dbo.TMODEL.MODEL,
dbo.TMODEL.MODELDATE,
dbo.TMODEL.COMMENTS,
dbo.TMODEL.USERID,
dbo.TMODEL.LANGUAGEID,
dbo.TMODEL.MODELTYPEID,
dbo.TMODEL.OBJECTTYPEID,
dbo.TMODEL.CONTRACTRELATIONID,
dbo.TMODEL.AGREEMENT_TYPEID,
dbo.TMODEL.STRATEGYTYPEID,
dbo.TLANGUAGE.MIK_LANGUAGE AS MIK_LANGUAGE, dbo.TCONTRACTRELATION.CONTRACTRELATION AS CONTRACTRELATION, 
                      dbo.TAGREEMENT_TYPE.AGREEMENT_TYPE AS AGREEMENT_TYPE, dbo.TSTRATEGYTYPE.STRATEGYTYPE AS STRATEGYTYPE, 
                      dbo.TMODELTYPE.MODELTYPE AS MODELTYPE, dbo.TOBJECTTYPE.OBJECTTYPE AS OBJECTTYPE, dbo.TOBJECTTYPE.FIXED AS OBJECTTYPEFIXED,
dbo.TMODEL.SUB_OBJECTTYPEID
FROM         dbo.TMODEL LEFT OUTER JOIN
                      dbo.TSTRATEGYTYPE ON dbo.TMODEL.STRATEGYTYPEID = dbo.TSTRATEGYTYPE.STRATEGYTYPEID LEFT OUTER JOIN
                      dbo.TAGREEMENT_TYPE ON dbo.TMODEL.AGREEMENT_TYPEID = dbo.TAGREEMENT_TYPE.AGREEMENT_TYPEID LEFT OUTER JOIN
                      dbo.TCONTRACTRELATION ON dbo.TMODEL.CONTRACTRELATIONID = dbo.TCONTRACTRELATION.CONTRACTRELATIONID LEFT OUTER JOIN
                      dbo.TMODELTYPE ON dbo.TMODEL.MODELTYPEID = dbo.TMODELTYPE.MODELTYPEID LEFT OUTER JOIN
                      dbo.TLANGUAGE ON dbo.TMODEL.LANGUAGEID = dbo.TLANGUAGE.LANGUAGEID LEFT OUTER  JOIN
                      dbo.TOBJECTTYPE ON dbo.TMODEL.OBJECTTYPEID = dbo.TOBJECTTYPE.OBJECTTYPEID

GO
/****** Object:  View [dbo].[VNOTE]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VNOTE]
AS
SELECT     dbo.TNOTETYPE.NOTETYPE, dbo.TNOTE.NOTETITLE, dbo.TNOTE.USERID, dbo.TPERSON.DISPLAYNAME AS LASTCHANGEDBY, 
                      dbo.TNOTE.LASTCHANGEDDATE, dbo.TNOTE.NOTEID, dbo.TNOTE_IN_OBJECT.OBJECTTYPEID, dbo.TNOTE_IN_OBJECT.OBJECTID, 
                      dbo.TNOTE.NOTETYPEID
FROM         dbo.TEMPLOYEE LEFT OUTER JOIN
                      dbo.TPERSON ON dbo.TEMPLOYEE.PERSONID = dbo.TPERSON.PERSONID RIGHT OUTER JOIN
                      dbo.TUSER ON dbo.TEMPLOYEE.EMPLOYEEID = dbo.TUSER.EMPLOYEEID RIGHT OUTER JOIN
                      dbo.TNOTE INNER JOIN
                      dbo.TNOTE_IN_OBJECT ON dbo.TNOTE.NOTEID = dbo.TNOTE_IN_OBJECT.NOTEID INNER JOIN
                      dbo.TNOTETYPE ON dbo.TNOTE.NOTETYPEID = dbo.TNOTETYPE.NOTETYPEID ON dbo.TUSER.USERID = dbo.TNOTE.USERID



GO
/****** Object:  View [dbo].[VOPTIONALEXTENSION]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VOPTIONALEXTENSION] AS
SELECT
O.OPTIONID,
O.OPTIONNAME,
O.OPTIONNUMBER,
O.MIK_SEQUENCE,
O.FROMDATE,
O.TODATE,
O.DECLARED,
O.DATEDECLARED,
C.CONTRACTID,
C.CONTRACTNUMBER,
C.EXPIRYDATE,
C.REV_EXPIRYDATE
FROM
TOPTION O,
TCONTRACT C
WHERE
O.CONTRACTID=C.CONTRACTID

GO
/****** Object:  View [dbo].[VORDER]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VORDER]
AS
SELECT	O.ORDERID,
		O.ORDERTYPEID,
		O.CONTRACTID,
		O.STATUSID,
		O.PROJECTID,
		O.AMOUNTID,
		O.COMPANYCONTACTID,
		O.ORDERNAME,
		O.ORDERNUMBER,
		O.ORDERREVISION,
		O.EXTERNALNUMBER,
		O.INTERNALNUMBER,
		O.COUNTERPARTYNUMBER,
		O.SCOPE,
		O.CREATEDDATE,
		O.ORDERDATE,
		O.STARTDATE,
		O.ENDDATE,
		O.DELIVERBYDATE,
		O.INSURANCEEXPIRYDATE,
		O.RATEESCALATIONDATE,
		O.MIK_VALID,
		OT.ORDERTYPE,
		OT.FIXED						AS ORDERTYPEFIXED,
		C.[CONTRACT],
		C.CONTRACTNUMBER,
		S.[STATUS],
		S.FIXED							AS STATUSFIXED,
		PRJ.PROJECT, 
		PRJ.PROJECT_NUMBER,
		A.Amount						AS VALUE,
		P.DISPLAYNAME					AS REPRESENTATIVE, 
		P.EMAIL							AS REPRESENTATIVEEMAIL,
		P.PHONE1						AS REPRESENTATIVEPHONE
  FROM	dbo.TCOMPANYCONTACT				CC
  JOIN	dbo.TPERSON						P
	ON	CC.PERSONID						= P.PERSONID
 RIGHT	OUTER
  JOIN	dbo.TORDER						O
  JOIN	dbo.TORDERTYPE					OT
	ON	O.ORDERTYPEID					= OT.ORDERTYPEID
  JOIN	dbo.TCONTRACT					C
	ON	O.CONTRACTID					= C.CONTRACTID
  JOIN	dbo.TSTATUS						S
	ON	O.STATUSID						= S.STATUSID
	ON	CC.COMPANYCONTACTID				= O.COMPANYCONTACTID
  LEFT	OUTER
  JOIN	dbo.TAMOUNT						A
	ON	O.AMOUNTID						= A.AmountID
  LEFT	OUTER
  JOIN	dbo.TPROJECT					PRJ
	ON	O.PROJECTID						= PRJ.PROJECTID

GO
/****** Object:  View [dbo].[VPERSON]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	This view might return duplicates (persons/users who are contacts for more than one company each)
--	Alex L 23-feb-2011
CREATE VIEW [dbo].[VPERSON] AS(
SELECT	'USER_INTERNAL'			AS PERSONCATEGORY,
		P.PERSONID,
		P.DISPLAYNAME + ' (' + U.USERINITIAL + ')'
								AS DISPLAYNAME,
		P.EMAIL,
		P.PHONE1, 
		P.PHONE2,
		P.INITIALS,
		P.TITLE,
		P.FIRSTNAME,
		P.MIDDLENAME,
		P.LASTNAME,
		P.PERSONAL_CODE,
		P.DATE_OF_BIRTH,
		CT.COUNTRY, 
		U.USERID				AS ID_IN_CATEGORY,
		U.MIK_VALID				AS VALID_IN_CATEGORY,
		'DEPARTMENT'			AS CONTEXT,
		E.DEPARTMENTID			AS CONTEXTID, 
		D .DEPARTMENT_CODE		AS CONTEXTCODE,
		D .DEPARTMENT			AS CONTEXTNAME,
		E1.EMPLOYEEID			AS MANAGEREMPLOYEEID,
		P1.PERSONID				AS MANAGERPERSONID,
		P1.FIRSTNAME + ' ' + P1.LASTNAME
								AS PRIMARYMANAGER
  FROM	TPERSON					P
  JOIN	TEMPLOYEE				E
	ON	P.PERSONID				= E.PERSONID
  LEFT	
  JOIN  TEMPLOYEERELATION		ER
  	ON	E.EMPLOYEEID			= ER.INFERIOREMPLOYEEID AND	ER.ISPRIMARYMANAGER	= 1
  LEFT
  JOIN	TEMPLOYEE				E1
	ON	E1.EMPLOYEEID			= ER.MANAGEREMPLOYEEID
  LEFT
  JOIN	TPERSON					P1
	ON	P1.PERSONID				= E1.PERSONID	
  JOIN	TDEPARTMENT				D
	ON	E.DEPARTMENTID			= D .DEPARTMENTID
  JOIN	TUSER					U
	ON	E.EMPLOYEEID			= U.EMPLOYEEID
  LEFT	OUTER
  JOIN	TCOUNTRY				CT
	ON	P.COUNTRYID				= CT.COUNTRYID
 WHERE	P.PERSONID				> 0
   AND	(	P.FIRSTNAME			<> 'System'
		AND P.LASTNAME			<> 'Service'
		)
UNION ALL
SELECT	'USER_EXTERNAL'			AS PERSONCATEGORY,
		P.PERSONID,
		P.DISPLAYNAME + ' (' + U.USERINITIAL + ')'
								AS DISPLAYNAME,
		P.EMAIL,
		P.PHONE1, 
		P.PHONE2,
		P.INITIALS,
		P.TITLE,
		P.FIRSTNAME,
		P.MIDDLENAME,
		P.LASTNAME,
		P.PERSONAL_CODE,
		P.DATE_OF_BIRTH,
		CT.COUNTRY, 
		U.USERID				AS ID_IN_CATEGORY,
		U.MIK_VALID				AS VALID_IN_CATEGORY,
		'COMPANY'				AS CONTEXT,
		CC.COMPANYID			AS CONTEXTID, 
		CY.COMPANYNO			AS CONTEXTCODE,
		CY.COMPANY				AS CONTEXTNAME,
		null					AS MANAGEREMPLOYEEID,
		null					AS MANAGERPERSONID,
		null					AS PRIMARYMANAGER
  FROM	TPERSON					P
  JOIN	TCOMPANYCONTACT			CC
	ON	P.PERSONID				= CC.PERSONID
  JOIN	TCOMPANY				CY
	ON	CC.COMPANYID			= CY.COMPANYID
  JOIN	TUSER					U
	ON	CC.PERSONID				= U.PERSONID
  LEFT	OUTER
  JOIN	TCOUNTRY				CT
	ON	P.COUNTRYID				= CT.COUNTRYID
 WHERE	P.PERSONID				> 0
   AND	P.FIRSTNAME				<> 'System'
   AND	P.LASTNAME				<> 'Service'
UNION ALL
SELECT	'EMPLOYEE'				AS PERSONCATEGORY,
		P.PERSONID,
		P.DISPLAYNAME + ' [' + ISNULL(E.EMPLOYEECODE, '') + ']'
								AS DISPLAYNAME,
		P.EMAIL,
		P.PHONE1, 
		P.PHONE2,
		P.INITIALS,
		P.TITLE,
		P.FIRSTNAME,
		P.MIDDLENAME,
		P.LASTNAME,
		P.PERSONAL_CODE,
		P.DATE_OF_BIRTH,
		CT.COUNTRY, 
		E.EMPLOYEEID			AS ID_IN_CATEGORY,
		E.MIK_VALID				AS VALID_IN_CATEGORY,
		'DEPARTMENT'			AS CONTEXT,
		E.DEPARTMENTID			AS CONTEXTID, 
		D .DEPARTMENT_CODE		AS CONTEXTCODE,
		D .DEPARTMENT			AS CONTEXTNAME,
		E1.EMPLOYEEID			AS MANAGEREMPLOYEEID,
		P1.PERSONID				AS MANAGERPERSONID,
		P1.FIRSTNAME + ' ' + P1.LASTNAME
								AS PRIMARYMANAGER
  FROM	TPERSON					P
  JOIN	TEMPLOYEE				E
	ON	P.PERSONID				= E.PERSONID
  LEFT	
  JOIN  TEMPLOYEERELATION		ER
  	ON	E.EMPLOYEEID			= ER.INFERIOREMPLOYEEID AND	ER.ISPRIMARYMANAGER	= 1
  LEFT
  JOIN	TEMPLOYEE				E1
	ON	E1.EMPLOYEEID			= ER.MANAGEREMPLOYEEID
  LEFT
  JOIN	TPERSON					P1
	ON	P1.PERSONID				= E1.PERSONID
  JOIN	TDEPARTMENT				D
	ON	E.DEPARTMENTID			= D.DEPARTMENTID
  LEFT	OUTER
  JOIN	TCOUNTRY				CT
	ON	P.COUNTRYID				= CT.COUNTRYID
 WHERE	P.PERSONID				> 0
   AND	P.FIRSTNAME				<> 'System'
   AND	P.LASTNAME				<> 'Service'
UNION ALL
SELECT	'COMPANYCONTACT'		AS PERSONCATEGORY,
		P.PERSONID,
		P.DISPLAYNAME,
		P.EMAIL,
		P.PHONE1,
		P.PHONE2,
		P.INITIALS,
		P.TITLE,
		P.FIRSTNAME, 
		P.MIDDLENAME,
		P.LASTNAME,
		P.PERSONAL_CODE,
		P.DATE_OF_BIRTH,
		CT.COUNTRY,
		CC.COMPANYCONTACTID		AS ID_IN_CATEGORY, 
		CC.MIK_VALID			AS VALID_IN_CATEGORY,
		'COMPANY'				AS CONTEXT,
		CC.COMPANYID			AS CONTEXTID,
		CY.COMPANYNO			AS CONTEXTCODE, 
		CY.COMPANY				AS CONTEXTNAME,
		null					AS MANAGEREMPLOYEEID,
		null					AS MANAGERPERSONID,
		null					AS PRIMARYMANAGER
  FROM	TPERSON					P
  JOIN	TCOMPANYCONTACT			CC
	ON	P.PERSONID				= CC.PERSONID
  LEFT	OUTER
  JOIN	TCOUNTRY				CT
	ON	P.COUNTRYID				= CT.COUNTRYID
  JOIN	TCOMPANY				CY
	ON	CC.COMPANYID			= CY.COMPANYID
 WHERE	P.PERSONID				> 0
   AND	(	P.FIRSTNAME			<> 'System'
		AND P.LASTNAME			<> 'Service'
		)
UNION ALL
SELECT	'CONSULTANT'			AS PERSONCATEGORY,
		P.PERSONID,
		P.DISPLAYNAME,
		P.EMAIL,
		P.PHONE1,
		P.PHONE2,
		P.INITIALS,
		P.TITLE,
		P.FIRSTNAME, 
		P.MIDDLENAME,
		P.LASTNAME,
		P.PERSONAL_CODE,
		P.DATE_OF_BIRTH,
		CT.COUNTRY,
		CA.CONSULTANTID			AS ID_IN_CATEGORY, 
		CA.MIK_VALID			AS VALID_IN_CATEGORY,
		'COMPANY'				AS CONTEXT,
		CA.COMPANYID			AS CONTEXTID,
		CY.COMPANYNO			AS CONTEXTCODE, 
		CY.COMPANY				AS CONTEXTNAME,
		null					AS MANAGEREMPLOYEEID,
		null					AS MANAGERPERSONID,
		null					AS PRIMARYMANAGER
  FROM	TPERSON					P
  JOIN	TCONSULTANT				CA
	ON	P.PERSONID				= CA.PERSONID
  JOIN	TCOMPANY				CY
	ON	CA.COMPANYID			= CY.COMPANYID	
  LEFT	OUTER
  JOIN	TCOUNTRY				CT
	ON	P.COUNTRYID				= CT.COUNTRYID 
 WHERE	P.PERSONID				> 0
   AND	P.FIRSTNAME				<> 'System'
   AND	P.LASTNAME				<> 'Service'
)

GO
/****** Object:  View [dbo].[VPERSON_WEB]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VPERSON_WEB] AS(
SELECT  'USER_WEB'			    AS PERSONCATEGORY,
		P.PERSONID,
		P.DISPLAYNAME + ' (' + U.USERINITIAL + ')' AS DISPLAYNAME,
		P.EMAIL,
		P.PHONE1, 
		P.PHONE2,
		P.INITIALS,
		P.TITLE,
		P.FIRSTNAME,
		P.MIDDLENAME,
		P.LASTNAME,
		P.PERSONAL_CODE,
		P.DATE_OF_BIRTH,
		CT.COUNTRY, 
		U.USERID				AS ID_IN_CATEGORY,
		U.MIK_VALID				AS VALID_IN_CATEGORY,
		''						AS CONTEXT,
		null					AS CONTEXTID, 
		null					AS CONTEXTCODE,
		null					AS CONTEXTNAME,
		null					AS MANAGEREMPLOYEEID,
		null					AS MANAGERPERSONID,
		null					AS PRIMARYMANAGER
  FROM	TPERSON					P
  LEFT OUTER 
  JOIN TEMPLOYEE E 
    ON E.PERSONID=P.PERSONID
  JOIN	TUSER					U
	ON	(U.PERSONID=P.PERSONID OR U.EMPLOYEEID=E.EMPLOYEEID)
  LEFT	OUTER
  JOIN	TCOUNTRY				CT
	ON	P.COUNTRYID				= CT.COUNTRYID
  JOIN dbo.TWorkflowUser			WU  
    JOIN dbo.TClientType             CLT
      ON CLT.FIXED in(N'WEB' , N'CCP')
    JOIN dbo.TWorkflowUser_in_ClientType WUCT
      ON WUCT.WorkflowUserId = WU.WorkflowUserId  AND  WUCT.ClientTypeId = CLT.ClientTypeId
    ON WU.ExternalUserId = U.USERID
WHERE	P.PERSONID				> 0
   AND	P.FIRSTNAME				<> 'System'
   AND	P.LASTNAME				<> 'Service'
   AND  U.USERINITIAL           <> N'Intranet CIS'
)

GO
/****** Object:  View [dbo].[VPREQUALIFICATION]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VPREQUALIFICATION]
AS
SELECT TOP (100) PERCENT 
	dbo.TASSESSMENT.ASSESSMENTID, 
	dbo.TASSESSMENT.COMMENTS, 
	dbo.TEVALUATIONTYPE.EVALUATIONTYPEID,
	dbo.TEVALUATIONTYPE.EVALUATIONTYPE, 
	dbo.TEVALUATIONTYPE.FIXED AS EvaluationTypeFixed, 
	dbo.TASSESSMENT.USERID_OWNER AS OwnerUserId, 
	dbo.TASSESSMENT_TEMPLATE.ASSESSMENTTEMPLATEID AS TemplateId, 
	dbo.TCRITERION_TEMPLATE.DESCRIPTION AS Template, 
	dbo.TASSESSMENTTEMPLATETYPE.ASSESSMENTTEMPLATETYPEID AS TemplateTypeId, 
	dbo.TASSESSMENTTEMPLATETYPE.ASSESSMENTTEMPLATETYPE AS TemplateType, 
	dbo.TASSESSMENT.STATUSID, 
	dbo.TASSESSMENT.ASSESSMENTDATE, 
	dbo.TASSESSMENT.QUALIFIED AS PreQualified, 
	dbo.TASSESSMENT.EXPIRY_DATE AS ExpiryDate, 
	dbo.TASSESSMENTCRITERION.DESCRIPTION AS AssessmentName, 
	dbo.TASSESSMENTCRITERION.MAX_VALUE AS MaxScore, 
	dbo.TASSESSMENTCRITERION.MINSCORE, 
	dbo.TCRITERIONTYPE.CRITERIONTYPEID,  
	dbo.TCRITERIONTYPE.CRITERIONTYPE, 
	dbo.TCOMPANY.COMPANY, 
	dbo.TASSESSMENTSCORE.SCORE, 
	dbo.TCONTRACT.CONTRACT, 
	dbo.TCRITERIONCLASS.CRITERIONCLASS, 
	dbo.TPERSON.DISPLAYNAME, 
	dbo.TTENDERER.TENDERERID, 
	dbo.TCONTRACT.CONTRACTID, 
	dbo.TCOMPANY.COMPANYID, 
	dbo.TPERSON.PERSONID, 
	dbo.TCONTRACT.CONTRACTNUMBER
FROM dbo.TASSESSMENTCRITERION 
INNER JOIN dbo.TASSESSMENTOBJECT 
INNER JOIN dbo.TASSESSMENT 
	ON dbo.TASSESSMENTOBJECT.ASSESSMENTID = dbo.TASSESSMENT.ASSESSMENTID 
	ON dbo.TASSESSMENTCRITERION.ASSESSMENTID = dbo.TASSESSMENT.ASSESSMENTID 
INNER JOIN dbo.TEVALUATIONTYPE ON dbo.TASSESSMENT.EVALUATIONTYPEID = dbo.TEVALUATIONTYPE.EVALUATIONTYPEID 
LEFT OUTER JOIN	dbo.TUSER 
INNER JOIN dbo.TEMPLOYEE ON dbo.TUSER.EMPLOYEEID = dbo.TEMPLOYEE.EMPLOYEEID 
INNER JOIN dbo.TPERSON 
	ON dbo.TEMPLOYEE.PERSONID = dbo.TPERSON.PERSONID 
	ON dbo.TASSESSMENT.USERID_OWNER = dbo.TUSER.USERID 
LEFT OUTER JOIN	dbo.TASSESSMENTTEMPLATETYPE 
INNER JOIN dbo.TCRITERION_TEMPLATE 
INNER JOIN dbo.TASSESSMENT_TEMPLATE 
	ON dbo.TCRITERION_TEMPLATE.ASSESSMENTTEMPLATEID = dbo.TASSESSMENT_TEMPLATE.ASSESSMENTTEMPLATEID 
	ON dbo.TASSESSMENTTEMPLATETYPE.ASSESSMENTTEMPLATETYPEID = dbo.TASSESSMENT_TEMPLATE.ASSESSMENTTEMPLATETYPEID 
	ON dbo.TASSESSMENT.ASSESSMENTTEMPLATEID = dbo.TASSESSMENT_TEMPLATE.ASSESSMENTTEMPLATEID 
LEFT OUTER JOIN	dbo.TCONTRACT 
INNER JOIN dbo.TTENDERER 
	ON dbo.TCONTRACT.CONTRACTID = dbo.TTENDERER.CONTRACTID 
	ON dbo.TASSESSMENTOBJECT.ASSESSEDOBJECTID = dbo.TTENDERER.TENDERERID 
		AND TASSESSMENTOBJECT.ASSESSEDOBJECTTYPEID = (SELECT TOP 1 OBJECTTYPEID FROM TOBJECTTYPE WHERE FIXED = 'TENDERER')
LEFT OUTER JOIN	dbo.TCOMPANY ON dbo.TASSESSMENTOBJECT.ASSESSEDOBJECTID = dbo.TCOMPANY.COMPANYID AND TASSESSMENTOBJECT.ASSESSEDOBJECTTYPEID = (SELECT TOP 1 OBJECTTYPEID FROM TOBJECTTYPE WHERE FIXED = 'COMPANY') 
LEFT OUTER JOIN dbo.TCRITERIONCLASS 
INNER JOIN dbo.TCRITERIONTYPE 
	ON dbo.TCRITERIONCLASS.CRITERIONCLASSID = dbo.TCRITERIONTYPE.CRITERIONCLASSID 
	ON dbo.TASSESSMENTCRITERION.CRITERIONTYPEID = dbo.TCRITERIONTYPE.CRITERIONTYPEID 
LEFT OUTER JOIN dbo.TASSESSMENTSCORE ON dbo.TASSESSMENTCRITERION.ASSESSMENTCRITERIONID = dbo.TASSESSMENTSCORE.ASSESSMENTCRITERIONID 
	AND dbo.TASSESSMENTOBJECT.ASSESSMENTOBJECTID = dbo.TASSESSMENTSCORE.ASSESSMENTOBJECTID
WHERE     
	(dbo.TASSESSMENTCRITERION.PARENTID IS NULL) 
	AND (dbo.TCRITERION_TEMPLATE.PARENTID IS NULL) 
	AND  (dbo.TEVALUATIONTYPE.FIXED = 'TENDER_PREQUALIFICATION')
ORDER BY 
	dbo.TASSESSMENT.ASSESSMENTID


GO
/****** Object:  View [dbo].[VPRODUCTGROUP_IN_OBJECT_GENERIC]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VPRODUCTGROUP_IN_OBJECT_GENERIC]
AS
SELECT     dbo.TPRODUCTGROUP.PRODUCTGROUPID, dbo.TPRODUCTGROUP.PRODUCTGROUP, dbo.TPRODUCTGROUP.PRODUCTGROUPNOMENCLATUREID, 
                      dbo.TPRODUCTGROUP.PRODUCTGROUPCODE, dbo.TPRODUCTGROUP.EXTERNALNUMBER, 
                      dbo.TPRODUCTGROUPNOMENCLATURE.PRODUCTGROUPNOMENCLATURE, dbo.TPRODUCTGROUPNOMENCLATURE.FIXED, 
                      dbo.TPRODUCTGROUP_IN_OBJECT.PRODUCTGROUP_IN_OBJECTID, dbo.TPRODUCTGROUP_IN_OBJECT.OBJECTTYPEID, 
                      dbo.TPRODUCTGROUP_IN_OBJECT.OBJECTID, dbo.TPRODUCTGROUP_IN_OBJECT.MIK_VALID
FROM         dbo.TPRODUCTGROUP INNER JOIN
                      dbo.TPRODUCTGROUP_IN_OBJECT ON 
                      dbo.TPRODUCTGROUP.PRODUCTGROUPID = dbo.TPRODUCTGROUP_IN_OBJECT.PRODUCTGROUPID INNER JOIN
                      dbo.TPRODUCTGROUPNOMENCLATURE ON 
                      dbo.TPRODUCTGROUP.PRODUCTGROUPNOMENCLATUREID = dbo.TPRODUCTGROUPNOMENCLATURE.PRODUCTGROUPNOMENCLATUREID
                      

GO
/****** Object:  View [dbo].[VPRODUCTGROUPS_IN_CONTRACT_COUNT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VPRODUCTGROUPS_IN_CONTRACT_COUNT]
AS
SELECT     dbo.TPRODUCTGROUP.PRODUCTGROUPID, dbo.TPRODUCTGROUP.PRODUCTGROUPCODE, dbo.TPRODUCTGROUP.PRODUCTGROUP, 
                      dbo.TPRODUCTGROUP.PARENTID, dbo.TPRODUCTGROUP.PRODUCTGROUPNOMENCLATUREID, dbo.TCONTRACT.PUBLISH, 
                      COUNT(dbo.TCONTRACT.CONTRACTID) AS CONTRACTCOUNT, dbo.TPRODUCTGROUP.MIK_VALID
FROM         dbo.TPROD_GROUP_IN_CONTRACT INNER JOIN
                      dbo.TPRODUCTGROUP ON dbo.TPROD_GROUP_IN_CONTRACT.PRODUCTGROUPID = dbo.TPRODUCTGROUP.PRODUCTGROUPID INNER JOIN
                      dbo.TCONTRACT ON dbo.TPROD_GROUP_IN_CONTRACT.CONTRACTID = dbo.TCONTRACT.CONTRACTID
GROUP BY dbo.TPRODUCTGROUP.PRODUCTGROUPID, dbo.TPRODUCTGROUP.PRODUCTGROUPNOMENCLATUREID, 
                      dbo.TPRODUCTGROUP.PRODUCTGROUP, dbo.TPRODUCTGROUP.PARENTID, dbo.TPRODUCTGROUP.PRODUCTGROUPCODE, 
                      dbo.TCONTRACT.PUBLISH, dbo.TPRODUCTGROUP.MIK_VALID



GO
/****** Object:  View [dbo].[VRCompanyAddress]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- VRCompanyAddress for TheVendor.Reporting.Company.Address 

CREATE VIEW [dbo].[VRCompanyAddress] AS
SELECT 
dbo.TCOMPANYADDRESS.COMPANYADDRESSID,
dbo.TCOMPANYADDRESS.ADDRESSTYPEID,
dbo.TCOMPANYADDRESS.COMPANYID,
dbo.TCOMPANYADDRESS.ADDRESSLINE1,
dbo.TCOMPANYADDRESS.ADDRESSLINE2,
dbo.TCOMPANYADDRESS.ADDRESSLINE3,
dbo.TCOMPANYADDRESS.ADDRESSLINE4,
dbo.TCOMPANYADDRESS.ADDRESSLINE5,
dbo.TCOMPANYADDRESS.PHONE,
dbo.TCOMPANYADDRESS.FAX,
dbo.TCOMPANYADDRESS.WWW,
dbo.TCOMPANYADDRESS.EMAIL,
dbo.TCOMPANYADDRESS.COUNTRYID,
dbo.TCOMPANYADDRESS.MIK_DEFAULT,

TADDRESSTYPE.AddressType, TADDRESSTYPE.[Description], TADDRESSTYPE.FIXED, TADDRESSTYPE.MIK_SEQUENCE
FROM TCOMPANYADDRESS
INNER JOIN TADDRESSTYPE ON (TCOMPANYADDRESS.ADDRESSTYPEID = TADDRESSTYPE.ADDRESSTYPEID)

GO
/****** Object:  View [dbo].[VRCompanyProductAndServiceGroups]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- VRCompanyProductAndServiceGroups for TheVendor.Reporting.Company.ProductAndServiceGroups 

CREATE VIEW [dbo].[VRCompanyProductAndServiceGroups] AS
SELECT DISTINCT
	TPRODUCTGROUPNOMENCLATURE.PRODUCTGROUPNOMENCLATURE, 
	dbo.TPRODUCTGROUP.PRODUCTGROUPID,
	dbo.TPRODUCTGROUP.PRODUCTGROUP,
	dbo.TPRODUCTGROUP.PARENTID,
	dbo.TPRODUCTGROUP.PRODUCTGROUPNOMENCLATUREID,
	dbo.TPRODUCTGROUP.MIK_VALID,
	dbo.TPRODUCTGROUP.PRODUCTGROUPCODE,
	dbo.TPRODUCTGROUP.EXTERNALNUMBER
FROM TPRODUCTGROUP 
INNER JOIN TPRODUCTGROUPNOMENCLATURE ON (TPRODUCTGROUP.PRODUCTGROUPNOMENCLATUREID = TPRODUCTGROUPNOMENCLATURE.PRODUCTGROUPNOMENCLATUREID)
INNER JOIN TPROD_GROUP_IN_COMPANY ON (TPROD_GROUP_IN_COMPANY.PRODUCTGROUPID = TPRODUCTGROUP.PRODUCTGROUPID)



GO
/****** Object:  View [dbo].[VRContractProductAndServiceGroups]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--VRContractProductAndServiceGroups for TheVendor.Reporting.Contract.ProductAndServiceGroups 

CREATE VIEW [dbo].[VRContractProductAndServiceGroups] AS
SELECT 
	TPROD_GROUP_IN_CONTRACT.CONTRACTID, 
	TPRODUCTGROUPNOMENCLATURE.PRODUCTGROUPNOMENCLATURE, 
	dbo.TPRODUCTGROUP.PRODUCTGROUPID,
	dbo.TPRODUCTGROUP.PRODUCTGROUP,
	dbo.TPRODUCTGROUP.PARENTID,
	dbo.TPRODUCTGROUP.PRODUCTGROUPNOMENCLATUREID,
	dbo.TPRODUCTGROUP.MIK_VALID,
	dbo.TPRODUCTGROUP.PRODUCTGROUPCODE,
	dbo.TPRODUCTGROUP.EXTERNALNUMBER
FROM TPRODUCTGROUP 
INNER JOIN TPRODUCTGROUPNOMENCLATURE ON (TPRODUCTGROUP.PRODUCTGROUPNOMENCLATUREID = TPRODUCTGROUPNOMENCLATURE.PRODUCTGROUPNOMENCLATUREID)
INNER JOIN TPROD_GROUP_IN_CONTRACT ON (TPROD_GROUP_IN_CONTRACT.PRODUCTGROUPID = TPRODUCTGROUP.PRODUCTGROUPID)



GO
/****** Object:  View [dbo].[VRDepartmentroleInObject]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VRDepartmentroleInObject] AS
SELECT DISTINCT 
	tdepartmentrole_in_object.objectid, 
	tdepartment.department, 
	tdepartment.department_code, 
	trole.role
FROM 	tdepartmentrole_in_object
INNER JOIN tdepartment ON (tdepartmentrole_in_object.departmentid = tdepartment.departmentid)
INNER JOIN trole ON (tdepartmentrole_in_object.roleid = trole.roleid)
INNER JOIN tobjecttype ON (tdepartmentrole_in_object.objecttypeid = tobjecttype.objecttypeid)
WHERE tobjecttype.fixed = 'CONTRACT' and tdepartmentrole_in_object.objectid >= 0



GO
/****** Object:  View [dbo].[VREPORTPROCESSPLAN]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VREPORTPROCESSPLAN]
AS
SELECT     WPP.WorkflowProcessPlanID, WP.WorkflowProcessID, WP.WorkflowDefinitionID, WPP.WorkflowProcessPlan, WP.WorkflowProcess, 
                      WPP.Description, WPP.PlannedTimeStarted, WPP.PlannedTimeFinished, WP.TimeStarted, WP.TimeFinished, WPP.Duration, 
                      WU1.Description AS StartedByUser, WU2.Description AS ResponsibleUser, WU3.Description AS OwnerUser, WPP.ObjectID, WPP.ObjectTypeID, 
                      TS.STATUS
FROM         dbo.TWorkflowProcessPlan WPP INNER JOIN
                      dbo.TWorkflowProcess WP ON WPP.WorkflowProcessPlanID = WP.WorkflowProcessPlanID LEFT OUTER JOIN
                      dbo.TWorkflowUser WU1 ON WP.StartedByUserId = WU1.WorkflowUserId LEFT OUTER JOIN
                      dbo.TWorkflowUser WU2 ON WPP.ResponsibleUserID = WU2.WorkflowUserId LEFT OUTER JOIN
                      dbo.TWorkflowUser WU3 ON WPP.OwnerUserID = WU3.WorkflowUserId LEFT OUTER JOIN
                      dbo.TSTATUS TS ON WP.STATUSID = TS.STATUSID


GO
/****** Object:  View [dbo].[VRExtendedContract]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VRExtendedContract]
AS
SELECT DISTINCT 
                      dbo.TCONTRACT.CONTRACTID, dbo.TCONTRACT.CONTRACTNUMBER, dbo.TCONTRACT.CONTRACT, dbo.TCONTRACT.CONTRACTDATE, 
                      dbo.TCONTRACT.STARTDATE, dbo.TCONTRACT.AWARDDATE, dbo.TCONTRACT.EXPIRYDATE, dbo.TCONTRACT.REV_EXPIRYDATE, 
                      dbo.TCONTRACT.COMMENTS, dbo.TCONTRACT.STATUSID, dbo.TCONTRACT.REVIEWDATE, dbo.TCONTRACT.DEFINEDENDDATE, 
                      dbo.TCONTRACT.SIGNEDDATE, TAMOUNT_2.Amount AS LumpSumAmount, TAMOUNT_3.Amount AS ProvisionalSumAmount, 
                      TAMOUNT_4.Amount AS AwardValueAmount, TAMOUNT_5.Amount AS EstimatedValueAmount, TAMOUNT_6.Amount, 
                      TAMOUNT_7.Amount AS EscalationAmount, TAMOUNT_8.Amount AS ContingencyAmount, TAMOUNT_9.Amount AS ApprovedValueAmount, 
                      TAMOUNT_10.Amount AS InvoicedValueAmount, TAMOUNT_11.Amount AS BankGuaranteeAmount, 
                      TAMOUNT_12.Amount AS ParentCompanyGuaranteeAmount, TAMOUNT_15.Amount AS InsuranceAmount, 
                      TAMOUNT_14.Amount AS TransportationAmount, TAMOUNT_13.Amount AS TrendAmount, dbo.TAMOUNT.Amount AS OtherExpensesAmount, 
                      dbo.TSTRATEGYTYPE.STRATEGYTYPE, dbo.TAGREEMENT_TYPE.AGREEMENT_TYPE, dbo.TCONTRACTRELATION.CONTRACTRELATION, 
                      dbo.TLANGUAGE.MIK_LANGUAGE, TPERSON_1.DISPLAYNAME AS Owner, dbo.TPERSON.DISPLAYNAME AS TechCordinator, 
                      dbo.TCOMPANY.COMPANY, dbo.TCOMPANY.COMPANYNO, TPERSON_2.DISPLAYNAME AS Executor, TCURRENCY_1.CURRENCY_CODE, 
                      TCURRENCY_2.CURRENCY_CODE AS LumpSumCurrency, TCURRENCY_3.CURRENCY_CODE AS ProvisionalSumCurrency, 
                      TCURRENCY_4.CURRENCY_CODE AS AwardValueCurrency, TCURRENCY_5.CURRENCY_CODE AS EstimatedValueCurrency, 
                      TCURRENCY_6.CURRENCY_CODE AS Expr1, TCURRENCY_7.CURRENCY_CODE AS EscalationCurrency, 
                      TCURRENCY_8.CURRENCY_CODE AS ContingencyCurrency, TCURRENCY_9.CURRENCY_CODE AS ApprovedValueCurrency, 
                      TCURRENCY_11.CURRENCY_CODE AS BankGuaranteeCurrency, TCURRENCY_12.CURRENCY_CODE AS ParentCompanyGuaranteeCurrency, 
                      TCURRENCY_13.CURRENCY_CODE AS TrendCurrency, TCURRENCY_14.CURRENCY_CODE AS TransportationCurrency, 
                      TCURRENCY_15.CURRENCY_CODE AS InsuranceCurrency, TCURRENCY_10.CURRENCY_CODE AS Expr2, 
                      TCURRENCY_CONTRACT.CURRENCY_CODE AS [Contract currency], dbo.TCONTRACT.APPROVALSTATUSID AS ApprovalStatusID
                      ,PERSON_CC.DISPLAYNAME AS [Commercial coordinator contact]
                      ,dbo.TDEPARTMENT.DEPARTMENT AS [Commercial coordinator department]
FROM         dbo.TCURRENCY TCURRENCY_12 RIGHT OUTER JOIN
                      dbo.TCURRENCY TCURRENCY_1 RIGHT OUTER JOIN
                      dbo.TCURRENCY TCURRENCY_15 RIGHT OUTER JOIN
                      dbo.TAMOUNT TAMOUNT_7 RIGHT OUTER JOIN
                      dbo.TAMOUNT TAMOUNT_8 RIGHT OUTER JOIN
                      dbo.TAMOUNT TAMOUNT_14 RIGHT OUTER JOIN
                      dbo.TAMOUNT TAMOUNT_9 RIGHT OUTER JOIN
                      dbo.TAMOUNT TAMOUNT_3 RIGHT OUTER JOIN
                      dbo.TAMOUNT TAMOUNT_15 RIGHT OUTER JOIN
                      dbo.TAMOUNT TAMOUNT_4 RIGHT OUTER JOIN
                      dbo.TAMOUNT TAMOUNT_10 LEFT OUTER JOIN
                      dbo.TCURRENCY TCURRENCY_10 ON TAMOUNT_10.CurrencyId = TCURRENCY_10.CURRENCYID RIGHT OUTER JOIN
                      dbo.TAMOUNT TAMOUNT_6 RIGHT OUTER JOIN
                      dbo.TAMOUNT TAMOUNT_11 RIGHT OUTER JOIN
                      dbo.TCURRENCY TCURRENCY_CONTRACT RIGHT OUTER JOIN
                      dbo.TCONTRACT ON TCURRENCY_CONTRACT.CURRENCYID = dbo.TCONTRACT.CURRENCYID ON 
                      TAMOUNT_11.AmountId = dbo.TCONTRACT.BankGuaranteeAmountID ON 
                      TAMOUNT_6.AmountId = dbo.TCONTRACT.SumExpenditureAmountID LEFT OUTER JOIN
                      dbo.TAMOUNT TAMOUNT_12 ON dbo.TCONTRACT.ParentCompanyGuaranteeAmountID = TAMOUNT_12.AmountId LEFT OUTER JOIN
                      dbo.TAMOUNT TAMOUNT_5 ON dbo.TCONTRACT.EstimatedValueAmountID = TAMOUNT_5.AmountId ON 
                      TAMOUNT_10.AmountId = dbo.TCONTRACT.InvoicedValueAmountID ON TAMOUNT_4.AmountId = dbo.TCONTRACT.AwardValueAmountID ON 
                      TAMOUNT_15.AmountId = dbo.TCONTRACT.InsuranceAmountID ON TAMOUNT_3.AmountId = dbo.TCONTRACT.ProvisionalSumAmountID ON 
                      TAMOUNT_9.AmountId = dbo.TCONTRACT.ApprovedValueAmountID ON TAMOUNT_14.AmountId = dbo.TCONTRACT.TransportationAmountID ON 
                      TAMOUNT_8.AmountId = dbo.TCONTRACT.ContingencyAmountID LEFT OUTER JOIN
                      dbo.TAMOUNT ON dbo.TCONTRACT.OtherExpensesAmountID = dbo.TAMOUNT.AmountId LEFT OUTER JOIN
                      dbo.TAMOUNT TAMOUNT_2 ON dbo.TCONTRACT.LumpSumAmountID = TAMOUNT_2.AmountId ON 
                      TAMOUNT_7.AmountId = dbo.TCONTRACT.EscalationAmountID LEFT OUTER JOIN
                      dbo.TAMOUNT TAMOUNT_13 ON dbo.TCONTRACT.TrendAmountID = TAMOUNT_13.AmountId ON 
                      TCURRENCY_15.CURRENCYID = TAMOUNT_15.CurrencyId ON TCURRENCY_1.CURRENCYID = dbo.TAMOUNT.CurrencyId LEFT OUTER JOIN
                      dbo.TCURRENCY TCURRENCY_14 ON TAMOUNT_14.CurrencyId = TCURRENCY_14.CURRENCYID LEFT OUTER JOIN
                      dbo.TCURRENCY TCURRENCY_13 ON TAMOUNT_13.CurrencyId = TCURRENCY_13.CURRENCYID ON 
                      TCURRENCY_12.CURRENCYID = TAMOUNT_12.CurrencyId LEFT OUTER JOIN
                      dbo.TCURRENCY TCURRENCY_11 ON TAMOUNT_11.CurrencyId = TCURRENCY_11.CURRENCYID LEFT OUTER JOIN
                      dbo.TCURRENCY TCURRENCY_9 ON TAMOUNT_9.CurrencyId = TCURRENCY_9.CURRENCYID LEFT OUTER JOIN
                      dbo.TCURRENCY TCURRENCY_8 ON TAMOUNT_8.CurrencyId = TCURRENCY_8.CURRENCYID LEFT OUTER JOIN
                      dbo.TCURRENCY TCURRENCY_7 ON TAMOUNT_7.CurrencyId = TCURRENCY_7.CURRENCYID LEFT OUTER JOIN
                      dbo.TCURRENCY TCURRENCY_5 ON TAMOUNT_5.CurrencyId = TCURRENCY_5.CURRENCYID LEFT OUTER JOIN
                      dbo.TCURRENCY TCURRENCY_6 ON TAMOUNT_6.CurrencyId = TCURRENCY_6.CURRENCYID LEFT OUTER JOIN
                      dbo.TCURRENCY TCURRENCY_3 ON TAMOUNT_3.CurrencyId = TCURRENCY_3.CURRENCYID LEFT OUTER JOIN
                      dbo.TCURRENCY TCURRENCY_4 ON TAMOUNT_4.CurrencyId = TCURRENCY_4.CURRENCYID LEFT OUTER JOIN
                      dbo.TCURRENCY TCURRENCY_2 ON TAMOUNT_2.CurrencyId = TCURRENCY_2.CURRENCYID LEFT OUTER JOIN
                      dbo.TCOMPANY 
					  ON dbo.TCOMPANY.COMPANYID = dbo.udf_get_companyid(dbo.TCONTRACT.CONTRACTID)
					  LEFT OUTER JOIN
                      dbo.TLANGUAGE ON dbo.TCONTRACT.LANGUAGEID = dbo.TLANGUAGE.LANGUAGEID LEFT OUTER JOIN
                      dbo.TCONTRACTRELATION ON dbo.TCONTRACT.CONTRACTRELATIONID = dbo.TCONTRACTRELATION.CONTRACTRELATIONID LEFT OUTER JOIN
                      dbo.TAGREEMENT_TYPE ON dbo.TCONTRACT.AGREEMENT_TYPEID = dbo.TAGREEMENT_TYPE.AGREEMENT_TYPEID LEFT OUTER JOIN
                      dbo.TSTRATEGYTYPE ON dbo.TCONTRACT.STRATEGYTYPEID = dbo.TSTRATEGYTYPE.STRATEGYTYPEID 
	LEFT OUTER JOIN dbo.TPERSON TPERSON_2 
		RIGHT OUTER JOIN dbo.TEMPLOYEE TEMPLOYEE_2 ON TPERSON_2.PERSONID = TEMPLOYEE_2.PERSONID 
		RIGHT OUTER JOIN dbo.TUSER ON TEMPLOYEE_2.EMPLOYEEID = dbo.TUSER.EMPLOYEEID 
		ON dbo.TCONTRACT.EXECUTORID = dbo.TUSER.USERID 
	LEFT OUTER JOIN dbo.TEMPLOYEE TEMPLOYEE_1 ON dbo.TCONTRACT.TECHCOORDINATORID = TEMPLOYEE_1.EMPLOYEEID 
	LEFT OUTER JOIN dbo.TPERSON TPERSON_1 ON TEMPLOYEE_1.PERSONID = TPERSON_1.PERSONID 
	LEFT OUTER JOIN dbo.TEMPLOYEE 
		LEFT OUTER JOIN dbo.TPERSON ON dbo.TEMPLOYEE.PERSONID = dbo.TPERSON.PERSONID 
		ON dbo.TCONTRACT.OWNERID = dbo.TEMPLOYEE.EMPLOYEEID
	-- get Commercial coordinator contact of person
	LEFT OUTER JOIN dbo.TPERSON as PERSON_CC 
		LEFT OUTER JOIN dbo.TROLE ROLE_CCP ON ROLE_CCP.FIXED = N'COMMERCIAL_CO_ORDINATOR'
		LEFT OUTER JOIN dbo.TPERSONROLE_IN_OBJECT
			ON dbo.TPERSONROLE_IN_OBJECT.ROLEID = ROLE_CCP.ROLEID
			AND dbo.TPERSONROLE_IN_OBJECT.PERSONID = PERSON_CC.PERSONID
	ON dbo.TPERSONROLE_IN_OBJECT.OBJECTID = dbo.TCONTRACT.CONTRACTID
	-- get Commercial coordinator department
	LEFT OUTER JOIN dbo.TDEPARTMENT 
		LEFT JOIN dbo.TROLE ROLE_CC ON ROLE_CC.FIXED = N'COMMERCIAL_CO_ORDINATOR' 
		LEFT OUTER JOIN dbo.TDEPARTMENTROLE_IN_OBJECT ON dbo.TDEPARTMENTROLE_IN_OBJECT.ROLEID = ROLE_CC.ROLEID 
			AND dbo.TDEPARTMENTROLE_IN_OBJECT.DEPARTMENTID = dbo.TDEPARTMENT.DEPARTMENTID
	ON dbo.TDEPARTMENTROLE_IN_OBJECT.OBJECTID = dbo.TCONTRACT.CONTRACTID 



GO
/****** Object:  View [dbo].[VRFX]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VRFX]
AS
SELECT	TRFX.RFXID				,
	TRFX.RFX					,
	TRFX.SHORTDESCRIPTION		,
	TRFX.LONGDESCRIPTION 		,
	TRFX.INTERNALNUMBER  		,
	TRFX.EXTERNALNUMBER  		,
	TRFX.OTHERNUMBER     		,
	TRFX.TIMEZONEDISPLAYNAME  	,
	TRFX.TIMEZONEUTCOFFSET    	,
	TRFX.TIMEZONEINDEX        	,
	TRFX.PUBLICATIONDATE      	,
	TRFX.CONFIRMINTERESTDATE  	,
	TRFX.CLARIFICATIONDEADLINE	,
	TRFX.RESPONSEDEADLINE     	,
	TRFX.FORMALOPENINGDATE    	,
	TRFX.FORMALOPENINGPLACE   	,
	TRFX.MINIMUMTENDERVALIDITY	,
	TRFX.PLANNEDAWARDDATE     	,
	TRFX.PLANNEDEFFECTIVEDATE 	,
	TRFX.PLANNEDEXPIRYDATE    	,
	TRFX.FRAMEWORKCONTRACT    	,
	TRFX.RFXURL               	,
	TRFX.RFXINFOEMAIL         	,
	TRFX.STATUSID             	,
	TRFX.RFXTYPEID            	,
	TRFX.AWARDTOMOSTATTRACTIVE	,
	TRFX.INPRIORITIZEDSEQUENCE	,
	TRFX.AWARDCRITERIA        	,
	TRFX.STRATEGYTYPEID       	,
	TRFX.AGREEMENT_TYPEID     	,
	TRFX.REGULATIONSID        	,
	TRFX.WORKLOCATIONID       	,
	TRFX.CURRENCYID           	,
	TRFX.PAYMENTFORMCLAUSETEXTID 	,
	TRFX.MIK_VALID               	,
	dbo.TRFXTYPE.RFXTYPE		,
	dbo.TWORKLOCATION.WORKLOCATION	, 
	dbo.TREGULATIONS.REGULATIONS	,
	dbo.TSTATUS.STATUS		,
	dbo.TSTRATEGYTYPE.STRATEGYTYPE	,
	dbo.TAGREEMENT_TYPE.AGREEMENT_TYPE,
	dbo.TCURRENCY.CURRENCY		,
	TRFX.CONTRACTID,
	TRFX.ISOPEN,
	TRFX.ISPUBLISHED,
	TRFX.BIDLOCKED,
	TRFX.BIDOPENINGCOUNTDOWN,
	TRFX.ACTIVATEEXTERNALUSERS,
	CASE WHEN (
		SELECT  TOP 1
				dbo.TTENDERER.CONTRACTID
		  FROM  dbo.TTENDERER
		 WHERE  dbo.TTENDERER.CONTRACTID	IS NOT NULL
		   AND  dbo.TTENDERER.RFXID			= dbo.TRFX.RFXID
		) IS NULL THEN 0
		ELSE 1
	END AS IsCurrent,
	TRFX.TimeZoneIdentifier,
	TRFX.EspdRequired
FROM	dbo.TRFX 
LEFT	OUTER JOIN	dbo.TREGULATIONS 
	ON	dbo.TRFX.REGULATIONSID            = dbo.TREGULATIONS.REGULATIONSID
LEFT	OUTER JOIN	dbo.TSTATUS 
	ON	dbo.TRFX.STATUSID                 = dbo.TSTATUS.STATUSID 
LEFT OUTER JOIN		dbo.TWORKLOCATION 
	ON	dbo.TRFX.WORKLOCATIONID           = dbo.TWORKLOCATION.WORKLOCATIONID 
LEFT OUTER JOIN		dbo.TCURRENCY 
	ON	dbo.TRFX.CURRENCYID               = dbo.TCURRENCY.CURRENCYID 
LEFT OUTER JOIN		dbo.TAGREEMENT_TYPE 
	ON	dbo.TRFX.AGREEMENT_TYPEID         = dbo.TAGREEMENT_TYPE.AGREEMENT_TYPEID 
LEFT OUTER JOIN		dbo.TSTRATEGYTYPE 
	ON	dbo.TRFX.STRATEGYTYPEID           = dbo.TSTRATEGYTYPE.STRATEGYTYPEID 
LEFT OUTER JOIN dbo.TRFXTYPE 
	ON	dbo.TRFX.RFXTYPEID                = dbo.TRFXTYPE.RFXTYPEID

GO
/****** Object:  View [dbo].[VRFXDOCUMENT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VRFXDOCUMENT]
AS
SELECT     *
FROM         TDOCUMENT


GO
/****** Object:  View [dbo].[VRFXINTEREST]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*----------------------------------------------------------------------------*\
FIX:
	  Date: 2015-11-11
	  Purpose: Fix of [PON-778-8028] No access to one particular contact
	  Author: Egor Yelgeshin

ORIGINAL:
      Date:       2011-03-04
      Purpose:    Bug 2039 fixed. Interested party country was empty if it was not connected to a company
      Author:     Ilya Chernomordik
\*----------------------------------------------------------------------------*/

CREATE VIEW [dbo].[VRFXINTEREST] AS
SELECT RI.RFXINTERESTID,
             RI.RFXID,
             RI.RFXINTERESTEDPARTYID,
             RI.PRIMARYCOMPANYCONTACTUSERID,
			 RI.CONFIRMEDINTEREST,
             RI.CONFIRMEDINTERESTDATE,
             CC.CompanyContactID AS PRIMARYCOMPANYCONTACTID,
             P.PERSONID AS PRIMARYCOMPANYCONTACTPERSONID,
             CMP.COMPANYID,
             ISNULL(IP.COMPANYNAME, CMP.COMPANY) AS COMPANY,
             ISNULL(IP.COMPANYNO, CMP.COMPANYNO) AS COMPANYNO,
             ISNULL(IP.FIRSTNAME, P.FIRSTNAME) AS FIRSTNAME,
             ISNULL(IP.LASTNAME, P.LASTNAME) AS LASTNAME,
             ISNULL(IP.EMAIL, P.EMAIL) AS EMAIL,
             ISNULL(IP.PHONE, P.PHONE1) AS PHONE,
             CASE 
					WHEN CNT.COUNTRYID IS NOT NULL AND CNT.COUNTRYID > 0 THEN CNT.COUNTRY 
					WHEN IP.COUNTRY IS NOT NULL THEN IP.COUNTRY 
					ELSE NULL 
					END AS COUNTRY,
             ISNULL(IP.REGISTERED, CMP.CREATEDATE) AS REGISTERED,
             RISL.STATUSID,
             S.STATUS,
             S.FIXED,
             RISL.LOGDATE,
			 RISL.COMMENT,
             (
             SELECT COUNT(*)
               FROM TCOMPANY_IN_COMPANYREGISTRY             CR
             WHERE CR.COMPANYID                            = CMP.COMPANYID
             )                                              AS INCOMPANYREGISTRYCOUNT,
             CC.MIK_VALID AS COMPANYCONTACT_VALID
  FROM TRFXINTEREST                      RI
  LEFT OUTER
  JOIN TRFXINTERESTEDPARTY               IP
       ON     RI.RFXINTERESTEDPARTYID           = IP.RFXINTERESTEDPARTYID
  LEFT OUTER
  JOIN TUSER                                   U
       ON     RI.PRIMARYCOMPANYCONTACTUSERID      = U.USERID
  LEFT OUTER
  JOIN TPERSON                                        P
       ON     U.PERSONID                              = P.PERSONID
  LEFT OUTER
  JOIN TCOMPANY                                CMP
       ON     RI.COMPANYID                      = CMP.COMPANYID
  LEFT OUTER
  JOIN TCompanyContact                         CC
       ON     CC.PersonID                             = U.PersonID
   AND CC.CompanyID                      = RI.CompanyID      
  LEFT OUTER
  JOIN TCOMPANYADDRESS                         CA
       ON     CMP.COMPANYID                     = CA.COMPANYID
   AND CA.ADDRESSTYPEID                  = (
             SELECT AT.ADDRESSTYPEID
               FROM TADDRESSTYPE        AT
             WHERE AT.FIXED                   = 'MAINADDRESS'
             )
  LEFT OUTER
  JOIN TCOUNTRY                                CNT
       ON     CA.COUNTRYID                      = CNT.COUNTRYID
  LEFT OUTER
  JOIN (	SELECT	*
			FROM	TRFXINTERESTSTATUSLOG	X
			WHERE	X.RFXINTERESTSTATUSLOGID =
				(
					SELECT MAX(Y.RFXINTERESTSTATUSLOGID)
					FROM	TRFXINTERESTSTATUSLOG	Y
					WHERE	Y.LOGDATE = (
								SELECT MAX(Log2.LOGDATE)
								FROM TRFXINTERESTSTATUSLOG             Log2
								WHERE Y.RFXINTERESTID                  = Log2.RFXINTERESTID
								)	
							AND Y.RFXINTERESTID = X.RFXINTERESTID
				)
		)	RISL 
		ON	RISL.RFXINTERESTID = RI.RFXINTERESTID  
  LEFT OUTER
  JOIN TSTATUS                                        S
       ON     RISL.STATUSID                     = S.STATUSID


GO
/****** Object:  View [dbo].[VRFXQUESTIONANDANSWER]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VRFXQUESTIONANDANSWER]

AS

SELECT 
		QNA.RFXQUESTIONANDANSWERID,
		CASE WHEN OT.FIXED = 'RFXINTEREST'
			THEN RI.RFXINTERESTID
			ELSE NULL
		END											AS RFXINTERESTID,
		ORIGINALQUESTIONS.STATEMENTID				AS ORIGINALQUESTIONSTATEMENTID,
		ORIGINALQUESTIONS.[STATEMENT]				AS ORIGINALQUESTION,
		REPHRASEDQUESTIONS.STATEMENTID				AS ANONYMIZEDQUESTIONSTATEMENTID,
		REPHRASEDQUESTIONS.[STATEMENT]				AS ANONYMIZEDQUESTION,
		ORIGINALQUESTIONS.STATEMENTDATETIME			AS QUESTIONDATETIME,
		ANSWERS.STATEMENTID							AS ANSWERSTATEMENTID,
		ANSWERS.[STATEMENT]							AS ANSWER,
		ANSWERS.STATEMENTDATETIME					AS ANSWERDATETIME,
		CASE 
			WHEN ANSWERS.ISPUBLISHED IS NULL
				THEN CAST(0 AS BIT)  
			ELSE ANSWERS.ISPUBLISHED
		END											AS ISPUBLISHED,						
		CASE 
			WHEN ANSWERS.ISPRIVATE IS NULL
				THEN CAST(0 AS BIT) 
			ELSE ANSWERS.ISPRIVATE
		END											AS PUBLISH_TO_ASKER_ONLY,
		ORIGINALQUESTIONS.ISCANCELLED				AS IS_CANCELED,
		QNA.MIK_SEQUENCE							AS MIK_SEQUENCE,
		QNA.MIK_VALID								AS MIK_VALID,
		CASE	
			WHEN OT.FIXED = 'RFXINTEREST'
				THEN RI.RFXID
			ELSE
				QNA.OBJECTID
		END											AS RFXID,
		RI.RFXINTERESTEDPARTYID,
		RI.PRIMARYCOMPANYCONTACTUSERID,
		CC.COMPANYCONTACTID							AS PRIMARYCOMPANYCONTACTID, 
		P.PERSONID,
		C.COMPANYID,
		T.TENDERERID,
		CASE
			WHEN RI.RFXINTERESTEDPARTYID IS NULL 
				THEN C.COMPANY 
			ELSE RIP.COMPANYNAME
		END							AS COMPANY, 
		CASE
			WHEN RI.RFXINTERESTEDPARTYID IS NULL
				THEN C.COMPANYNO
			ELSE RIP.COMPANYNO
		END							AS COMPANYNO,
		CASE
			WHEN RI.RFXINTERESTEDPARTYID IS NULL 
				THEN P.FIRSTNAME
			ELSE RIP.FIRSTNAME
		END							AS FIRSTNAME, 
		CASE
			WHEN RI.RFXINTERESTEDPARTYID IS NULL
				THEN P.LASTNAME
			ELSE RIP.LASTNAME
		END							AS LASTNAME,
		CASE
			WHEN RI.RFXINTERESTEDPARTYID IS NULL
				THEN P.EMAIL
			ELSE RIP.EMAIL
		END							AS EMAIL ,
		QDoc.DOCUMENTID				AS QUESTIONDOCUMENTID,
		QDoc.OBJECTTYPEID			AS QDOCOBJECTTYPEID,
		QDoc.OBJECTID				AS QDOCOBJECTID,
		QDoc.DOCUMENT				AS QDOCDOCUMENT,
		QDoc.[DESCRIPTION]			AS QDOCDESCRIPTION,
		ADoc.DOCUMENTID				AS ANSWERDOCUMENTID,
		ADoc.OBJECTTYPEID			AS ADOCOBJECTTYPEID,
		ADoc.OBJECTID				AS ADOCOBJECTID,
		ADoc.DOCUMENT				AS ADOCDOCUMENT,
		ADoc.[DESCRIPTION]			AS ADOCDESCRIPTION,
		QNA.REFID					AS REFID

 FROM dbo.TRFXQUESTIONANDANSWER QNA
 
	 LEFT OUTER
	 JOIN 
	 (
		SELECT	
				TSTATEMENT.STATEMENTID				AS	STATEMENTID,
				TSTATEMENT.STATEMENTTYPEID			AS	STATEMENTTYPEID,
				TSTATEMENT.[STATEMENT]				AS	[STATEMENT],
				TSTATEMENT.STATEMENTDATETIME		AS	STATEMENTDATETIME,
				TSTATEMENT.RFXQUESTIONANDANSWERID	AS	RFXQUESTIONANDANSWERID,
				TSTATEMENT.PERSONID					AS	PERSONID,
				TSTATEMENT.ISPUBLISHED				AS	ISPUBLISHED,
				TSTATEMENT.ISPRIVATE				AS	ISPRIVATE,
				TSTATEMENT.ISCANCELLED				AS	ISCANCELLED,
				TSTATEMENT.PARENTSTATEMENTID		AS	PARENTSTATEMENTID
		FROM dbo.TSTATEMENT
			 LEFT JOIN dbo.TSTATEMENTTYPE
					ON TSTATEMENT.STATEMENTTYPEID = TSTATEMENTTYPE.STATEMENTTYPEID
				 WHERE TSTATEMENTTYPE.FIXED = 'QUESTION'
			 
	 )  ORIGINALQUESTIONS
	   
	 ON QNA.RFXQUESTIONANDANSWERID = ORIGINALQUESTIONS.RFXQUESTIONANDANSWERID  
	 
	 LEFT OUTER
	 JOIN 
	 (
		SELECT	
				TSTATEMENT.STATEMENTID				AS	STATEMENTID,
				TSTATEMENT.STATEMENTTYPEID			AS	STATEMENTTYPEID,
				TSTATEMENT.[STATEMENT]				AS	[STATEMENT],
				TSTATEMENT.STATEMENTDATETIME		AS	STATEMENTDATETIME,
				TSTATEMENT.RFXQUESTIONANDANSWERID	AS	RFXQUESTIONANDANSWERID,
				TSTATEMENT.PERSONID					AS	PERSONID,
				TSTATEMENT.ISPUBLISHED				AS	ISPUBLISHED,
				TSTATEMENT.ISPRIVATE				AS	ISPRIVATE,
				TSTATEMENT.ISCANCELLED				AS	ISCANCELLED,
				TSTATEMENT.PARENTSTATEMENTID		AS	PARENTSTATEMENTID
		FROM dbo.TSTATEMENT
			 LEFT JOIN dbo.TSTATEMENTTYPE
					ON TSTATEMENT.STATEMENTTYPEID = TSTATEMENTTYPE.STATEMENTTYPEID
				 WHERE TSTATEMENTTYPE.FIXED = 'REPHRASED_QUESTION'
			 
	 )	REPHRASEDQUESTIONS
	   
	 ON QNA.RFXQUESTIONANDANSWERID = REPHRASEDQUESTIONS.RFXQUESTIONANDANSWERID

	 LEFT OUTER
	 JOIN 
	 (
		SELECT	
				TSTATEMENT.STATEMENTID				AS	STATEMENTID,
				TSTATEMENT.STATEMENTTYPEID			AS	STATEMENTTYPEID,
				TSTATEMENT.[STATEMENT]				AS	[STATEMENT],
				TSTATEMENT.STATEMENTDATETIME		AS	STATEMENTDATETIME,
				TSTATEMENT.RFXQUESTIONANDANSWERID	AS	RFXQUESTIONANDANSWERID,
				TSTATEMENT.PERSONID					AS	PERSONID,
				TSTATEMENT.ISPUBLISHED				AS	ISPUBLISHED,
				TSTATEMENT.ISPRIVATE				AS	ISPRIVATE,
				TSTATEMENT.ISCANCELLED				AS	ISCANCELLED,
				TSTATEMENT.PARENTSTATEMENTID		AS	PARENTSTATEMENTID
		FROM dbo.TSTATEMENT
			 LEFT JOIN dbo.TSTATEMENTTYPE
					ON TSTATEMENT.STATEMENTTYPEID = TSTATEMENTTYPE.STATEMENTTYPEID
				 WHERE TSTATEMENTTYPE.FIXED = 'ANSWER'
			 
	 ) ANSWERS
	   
	 ON QNA.RFXQUESTIONANDANSWERID = ANSWERS.RFXQUESTIONANDANSWERID
	 
	  LEFT OUTER
	  JOIN 	dbo.TPERSON					P
		ON	ORIGINALQUESTIONS.PERSONID	= P.PERSONID

	  JOIN	dbo.TOBJECTTYPE				OT
		ON	QNA.OBJECTTYPEID			= OT.OBJECTTYPEID
	  LEFT  OUTER 
	  JOIN	dbo.TRFXINTEREST			RI
		ON	QNA.OBJECTID				= RI.RFXINTERESTID
		AND	OT.FIXED					= 'RFXINTEREST'
	  LEFT	OUTER
	  JOIN	dbo.TRFXINTERESTEDPARTY		RIP
		ON	RI.RFXINTERESTEDPARTYID		= RIP.RFXINTERESTEDPARTYID
	  LEFT	OUTER
	  JOIN	dbo.TUSER					U
		ON	RI.PRIMARYCOMPANYCONTACTUSERID = U.USERID
	  LEFT	OUTER
	  JOIN	dbo.TCOMPANYCONTACT			CC
		ON	U.PERSONID					= CC.PERSONID
	   AND	CC.COMPANYID				= RI.COMPANYID  
	  LEFT	OUTER
	  JOIN	dbo.TCOMPANY				C
		ON	CC.COMPANYID				= C.COMPANYID
	  LEFT	OUTER
	  JOIN	dbo.TTENDERER				T
		ON	CC.COMPANYID				= T.COMPANYID
	   AND	RI.RFXID					= T.RFXID
	  LEFT	OUTER
	  JOIN	dbo.TDOCUMENT				QDoc
		ON	QDoc.OBJECTID				= ORIGINALQUESTIONS.STATEMENTID
	   AND	QDoc.OBJECTTYPEID			IN (SELECT OBJECTTYPEID FROM TOBJECTTYPE WHERE FIXED='STATEMENT')
	  LEFT	OUTER
	  JOIN	dbo.TDOCUMENT				ADoc
		ON	ADoc.OBJECTID				= ANSWERS.STATEMENTID
	   AND	ADoc.OBJECTTYPEID			IN (SELECT OBJECTTYPEID FROM TOBJECTTYPE WHERE FIXED='STATEMENT')
	 	 	
	 WHERE	OT.FIXED	IN ('RFXINTEREST', 'RFX')
	   AND	QNA.QATYPEID IN 
							(
							 SELECT QATYPEID 
							 FROM TQATYPE
							 WHERE FIXED	= 'QUESTION_AND_ANSWER'
							)


GO
/****** Object:  View [dbo].[VRole]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VRole]
AS
SELECT     dbo.TWorkflowUser.ExternalUserContext, dbo.TWorkflowRole.WorkflowRole
FROM         dbo.TWorkflowRole RIGHT OUTER JOIN
                      dbo.TWorkflowUser_in_WorkflowRole ON 
                      dbo.TWorkflowRole.WorkflowRoleID = dbo.TWorkflowUser_in_WorkflowRole.WorkflowRoleID RIGHT OUTER JOIN
                      dbo.TWorkflowUser ON dbo.TWorkflowUser_in_WorkflowRole.WorkflowUserId = dbo.TWorkflowUser.WorkflowUserId




GO
/****** Object:  View [dbo].[VRPersonroleInObject]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VRPersonroleInObject] AS
SELECT DISTINCT 
	tpersonrole_in_object.objectid, 
	tperson.displayname, 
	tperson.email, 
	tperson.phone1, 
	tperson.phone2, 
	trole.role 
FROM tpersonrole_in_object 
INNER JOIN tperson ON (tpersonrole_in_object.personid = tperson.personid) 
INNER JOIN trole ON (tpersonrole_in_object.roleid = trole.roleid) 
INNER JOIN tobjecttype ON (tpersonrole_in_object.OBJECTTYPEid = tobjecttype.objecttypeid)
WHERE tobjecttype.fixed = 'CONTRACT' and tpersonrole_in_object.objectid >= 0


GO
/****** Object:  View [dbo].[VRProcessPlan]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VRProcessPlan]
AS
SELECT     WPP.WorkflowProcessPlanID, WP.WorkflowProcessID, WP.WorkflowDefinitionID, WPP.WorkflowProcessPlan, WP.WorkflowProcess, 
                      WPP.Description, WPP.PlannedTimeStarted, WPP.PlannedTimeFinished, WP.TimeStarted, WP.TimeFinished, WPP.Duration, 
                      WU1.Description AS StartedByUser, WU2.Description AS ResponsibleUser, WU3.Description AS OwnerUser, WPP.ObjectID, WPP.ObjectTypeID, 
                      TS.STATUS
FROM         dbo.TWorkflowProcessPlan WPP INNER JOIN
                      dbo.TWorkflowProcess WP ON WPP.WorkflowProcessPlanID = WP.WorkflowProcessPlanID LEFT OUTER JOIN
                      dbo.TWorkflowUser WU1 ON WP.StartedByUserId = WU1.WorkflowUserId LEFT OUTER JOIN
                      dbo.TWorkflowUser WU2 ON WPP.ResponsibleUserID = WU2.WorkflowUserId LEFT OUTER JOIN
                      dbo.TWorkflowUser WU3 ON WPP.OwnerUserID = WU3.WorkflowUserId LEFT OUTER JOIN
                      dbo.TSTATUS TS ON WP.STATUSID = TS.STATUSID





GO
/****** Object:  View [dbo].[VRProductGroupForContracts]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VRProductGroupForContracts]
AS
SELECT DISTINCT 
TPROD_GROUP_IN_CONTRACT.CONTRACTID, 
TPROD_GROUP_IN_CONTRACT.PRODUCTGROUPID, 
TPRODUCTGROUP.PRODUCTGROUP, 
TPRODUCTGROUP.PRODUCTGROUPCODE,
TPRODUCTGROUP.EXTERNALNUMBER,
TPRODUCTGROUPNOMENCLATURE.PRODUCTGROUPNOMENCLATURE,
TPRODUCTGROUPNOMENCLATURE.FIXED 
FROM TPROD_GROUP_IN_CONTRACT INNER JOIN TPRODUCTGROUP ON (TPROD_GROUP_IN_CONTRACT.PRODUCTGROUPID = TPRODUCTGROUP.PRODUCTGROUPID)
INNER JOIN TPRODUCTGROUPNOMENCLATURE ON (TPRODUCTGROUP.PRODUCTGROUPNOMENCLATUREID = TPRODUCTGROUPNOMENCLATURE.PRODUCTGROUPNOMENCLATUREID)
WHERE TPRODUCTGROUP.MIK_VALID = 1 AND TPRODUCTGROUPNOMENCLATURE.MIK_VALID = 1



GO
/****** Object:  View [dbo].[VRProjectsForContract]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- VRProjectsForContract for TheVendor.Reporting.Contract.Project 

CREATE VIEW [dbo].[VRProjectsForContract]
AS
SELECT DISTINCT 
	dbo.TPROJECT.PROJECTID,
	dbo.TPROJECT.PARENTID,
	dbo.TPROJECT.PROJECT,
	dbo.TPROJECT.PROJECT_NUMBER,
	dbo.TPROJECT.PROJECT_DESCRIPTION,
	dbo.TPROJECT.PROJECT_START_DATE,
	dbo.TPROJECT.PROJECT_END_DATE,
	dbo.TPROJECT.PROJECTTYPEID,
	dbo.TPROJECT.STATUSID,
	dbo.TPROJECT.REFERENCENUMBER,
	dbo.TPROJECTTYPE.PROJECTTYPE AS PROJECTTYPE, 
	dbo.TSTATUS.STATUS AS STATUS
FROM 	dbo.TCONTRACT_IN_PROJECT RIGHT OUTER JOIN
        dbo.TPROJECT ON dbo.TCONTRACT_IN_PROJECT.PROJECTID = dbo.TPROJECT.PROJECTID INNER JOIN
        dbo.TPROJECTTYPE ON (dbo.TPROJECT.PROJECTTYPEID = dbo.TPROJECTTYPE.PROJECTTYPEID) LEFT OUTER JOIN
        dbo.TSTATUS ON (dbo.TSTATUS.STATUSID = dbo.TPROJECT.STATUSID)


GO
/****** Object:  View [dbo].[VRProjectsInContract]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--VRProjectsInContract for TheVendor.Reporting.Contract.Project 

CREATE VIEW [dbo].[VRProjectsInContract] AS
SELECT DISTINCT 
	TCONTRACT_IN_PROJECT.CONTRACTID, 
	dbo.TPROJECT.PROJECTID,
	dbo.TPROJECT.PARENTID,
	dbo.TPROJECT.PROJECT,
	dbo.TPROJECT.PROJECT_NUMBER,
	dbo.TPROJECT.PROJECT_DESCRIPTION,
	dbo.TPROJECT.PROJECT_START_DATE,
	dbo.TPROJECT.PROJECT_END_DATE,
	dbo.TPROJECT.PROJECTTYPEID,
	dbo.TPROJECT.STATUSID,
	dbo.TPROJECT.REFERENCENUMBER,
	TPROJECTTYPE.PROJECTTYPE, 
	TSTATUS.STATUS
FROM TCONTRACT_IN_PROJECT 
INNER JOIN TPROJECT ON (TCONTRACT_IN_PROJECT.PROJECTID = TPROJECT.PROJECTID)
INNER JOIN TPROJECTTYPE ON (TPROJECT.PROJECTTYPEID = TPROJECTTYPE.PROJECTTYPEID)
LEFT JOIN TSTATUS ON (TSTATUS.STATUSID = TPROJECT.STATUSID)



GO
/****** Object:  View [dbo].[VSEARCHCOMPANYANDCONTACT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--	This view might contain duplicates (persons who are contacts for more than one company each) Alex L 23-feb-2011
CREATE VIEW [dbo].[VSEARCHCOMPANYANDCONTACT]
AS
SELECT	C.COMPANYID,
		C.COMPANYNO,
		C.EXTERNALNUMBER,
		C.COMPANY, 
		C.MIK_VALID					AS IsCompanyValid,
		CA.EMAIL					AS CompanyEmail, 
		CA.PHONE					AS CompanyPhone,
		CT.COUNTRY					AS CompanyCountry, 
		CC.COMPANYCONTACTID,
		P.FIRSTNAME,
		P.LASTNAME,
		P.DISPLAYNAME, 
		P.EMAIL						AS CompanyContactEmail,
		P.PHONE1					AS CompanyContactPhone1, 
		P.PHONE2					AS CompanyContactPhone2,
		CTP.COUNTRY					AS CompanyContactCountry,
		U.USERID,
		U.ISEXTERNALUSER,
		U.MIK_VALID					AS IsUserValid,
		U.USERINITIAL,
		C.DUNSNUMBER
  FROM	dbo.TCOMPANY				C
  LEFT	OUTER
  JOIN	dbo.TCOMPANYADDRESS			CA
	ON	CA.COMPANYID				= C.COMPANYID
  LEFT	OUTER
  JOIN	dbo.TADDRESSTYPE			AT
	ON	AT.ADDRESSTYPEID			= CA.ADDRESSTYPEID
  LEFT	OUTER
  JOIN	dbo.TCOUNTRY				CT
	ON	CA.COUNTRYID				= CT.COUNTRYID
  LEFT	OUTER
  JOIN	dbo.TCOMPANYCONTACT			CC
	ON	CC.COMPANYID				= C.COMPANYID
  LEFT	OUTER
  JOIN	dbo.TPERSON					P
	ON	CC.PERSONID					= P.PERSONID
  LEFT	OUTER
  JOIN	dbo.TCOUNTRY				CTP
	ON	P.COUNTRYID					= CTP.COUNTRYID
  LEFT	OUTER
  JOIN	dbo.TUSER					U
	ON	U.PERSONID					= P.PERSONID
 WHERE	AT.FIXED					= 'MAINADDRESS'


GO
/****** Object:  View [dbo].[VSEARCHCONTRACT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VSEARCHCONTRACT]
AS
SELECT	TOP 100 PERCENT -- ORDER BY clause is disabled in view without using TOP 
		C.CONTRACTNUMBER,
		C.[CONTRACT],
		P.DISPLAYNAME,
		CY.COMPANY, 
		S.[STATUS],
		AT.AGREEMENT_TYPE,
		CR.CONTRACTRELATION, 
		ST.STRATEGYTYPE
  FROM	dbo.TCONTRACT				C
  JOIN	dbo.TEMPLOYEE				E
	ON	C.OWNERID					= E.EMPLOYEEID
   AND	C.TECHCOORDINATORID			= E.EMPLOYEEID
  JOIN	dbo.TPERSON					P
	ON	E.PERSONID					= P.PERSONID
  JOIN	dbo.TUSER					U
	ON	C.EXECUTORID				= U.USERID
   AND	C.CHECKEDOUTBY				= U.USERID
   AND	E.EMPLOYEEID				= U.EMPLOYEEID
  JOIN	dbo.TCOMPANY				CY
	ON	CY.COMPANYID = dbo.udf_get_companyid(C.CONTRACTID)
  JOIN	dbo.TCOMPANYCONTACT			CC
	ON	P.PERSONID					= CC.PERSONID
   AND	CY.COMPANYID				= CC.COMPANYID
  JOIN	dbo.TAGREEMENT_TYPE			AT
	ON	C.AGREEMENT_TYPEID			= AT.AGREEMENT_TYPEID
  JOIN	dbo.TSTRATEGYTYPE			ST
	ON	C.STRATEGYTYPEID			= ST.STRATEGYTYPEID
  JOIN	dbo.TCONTRACTRELATION		CR
	ON	C.CONTRACTRELATIONID		= CR.CONTRACTRELATIONID
  JOIN	dbo.TSTATUS					S
	ON	C.STATUSID					= S.STATUSID
 ORDER	BY
		C.CONTRACTNUMBER

GO
/****** Object:  View [dbo].[VSEARCHCONTRACTCLIENTFIELDS]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VSEARCHCONTRACTCLIENTFIELDS]
AS
SELECT DISTINCT
	CFIC.CONTRACTID,
	CFIC.CLIENTFIELDID,
	CFIC.CLIENTFIELD,
	CFIC.CLIENTFIELDRANGEINCONTRACTID,
	CFIC.MULTIVALUE,
	CFIC.LEVEL1ID,
	CFIC.LEVEL1,
	CFIC.LEVEL2ID,
	CFIC.LEVEL2,
	CFIC.LEVEL3ID,
	CFIC.LEVEL3,
	CFIC.LEVEL4ID,
	CFIC.LEVEL4
FROM
	TEXTRA_FIELD_IN_CONTRACT AS EFIC

	FULL JOIN

	(SELECT
		CLF.CLIENTFIELDID,
		CLF.CLIENTFIELD,
		CFIC.CONTRACTID,
		CFIC.CLIENTFIELDRANGEINCONTRACTID,
		(ISNULL(L1.LEVEL1, '') + ISNULL(', ' + L2.LEVEL2, '') + ISNULL(', ' + L3.LEVEL3, '') + ISNULL(', ' + L4.LEVEL4, '')) AS MULTIVALUE,
		CFIC.LEVEL1ID,
		L1.LEVEL1,
		CFIC.LEVEL2ID,
		L2.LEVEL2,
		CFIC.LEVEL3ID,
		L3.LEVEL3,
		CFIC.LEVEL4ID,
		L4.LEVEL4
	FROM
		TCLIENTFIELD AS CLF 
	
			LEFT JOIN
			TCLIENTFIELDRANGE_IN_CONTRACT AS CFIC ON (CLF.CLIENTFIELDID = CFIC.CLIENTFIELDID)
	
				LEFT JOIN
				TLEVEL1 AS L1 ON (CFIC.LEVEL1ID = L1.LEVEL1ID)
	
				LEFT JOIN
				TLEVEL2 AS L2 ON (CFIC.LEVEL2ID = L2.LEVEL2ID)
	
				LEFT JOIN
				TLEVEL3 AS L3 ON (CFIC.LEVEL3ID = L3.LEVEL3ID)
	
				LEFT JOIN
				TLEVEL4 AS L4 ON (CFIC.LEVEL4ID = L4.LEVEL4ID)) AS CFIC ON (EFIC.CONTRACTID = CFIC.CONTRACTID)

WHERE
	NOT ISNULL(EFIC.CONTRACTID, CFIC.CONTRACTID) IS NULL


GO
/****** Object:  View [dbo].[VSEARCHPUBLISHEDCONTRACTS]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VSEARCHPUBLISHEDCONTRACTS] AS(
SELECT
	[DBO].[TCONTRACT].[CONTRACTID],
	[DBO].[TCONTRACT].[CONTRACTNUMBER],
	[DBO].[TCONTRACT].[CONTRACT],
	[DBO].[TCOMPANY].[COMPANY],
	[DBO].[TSTATUS].[STATUS],	
	[DBO].[TCONTRACT].[PUBLISH],
	[DBO].[TCONTRACT].[STATUSID],
	[DBO].[TSTATUS].[FIXED] 'STATUSFIXED',
	[DBO].[TCONTRACT].[REFERENCECONTRACTNUMBER],
	[DBO].[TCONTRACT].[COUNTERPARTYNUMBER],
    [DBO].[TCOMPANY].[COMPANYID],
	[DBO].[TCOMPANY].[COMPANYNO],
	[DBO].[TCONTRACT].[COMMENTS],
	[DBO].[TCONTRACT].[AWARDDATE],
	[DBO].[TCONTRACTSUMMARY].[SEARCHWORDS] 'CONTRACTSUMMARYSEARCHWORDS',
	[DBO].[TCONTRACTRELATION].[CONTRACTRELATION],
	[DBO].[TCONTRACTRELATION].[FIXED] 'CONTRACTRELATIONFIXED',
	[DBO].[TAGREEMENT_TYPE].[AGREEMENT_TYPE] 'AGREEMENTTYPE',
	[DBO].[TAGREEMENT_TYPE].[FIXED] 'AGREEMENTTYPEFIXED',
   (SELECT ISNULL(SUBSTRING((SELECT ',' + ISNULL(X.PRODUCTGROUPCODE, '') + ISNULL(' - ' + X.PRODUCTGROUP, '') 
    FROM TPRODUCTGROUP X INNER JOIN TPROD_GROUP_IN_CONTRACT Y ON Y.PRODUCTGROUPID = X.PRODUCTGROUPID
    WHERE Y.CONTRACTID = TCONTRACT.CONTRACTID
    FOR XML PATH, TYPE).value('.[1]', 'nvarchar(max)'), 2, 4000), '')) AS 'PRODUCTGROUPS',
   (SELECT ISNULL(SUBSTRING((SELECT '|' + ISNULL(P.DISPLAYNAME, '') 
	FROM TPERSONROLE_IN_OBJECT PIO
	INNER JOIN 	TPERSON P ON PIO.PERSONID = P.PERSONID
	INNER JOIN 	TOBJECTTYPE O ON PIO.OBJECTTYPEID = O.OBJECTTYPEID
	WHERE
	PIO.OBJECTID = TCONTRACT.CONTRACTID AND
	O.FIXED = 'CONTRACT'
	ORDER BY
	PIO.ROLEID ASC,
	P.DISPLAYNAME ASC 	
	FOR XML PATH, TYPE).value('.[1]', 'nvarchar(max)'), 2, 4000), '')) AS  'PERSONSWITHROLES',
   (SELECT ISNULL(SUBSTRING((SELECT '|' + ISNULL(D.DEPARTMENT, '') 
	FROM TDEPARTMENTROLE_IN_OBJECT DIO
        INNER JOIN 	TDEPARTMENT D ON (DIO.DEPARTMENTID = D.DEPARTMENTID)
	INNER JOIN  TOBJECTTYPE O ON (DIO.OBJECTTYPEID = O.OBJECTTYPEID)
	WHERE
	DIO.OBJECTID = TCONTRACT.CONTRACTID
	AND O.FIXED = 'CONTRACT'
	ORDER BY
	DIO.ROLEID ASC, 
	D.DEPARTMENT ASC 
	FOR XML PATH, TYPE).value('.[1]', 'nvarchar(max)'), 2, 4000), '')) AS 'DEPARTMENTSWITHROLES'

FROM [DBO].[TCONTRACTSUMMARY] 
RIGHT OUTER JOIN [DBO].[TCONTRACT] ON ([DBO].[TCONTRACTSUMMARY].[CONTRACTID] = [DBO].[TCONTRACT].[CONTRACTID])
INNER JOIN [DBO].[TSTATUS] ON ([DBO].[TCONTRACT].[STATUSID] = [DBO].[TSTATUS].[STATUSID])
LEFT OUTER JOIN [DBO].[TCOMPANY] ON ([DBO].[TCOMPANY].[COMPANYID] = dbo.udf_get_companyid(dbo.TCONTRACT.CONTRACTID))
LEFT OUTER JOIN [DBO].[TAGREEMENT_TYPE] ON ([DBO].[TCONTRACT].[AGREEMENT_TYPEID] = [DBO].[TAGREEMENT_TYPE].[AGREEMENT_TYPEID])
INNER JOIN [DBO].[TCONTRACTRELATION] ON ([DBO].[TCONTRACT].[CONTRACTRELATIONID] = [DBO].[TCONTRACTRELATION].[CONTRACTRELATIONID])
WHERE ([DBO].[TCONTRACT].[PUBLISH] = 1)
)


GO
/****** Object:  View [dbo].[VSEARCHSIMPLECOMPANY]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VSEARCHSIMPLECOMPANY]
AS
SELECT     dbo.TCOMPANY.COMPANYID, dbo.TCOMPANY.PARENTCOMPANYID, dbo.TCOMPANY.COMPANY, dbo.TCOMPANY.COMPANYNO, 
                      dbo.TCOMPANY.MIK_VALID AS MIKVALID, dbo.TCOMPANY.EXTERNALNUMBER, dbo.TCOMPANY.ISVENDOR, dbo.TCOMPANY.ISCUSTOMER, 
                      dbo.TCOMPANY.ISPARTNER, dbo.TCOMPANY.ISINTERNAL, TCOMPANY_1.COMPANYNO AS PARENTCOMPANYNO, 
                      TCOMPANY_1.COMPANY AS PARENTCOMPANY, dbo.TCOMPANYADDRESS.COMPANYADDRESSID, dbo.TCOMPANYADDRESS.ADDRESSTYPEID, 
                      dbo.TCOMPANYADDRESS.ADDRESSLINE1, dbo.TCOMPANYADDRESS.ADDRESSLINE2, dbo.TCOMPANYADDRESS.ADDRESSLINE3, 
                      dbo.TCOMPANYADDRESS.ADDRESSLINE4, dbo.TCOMPANYADDRESS.ADDRESSLINE5, dbo.TCOMPANYADDRESS.PHONE, 
                      dbo.TCOMPANYADDRESS.FAX, dbo.TCOMPANYADDRESS.WWW, dbo.TADDRESSTYPE.ADDRESSTYPE, dbo.TADDRESSTYPE.FIXED, 
                      dbo.TCOMPANYADDRESS.COUNTRYID, dbo.TCOUNTRY.COUNTRY, dbo.TCOMPANY.DUNSNUMBER
FROM         dbo.TADDRESSTYPE INNER JOIN
                      dbo.TCOMPANYADDRESS ON dbo.TADDRESSTYPE.ADDRESSTYPEID = dbo.TCOMPANYADDRESS.ADDRESSTYPEID LEFT OUTER JOIN
                      dbo.TCOUNTRY ON dbo.TCOMPANYADDRESS.COUNTRYID = dbo.TCOUNTRY.COUNTRYID RIGHT OUTER JOIN
                      dbo.TCOMPANY ON dbo.TCOMPANYADDRESS.COMPANYID = dbo.TCOMPANY.COMPANYID LEFT OUTER JOIN
                      dbo.TCOMPANY TCOMPANY_1 ON dbo.TCOMPANY.PARENTCOMPANYID = TCOMPANY_1.COMPANYID



GO
/****** Object:  View [dbo].[VSEARCHSIMPLECONTRACT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VSEARCHSIMPLECONTRACT] AS
SELECT    dbo.TCONTRACT.CONTRACTID, dbo.TCONTRACT.CONTRACTNUMBER, 
                      dbo.TCONTRACTRELATION.FIXED AS CONTRACTRELATIONFIXED, dbo.TCONTRACT.CONTRACT, dbo.TCONTRACT.STARTDATE, 
                      dbo.TCONTRACT.EXPIRYDATE, dbo.TCONTRACT.REV_EXPIRYDATE AS REVEXPIRYDATE, dbo.TSTATUS.STATUS, 
                      dbo.TCONTRACTRELATION.CONTRACTRELATION, dbo.TCONTRACTTYPE.CONTRACTTYPE, dbo.TCONTRACT.AWARDDATE, dbo.TCONTRACT.STATUSID, 
                      dbo.TSTATUS.FIXED AS STATUSFIXED, dbo.TSTATUS.MIK_SEQUENCE AS STATUSMIKSEQUENCE, 
                      dbo.TAGREEMENT_TYPE.AGREEMENT_TYPE AS AGREEMENTTYPE, dbo.TCOMPANY.COMPANY, dbo.TCOUNTRY.COUNTRY, 
                      dbo.TADDRESSTYPE.FIXED AS ADDRESSTYPEFIXED,
                          (SELECT     MAX(A.TIME)
                            FROM          TAUDITTRAIL A, TOBJECTTYPE O10
                            WHERE      A.OBJECTTYPEID = O10.OBJECTTYPEID AND O10.FIXED = 'CONTRACT' AND A.OBJECTID = dbo.TCONTRACT.CONTRACTID) 
                      AS LASTCHANGEDTIME, dbo.TSTRATEGYTYPE.STRATEGYTYPE, dbo.TSTRATEGYTYPE.FIXED AS STRATEGYTYPEFIXED, 
                      dbo.TCONTRACT.REFERENCECONTRACTNUMBER, dbo.TCONTRACT.COUNTERPARTYNUMBER, dbo.TCONTRACT.REFERENCECONTRACTID, 
                      dbo.TCONTRACT.STRATEGYTYPEID, dbo.TCONTRACT.CONTRACTTYPEID, TCOMPANY.COMPANYID as COMPANYID, dbo.TCONTRACT.CONTRACTRELATIONID, 
                      dbo.TCONTRACT.REVIEWDATE, dbo.TCONTRACT.DEFINEDENDDATE, dbo.TCONTRACT.SIGNEDDATE, dbo.TCOUNTRY.COUNTRYID, 
                      TCONTRACT_1.CONTRACTNUMBER AS LINKEDTONUMBER, dbo.TCONTRACT.CONTRACTDATE, dbo.TPERSONROLE_IN_OBJECT.PERSONID, 
                      dbo.TPERSONROLE_IN_OBJECT.ROLEID AS PERSONROLEID, TOBJECTTYPE_1.FIXED AS OBJECTTYPEFIXED, TROLE_2.ROLE AS PERSONROLE, 
                      TROLE_2.FIXED AS PERSONROLEFIXED, dbo.TPERSON.DISPLAYNAME AS PERSON, dbo.TPERSON.EMAIL AS PERSONEMAIL, 
                      dbo.TPERSON.PHONE1 AS PERSONPHONE1, dbo.TPERSON.PHONE2 AS PERSONPHONE2, dbo.TDEPARTMENTROLE_IN_OBJECT.OBJECTTYPEID, 
                      dbo.TDEPARTMENTROLE_IN_OBJECT.DEPARTMENTID, dbo.TDEPARTMENTROLE_IN_OBJECT.ROLEID AS DEPARTMENTROLEID, 
                      TROLE_1.ROLE AS DEPARTMENTROLE, TROLE_1.FIXED AS DEPARTMENTROLEFIXED, dbo.TDEPARTMENT.DEPARTMENT, 
                      dbo.TDEPARTMENT.DEPARTMENT_CODE AS DEPARTMENTCODE, dbo.TCONTRACT.PUBLISH, dbo.TCONTRACT.REFERENCENUMBER, 
                      TSTATUS_1.STATUS AS ApprovalStatus,
	         dbo.TCONTRACT.LASTTASKCOMPLETED,
	         ISNULL(SUBSTRING((SELECT ';' + ISNULL(X.PRODUCTGROUP, '') + ISNULL('(CODE: ' + X.PRODUCTGROUPCODE + ')', '') 
             FROM DBO.TPRODUCTGROUP X INNER JOIN TPROD_GROUP_IN_CONTRACT Y ON Y.PRODUCTGROUPID = X.PRODUCTGROUPID
			 WHERE Y.CONTRACTID = DBO.TCONTRACT.CONTRACTID
			 FOR XML PATH, TYPE).value('.[1]', 'nvarchar(max)'), 2, 4000), '')  AS 'PRODUCTGROUPS',  
             dbo.TCONTRACT.SHAREDWITHSUPPLIER
FROM         dbo.TCOMPANYADDRESS 
	INNER JOIN dbo.TADDRESSTYPE ON dbo.TCOMPANYADDRESS.ADDRESSTYPEID = dbo.TADDRESSTYPE.ADDRESSTYPEID 
		AND dbo.TADDRESSTYPE.FIXED = 'MAINADDRESS' 
	LEFT OUTER JOIN dbo.TCOUNTRY ON dbo.TCOMPANYADDRESS.COUNTRYID = dbo.TCOUNTRY.COUNTRYID 
	RIGHT OUTER JOIN dbo.TCOMPANY ON dbo.TCOMPANYADDRESS.COMPANYID = dbo.TCOMPANY.COMPANYID 
	RIGHT OUTER JOIN dbo.TSTATUS TSTATUS_1 
		RIGHT OUTER JOIN dbo.TCONTRACT ON TSTATUS_1.STATUSID = dbo.TCONTRACT.APPROVALSTATUSID 
		LEFT OUTER JOIN dbo.TCONTRACT TCONTRACT_1 ON dbo.TCONTRACT.REFERENCECONTRACTID = TCONTRACT_1.CONTRACTID 
		LEFT OUTER JOIN dbo.TROLE TROLE_1 
			INNER JOIN dbo.TDEPARTMENTROLE_IN_OBJECT 
				INNER JOIN dbo.TDEPARTMENT ON dbo.TDEPARTMENTROLE_IN_OBJECT.DEPARTMENTID = dbo.TDEPARTMENT.DEPARTMENTID 
			ON TROLE_1.ROLEID = dbo.TDEPARTMENTROLE_IN_OBJECT.ROLEID 
			INNER JOIN dbo.TOBJECTTYPE TOBJECTTYPE_1 ON dbo.TDEPARTMENTROLE_IN_OBJECT.OBJECTTYPEID = TOBJECTTYPE_1.OBJECTTYPEID 
				AND  TOBJECTTYPE_1.FIXED = N'CONTRACT' 
		ON dbo.TCONTRACT.CONTRACTID = dbo.TDEPARTMENTROLE_IN_OBJECT.OBJECTID 
		LEFT OUTER JOIN dbo.TOBJECTTYPE TOBJECTTYPE_2 
			INNER JOIN dbo.TROLE TROLE_2 
				INNER JOIN dbo.TPERSON 
					INNER JOIN dbo.TPERSONROLE_IN_OBJECT ON dbo.TPERSON.PERSONID = dbo.TPERSONROLE_IN_OBJECT.PERSONID 
				ON TROLE_2.ROLEID = dbo.TPERSONROLE_IN_OBJECT.ROLEID 
			ON TOBJECTTYPE_2.OBJECTTYPEID = dbo.TPERSONROLE_IN_OBJECT.OBJECTTYPEID AND TOBJECTTYPE_2.FIXED = N'CONTRACT' 
		ON dbo.TCONTRACT.CONTRACTID = dbo.TPERSONROLE_IN_OBJECT.OBJECTID 
	ON dbo.TCOMPANY.COMPANYID = dbo.udf_get_companyid(tcontract.contractid)
	LEFT OUTER JOIN dbo.TCONTRACTTYPE ON dbo.TCONTRACT.CONTRACTTYPEID = dbo.TCONTRACTTYPE.CONTRACTTYPEID 
	LEFT OUTER JOIN dbo.TSTRATEGYTYPE ON dbo.TCONTRACT.STRATEGYTYPEID = dbo.TSTRATEGYTYPE.STRATEGYTYPEID 
	LEFT OUTER JOIN dbo.TCONTRACTRELATION ON dbo.TCONTRACT.CONTRACTRELATIONID = dbo.TCONTRACTRELATION.CONTRACTRELATIONID 
	LEFT OUTER JOIN dbo.TSTATUS ON dbo.TCONTRACT.STATUSID = dbo.TSTATUS.STATUSID 
	LEFT OUTER JOIN dbo.TAGREEMENT_TYPE ON dbo.TCONTRACT.AGREEMENT_TYPEID = dbo.TAGREEMENT_TYPE.AGREEMENT_TYPEID


GO
/****** Object:  View [dbo].[VSEARCHSIMPLEDOCUMENT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  View [dbo].[VSEARCHSIMPLEDOCUMENT]******/
CREATE VIEW [dbo].[VSEARCHSIMPLEDOCUMENT] 
AS 
SELECT	
        CASE
			WHEN	OWN.ObjectTypeFixed	= N'TENDERER' 
			THEN ISNULL(C.ContractNumber,N'')+ISNULL(N' - '+ dbo.udf_get_companyname(c.contractid), N'')
			ELSE	OWN.Name
		END												AS OBJECTOWNERNAME,
		OWN.ObjectType									AS OBJECTTYPE, 
		OWN.ObjectTypeFixed								AS OBJECTTYPEFIXED,
		OWN.ContractID									AS OwnerContractID, 
		D.Description									AS TITLE, 
		CONVERT(NVARCHAR, fi.MajorVersion) + N'.' + CONVERT(NVARCHAR, fi.MinorVersion)
														AS [VERSION], 
		FI.MajorVersion									, 
		FI.MinorVersion									,
		A.Archive										AS [STATUS],
		ISNULL(P2.Displayname, P4.Displayname)			AS [OWNER], 
		MT.ModuleType									AS TEMPLATETYPE,
		ISNULL(P1.DisplayName, P3.DisplayName)			AS CHECKEDOUTBY, 
		FI.LastChangedDate								AS VERSIONDATE, 
		D.DocumentDate									AS DATECREATED, 
		D.CheckedOutDate								AS CHECKEDOUTDATE,
		D.Document										AS [FILENAME],
		FI.FileSize										,
		D.OrigFileName									AS ORIGINALFILENAME, 
		D.UserID										AS DOCUMENTOWNERID, 
		D.CheckedOutBy									AS CHECKEDOUTBYID, 
		D.CheckedIn										AS CHECKEDOUTSTATUS,
		D.DocumentTypeID								AS DOCUMENTTYPEID, 
		D.DocumentID									AS DOCUMENTID, 
		D.ArchiveID										AS ARCHIVEID, 
		D.SourceFileInfoID								AS SOURCEFILEINFOID, 
		A.Fixed											AS ARCHIVEFIXED, 
		D.MIK_VALID										AS MIKVALID, 
		D.DeletedByUserID								, 
		FI.FileID										, 
		DT.DocumentType									AS DOCUMENTTYPE, 
		FI.FileType										,
		FI.SmartTemplateBasedDocCanBeEdited				,
		D.ObjectTypeID									AS OBJECTTYPEID, 
		D.ObjectID										AS OBJECTID, 
		(
		SELECT	COUNT(ClauseID)			AS expr1 
		  FROM	dbo.TClause_In_Document CID
		 WHERE	DocumentID				= D.DocumentID
		)												AS CLAUSECOUNT, 
		D.Publish										AS PUBLISH, 
		dbo.TStatus.[Status]							AS ApprovalStatus, 
		dbo.TStatus.StatusID							AS ApprovalStatusID, 
		dbo.TStatus.Fixed								AS ApprovalStatusFixed, 
		D.ScheduledForArchiving							AS SCHEDULEDFORARCHIVING, 
		D.ArchivedDate									AS ARCHIVEDDATE,
		D.ArchiveDocumentKey							AS ARCHIVEDOCUMENTKEY, 
		D.InDate										AS INDATE,
		D.OutDate										AS OUTDATE,
		D.SharedWithSupplier							AS SHAREDWITHSUPPLIER, 
		dbo.udf_get_companyid(c.contractid)				AS CONTRACT_COMPANYID, 
		ST_Contract.Fixed								AS CONTRACT_STATUS_FIXED, 
		C.SharedWithSupplier							AS CONTRACT_SHAREDWITHSUPPLIER,
		CONVERT(BIT,	CASE WHEN EXISTS
						(	SELECT TOP 1 DU.DOCUMENTID 
							FROM TDOCUMENT_SHARED_WITH_CCS_USER DU 
							WHERE D.DOCUMENTID = DU.DOCUMENTID
						)	
						THEN 1 
						ELSE 0 
				END	)									AS SHAREDONCCS
  FROM	dbo.TUser										U1
 RIGHT	OUTER
  JOIN	dbo.TDocument									D 
  LEFT	OUTER
  JOIN	dbo.TStatus
	ON	D.ApprovalStatusID								= dbo.TStatus.StatusID 
  JOIN	DBO.Tuser										U2
	ON	D.UserID										= U2.UserID 
  JOIN	dbo.TFileInfo									FI 
	ON	D.FileInfoID									= FI.FileInfoID
  --	!!!	This join is left because otherwise documents which had been belonged to object(s) which
  --	was/were deleted are not visible in the Recycle Bin. Alex L 2011-11-09 !!!
  LEFT	OUTER	
  JOIN	(
		SELECT	ISNULL(C.ContractNumber, N'')+ISNULL(N' - '+C.[Contract], N'')
														AS Name,
				C.ContractID							AS ObjectID,
				OT.ObjectTypeID							AS ObjectTypeID,
				OT.ObjectType							, 
				OT.Fixed								AS ObjectTypeFixed,
				C.ContractID							AS ContractID,
				NULL									AS CompanyID
		  FROM	dbo.TObjectType							OT
		  JOIN	dbo.TContract							C
		    ON	OT.Fixed								= N'CONTRACT'
		UNION	ALL		    
		SELECT	CONVERT(NVARCHAR, A.AmendmentNumber)+ISNULL(N' - '+A.Amendment, N'')
														AS Name,
				A.AmendmentID							AS ObjectID,
				OT.ObjectTypeID							AS ObjectTypeID,
				OT.ObjectType							, 
				OT.Fixed								AS ObjectTypeFixed,
				A.ContractID							AS ContractID,
				NULL									AS CompanyID
		  FROM	dbo.TObjectType							OT
		  JOIN	dbo.TAmendment							A
		    ON	OT.Fixed								= N'AMENDMENT'
		UNION	ALL
		SELECT	ISNULL(CONVERT(NVARCHAR, CO.Mik_Sequence)+N' - ', N'')+ISNULL(CO.[DESCRIPTION], '')
														AS Name,
				CO.CallOffID							AS ObjectID,
				OT.ObjectTypeID							AS ObjectTypeID,
				OT.ObjectType							, 
				OT.Fixed								AS ObjectTypeFixed,
				CO.ContractID							AS ContractID,
				NULL									AS CompanyID
		  FROM	dbo.TObjectType							OT
		  JOIN	dbo.TCalloff							CO
			ON  OT.Fixed								= N'CALLOFF'
		UNION	ALL
		SELECT	ISNULL(CY.CompanyNo+N' - ', N'')+ISNULL(CY.Company, N'')
														AS Name,
				CY.CompanyID							AS ObjectID,
				OT.ObjectTypeID							AS ObjectTypeID,
				OT.ObjectType							, 
				OT.Fixed								AS ObjectTypeFixed,
				NULL									AS ContractID,
				NULL									AS CompanyID
		  FROM	dbo.TObjectType							OT
		  JOIN	dbo.TCompany							CY
		    ON	OT.Fixed								= N'COMPANY'
		UNION	ALL
		SELECT	ISNULL(O.OptionName, N'')
														AS Name,
				O.OptionID								AS ObjectID,
				OT.ObjectTypeID							AS ObjectTypeID,
				OT.ObjectType							, 
				OT.Fixed								AS ObjectTypeFixed,
				O.ContractID							AS ContractID,
				NULL									AS CompanyID
		  FROM	dbo.TObjectType							OT
		  JOIN	dbo.TOption								O
			ON  OT.Fixed								= N'OPTION'
		UNION	ALL	
		SELECT	CONVERT(NVARCHAR, ORD.OrderNumber)+ISNULL(N' - '+ORD.OrderName, N'')
														AS Name,
				ORD.OrderID								AS ObjectID,
				OT.ObjectTypeID							AS ObjectTypeID,
				OT.ObjectType							,
				OT.Fixed								AS ObjectTypeFixed,
				ORD.ContractID							AS ContractID,
				NULL									AS CompanyID
		  FROM	dbo.TObjectType							OT
		  JOIN	dbo.TOrder								ORD
			ON  OT.Fixed								= N'ORDER'
		UNION	ALL
		SELECT	CASE TRPROCESS.[DESCRIPTION] 
					WHEN null THEN TRPROCESSTYPE.RPROCESSTYPE + N' '+ CONVERT(NVARCHAR, TRPROCESS.RPROCESSNUMBER)
					WHEN N''  THEN TRPROCESSTYPE.RPROCESSTYPE + N' '+ CONVERT(NVARCHAR, TRPROCESS.RPROCESSNUMBER)
					ELSE CONVERT(NVARCHAR, TRPROCESS.RPROCESSNUMBER) + N' - ' + TRPROCESS.[DESCRIPTION] 
				END
														AS Name,
				TRPROCESS.RPROCESSID					AS ObjectID,
				OT.ObjectTypeID							AS ObjectTypeID,
				TRPROCESSTYPE.RPROCESSTYPE              AS ObjectType,   --We need this way of retrieving object type because "Recurring process" object type should not be visible to customers, and document grid should display recurring process type as a parent object
				OT.Fixed								AS ObjectTypeFixed,
				TRPROCESS.ContractID					AS ContractID,
				NULL									AS CompanyID
		  FROM	dbo.TObjectType							OT
		  JOIN	dbo.TRPROCESS							TRPROCESS
			ON  OT.Fixed								= N'RPROCESS'
		  JOIN	dbo.TRPROCESSTYPE						TRPROCESSTYPE
		    ON	TRPROCESS.RPROCESSTYPEID				= TRPROCESSTYPE.RPROCESSTYPEID
		UNION	ALL
		SELECT	ISNULL(P.Project_Number+N' - ', N'')+ISNULL(P.Project, N'')
														AS Name,
				P.ProjectID								AS ObjectID,
				OT.ObjectTypeID							AS ObjectTypeID,
				OT.ObjectType							,
				OT.Fixed								AS ObjectTypeFixed,
				NULL									AS ContractID,
				NULL									AS CompanyID
		  FROM	dbo.TObjectType							OT
		  JOIN	dbo.TProject							P
			ON  OT.Fixed								= N'PROJECT'
		UNION	ALL
		SELECT	ISNULL(R.InternalNumber+N' - ', N'')+ISNULL(R.Rfx, N'')
														AS Name,
				R.RfxID									AS ObjectID,
				OT.ObjectTypeID							AS ObjectTypeID,
				OT.ObjectType							,
				OT.Fixed								AS ObjectTypeFixed,
				R.ContractID							AS ContractID,
				NULL									AS CompanyID
		  FROM	dbo.TObjectType							OT
		  JOIN	dbo.TRfx								R
			ON  OT.Fixed								= N'RFX'
		UNION	ALL
		SELECT	ISNULL(CONVERT(NVARCHAR, SO.Service_Order_Number)+N' - ', N'')+ISNULL(CONVERT(NVARCHAR, SO.Revision), N'')
														AS Name,
				SO.Service_OrderId						AS ObjectID,
				OT.ObjectTypeID							AS ObjectTypeID,
				OT.ObjectType							,
				OT.Fixed								AS ObjectTypeFixed,
				SO.ContractID							AS ContractID,
				NULL									AS CompanyID
		  FROM	dbo.TObjectType							OT
		  JOIN	dbo.TService_Order						SO
			ON  OT.Fixed								= N'SERVICE_ORDER'
		UNION	ALL
		SELECT	''
														AS Name,
				T.TendererID							AS ObjectID,
				OT.ObjectTypeID							AS ObjectTypeID,
				OT.ObjectType							,
				OT.Fixed								AS ObjectTypeFixed,
				T.ContractID							AS ContractID,
				T.CompanyID								AS CompanyID
		  FROM	dbo.TObjectType							OT
		  JOIN	dbo.TTenderer							T
			ON  OT.Fixed								= N'TENDERER'
		UNION	ALL
		SELECT	CONVERT(NVARCHAR, VI.ViNumber) + ISNULL(N' - ' + VI.Vi, N'')
														AS Name,
				VI.ViID									AS ObjectID,
				OT.ObjectTypeID							AS ObjectTypeID,
				OT.ObjectType							,
				OT.Fixed								AS ObjectTypeFixed,
				VI.ContractID							AS ContractID,
				NULL									AS CompanyID
		  FROM	dbo.TObjectType							OT
		  JOIN	dbo.TVI									VI
			ON  OT.Fixed								= N'VI'
		UNION	ALL	
		SELECT	CONVERT(NVARCHAR, VO.VONumber) + ISNULL(N' - ' + VO.VO, N'')
														AS Name,
				VO.VoID									AS ObjectID,
				OT.ObjectTypeID							AS ObjectTypeID,
				OT.ObjectType							,
				OT.Fixed								AS ObjectTypeFixed,
				VO.ContractID							AS ContractID,
				NULL									AS CompanyID
		  FROM	dbo.TObjectType							OT
		  JOIN	dbo.TVO									VO
			ON  OT.Fixed								= N'VO'
		UNION	ALL
		SELECT	CONVERT(NVARCHAR, VOR.VORNumber) + ISNULL(N' - ' + VOR.Vor, N'')
														AS Name,
				VOR.VorID								AS ObjectID,
				OT.ObjectTypeID							AS ObjectTypeID,
				OT.ObjectType							,
				OT.Fixed								AS ObjectTypeFixed,
				VOR.ContractID							AS ContractID,
				NULL									AS CompanyID
		  FROM	dbo.TObjectType							OT
		  JOIN	dbo.TVOR								VOR
			ON  OT.Fixed								= N'VOR'
		UNION	ALL
		SELECT	ISNULL(R.InternalNumber+N' - ', N'')+ISNULL(R.Rfx, N'')
														AS Name,
				E.ESPD_REQUESTID						AS ObjectID,
				OT.ObjectTypeID							AS ObjectTypeID,
				OT.ObjectType							,
				OT.Fixed								AS ObjectTypeFixed,
				R.ContractID							AS ContractID,
				NULL									AS CompanyID
		  FROM	dbo.TObjectType							OT
		  JOIN	dbo.TRfx								R
			JOIN  dbo.TESPD_REQUEST						E
				ON  R.RFXID								= E.RFXID
			ON  OT.Fixed								= N'ESPD_REQUEST'
		UNION	ALL
		SELECT	ISNULL(R.InternalNumber+N' - ', N'')+ISNULL(R.Rfx, N'')
														AS Name,
				E.ESPD_RESPONSEID						AS ObjectID,
				OT.ObjectTypeID							AS ObjectTypeID,
				OT.ObjectType							,
				OT.Fixed								AS ObjectTypeFixed,
				R.ContractID							AS ContractID,
				RI.COMPANYID							AS CompanyID
		  FROM	dbo.TObjectType							OT
		  JOIN	dbo.TRfx								R
			join dbo.TRFXINTEREST                       RI
				JOIN  dbo.TESPD_RESPONSE				E
					ON  RI.RFXINTERESTID				= E.RFXINTERESTID
				ON  R.RFXID								= RI.RFXID
			ON  OT.Fixed								= N'ESPD_RESPONSE'
		)												OWN
	ON	OWN.ObjectID									= D.ObjectID
   AND	OWN.ObjectTypeID								= D.ObjectTypeID
  LEFT	OUTER
  JOIN	TCONTRACT										C
	ON	C.ContractID									= OWN.ContractID
 LEFT	OUTER
  JOIN	dbo.TDocumentType								DT 
	ON	D.DocumentTypeID								= DT.DocumentTypeID 
  LEFT	OUTER
  JOIN	dbo.TModuleType									MT
	ON	D.ModuleTypeID									= MT.ModuleTypeID 
	ON	U1.UserID										= D.CheckedOutBy 
  LEFT	OUTER
  JOIN	dbo.TArchive									A
	ON	D.ArchiveID										= A.ArchiveID
  LEFT	OUTER
  JOIN	dbo.Temployee									E1 
	ON	U1.EmployeeID									= E1.EmployeeID
  LEFT	OUTER
  JOIN	dbo.TPerson										P1
	ON	E1.PersonID										= P1.PersonID 
  LEFT	OUTER
  JOIN	dbo.TPerson										P3 
	ON	U1.PersonID										= P3.PersonID
  LEFT	OUTER
  JOIN	dbo.Temployee									E2 
  LEFT	OUTER
  JOIN	dbo.TPerson										P2 
	ON	E2.PersonID										= P2.PersonID
	ON	U2.EmployeeID									= E2.EmployeeID
  LEFT	OUTER
  JOIN	dbo.TPerson										P4 
	ON	U2.PersonID										= P4.PersonID
  LEFT	OUTER
  JOIN	dbo.TStatus										st_contract
	ON	st_contract.StatusID							= C.StatusID
 WHERE	(	OWN.ObjectTypeFixed							!= N'TENDERER'
		OR	(
				(	FI.Encrypted						IS NULL
				OR	FI.Encrypted						= 0
				)
			)
		)
   AND	D.ObjectTypeID									NOT IN (
		SELECT	OT.ObjectTypeID
		  FROM	TObjectType								OT
		 WHERE	OT.FIXED								IN ('RFXQUESTIONANDANSWER', 'RFXINTEREST', 'STATEMENT') 
		)

GO
/****** Object:  View [dbo].[VSEARCHSIMPLEPROJECT]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VSEARCHSIMPLEPROJECT]
AS
SELECT	TOP 100 PERCENT P.PROJECTID, P.PARENTID, P.PROJECT_NUMBER AS PROJECTNUMBER, P.PROJECT, 
		P.PROJECT_START_DATE AS PROJECTSTARTDATE, P.PROJECT_END_DATE AS PROJECTENDDATE, P.PROJECTTYPEID, P.STATUSID, 
		PT.PROJECTTYPE, S.STATUS, S.FIXED AS STATUSFIXED, PIO.ROLE AS PERSONROLE, PIO.FIXED AS PERSONROLEFIXED, 
		PIO.DISPLAYNAME AS PERSON, DIO.ROLE AS DEPARTMENTROLE, DIO.FIXED AS DEPARTMENTROLEFIXED, DIO.DEPARTMENT, 
		'PROJECT' AS OBJECTTYPEFIXED, PIO.PERSONID, PIO.OBJECTTYPEID, PIO.ROLEID AS PERSONROLEID, PIO.EMAIL AS PERSONEMAIL, 
		PIO.PHONE1 AS PERSONPHONE1, PIO.PHONE2 AS PERSONPHONE2, DIO.DEPARTMENTID, DIO.ROLEID AS DEPARTMENTROLEID, 
		P.REFERENCENUMBER
  FROM	dbo.TPROJECT					P
  JOIN	dbo.TPROJECTTYPE				PT
	ON	P.PROJECTTYPEID					= PT.PROJECTTYPEID
  JOIN	dbo.TSTATUS						S
	ON	P.STATUSID						= S.STATUSID
  LEFT	OUTER
  JOIN	(SELECT PIO_.OBJECTID,
				PIO_.OBJECTTYPEID,
				PIO_.PERSONID,
				PIO_.PERSONROLE_IN_OBJECTID,
				PIO_.ROLEID,
				R1.ROLE,
				R1.FIXED,
				PR.DISPLAYNAME,
				PR.EMAIL,
				PR.PHONE1,
				PR.PHONE2
		  FROM	dbo.TPERSONROLE_IN_OBJECT	PIO_
		  JOIN	dbo.TROLE					R1
			ON	R1.ROLEID					= PIO_.ROLEID
		  JOIN	dbo.TPERSON					PR
			ON	PIO_.PERSONID				= PR.PERSONID
		 WHERE  PIO_.OBJECTTYPEID			= (
				SELECT  OBJECTTYPEID
				  FROM  TOBJECTTYPE
				 WHERE  FIXED = 'PROJECT'
				)
		)								PIO
	ON	P.PROJECTID						= PIO.OBJECTID
  LEFT  OUTER
  JOIN  (
		SELECT  DIO_.DEPARTMENTID,
				DIO_.DEPARTMENTROLE_IN_OBJECTID,
				DIO_.OBJECTID,
				DIO_.OBJECTTYPEID,
				DIO_.ROLEID,
				R2.ROLE,
				R2.FIXED,
				D.DEPARTMENT
		  FROM	dbo.TDEPARTMENTROLE_IN_OBJECT	DIO_
		  JOIN	dbo.TROLE						R2 
			ON	DIO_.ROLEID						= R2.ROLEID
		  JOIN	dbo.TDEPARTMENT					D
			ON	DIO_.DEPARTMENTID				= D.DEPARTMENTID
		 WHERE	DIO_.OBJECTTYPEID				= (
				SELECT  OBJECTTYPEID
				  FROM  TOBJECTTYPE
				 WHERE  FIXED = 'PROJECT'
				)
		)								DIO
	ON	DIO.OBJECTID					= P.PROJECTID
 ORDER	BY
		P.PROJECT_NUMBER

GO
/****** Object:  View [dbo].[VWorkflowProcess]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VWorkflowProcess]
AS
SELECT     dbo.TWorkflowProcessActivity.WorkflowProcessActivity, dbo.TWorkflowProcessActivity.WorkflowProcessActivityID, 
                      dbo.TWorkflowProcessActivity.WorkflowRoleID, dbo.TWorkflowRole.WorkflowRole, dbo.TSTATUS.STATUS, dbo.TWorkflowProcess.WorkflowProcessID, 
                      dbo.TWorkflowProcess.WorkflowDefinitionID, dbo.TWorkflowProcess.WorkflowProcess, dbo.TWorkflowProcess.TimeStarted, 
                      dbo.TWorkflowProcess.TimeFinished, dbo.TWorkflowProcess.StartedByUserId, dbo.TWorkflowProcess.STATUSID, 
                      dbo.TWorkflowProcess.InstantiatingActivityLineID, dbo.TWorkflowProcess.WorkflowProcessPlanID, dbo.TSTATUS.FIXED, 
                      dbo.TWorkflowRole.FIXED AS ROLEFIXED, dbo.TSTATUS.MIK_VALID
FROM         dbo.TWorkflowProcess RIGHT OUTER JOIN
                      dbo.TSTATUS ON dbo.TWorkflowProcess.STATUSID = dbo.TSTATUS.STATUSID RIGHT OUTER JOIN
                      dbo.TWorkflowProcessActivity RIGHT OUTER JOIN
                      dbo.TWorkflowRole ON dbo.TWorkflowProcessActivity.WorkflowRoleID = dbo.TWorkflowRole.WorkflowRoleID ON 
                      dbo.TWorkflowProcess.WorkflowProcessID = dbo.TWorkflowProcessActivity.WorkflowProcessID





GO
/****** Object:  View [dbo].[VWorkflowProcessActivityLine]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VWorkflowProcessActivityLine]
AS
SELECT     dbo.TWorkflowProcessActivityLine.WorkflowProcessActivityLineID, dbo.TWorkflowProcessActivityLine.Sequence,
                      dbo.TWorkflowProcessActivityLine.WorkflowProcessActivityLine, dbo.TWorkflowProcessActivityLine.TimeStarted AS ActivityLine_TimeStarted,
                      dbo.TWorkflowProcessActivityLine.TimeFinished AS ActivityLine_TimeFinished, dbo.TWorkflowProcessActivityLine.WorkflowProcessActivityID,
                      dbo.TWorkflowProcessActivityLine.STATUSID AS ActivityLine_STATUSID,
                      dbo.TWorkflowProcessActivityLine.GraphNodeKey AS ActivityLine_GraphNodeKey,
                      dbo.TWorkflowProcessActivityLine.StartedByUserId AS ActivityLine_StartedByUserId, dbo.TWorkflowProcessActivityLine.WorkflowServiceOperationID,
                      dbo.TWorkflowProcessActivity.WorkflowProcessActivity, dbo.TWorkflowProcessActivity.WorkflowProcessID,
                      dbo.TWorkflowProcessActivity.GraphNodeKey AS Activity_GraphNodeKey, dbo.TWorkflowProcessActivity.WorkflowRoleID,
                      dbo.TWorkflowProcess.WorkflowDefinitionID AS Process_WorkflowDefinitionID, dbo.TWorkflowProcess.BPEL AS Process_BPEL,
                      dbo.TWorkflowProcess.WorkflowProcess, dbo.TWorkflowProcess.TimeFinished AS Process_TimeFinished,
                      dbo.TWorkflowProcess.StartedByUserId AS Process_StartedByUserId, dbo.TWorkflowProcess.STATUSID AS Process_STATUSID,
                      dbo.TWorkflowProcess.InstantiatingActivityLineID, dbo.TWorkflowProcess.WorkflowProcessPlanID,
                      dbo.TWorkflowProcess.TimeStarted AS Process_TimeStarted, dbo.TWorkflowDefinition.WorkflowDefinition,
                      dbo.TWorkflowDefinition.Description AS Definition_Description, dbo.TWorkflowDefinition.BPEL AS Definition_BPEL, dbo.TWorkflowDefinition.IsActive,
                      dbo.TWorkflowDefinition.IsTemplate, dbo.TWorkflowDefinition.MIK_VALID AS Definition_MIK_VALID,
                      dbo.TWorkflowDefinition.ProducesTransientProcess, dbo.TWorkflowDefinition.IsMainWorkflow, dbo.TWorkflowDefinition.IconId AS Definition_IconId,
                      dbo.TWorkflowServiceOperation.WorkflowServiceOperation, dbo.TWorkflowServiceOperation.DisplayName AS Operation_DisplayName,
                      dbo.TWorkflowServiceOperation.Description AS Operation_Description, dbo.TWorkflowServiceOperation.IsCallable,
                      dbo.TWorkflowServiceOperation.IsInteractive, dbo.TWorkflowServiceOperation.WorkflowServiceID, dbo.TWorkflowService.WorkflowService,
                      dbo.TWorkflowService.DisplayName AS Service_DisplayName, dbo.TWorkflowService.Description AS Service_Description,
                      dbo.TWorkflowService.IsNative, dbo.TWorkflowService.IconId AS Service_IconId, dbo.TWorkflowService.MIK_VALID AS Service_MIK_VALID,
                      dbo.TWorkflowService.WorkflowDefinitionID AS Service_WorkflowDefinitionID, dbo.TWorkflowService.ServiceURI,
                      TSTATUS_ActivityLine.STATUS AS ActivityLine_STATUS, TSTATUS_ActivityLine.FIXED AS ActivityLine_StatusFIXED, TSTATUS_Process.STATUS AS Process_STATUS, dbo.TWorkflowRole.WorkflowRole,
                      dbo.TWorkflowRole.FIXED AS WorkflowRole_FIXED, dbo.TWorkflowRole.ExternalSystemId AS WorkflowRole_ExternalSystemId,
                      TIcon_Definition.Icon AS Icon_Definition_Icon, TIcon_Definition.Image AS Icon_Definition_Image, TIcon_Service.Icon AS Icon_Service_Icon,
                      TIcon_Service.Image AS Icon_Service_Image, TWorkflowUser_ActivityLine.ExternalSystemId AS WorkflowUser_ActivityLine_ExternalSystemId,
                      TWorkflowUser_ActivityLine.ExternalUserId AS WorkflowUser_ActivityLine_ExternalUserId,
                      TWorkflowUser_ActivityLine.ExternalUserContext AS WorkflowUser_ActivityLine_ExternalUserContext,
                      TWorkflowUser_ActivityLine.Description AS WorkflowUser_ActivityLine_Description,
                      TWorkflowUser_Process.ExternalSystemId AS WorkflowUser_Process_ExternalSystemId,
                      TWorkflowUser_Process.ExternalUserId AS WorkflowUser_Process_ExternalUserId,
                      TWorkflowUser_Process.ExternalUserContext AS WorkflowUser_Process_ExternalUserContext,
                      TWorkflowUser_Process.Description AS WorkflowUser_Process_Description,
                      dbo.TWorkflowProcessPlan.WorkflowProcessPlan AS WorkflowProcessPlan,
                      dbo.TWorkflowProcessPlan.WorkflowDefinitionID AS Plan_WorkflowDefinitionID, dbo.TWorkflowProcessPlan.Description AS Plan_Description,
                      dbo.TWorkflowProcessPlan.PlannedTimeStarted AS Plan_PlannedTimeStarted,
                      dbo.TWorkflowProcessPlan.PlannedTimeFinished AS Plan_PlannedTimeFinished, dbo.TWorkflowProcessPlan.Duration AS Plan_Duration,
                      dbo.TWorkflowProcessPlan.ResponsibleUserID AS Plan_ResponsibleUserID, dbo.TWorkflowProcessPlan.OwnerUserID AS Plan_OwnerUserID,
                      dbo.TWorkflowProcessPlanActivity.WorkflowProcessPlanActivityID, dbo.TWorkflowProcessPlanActivity.WorkflowProcessPlanActivity,
                      dbo.TWorkflowProcessPlanActivity.GraphNodeKey AS PlanActivity_GraphNodeKey,
                      dbo.TWorkflowProcessPlanActivityLine.WorkflowProcessPlanActivityLineID, dbo.TWorkflowProcessPlanActivityLine.WorkflowProcessPlanActivityLine,
                      dbo.TWorkflowProcessPlanActivityLine.Description AS PlanActivityLine_Description,
                      dbo.TWorkflowProcessPlanActivityLine.PlannedTimeStarted AS PlanActivityLine_PlannedTimeStarted,
                      dbo.TWorkflowProcessPlanActivityLine.PlannedTimeFinished AS PlanActivityLine_PlannedTimeFinished,
                      dbo.TWorkflowProcessPlanActivityLine.GraphNodeKey AS PlanActivityLine_GraphNodeKey
FROM         dbo.TWorkflowProcessPlanActivity LEFT OUTER JOIN
                      dbo.TWorkflowProcessPlanActivityLine ON
                      dbo.TWorkflowProcessPlanActivity.WorkflowProcessPlanActivityID = dbo.TWorkflowProcessPlanActivityLine.WorkflowProcessPlanActivityID RIGHT OUTER
                       JOIN
                      dbo.TWorkflowProcessPlan ON
                      dbo.TWorkflowProcessPlanActivity.WorkflowProcessPlanID = dbo.TWorkflowProcessPlan.WorkflowProcessPlanID RIGHT OUTER JOIN
                      dbo.TWorkflowProcessActivityLine INNER JOIN
                      dbo.TWorkflowProcessActivity ON
                      dbo.TWorkflowProcessActivityLine.WorkflowProcessActivityID = dbo.TWorkflowProcessActivity.WorkflowProcessActivityID INNER JOIN
                      dbo.TWorkflowProcess ON dbo.TWorkflowProcessActivity.WorkflowProcessID = dbo.TWorkflowProcess.WorkflowProcessID INNER JOIN
                      dbo.TWorkflowDefinition ON dbo.TWorkflowProcess.WorkflowDefinitionID = dbo.TWorkflowDefinition.WorkflowDefinitionID INNER JOIN
                      dbo.TWorkflowServiceOperation ON
                      dbo.TWorkflowProcessActivityLine.WorkflowServiceOperationID = dbo.TWorkflowServiceOperation.WorkflowServiceOperationID INNER JOIN
                      dbo.TWorkflowService ON dbo.TWorkflowServiceOperation.WorkflowServiceID = dbo.TWorkflowService.WorkflowServiceID INNER JOIN
                      dbo.TSTATUS TSTATUS_ActivityLine ON dbo.TWorkflowProcessActivityLine.STATUSID = TSTATUS_ActivityLine.STATUSID INNER JOIN
                      dbo.TSTATUS TSTATUS_Process ON dbo.TWorkflowProcess.STATUSID = TSTATUS_Process.STATUSID ON
                      dbo.TWorkflowProcessPlan.WorkflowProcessPlanID = dbo.TWorkflowProcess.WorkflowProcessPlanID LEFT OUTER JOIN
                      dbo.TWorkflowRole ON dbo.TWorkflowProcessActivity.WorkflowRoleID = dbo.TWorkflowRole.WorkflowRoleID LEFT OUTER JOIN
                      dbo.TWorkflowUser TWorkflowUser_ActivityLine ON
                      dbo.TWorkflowProcessActivityLine.StartedByUserId = TWorkflowUser_ActivityLine.WorkflowUserId LEFT OUTER JOIN
                      dbo.TWorkflowUser TWorkflowUser_Process ON dbo.TWorkflowProcess.StartedByUserId = TWorkflowUser_Process.WorkflowUserId LEFT OUTER JOIN
                      dbo.TIcon TIcon_Definition ON dbo.TWorkflowDefinition.IconId = TIcon_Definition.IconId LEFT OUTER JOIN
                      dbo.TIcon TIcon_Service ON dbo.TWorkflowService.IconId = TIcon_Service.IconId

GO
/****** Object:  View [dbo].[VWorkflowUserInClientType]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VWorkflowUserInClientType]
AS
SELECT     u.WorkflowUserId, 
	   u.ExternalSystemId, 
	   u.ExternalUserId, 
	   u.ExternalUserContext, 
	   u.Description AS UserDescription, 
	   u.MIK_VALID, 
	   ct.ClientTypeId, 
           ct.ClientTypeName, 
           ct.FIXED, 
           ct.Description AS ClientTypeDescription
FROM         dbo.TWorkflowUser u 
		INNER JOIN dbo.TWorkflowUser_in_ClientType uct ON u.WorkflowUserId = uct.WorkflowUserId 
		INNER JOIN dbo.TClientType ct ON uct.ClientTypeId = ct.ClientTypeId


GO
/****** Object:  View [dbo].[VWorkflowYourTasks]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VWorkflowYourTasks]
AS
SELECT
  pal.WorkflowProcessActivityLineID
 ,ISNULL(ipal.WorkflowProcessActivityLine + '; ', '') + pal.WorkflowProcessActivityLine AS WorkflowProcessActivityLine
 ,pal.Context
 ,so.DisplayName AS WorkflowServiceOperation_DisplayName
 ,so.Description AS WorkflowServiceOperation_Description
 ,p.WorkflowProcess
 ,pal.TimeStarted AS ActivityLine_TimeStarted
 ,pal.TimeFinished AS ActivityLine_TimeFinished
 ,s.STATUS AS ActivityLine_Status
 ,r.WorkflowRole
 ,pal.STATUSID AS ActivityLine_StatusId
 ,s.FIXED AS ActivityLine_StatusFixed
 ,r.FIXED AS WorkflowRole_Fixed
 ,r.ExternalSystemId
 ,pal.StartedByUserId
 ,pa.WorkflowProcessActivityID
 ,pa.WorkflowProcessID
 ,pa.WorkflowRoleID
 ,p.TimeStarted AS Process_TimeStarted
 ,p.TimeFinished AS Process_TimeFinished
 ,p.StartedByUserId AS Process_StartedByUserId
 ,s2.STATUSID AS Process_StatusId
 ,s2.STATUS AS Process_Status
 ,s2.FIXED AS Process_StatusFixed
 ,pp.WorkflowProcessPlanID
 ,pp.PlannedTimeStarted AS Process_PlannedTimeStarted
 ,pp.PlannedTimeFinished AS Process_PlannedTimeFinished
 ,pp.Duration AS Process_PlannedDuration
 ,pp.ResponsibleUserID AS Process_ResponsibleUserId
 ,0 AS WorkflowProcessPlanActivityID
 ,0 AS WorkflowProcessPlanActivityLineID
 ,ppal.PlannedTimeStarted AS ActivityLine_PlannedTimeStarted
 ,ppal.PlannedTimeFinished AS ActivityLine_PlannedTimeFinished
 ,ppal.ResponsibleUserID AS ActivityLine_ResponsibleUserId
 ,pa.GraphNodeKey AS Activity_GraphNodeKey
 ,ppa.GraphNodeKey AS PlanActivity_GraphNodeKey
 ,DATEDIFF(DAY, GETDATE(), DATEADD(MI, DATEDIFF(MI, GETUTCDATE(), GETDATE()), ppal.PlannedTimeStarted)) AS noDfDaysToPlannedStarted
 ,DATEDIFF(DAY, pal.TimeFinished, GETDATE()) AS noOfDaysSinceActualFinished
 ,pp.WorkflowProcessPlan
 ,ppal.WorkflowProcessPlanActivityLine
 ,pp.ObjectID
 ,pp.ObjectTypeID
 ,ipal.WorkflowProcessActivityLine AS InstantiatingActivityLine
FROM dbo.TWorkflowProcessActivityLine AS pal
INNER JOIN dbo.TSTATUS AS s
  ON pal.STATUSID = s.STATUSID
INNER JOIN dbo.TWorkflowServiceOperation AS so
  ON pal.WorkflowServiceOperationID = so.WorkflowServiceOperationID
INNER JOIN dbo.TWorkflowProcessActivity AS pa
  ON pal.WorkflowProcessActivityID = pa.WorkflowProcessActivityID
INNER JOIN dbo.TWorkflowRole AS r
  ON pa.WorkflowRoleID = r.WorkflowRoleID
INNER JOIN dbo.TWorkflowProcess AS p
  ON pa.WorkflowProcessID = p.WorkflowProcessID
INNER JOIN dbo.TSTATUS AS s2
  ON p.STATUSID = s2.STATUSID
INNER JOIN dbo.TWorkflowDefinition wd
  ON p.WorkflowDefinitionID = wd.WorkflowDefinitionID
LEFT OUTER JOIN dbo.TWorkflowProcessPlan AS pp
  ON p.WorkflowProcessPlanID = pp.WorkflowProcessPlanID
LEFT OUTER JOIN dbo.TWorkflowProcessPlanActivity AS ppa
  ON pp.WorkflowProcessPlanID = ppa.WorkflowProcessPlanID
LEFT OUTER JOIN dbo.TWorkflowProcessPlanActivityLine AS ppal
  ON ppa.WorkflowProcessPlanActivityID = ppal.WorkflowProcessPlanActivityID
LEFT OUTER JOIN dbo.TWorkflowProcessActivityLine AS ipal
  ON ipal.WorkflowProcessActivityLineID = p.InstantiatingActivityLineID
WHERE (wd.ProducesTransientProcess = 0)

GO
/****** Object:  View [dbo].[zV_T_TheCompany_ALL_0_MigFlags]    Script Date: 24 Jun 2024 08:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[zV_T_TheCompany_ALL_0_MigFlags]

as

select 
	contractid as Contractid_Proc
	, UO_DPT_CODE as UO_DPT_CODE_Proc /* contract owner department code is procurement */
	, substring(UO_DPT_CODE,0,5) as GPROCSubstring /* first 4 characters of department code */

	/* user role department is attributed to Ariba - GP/IT */
	, (CASE WHEN Procurement_RoleFlag in ('GP','IT')
		THEN 'Y' ELSE 'N' END) as Proc_RoleFlag /* Procurement user department role - yes or no */

	, (CASE WHEN Procurement_AgTypeFlag = 3 /* $DPT */ then 
			(case when Procurement_RoleFlag in ('GP','IT')
				THEN 'Procurement by Dpt' ELSE 'Legal by Dpt' 
				END)  
			ELSE 'No $DPT Flag' end) 
		as Proc_RoleDptName

		/* Numeric flag for AGREEMENT_FIXED field without taking IC into account */
		, [Procurement_AgTypeFlag] as Proc_AgFixedFlag		
		
		, Procurement_AgTypeFlag as Proc_AgTypeICFlag /* no longer needed, can delete but first needs removing in reports */

		/* Friendly labels for all numeric flags including intercompany */
		, (CASE 
				WHEN Procurement_AgTypeFlag = 9 /* already migrated to Ariba */ THEN 'ARIBA (Migrated)'
				WHEN Procurement_AgTypeFlag = 4 /* intercompany */ THEN 'Intercompany'
				WHEN Procurement_AgTypeFlag = 3 THEN '$DPT' 
					+ (CASE WHEN Procurement_RoleFlag >'' THEN  '-' + Procurement_RoleFlag ELSE '' END)
				WHEN Procurement_AgTypeFlag = 6 THEN 'GxP' /* Gxp in contract title */
				WHEN Procurement_AgTypeFlag IN(0,1,2,5) then [TargetSystem_AgType] /* Agreement type only */
				ELSE 'N/A' /* no flag */
			END) as Proc_AgTypeICLabel

		/* Friendly labels with Legal/Intercompany combined in one flag Legal/IC */
		, (CASE 
				WHEN Procurement_AgTypeFlag = 9 /* already migrated to Ariba */ THEN 'ARIBA (Migrated)'
				WHEN Procurement_AgTypeFlag IN (1,2,5,7,8) THEN [TargetSystem_AgType] /* $ARIBA */
				WHEN Procurement_AgTypeFlag IN(0 /* Legal */, 4 /* Intercompany' */) THEN 'Legal/IC'
			/*	WHEN Procurement_AgTypeFlag = 2 THEN '$SPLIT'
				WHEN Procurement_AgTypeFlag = 3 THEN  '$DPT'
				WHEN Procurement_AgTypeFlag = 7 THEN  '$LG_MM' /* matter management */
				WHEN Procurement_AgTypeFlag = 8 THEN  '$IP_LIC'/* IP/Licensing */ */
				ELSE 'N/A'
			END) as Proc_AgTypeLabel

		, (CASE 
			/* WHEN COUNTERPARTYNUMBER like '!ARIBA%' THEN 'OTHER' /* Ariba, already migrated */ */
			WHEN Procurement_AgTypeFlag IN (0 /* LEGAL */, 4 /*IC*/, 6 /*GxP*/) THEN 'LINC'
			WHEN Procurement_AgTypeFlag IN ( 1 /* ARIBA */, 2 /* SPLIT */
											, 3 /* dpt*/, 5 /*other*/,7 ,8, 9 /* already migrated */ ) THEN 'OTHER'
			ELSE 'OTHER'	
			END)
		AS  MigrateToSystem_LNCCategory

		, (CASE 
			/* Prioritized */	
			WHEN Procurement_AgTypeFlag  = 9 /* already migrated */  THEN 'ARIBA'
			WHEN Procurement_AgTypeFlag = 1 THEN 'LINC, RIM or ARIBA' /* FIXED like '%+HCX%' */

			WHEN Procurement_AgTypeFlag = 4 /* Intercompany*/ THEN 'LINC'
			/* WHEN TargetSystem_AgTypeFLAG = 0 /* LEGAL */ THEN 'LINC' */
			WHEN Procurement_AgTypeFlag  = 6 /* Gxp is also LEGAL, manually review */ THEN 'LINC'			
			WHEN Procurement_AgTypeFlag in ( 0 /* LEGAL */ ) THEN 'LINC'

			
			WHEN Procurement_AgTypeFlag IN (2 /* split */, 3 /* dpt */, 5 /*other*/) THEN 'TBD' /* no HCX flag */
			WHEN Procurement_AgTypeFlag = 7 THEN 'iManage' /* matter management */
			WHEN Procurement_AgTypeFlag = 8 THEN 'IP/TM' /* IP/Licensing */		
			ELSE 'TBD'	
			END)
		AS  MigrateToSystem

		, (CASE	
			/* Prioritized */
			WHEN Procurement_AgTypeFlag  = 9 /* already migrated */  THEN 'ARIBA (already migrated)'
			WHEN Procurement_AgTypeFlag  = 4 /* Intercompany*/  THEN 'LINC (Intercompany)'
			WHEN Procurement_AgTypeFlag  = 6 /* Gxp is also LEGAL, manually review */ THEN 'LINC (GxP)'
			/* WHEN AgrType_IsHCX_Flag = 1 /* HCP/HCO */ THEN 'ARIBA (HCX)' */
			WHEN Procurement_AgTypeFlag = 0 /* LEGAL */ THEN 'LINC (Legal)' 	
			WHEN Procurement_AgTypeFlag = 1 /* ARIBA */ THEN 'LINC, RIM or ARIBA (HCX)'
			 	
			WHEN Procurement_AgTypeFlag = 2 /* Split */ THEN 'TBD' /* no HCX flag yet */
			WHEN Procurement_AgTypeFlag= 5 /* OTHER */ THEN 'TBD'/* 5 = other */ 
			WHEN Procurement_AgTypeFlag = 3 /* department */ THEN 'TBD' /* no HCX flag yet */

			WHEN Procurement_AgTypeFlag = 7 THEN 'iManage' /* matter management */
			WHEN Procurement_AgTypeFlag = 8 THEN 'IP/TM' /* IP/Licensing */		

			ELSE 'TBD'	
			END) + (case when [ConfidentialityFlag] = 'TOP SECRET' THEN ' - TOP SECRET?' else '' end)
		AS  MigrateToSystem_Detail

	, (CASE when a.statusid = 5 /* active */ then 1 /* all active agreements */
			When a.ConfidentialityFlag is not null then 1 /* if top secret or confidential */
			when a.Agr_IsMaterial_flag = 1 then 1 /* material agreements */
			WHEN DATEDIFF(mm,a.contractdate,GetDate()) <=24 THEN 1
			else 0 end)
		as MigrateYN_Flag

	, (CASE when a.statusid = 5 /* active */ then '1 - Active contract' /* all active agreements */
			When a.ConfidentialityFlag >'' then '2 - TS/Confidential' /* if top secret or confidential */
			when a.Agr_IsMaterial_flag = 1 then '3 - Material agreement' /* material agreements */
			WHEN DATEDIFF(mm,a.contractdate,GetDate()) <=24 THEN '4 - expired within 2 years'
			else '9 - Do not Migrate' end)
		as MigrateYN_Detail

/* master flag showing if contract is Ariba or Legal */	
	, (CASE WHEN Procurement_AgTypeFlag = 1 /* Ariba agreement type, excl. intercompany and GxP */ 
				OR (Procurement_AgTypeFlag = 3 /* $DPT split */  
					AND Procurement_RoleFlag in ('GP','IT'))  /* $DPT department split flag AND any user role is procurement*/ 
				THEN 1 /* Ariba */ ELSE 0 /* Legal */ END)  				
		as  Proc_NetFlag

/* master flag LABEL showing if contract is Ariba or Legal */		
	, (CASE WHEN Procurement_AgTypeFlag = 1 /* Ariba agreement type */ 
				OR (Procurement_AgTypeFlag = 3 /* $Dpt split */
					AND Procurement_RoleFlag in ('GP','IT')) /* $DPT department split flag AND any user role is procurement*/ 
				THEN 'PROCUREMENT' ELSE 'LEGAL' END)  				
		as  Proc_NetLabel
		
/*	if agreement type has department split, suffix it with ' - Procurement' in the field AGREEMENT_TYPE_WithProcurement */
			
	, (CASE WHEN Procurement_AgTypeFlag = 2 /* $DPT */
		THEN AGREEMENT_TYPE + 
			(case when Procurement_RoleFlag in ('GP','IT')
			THEN ' - Procurement' ELSE '' END) 
		ELSE AGREEMENT_TYPE END) as AGREEMENT_TYPE_WithProcurement
	
/* a procurement related product group was selected or applies according to the contract title */			
	, (CASE WHEN VP_IndirectProcurement>'' then 
			'Y'
			ELSE 'N' end) as Proc_HasProcProdGroupFlag



FROM T_TheCompany_ALL a
	/*INNER join [V_TheCompany_AgreementType] t /* TheCompany_2WEEKLY_Maintenance_AgreementTypes sets blank agreement types to type 'OTHER'*/
		on a.AGREEMENT_TYPEID = t.AgrTypeID /* needed to calculate flags */*/
	

	/* need not filter with WHERE, used in V_TheCompany_ALL */
/* WHERE
	CONTRACTTYPEID not in (11 /* Legal matter / Case */
						, 13 /* Test old */
						, 106 /* Test new*/) 
	AND NUMBER not like 'Xt%' /* divested products or sites */ */


GO
