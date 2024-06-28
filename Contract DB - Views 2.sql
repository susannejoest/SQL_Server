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
DUCTGROUP_TN_AI_INCL_INACTIVE]    Script Date: 24 Jun 2024 08:57:53 ******/
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
