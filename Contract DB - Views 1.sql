
/****** Object:  View [dbo].[V_TheCompany_KWS_2_JPS_TPRODUCT_ContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view

[dbo].[V_TheCompany_KWS_2_JPS_TPRODUCT_ContractID]
/* to do: include spaces with Productgroup name */
as 

	SELECT DISTINCT 
		s.*

		, t.CONTRACTID

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
		inner join T_TheCompany_ContractData_JPSunrise_Products_In_Contracts t on c.PRODUCTGROUPID = t.PRODUCTGROUPID
		inner join [dbo].[T_TheCompany_ContractData_JP_Sunrise_ExecutedAgreements] a on t.contractid = a.contractid
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
/****** Object:  View [dbo].[V_TheCompany_KWS_3_JPS_TPRODUCT_ContractID_Extended]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_KWS_3_JPS_TPRODUCT_ContractID_Extended]
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


	, [PrdGrpMatch_EXACT_Flag] 
		AS ProductMatch_Exact
	, (CASE when [KeyWord_ExclusionFlag] = 1 then 0
		/* WHEN [PrdGrpMatch_EXACT_Flag]=0 THEN 1 		 */
		ELSE 0 END) 
		AS ProductMatch_NotExact
	, [KeyWordVarchar255]
		AS ProductKeyword_Any

	FROM [dbo].[V_TheCompany_KWS_2_JPS_TPRODUCT_ContractID] u /* big definition query */
	WHERE u.contractid > 0 /* no NULLS */
	AND ( [KeyWord_ExclusionFlag] = 0 OR [PrdGrpMatch_EXACT_Flag] = 1) /* - only if exact match */

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_ARB_TCOMPANY_ContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view

[dbo].[V_TheCompany_KWS_2_ARB_TCOMPANY_ContractID]
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


		, c.[contractInternalID] as ContractID
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
		inner join [T_TheCompany_ContractData_ARB_1VCOMPANY] c
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
/****** Object:  View [dbo].[V_TheCompany_KWS_0Ariba_CompareVendorsToRawDump2]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create View

[dbo].[V_TheCompany_KWS_0Ariba_CompareVendorsToRawDump2]

as

select r.[Affected Parties - Common Supplier]
, (case when  CompanyCountry is null 
	or CompanyCountry = 'United States' 
	or CompanyCountry = ''
	or CompanyCountry like '%Unclassified%'
then 'USA or BLANK' else 'Non-US Country' END) as CompanyIsUS
, r.CompanyCountry
, MAX([Project - Project Name]) as MaxContractName
, COUNT(*) as ActiveContractCount	
from T_TheCompany_Ariba_Dump_Raw r 
inner join [dbo].[V_TheCompany_KWS_2_ARB_TCOMPANY_ContractID] c 
on r.[Project - Project Id] = c.ContractID
where State = 'Active'
group by r.[Affected Parties - Common Supplier]
, r.CompanyCountry
 /* order by r.[Affected Parties - Common Supplier] ASC, count(*) desc */


GO
/****** Object:  View [dbo].[VPRODUCTGROUPS_IN_CONTRACT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VPRODUCTGROUPS_IN_CONTRACT]
AS
SELECT     dbo.TPROD_GROUP_IN_CONTRACT.PRODUCTGROUPID, dbo.TPRODUCTGROUP.PRODUCTGROUP, 
                      dbo.TPRODUCTGROUPNOMENCLATURE.PRODUCTGROUPNOMENCLATURE AS Nomenclature, dbo.TPROD_GROUP_IN_CONTRACT.CONTRACTID, 
                      dbo.TPRODUCTGROUP.PRODUCTGROUPCODE, dbo.TPRODUCTGROUP.PRODUCTGROUPNOMENCLATUREID, dbo.TCONTRACT.PUBLISH, 
                      dbo.TCONTRACT.STATUSID
FROM         dbo.TCONTRACT RIGHT OUTER JOIN
                      dbo.TPROD_GROUP_IN_CONTRACT ON dbo.TCONTRACT.CONTRACTID = dbo.TPROD_GROUP_IN_CONTRACT.CONTRACTID LEFT OUTER JOIN
                      dbo.TPRODUCTGROUPNOMENCLATURE RIGHT OUTER JOIN
                      dbo.TPRODUCTGROUP ON 
                      dbo.TPRODUCTGROUPNOMENCLATURE.PRODUCTGROUPNOMENCLATUREID = dbo.TPRODUCTGROUP.PRODUCTGROUPNOMENCLATUREID ON 
                      dbo.TPROD_GROUP_IN_CONTRACT.PRODUCTGROUPID = dbo.TPRODUCTGROUP.PRODUCTGROUPID



GO
/****** Object:  View [dbo].[V_TheCompany_VPRODUCTGROUP]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_VPRODUCTGROUP]

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
	,(CASE WHEN p.PRODUCTGROUPID IN(select PRODUCTGROUPID from dbo.VPRODUCTGROUPS_IN_CONTRACT) THEN 1 ELSE 0 END) as ProductGroup_IsUsed
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
		(p.PRODUCTGROUPNOMENCLATUREID IN('2' /* API */,'3' /* TN */) 
		OR (p.PRODUCTGROUPNOMENCLATUREID = '7' /* Project ID, only if valid */ 
			AND p.MIK_VALID = 1))
		/*	and p.parentid = 2629 */
	/* AND LEN(PRODUCTGROUP)>3  e.g. GEM */
	/* and Productgroupid in (6196) */

GO
/****** Object:  View [dbo].[V_TheCompany_KeyWordSearch]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_KeyWordSearch]

as

	select 
		* 
	from T_TheCompany_KeyWordSearch


GO
/****** Object:  View [dbo].[V_TheCompany_KWS_5c_JPS_DESCRIPTION_ContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view 
[dbo].[V_TheCompany_KWS_5c_JPS_DESCRIPTION_ContractID]

as 

	SELECT  
		s.KeyWordVarchar255 as DescriptionKeyword
		, s.KeyWordType
		, p.CONTRACTID
		, p.contractnumber
	FROM [V_TheCompany_KeyWordSearch] s 
		inner join T_TheCompany_ContractData_JP_Sunrise_ExecutedAgreements p /* was left join leading to empty contract ids */
			on (p.[Name of Agreement] like 
				(CASE WHEN s.KeyWordLength < 4 THEN
				 '%[^a-z]'+s.KeyWordVarchar255+'[^a-z]%'
				 ELSE
				 '%'+s.KeyWordVarchar255+'%'
				 END)
			/* or title like kwdalphanum */)
	/* WHERE s.KeyWordType = 'Product' */
	WHERE 
		p.contractid not in (
			select contractid from T_TheCompany_KWS_3_JPS_TCompany_ContractID_Extended
				UNION
			select contractid from T_TheCompany_KWS_3_JPS_TProduct_ContractID_Extended
				UNION 
			select contractid from T_TheCompany_KWS_2_JPS_InternalPartner_ContractID
				UNION 
			select  contractid from T_TheCompany_KWS_2_JPS_Territories_ContractID
				UNION
			select contractid from T_TheCompany_KWS_2_JPS_TCOMPANYCountry_ContractID
		/*		UNION
			select contractid from T_TheCompany_KWS_2_JPS_Tag_ContractID */ 
			)

GO
/****** Object:  View [dbo].[V_TheCompany_VDepartment_Parsed]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view
[dbo].[V_TheCompany_VDepartment_Parsed]

as 
/* for hierarchy query */
select 
		*
		,(CASE WHEN LEFT(DEPARTMENT_CODE,1) IN (',','.',';') 
			THEN SUBSTRING(DEPARTMENT_CODE,2,2) ELSE NULL END) 
	AS DPT_CODE_2Digit_InternalPartner

	,  (CASE WHEN (LEFT(DEPARTMENT_CODE,1) = ';' and SUBSTRING(DEPARTMENT_CODE,4,1) in ('*','','#')) 
		THEN SUBSTRING(DEPARTMENT_CODE,2,2) ELSE NULL END) 
	AS [DPT_CODE_2Digit_TerritoryRegion]

	,    (CASE WHEN LEFT(DEPARTMENT_CODE,1) IN (',','.',';') 
		THEN SUBSTRING(DEPARTMENT_CODE,2,2) ELSE NULL END) 
		AS DPT_CODE_2Digit

	  ,(CASE 
	WHEN DEPARTMENT_CODE IS NULL THEN NULL
	WHEN  LEFT(DEPARTMENT_CODE,1) in(':','#') THEN 'Area' 
	WHEN LEFT(DEPARTMENT_CODE,1) in ('.',';',',') THEN  'Country Dpt IP' 
	WHEN LEFT(DEPARTMENT_CODE,1)='-' THEN 'Department' 
	ELSE 'Other' END) 
	  as FieldCategory

	   ,(CASE 
	WHEN DEPARTMENT_CODE IS NULL THEN NULL
	WHEN  LEFT(DEPARTMENT_CODE,1) in(':','#') THEN 
	(CASE WHEN [PARENTID] = 100100 /*[DEPARTMENTLEVEL] = 1*/ THEN 'Region' ELSE 'Area' END)
	WHEN LEFT(DEPARTMENT_CODE,1) =',' THEN  'Internal Partner' 
	WHEN LEFT(DEPARTMENT_CODE,1) =';' THEN  'Country' 
	WHEN LEFT(DEPARTMENT_CODE,1) ='.' THEN  'Country Department' 
	WHEN LEFT(DEPARTMENT_CODE,1)='-' THEN 'Department' 
	ELSE 'Other' END) AS NodeType

	   ,(CASE 
	WHEN DEPARTMENT_CODE IS NULL THEN NULL
	WHEN LEFT(DEPARTMENT_CODE,1) in('.',':','-') THEN 'D' 
	WHEN LEFT(DEPARTMENT_CODE,1) =',' THEN  'I' 
	WHEN  LEFT(DEPARTMENT_CODE,1) in(';','#') THEN 'T' 
	ELSE 'Other' END) AS NodeRole

	, (CASE WHEN DEPARTMENT_CODE like '%[*][*]%' THEN 2 
		WHEN DEPARTMENT_CODE like '%[*]%' THEN 1 
		ELSE 0 END) AS NodeMajorFlag  
	, len([DEPARTMENT]) as Dpt_LEN 
	, charindex(')', [DEPARTMENT] )+1 as Dpt_CharInd_BracketClose
FROM TDEPARTMENT d
/* WHERE  /* MIK_VALID = 1 AND */
	DEPARTMENT_CODE like ',%' /* Internal Partners only */ */

GO
/****** Object:  View [dbo].[V_TheCompany_Hierarchy_NewTry]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view  [dbo].[V_TheCompany_KWS_0_ContikiView_LNC]

as 

select 

     convert(varchar(255),[Reference] ) AS  [ContractNumber]
      , left([Contract title] 
		+ (case when [Study] is null then  '' else ' - Study: ' + [Study] end
		+ (case when [Description] /* NOW ALSO IN COMMENTS FIELD */ is null then '' else ' - ' + [Description] end)

		/* ntext must be converted to varchar(255) , max 1500 char */
		) ,255)
		as [Contract Description]
	  , '' as [Contract Relation]
      , [Contract Type] as [Agreement Type]
	  , [Material contract] as 'Agreement Type Divestment'	 
      ,[Status] /* State = 'Active', 'Completed' 
	  means [Contract Status] of Published, Draft, Draft Amendment, Pending, On Hold, or Expired */
      ,convert(date,[Start Date]) AS [Registered Date] /* for migrated contracts this seems to be the import date */
      ,'' AS [Reg Date Cat]
      , convert(date,[Start Date]) as [Start Date] /*[EndDateDate]*/
      , convert(date,[End Date]) as [End Date] /*[ExpirationDateDate]*/
      , convert(date,NULL) AS [Review Date]
      , convert(date,NULL) AS [Review Date Reminder]
	  /* , isnull([study number],'') as [Study Number] */
	  , [compound/product] as [All Products]
      /* ,isnull([Additional Comments],'') as [Comments] */
      ,0 AS [Number of Attachments]

      ,(CASE WHEN [Contract Type] <> 'Inter Company Agreements' THEN [Outside party] ELSE 'Intercompany TheCompany (Two or more TheCompany Entities)' END) as [Company Names] /* Inter Company Agreements where contractid = 'TAX-18003134' */
      
	  ,0 AS [Company Count] 
	  , '' as [Company Countries] 
      ,'' as [Confidentiality Flag]
       ,'' AS [Super User Email]
      ,'' AS [Super User Primary User Group]
      ,0 as [Super User Active Flag]
      , '' as [Owner Name]
      , '' as [Owner Email]
      , [Business unit] AS [Owner Primary User Group]
      , '' AS [Contract Responsible Email]
      , '' AS [Responsible Primary User Group]
   
      , [TheCompany entity/first party] AS [Internal Partners]  
      , 0 AS [Internal Partners Count]
      , '' AS [Territories]
      , null AS [Territories Count]
      , '' AS [Active Ingredients]
      , '' AS [Trade Names]
      , [Total or max value] as [Lump Sum]
      , [Currency] as [LumpSumCurrency]
      , '' as [Tags] /* DP schedule  */
      , '' as [L0]
      , '' as[L1] /* not the owner region like in Contiki but all we have */
      , '' as [L2]
      , '' as [L3]
      , '' as [L4]
      , 'Contract' as [Contract Type (CategoryContract)] /* do not mix up with agreement type !*/
	   	  , convert(varchar(255),[Reference] )  AS 'ContractID'
		/*  	  , NULL as AGREEMENT_TYPEID */
		, '' AS [Company Country is US]
		, left([Description],255) as Comments

	/* Link and Date */
      , 'https://shire.axxerion.us/axxerion/sso' as [LinkToContractURL]
      , [DateTableRefreshed] 

  FROM [dbo].[T_TheCompany_KWS_0_Data_LINC] d
  where Reference = 'TAX-18003134'
GO
/****** Object:  View [dbo].[V_TheCompany_KWS_5c_LNC_DESCRIPTION_ContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view 
[dbo].[V_TheCompany_KWS_5c_LNC_DESCRIPTION_ContractID]

as 

	SELECT  
		s.KeyWordVarchar255 as DescriptionKeyword
		, s.KeyWordType
		, p.CONTRACTID
		, p.contractnumber
	FROM [V_TheCompany_KeyWordSearch] s 
		inner join V_TheCompany_KWS_0_ContikiView_LNC p /* was left join leading to empty contract ids */
			on (p.[Contract Description] like 
				(CASE WHEN s.KeyWordLength < 4 THEN
				 '%[^a-z]'+s.KeyWordVarchar255+'[^a-z]%'
				 ELSE
				 '%'+s.KeyWordVarchar255+'%'
				 END)
			/* or title like kwdalphanum */)
	/* WHERE s.KeyWordType = 'Product' */
	  WHERE 
		p.contractid not in (
			select contractid from T_TheCompany_KWS_3_LNC_TCompany_ContractID_Extended
			/* DOES NOT EXIST YET  UNION
			select contractid from V_TheCompany_KWS_3_LNC_TProduct_ContractID_Extended */
				UNION
			select contractid from T_TheCompany_KWS_2_LNC_InternalPartner_ContractID
			/*	UNION 
			 DOES NOT EXIST YET select  contractid from T_TheCompany_KWS_2_LNC_Territories_ContractID
				UNION 
			select contractid from T_TheCompany_KWS_2_LNC_TCOMPANYCountry_ContractID
				UNION */
		/*	select contractid from T_TheCompany_KWS_2_LNC_Tag_ContractID */
			)  

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_0_ContikiView_JPS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view  [dbo].[V_TheCompany_KWS_0_ContikiView_JPS]

as 

select 

      [Contractnumber] as [Contractnumber]
      , [Name of Agreement] as [Contract Description]
	  , '' as [Contract Relation]
      , [dbo].[TheCompany_RemoveNonAlphaNonSpace]( [Category(master)]) as [Agreement Type] /* 0002 License out */
	  , 'Yes' as 'Agreement Type Divestment'	 
      , 'Active' as [Status] /* State = 'Active', 'Completed' 
		means [Contract Status] of Published, Draft, Draft Amendment, Pending, On Hold, or Expired */
      
	  , convert(date,[Created]) AS [Registered Date] /* for migrated contracts this seems to be the import date */
      ,'' AS [Reg Date Cat]
      , CONVERT(date, [Execution Date])  as [Start Date] /*[EndDateDate]*/
      , CONVERT(date, null) as [End Date] /*[ExpirationDateDate]*/
      , CONVERT(date, null) AS [Review Date]
      , CONVERT(date, null) AS [Review Date Reminder]
	  /* , isnull([study number],'') as [Study Number] */
	  , [ProductClean] as [All Products]
      /* ,isnull([Additional Comments],'') as [Comments] */
      , 0 AS [Number of Attachments]
	  /* [Client(master)] */
      , ISNULL([Company],'') as [Company Names] /* do not use all suppliers concat, since project name is also there */
      , 1 AS [Company Count], '' as [CompanyCountries]
      , '' as [Confidentiality Flag]
       , 'Yukako.Ichiyanagi@TheCompany.com' AS [Super User Email]
      , 'International Legal, Japan' AS [Super User Primary User Group]
      , 1 as [Super User Active Flag]
      , [Person in charge] as [Owner Name]
      , '' as [Owner Email]
      , '' AS [Owner Primary User Group]
      , '' AS [Contract Responsible Email]
      ,'' AS [Responsible Primary User Group]
   
      , [Internal_Partner] AS [Internal Partners]  
      , 1 AS [Internal Partners Count]
      , [dbo].[TheCompany_RemoveNonAlphaNonSpace]([Territory(master)]) AS [Territories] /* remove 001 etc. */
      , (case when [Territory(master)] IS null then 0 else 1 end) AS [Territories Count]
      , '' AS [Active Ingredients]
      , '' AS [Trade Names]
      , NULL as [Lump Sum]
      , 'JPY' as [LumpSumCurrency]
      , '' as [Tags]
      ,  '' as [L0]
      , '' as [L1] /* not the owner region like in Contiki but all we have */
      , '' as [L2]
      , '' as [L3]
      , '' as [L4]
      ,'Contract' as [Contract Type (Contract Case)] /* do not mix up with agreement type */
	   , convert(varchar, [CONTRACTID]) AS CONTRACTID
		/*  	  , NULL as AGREEMENT_TYPEID */

	  ,(case when [companycountry] In ('United States', 'USA','US') THEN 'US' else 'Non-US' END) 
		AS [Company Country is US]
		, '' as Comments

	/* Link and Date */
      ,'https://myTheCompany.sharepoint.com/teams/site002-2/lcdb/Lists/List_e/DispForm.aspx?ID=' + convert(varchar(255),ContractID) as [LinkToContractURL]
      ,[DateTableRefreshed] as [DateTableRefreshed] 

	  /* ,(case when [contractnumber] in (select [TxtFldUnique] from [dbo].[T_TheCompany_Adhoc_ContractNumber]) Then 1 else 0 end) as ListFlag */
  FROM [dbo].[T_TheCompany_ContractData_JP_Sunrise_ExecutedAgreements] d

GO
/****** Object:  View [dbo].[V_TheCompany_KWSR_0_JPS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[V_TheCompany_KWSR_0_JPS]
/* be sure to run [TheCompany_KeyWordSearch] */
as

		SELECT
		 LTRIM((CASE WHEN isnull(u.ProductKeyword_Any,'') >'' THEN ' Product' ELSE '' END)
		 + 	(CASE WHEN isnull(u.CompanyMatch_score,0) >0 THEN u.CompanyMatch_LevelCategory
				  ELSE '' END)
		 + 	(CASE WHEN isnull(u.Description_Match,'') >'' THEN ' ' + ' Description' ELSE '' END)
		 + 	(CASE WHEN isnull(u.AgreementType_Match,'') >'' THEN ' ' + ' AgreementType' ELSE '' END)
		 + 	(CASE WHEN isnull(u.InternalPartner_Match,'') >'' THEN ' ' + ' InternalPartner' ELSE '' END)
		 + 	(CASE WHEN isnull(u.Territory_Match,'') >'' THEN ' ' + ' Territory' ELSE '' END)	
		 + 	(CASE WHEN isnull(u.CompanyCountryMatch,'') >'' THEN ' ' + ' Country(Company)' ELSE '' END)	
		 + 	(CASE WHEN isnull(u.TagCategory_Match,'') >'' THEN ' ' + ' TagCategory' ELSE '' END)			 
		 )
			 as MatchLevel

	/* FOUND KEYWORD - found in search, not original keyword */
		, convert(varchar(255),left(LTRIM((CASE WHEN isnull(u.ProductKeyword_Any,'') > '' 
			then isnull(u.ProductKeyword_Any,'') + ' (Product); ' ELSE '' END)
			 + (CASE WHEN isnull(u.CompanyMatch_Score,0) >0 THEN  ' ' /* is the keyword not found company */
			/*			+ u.companyMatch_Name + ' (Company, ' + convert(varchar(2),u.companymatch_score) + ');' ELSE '' END)*/
				+ isnull(u.CompanyMatch_Name,'') /* keyword instead */+ ' (Company); ' ELSE '' END)
			 + (CASE WHEN isnull(u.Description_Match,'') >'' THEN ' ' 
				+ u.Description_Match + ' (Desc); ' ELSE '' END)
			 + (CASE WHEN isnull(u.AgreementType_Match,'') >'' THEN ' ' 
				+ u.AgreementType_Match + ' (AgrmtType); ' ELSE '' END)
			 + (CASE WHEN isnull(u.InternalPartner_Match,'') >'' THEN ' ' 
				+ u.InternalPartner_Match + ' (IP); ' ELSE '' END)
			 + (CASE WHEN isnull(u.Territory_Match,'') >'' THEN ' ' 
				+ u.Territory_Match + ' (TT); ' ELSE '' END) 
			 + (CASE WHEN u.CompanyCountryMatch >'' THEN ' ' 
				+ u.CompanyCountryMatch + ' (CompanyCty); ' ELSE '' END) 
			 + (CASE WHEN isnull(u.TagCategory_Match,'') >'' THEN ' ' 
				+ u.TagCategory_Match + ' (TagCat); ' ELSE '' END) 
				),255))
			 as KeywordMatch_Found

	/* ORIGINAL KEYWORD - from input list */

		, convert(varchar(255),left(LTRIM((CASE WHEN isnull(u.ProductKeyword_Any,'') > '' 
			then u.ProductKeyword_Any + ' (Product); ' ELSE '' END)
			 + (CASE WHEN isnull(u.CompanyMatch_score,0) >0 THEN  ' ' /* is the keyword not found company */
			/*			+ u.companyMatch_Name + ' (Company, ' + convert(varchar(2),u.companymatch_score) + ');' ELSE '' END)*/
				+ companymatch_keyword /* keyword instead *//*+ ' (Company)*/ +'; ' ELSE '' END)
			 + (CASE WHEN isnull(u.Description_Match,'') >'' THEN ' ' 
				+ u.Description_Match + ' (Desc); ' ELSE '' END)
			 + (CASE WHEN isnull(u.AgreementType_Match,'') >'' THEN ' ' 
				+ u.AgreementType_Match + ' (AgrmtType); ' ELSE '' END)
			 + (CASE WHEN isnull(u.InternalPartner_Match,'') >'' THEN ' ' 
				+ u.InternalPartner_Match + ' (IP); ' ELSE '' END)
			 + (CASE WHEN isnull(u.Territory_Match,'') >'' THEN ' ' 
				+ u.Territory_Match + ' (TT); ' ELSE '' END) 
			 + (CASE WHEN isnull(u.CompanyCountryMatch,'') >'' THEN ' ' 
				+ u.CompanyCountryMatch + ' (CompanyCty); ' ELSE '' END) 
			 + (CASE WHEN isnull(u.TagCategory_Match,'') >'' THEN ' ' 
				+ u.TagCategory_Match + ' (TagCat); ' ELSE '' END) 
				),255))
			 as KeywordMatch_Original

/*		, LTRIM((CASE WHEN u.ProductKeyword_Any > '' 
			then 1 ELSE 0 END)
			 + (CASE WHEN u.CompanyMatch_score >0 THEN companymatch_Score ELSE o END)
	/*		 + (CASE WHEN u.Description_Match >'' THEN ' ' 
				+ u.Description_Match + ' (Desc); ' ELSE '' END)
			 + (CASE WHEN u.InternalPartner_Match >'' THEN ' ' 
				+ u.InternalPartner_Match + ' (IP); ' ELSE '' END)
			 + (CASE WHEN u.Territory_Match >'' THEN ' ' 
				+ u.Territory_Match + ' (TT); ' ELSE '' END) 
			 + (CASE WHEN u.CompanyCountryMatch >'' THEN ' ' 
				+ u.CompanyCountryMatch + ' (CompanyCty); ' ELSE '' END) 
			 + (CASE WHEN u.TagCategory_Match >'' THEN ' ' 
				+ u.TagCategory_Match + ' (TagCat); ' ELSE '' END) */
				)
			 as KeywordMatch_Score
		*/

		/* PRODUCT */
			, u.ProductKeyword_Any as 'Product (Any)'
			 /*, p.[KeyWordMatch_TradeName]
			 , p.[KeyWordMatch_ActiveIngredients] */

		 /* COMPANY */
			, u.CompanyMatch_Score
			, u.companyMatch_Level
			, convert(varchar(255), u.CompanyMatch_Name) /* any */ as 'Company (ALL)'

			, convert(varchar(255), u.CompanyMatch_NotExactNotLike) as 'Company (Other)'/* CompanyMatch_KeyWord */
			, convert(varchar(255), u.CompanyMatch_Like) as 'Company (Like)'
			, convert(varchar(255), u.CompanyMatch_Exact) as 'Company (Exact)'
			, convert(varchar(1), U.companyType) as 'C. Type' /* I = Individual, C = Company, U = Undefined */

		/* COUNTRY */
			, convert(varchar(255), u.CompanyCountryMatch) as 'Company Country Match'

		/* DESCRIPTION */
			, u.Description_Match as 'Description Match Only'

		/* LISTS */
			, '' as 'KeyWordSource Lists'
			, convert(varchar(255), u.[Custom1_Lists]) as [Custom1_Lists]
			, convert(varchar(255), u.[Custom2_Lists]) as [Custom2_Lists]
		
		/* TERRITORIES, INTERNAL PARTNERS */
			, convert(varchar(255), u.Territory_Match) AS 'Territory Match'
			, convert(varchar(255), u.InternalPartner_Match) AS 'Internal Partner Match'
			, '' /*U.[TagCategory_Match] */ AS 'Full Text Tag Match'
			, u.AgreementType_Match AS 'Agreement Type Match'
					 
		 /* ALL */
		 , s.*
	 FROM   [V_TheCompany_KWS_0_ContikiView_JPS] s
			inner join T_TheCompany_KWS_7_JPS_ContractID_SummaryByContractID u
				on s.contractid = u.[ContractID]

GO
/****** Object:  View [dbo].[V_TheCompany_Edit_DuplicateCompanies_Base]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_TheCompany_Edit_DuplicateCompanies_Base]

as

	SELECT Company
	, LTRIM(RTRIM(UPPER(COMPANY))) AS CompanyTrim
	, c.COMPANYID
	, MAX(contractid) as ContractIDMax
	, MIN(contractid) as ContractIDMin
	, count(contractid) as ContractIDCount
	FROM TCOMPANY c left join ttenderer t on c.companyid = t.companyid 
	WHERE 
	MIK_VALID = 1 
	and c.COMPANYID <>1 /* Not Intercompany */
	group by LTRIM(RTRIM(UPPER(c.COMPANY))), c.company, c.companyid

GO
/****** Object:  View [dbo].[V_TheCompany_Edit_DuplicateCompanies]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[V_TheCompany_Edit_DuplicateCompanies]

as

SELECT 
CompanyTrim
, COUNT(COMPANYID) AS CompanyDupeCount
, MAX(COMPANYID) AS CompanyIDMax
, MIN(COMPANYID) AS CompanyIDMin
, MIN(contractidmin) as ContractIDMin
, Max(contractidmax) as ContractIdMax
, count(ContractIDCount) as ContractCount

,STUFF(
(SELECT ';' + CONVERT(nvarchar(255), cp.COMPANYid)
FROM TCOMPANY cp
WHERE LTRIM(RTRIM(UPPER(cp.COMPANY))) =CompanyTrim
FOR XML PATH('')),1,1,'') AS UniqueDuplicateID

,STUFF(
(SELECT ';' + CONVERT(nvarchar(255), cp.company)
FROM TCOMPANY cp
WHERE LTRIM(RTRIM(UPPER(cp.COMPANY))) =CompanyTrim
FOR XML PATH('')),1,1,'') AS CompanyList

FROM
	dbo.V_TheCompany_Edit_DuplicateCompanies_Base b
GROUP BY CompanyTrim
HAVING COUNT(COMPANYID)>1
 
GO
/****** Object:  View [dbo].[V_TheCompany_VDEPARTMENT_Entities_Diligent_Union_Alias]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_VDEPARTMENT_Entities_Diligent_Union_Alias]

as 

SELECT [EntityName] as DLE_EntityName /* Diligent name or Alias */
		, [EntityName] as DLE_EntityName_Main /* Diligent Name */
		, [EntityName_Clean] as DLE_EntityName_Clean /* Clean Diligent Name */
		, [AliasName] as DLE_EntityName_Alias /* Alias not in Diligent main name */
      ,[Country] as DLE_Country
      ,[SAP_Code] as DLE_SAP_Code
      ,[BP_QuickRef] as DLE_QuickRef

      ,[Status] as DLE_Status
      ,[Comments] as DLE_Comments
      ,[MaxNoSignatures] as DLE_MaxNoSignatures
      ,[SignatureRules] as DLE_SignatureRules
	  , left([dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]([EntityName]),255) as DLE_EntityName_NonFwSlash

	, dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([EntityName]) as DLE_EntityName_NonAlphaNonNum
	, 'NameMain' as DLE_EntMainNameOrAlias
from
	T_TheCompany_Entities_DiligentData

	UNION 

SELECT [AliasName] as DLE_EntityName /* Diligent name or Alias */
		, [EntityName] as DLE_EntityName_Main /* Diligent Name */
		, [EntityName_Clean] as DLE_EntityName_Clean /* Clean Diligent Name */
		, [AliasName] as DLE_EntityName_Alias /* Alias not in Diligent main name */
      ,[Country] as DLE_Country
      ,[SAP_Code] as DLE_SAP_Code
      ,[BP_QuickRef] as DLE_QuickRef
       
      ,[Status] as DLE_Status
      ,[Comments] as DLE_Comments
      ,[MaxNoSignatures] as DLE_MaxNoSignatures
      ,[SignatureRules] as DLE_SignatureRules
	  , left([dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]([AliasName]),255) as DLE_EntityName_NonFwSlash

	, dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([AliasName]) as DLE_EntityName_NonAlphaNonNum
	, 'NameAlias' as EntMainNameOrAlias
from
	T_TheCompany_Entities_DiligentData
	WHERE [AliasName] >''
		and AliasName <> 'Same'
		and AliasName <> [EntityName]
		and [dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]([AliasName]) <> [dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]([EntityName])

/* LINC */
UNION 

SELECT [EntityName_LINC] as DLE_EntityName
		, [EntityName] as DLE_EntityName_Main /* Diligent Name */
		, [EntityName_Clean] as DLE_EntityName_Clean /* Clean Diligent Name */
		, [EntityName_LINC] as DLE_EntityName_Alias
      ,[Country] as DLE_Country
      ,[SAP_Code] as DLE_SAP_Code
      ,[BP_QuickRef] as DLE_QuickRef
       
      ,[Status] as DLE_Status
      ,[Comments] as DLE_Comments
      ,[MaxNoSignatures] as DLE_MaxNoSignatures
      ,[SignatureRules] as DLE_SignatureRules
	  , left([dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]([EntityName_LINC]),255) as DLE_EntityName_NonFwSlash

	, dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([EntityName_LINC]) as DLE_EntityName_NonAlphaNonNum
	, 'NameAlias_LNC' as EntMainNameOrAlias
from
	T_TheCompany_Entities_DiligentData
	WHERE [EntityName_LINC] >''
		and [EntityName_LINC] <> [EntityName]
		and (AliasName  is null or [EntityName_LINC] <> AliasName)
		and [dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]([EntityName_LINC]) <> [dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]([EntityName])
		and [dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]([EntityName_LINC]) <> [dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]([AliasName])

GO
/****** Object:  View [dbo].[V_TheCompany_VDepartment_ParsedDpt_InternalPartner]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view
[dbo].[V_TheCompany_VDepartment_ParsedDpt_InternalPartner]

as 

select 
	d.DEPARTMENTID
	, d.DEPARTMENT
	, d.DEPARTMENT_CODE
	,len(d.DEPARTMENT_CODE) as LenDptCode
	, (case when CHARINDEX('[' /* branch office such as ,UKI,CHI[BranchOffice] */, d.DEPARTMENT_CODE) > 0 
			THEN 'BranchOffice' ELSE 'InternalPartner' END) as InternalPartnerType

/* fails if [BranchOffice] not prefixed by main office ,IEI,CHI#EU #CC1380[BranchOffice] */
	, (case when CHARINDEX('[' /* branch office such as ,UKI,CHI[BranchOffice] */, d.DEPARTMENT_CODE) > 0 
			THEN
			SUBSTRING(d.DEPARTMENT_CODE
					, (CHARINDEX(',', d.DEPARTMENT_CODE))+1 /* first , */
					, (charindex( ',', d.DEPARTMENT_CODE, charindex( ',', d.DEPARTMENT_CODE ) + 1 /* second , */ ))-2) 
					ELSE '' END) as DptCode_BranchOffice
	
	
	, (case when CHARINDEX('[' /* branch office such as ,UKI,CHI[BranchOffice] */, d.DEPARTMENT_CODE) > 0 
				THEN
					SUBSTRING(d.DEPARTMENT_CODE
							, (charindex( ',', d.DEPARTMENT_CODE, charindex( ',', d.DEPARTMENT_CODE ) + 1 /* second , */))+1
							,len(d.DEPARTMENT_CODE)
								- ((charindex( '[', d.DEPARTMENT_CODE)+1) +(charindex( ',', d.DEPARTMENT_CODE, charindex( ',', d.DEPARTMENT_CODE )) + 1)+2) 
								- charindex( ',', d.DEPARTMENT_CODE, charindex( ',', d.DEPARTMENT_CODE) + 1 )																	)
				ELSE '' END) as Dpt_Code_HeadOffice
				
	, (case when d.DEPARTMENT_CODE like '%Office%' /* Branch office only OR Rep office, both have main office reference such as ,chi */
				THEN
					(SELECT MAX(dd.DEPARTMENTID)
					FROM TDEPARTMENT dd
					WHERE 
						/* DL.d.DEPARTMENT_CODE like ',%' not needed */
						SUBSTRING(dd.DEPARTMENT_CODE,1,4) =  SUBSTRING(d.DEPARTMENT_CODE,5,4) /* ',CHI' */
						AND SUBSTRING(d.DEPARTMENT_CODE,5,1) like '%[^a-z]%')
				ELSE '' END) 
				as DptID_HeadOffice  
				
	/* Internal Partner - Code_Basic */
	, SUBSTRING(d.DEPARTMENT_CODE
				,CHARINDEX(',',d.DEPARTMENT_CODE)+1
				,(CASE WHEN d.DEPARTMENT_CODE LIKE '%(%' THEN CHARINDEX('(',d.DEPARTMENT_CODE)-2
					WHEN d.DEPARTMENT_CODE LIKE '%#%'  THEN CHARINDEX('#',d.DEPARTMENT_CODE)-2
					ELSE len(d.DEPARTMENT_CODE)END )
				) as Code_Basic /* e.g. CHI for TPIZ or IEI,CHI for TPIZ ireland branch office */
	, ',' + SUBSTRING(d.DEPARTMENT_CODE
				,CHARINDEX(',',d.DEPARTMENT_CODE)+1
				,(CASE WHEN d.DEPARTMENT_CODE LIKE '%(%' THEN CHARINDEX('(',d.DEPARTMENT_CODE)-2
					WHEN d.DEPARTMENT_CODE LIKE '%#%'  THEN CHARINDEX('#',d.DEPARTMENT_CODE)-2
					ELSE len(d.DEPARTMENT_CODE)END )
				) as Code_BasicIPWithCommaPrefix /* e.g. CHI for TPIZ or IEI,CHI for TPIZ ireland branch office */
	/* Internal Partner - Code_Shortcut */ 
, (CASE WHEN d.DEPARTMENT_CODE LIKE '%(%'
	THEN SUBSTRING(d.DEPARTMENT_CODE
	,CHARINDEX('(',d.DEPARTMENT_CODE) 
	,(CHARINDEX(')',d.DEPARTMENT_CODE)+1)-CHARINDEX('(',d.DEPARTMENT_CODE)) 
		ELSE '' END) as Code_Shortcut

	/* Internal Partner - Code_Areas */	
, (CASE WHEN d.DEPARTMENT_CODE LIKE '%#%'
	THEN SUBSTRING(d.DEPARTMENT_CODE
	,CHARINDEX('#',d.DEPARTMENT_CODE) 
	,3)
		ELSE '' END) as Code_Areas

, (Case 
	when d.PARENTID = 204318 then 'INACTIVE' /* Inactive tree */
	when (d.DEPARTMENT_CODE LIKE ',%' 
		AND d.parentid <> 10004 /* IP Root */ /* SUBSTRING(d.DEPARTMENT_CODE,5,1) LIKE ('[A-Z]' */	)
	THEN 'INACTIVE' 
	WHEN d.DEPARTMENT_CODE like '%INACTIVE%' then 'INACTIVE'
	ELSE 'Active' END) as InternalPartnerStatus

, (Case 
	when d.PARENTID = 204318 then '[***INACTIVE*(Tree)]' /* Inactive tree */
	when (d.DEPARTMENT_CODE LIKE ',%' 
		AND d.parentid <> 10004 /* IP Root */ /* SUBSTRING(d.DEPARTMENT_CODE,5,1) LIKE ('[A-Z]' */	)
	THEN '[***INACTIVE*(merged)]' 
	WHEN d.DEPARTMENT_CODE like '%INACTIVE%' then '[***INACTIVE(DptCode)]'
	ELSE 'Active' END) as InternalPartnerStatus_Detail

, (Case when (d.DEPARTMENT_CODE LIKE ',%' 
	AND d.parentid <> 10004 /* IP Root */ /* SUBSTRING(d.DEPARTMENT_CODE,5,1) LIKE ('[A-Z]' */
	)
	THEN 0 ELSE -1 END) as InternalPartnerStatusFlag
	
	/* Country Name Prefix e.g. Germany */

		  , convert(varchar(25) /* Bosnia and Herzegovina = 22 */,replace((left(d.[DEPARTMENT]
			, charindex(')', d.[DEPARTMENT] + ')') - 1)),'(','') )
	  as InternalPartner_CountryPrefix
	  	 
		  , (case when /*mik_valid = 1 and  */ charindex(')', d.[DEPARTMENT] ) >1 
				THEN (case when LEN(d.[DEPARTMENT])>0 
				THEN right(d.[DEPARTMENT], LEN(d.[DEPARTMENT])
					- charindex(')', d.[DEPARTMENT])-1) 
					else '' end)
			else '' 
			end) 
		as InternalPartner_Name	

		  , left([dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]((case when /*mik_valid = 1 and  */ charindex(')', d.[DEPARTMENT] ) >1 
				THEN (case when LEN(d.[DEPARTMENT])>0 
				THEN right(d.[DEPARTMENT], LEN(d.[DEPARTMENT])
					- charindex(')', d.[DEPARTMENT])-1) 
					else '' end)
			else '' 
			end) ),255)
		as InternalPartner_Name_NonSpaceFwSlash	
		

		  , dp.DEPARTMENT as IP_ParentName
		  	  , d.PARENTID
		  	, d.DEPARTMENTLEVEL as IP_Departmentlevel
	, d.MIK_VALID

/* Blueprint */

		  /* T_TheCompany_Blueprint_Mapping */
		  , m.[Bp_CompanyStatus_Code] 
		  , m.[Bp_CompanyName]
		, m.[Bp_CompanyQuickRef]

		/* T_TheCompany_Blueprint_CompanyReport */
		/* , c.[Company Name] as BP_CompanyName */
		 /* , c.[QuickRef] as BP_QuickRef */
		  , c.[Company number] as BC_CompanyNumber

		  , c.[Country]  as BC_Country
		 /* , c.[Company status] as BP_CompanyStatus
		  , c.[Company status (code)] as BP_CompanyStatusCODE */
		  , c.[Company Sub-Category] as BC_CompanySubCategory
		  , c.[Country (Code)] as BC_CountryCode
		  , c.[Country region] as BC_CountryRegion
		  , c.[Country Region (Code)] as  BC_CountryRegionCODE
		  , c.[Company Type] as BC_CompanyType
		  , c.[Company's occupation] as BC_CompanyOccupation
		  , c.[Company type (code)] as BC_CompanyType_CODE
		  , c.[Company Key] as BC_CompanyKey
		  , c.[Company Category] as  BC_CompanyCategory
		  , c.[Entity type] as BC_EntityType

		  , IP_Count_Contracts 

		  	, (CASE 
				/* Normal or Branch (own cc), no rep office */
				WHEN charindex('#CC', d.[DEPARTMENT_Code])>0 
					and d.DEPARTMENT_CODE not like '%Repoffice%' /* not rep office */
					THEN 
					SUBSTRING(d.[DEPARTMENT_CODE],charindex('#CC', d.[DEPARTMENT_code])+3,4)
				/* Rep offices do not have own cost center, use main cc with suffix */
				WHEN charindex('#CC', d.[DEPARTMENT_Code])>0 
					and d.DEPARTMENT_CODE like '%Repoffice%' 
					THEN 
					SUBSTRING(d.[DEPARTMENT_CODE],charindex('#CC', d.[DEPARTMENT_code])+3,4)
						+ substring(d.[DEPARTMENT_code],6,2) /* append country code */
				ELSE '' END)
		 as IP_CostCenter /*	#CC3879*/

		  	, (CASE 
				WHEN charindex('#CC', d.[DEPARTMENT_Code])>0 
					THEN 
					SUBSTRING(d.[DEPARTMENT_CODE],charindex('#CC', d.[DEPARTMENT_code])+3,4)				
			ELSE '' END)
		 as IP_CostCenter_NonUnique /*	dupe if rep branch offices exist */
		 /* letters and special chars convert like espanja
		  */
		 , convert(varchar(255),dbo.TheCompany_RemoveAccents_Varchar255(dbo.TheCompany_RemoveNonAlphaCharacters(
		 (case when /*mik_valid = 1 and  */ charindex(')', d.[DEPARTMENT] ) >1 
				THEN (case when LEN(d.[DEPARTMENT])>0 
				THEN right(d.[DEPARTMENT], LEN(d.[DEPARTMENT])
					- charindex(')', d.[DEPARTMENT])-1) 
					else '' end)
			else '' 
			end) ) ))
			as InternalPartnerName_LettersOnly

		, (case 
			when d.DEPARTMENT_CODE like '%#CC8036%' then 1 /*TPIZ*/
			when m.Company_CC_4Digit = m.[Company_CC_4Digit_WithSuffix] then 2 /* is a head office */
			when d.DEPARTMENT_CODE not like '%office%' then 3 
			when d.DEPARTMENT_CODE like '%office%' then 4 else 9 END)
			as IP_Rank
			, 'CTK-IP-' + ltrim(str(d.DEPARTMENTID)) as LNC_InternalPartnerID
FROM  [dbo].[V_TheCompany_VDepartment_Parsed] d
		left join [dbo].[T_TheCompany_Entities_MappingDiligentContiki] m 
			on  d.[DEPARTMENTID] = m.[Cnt_CompanyID] 
				/* and m.[Cnt_CompanyID]  is not null */
		left join  [dbo].[T_TheCompany_Entities_zDiligentCompanyReport] c 
			 on c.[QuickRef] = m.[Bp_CompanyQuickRef]
		left join TDEPARTMENT dp on d.PARENTID = dp.DEPARTMENTID
		left join (select departmentid
			, count([DEPARTMENTROLE_IN_OBJECTID]
			) as IP_Count_Contracts 
			from [dbo].[TDEPARTMENTROLE_IN_OBJECT]
			group by departmentid) r on d.DEPARTMENTID = r.DEPARTMENTID
WHERE  /* MIK_VALID = 1 AND */
	d.DEPARTMENT_CODE like ',[a-z]%' /*error in Internal Partner clean formula without */
	and d.DEPARTMENTID not in (204113 /* docsign */)
	/* and d.DEPARTMENT_CODE like '%1350%' */
GO
/****** Object:  View [dbo].[V_TheCompany_VDEPARTMENT_Entities_LINC]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[V_TheCompany_VDEPARTMENT_Entities_LINC]

as 

	select 
		[Name] as LNC_EntityName
		  ,[Former name or alias] as LNC_EntityNameAlias
		  ,[Entity status] as LNC_EntityStatus
		  ,[External reference] as LNC_CompanyCode_ExternalReference
		  ,[AO] as LNC_AO
		  ,[Street address] as LNC_StreetAddress
		  ,[Category] as LNC_Category
		  ,[Contact] as LNC_Contact
		  ,[Distributor contact person] as LNC_DistributorContactPerson
		  ,[Email] as LNC_Email
		 /* ,[Phone]
		  ,[Team Contact]
		  ,[Contact1] */
		  ,[Description] as LNC_Description
		, dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([Name]) as LNC_EntityName_NonAlphaNonNum
		, left([dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]([Name]),255) as LNC_EntityName_NonFwSlash

		/* Internal Partner Table */
		, LNC_InternalPartnerID as CTK_InternalPartnerID
		, [InternalPartnerStatus] as 'CTK_InternalPartnerStatus'
		, BC_Country as CTK_Country
	from
		[dbo].[T_TheCompany_Entities_LINC] l left join 
			[dbo].[V_TheCompany_VDepartment_ParsedDpt_InternalPartner] p 
				on L.[External reference] = p.LNC_InternalPartnerID 
	WHERE LEN(Name)>3 /* no blanks */


GO
/****** Object:  View [dbo].[V_TheCompany_VDEPARTMENT_Entities_DiligentAndLINC]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view

[dbo].[V_TheCompany_VDEPARTMENT_Entities_DiligentAndLINC]

as

	select 
	/* TOP 100 percent */
	 (case when [DLE_EntityName_Main] IS not null then [DLE_EntityName_Main] 
				/*+ (case when [DLE_EntityNameAlias] >'' then + ' (Alias: '+ [DLE_EntityNameAlias]+')' else '' end)*/
			else [LNC_EntityName] 
				/*+ (case when [LNC_EntityNameAlias] >'' then 
				+ ' (Alias: '+ [LNC_EntityNameAlias]+')' else '' end)*/
		 end) as EntNameMain_DLE_or_LNC 

	 , (case when [DLE_EntityName_Clean] IS not null then [DLE_EntityName_Clean] 
				/*+ (case when [DLE_EntityNameAlias] >'' then + ' (Alias: '+ [DLE_EntityNameAlias]+')' else '' end)*/
			else [LNC_EntityName] 
				/*+ (case when [LNC_EntityNameAlias] >'' then 
				+ ' (Alias: '+ [LNC_EntityNameAlias]+')' else '' end)*/
		 end) as EntNameClean_DLE_or_LNC 

	 , (case when [DLE_EntityName_Alias]>'' then ' (Alias: '+ [DLE_EntityName_Alias]+')'
			else [LNC_EntityName] + ' (LINC)'
				/*+ (case when [LNC_EntityNameAlias] >'' then 
				+ ' (Alias: '+ [LNC_EntityNameAlias]+')' else '' end)*/
		 end) as EntNameAlias_DLE_or_LNC_WithAliasSuffix

		 , [DLE_EntityName_Main]
		, [DLE_EntityName_Alias]
		, (case 
			when [DLE_EntityName] IS not null and lnc_entityname is not null then '1 - Diligent + LINC' 
			when [DLE_EntityName] IS not null and lnc_entityname is null then '2 - Diligent Only' 
			 /* when CTK_InternalPartnerID IS not null  and CTK_InternalPartnerStatus = 'Active'  then '4 - LINC (Contiki Legacy ACTIVE)'
			 when CTK_InternalPartnerID IS not null  and CTK_InternalPartnerStatus <> 'Active'  then '5 - LINC (Contiki Legacy INACTIVE)' */
			when [DLE_EntityName] IS null and lnc_entityname is not null 
					and LNC_Category not IN ( 'Default', 'Vendor')  then '3 - LINC Only' 
			when [DLE_EntityName] IS null and lnc_entityname is not null	
					and LNC_Category IN ( 'Default', 'Vendor') then '6 - LINC Vendor' 
			else 'OTHER' end) 
		 as EntExistsIn
		
		, cast((case when [DLE_SAP_Code]>'' then [DLE_SAP_Code]
			when [LNC_CompanyCode_ExternalReference]>'' then 'LINC: ' + [LNC_CompanyCode_ExternalReference]
			end) as varchar(255))  as Ent_SAP_Code

		, (case when [DLE_Status] >'' then [DLE_Status] 
				when [LNC_EntityStatus] >'' then [LNC_EntityStatus]
				/* else CTK_InternalPartnerStatus */
			end) as EntStatus

		,  cast((case when [DLE_EntityName_NonFwSlash] is not null then [DLE_EntityName_NonFwSlash] 
					else [LNC_EntityName_NonFwSlash] end) 
				as varchar(255)) 
				EntName_DLE_or_LINC_NonFwSlash

		,  UPPER(cast((case when [DLE_EntityName_NonFwSlash] is not null then [DLE_EntityName_NonFwSlash] else [LNC_EntityName_NonFwSlash] end) 
				as varchar(255)) )
				EntName_DLE_or_LINC_NonFwSlash_UPPER

		, (case when DLE_Country >'' then DLE_Country else CTK_Country /*LNC*/ end) 
			as EntCountry

		/* Diligent */
		, [DLE_Country]
		, [DLE_QuickRef]
		, [DLE_Status]
		, [DLE_MaxNoSignatures]
		, [DLE_SignatureRules]
		, [DLE_EntityName]
		, UPPER([DLE_EntityName_NonFwSlash]) as DLE_EntName_NonFwSlash_UPPER
		/*, [DLE_EntityNameAlias] */
		, DLE_Sap_Code
		/*,  cast([DLE_EntityName_NonFwSlash] as varchar(255)) [DLE_EntityName_NonFwSlash] */
		/*,  cast(upper([DLE_EntityName_NonFwSlash]) as varchar(255)) [DLE_EntityName_NonFwSlash_UPPER]*/
		, [DLE_EntMainNameOrAlias]
		/* LNC */
		, [LNC_EntityStatus]
		, [LNC_CompanyCode_ExternalReference]
		, [LNC_Category]

		, CTK_InternalPartnerID
		, CTK_InternalPartnerStatus

		, LNC_EntityName /*(case when [LNC_EntityName] is not null then [LNC_EntityName] else [DLE_EntityName] end) as */
		, [LNC_EntityNameAlias]
		/*,  cast((case when [LNC_EntityName_NonFwSlash] is not null then [LNC_EntityName_NonFwSlash] else [DLE_EntityName_NonFwSlash] end) 
				as varchar(255)) [LNC_EntityName_NonFwSlash] */

		/* General */
		, (case when d.[DLE_EntityName] = L.[LNC_EntityName] and d.[DLE_EntMainNameOrAlias] = 'NameMain' 
				then 'Exact Name Match' 
				else 'Alias Name Match' 
				end)
			as MatchCategory_Name

		, (case when d.DLE_SAP_Code = L.[LNC_CompanyCode_ExternalReference] then 'Company Code Match' else null end) 
		as MatchCategory_Code

	FROM [dbo].[V_TheCompany_VDEPARTMENT_Entities_Diligent_Union_Alias] d
		full join
		[dbo].[V_TheCompany_VDEPARTMENT_Entities_LINC] l
			on (d.DLE_SAP_Code = L.[LNC_CompanyCode_ExternalReference] and d.DLE_SAP_Code >'')
				/*or d.[DLE_EntityName_NonAlphaNonNum] = L.[LNC_EntityName_NonAlphaNonNum]*/
				or (d.[DLE_EntityName] = L.[LNC_EntityNameAlias]
					AND d.[DLE_SAP_Code] = l.[LNC_CompanyCode_ExternalReference])
				/* or d.[DLE_EntityNameAlias] = L.[LNC_EntityName] */
				or (UPPER(d.[DLE_EntityName_NonFwSlash]) = UPPER(l.[LNC_EntityName_NonFwSlash])
					AND d.[DLE_SAP_Code] = l.[LNC_CompanyCode_ExternalReference])/* TheCompany Pharmaceuticals S.R.L. duplicate name in MD and RO new 11.01.2022 */

/* TheCompany GmbH, but rep offices have same code */
/*	WHERE 
		d.DLE_SAP_Code = L.[LNC_CompanyCode_ExternalReference]
		OR ((len(d.DLE_SAP_Code)<>4 or  len(L.[LNC_CompanyCode_ExternalReference])<>4) 
			and (d.[DLE_EntityName_NonAlphaNonNum] = L.[LNC_EntityName_NonAlphaNonNum]
			or d.[DLE_EntityName] = L.[LNC_EntityNameAlias]
			or d.[DLE_EntityNameAlias] = L.[LNC_EntityName])) */
/*	order by 
	(case when [DLE_EntityName] IS not null then [DLE_EntityName] else [LNC_EntityName] end) 
	asc
*/
GO
/****** Object:  View [dbo].[V_TheCompany_VDEPARTMENT_Entities_DiligentAndLINC_SCRUB]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_VDEPARTMENT_Entities_DiligentAndLINC_SCRUB]

as
SELECT  EntNameMain_DLE_or_LNC
		, max(EntNameAlias_DLE_or_LNC_WithAliasSuffix) as EntNameAlias_DLE_or_LNC_WithAliasSuffix_Max

		, min([EntExistsIn]) as CompareCategory
	  , min((case when entexistsin = '2 - Diligent Only' and Entstatus ='Active' then 'Add missing Entity in LINC'
				when (entexistsin = '3 - LINC Only' and ([Entstatus] is null or [Entstatus] ='' or [Entstatus]  not in ('Inactive','Dissolved','Merged')))  then 'correct LINC status from '+ (case when LNC_entitystatus = '' THEN 'BLANK' else LNC_entitystatus end) +' to Inactive or correct entity name to the DiligentName if active'
				when (entexistsin = '1 - Diligent + LINC'  and [DLE_Status]<>[LNC_EntityStatus]) then 'correct LINC status from ' + (case when LNC_entitystatus = '' THEN 'BLANK' else LNC_entitystatus end) + ' to ' + DLE_Status 
				end) 
				+ (case when [LNC_CompanyCode_ExternalReference] ='' and [DLE_Sap_Code] >'' then ' and add the SAP Company Code: ' + [DLE_Sap_Code]
						when [LNC_CompanyCode_ExternalReference]<>[DLE_Sap_Code] and len([DLE_Sap_Code])=4 then ' and correct the SAP Company Code from '+ [LNC_CompanyCode_ExternalReference]+ ' to: ' + [DLE_Sap_Code]
						else '' end )
				) as ActionItem
				
      ,[Ent_SAP_Code]
      ,[EntStatus]
    /*  ,[EntName_DLE_or_LINC_NonFwSlash] */
   /*   ,[EntName_DLE_or_LINC_NonFwSlash_UPPER] */
      ,[EntCountry]
      ,[DLE_Country]
      ,[DLE_QuickRef]
      ,[DLE_Status]
      ,[DLE_MaxNoSignatures]
      ,[DLE_SignatureRules]
     /* ,[DLE_EntityName] */
      ,[DLE_Sap_Code]
      /*,[DLE_EntMainNameOrAlias]*/
      ,max([LNC_EntityStatus]) as LNC_EntityStatus_Max
      ,max([LNC_CompanyCode_ExternalReference]) as LNC_CompanyCode_ExternalReference_Max
      ,max([LNC_Category]) as LNC_Category_Max
      ,max([LNC_EntityName]) as LNC_EntityName_Max

  FROM [DAQ-1445_Contiki_App_DESQL016_Divestment].[dbo].[V_TheCompany_VDEPARTMENT_Entities_DiligentAndLINC]
  where 
  entexistsin in ('1 - Diligent + LINC','2 - Diligent Only','3 - LINC Only')
 group by EntNameMain_DLE_or_LNC
 /* , EntNameAlias_DLE_or_LNC_WithAliasSuffix */

      ,[Ent_SAP_Code]
      ,[EntStatus]
     /*,[EntName_DLE_or_LINC_NonFwSlash]
      ,[EntName_DLE_or_LINC_NonFwSlash_UPPER] */
      ,[EntCountry]
      ,[DLE_Country]
      ,[DLE_QuickRef]
      ,[DLE_Status]
      ,[DLE_MaxNoSignatures]
      ,[DLE_SignatureRules]
     /* ,[DLE_EntityName]*/
      ,[DLE_Sap_Code]
      /*,[DLE_EntMainNameOrAlias]*/


     
GO
/****** Object:  View [dbo].[VDOCUMENT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VDOCUMENT]
AS
SELECT     TOP 100 PERCENT dbo.TDOCUMENT.DESCRIPTION AS Title, CAST(dbo.TFILEINFO.MajorVersion AS decimal) 
                      + CAST('0.' + CAST(dbo.TFILEINFO.MinorVersion AS varchar) AS decimal) AS Version, dbo.TFILEINFO.MajorVersion, dbo.TFILEINFO.MinorVersion, 
                      dbo.TARCHIVE.ARCHIVE AS Status, TPERSON_2.DISPLAYNAME AS Owner, dbo.TMODULETYPE.MODULETYPE AS TemplateType, 
                      TPERSON_1.DISPLAYNAME AS CheckedOutBy, dbo.TFILEINFO.LastChangedDate AS VersionDate, dbo.TDOCUMENT.DOCUMENTDATE AS Datecreated, 
                      dbo.TDOCUMENT.CHECKEDOUTDATE, dbo.TDOCUMENT.DOCUMENT AS FileName, dbo.TFILEINFO.FileSize, 
                      dbo.TDOCUMENT.ORIGFILENAME AS OriginalFileName, dbo.TDOCUMENT.USERID AS DocumentOwnerId, 
                      dbo.TDOCUMENT.CHECKEDOUTBY AS CheckedOutById, dbo.TDOCUMENT.CHECKEDIN AS CheckedOutStatus, dbo.TDOCUMENT.DOCUMENTTYPEID, 
                      dbo.TDOCUMENT.DOCUMENTID, dbo.TDOCUMENT.ARCHIVEID, dbo.TARCHIVE.FIXED AS ArchiveFixed, dbo.TDOCUMENT.MIK_VALID, 
                      dbo.TFILEINFO.FileID, dbo.TDOCUMENT.OBJECTTYPEID, dbo.TDOCUMENT.OBJECTID, dbo.TDOCUMENTTYPE.DOCUMENTTYPE, 
                      dbo.TFILEINFO.FileType, dbo.TDOCUMENT.SOURCEFILEINFOID, dbo.TSTATUS.STATUS AS ApprovalStatus, 
                      dbo.TSTATUS.STATUSID AS ApprovalStatusID, dbo.TSTATUS.FIXED AS ApprovalStatusFixed
FROM         dbo.TMODULETYPE RIGHT OUTER JOIN
                      dbo.TDOCUMENT INNER JOIN
                      dbo.TUSER AS TUSER_2 ON dbo.TDOCUMENT.USERID = TUSER_2.USERID INNER JOIN
                      dbo.TFILEINFO ON dbo.TDOCUMENT.FILEINFOID = dbo.TFILEINFO.FileInfoID LEFT OUTER JOIN
                      dbo.TSTATUS ON dbo.TDOCUMENT.APPROVALSTATUSID = dbo.TSTATUS.STATUSID LEFT OUTER JOIN
                      dbo.TDOCUMENTTYPE ON dbo.TDOCUMENT.DOCUMENTTYPEID = dbo.TDOCUMENTTYPE.DOCUMENTTYPEID ON 
                      dbo.TMODULETYPE.MODULETYPEID = dbo.TDOCUMENT.MODULETYPEID LEFT OUTER JOIN
                      dbo.TUSER AS TUSER_1 ON dbo.TDOCUMENT.CHECKEDOUTBY = TUSER_1.USERID LEFT OUTER JOIN
                      dbo.TARCHIVE ON dbo.TDOCUMENT.ARCHIVEID = dbo.TARCHIVE.ARCHIVEID LEFT OUTER JOIN
                      dbo.TEMPLOYEE AS TEMPLOYEE_1 ON TUSER_1.EMPLOYEEID = TEMPLOYEE_1.EMPLOYEEID LEFT OUTER JOIN
                      dbo.TPERSON AS TPERSON_1 ON TEMPLOYEE_1.PERSONID = TPERSON_1.PERSONID LEFT OUTER JOIN
                      dbo.TEMPLOYEE AS TEMPLOYEE_2 LEFT OUTER JOIN
                      dbo.TPERSON AS TPERSON_2 ON TEMPLOYEE_2.PERSONID = TPERSON_2.PERSONID ON 
                      TUSER_2.EMPLOYEEID = TEMPLOYEE_2.EMPLOYEEID
ORDER BY dbo.TDOCUMENT.DOCUMENTID


GO
/****** Object:  View [dbo].[V_TheCompany_VDOCUMENT_CONTRACT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [dbo].[V_TheCompany_VDOCUMENT_CONTRACT]

AS

	SELECT   d.documentid
			, c.contractid
			, d.objectid
			, NULL as AMENDMENTID
		, 	[Title]
      ,[Version]
     /* ,[MajorVersion]
      ,[MinorVersion] */
      ,[Status]
      ,[Owner]
      /*,[TemplateType]
      ,[CheckedOutBy]*/
      ,[VersionDate]
      ,d.[Datecreated]
     /* ,[CHECKEDOUTDATE] */
      ,[FileName]
      ,[FileSize]
      ,[OriginalFileName]
      ,[DocumentOwnerId]
      /*,[CheckedOutById]
      ,[CheckedOutStatus]*/
      ,[DOCUMENTTYPEID]
    /*  ,[DOCUMENTID]
      ,[ARCHIVEID]
      ,[ArchiveFixed] */
      ,[MIK_VALID]
      ,[FileID]
      ,[OBJECTTYPEID]
      ,[DOCUMENTTYPE]
      ,[FileType] /* e.g. .pdf , .ContikiMail shows as type .msg just like Outlook mail but is excluded*/
     /* ,[SOURCEFILEINFOID]
      ,[ApprovalStatus]
      ,[ApprovalStatusID]
      ,[ApprovalStatusFixed] */
	FROM         
				VDOCUMENT d 
				inner join tcontract c 
						on d.OBJECTID = c.CONTRACTID 
							and d.OBJECTTYPEID = 1 /* Contract */
				/*left join VUSER u on d.DocumentOwnerId = u.USERID
				 left join [dbo].[TAMENDMENT] a 
					on d.objectid = a.AMENDMENTID 
						and d.OBJECTTYPEID = 4 /* amendment */ */

	where 
		mik_valid = 1 /* valid document */
		AND d.filetype not in (
		 '.ContikiMail' /* e.g. .pdf , .ContikiMail shows as type .msg just like Outlook mail but is excluded*/
		/*
		.doc	4433
		.txt	3825
		.msg	3388 /* e.g. .pdf , .ContikiMail shows as type .msg just like Outlook mail but is excluded*/
		.xls	1228
		.xlsm	1206
		.docx	873
		.ppt	339
		.xlsx	321
		.zip	211
		.htm	130
		.pptx	110
		.jpg	69
		.rtf	35
		.png	20 */
		, '.dwg' /*	13 */
		, '.gif'
		, '.2004' /*	8 */
		, '.tif'
		, '.dot'
		, '.bmp'
		, '.jpeg'
		, '.log'
		, '.vcf'
		, '.edoc'	
		, '.docm'
		, '.3'
		, '.accdb'
		, '.tmp'	
		, '.pps'
		, '.pptm'
		, '.mdb'
		, '.Område'
		, '.p7m'	
		, '.ics'	
		, '.asice'	
		, '.config'	
		, '.11579'	
		, '.18'	
		, '.2003'	
		, '.ContikiMS'	
		, '.dtsConfig'	
		, '.xlt'
		, '.xltx'
		, '.xml'
		)

GO
/****** Object:  View [dbo].[V_TheCompany_VDOCUMENT_AMENDMENT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[V_TheCompany_VDOCUMENT_AMENDMENT]

AS

	SELECT   d.documentid
			, a.contractid
			, d.objectid
			, a.amendmentid
			, 	[Title]
      ,[Version]
     /* ,[MajorVersion]
      ,[MinorVersion] */
      ,[Status]
      ,[Owner]
      /*,[TemplateType]
      ,[CheckedOutBy]*/
      ,[VersionDate]
      ,d.[Datecreated]
     /* ,[CHECKEDOUTDATE] */
      ,[FileName]
      ,[FileSize]
      ,[OriginalFileName]
      ,[DocumentOwnerId]
      /*,[CheckedOutById]
      ,[CheckedOutStatus]*/
      ,[DOCUMENTTYPEID]
    /*  ,[DOCUMENTID]
      ,[ARCHIVEID]
      ,[ArchiveFixed] */
      ,[MIK_VALID]
      ,[FileID]
      ,[OBJECTTYPEID]
      ,[DOCUMENTTYPE]
      ,[FileType]
     /* ,[SOURCEFILEINFOID]
      ,[ApprovalStatus]
      ,[ApprovalStatusID]
      ,[ApprovalStatusFixed] */
	FROM         
				VDOCUMENT d 
				 inner join [dbo].[TAMENDMENT] a 
					on d.objectid = a.AMENDMENTID 
						and d.OBJECTTYPEID = 4 /* amendment */ 

	WHERE
		mik_valid = 1 /* valid document */
		AND d.filetype not in (
		 '.ContikiMail'
		/*
		.doc	4433
		.txt	3825
		.msg	3388
		.xls	1228
		.xlsm	1206
		.docx	873
		.ppt	339
		.xlsx	321
		.zip	211
		.htm	130
		.pptx	110
		.jpg	69
		.rtf	35
		.png	20 */
		, '.dwg' /*	13 */
		, '.gif'
		, '.2004' /*	8 */
		, '.tif'
		, '.dot'
		, '.bmp'
		, '.jpeg'
		, '.log'
		, '.vcf'
		, '.edoc'	
		, '.docm'
		, '.3'
		, '.accdb'
		, '.tmp'	
		, '.pps'
		, '.pptm'
		, '.mdb'
		, '.Område'
		, '.p7m'	
		, '.ics'	
		, '.asice'	
		, '.config'	
		, '.11579'	
		, '.18'	
		, '.2003'	
		, '.ContikiMS'	
		, '.dtsConfig'	
		, '.xlt'
		, '.xltx'
		, '.xml'
		)

GO
/****** Object:  View [dbo].[V_TheCompany_VDOCUMENT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[V_TheCompany_VDOCUMENT]

AS

SELECT  
	   d.contractid
	, d.[OBJECTTYPEID] /* 1 = contract or 4 = amendment */
      ,d.[OBJECTID] as OBJECTID_DOC_CON_OR_AMD /* Contractid or amendmentid */
	  , d.amendmentid
	, (case when c.[contract] like '%TOP SECRET%' 
				THEN 'DocumentID_' + convert(varchar(255), d.documentid ) 
				+ ': *** TOP SECRET ***' 
				ELSE (case when d.[Originalfilename] IS null or d.[Originalfilename] = '' 
					then d.[OriginalFileName] END) END) 
				as 'DocumentTitle_TS_Redacted'

				, (case when len(d.title)>0 then d.title
					when len(d.[Originalfilename])>4 then d.[Originalfilename]
					when len(d.[Filename])>0 then d.[Filename] end)
					 
				 as /* 'TitleOrFileNameOrOrigFileName'
				, d.Title as */ Title

			, (c.CONTRACTNUMBER + ': ' + c.CONTRACT /*+ max((COUNT(c.contractid)))*/ ) 
				as ContractSummary_TS_Included

			, (case when c.[contract] like '%TOP SECRET%' 
					THEN c.[contractnumber] + ': *** TOP SECRET ***' 
					ELSE c.CONTRACTNUMBER + ': ' + c.CONTRACT   END) 
							as ContractSummary_TS_Redacted
      
      ,[Version]
      ,u.email as OwnerEmail /*[Owner] */
      ,[VersionDate]
      ,d.[Datecreated]
      ,[FileName]
      ,[FileSize]
      ,[OriginalFileName]
      ,[DocumentOwnerId]
      ,[DOCUMENTTYPEID]
      ,[DOCUMENTTYPE] /* folder, e.g. signed contracts */
      ,d.[DOCUMENTID]
      ,[MIK_VALID]
      ,[FileID]

      ,[FileType] /* e.g. .pdf , .ContikiMail shows as type .msg just like Outlook mail but is excluded*/

	, (SELECT 
		CAST(STUFF(
		(SELECT DISTINCT ',' + tg.TAG /*+ ' ('+tg.TagCategory+')'*/
			FROM ttag /*V_TheCompany_TTag_Detail*/ tg
				inner join TTAG_IN_OBJECT tj 
					on tg.tagid = tj.tagid
			WHERE tj.OBJECTID =d.DOCUMENTID 
			and tj.OBJECTTYPEID = 7 /* document */
			FOR XML PATH('')),1,1,'') AS VARCHAR(255))) AS DocumentTags	/* e.g. change of control */
		, c.[CONTRACT] as ContractTitle
	FROM         
			(select * from V_TheCompany_VDOCUMENT_CONTRACT
				union all select * from V_TheCompany_VDOCUMENT_AMENDMENT) d
			left join VUSER u on d.DocumentOwnerId = u.USERID
			inner join tcontract c on d.contractid = c.contractid

	/* where d.filetype not in (
		 '.ContikiMail'
		/*
		.doc	4433
		.txt	3825
		.msg	3388
		.xls	1228
		.xlsm	1206
		.docx	873
		.ppt	339
		.xlsx	321
		.zip	211
		.htm	130
		.pptx	110
		.jpg	69
		.rtf	35
		.png	20 */
		, '.dwg' /*	13 */
		, '.gif'
		, '.2004' /*	8 */
		, '.tif'
		, '.dot'
		, '.bmp'
		, '.jpeg'
		, '.log'
		, '.vcf'
		, '.edoc'	
		, '.docm'
		, '.3'
		, '.accdb'
		, '.tmp'	
		, '.pps'
		, '.pptm'
		, '.mdb'
		, '.Område'
		, '.p7m'	
		, '.ics'	
		, '.asice'	
		, '.config'	
		, '.11579'	
		, '.18'	
		, '.2003'	
		, '.ContikiMS'	
		, '.dtsConfig'	
		, '.xlt'
		, '.xltx'
		, '.xml'
		)
*/
GO
/****** Object:  View [dbo].[V_TheCompany_TTAG_Upload_Quality]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View [dbo].[V_TheCompany_TTAG_Upload_Quality]

as

select 
'EXEC [dbo].[TheCompany_TagUpload_DocumentID] ' + ltrim(str(42))/* Tag Quality Agreement */ /*@TAGID bigint */ + ', ' 
				+ ltrim(str(7))/* @OBJECTTYPEID bigint 7 = Document */ + ', ' 
				+ ltrim(str(d.documentid)) /* OBJECTID */ + ';' as ExecSQL
, title

from V_TheCompany_VDOCUMENT d
where

	(
	Title like '%quality%'
	/* or Title like '%[^0-9A-z]QA[^0-9A-z]%' */
	)
	AND d.documentid not in (select objectid from TTAG_IN_OBJECT where OBJECTTYPEID = 7 /* document */
	and tagid = 42)

union all

	select 
	'EXEC [dbo].[TheCompany_TagUpload_DocumentID] ' + ltrim(str(43))/* Tag Quality Agreement */ /*@TAGID bigint */ + ', ' 
					+ ltrim(str(7))/* @OBJECTTYPEID bigint 7 = Document */ + ', ' 
					+ ltrim(str(d.documentid)) /* OBJECTID */ + ';' as ExecSQL
	, title

	from V_TheCompany_VDOCUMENT d
	where

		(
		Title  like '%[^0-9A-z]QA[^0-9A-z]%'
		)
		AND d.documentid not in (select objectid from TTAG_IN_OBJECT where OBJECTTYPEID = 7 /* document */
		and tagid = 43)
		/* exec [dbo].[TheCompany_TagUpload_DocumentID] 42, 7, 149230 */

/* delete from TTAG_IN_OBJECT where tagid = 42 */
GO
/****** Object:  View [dbo].[vUsageAnalysis_User]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vUsageAnalysis_User] as
select
case when winuser.ExternalUserId is not null then 1 else 0 end as "WinAccess",
case when ccsuser.ExternalUserId is not null and winuser.ExternalUserId is null  then 1 else 0 end as "CCSAccess", 
case when t1.USER_MIK_VALID = 1 then 1 else 0 end as "Active",
left(t1.DISPLAYNAME,30) "DisplayName",
left(t1.USERINITIAL,15) "UserInitial",
t1.userid "UserId",
left(t1.DEPARTMENT,30) "Department",
(select max(l2.dt_logon) from tlogon l2 where l2.userid=t1.userid and l2.appl = 'Contiki.Windows.Application' ) "LastLoggedInWin",
(select max(l2.dt_logon) from tlogon l2 where l2.userid=t1.userid and l2.appl = 'Contiki.Collaboration.Server') "LastLoggedInCCS",
(select count(l2.dt_logon) from tlogon l2 where l2.userid=t1.userid and l2.appl = 'Contiki.Windows.Application' ) "LoginsWin",
(select count(l2.dt_logon) from tlogon l2 where l2.userid=t1.userid and l2.appl = 'Contiki.Collaboration.Server') "LoginsCCS",
(select count(l2.dt_logon) from tlogon l2 where l2.userid=t1.userid and l2.dt_logon > (GetDate() - 365) and l2.appl = 'Contiki.Windows.Application' ) "LoginsWinLast365",
(select count(l2.dt_logon) from tlogon l2 where l2.userid=t1.userid and l2.dt_logon > (GetDate() - 180) and l2.appl = 'Contiki.Windows.Application' ) "LoginsWinLast180",
(select count(l2.dt_logon) from tlogon l2 where l2.userid=t1.userid and l2.dt_logon > (GetDate() - 365) and l2.appl = 'Contiki.Collaboration.Server') "LoginsCCSLast365",
(select count(l2.dt_logon) from tlogon l2 where l2.userid=t1.userid and l2.dt_logon > (GetDate() - 180) and l2.appl = 'Contiki.Collaboration.Server') "LoginsCCSLast180",
(select count(1) from tacl where PRIVILEGEID = 3 and objecttypeid = 1 and userid = t1.UserId) "ContractsCreated",
(select count(1) from tacl where PRIVILEGEID = 3 and objecttypeid = 12 and userid = t1.userid) "ProjectsCreated",
(select count(d.documentid) from tdocument d where d.userid=t1.userid) "DocsCreated",
(select count(f.fileinfoid) from tfileinfo f where f.lastchangedby=t1.userid and not(f.majorversion=1 and f.minorversion=0)) "DocsEdited",
(select max(f.lastchangeddate) from tfileinfo f where f.lastchangedby=t1.userid) "LastCreatedEditedDoc",
(select count(1) from tassessment where assessmentid in( select distinct ac.assessmentid from tassessmentcriterion ac, tassessmentscore sc where ac.assessmentcriterionid=sc.assessmentcriterionid  and ac.personid_score_assignor=t1.personid)) "AssessmentsScored",
(select count(1) from tapproval a where a.approvalid in (select distinct aps.approvalid from tapprovalstep aps where (not aps.approved is null) and aps.userid=t1.userid)) "ApprovalsDone",
(select max(aps.ACTIVATEDDATE) from TAPPROVALSTEP aps where (not aps.approved is null) and aps.userid=t1.userid) "LastApprovalDone"
from vuser t1 left outer join (select wu.ExternalUserId
		from
		  dbo.tworkflowuser wu, 
		  dbo.tworkflowuser_in_clienttype wuic
		where
		wu.workflowuserid=wuic.workflowuserid and
		wuic.clienttypeid=2) as ccsuser on t1.Userid = ccsuser.ExternalUserId left outer join (select wu.ExternalUserId
		from
		  dbo.tworkflowuser wu, 
		  dbo.tworkflowuser_in_clienttype wuic
		where
		wu.workflowuserid=wuic.workflowuserid and
		wuic.clienttypeid=1) as winuser on t1.Userid = winuser.ExternalUserId
where 
  -- t1.USER_MIK_VALID = 1 and
  -- not ((select max(l2.dt_logon) from tlogon l2 where l2.userid=t1.userid) is null) and
  exists (
		select wu.workflowuserid
		from
		  dbo.tworkflowuser wu, 
		  dbo.tworkflowuser_in_clienttype wuic
		where
		wu.externaluserid=USERID and
		wu.workflowuserid=wuic.workflowuserid and
		(wuic.clienttypeid=2 or wuic.clienttypeid=1))

GO
/****** Object:  View [dbo].[V_TheCompany_User_TLOGON_Last]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_User_TLOGON_Last]

as 

select *
	, 0 as CountLoginID
      ,'' as LastAppUsed
      ,'' as Dt_Logon_Max
      ,'' as Dt_Logoff_Max
      ,'' as Dt_Lastseen_Max
      /* ,[LOGINLOCATION]
      ,[ISCHATTING] */
from vUsageAnalysis_User 
where USERID in (select USERID from TUSER where MIK_VALID = 1)


GO
/****** Object:  View [dbo].[V_TheCompany_VUSER_IN_USERGROUP]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE View [dbo].[V_TheCompany_VUSER_IN_USERGROUP]

as

	select userid 
		/* User Group LIST */
		, CAST(Replace(STUFF(
		(SELECT ',' + p.USERGROUP
		FROM TUSER_IN_USERGROUP s 
			inner join TUSERGROUP /* [dbo].[V_TheCompany_VDEPARTMENT_VUSERGROUP] */ p 
			on s.USERGROUPID = p.USERGROUPID
		WHERE 
			s.userid =d.userid 
			AND s.PRIMARYGROUP is null
			and p.DEPARTMENTID is null
			and p.COMPANYID is null
			and p.USERGROUPID /* PUBLIC */ NOT IN  (1089 /* all users public */
				, 3397 /* read headers */
				, 4995 /*super user msa read write */
				, 130 /* all super users */)
			and p.USERGROUPID not IN (5428 /* L-Shire */)
			and p.MIK_VALID = 1
		FOR XML PATH('')),1,1,''),'&amp;','&') as varchar(255)) AS CustomUserGrp_List

		/* User group ID List */
			,CAST(left(Replace(STUFF(
			(SELECT ',' + STR(p.USERGROUPID)
			FROM TUSER_IN_USERGROUP s inner join TUSERGROUP /* [dbo].[V_TheCompany_VDEPARTMENT_VUSERGROUP] */ p 
				on s.USERGROUPID = p.USERGROUPID
			WHERE 
				s.userid =d.userid 
				AND s.PRIMARYGROUP is null
				and p.DEPARTMENTID is null
				and p.COMPANYID is null
			and p.USERGROUPID /* PUBLIC */ NOT IN  (1089 /* all users public */
				, 3397 /* read headers */
				, 4995 /*super user msa read write */
				, 130 /* all super users */)
			and p.USERGROUPID not IN (5428 /* L-Shire */)
				and p.MIK_VALID = 1
			FOR XML PATH('')),1,1,''),'&amp;','&'),50) as varchar(50)) AS CustomUserGrpID_List

	from 
		TUSER_IN_USERGROUP d
		/* where USERID = 83663 */
		WHERE USERID not in (select USERID from TUSER where MIK_VALID = 0)
	group by userid
	

	/* select * from VUSER where LASTNAME like '%joest%'
	select * from TUSER_IN_USERGROUP where USERID = 83663 */
GO
/****** Object:  View [dbo].[V_TheCompany_Hierarchy]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[V_TheCompany_Hierarchy]

as



SELECT
  Hierarchy.DEPARTMENTID,
  Hierarchy.LEVEL,
  Hierarchy.L0,
  Hierarchy.L1,
  Hierarchy.L2,
  Hierarchy.L3,
  Hierarchy.L4,
  Hierarchy.L5,
  Hierarchy.L6,
  Hierarchy.L7,
  Hierarchy.DEPARTMENT,
  Hierarchy.DEPARTMENT_CONCAT,

  Hierarchy.DPT_LOWEST_ID_TO_SHOW,
  Hierarchy.DEPARTMENT_CODE

  /* (
		CASE WHEN L0 = 'CCO' THEN

			(CASE WHEN L1 IN ('EUCAN', 'EMERGING MARKETS') THEN L1 ELSE 'N/A' END)

			ELSE	/* L0 not CCO but EUCAN/EM */		
			CASE
				WHEN (Hierarchy.DEPARTMENT_CODE in ('%#E%') OR L1 = 'EUCAN') THEN 'EUCAN' 
				WHEN Hierarchy.DEPARTMENT_CODE in ('%#JP%') THEN 'Japan' 
				WHEN Hierarchy.DEPARTMENT_CODE in ('%#US%') THEN 'USA' 
				WHEN Hierarchy.DEPARTMENT_CODE in ('%#OTHE%')  THEN 'N/A' 
			ELSE 'EMERGING MARKETS'
			END

				
		END) 'do not use field' AS REGION*/

  ,(CASE WHEN LEFT(Hierarchy.DEPARTMENT_CODE,1) IN (',','.',';') THEN SUBSTRING(Hierarchy.DEPARTMENT_CODE,2,2) ELSE NULL END) AS DPT_CODE_2Digit_InternalPartner,
  (CASE WHEN (LEFT(Hierarchy.DEPARTMENT_CODE,1) = ';' and SUBSTRING(Hierarchy.DEPARTMENT_CODE,4,1) in ('*','','#')) THEN SUBSTRING(Hierarchy.DEPARTMENT_CODE,2,2) ELSE NULL END) AS [DPT_CODE_2Digit_TerritoryRegion],
    (CASE WHEN LEFT(Hierarchy.DEPARTMENT_CODE,1) IN (',','.',';') THEN SUBSTRING(Hierarchy.DEPARTMENT_CODE,2,2) ELSE NULL END) AS DPT_CODE_2Digit,
  SUBSTRING(Hierarchy.DEPARTMENT_CODE,1,1) as DPT_CODE_FirstChar,
  (CASE 
WHEN Hierarchy.DEPARTMENT_CODE IS NULL THEN NULL
WHEN  LEFT(Hierarchy.DEPARTMENT_CODE,1) in(':','#') THEN 'Area' 
WHEN LEFT(Hierarchy.DEPARTMENT_CODE,1) in ('.',';',',') THEN  'Country Dpt IP' 
WHEN LEFT(Hierarchy.DEPARTMENT_CODE,1)='-' THEN 'Department' 
ELSE 'Other' END) 
  as FieldCategory

   ,(CASE 
WHEN Hierarchy.DEPARTMENT_CODE IS NULL THEN NULL
WHEN  LEFT(Hierarchy.DEPARTMENT_CODE,1) in(':','#') THEN 
	(CASE WHEN [level] = 1 THEN 'Region' ELSE 'Area' END)
WHEN LEFT(Hierarchy.DEPARTMENT_CODE,1) =',' THEN  'Internal Partner' 
WHEN LEFT(Hierarchy.DEPARTMENT_CODE,1) =';' THEN  'Country' 
WHEN LEFT(Hierarchy.DEPARTMENT_CODE,1) ='.' THEN  'Country Department' 
WHEN LEFT(Hierarchy.DEPARTMENT_CODE,1)='-' THEN 'Department' 
ELSE 'Other' END) AS NodeType

   ,(CASE 
WHEN Hierarchy.DEPARTMENT_CODE IS NULL THEN NULL
WHEN LEFT(Hierarchy.DEPARTMENT_CODE,1) in('.',':','-') THEN 'D' 
WHEN LEFT(Hierarchy.DEPARTMENT_CODE,1) =',' THEN  'I' 
WHEN  LEFT(Hierarchy.DEPARTMENT_CODE,1) in(';','#') THEN 'T' 
ELSE 'Other' END) AS NodeRole

, (CASE WHEN Hierarchy.DEPARTMENT_CODE like '%[*][*]%' THEN 2 
	WHEN Hierarchy.DEPARTMENT_CODE like '%[*]%' THEN 1 
	ELSE 0 END) AS NodeMajorFlag
  ,Hierarchy.PARENTID

FROM
  ( 
  SELECT *
 FROM 
( SELECT 
'0' AS LEVEL
,'No Contract Owner Dpt Assigned' AS L0
,NULL AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7
, 0 AS L0_DPTID
, NULL AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

,'No Contract Owner Dpt Assigned' AS DEPARTMENT
,'No Contract Owner Dpt Assigned' AS DEPARTMENT_CONCAT
, 0 AS DPT_LOWEST_ID_TO_SHOW

, 0 AS DEPARTMENTID
, 'N/A' AS DEPARTMENT_CODE
, 0 AS PARENTID

FROM TDEPARTMENT 
WHERE DEPARTMENTID = 1 ) "H NA"

UNION ALL

SELECT *
 FROM 
( SELECT 
'0' AS LEVEL
,DEPARTMENT AS L0
,NULL AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7
, DEPARTMENTID AS L0_DPTID
, NULL AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, DEPARTMENT
, DEPARTMENT AS DEPARTMENT_CONCAT
, DEPARTMENTID AS DPT_LOWEST_ID_TO_SHOW

, DEPARTMENTID
, DEPARTMENT_CODE
, PARENTID

FROM TDEPARTMENT 
WHERE  
DEPARTMENTID IN('201789' /* CCO */ ,'100100' /* Territories - Region */ , '203831' /* Territories - Alphabetical */ , '203831' /* Territories - Alphabetical */,'10004' /* Internal Partner*/)
 ) "H0"

UNION ALL

SELECT *
 FROM
( SELECT 
'1' AS LEVEL
, "H0".DEPARTMENT AS L0
,  d.DEPARTMENT AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H0".DEPARTMENTID AS L0_DPTID
, d.DEPARTMENTID AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT
, d.DEPARTMENT AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
ELSE  "H0".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID
FROM TDEPARTMENT d , ( SELECT 
'0' AS LEVEL
,DEPARTMENT AS L0
,NULL AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7
, DEPARTMENTID AS L0_DPTID
, NULL AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, DEPARTMENT
, DEPARTMENT AS DEPARTMENT_CONCAT
, DEPARTMENTID AS DPT_LOWEST_ID_TO_SHOW

, DEPARTMENTID
, DEPARTMENT_CODE
, PARENTID

FROM TDEPARTMENT 
WHERE  
DEPARTMENTID IN('201789' /* CCO */ ,'100100' /* Territories - Region */ , '203831' /* Territories - Alphabetical */,'10004' /* Internal Partner*/)
 ) "H0"
WHERE  
d.PARENTID = "H0".DEPARTMENTID

 ) "H1"

UNION ALL

SELECT *
 FROM
( SELECT 
'2' AS LEVEL
, "H1".L0 AS L0
, "H1".L1 AS L1
/* ,  d.DEPARTMENT as L2 */
, (CASE WHEN d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H1".L0_DPTID AS L0_DPTID
, "H1".L1_DPTID AS L1_DPTID
,  d.DEPARTMENTID AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN  "H1".L1 >'' THEN  "H1".L1 
ELSE  "H1".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN  "H1".L1 >'' THEN  "H1".L1_DPTID 
ELSE  "H1".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'1' AS LEVEL
, "H0".DEPARTMENT AS L0
,  d.DEPARTMENT AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H0".DEPARTMENTID AS L0_DPTID
, d.DEPARTMENTID AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT
, d.DEPARTMENT AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
ELSE  "H0".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID
FROM TDEPARTMENT d , ( SELECT 
'0' AS LEVEL
,DEPARTMENT AS L0
,NULL AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7
, DEPARTMENTID AS L0_DPTID
, NULL AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, DEPARTMENT
, DEPARTMENT AS DEPARTMENT_CONCAT
, DEPARTMENTID AS DPT_LOWEST_ID_TO_SHOW

, DEPARTMENTID
, DEPARTMENT_CODE
, PARENTID

FROM TDEPARTMENT 
WHERE  
DEPARTMENTID IN('201789' /* CCO */ ,'100100' /* Territories - Region */ , '203831' /* Territories - Alphabetical */,'10004' /* Internal Partner*/)
 ) "H0"
WHERE  
d.PARENTID = "H0".DEPARTMENTID

 ) "H1"
WHERE  
d.PARENTID = "H1".DEPARTMENTID
/* AND d.DEPARTMENTID='203322' */
 ) "H2"

UNION ALL

SELECT *
 FROM
( SELECT 
'3' AS LEVEL
, "H2".L0 AS L0
, "H2".L1 AS L1
, "H2".L2 AS L2
, (CASE WHEN d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H2".L0_DPTID AS L0_DPTID
, "H2".L1_DPTID AS L1_DPTID
, "H2".L2_DPTID AS L2_DPTID
,  d.DEPARTMENTID AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT


, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H2".L2 >'' THEN  "H2".L2 
WHEN  "H2".L1 >'' THEN  "H2".L1 
ELSE  "H2".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H2".L2 >'' THEN  "H2".L2_DPTID 
WHEN  "H2".L1 >'' THEN  "H2".L1_DPTID 
ELSE  "H2".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'2' AS LEVEL
, "H1".L0 AS L0
, "H1".L1 AS L1
/* ,  d.DEPARTMENT as L2 */
, (CASE WHEN d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H1".L0_DPTID AS L0_DPTID
, "H1".L1_DPTID AS L1_DPTID
,  d.DEPARTMENTID AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN  "H1".L1 >'' THEN  "H1".L1 
ELSE  "H1".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN  "H1".L1 >'' THEN  "H1".L1_DPTID 
ELSE  "H1".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'1' AS LEVEL
, "H0".DEPARTMENT AS L0
,  d.DEPARTMENT AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H0".DEPARTMENTID AS L0_DPTID
, d.DEPARTMENTID AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT
, d.DEPARTMENT AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
ELSE  "H0".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID
FROM TDEPARTMENT d , ( SELECT 
'0' AS LEVEL
,DEPARTMENT AS L0
,NULL AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7
, DEPARTMENTID AS L0_DPTID
, NULL AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, DEPARTMENT
, DEPARTMENT AS DEPARTMENT_CONCAT
, DEPARTMENTID AS DPT_LOWEST_ID_TO_SHOW

, DEPARTMENTID
, DEPARTMENT_CODE
, PARENTID

FROM TDEPARTMENT 
WHERE  
DEPARTMENTID IN('201789' /* CCO */ ,'100100' /* Territories - Region */ , '203831' /* Territories - Alphabetical */,'10004' /* Internal Partner*/)
 ) "H0"
WHERE  
d.PARENTID = "H0".DEPARTMENTID

 ) "H1"
WHERE  
d.PARENTID = "H1".DEPARTMENTID
/* AND d.DEPARTMENTID='203322' */
 ) "H2"
WHERE  
d.PARENTID = "H2".DEPARTMENTID
 ) "H3"

UNION ALL

SELECT *
 FROM
( SELECT 
'4' AS LEVEL
, "H3".L0 AS L0
, "H3".L1 AS L1
, "H3".L2 AS L2
, "H3".L3 AS L3
/*,  d.DEPARTMENT as L4 */
, (CASE WHEN (SUBSTRING(d.DEPARTMENT_CODE,5,1)='*' AND  d.MIK_VALID=1) THEN d.DEPARTMENT END) AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H3".L0_DPTID AS L0_DPTID
, "H3".L1_DPTID AS L1_DPTID
, "H3".L2_DPTID AS L2_DPTID
, "H3".L3_DPTID AS L3_DPTID
,  d.DEPARTMENTID AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT
, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H3".L3 >'' THEN  "H3".L3 
WHEN "H3".L2 >'' THEN  "H3".L2 
WHEN  "H3".L1 >'' THEN  "H3".L1 
ELSE  "H3".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H3".L3 >'' THEN  "H3".L3_DPTID 
WHEN "H3".L2 >'' THEN  "H3".L2_DPTID 
WHEN  "H3".L1 >'' THEN  "H3".L1_DPTID 
ELSE  "H3".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW


, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'3' AS LEVEL
, "H2".L0 AS L0
, "H2".L1 AS L1
, "H2".L2 AS L2
, (CASE WHEN d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H2".L0_DPTID AS L0_DPTID
, "H2".L1_DPTID AS L1_DPTID
, "H2".L2_DPTID AS L2_DPTID
,  d.DEPARTMENTID AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT


, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H2".L2 >'' THEN  "H2".L2 
WHEN  "H2".L1 >'' THEN  "H2".L1 
ELSE  "H2".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H2".L2 >'' THEN  "H2".L2_DPTID 
WHEN  "H2".L1 >'' THEN  "H2".L1_DPTID 
ELSE  "H2".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'2' AS LEVEL
, "H1".L0 AS L0
, "H1".L1 AS L1
/* ,  d.DEPARTMENT as L2 */
, (CASE WHEN d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H1".L0_DPTID AS L0_DPTID
, "H1".L1_DPTID AS L1_DPTID
,  d.DEPARTMENTID AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN  "H1".L1 >'' THEN  "H1".L1 
ELSE  "H1".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN  "H1".L1 >'' THEN  "H1".L1_DPTID 
ELSE  "H1".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'1' AS LEVEL
, "H0".DEPARTMENT AS L0
,  d.DEPARTMENT AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H0".DEPARTMENTID AS L0_DPTID
, d.DEPARTMENTID AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT
, d.DEPARTMENT AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
ELSE  "H0".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID
FROM TDEPARTMENT d , ( SELECT 
'0' AS LEVEL
,DEPARTMENT AS L0
,NULL AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7
, DEPARTMENTID AS L0_DPTID
, NULL AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, DEPARTMENT
, DEPARTMENT AS DEPARTMENT_CONCAT
, DEPARTMENTID AS DPT_LOWEST_ID_TO_SHOW

, DEPARTMENTID
, DEPARTMENT_CODE
, PARENTID

FROM TDEPARTMENT 
WHERE  
DEPARTMENTID IN('201789' /* CCO */ ,'100100' /* Territories - Region */ , '203831' /* Territories - Alphabetical */,'10004' /* Internal Partner*/)
 ) "H0"
WHERE  
d.PARENTID = "H0".DEPARTMENTID

 ) "H1"
WHERE  
d.PARENTID = "H1".DEPARTMENTID
/* AND d.DEPARTMENTID='203322' */
 ) "H2"
WHERE  
d.PARENTID = "H2".DEPARTMENTID
 ) "H3"
WHERE  
d.PARENTID = "H3".DEPARTMENTID ) "H4"

UNION ALL

SELECT *
 FROM
( SELECT 
'5' AS LEVEL
, "H4".L0 AS L0
, "H4".L1 AS L1
, "H4".L2 AS L2
, "H4".L3 AS L3
, "H4".L4 AS L4

, (CASE 
WHEN (SUBSTRING(d.DEPARTMENT_CODE,5,1)='*' AND  d.MIK_VALID=1) THEN  d.DEPARTMENT END) AS L5

,NULL AS L6
,NULL AS L7

, "H4".L0_DPTID AS L0_DPTID
, "H4".L1_DPTID AS L1_DPTID
, "H4".L2_DPTID AS L2_DPTID
, "H4".L3_DPTID AS L3_DPTID
, "H4".L4_DPTID AS L4_DPTID
,  d.DEPARTMENTID AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H4".L4 >'' THEN  "H4".L4 
WHEN "H4".L3 >'' THEN  "H4".L3 
WHEN "H4".L2 >'' THEN  "H4".L2 
WHEN  "H4".L1 >'' THEN  "H4".L1 
ELSE  "H4".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H4".L4 >'' THEN  "H4".L4_DPTID 
WHEN "H4".L3 >'' THEN  "H4".L3_DPTID 
WHEN "H4".L2 >'' THEN  "H4".L2_DPTID 
WHEN  "H4".L1 >'' THEN  "H4".L1_DPTID 
ELSE  "H4".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'4' AS LEVEL
, "H3".L0 AS L0
, "H3".L1 AS L1
, "H3".L2 AS L2
, "H3".L3 AS L3
/*,  d.DEPARTMENT as L4 */
, (CASE WHEN (SUBSTRING(d.DEPARTMENT_CODE,5,1)='*' AND  d.MIK_VALID=1) THEN d.DEPARTMENT END) AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H3".L0_DPTID AS L0_DPTID
, "H3".L1_DPTID AS L1_DPTID
, "H3".L2_DPTID AS L2_DPTID
, "H3".L3_DPTID AS L3_DPTID
,  d.DEPARTMENTID AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT
, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H3".L3 >'' THEN  "H3".L3 
WHEN "H3".L2 >'' THEN  "H3".L2 
WHEN  "H3".L1 >'' THEN  "H3".L1 
ELSE  "H3".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H3".L3 >'' THEN  "H3".L3_DPTID 
WHEN "H3".L2 >'' THEN  "H3".L2_DPTID 
WHEN  "H3".L1 >'' THEN  "H3".L1_DPTID 
ELSE  "H3".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW


, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'3' AS LEVEL
, "H2".L0 AS L0
, "H2".L1 AS L1
, "H2".L2 AS L2
, (CASE WHEN d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H2".L0_DPTID AS L0_DPTID
, "H2".L1_DPTID AS L1_DPTID
, "H2".L2_DPTID AS L2_DPTID
,  d.DEPARTMENTID AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT


, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H2".L2 >'' THEN  "H2".L2 
WHEN  "H2".L1 >'' THEN  "H2".L1 
ELSE  "H2".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H2".L2 >'' THEN  "H2".L2_DPTID 
WHEN  "H2".L1 >'' THEN  "H2".L1_DPTID 
ELSE  "H2".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'2' AS LEVEL
, "H1".L0 AS L0
, "H1".L1 AS L1
/* ,  d.DEPARTMENT as L2 */
, (CASE WHEN d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H1".L0_DPTID AS L0_DPTID
, "H1".L1_DPTID AS L1_DPTID
,  d.DEPARTMENTID AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN  "H1".L1 >'' THEN  "H1".L1 
ELSE  "H1".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN  "H1".L1 >'' THEN  "H1".L1_DPTID 
ELSE  "H1".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'1' AS LEVEL
, "H0".DEPARTMENT AS L0
,  d.DEPARTMENT AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H0".DEPARTMENTID AS L0_DPTID
, d.DEPARTMENTID AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT
, d.DEPARTMENT AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
ELSE  "H0".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID
FROM TDEPARTMENT d , ( SELECT 
'0' AS LEVEL
,DEPARTMENT AS L0
,NULL AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7
, DEPARTMENTID AS L0_DPTID
, NULL AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, DEPARTMENT
, DEPARTMENT AS DEPARTMENT_CONCAT
, DEPARTMENTID AS DPT_LOWEST_ID_TO_SHOW

, DEPARTMENTID
, DEPARTMENT_CODE
, PARENTID

FROM TDEPARTMENT 
WHERE  
DEPARTMENTID IN('201789' /* CCO */ ,'100100' /* Territories - Region */ , '203831' /* Territories - Alphabetical */,'10004' /* Internal Partner*/)
 ) "H0"
WHERE  
d.PARENTID = "H0".DEPARTMENTID

 ) "H1"
WHERE  
d.PARENTID = "H1".DEPARTMENTID
/* AND d.DEPARTMENTID='203322' */
 ) "H2"
WHERE  
d.PARENTID = "H2".DEPARTMENTID
 ) "H3"
WHERE  
d.PARENTID = "H3".DEPARTMENTID ) "H4"
WHERE  
d.PARENTID = "H4".DEPARTMENTID ) "H5"

UNION ALL

SELECT *
 FROM
( SELECT 
'6' AS LEVEL
, "H5".L0 AS L0
, "H5".L1 AS L1
, "H5".L2 AS L2
, "H5".L3 AS L3
, "H5".L4 AS L4
, "H5".L5 AS L5

/* ,  d.DEPARTMENT as L6 */

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN  d.DEPARTMENT END) AS L6

,NULL AS L7

, "H5".L0_DPTID AS L0_DPTID
, "H5".L1_DPTID AS L1_DPTID
, "H5".L2_DPTID AS L2_DPTID
, "H5".L3_DPTID AS L3_DPTID
, "H5".L4_DPTID AS L4_DPTID
, "H5".L5_DPTID AS L5_DPTID
,  d.DEPARTMENTID AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H5".L5 >'' THEN  "H5".L5 
WHEN "H5".L4 >'' THEN  "H5".L4 
WHEN "H5".L3 >'' THEN  "H5".L3 
WHEN "H5".L2 >'' THEN  "H5".L2 
WHEN  "H5".L1 >'' THEN  "H5".L1 
ELSE  "H5".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H5".L5 >'' THEN  "H5".L5_DPTID 
WHEN "H5".L4 >'' THEN  "H5".L4_DPTID 
WHEN "H5".L3 >'' THEN  "H5".L3_DPTID 
WHEN "H5".L2 >'' THEN  "H5".L2_DPTID 
WHEN  "H5".L1 >'' THEN  "H5".L1_DPTID 
ELSE  "H5".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID
FROM TDEPARTMENT d , ( SELECT 
'5' AS LEVEL
, "H4".L0 AS L0
, "H4".L1 AS L1
, "H4".L2 AS L2
, "H4".L3 AS L3
, "H4".L4 AS L4

, (CASE 
WHEN (SUBSTRING(d.DEPARTMENT_CODE,5,1)='*' AND  d.MIK_VALID=1) THEN  d.DEPARTMENT END) AS L5

,NULL AS L6
,NULL AS L7

, "H4".L0_DPTID AS L0_DPTID
, "H4".L1_DPTID AS L1_DPTID
, "H4".L2_DPTID AS L2_DPTID
, "H4".L3_DPTID AS L3_DPTID
, "H4".L4_DPTID AS L4_DPTID
,  d.DEPARTMENTID AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H4".L4 >'' THEN  "H4".L4 
WHEN "H4".L3 >'' THEN  "H4".L3 
WHEN "H4".L2 >'' THEN  "H4".L2 
WHEN  "H4".L1 >'' THEN  "H4".L1 
ELSE  "H4".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H4".L4 >'' THEN  "H4".L4_DPTID 
WHEN "H4".L3 >'' THEN  "H4".L3_DPTID 
WHEN "H4".L2 >'' THEN  "H4".L2_DPTID 
WHEN  "H4".L1 >'' THEN  "H4".L1_DPTID 
ELSE  "H4".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'4' AS LEVEL
, "H3".L0 AS L0
, "H3".L1 AS L1
, "H3".L2 AS L2
, "H3".L3 AS L3
/*,  d.DEPARTMENT as L4 */
, (CASE WHEN (SUBSTRING(d.DEPARTMENT_CODE,5,1)='*' AND  d.MIK_VALID=1) THEN d.DEPARTMENT END) AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H3".L0_DPTID AS L0_DPTID
, "H3".L1_DPTID AS L1_DPTID
, "H3".L2_DPTID AS L2_DPTID
, "H3".L3_DPTID AS L3_DPTID
,  d.DEPARTMENTID AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT
, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H3".L3 >'' THEN  "H3".L3 
WHEN "H3".L2 >'' THEN  "H3".L2 
WHEN  "H3".L1 >'' THEN  "H3".L1 
ELSE  "H3".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H3".L3 >'' THEN  "H3".L3_DPTID 
WHEN "H3".L2 >'' THEN  "H3".L2_DPTID 
WHEN  "H3".L1 >'' THEN  "H3".L1_DPTID 
ELSE  "H3".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW


, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'3' AS LEVEL
, "H2".L0 AS L0
, "H2".L1 AS L1
, "H2".L2 AS L2
, (CASE WHEN d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H2".L0_DPTID AS L0_DPTID
, "H2".L1_DPTID AS L1_DPTID
, "H2".L2_DPTID AS L2_DPTID
,  d.DEPARTMENTID AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT


, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H2".L2 >'' THEN  "H2".L2 
WHEN  "H2".L1 >'' THEN  "H2".L1 
ELSE  "H2".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H2".L2 >'' THEN  "H2".L2_DPTID 
WHEN  "H2".L1 >'' THEN  "H2".L1_DPTID 
ELSE  "H2".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'2' AS LEVEL
, "H1".L0 AS L0
, "H1".L1 AS L1
/* ,  d.DEPARTMENT as L2 */
, (CASE WHEN d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H1".L0_DPTID AS L0_DPTID
, "H1".L1_DPTID AS L1_DPTID
,  d.DEPARTMENTID AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN  "H1".L1 >'' THEN  "H1".L1 
ELSE  "H1".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN  "H1".L1 >'' THEN  "H1".L1_DPTID 
ELSE  "H1".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'1' AS LEVEL
, "H0".DEPARTMENT AS L0
,  d.DEPARTMENT AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H0".DEPARTMENTID AS L0_DPTID
, d.DEPARTMENTID AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT
, d.DEPARTMENT AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
ELSE  "H0".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID
FROM TDEPARTMENT d , ( SELECT 
'0' AS LEVEL
,DEPARTMENT AS L0
,NULL AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7
, DEPARTMENTID AS L0_DPTID
, NULL AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, DEPARTMENT
, DEPARTMENT AS DEPARTMENT_CONCAT
, DEPARTMENTID AS DPT_LOWEST_ID_TO_SHOW

, DEPARTMENTID
, DEPARTMENT_CODE
, PARENTID

FROM TDEPARTMENT 
WHERE  
DEPARTMENTID IN('201789' /* CCO */ ,'100100' /* Territories */,'10004' /* Internal Partner*/)
 ) "H0"
WHERE  
d.PARENTID = "H0".DEPARTMENTID

 ) "H1"
WHERE  
d.PARENTID = "H1".DEPARTMENTID
/* AND d.DEPARTMENTID='203322' */
 ) "H2"
WHERE  
d.PARENTID = "H2".DEPARTMENTID
 ) "H3"
WHERE  
d.PARENTID = "H3".DEPARTMENTID ) "H4"
WHERE  
d.PARENTID = "H4".DEPARTMENTID ) "H5"
WHERE  
d.PARENTID = "H5".DEPARTMENTID  ) "H6"

UNION ALL

SELECT *
 FROM
( SELECT 
'7' AS LEVEL
, "H6".L0 AS L0
, "H6".L1 AS L1
, "H6".L2 AS L2
, "H6".L3 AS L3
, "H6".L4 AS L4
, "H6".L5 AS L5
, "H6".L6 AS L6
, (CASE WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L7

, "H6".L0_DPTID AS L0_DPTID
, "H6".L1_DPTID AS L1_DPTID
, "H6".L2_DPTID AS L2_DPTID
, "H6".L3_DPTID AS L3_DPTID
, "H6".L4_DPTID AS L4_DPTID
, "H6".L5_DPTID AS L5_DPTID
, "H6".L6_DPTID AS L6_DPTID
,  d.DEPARTMENTID AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H6".L6 >'' THEN  "H6".L6 
WHEN "H6".L5 >'' THEN  "H6".L5 
WHEN "H6".L4 >'' THEN  "H6".L4 
WHEN "H6".L3 >'' THEN  "H6".L3 
WHEN "H6".L2 >'' THEN  "H6".L2 
WHEN  "H6".L1 >'' THEN  "H6".L1 
ELSE  "H6".L0 
END) AS DEPARTMENT_CONCAT


, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H6".L6 >'' THEN  "H6".L6_DPTID 
WHEN "H6".L5 >'' THEN  "H6".L5_DPTID 
WHEN "H6".L4 >'' THEN  "H6".L4_DPTID 
WHEN "H6".L3 >'' THEN  "H6".L3_DPTID 
WHEN "H6".L2 >'' THEN  "H6".L2_DPTID 
WHEN  "H6".L1 >'' THEN  "H6".L1_DPTID 
ELSE  "H6".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'6' AS LEVEL
, "H5".L0 AS L0
, "H5".L1 AS L1
, "H5".L2 AS L2
, "H5".L3 AS L3
, "H5".L4 AS L4
, "H5".L5 AS L5

/* ,  d.DEPARTMENT as L6 */

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN  d.DEPARTMENT END) AS L6

,NULL AS L7

, "H5".L0_DPTID AS L0_DPTID
, "H5".L1_DPTID AS L1_DPTID
, "H5".L2_DPTID AS L2_DPTID
, "H5".L3_DPTID AS L3_DPTID
, "H5".L4_DPTID AS L4_DPTID
, "H5".L5_DPTID AS L5_DPTID
,  d.DEPARTMENTID AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H5".L5 >'' THEN  "H5".L5 
WHEN "H5".L4 >'' THEN  "H5".L4 
WHEN "H5".L3 >'' THEN  "H5".L3 
WHEN "H5".L2 >'' THEN  "H5".L2 
WHEN  "H5".L1 >'' THEN  "H5".L1 
ELSE  "H5".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H5".L5 >'' THEN  "H5".L5_DPTID 
WHEN "H5".L4 >'' THEN  "H5".L4_DPTID 
WHEN "H5".L3 >'' THEN  "H5".L3_DPTID 
WHEN "H5".L2 >'' THEN  "H5".L2_DPTID 
WHEN  "H5".L1 >'' THEN  "H5".L1_DPTID 
ELSE  "H5".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID
FROM TDEPARTMENT d , ( SELECT 
'5' AS LEVEL
, "H4".L0 AS L0
, "H4".L1 AS L1
, "H4".L2 AS L2
, "H4".L3 AS L3
, "H4".L4 AS L4

, (CASE 
WHEN (SUBSTRING(d.DEPARTMENT_CODE,5,1)='*' AND  d.MIK_VALID=1) THEN  d.DEPARTMENT END) AS L5

,NULL AS L6
,NULL AS L7

, "H4".L0_DPTID AS L0_DPTID
, "H4".L1_DPTID AS L1_DPTID
, "H4".L2_DPTID AS L2_DPTID
, "H4".L3_DPTID AS L3_DPTID
, "H4".L4_DPTID AS L4_DPTID
,  d.DEPARTMENTID AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H4".L4 >'' THEN  "H4".L4 
WHEN "H4".L3 >'' THEN  "H4".L3 
WHEN "H4".L2 >'' THEN  "H4".L2 
WHEN  "H4".L1 >'' THEN  "H4".L1 
ELSE  "H4".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H4".L4 >'' THEN  "H4".L4_DPTID 
WHEN "H4".L3 >'' THEN  "H4".L3_DPTID 
WHEN "H4".L2 >'' THEN  "H4".L2_DPTID 
WHEN  "H4".L1 >'' THEN  "H4".L1_DPTID 
ELSE  "H4".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'4' AS LEVEL
, "H3".L0 AS L0
, "H3".L1 AS L1
, "H3".L2 AS L2
, "H3".L3 AS L3
/*,  d.DEPARTMENT as L4 */
, (CASE WHEN (SUBSTRING(d.DEPARTMENT_CODE,5,1)='*' AND  d.MIK_VALID=1) THEN d.DEPARTMENT END) AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H3".L0_DPTID AS L0_DPTID
, "H3".L1_DPTID AS L1_DPTID
, "H3".L2_DPTID AS L2_DPTID
, "H3".L3_DPTID AS L3_DPTID
,  d.DEPARTMENTID AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT
, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H3".L3 >'' THEN  "H3".L3 
WHEN "H3".L2 >'' THEN  "H3".L2 
WHEN  "H3".L1 >'' THEN  "H3".L1 
ELSE  "H3".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H3".L3 >'' THEN  "H3".L3_DPTID 
WHEN "H3".L2 >'' THEN  "H3".L2_DPTID 
WHEN  "H3".L1 >'' THEN  "H3".L1_DPTID 
ELSE  "H3".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW


, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'3' AS LEVEL
, "H2".L0 AS L0
, "H2".L1 AS L1
, "H2".L2 AS L2
, (CASE WHEN d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H2".L0_DPTID AS L0_DPTID
, "H2".L1_DPTID AS L1_DPTID
, "H2".L2_DPTID AS L2_DPTID
,  d.DEPARTMENTID AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT


, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H2".L2 >'' THEN  "H2".L2 
WHEN  "H2".L1 >'' THEN  "H2".L1 
ELSE  "H2".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H2".L2 >'' THEN  "H2".L2_DPTID 
WHEN  "H2".L1 >'' THEN  "H2".L1_DPTID 
ELSE  "H2".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'2' AS LEVEL
, "H1".L0 AS L0
, "H1".L1 AS L1
/* ,  d.DEPARTMENT as L2 */
, (CASE WHEN d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H1".L0_DPTID AS L0_DPTID
, "H1".L1_DPTID AS L1_DPTID
,  d.DEPARTMENTID AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN  "H1".L1 >'' THEN  "H1".L1 
ELSE  "H1".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN  "H1".L1 >'' THEN  "H1".L1_DPTID 
ELSE  "H1".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'1' AS LEVEL
, "H0".DEPARTMENT AS L0
,  d.DEPARTMENT AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H0".DEPARTMENTID AS L0_DPTID
, d.DEPARTMENTID AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT
, d.DEPARTMENT AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
ELSE  "H0".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID
FROM TDEPARTMENT d , ( SELECT 
'0' AS LEVEL
,DEPARTMENT AS L0
,NULL AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7
, DEPARTMENTID AS L0_DPTID
, NULL AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, DEPARTMENT
, DEPARTMENT AS DEPARTMENT_CONCAT
, DEPARTMENTID AS DPT_LOWEST_ID_TO_SHOW

, DEPARTMENTID
, DEPARTMENT_CODE
, PARENTID

FROM TDEPARTMENT 
WHERE  
DEPARTMENTID IN('201789' /* CCO */ ,'100100' /* Territories */,'10004' /* Internal Partner*/)
 ) "H0"
WHERE  
d.PARENTID = "H0".DEPARTMENTID

 ) "H1"
WHERE  
d.PARENTID = "H1".DEPARTMENTID
/* AND d.DEPARTMENTID='203322' */
 ) "H2"
WHERE  
d.PARENTID = "H2".DEPARTMENTID
 ) "H3"
WHERE  
d.PARENTID = "H3".DEPARTMENTID ) "H4"
WHERE  
d.PARENTID = "H4".DEPARTMENTID ) "H5"
WHERE  
d.PARENTID = "H5".DEPARTMENTID  ) "H6"
WHERE  
d.PARENTID = "H6".DEPARTMENTID ) "H7"

UNION ALL 

SELECT *
 FROM
( SELECT 
'8' AS LEVEL
, "H7".L0 AS L0
, "H7".L1 AS L1
, "H7".L2 AS L2
, "H7".L3 AS L3
, "H7".L4 AS L4
, "H7".L5 AS L5
, "H7".L6 AS L6
, "H7".L7 AS L7

, "H7".L0_DPTID AS L0_DPTID
, "H7".L1_DPTID AS L1_DPTID
, "H7".L2_DPTID AS L2_DPTID
, "H7".L3_DPTID AS L3_DPTID
, "H7".L4_DPTID AS L4_DPTID
, "H7".L5_DPTID AS L5_DPTID
, "H7".L6_DPTID AS L6_DPTID
, "H7".L7_DPTID AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN "H7".L7 >'' THEN  "H7".L7 
WHEN "H7".L6 >'' THEN  "H7".L6 
WHEN "H7".L5 >'' THEN  "H7".L5 
WHEN "H7".L4 >'' THEN  "H7".L4 
WHEN "H7".L3 >'' THEN  "H7".L3 
WHEN "H7".L2 >'' THEN  "H7".L2 
WHEN  "H7".L1 >'' THEN  "H7".L1 
ELSE  "H7".L0 
END) AS DEPARTMENT_CONCAT


, (CASE 
WHEN "H7".L7 >'' THEN  "H7".L7_DPTID 
WHEN "H7".L6 >'' THEN  "H7".L6_DPTID 
WHEN "H7".L5 >'' THEN  "H7".L5_DPTID 
WHEN "H7".L4 >'' THEN  "H7".L4_DPTID 
WHEN "H7".L3 >'' THEN  "H7".L3_DPTID 
WHEN "H7".L2 >'' THEN  "H7".L2_DPTID 
WHEN  "H7".L1 >'' THEN  "H7".L1_DPTID 
ELSE  "H7".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'7' AS LEVEL
, "H6".L0 AS L0
, "H6".L1 AS L1
, "H6".L2 AS L2
, "H6".L3 AS L3
, "H6".L4 AS L4
, "H6".L5 AS L5
, "H6".L6 AS L6
, (CASE WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L7

, "H6".L0_DPTID AS L0_DPTID
, "H6".L1_DPTID AS L1_DPTID
, "H6".L2_DPTID AS L2_DPTID
, "H6".L3_DPTID AS L3_DPTID
, "H6".L4_DPTID AS L4_DPTID
, "H6".L5_DPTID AS L5_DPTID
, "H6".L6_DPTID AS L6_DPTID
,  d.DEPARTMENTID AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H6".L6 >'' THEN  "H6".L6 
WHEN "H6".L5 >'' THEN  "H6".L5 
WHEN "H6".L4 >'' THEN  "H6".L4 
WHEN "H6".L3 >'' THEN  "H6".L3 
WHEN "H6".L2 >'' THEN  "H6".L2 
WHEN  "H6".L1 >'' THEN  "H6".L1 
ELSE  "H6".L0 
END) AS DEPARTMENT_CONCAT


, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H6".L6 >'' THEN  "H6".L6_DPTID 
WHEN "H6".L5 >'' THEN  "H6".L5_DPTID 
WHEN "H6".L4 >'' THEN  "H6".L4_DPTID 
WHEN "H6".L3 >'' THEN  "H6".L3_DPTID 
WHEN "H6".L2 >'' THEN  "H6".L2_DPTID 
WHEN  "H6".L1 >'' THEN  "H6".L1_DPTID 
ELSE  "H6".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'6' AS LEVEL
, "H5".L0 AS L0
, "H5".L1 AS L1
, "H5".L2 AS L2
, "H5".L3 AS L3
, "H5".L4 AS L4
, "H5".L5 AS L5

/* ,  d.DEPARTMENT as L6 */

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN  d.DEPARTMENT END) AS L6

,NULL AS L7

, "H5".L0_DPTID AS L0_DPTID
, "H5".L1_DPTID AS L1_DPTID
, "H5".L2_DPTID AS L2_DPTID
, "H5".L3_DPTID AS L3_DPTID
, "H5".L4_DPTID AS L4_DPTID
, "H5".L5_DPTID AS L5_DPTID
,  d.DEPARTMENTID AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H5".L5 >'' THEN  "H5".L5 
WHEN "H5".L4 >'' THEN  "H5".L4 
WHEN "H5".L3 >'' THEN  "H5".L3 
WHEN "H5".L2 >'' THEN  "H5".L2 
WHEN  "H5".L1 >'' THEN  "H5".L1 
ELSE  "H5".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H5".L5 >'' THEN  "H5".L5_DPTID 
WHEN "H5".L4 >'' THEN  "H5".L4_DPTID 
WHEN "H5".L3 >'' THEN  "H5".L3_DPTID 
WHEN "H5".L2 >'' THEN  "H5".L2_DPTID 
WHEN  "H5".L1 >'' THEN  "H5".L1_DPTID 
ELSE  "H5".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID
FROM TDEPARTMENT d , ( SELECT 
'5' AS LEVEL
, "H4".L0 AS L0
, "H4".L1 AS L1
, "H4".L2 AS L2
, "H4".L3 AS L3
, "H4".L4 AS L4

, (CASE 
WHEN (SUBSTRING(d.DEPARTMENT_CODE,5,1)='*' AND  d.MIK_VALID=1) THEN  d.DEPARTMENT END) AS L5

,NULL AS L6
,NULL AS L7

, "H4".L0_DPTID AS L0_DPTID
, "H4".L1_DPTID AS L1_DPTID
, "H4".L2_DPTID AS L2_DPTID
, "H4".L3_DPTID AS L3_DPTID
, "H4".L4_DPTID AS L4_DPTID
,  d.DEPARTMENTID AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H4".L4 >'' THEN  "H4".L4 
WHEN "H4".L3 >'' THEN  "H4".L3 
WHEN "H4".L2 >'' THEN  "H4".L2 
WHEN  "H4".L1 >'' THEN  "H4".L1 
ELSE  "H4".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H4".L4 >'' THEN  "H4".L4_DPTID 
WHEN "H4".L3 >'' THEN  "H4".L3_DPTID 
WHEN "H4".L2 >'' THEN  "H4".L2_DPTID 
WHEN  "H4".L1 >'' THEN  "H4".L1_DPTID 
ELSE  "H4".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'4' AS LEVEL
, "H3".L0 AS L0
, "H3".L1 AS L1
, "H3".L2 AS L2
, "H3".L3 AS L3
/*,  d.DEPARTMENT as L4 */
, (CASE WHEN (SUBSTRING(d.DEPARTMENT_CODE,5,1)='*' AND  d.MIK_VALID=1) THEN d.DEPARTMENT END) AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H3".L0_DPTID AS L0_DPTID
, "H3".L1_DPTID AS L1_DPTID
, "H3".L2_DPTID AS L2_DPTID
, "H3".L3_DPTID AS L3_DPTID
,  d.DEPARTMENTID AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT
, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H3".L3 >'' THEN  "H3".L3 
WHEN "H3".L2 >'' THEN  "H3".L2 
WHEN  "H3".L1 >'' THEN  "H3".L1 
ELSE  "H3".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H3".L3 >'' THEN  "H3".L3_DPTID 
WHEN "H3".L2 >'' THEN  "H3".L2_DPTID 
WHEN  "H3".L1 >'' THEN  "H3".L1_DPTID 
ELSE  "H3".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW


, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'3' AS LEVEL
, "H2".L0 AS L0
, "H2".L1 AS L1
, "H2".L2 AS L2
, (CASE WHEN d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H2".L0_DPTID AS L0_DPTID
, "H2".L1_DPTID AS L1_DPTID
, "H2".L2_DPTID AS L2_DPTID
,  d.DEPARTMENTID AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT


, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H2".L2 >'' THEN  "H2".L2 
WHEN  "H2".L1 >'' THEN  "H2".L1 
ELSE  "H2".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H2".L2 >'' THEN  "H2".L2_DPTID 
WHEN  "H2".L1 >'' THEN  "H2".L1_DPTID 
ELSE  "H2".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'2' AS LEVEL
, "H1".L0 AS L0
, "H1".L1 AS L1
/* ,  d.DEPARTMENT as L2 */
, (CASE WHEN d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H1".L0_DPTID AS L0_DPTID
, "H1".L1_DPTID AS L1_DPTID
,  d.DEPARTMENTID AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN  "H1".L1 >'' THEN  "H1".L1 
ELSE  "H1".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN  "H1".L1 >'' THEN  "H1".L1_DPTID 
ELSE  "H1".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'1' AS LEVEL
, "H0".DEPARTMENT AS L0
,  d.DEPARTMENT AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H0".DEPARTMENTID AS L0_DPTID
, d.DEPARTMENTID AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT
, d.DEPARTMENT AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
ELSE  "H0".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID
FROM TDEPARTMENT d , ( SELECT 
'0' AS LEVEL
,DEPARTMENT AS L0
,NULL AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7
, DEPARTMENTID AS L0_DPTID
, NULL AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, DEPARTMENT
, DEPARTMENT AS DEPARTMENT_CONCAT
, DEPARTMENTID AS DPT_LOWEST_ID_TO_SHOW

, DEPARTMENTID
, DEPARTMENT_CODE
, PARENTID

FROM TDEPARTMENT 
WHERE  
DEPARTMENTID IN('201789' /* CCO */ ,'100100' /* Territories */,'10004' /* Internal Partner*/)
 ) "H0"
WHERE  
d.PARENTID = "H0".DEPARTMENTID

 ) "H1"
WHERE  
d.PARENTID = "H1".DEPARTMENTID
/* AND d.DEPARTMENTID='203322' */
 ) "H2"
WHERE  
d.PARENTID = "H2".DEPARTMENTID
 ) "H3"
WHERE  
d.PARENTID = "H3".DEPARTMENTID ) "H4"
WHERE  
d.PARENTID = "H4".DEPARTMENTID ) "H5"
WHERE  
d.PARENTID = "H5".DEPARTMENTID  ) "H6"
WHERE  
d.PARENTID = "H6".DEPARTMENTID ) "H7"
WHERE  
d.PARENTID = "H7".DEPARTMENTID ) "H8"

UNION ALL 

SELECT *
 FROM
( SELECT 
'9' AS LEVEL
, "H8".L0 AS L0
, "H8".L1 AS L1
, "H8".L2 AS L2
, "H8".L3 AS L3
, "H8".L4 AS L4
, "H8".L5 AS L5
, "H8".L6 AS L6
, "H8".L7 AS L7

, "H8".L0_DPTID AS L0_DPTID
, "H8".L1_DPTID AS L1_DPTID
, "H8".L2_DPTID AS L2_DPTID
, "H8".L3_DPTID AS L3_DPTID
, "H8".L4_DPTID AS L4_DPTID
, "H8".L5_DPTID AS L5_DPTID
, "H8".L6_DPTID AS L6_DPTID
, "H8".L7_DPTID AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN "H8".L7 >'' THEN  "H8".L7 
WHEN "H8".L6 >'' THEN  "H8".L6 
WHEN "H8".L5 >'' THEN  "H8".L5 
WHEN "H8".L4 >'' THEN  "H8".L4 
WHEN "H8".L3 >'' THEN  "H8".L3 
WHEN "H8".L2 >'' THEN  "H8".L2 
WHEN  "H8".L1 >'' THEN  "H8".L1 
ELSE  "H8".L0 
END) AS DEPARTMENT_CONCAT


, (CASE 
WHEN "H8".L7 >'' THEN  "H8".L7_DPTID 
WHEN "H8".L6 >'' THEN  "H8".L6_DPTID 
WHEN "H8".L5 >'' THEN  "H8".L5_DPTID 
WHEN "H8".L4 >'' THEN  "H8".L4_DPTID 
WHEN "H8".L3 >'' THEN  "H8".L3_DPTID 
WHEN "H8".L2 >'' THEN  "H8".L2_DPTID 
WHEN  "H8".L1 >'' THEN  "H8".L1_DPTID 
ELSE  "H8".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'8' AS LEVEL
, "H7".L0 AS L0
, "H7".L1 AS L1
, "H7".L2 AS L2
, "H7".L3 AS L3
, "H7".L4 AS L4
, "H7".L5 AS L5
, "H7".L6 AS L6
, "H7".L7 AS L7

, "H7".L0_DPTID AS L0_DPTID
, "H7".L1_DPTID AS L1_DPTID
, "H7".L2_DPTID AS L2_DPTID
, "H7".L3_DPTID AS L3_DPTID
, "H7".L4_DPTID AS L4_DPTID
, "H7".L5_DPTID AS L5_DPTID
, "H7".L6_DPTID AS L6_DPTID
, "H7".L7_DPTID AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN "H7".L7 >'' THEN  "H7".L7 
WHEN "H7".L6 >'' THEN  "H7".L6 
WHEN "H7".L5 >'' THEN  "H7".L5 
WHEN "H7".L4 >'' THEN  "H7".L4 
WHEN "H7".L3 >'' THEN  "H7".L3 
WHEN "H7".L2 >'' THEN  "H7".L2 
WHEN  "H7".L1 >'' THEN  "H7".L1 
ELSE  "H7".L0 
END) AS DEPARTMENT_CONCAT


, (CASE 
WHEN "H7".L7 >'' THEN  "H7".L7_DPTID 
WHEN "H7".L6 >'' THEN  "H7".L6_DPTID 
WHEN "H7".L5 >'' THEN  "H7".L5_DPTID 
WHEN "H7".L4 >'' THEN  "H7".L4_DPTID 
WHEN "H7".L3 >'' THEN  "H7".L3_DPTID 
WHEN "H7".L2 >'' THEN  "H7".L2_DPTID 
WHEN  "H7".L1 >'' THEN  "H7".L1_DPTID 
ELSE  "H7".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'7' AS LEVEL
, "H6".L0 AS L0
, "H6".L1 AS L1
, "H6".L2 AS L2
, "H6".L3 AS L3
, "H6".L4 AS L4
, "H6".L5 AS L5
, "H6".L6 AS L6
, (CASE WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L7

, "H6".L0_DPTID AS L0_DPTID
, "H6".L1_DPTID AS L1_DPTID
, "H6".L2_DPTID AS L2_DPTID
, "H6".L3_DPTID AS L3_DPTID
, "H6".L4_DPTID AS L4_DPTID
, "H6".L5_DPTID AS L5_DPTID
, "H6".L6_DPTID AS L6_DPTID
,  d.DEPARTMENTID AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H6".L6 >'' THEN  "H6".L6 
WHEN "H6".L5 >'' THEN  "H6".L5 
WHEN "H6".L4 >'' THEN  "H6".L4 
WHEN "H6".L3 >'' THEN  "H6".L3 
WHEN "H6".L2 >'' THEN  "H6".L2 
WHEN  "H6".L1 >'' THEN  "H6".L1 
ELSE  "H6".L0 
END) AS DEPARTMENT_CONCAT


, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H6".L6 >'' THEN  "H6".L6_DPTID 
WHEN "H6".L5 >'' THEN  "H6".L5_DPTID 
WHEN "H6".L4 >'' THEN  "H6".L4_DPTID 
WHEN "H6".L3 >'' THEN  "H6".L3_DPTID 
WHEN "H6".L2 >'' THEN  "H6".L2_DPTID 
WHEN  "H6".L1 >'' THEN  "H6".L1_DPTID 
ELSE  "H6".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'6' AS LEVEL
, "H5".L0 AS L0
, "H5".L1 AS L1
, "H5".L2 AS L2
, "H5".L3 AS L3
, "H5".L4 AS L4
, "H5".L5 AS L5

/* ,  d.DEPARTMENT as L6 */

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN  d.DEPARTMENT END) AS L6

,NULL AS L7

, "H5".L0_DPTID AS L0_DPTID
, "H5".L1_DPTID AS L1_DPTID
, "H5".L2_DPTID AS L2_DPTID
, "H5".L3_DPTID AS L3_DPTID
, "H5".L4_DPTID AS L4_DPTID
, "H5".L5_DPTID AS L5_DPTID
,  d.DEPARTMENTID AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H5".L5 >'' THEN  "H5".L5 
WHEN "H5".L4 >'' THEN  "H5".L4 
WHEN "H5".L3 >'' THEN  "H5".L3 
WHEN "H5".L2 >'' THEN  "H5".L2 
WHEN  "H5".L1 >'' THEN  "H5".L1 
ELSE  "H5".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H5".L5 >'' THEN  "H5".L5_DPTID 
WHEN "H5".L4 >'' THEN  "H5".L4_DPTID 
WHEN "H5".L3 >'' THEN  "H5".L3_DPTID 
WHEN "H5".L2 >'' THEN  "H5".L2_DPTID 
WHEN  "H5".L1 >'' THEN  "H5".L1_DPTID 
ELSE  "H5".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID
FROM TDEPARTMENT d , ( SELECT 
'5' AS LEVEL
, "H4".L0 AS L0
, "H4".L1 AS L1
, "H4".L2 AS L2
, "H4".L3 AS L3
, "H4".L4 AS L4

, (CASE 
WHEN (SUBSTRING(d.DEPARTMENT_CODE,5,1)='*' AND  d.MIK_VALID=1) THEN  d.DEPARTMENT END) AS L5

,NULL AS L6
,NULL AS L7

, "H4".L0_DPTID AS L0_DPTID
, "H4".L1_DPTID AS L1_DPTID
, "H4".L2_DPTID AS L2_DPTID
, "H4".L3_DPTID AS L3_DPTID
, "H4".L4_DPTID AS L4_DPTID
,  d.DEPARTMENTID AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H4".L4 >'' THEN  "H4".L4 
WHEN "H4".L3 >'' THEN  "H4".L3 
WHEN "H4".L2 >'' THEN  "H4".L2 
WHEN  "H4".L1 >'' THEN  "H4".L1 
ELSE  "H4".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H4".L4 >'' THEN  "H4".L4_DPTID 
WHEN "H4".L3 >'' THEN  "H4".L3_DPTID 
WHEN "H4".L2 >'' THEN  "H4".L2_DPTID 
WHEN  "H4".L1 >'' THEN  "H4".L1_DPTID 
ELSE  "H4".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'4' AS LEVEL
, "H3".L0 AS L0
, "H3".L1 AS L1
, "H3".L2 AS L2
, "H3".L3 AS L3
/*,  d.DEPARTMENT as L4 */
, (CASE WHEN (SUBSTRING(d.DEPARTMENT_CODE,5,1)='*' AND  d.MIK_VALID=1) THEN d.DEPARTMENT END) AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H3".L0_DPTID AS L0_DPTID
, "H3".L1_DPTID AS L1_DPTID
, "H3".L2_DPTID AS L2_DPTID
, "H3".L3_DPTID AS L3_DPTID
,  d.DEPARTMENTID AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT
, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H3".L3 >'' THEN  "H3".L3 
WHEN "H3".L2 >'' THEN  "H3".L2 
WHEN  "H3".L1 >'' THEN  "H3".L1 
ELSE  "H3".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H3".L3 >'' THEN  "H3".L3_DPTID 
WHEN "H3".L2 >'' THEN  "H3".L2_DPTID 
WHEN  "H3".L1 >'' THEN  "H3".L1_DPTID 
ELSE  "H3".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW


, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'3' AS LEVEL
, "H2".L0 AS L0
, "H2".L1 AS L1
, "H2".L2 AS L2
, (CASE WHEN d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H2".L0_DPTID AS L0_DPTID
, "H2".L1_DPTID AS L1_DPTID
, "H2".L2_DPTID AS L2_DPTID
,  d.DEPARTMENTID AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT


, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN "H2".L2 >'' THEN  "H2".L2 
WHEN  "H2".L1 >'' THEN  "H2".L1 
ELSE  "H2".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN "H2".L2 >'' THEN  "H2".L2_DPTID 
WHEN  "H2".L1 >'' THEN  "H2".L1_DPTID 
ELSE  "H2".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'2' AS LEVEL
, "H1".L0 AS L0
, "H1".L1 AS L1
/* ,  d.DEPARTMENT as L2 */
, (CASE WHEN d.MIK_VALID=1 THEN d.DEPARTMENT END) AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H1".L0_DPTID AS L0_DPTID
, "H1".L1_DPTID AS L1_DPTID
,  d.DEPARTMENTID AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT

, (CASE 
WHEN SUBSTRING(d.DEPARTMENT_CODE,5,1)='*'  AND  d.MIK_VALID=1 THEN d.DEPARTMENT
WHEN  "H1".L1 >'' THEN  "H1".L1 
ELSE  "H1".L0 
END) AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
WHEN  "H1".L1 >'' THEN  "H1".L1_DPTID 
ELSE  "H1".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID

FROM TDEPARTMENT d , ( SELECT 
'1' AS LEVEL
, "H0".DEPARTMENT AS L0
,  d.DEPARTMENT AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7

, "H0".DEPARTMENTID AS L0_DPTID
, d.DEPARTMENTID AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, d.DEPARTMENT
, d.DEPARTMENT AS DEPARTMENT_CONCAT

, (CASE 
WHEN d.MIK_VALID=1 THEN d.DEPARTMENTID
ELSE  "H0".L0_DPTID 
END) AS DPT_LOWEST_ID_TO_SHOW

, d.DEPARTMENTID
, d.DEPARTMENT_CODE
, d.PARENTID
FROM TDEPARTMENT d , ( SELECT 
'0' AS LEVEL
,DEPARTMENT AS L0
,NULL AS L1
,NULL AS L2
,NULL AS L3
,NULL AS L4
,NULL AS L5
,NULL AS L6
,NULL AS L7
, DEPARTMENTID AS L0_DPTID
, NULL AS L1_DPTID
, NULL AS L2_DPTID
, NULL AS L3_DPTID
, NULL AS L4_DPTID
, NULL AS L5_DPTID
, NULL AS L6_DPTID
, NULL AS L7_DPTID

, DEPARTMENT
, DEPARTMENT AS DEPARTMENT_CONCAT
, DEPARTMENTID AS DPT_LOWEST_ID_TO_SHOW

, DEPARTMENTID
, DEPARTMENT_CODE
, PARENTID

FROM TDEPARTMENT 
WHERE  
DEPARTMENTID IN('201789' /* CCO */ ,'100100' /* Territories */,'10004' /* Internal Partner*/)
 ) "H0"
WHERE  
d.PARENTID = "H0".DEPARTMENTID

 ) "H1"
WHERE  
d.PARENTID = "H1".DEPARTMENTID
/* AND d.DEPARTMENTID='203322' */
 ) "H2"
WHERE  
d.PARENTID = "H2".DEPARTMENTID
 ) "H3"
WHERE  
d.PARENTID = "H3".DEPARTMENTID ) "H4"
WHERE  
d.PARENTID = "H4".DEPARTMENTID ) "H5"
WHERE  
d.PARENTID = "H5".DEPARTMENTID  ) "H6"
WHERE  
d.PARENTID = "H6".DEPARTMENTID ) "H7"
WHERE  
d.PARENTID = "H7".DEPARTMENTID ) "H8"
WHERE  
d.PARENTID = "H8".DEPARTMENTID ) "H9"
  )  Hierarchy
  



GO
/****** Object:  View [dbo].[V_TheCompany_VDEPARTMENT_VUSERGROUP]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE view
[dbo].[V_TheCompany_VDEPARTMENT_VUSERGROUP]

as 
/* includes ALL departments, internal partners or otherwise */
Select 
	(case when d.DEPARTMENTID IS not null and g.usergroupid is null then 'Department' 
		WHEN d.departmentid is not null and g.usergroupid is not null then 'Dpt_AND_UserGroup' 
		WHEN d.departmentid is null and g.usergroupid is not null then 'UserGroup' 
		 WHEN g.companyid is not null then 'Company'		 		 
		ELSE 'OTHER' END )
			as IsDptUserGrp

		, 	(case when g.USERGROUPID IN  (1089 /* all users public */
			, 3397 /* read headers */
			, 4995 /*super user msa read write */
			, 130 /* all super users */
			) 
			THEN 'PUBLIC' ELSE 'OTHER' END) as UserGroupType

		, (case when g.usergroupid  in  ( 0 /* sys admin */
									, 20 /* Legal */
									, 126 /* System Internal */
									, 130 /* Super users */
									, 137 /* Read All */
									, 1089 /* Public */
									, 3397 /* Read all Headers */
									, 4901 /* Top Secret */) THEN 1 else 0 END) 
									as GrpDptGroupIsGGC_Tax_Finance_FLAG

	,d.DEPARTMENT as DPT_NAME
	, left(replace((CASE WHEN DptCode_BranchOffice>'' 
		THEN DptCode_BranchOffice ELSE p.Code_Basic END),',',''),255) 
		as DptCode_Basic_Text /* was nvarchar 4000 */
	/* Branch office, Head office */
	, InternalPartnerType
	, Dpt_Code_HeadOffice /* e.g. CHI for IEICHI[BranchOffice] */
	, DptCode_BranchOffice /* e.g. IEI for IEICHI[BranchOffice] */

	, LEN(CASE WHEN DptCode_BranchOffice>'' THEN DptCode_BranchOffice ELSE p.Code_Basic END) as DptCode_Basic_LEN
	/* Automatic user group upload */
	, (case when g.FIXED like 'AUTO_%' THEN 1 
		ELSE 0 END) as AutomaticUserGroupUploadFlag
	, (CASE WHEN left(d.DEPARTMENT_code,1)=',' 
		THEN substring(d.department, CHARINDEX(')', d.department)+2, len(d.department)-CHARINDEX(')', d.department)+2)
		ELSE '' END) as InternalPNoCountryIB /* for comparing to Data Sheet, Ariba etc., varchar conversion removes special chars such as accents */
	, (CASE WHEN left(d.DEPARTMENT_code,1)=',' 
		THEN CAST(substring(d.department, CHARINDEX(')', d.department)+2, len(d.department)-CHARINDEX(')', d.department)+2) AS varchar(100)) COLLATE Cyrillic_General_CI_AI 
		ELSE '' END) as InternalPNoCountryIBNoSpCh /* for comparing to Data Sheet, Ariba etc., varchar conversion removes special chars such as accents */
	, g.* /* used to be first item after select but is blank due to full join so the first few rows are blank therefore moving it here into the middle */
	 	, d.MIK_VALID as Dpt_MIK_VALID
	, d.DEPARTMENTID as DPT_DEPARTMENTID
	, p.Code_Basic
	,h.[LEVEL]
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
		,(case when g.DEPARTMENTID IS not null then 'Department' 
				when g.COMPANYID IS not null then 'Company' 
				ELSE 'UserGroup' END) as GrpCategory

	/* ALL IDs */
	,CAST(LEFT(STUFF(
	(SELECT ';' + s.EMAIL
	FROM VUSER s
	WHERE s.primaryusergroupid =g.USERGROUPID
	and s.USER_MIK_VALID = 1
	FOR XML PATH('')),1,1,''),255) as varchar(255)) AS PrimaryGroupUserEmails

	,(SELECT COUNT(s.PRIMARYUSERGROUPID)
	FROM VUSER s
	WHERE s.PRIMARYUSERGROUPID = g.USERGROUPID
	and s.USER_MIK_VALID = 1
	GROUP BY s.PRIMARYUSERGROUPID) AS PrimaryGroupUserCount
	
	,CAST(LEFT(STUFF(
	(SELECT ';' + s.EMAIL
	FROM VUSER s
	WHERE s.primaryusergroupid =g.USERGROUPID
		and s.UserProfile like '%super%'
		and s.USER_MIK_VALID = 1
	FOR XML PATH('')),1,1,''),255) as varchar(255)) AS PrimaryGroupUserSuperEmails
	
	,(SELECT COUNT(s.PRIMARYUSERGROUPID)
	FROM VUSER s
	WHERE s.PRIMARYUSERGROUPID = g.USERGROUPID
		and s.UserProfile like '%super%'
		and s.USER_MIK_VALID = 1
	GROUP BY s.PRIMARYUSERGROUPID) AS PrimaryGroupUserSuperCount
	, (case when d.mik_valid = 1 THEN 'Active' Else 'Inactive' END) as Dpt_Status
from TDEPARTMENT d
		/* left join V_TheCompany_VDepartment_Parsed dp on d.DEPARTMENTID = dp.DptID_Parsed NO- hierarchy source */
		left join dbo.V_TheCompany_Hierarchy h on d.DEPARTMENTID = h.DEPARTMENTID
		left join V_TheCompany_VDepartment_ParsedDpt_InternalPartner p on d.DEPARTMENTID = p.DEPARTMENTID
	FULL join TUSERGROUP g  on d.DEPARTMENTid = g.DEPARTMENTID  /* inner join will not include all records since not all departments have user groups) */



GO
/****** Object:  View [dbo].[V_TheCompany_VUSER]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[V_TheCompany_VUSER]

AS

/* select MAX(len(DOMAINNAME))from v_TheCompany_vuser */
SELECT	U.USERID,
		U.USERINITIAL,
		U.PATHID,
		PA.PATH,
		U.MIK_VALID AS USER_MIK_VALID,
		E.EMPLOYEEID,
		/* E.MIK_VALID AS EMPLOYEE_MIK_VALID, */
		cast(c.COUNTRY as varchar(50)) as COUNTRY , /* C.COUNTRY, COUNTRYID removed in 6.16 for data privacy reasons */
		P.PERSONID,
		P.PERSONAL_CODE,
		P.TITLE,
		P.FIRSTNAME,
		P.MIDDLENAME,
		P.LASTNAME, 
		P.INITIALS,
		cast(P.DISPLAYNAME as varchar(100)) as DISPLAYNAME , /* max len 63*/
		cast(P.EMAIL as varchar(100)) as EMAIL, /* max len 73 */
		p.COUNTRYID,
		NULL AS STARTDATE, /* e.STARTDATE,removed in 6.16 for data privacy reasons */
		UUG.USERGROUPID AS PRIMARYUSERGROUPID, 

		CAST(ISNULL(UG.USERGROUP ,'') AS VARCHAR(255)) AS PRIMARYUSERGROUP, /*otherwise it is nvarchar 450 which becomes a memo fld in Access */
		E.DEPARTMENTID,
		cast(DEP.DEPARTMENT as varchar(100)) as DEPARTMENT, /* max len 87 */
		cast(dep.DEPARTMENT_CODE as varchar(100)) as DEPARTMENT_CODE , /* max len 52 */
		U.ISEXTERNALUSER,
		cast(U.DOMAINNETBIOSUSERNAME as varchar(50)) as DOMAINNETBIOSUSERNAME, /* max len 30 */
		
		(CASE WHEN CHARINDEX ('@', DOMAINUSERNAME) is null or CHARINDEX ('@', DOMAINUSERNAME) <3
			THEN '' 
			ELSE LEFT(domainusername,CHARINDEX ('@', DOMAINUSERNAME)-1) END) as USERINITIAL_DOMAINUSERNAME, /* strip out user ID */
		(CASE WHEN CHARINDEX ('\', [DOMAINNETBIOSUSERNAME]) is null or CHARINDEX ('\', [DOMAINNETBIOSUSERNAME]) <3
			THEN '' 
			ELSE LEFT([DOMAINNETBIOSUSERNAME],CHARINDEX ('\', [DOMAINNETBIOSUSERNAME])-1) END) 
			as DOMAINNAME, /* strip out domain */
		
		U.DOMAINUSERNAME,
		U.DOMAINUSERSID,
		U.UserProfileID,
		PF.UserProfile
		, (CASE WHEN pf.userprofile LIKE '%basic%' THEN 'Basic User' 
			WHEN pf.userprofile LIKE '%left%' THEN 'Has Left TheCompany'
			WHEN pf.USERPROFILE IS null then '' 
			ELSE 'Super User' END) as UserProfileGroup

		, (CASE 
			WHEN dep.DEPARTMENT_CODE = '-LG_SYS' THEN 'Administrator' /* pf.userprofile LIKE '%System%' or */ 
			when pf.userprofile is null then 'Empty Profile'
			ELSE 'Non-Administrator' END) as UserProfileCategory

		,E1.EMPLOYEEID			AS MANAGEREMPLOYEEID,
		P1.PERSONID				AS MANAGERPERSONID,
		P1.FIRSTNAME + ' ' + P1.LASTNAME
								AS PRIMARYMANAGER,
		CASE
			WHEN (U.DOMAINUSERSID IS NOT NULL) AND (U.DOMAINUSERSID <> '') 
				THEN 'USER_INTERNAL_AD'
			WHEN U.ISEXTERNALUSER = 1 AND (
					SELECT	COUNT(*)
					  FROM	TCOMPANYCONTACT		CC
					 WHERE	CC.PersonID			= P.PersonID
					) > 1
				THEN 'USER_EXTERNAL_MULTICOMPANY'
			WHEN U.ISEXTERNALUSER = 1
				THEN 'USER_EXTERNAL'
			WHEN U.ISEXTERNALUSER = 0
				THEN 'USER_INTERNAL'
			ELSE	'USER_UNKNOWNCATEGORY'
		END AS USERCATEGORY
		, (CASE WHEN u.USERID IN
                             (SELECT        USERID
                               FROM            TUSER_IN_USERGROUP
                               WHERE        (USERGROUPID =
                                                             (SELECT        USERGROUPID
                                                               FROM            TUSERGROUP
                                                               WHERE        (USERGROUP = 'L-Shire')))) 
			THEN 'L-Shire' ELSE 'L-TheCompany' END)
		as LegacyDomain
		, uiug.[CustomUserGrp_List]

		, isnull((select GrpDptGroupIsGGC_Tax_Finance_FLAG 
			from V_TheCompany_VDEPARTMENT_VUSERGROUP 
			where USERGROUPID = UUG.USERGROUPID),0)
				as UserPrimaryUserGroup_Is_LegalFinanceTax_FLAG

		, isnull((case when dep.DEPARTMENT_CODE like '-LG%' then 1 
						when dep.DEPARTMENT_CODE like '-FI-CO'  then 1 
						when dep.DEPARTMENT_CODE ='-FI' THEN 1
						when dep.DEPARTMENT_CODE like '-EUF' then 1 /* Costa S. etc. */
						when dep.DEPARTMENT_CODE like '-TX' then 1 /* tax */

					else 0 END),0)
		as UserDepartment_Is_LegalFinanceTax_FLAG

  FROM	dbo.TUSER U
	  INNER JOIN	dbo.TEMPLOYEE E
			ON	E.EMPLOYEEID = U.EMPLOYEEID
	  INNER JOIN dbo.TPERSON P
		ON	P.PERSONID = E.PERSONID /*OR	P.PERSONID				= U.PERSONID*/
		
		/* other */
	 LEFT JOIN	dbo.TPATH				PA
		ON	PA.PATHID				= U.PATHID 

	  LEFT	OUTER
	  JOIN  TEMPLOYEERELATION		ER
  		ON	E.EMPLOYEEID			= ER.INFERIOREMPLOYEEID AND	ER.ISPRIMARYMANAGER	= 1
	  LEFT	OUTER
	  JOIN	TEMPLOYEE				E1
		ON	E1.EMPLOYEEID			= ER.MANAGEREMPLOYEEID
	  LEFT	OUTER
	  JOIN	TPERSON					P1
		ON	P1.PERSONID				= E1.PERSONID
		LEFT	OUTER
	  JOIN	dbo.TCOUNTRY			C
		ON	C.COUNTRYID				= P.COUNTRYID 
	  LEFT	OUTER
	  JOIN	dbo.TUSER_IN_USERGROUP	UUG
		ON	UUG.USERID				= U.USERID
	   AND	UUG.PRIMARYGROUP		= 1
	  LEFT	OUTER
	  JOIN	dbo.TUSERGROUP			UG
		ON	UG.USERGROUPID			= UUG.USERGROUPID
	  LEFT	OUTER
	  JOIN	dbo.TDEPARTMENT			DEP
		ON	E.DEPARTMENTID			= DEP.DEPARTMENTID
		LEFT	OUTER
	  JOIN	dbo.TUserProfile		PF
		ON	U.UserProfileID			= PF.UserProfileID
		LEFT OUTER JOIN V_TheCompany_VUSER_IN_USERGROUP uiug on U.USERID = uiug.userid
	 WHERE P.PERSONID > 0 /* or 10 duplicate values are included - changed 23-feb-2021 */ 

GO
/****** Object:  View [dbo].[V_TheCompany_UserID_CountractRoleCount_VUSER]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[V_TheCompany_UserID_CountractRoleCount_VUSER]

as 

SELECT 
	r.*
	, u.DEPARTMENT
	, u.PRIMARYUSERGROUP
	, u.UserProfile
	, u.UserProfileGroup
	, u.UserProfileCategory
	, u.TITLE /* currently shows domain onetakea nycomed etc. */
	, u.EMAIL
	, u.DOMAINNAME
	, u.DOMAINNETBIOSUSERNAME
	/*, (CASE WHEN l.LastLoggedInCCS > l.LastLoggedInWin then l.LastLoggedInCCS else l.LastLoggedInWin END) as Dt_Logoff_Max */
	 , (CASE WHEN l.LastLoggedInCCS IS null and l.LastLoggedInWin IS null then NULL
			WHEN l.LastLoggedInCCS is not null and lastloggedinwin is null then 'Web Viewer'
			WHEN l.Lastloggedinccs is null and lastloggedinwin is not null then 'Windows Client'
			WHEN l.Lastloggedinccs is not null and lastloggedinwin is not null then 'Web + Windows Client' 
		else NULL END) as LastAppUsed 
      ,l.[CCSAccess]
      ,l.[Active]
      /* ,l.[DisplayName] */
      /* ,l.[UserInitial] */
      /* ,[UserId] 
      ,[Department]*/
      ,l.[LastLoggedInWin]
      ,l.[LastLoggedInCCS]
	  , (case when l.[LastLoggedInWin] > l.[LastLoggedInCCS] then l.[LastLoggedInWin]
			when l.[LastLoggedInCCS] > l.[LastLoggedInWin] then l.[LastLoggedInWin]
			else null END) as LastLoggedInWinOrCCS
	  , (case when l.[LastLoggedInWin] > l.[LastLoggedInCCS] then year(l.[LastLoggedInWin])
			when l.[LastLoggedInCCS] > l.[LastLoggedInWin] then year(l.[LastLoggedInWin])
			else null END) as LastLoggedInWinOrCCS_Year
	  , year(getdate()) - (case when l.[LastLoggedInWin] > l.[LastLoggedInCCS] then year(l.[LastLoggedInWin])
			when l.[LastLoggedInCCS] > l.[LastLoggedInWin] then year(l.[LastLoggedInWin])
			else null END) as LastLoggedInWinOrCCS_YearsSinceLastLogin
      ,l.[LoginsWin]
      ,l.[LoginsCCS]
      ,l.[LoginsWinLast365]
      ,l.[LoginsWinLast180]
      ,l.[LoginsCCSLast365]
      ,l.[LoginsCCSLast180]
      ,l.[ContractsCreated]
      /*,[ProjectsCreated] */
      ,[DocsCreated]
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
	  , u.[LegacyDomain]
  FROM [Contiki_app].[dbo].[V_TheCompany_UserID_CountractRoleCount] r 
	left join V_TheCompany_VUSER u on r.userid = u.USERID /* inner join better , faster? */
	left join V_TheCompany_User_TLOGON_Last L on r.userid = l.userid
  /* where  MIK_VALID = 1 *//* User Mik Valid, Employee May Differ if 
				someone is still employed but not a Contiki user anymore */

GO
/****** Object:  View [dbo].[VDOCUMENTANCESTORCONTRACT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VDOCUMENTANCESTORCONTRACT]
AS
SELECT	DOCUMENTID,
		CONTRACTID
  FROM	(
		SELECT	D.DOCUMENTID,
				C.CONTRACTID
		  FROM	TDOCUMENT			D
		  JOIN	TOBJECTTYPE			OT
			ON	OT.OBJECTTYPEID		= D.OBJECTTYPEID
		  JOIN	TCONTRACT			C
			ON	C.CONTRACTID		= D.OBJECTID
		 WHERE	OT.FIXED			= 'CONTRACT'
		UNION	ALL
		SELECT	D.DOCUMENTID,
				C.CONTRACTID
		  FROM	TDOCUMENT			D
		  JOIN	TOBJECTTYPE			OT
			ON	OT.OBJECTTYPEID		= D.OBJECTTYPEID
		  JOIN	TTENDERER			T
			ON	T.TENDERERID		= D.OBJECTID
		  JOIN	TCONTRACT			C
		    ON	C.CONTRACTID		= T.CONTRACTID
		 WHERE	OT.FIXED			= 'TENDERER'
		UNION	ALL
		SELECT	D.DOCUMENTID,
				C.CONTRACTID
		  FROM	TDOCUMENT			D
		  JOIN	TOBJECTTYPE			OT
			ON	OT.OBJECTTYPEID		= D.OBJECTTYPEID
		  JOIN	TAMENDMENT			A
			ON	A.AMENDMENTID		= D.OBJECTID
		  JOIN	TCONTRACT			C
			ON	C.CONTRACTID		= A.CONTRACTID
		 WHERE	OT.FIXED			= 'AMENDMENT'
		UNION	ALL
		SELECT	D.DOCUMENTID,
				C.CONTRACTID
		  FROM	TDOCUMENT			D
		  JOIN	TOBJECTTYPE			OT
			ON	OT.OBJECTTYPEID		= D.OBJECTTYPEID
		  JOIN	TVO					V
			ON	V.VOID				= D.OBJECTID
		  JOIN	TCONTRACT			C
			ON	C.CONTRACTID		= V.CONTRACTID
		 WHERE	OT.FIXED			= 'VO'
		UNION	ALL
		SELECT	D.DOCUMENTID,
				C.CONTRACTID
		  FROM	TDOCUMENT			D
		  JOIN	TOBJECTTYPE			OT
			ON	OT.OBJECTTYPEID		= D.OBJECTTYPEID
		  JOIN	TCALLOFF			CF
			ON	CF.CALLOFFID		= D.OBJECTID
		  JOIN	TCONTRACT			C
			ON	C.CONTRACTID		= CF.CONTRACTID
		 WHERE	OT.FIXED			= 'CALLOFF'
		UNION	ALL
		SELECT	D.DOCUMENTID,
				C.CONTRACTID
		  FROM	TDOCUMENT			D
		  JOIN	TOBJECTTYPE			OT
			ON	OT.OBJECTTYPEID		= D.OBJECTTYPEID
		  JOIN	TSERVICE_ORDER		SO
			ON	SO.SERVICE_ORDERID	= D.OBJECTID
		  JOIN	TCONTRACT			C ON C.CONTRACTID=SO.CONTRACTID
		 WHERE	OT.FIXED			= 'SERVICE_ORDER'
		UNION	ALL
		SELECT	D.DOCUMENTID,
				C.CONTRACTID
		  FROM	TDOCUMENT			D
		  JOIN	TOBJECTTYPE			OT
			ON	OT.OBJECTTYPEID		= D.OBJECTTYPEID
		  JOIN	TOPTION				O
			ON	O.OPTIONID			= D.OBJECTID
		  JOIN	TCONTRACT			C
			ON	C.CONTRACTID		= O.CONTRACTID
		 WHERE	OT.FIXED			= 'OPTION'
		UNION	ALL
		SELECT	D.DOCUMENTID,
				C.CONTRACTID
		  FROM	TDOCUMENT			D
		  JOIN	TOBJECTTYPE			OT
			ON	OT.OBJECTTYPEID		= D.OBJECTTYPEID
		  JOIN	TVOR				V
			ON	V.VORID				= D.OBJECTID
		  JOIN	TCONTRACT			C
			ON	C.CONTRACTID		= V.CONTRACTID
		 WHERE	OT.FIXED			= 'VOR'
		UNION	ALL
		SELECT	D.DOCUMENTID, 
				C.CONTRACTID
		  FROM	TDOCUMENT			D
		  JOIN	TOBJECTTYPE			OT
			ON	OT.OBJECTTYPEID		= D.OBJECTTYPEID
		  JOIN	TVI					V
			ON	V.VIID				= D.OBJECTID
		  JOIN	TCONTRACT			C
			ON	C.CONTRACTID		= V.CONTRACTID
		 WHERE	OT.FIXED			= 'VI'
		UNION	ALL
		SELECT	D.DOCUMENTID,
				NULL				AS CONTRACT_ID
		  FROM	TDOCUMENT			D
		  JOIN	TOBJECTTYPE			OT
			ON	OT.OBJECTTYPEID		= D.OBJECTTYPEID
		 WHERE	OT.FIXED			= 'PROJECT'
		UNION	ALL
		SELECT	D.DOCUMENTID,
				NULL				AS CONTRACT_ID
		  FROM	TDOCUMENT			D
		  JOIN	TOBJECTTYPE			OT
			ON	OT.OBJECTTYPEID		= D.OBJECTTYPEID
		 WHERE	OT.FIXED			= 'COMPANY'
		UNION	ALL
		SELECT	D.DOCUMENTID,
				C.CONTRACTID
		  FROM	TDOCUMENT			D
		  JOIN	TOBJECTTYPE			OT
			ON	OT.OBJECTTYPEID		= D.OBJECTTYPEID
		  JOIN	TRFX				R
			ON	R.RFXID				= D.OBJECTID
		  JOIN	TCONTRACT			C
			ON	C.CONTRACTID		= R.CONTRACTID
		 WHERE	OT.FIXED			= 'RFX'
		UNION	ALL
		SELECT	D.DOCUMENTID,
				C.CONTRACTID
		  FROM	TDOCUMENT			D
		  JOIN	TOBJECTTYPE			OT
			ON	OT.OBJECTTYPEID		= D.OBJECTTYPEID
		  JOIN  TTENDERER			T
			ON  T.TENDERERID        = D.OBJECTID 
		  JOIN	TRFX				R
			ON	R.RFXID				= T.RFXID
		  JOIN	TCONTRACT			C
			ON	C.CONTRACTID		= R.CONTRACTID
		 WHERE	OT.FIXED			= 'TENDERER'
		   AND	T.CONTRACTID IS NULL
		UNION	ALL
		SELECT	D.DOCUMENTID,
				C.CONTRACTID
		  FROM	TDOCUMENT			D
		  JOIN	TOBJECTTYPE			OT
			ON	OT.OBJECTTYPEID		= D.OBJECTTYPEID
		  JOIN	TORDER				O
			ON	O.ORDERID			= D.OBJECTID
		  JOIN	TCONTRACT			C
			ON	C.CONTRACTID		= O.CONTRACTID
		 WHERE	OT.FIXED			= 'ORDER'
		UNION	ALL
		SELECT	D.DOCUMENTID,
				C.CONTRACTID
		  FROM	TDOCUMENT			D
		  JOIN	TOBJECTTYPE			OT
			ON	OT.OBJECTTYPEID		= D.OBJECTTYPEID
		  JOIN	TRPROCESS			RP
			ON	RP.RPROCESSID		= D.OBJECTID
		  JOIN	TCONTRACT			C
			ON	C.CONTRACTID		= RP.CONTRACTID
		 WHERE	OT.FIXED			= 'RPROCESS'
		) T

GO
/****** Object:  View [dbo].[VDOCUMENTINOBJECTS_WO_ROLES]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VDOCUMENTINOBJECTS_WO_ROLES]
AS
SELECT	OT.OBJECTTYPE,
		OT.FIXED				AS OBJECTTYPEFIXED,
		D.DESCRIPTION			AS TITLE,
		CONVERT(VARCHAR, FI.MAJORVERSION) + '.' + CONVERT(VARCHAR, FI.MINORVERSION) 
								AS [VERSION],
		FI.MajorVersion,
		FI.MinorVersion,
		A.ARCHIVE				AS [STATUS],
		ISNULL(PCC2.DISPLAYNAME, P2.DISPLAYNAME)
								AS [OWNER],
		MT.MODULETYPE			AS TEMPLATETYPE,
		ISNULL(PCC1.DISPLAYNAME, P1.DISPLAYNAME)
								AS CHECKEDOUTBY,
		FI.LASTCHANGEDDATE		AS VERSIONDATE,
		FI.ChangeComment,
		FI.LastChangedBy,
		PS.BODY					AS LastInternalComment,
		D.DOCUMENTDATE			AS DATECREATED, 
		D.CHECKEDOUTDATE,
		D.DOCUMENT				AS [FILENAME],
		FI.FileSize,
		D.ORIGFILENAME			AS ORIGINALFILENAME,
		D.USERID				AS DOCUMENTOWNERID, 
		D.CHECKEDOUTBY			AS CHECKEDOUTBYID,
		D.CHECKEDIN				AS CHECKEDOUTSTATUS,
		D.DOCUMENTTYPEID,
		D.DOCUMENTID,
		D.ARCHIVEID,
		D.SOURCEFILEINFOID, 
		A.FIXED					AS ARCHIVEFIXED,
		D.MIK_VALID				AS MIKVALID,
		FI.FileID,
		FI.FileType,
		FI.SmartTemplateBasedDocCanBeEdited,
		D.OBJECTTYPEID,
		D.OBJECTID,
		(
		SELECT	COUNT(CLAUSEID)				AS EXPR1
			FROM	DBO.TCLAUSE_IN_DOCUMENT		CID
			WHERE	DOCUMENTID= D.DOCUMENTID
			) 
											AS clausecount,
		FI.[checksum],
		D.FILEINFOID,
		D.MODULETYPEID,
		D.MIK_SEQUENCE, 
		D.PUBLISH,
		S.STATUS				AS ApprovalStatus,
		S.STATUSID				AS ApprovalStatusID,
		S.FIXED					AS ApprovalStatusFixed, 
		D.SCHEDULEDFORARCHIVING,
		D.ARCHIVEDDATE,
		D.ARCHIVEDOCUMENTKEY,
		D.INDATE,
		D.OUTDATE,
		D.SHAREDWITHSUPPLIER,
		DBO.UDF_GET_COMPANYID(C.CONTRACTID) AS CONTRACT_COMPANYID,
		C.SHAREDWITHSUPPLIER	AS CONTRACT_SHAREDWITHSUPPLIER,
		ST_CONTRACT.FIXED		AS CONTRACT_STATUS_FIXED,
		DT.SUB_OBJECTTYPEID,
		CONVERT(BIT,	CASE WHEN EXISTS
				(	SELECT TOP 1 DU.DOCUMENTID 
					FROM TDOCUMENT_SHARED_WITH_CCS_USER DU 
					WHERE D.DOCUMENTID = DU.DOCUMENTID
				)	
				THEN 1 
				ELSE 0 
		END	)					AS SHAREDONCCS
  FROM	DBO.TMODULETYPE			MT
 RIGHT	OUTER
  JOIN	DBO.TDOCUMENT			D (NOLOCK)
  LEFT	OUTER
  JOIN	DBO.TUSER				U2
	ON	D.USERID				= U2.USERID
  JOIN	DBO.TFILEINFO			FI	WITH (INDEX (DOCUMENTFILEINFOID_PK))
	ON	FI.FILEINFOID			= D.FILEINFOID
  LEFT	OUTER
  JOIN	DBO.TEMPLOYEE			E2
  JOIN	DBO.TPERSON				P2 WITH (INDEX (PERSONID_PRIMARY_KEY))
	ON	P2.PERSONID				= E2.PERSONID
	ON	U2.EMPLOYEEID			= E2.EMPLOYEEID
  JOIN	DBO.TOBJECTTYPE			OT WITH (INDEX (OBJECTTYPEID_PK))
	ON	OT.OBJECTTYPEID			= D.OBJECTTYPEID
  JOIN	DBO.TARCHIVE			A
	ON	D.ARCHIVEID				= A.ARCHIVEID
  LEFT	OUTER
  JOIN	DBO.TSTATUS				S
	ON	D.APPROVALSTATUSID		= S.STATUSID
	ON	MT.MODULETYPEID			= D.MODULETYPEID
  LEFT	OUTER
  JOIN	DBO.TPERSON				P1 WITH (INDEX (PERSONID_PRIMARY_KEY))
  JOIN	DBO.TUSER				U1 WITH (INDEX (USERID_PRIMARY_KEY))
  JOIN	DBO.TEMPLOYEE			E1
	ON	U1.EMPLOYEEID			= E1.EMPLOYEEID
	ON	P1.PERSONID				= E1.PERSONID
	ON	D.CHECKEDOUTBY			= U1.USERID
  LEFT	OUTER
  JOIN	DBO.TPERSON				PCC1 WITH (INDEX (PERSONID_PRIMARY_KEY))
  JOIN	DBO.TUSER				UCC1 WITH (INDEX (USERID_PRIMARY_KEY))
	ON	UCC1.PERSONID			= PCC1.PERSONID
	ON	D.CHECKEDOUTBY			= UCC1.USERID
  LEFT	OUTER
  JOIN	DBO.TPERSON				PCC2 WITH (INDEX (PERSONID_PRIMARY_KEY))
	ON	PCC2.PERSONID			= U2.PERSONID
  LEFT	OUTER
  JOIN	DBO.VDOCUMENTANCESTORCONTRACT (NOLOCK)
								AC
	ON	AC.DOCUMENTID=D.DOCUMENTID
  LEFT	OUTER
  JOIN	DBO.TCONTRACT			C
	ON	C.CONTRACTID			= AC.CONTRACTID
  LEFT	OUTER
  JOIN	DBO.TSTATUS ST_CONTRACT
	ON	ST_CONTRACT.STATUSID	= C.STATUSID
  LEFT	OUTER
  JOIN	DBO.TDOCUMENTTYPE DT
	ON	DT.DOCUMENTTYPEID		= D.DOCUMENTTYPEID
  LEFT  OUTER
  JOIN  TDISCUSSION DS
    ON  DS.OWNEROBJECTID			= D.DOCUMENTID
		
  LEFT  OUTER
  JOIN  TPOST PS
    ON  PS.DISCUSSIONID			= DS.DISCUSSIONID
  WHERE DS.DISCUSSIONTYPEID = (SELECT TOP 1 DISCUSSIONTYPEID FROM TDISCUSSIONTYPE WHERE FIXED='INTERNAL_COMMENT') 
		AND DS.OWNEROBJECTTYPEID = (SELECT TOP 1 OBJECTTYPEID FROM TOBJECTTYPE WHERE FIXED='DOCUMENT') 
		AND DS.MIK_VALID		= 1
		AND PS.CREATEDTIMESTAMP = (SELECT MAX(CREATEDTIMESTAMP) FROM TPOST WHERE TPOST.DISCUSSIONID = PS.DISCUSSIONID)


GO
/****** Object:  View [dbo].[V_TheCompany_TTag_Detail_TagID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[V_TheCompany_TTag_Detail_TagID]

as

	select 
		DOCUMENTID
		, t.tagid as TagID
		, t.Tag
		
		, td.Keyword /*, f.FileType */
		, td.[TagCatID]
		, td.tagid as custtagid 

		, tc.TagCatName as TagCategory /* Privacy Shield Remediation */
		, tc.TagCatSHORT as TagCatShort

		, d.Title
		, d.[filename] as FileName
		, d.Datecreated
		, ti.objectid /* CONTRACTID */
		, d.OBJECTTYPEID /* Contract = 1 */


	from TTAG_IN_OBJECT ti
		/* inner join: new tags must be added in T_TheCompany_Tag_in_Document */
		inner join TTAG t on ti.tagid  = t.tagid
		inner join [dbo].[T_TheCompany_Tag_in_Document] td on ti.tagid = td.tagid
			inner join t_TheCompany_tag_categories tc on td.TagCatID = tc.TagCatID

		inner join v_TheCompany_Vdocument d on ti.OBJECTID = d.documentid and ti.OBJECTTYPEID = 7 /* Document */
			/* and ti.objecttypeid = d.objecttypeid contract */
			

GO
/****** Object:  View [dbo].[V_TheCompany_TTag_Summary_DOCUMENTID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_TTag_Summary_DOCUMENTID]

as

	select
	
		DOCUMENTID
		/*,CAST(rtrim(replace( Replace(STUFF(
			(SELECT DISTINCT ', ' + TagCategory
			FROM  [dbo].[V_TheCompany_TTag_Detail_TagCategory] s
			WHERE s.DOCUMENTID =d.DOCUMENTID
			FOR XML PATH('')),1,1,''),'&#x0D' /* carriage return */,''),';','')) as varchar(100))
		AS TagCategory_List */
		, STUFF(
			(SELECT DISTINCT ', ' + TagCategory
			FROM  [dbo].[T_TheCompany_TTag_Summary_TagCategory] s
			WHERE s.DOCUMENTID =d.DOCUMENTID
			FOR XML PATH('')),1,1,'')
		AS TagCategory_List
	/*	,CAST(rtrim( Replace(STUFF(
			(SELECT DISTINCT ', ' + s.Tag
			FROM V_TheCompany_TTag_Detail_TagID s
			WHERE s.DOCUMENTID =d.DOCUMENTID
			group by  s.DOCUMENTID, s.Tag	
			FOR XML PATH('')),1,1,''),'&#x0D' /* carriage return */,'')) as varchar(100))
		*/, 'N/A' AS TagDetail_List

		/*, max(d.Title) */, 'N/A' as Title


		, count(distinct TagCatID) as TagCatIDCount
		/*, count(distinct TagID) as TagIDCount */
	from [dbo].[V_TheCompany_TTag_Detail_TagID] d
	Group by DOCUMENTID 


GO
/****** Object:  View [dbo].[VDOCUMENTOWNEROBJECT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VDOCUMENTOWNEROBJECT] 
AS
SELECT
  ISNULL(T.ContractNumber, N'')+ISNULL(N' - '+T.[CONTRACT], N'') ObjectOwnerName,
  OT.OBJECTTYPE,
  OT.FIXED ObjectTypeFixed,
  D.Title,
  D.Version,
  D.MajorVersion,
  D.MinorVersion,
  D.Status,
  D.Owner,
  D.TemplateType,
  D.CheckedOutBy,
  D.VersionDate,
  D.Datecreated,
  D.CHECKEDOUTDATE,
  D.FileName,
  D.FileSize,
  D.OriginalFileName,
  D.DocumentOwnerId,
  D.CheckedOutById,
  D.CheckedOutStatus,
  D.DOCUMENTTYPEID,
  D.DOCUMENTID,
  D.ARCHIVEID,
  D.ArchiveFixed,
  D.MIK_VALID,
  D.FileID,
  D.OBJECTTYPEID,
  D.OBJECTID,
  D.DOCUMENTTYPE,
  D.FileType,
  D.SOURCEFILEINFOID,
  D.ApprovalStatus,
  D.ApprovalStatusID,
  D.ApprovalStatusFixed
FROM VDOCUMENT D
JOIN TOBJECTTYPE OT
  ON OT.OBJECTTYPEID = D.OBJECTTYPEID
JOIN TCONTRACT T
  ON T.CONTRACTID = D.OBJECTID
WHERE OT.FIXED = N'CONTRACT'
UNION
SELECT
  C.CONTRACTNUMBER + N' - ' + CY.COMPANY OwnerObjectName,
  OT.OBJECTTYPE,
  OT.FIXED ObjectTypeFixed,
  D.Title,
  D.Version,
  D.MajorVersion,
  D.MinorVersion,
  D.Status,
  D.Owner,
  D.TemplateType,
  D.CheckedOutBy,
  D.VersionDate,
  D.Datecreated,
  D.CHECKEDOUTDATE,
  D.FileName,
  D.FileSize,
  D.OriginalFileName,
  D.DocumentOwnerId,
  D.CheckedOutById,
  D.CheckedOutStatus,
  D.DOCUMENTTYPEID,
  D.DOCUMENTID,
  D.ARCHIVEID,
  D.ArchiveFixed,
  D.MIK_VALID,
  D.FileID,
  D.OBJECTTYPEID,
  D.OBJECTID,
  D.DOCUMENTTYPE,
  D.FileType,
  D.SOURCEFILEINFOID,
  D.ApprovalStatus,
  D.ApprovalStatusID,
  D.ApprovalStatusFixed
FROM VDOCUMENT D
JOIN TOBJECTTYPE OT
  ON OT.OBJECTTYPEID = D.OBJECTTYPEID
JOIN TTENDERER T
  ON T.TENDERERID = D.OBJECTID
JOIN TCONTRACT C
  ON C.CONTRACTID = T.CONTRACTID
JOIN TCOMPANY CY
  ON CY.COMPANYID = T.COMPANYID
WHERE OT.FIXED = N'TENDERER'
UNION
SELECT
  CONVERT(NVARCHAR, T.AmendmentNumber) + ISNULL(N' - ' + T.AMENDMENT, N'') OwnerObjectName,
  OT.OBJECTTYPE,
  OT.FIXED ObjectTypeFixed,
  D.Title,
  D.Version,
  D.MajorVersion,
  D.MinorVersion,
  D.Status,
  D.Owner,
  D.TemplateType,
  D.CheckedOutBy,
  D.VersionDate,
  D.Datecreated,
  D.CHECKEDOUTDATE,
  D.FileName,
  D.FileSize,
  D.OriginalFileName,
  D.DocumentOwnerId,
  D.CheckedOutById,
  D.CheckedOutStatus,
  D.DOCUMENTTYPEID,
  D.DOCUMENTID,
  D.ARCHIVEID,
  D.ArchiveFixed,
  D.MIK_VALID,
  D.FileID,
  D.OBJECTTYPEID,
  D.OBJECTID,
  D.DOCUMENTTYPE,
  D.FileType,
  D.SOURCEFILEINFOID,
  D.ApprovalStatus,
  D.ApprovalStatusID,
  D.ApprovalStatusFixed
FROM VDOCUMENT D
JOIN TOBJECTTYPE OT
  ON OT.OBJECTTYPEID = D.OBJECTTYPEID
JOIN TAMENDMENT T
  ON T.AMENDMENTID = D.OBJECTID
WHERE OT.FIXED = N'AMENDMENT'
UNION
SELECT
  CONVERT(NVARCHAR, T.VONumber) + ISNULL(N' - ' + T.VO, N'') OwnerObjectName,
  OT.OBJECTTYPE,
  OT.FIXED ObjectTypeFixed,
  D.Title,
  D.Version,
  D.MajorVersion,
  D.MinorVersion,
  D.Status,
  D.Owner,
  D.TemplateType,
  D.CheckedOutBy,
  D.VersionDate,
  D.Datecreated,
  D.CHECKEDOUTDATE,
  D.FileName,
  D.FileSize,
  D.OriginalFileName,
  D.DocumentOwnerId,
  D.CheckedOutById,
  D.CheckedOutStatus,
  D.DOCUMENTTYPEID,
  D.DOCUMENTID,
  D.ARCHIVEID,
  D.ArchiveFixed,
  D.MIK_VALID,
  D.FileID,
  D.OBJECTTYPEID,
  D.OBJECTID,
  D.DOCUMENTTYPE,
  D.FileType,
  D.SOURCEFILEINFOID,
  D.ApprovalStatus,
  D.ApprovalStatusID,
  D.ApprovalStatusFixed
FROM VDOCUMENT D
JOIN TOBJECTTYPE OT
  ON OT.OBJECTTYPEID = D.OBJECTTYPEID
JOIN TVO T
  ON T.VOID = D.OBJECTID
WHERE OT.FIXED = N'VO'
UNION
SELECT
  ISNULL(CONVERT(NVARCHAR, T.MIK_SEQUENCE) + N' - ', N'') + ISNULL(T.[DESCRIPTION], N'') OwnerObjectName,
  OT.OBJECTTYPE,
  OT.FIXED ObjectTypeFixed,
  D.Title,
  D.Version,
  D.MajorVersion,
  D.MinorVersion,
  D.Status,
  D.Owner,
  D.TemplateType,
  D.CheckedOutBy,
  D.VersionDate,
  D.Datecreated,
  D.CHECKEDOUTDATE,
  D.FileName,
  D.FileSize,
  D.OriginalFileName,
  D.DocumentOwnerId,
  D.CheckedOutById,
  D.CheckedOutStatus,
  D.DOCUMENTTYPEID,
  D.DOCUMENTID,
  D.ARCHIVEID,
  D.ArchiveFixed,
  D.MIK_VALID,
  D.FileID,
  D.OBJECTTYPEID,
  D.OBJECTID,
  D.DOCUMENTTYPE,
  D.FileType,
  D.SOURCEFILEINFOID,
  D.ApprovalStatus,
  D.ApprovalStatusID,
  D.ApprovalStatusFixed
FROM VDOCUMENT D
JOIN TOBJECTTYPE OT
  ON OT.OBJECTTYPEID = D.OBJECTTYPEID
JOIN TCALLOFF T
  ON T.CALLOFFID = D.OBJECTID
WHERE OT.FIXED = N'CALLOFF'
UNION
SELECT
  ISNULL(CONVERT(NVARCHAR, T.SERVICE_ORDER_NUMBER) + N' - ', N'') + ISNULL(CONVERT(NVARCHAR, T.REVISION), N'') OwnerObjectName,
  OT.OBJECTTYPE,
  OT.FIXED ObjectTypeFixed,
  D.Title,
  D.Version,
  D.MajorVersion,
  D.MinorVersion,
  D.Status,
  D.Owner,
  D.TemplateType,
  D.CheckedOutBy,
  D.VersionDate,
  D.Datecreated,
  D.CHECKEDOUTDATE,
  D.FileName,
  D.FileSize,
  D.OriginalFileName,
  D.DocumentOwnerId,
  D.CheckedOutById,
  D.CheckedOutStatus,
  D.DOCUMENTTYPEID,
  D.DOCUMENTID,
  D.ARCHIVEID,
  D.ArchiveFixed,
  D.MIK_VALID,
  D.FileID,
  D.OBJECTTYPEID,
  D.OBJECTID,
  D.DOCUMENTTYPE,
  D.FileType,
  D.SOURCEFILEINFOID,
  D.ApprovalStatus,
  D.ApprovalStatusID,
  D.ApprovalStatusFixed
FROM VDOCUMENT D
JOIN TOBJECTTYPE OT
  ON OT.OBJECTTYPEID = D.OBJECTTYPEID
JOIN TSERVICE_ORDER T
  ON T.SERVICE_ORDERID = D.OBJECTID
WHERE OT.FIXED = N'SERVICE_ORDER'
UNION
SELECT
  ISNULL(T.OPTIONNAME, N'') OwnerObjectName,
  OT.OBJECTTYPE,
  OT.FIXED ObjectTypeFixed,
  D.Title,
  D.Version,
  D.MajorVersion,
  D.MinorVersion,
  D.Status,
  D.Owner,
  D.TemplateType,
  D.CheckedOutBy,
  D.VersionDate,
  D.Datecreated,
  D.CHECKEDOUTDATE,
  D.FileName,
  D.FileSize,
  D.OriginalFileName,
  D.DocumentOwnerId,
  D.CheckedOutById,
  D.CheckedOutStatus,
  D.DOCUMENTTYPEID,
  D.DOCUMENTID,
  D.ARCHIVEID,
  D.ArchiveFixed,
  D.MIK_VALID,
  D.FileID,
  D.OBJECTTYPEID,
  D.OBJECTID,
  D.DOCUMENTTYPE,
  D.FileType,
  D.SOURCEFILEINFOID,
  D.ApprovalStatus,
  D.ApprovalStatusID,
  D.ApprovalStatusFixed
FROM VDOCUMENT D
JOIN TOBJECTTYPE OT
  ON OT.OBJECTTYPEID = D.OBJECTTYPEID
JOIN TOPTION T
  ON T.OPTIONID = D.OBJECTID
WHERE OT.FIXED = N'OPTION'
UNION
SELECT
  CONVERT(NVARCHAR, T.VORNUMBER) + ISNULL(N' - ' + T.VOR, N'') OwnerObjectName,
  OT.OBJECTTYPE,
  OT.FIXED ObjectTypeFixed,
  D.Title,
  D.Version,
  D.MajorVersion,
  D.MinorVersion,
  D.Status,
  D.Owner,
  D.TemplateType,
  D.CheckedOutBy,
  D.VersionDate,
  D.Datecreated,
  D.CHECKEDOUTDATE,
  D.FileName,
  D.FileSize,
  D.OriginalFileName,
  D.DocumentOwnerId,
  D.CheckedOutById,
  D.CheckedOutStatus,
  D.DOCUMENTTYPEID,
  D.DOCUMENTID,
  D.ARCHIVEID,
  D.ArchiveFixed,
  D.MIK_VALID,
  D.FileID,
  D.OBJECTTYPEID,
  D.OBJECTID,
  D.DOCUMENTTYPE,
  D.FileType,
  D.SOURCEFILEINFOID,
  D.ApprovalStatus,
  D.ApprovalStatusID,
  D.ApprovalStatusFixed
FROM VDOCUMENT D
JOIN TOBJECTTYPE OT
  ON OT.OBJECTTYPEID = D.OBJECTTYPEID
JOIN TVOR T
  ON T.VORID = D.OBJECTID
WHERE OT.FIXED = N'VOR'
UNION
SELECT
  CONVERT(NVARCHAR, T.VINUMBER) + ISNULL(N' - ' + T.VI, N'') OwnerObjectName,
  OT.OBJECTTYPE,
  OT.FIXED ObjectTypeFixed,
  D.Title,
  D.Version,
  D.MajorVersion,
  D.MinorVersion,
  D.Status,
  D.Owner,
  D.TemplateType,
  D.CheckedOutBy,
  D.VersionDate,
  D.Datecreated,
  D.CHECKEDOUTDATE,
  D.FileName,
  D.FileSize,
  D.OriginalFileName,
  D.DocumentOwnerId,
  D.CheckedOutById,
  D.CheckedOutStatus,
  D.DOCUMENTTYPEID,
  D.DOCUMENTID,
  D.ARCHIVEID,
  D.ArchiveFixed,
  D.MIK_VALID,
  D.FileID,
  D.OBJECTTYPEID,
  D.OBJECTID,
  D.DOCUMENTTYPE,
  D.FileType,
  D.SOURCEFILEINFOID,
  D.ApprovalStatus,
  D.ApprovalStatusID,
  D.ApprovalStatusFixed
FROM VDOCUMENT D
JOIN TOBJECTTYPE OT
  ON OT.OBJECTTYPEID = D.OBJECTTYPEID
JOIN TVI T
  ON T.VIID = D.OBJECTID
WHERE OT.FIXED = N'VI'
UNION
SELECT
  ISNULL(T.PROJECT_NUMBER + N' - ', N'') + ISNULL(T.PROJECT, N'') OwnerObjectName,
  OT.OBJECTTYPE,
  OT.FIXED ObjectTypeFixed,
  D.Title,
  D.Version,
  D.MajorVersion,
  D.MinorVersion,
  D.Status,
  D.Owner,
  D.TemplateType,
  D.CheckedOutBy,
  D.VersionDate,
  D.Datecreated,
  D.CHECKEDOUTDATE,
  D.FileName,
  D.FileSize,
  D.OriginalFileName,
  D.DocumentOwnerId,
  D.CheckedOutById,
  D.CheckedOutStatus,
  D.DOCUMENTTYPEID,
  D.DOCUMENTID,
  D.ARCHIVEID,
  D.ArchiveFixed,
  D.MIK_VALID,
  D.FileID,
  D.OBJECTTYPEID,
  D.OBJECTID,
  D.DOCUMENTTYPE,
  D.FileType,
  D.SOURCEFILEINFOID,
  D.ApprovalStatus,
  D.ApprovalStatusID,
  D.ApprovalStatusFixed
FROM VDOCUMENT D
JOIN TOBJECTTYPE OT
  ON OT.OBJECTTYPEID = D.OBJECTTYPEID
JOIN TPROJECT T
  ON T.PROJECTID = D.OBJECTID
WHERE OT.FIXED = N'PROJECT'
UNION
SELECT
  ISNULL(T.INTERNALNUMBER + N' - ', N'') + ISNULL(T.RFX, N'') OwnerObjectName,
  OT.OBJECTTYPE,
  OT.FIXED ObjectTypeFixed,
  D.Title,
  D.Version,
  D.MajorVersion,
  D.MinorVersion,
  D.Status,
  D.Owner,
  D.TemplateType,
  D.CheckedOutBy,
  D.VersionDate,
  D.Datecreated,
  D.CHECKEDOUTDATE,
  D.FileName,
  D.FileSize,
  D.OriginalFileName,
  D.DocumentOwnerId,
  D.CheckedOutById,
  D.CheckedOutStatus,
  D.DOCUMENTTYPEID,
  D.DOCUMENTID,
  D.ARCHIVEID,
  D.ArchiveFixed,
  D.MIK_VALID,
  D.FileID,
  D.OBJECTTYPEID,
  D.OBJECTID,
  D.DOCUMENTTYPE,
  D.FileType,
  D.SOURCEFILEINFOID,
  D.ApprovalStatus,
  D.ApprovalStatusID,
  D.ApprovalStatusFixed
FROM VDOCUMENT D
JOIN TOBJECTTYPE OT
  ON OT.OBJECTTYPEID = D.OBJECTTYPEID
JOIN TRFX T
  ON T.RFXID = D.OBJECTID
WHERE OT.FIXED = N'RFX'
UNION
SELECT
  ISNULL(CY.CompanyNo + N' - ', N'') + ISNULL(CY.COMPANY, N'') OwnerObjectName,
  OT.OBJECTTYPE,
  OT.FIXED ObjectTypeFixed,
  D.Title,
  D.Version,
  D.MajorVersion,
  D.MinorVersion,
  D.Status,
  D.Owner,
  D.TemplateType,
  D.CheckedOutBy,
  D.VersionDate,
  D.Datecreated,
  D.CHECKEDOUTDATE,
  D.FileName,
  D.FileSize,
  D.OriginalFileName,
  D.DocumentOwnerId,
  D.CheckedOutById,
  D.CheckedOutStatus,
  D.DOCUMENTTYPEID,
  D.DOCUMENTID,
  D.ARCHIVEID,
  D.ArchiveFixed,
  D.MIK_VALID,
  D.FileID,
  D.OBJECTTYPEID,
  D.OBJECTID,
  D.DOCUMENTTYPE,
  D.FileType,
  D.SOURCEFILEINFOID,
  D.ApprovalStatus,
  D.ApprovalStatusID,
  D.ApprovalStatusFixed
FROM VDOCUMENT D
JOIN TOBJECTTYPE OT
  ON OT.OBJECTTYPEID = D.OBJECTTYPEID
JOIN TCOMPANY CY
  ON CY.COMPANYID = D.OBJECTID
WHERE OT.FIXED = N'COMPANY'


GO
/****** Object:  View [dbo].[V_TheCompany_KWS_4_ARB_TCOMPANY_Summary]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_KWS_4_ARB_TCOMPANY_Summary]
as

select top 1000
	[KeyWordVarchar255]
	, [KeyWordLettersNumbersOnly_UPPER]
	,Replace(STUFF(
		(SELECT  DISTINCT ',' + rs.Company_LettersNumbersOnly_UPPER
		FROM V_TheCompany_KWS_2_ARB_TCompany_ContractID rs
		where  rs.KeyWordVarchar255 = r.KeyWordVarchar255
		group by rs.Company_LettersNumbersOnly_UPPER
		FOR XML PATH('')),1,1,''),'&amp;','&') AS Supplier_Short_List
	, max(CompanyMatch_Exact) as CompanyExactMatch
	, count([ContractID]) as ContractCount
	,Replace(STUFF(
		(SELECT DISTINCT ',' + rs.company
		FROM V_TheCompany_KWS_2_ARB_TCompany_ContractID rs
		where  rs.KeyWordVarchar255 = r.KeyWordVarchar255
		group by rs.Company
		FOR XML PATH('')),1,1,''),'&amp;','&') AS Company_List 
	 , count(DISTINCT Companyid) as CompanyCount 
	, max(companyid) as CompanyID_Max
	, Max(Company) as Company_MAX
from 
	[dbo].[V_TheCompany_KWS_2_ARB_TCompany_ContractID] r
group by 
	KeyWordVarchar255, [KeyWordLettersNumbersOnly_UPPER]
order by 
	KeyWordVarchar255

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_5_ARB_TCOMPANY_summary_gap]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_KWS_5_ARB_TCOMPANY_summary_gap]

as

	select top 1000 
		s.KeyWordVarchar255
		, s.KeyWordCustom2 as Spend
		, r.[CompanyExactMatch]
		, r.[KeyWordLettersNumbersOnly_UPPER]
		, r.Company_List
		, r.CompanyCount
		, r.ContractCount
	from T_TheCompany_KeyWordSearch s 
		left outer join [dbo].[V_TheCompany_KWS_4_ARB_TCOMPANY_Summary]  r 
		on s.KeyWordVarchar255 = r.KeyWordVarchar255
	where [KeyWordType] = 'Company'  
	order by s.KeyWordVarchar255

GO
/****** Object:  View [dbo].[VCONTRACTPERSONS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACTPERSONS]
AS
SELECT	C.CONTRACTID,
		R.ROLEID,
		P.PERSONID,
		E.EMPLOYEEID,
		U.UserID					AS UserID,
		P.DISPLAYNAME,
		R.FIXED						AS ROLEFIXED
  FROM	TCONTRACT					C
  JOIN	TPERSONROLE_IN_OBJECT		RIO
	ON	RIO.OBJECTID				= C.CONTRACTID
  JOIN	TOBJECTTYPE					OT
	ON	OT.OBJECTTYPEID				= RIO.OBJECTTYPEID
  JOIN	TROLE						R
	ON	R.ROLEID					= RIO.ROLEID
  JOIN	TPERSON						P
	ON	P.PERSONID					= RIO.PERSONID
  LEFT	OUTER	
  JOIN	TEMPLOYEE					E
	ON	E.PERSONID					= P.PERSONID
  LEFT	OUTER
  JOIN	TUSER						U
	ON	U.EmployeeID				= E.EmployeeID  
 WHERE	OT.FIXED					= 'CONTRACT'

GO
/****** Object:  View [dbo].[VDOCUMENTPERSONS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VDOCUMENTPERSONS]
AS
SELECT	DAC.DOCUMENTID,
		DAC.CONTRACTID,
		CP.ROLEID,
		CP.PERSONID,
		CP.EMPLOYEEID
  FROM	VDOCUMENTANCESTORCONTRACT		DAC
  LEFT 
  JOIN	VCONTRACTPERSONS				CP
	ON	CP.CONTRACTID					= DAC.CONTRACTID

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_CNT_TPRODUCT_ContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view

[dbo].[V_TheCompany_KWS_2_CNT_TPRODUCT_ContractID]
/* to do: include spaces with Productgroup name */
as 

	SELECT DISTINCT 
		s.*

		, t.CONTRACTID

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
		left join TPROD_GROUP_IN_CONTRACT t on c.PRODUCTGROUPID = t.PRODUCTGROUPID
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
/****** Object:  View [dbo].[V_TheCompany_KWS_3_CNT_TPRODUCT_ContractID_Extended]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_KWS_3_CNT_TPRODUCT_ContractID_Extended]
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

	FROM [dbo].[V_TheCompany_KWS_2_CNT_TPRODUCT_ContractID] u /* big definition query */
	WHERE u.contractid > 0 /* no NULLS */
	AND ( [KeyWord_ExclusionFlag] = 0 OR [PrdGrpMatch_EXACT_Flag] = 1) /* - only if exact match */
	/* ACTIVE CONTRACTS */
	/* and p.mik_valid = 1 */
	/*	and contractid = 13286 */
	
GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_0_MigFlags]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_T_TheCompany_ALL_0_MigFlags]

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
			END) + (case when [ConfidentialityFlagNAME] = 'TOP SECRET' THEN ' - TOP SECRET?' else '' end)
		AS  MigrateToSystem_Detail

	, (CASE when (COUNTERPARTYNUMBER like '!ARIBA_W%' OR COUNTERPARTYNUMBER like 'Xt_%') then 0
			when contractid not in (select contractid from [V_TheCompany_VDOCUMENT]) then 0 /* no valid files - only Contikimail etc. */
			WHEN a.statusid = 5 /* active */ then 1 /* all active agreements */	/* order switched 5-5-2021 */
			when a.[AgrType_IsHCX_Flag] = 1 then 0 /* 2 = undetermined */
			When a.[ConfidentialityFLAG_0123] > 0 /*ConfidentialityFlagNAME <>'N/A'*/ then 1 /* if top secret or confidential */
			when a.Agr_IsMaterial_flag = 1 then 1 /* material agreements */
			WHEN a.[InactiveWithExpiryDateWithinLast2Yrs] = 1  THEN 1
			else 0 end)
		as MigrateYN_Flag

	, (CASE when (COUNTERPARTYNUMBER like '!ARIBA_W%' OR COUNTERPARTYNUMBER like 'Xt_%') then '9 - RIM (AribaXt)'
			when contractid not in (select contractid from [V_TheCompany_VDOCUMENT]) then '0 - No valid files (only ContikiMail)'
			when a.statusid = 5 /* active */ then '1 - Active contract' /* all active agreements */
			when a.[AgrType_IsHCX_Flag] = 1 then '9 - RIM (HCX)'
			When a.[ConfidentialityFLAG_0123] > 0 /*ConfidentialityFlagNAME <>'N/A'*/ THEN '2 - TS/SC/Confidential' /* if top secret or confidential */
			when a.Agr_IsMaterial_flag = 1 then '3 - Material agreement' /* material agreements */
			WHEN a.[InactiveWithExpiryDateWithinLast2Yrs] = 1  THEN '4 - expired within 2 years' /* DATEDIFF(mm,a.contractdate,GetDate()) <=24 */
			else '9 - RIM' end)
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
/****** Object:  View [dbo].[V_TheCompany_Mig_0ProcNetFlag]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_Mig_0ProcNetFlag]

as

select  /* USE V_T_TheCompany_ALL_0_MigFlags */
	*

FROM V_T_TheCompany_ALL_0_MigFlags

	/* must not filter with WHERE, used in V_TheCompany_ALL */
/* WHERE
	CONTRACTTYPEID not in (11 /* Legal matter / Case */
						, 13 /* Test old */
						, 106 /* Test new*/) 
	AND NUMBER not like 'Xt%' /* divested products or sites */ */


GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_NoTS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View [dbo].[V_T_TheCompany_ALL_NoTS]

as

select

	[Number]
      ,[CONTRACTID]
      ,[Title]
      /* ,[Title_InclTopSecret] */
      ,[CONTRACTTYPE]
      ,[CONTRACTTYPEID]
      ,[Agreement_Type_Top25WithOther]
      ,[Agreement_Type_Top25Flag]
      ,[REFERENCENUMBER]
      ,[CONTRACTDATE]
      ,[RegisteredDate_YYYY_MM]
      ,[RegisteredDateNumMthCat]
      ,[AWARDDATE]
      ,[STARTDATE]
      ,[EXPIRYDATE]
      ,[REV_EXPIRYDATE]
      ,[FINAL_EXPIRYDATE]
      ,[REVIEWDATE]
      ,[RD_ReviewDate_Warning]
      ,[CHECKEDOUTDATE]
      ,[DEFINEDENDDATE]
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
      ,[AGREEMENT_TYPE]
      ,[AGREEMENT_TYPEID]
      ,[AGREEMENT_FIXED]
      ,[STRATEGYTYPE]
      ,[CompanyList]
      ,[CompanyIDList]
      ,[CompanyIDAwardedCount]
      ,[CompanyIDUnawardedCount]
      ,[CompanyIDCount]
      ,[ConfidentialityFlag]
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
      ,[DateTableRefreshed]
      ,[LinkToContractURL]
      ,[Procurement_AgTypeFlag]
      ,[Procurement_RoleFlag]
      ,[Tags]
      ,[AgreementTypeDivestment]

	  from T_TheCompany_ALL
GO
/****** Object:  View [dbo].[V_TheCompany_Mig_1T_TheCompany_All_ProcNetFlag]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view

[dbo].[V_TheCompany_Mig_1T_TheCompany_All_ProcNetFlag]
as

	select * 
	from V_T_TheCompany_ALL_NoTS /* no top secreta, dbo.T_TheCompany_ALL */ a 
	inner join dbo.V_TheCompany_Mig_0ProcNetFlag p 
		on a.Contractid = p.Contractid_Proc
				/* WHERE
			CONTRACTTYPEID not in (11 /* Legal matter / Case */
								, 13 /* Test old */
								, 106 /* Test new*/) 
			AND NUMBER not like 'Xt%' /* divested products or sites */ */
	where Proc_NetFlag = 1


GO
/****** Object:  View [dbo].[V_TheCompany_TTag_Detail_DOCUMENTID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_TTag_Detail_DOCUMENTID]

as

	select top 10000
	
		DOCUMENTID
		,CAST(rtrim(replace( Replace(STUFF(
			(SELECT DISTINCT ', ' +s.TagCategory
			FROM V_TheCompany_TTag_Detail_TagID s
			WHERE s.DOCUMENTID =d.DOCUMENTID
	
			FOR XML PATH('')),1,1,''),'&#x0D' /* carriage return */,''),';','')) as varchar(100))
		AS TagCategory_List
		,CAST(rtrim( Replace(STUFF(
			(SELECT DISTINCT ', ' + s.Tag
			FROM V_TheCompany_TTag_Detail_TagID s
			WHERE s.DOCUMENTID =d.DOCUMENTID
			group by  s.DOCUMENTID, s.Tag	
			FOR XML PATH('')),1,1,''),'&#x0D' /* carriage return */,'')) as varchar(100))
		AS TagDetail_List
		/*, td.TagCategory /* Privacy Shield Remediation */
		, td.TagCatShort
		, t.Tag
		, td.Keyword /*, f.FileType */*/
		, d.Title
		/* , d.[filename] as FileName */
		/*, d.Datecreated */
		/*, d.objectid  CONTRACTID */
		/*, d.OBJECTTYPEID  Contract = 1 */
		/*, td.tagid as custtagid */
		, count(distinct TagCategory) as TagCategoryCount
		, count(distinct TagID) as TagIDCount
	from [dbo].[V_TheCompany_TTag_Detail_TagID] d
	Group by DOCUMENTID, Title
	/* order by d.Datecreated desc */
	/* left join vdocument f on t.OBJECTID = f.DOCUMENTID */


GO
/****** Object:  View [dbo].[V_TheCompany_KWS_3_CNT_TCOMPANY_ContractID_Extended]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view 

[dbo].[V_TheCompany_KWS_3_CNT_TCOMPANY_ContractID_Extended]

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
	  , [CompanyID]
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
				and [CompanyMatch_LIKE2Way_FLAG] < [CompanyMatch_FirstWord2Way_FLAG]
				THEN [CompanyMatch_FirstWord2Way] 
				 ELSE '' END)
				AS [CompanyMatch_FirstWord2Way]

		, (CASE WHEN 
				[CompanyMatch_Like_FLAG] = 0
				AND [CompanyMatch_FirstWord_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
				and [CompanyMatch_LIKE2Way_FLAG] < [CompanyMatch_FirstWord2Way_FLAG]
				THEN [CompanyMatch_FirstWord2Way_FLAG]
				 ELSE 0 END)
				AS [CompanyMatch_FirstWord2Way_FLAG]

		/* First Word 2-Way Reverse */
		, (CASE WHEN 
						[CompanyMatch_Like_FLAG] = 0
				AND [CompanyMatch_FirstWord_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
				and [CompanyMatch_LIKE2Way_FLAG] < [CompanyMatch_FirstWord2Way_FLAG]
				AND [CompanyMatch_FirstWord2Way_FLAG] = 0
				THEN [CompanyMatch_FirstWord2Way_REV]
				 ELSE '' END)
				AS [CompanyMatch_FirstWord2Way_REV]
			
		, (CASE WHEN 
						[CompanyMatch_Like_FLAG] = 0
				AND [CompanyMatch_FirstWord_FLAG] = 0
				AND [CompanyMatch_FirstTwoWords_FLAG] = 0 
				and [CompanyMatch_LIKE2Way_FLAG] < [CompanyMatch_FirstWord2Way_FLAG]
				AND [CompanyMatch_FirstWord2Way_FLAG] = 0
				THEN [CompanyMatch_FirstWord2Way_REV_FLAG]
				 ELSE 0 END)
				AS [CompanyMatch_FirstWord2Way_REV_FLAG]
	
	/* Other */
	  , [CompanyMatch_EntireKeywordLike_FLAG]	 
	  ,  [CompanyMatch_Abbreviation_Flag]		
		, CompanyMatch_ContainsKeyword
		, CompanyMatch_BeginsWithKeyword

  FROM T_TheCompany_KWS_2_CNT_TCompany_ContractID
	/* from [dbo].[V_TheCompany_KWS_3_TCompany_ContractID] */ 

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_4_CNT_TzCOMPANY_summary_KeyWord]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view 
[dbo].[V_TheCompany_KWS_4_CNT_TzCOMPANY_summary_KeyWord]

as 

	SELECT  KeyWordVarchar255
		,Replace(STUFF(
			(SELECT DISTINCT ',' + rs.company
			FROM T_TheCompany_KWS_2_CNT_TCompany_ContractID rs
			where  rs.KeyWordVarchar255 = r.[KeyWordVarchar255]
			and rs.CompanyExact_Flag = 1
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Company_List_Exact			

		,Replace(STUFF(
			(SELECT DISTINCT ',' + rs.[KeyWordCustom1]
			FROM T_TheCompany_KWS_2_CNT_TCompany_ContractID rs
			where  rs.KeyWordVarchar255 = r.[KeyWordVarchar255] and rs.CompanyExact_Flag = 1
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Custom1_List
		,Replace(STUFF(
			(SELECT DISTINCT ',' + rs.[KeyWordCustom2]
			FROM T_TheCompany_KWS_2_CNT_TCompany_ContractID rs
			where  rs.KeyWordVarchar255 = r.[KeyWordVarchar255] and rs.CompanyExact_Flag = 1
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Custom2_List

		,Replace(STUFF(
			(SELECT DISTINCT ',' + rs.company
			FROM T_TheCompany_KWS_2_CNT_TCompany_ContractID rs
			where  rs.KeyWordVarchar255 = r.[KeyWordVarchar255] and rs.CompanyExact_Flag = 0
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Company_List_NotExact

		/*,Replace(STUFF(
			(SELECT DISTINCT ',' + rs.PRODUCTGROUP
			FROM V_TheCompany_KeyWordSearch_Results_TPRODUCT_ContractID rs
			where  rs.KeyWordVarchar255 = r.[KeyWordVarchar255]
			FOR XML PATH('')),1,1,''),'&amp;','&') AS ProductList*/

		, count(DISTINCT CASE WHEN r.CompanyExact_Flag = 1 
			THEN companyid ELSE NULL END) as CompanyCount_Exact
		, count(DISTINCT CASE WHEN r.CompanyExact_Flag = 1 
			THEN [ContractID_Company] ELSE NULL END) as ContractCount_Exact	
		, count(DISTINCT companyid) as CompanyCount
		, COUNT([ContractID_Company]) as ContractCount
		, MIN([CompanyMatch_Level]) AS CompanyMatchLevel_Min
	FROM 
		[V_TheCompany_KWS_3_CNT_TCompany_ContractID_Extended] r
	group by 
		r.[KeyWordVarchar255]

GO
/****** Object:  View [dbo].[VDOCUMENTROLESCUMULATIVE]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VDOCUMENTROLESCUMULATIVE]
AS
SELECT D.DOCUMENTID, 
	(SELECT R.FIXED + ';' + CAST(P.PERSONID AS VARCHAR(16)) + ';' + CAST(DP.EMPLOYEEID AS VARCHAR(16)) + ';' + P.DISPLAYNAME + '#'
		FROM VDOCUMENTPERSONS DP
		JOIN TDOCUMENT D1 ON D1.DOCUMENTID=DP.DOCUMENTID
		LEFT JOIN TROLE R ON R.ROLEID=DP.ROLEID
		LEFT JOIN TPERSON P ON P.PERSONID=DP.PERSONID
		WHERE D1.DOCUMENTID=D.DOCUMENTID
		FOR XML PATH, TYPE).value('.[1]', 'nvarchar(max)') AS PERSONS
FROM TDOCUMENT D

GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_NoTS_CountryAreaRegion]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[V_T_TheCompany_ALL_NoTS_CountryAreaRegion]
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
	  , ReviewDate_Reminder_RecipientList
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
      ,[DateTableRefreshed] as 'Date Table Refreshed' /* to show in two lines */

  FROM 
	  [Contiki_app].[dbo].[V_T_TheCompany_ALL_STD_NoTS] c 
	  left join [dbo].[V_TheCompany_Mig_0ProcNetFlag] p 
	  /* inner join won't drop records since this table contains all records except for test etc. xt records cases */
	  on c.contractid = p.contractid_proc



GO
/****** Object:  View [dbo].[V_TheCompany_KWS_4_CNT_TCOMPANY_summary_KeyWord]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view 
[dbo].[V_TheCompany_KWS_4_CNT_TCOMPANY_summary_KeyWord]

as 

	SELECT  
		CompanyMatch_KeyWord_UPPER
		, max(s.[Company Names]) AS CompanyMatch_NameList
		/* , companyid */
		, max(CompanyMatch_Name) AS CompanyMatch_Name_Max

		, max(Custom1_Lists) as Custom1_Lists_Max
		, max(Custom2_Lists) as Custom2_Lists_Max
			
		, count(DISTINCT CASE WHEN CompanyMatch_Exact_Flag = 1 
			THEN CompanyMatch_Name ELSE NULL END) as CompanyCount_Exact
		, count(DISTINCT CASE WHEN CompanyMatch_LIKE_FLAG = 1 
			THEN CompanyMatch_Name ELSE NULL END) as CompanyCount_Like
		, count(DISTINCT CASE WHEN 
			CompanyMatch_Exact_Flag = 0 
			AND CompanyMatch_LIKE_FLAG = 0 			
			THEN CompanyMatch_Name ELSE NULL END) as CompanyCount_Other

		, count(DISTINCT CASE WHEN CompanyMatch_Exact_Flag = 1 
			THEN u.[ContractID] ELSE NULL END) as ContractCount_Exact	

		, count(DISTINCT CASE WHEN CompanyMatch_LIKE_FLAG = 1 
			THEN u.[ContractID] ELSE NULL END) as ContractCount_LIKE

		, count(DISTINCT CASE WHEN 
			CompanyMatch_Exact_Flag = 0 
			AND CompanyMatch_LIKE_FLAG = 0 
			THEN u.[ContractID] ELSE NULL END) as ContractCount_Other

		, count(DISTINCT CompanyMatch_Name) as CompanyCount
		, COUNT(DISTINCT u.[ContractID]) as ContractCount

		, min(CompanyMatch_Level) as CompanyMatch_Level_Min

		/* Dates */
		, MAX(s.[End Date]) as StartDate_MIN
		, MAX(s.[End Date]) as EndDate_MIN
		, MAX(s.[End Date]) as StartDate_MAX
		, MAX(s.[End Date]) as EndDate_MAX

	 FROM   [Contiki_app].[dbo].[V_TheCompany_KWS_0_ContikiView_CNT] s
				inner join T_TheCompany_KWS_7_CNT_ContractID_SummaryByContractID u
				on s.contractid = u.[ContractID]
	WHERE 
		CompanyMatch_Score >0
	group by 
		CompanyMatch_KeyWord_UPPER /*, companyid */

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_5_CNT_TCOMPANY_summary_Keyword_gap]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_KWS_5_CNT_TCOMPANY_summary_Keyword_gap]
as

	select top 1000 
		s.KeyWordVarchar255
	/*	, s.KeyWordLettersNumbersSpacesOnly */
		, r.[CompanyMatch_NameList]
		, r.[Custom1_Lists_Max]
		, r.[Custom2_Lists_Max]
		/* , r.CompanyCount_Exact is 1 */
		, r.ContractCount_Exact	

		, r.CompanyCount
		, r.[ContractCount]

		, r.[CompanyMatch_Level_Min]

	from T_TheCompany_KeyWordSearch s 
		left join [V_TheCompany_KWS_4_CNT_TCOMPANY_summary_KeyWord]  r 
		on s.KeyWordVarchar255_UPPER = upper(r.CompanyMatch_KeyWord)
	/* where [KeyWordType] = 'Company'  */
	order by s.KeyWordVarchar255 ASC
GO
/****** Object:  View [dbo].[VDOCUMENTSAMENDMENT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VDOCUMENTSAMENDMENT]
AS
SELECT     
dbo.VDOCUMENT.Title,
dbo.VDOCUMENT.Version,
dbo.VDOCUMENT.MajorVersion,
dbo.VDOCUMENT.MinorVersion,
dbo.VDOCUMENT.Status,
dbo.VDOCUMENT.Owner,
dbo.VDOCUMENT.TemplateType,
dbo.VDOCUMENT.CheckedOutBy,
dbo.VDOCUMENT.VersionDate,
dbo.VDOCUMENT.Datecreated,
dbo.VDOCUMENT.CHECKEDOUTDATE,
dbo.VDOCUMENT.FileName,
dbo.VDOCUMENT.FileSize,
dbo.VDOCUMENT.OriginalFileName,
dbo.VDOCUMENT.DocumentOwnerId,
dbo.VDOCUMENT.CheckedOutById,
dbo.VDOCUMENT.CheckedOutStatus,
dbo.VDOCUMENT.DOCUMENTTYPEID,
dbo.VDOCUMENT.DOCUMENTID,
dbo.VDOCUMENT.ARCHIVEID,
dbo.VDOCUMENT.ArchiveFixed,
dbo.VDOCUMENT.MIK_VALID,
dbo.VDOCUMENT.FileID,
dbo.VDOCUMENT.OBJECTTYPEID,
dbo.VDOCUMENT.OBJECTID,
dbo.VDOCUMENT.DOCUMENTTYPE,
dbo.VDOCUMENT.FileType,
dbo.VDOCUMENT.SOURCEFILEINFOID,
dbo.VDOCUMENT.ApprovalStatus,
dbo.VDOCUMENT.ApprovalStatusID,
dbo.VDOCUMENT.ApprovalStatusFixed,
dbo.VDOCUMENT.OBJECTID AS AmendmentId
FROM         dbo.VDOCUMENT INNER JOIN
                      dbo.TOBJECTTYPE ON dbo.VDOCUMENT.OBJECTTYPEID = dbo.TOBJECTTYPE.OBJECTTYPEID
WHERE     (dbo.TOBJECTTYPE.FIXED = N'AMENDMENT')




GO
/****** Object:  View [dbo].[V_TheCompany_Mig_VAGREEMENT_Type_Proc]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_Mig_VAGREEMENT_Type_Proc]
AS
select distinct a.*
from dbo.TAGREEMENT_TYPE a inner join T_TheCompany_ALL c on a.AGREEMENT_TYPEID = c.AGREEMENT_TYPEID
where c.contractid in (select CONTRACTID_proc 
			from dbo.V_TheCompany_Mig_0ProcNetFlag m
			where m.Proc_NetFlag = 1)
			
GO
/****** Object:  View [dbo].[V_TheCompany_VDEPARTMENT_Entities_Diligent_Roxana]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_VDEPARTMENT_Entities_Diligent_Roxana]

as 

SELECT [EntityName] as DLE_EntityName
      ,[Country] as DLE_Country
      ,[SAP_Code] as DLE_CompanyCode
      /*,[BP_QuickRef] as DLE_QuickRef */
      /*,[AliasName] as DLE_EntityNameAlias */
      ,[Status] as DLE_Status
      /*,[Comments] as DLE_Comments*/
      ,[MaxNoSignatures] as DLE_MaxNoSignatures
      ,[SignatureRules] as DLE_SignatureRules
	  , [Date_Dissolved] as DLE_Date_Dissolved


	, dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([EntityName]) as DLE_EntityName_NonAlphaNonNum
	, upper(dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([EntityName])) as DLE_EntityName_NonAlphaNonNum_Upper
	
	, left([dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]([EntityName]),255) as DLE_EntityName_NonFwSlash
	, left([dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash](UPPER([EntityName])),255) as DLE_EntityName_NonFwSlash_UPPER
from
	T_TheCompany_Entities_DiligentData_Roxana

GO
/****** Object:  View [dbo].[V_TheCompany_VDEPARTMENT_Entities_Diligent_Roxana_Xt]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[V_TheCompany_VDEPARTMENT_Entities_Diligent_Roxana_Xt]
as
select r.*, d.DLE_EntityName_Clean
from V_TheCompany_VDEPARTMENT_Entities_Diligent_Roxana r 
left join  V_TheCompany_VDEPARTMENT_Entities_Diligent_UNION_ALIAS d 
	on r.[DLE_EntityName_NonFwSlash_UPPER] = upper(d.[DLE_EntityName_NonFwSlash] )
		and r.[DLE_CompanyCode] = d.[DLE_SAP_Code] /* TheCompany Pharmaceuticals S.R.L. duplicate name in MD and RO*/
GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_TS_CountryAreaRegion]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_T_TheCompany_ALL_TS_CountryAreaRegion]
/* usage: Country area region list workbooks 
\\nycomed.local\shares\AA-Data-Legal-Transfer\Contract_Lists
*/
as

select [Contract Number]
      ,[Contract Desc (incl. Top Secret)]
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
	  [Contiki_app].[dbo].[V_T_TheCompany_ALL_STD_WithTS] c 
	  left join [dbo].[V_TheCompany_Mig_0ProcNetFlag] p 
	  /* inner join won't drop records since this table contains all records except for test etc. xt records cases */
	  on c.contractid = p.contractid_proc



GO
/****** Object:  View [dbo].[VDOCUMENTSCONTRACT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VDOCUMENTSCONTRACT]
AS
SELECT     
dbo.VDOCUMENT.Title,
dbo.VDOCUMENT.Version,
dbo.VDOCUMENT.MajorVersion,
dbo.VDOCUMENT.MinorVersion,
dbo.VDOCUMENT.Status,
dbo.VDOCUMENT.Owner,
dbo.VDOCUMENT.TemplateType,
dbo.VDOCUMENT.CheckedOutBy,
dbo.VDOCUMENT.VersionDate,
dbo.VDOCUMENT.Datecreated,
dbo.VDOCUMENT.CHECKEDOUTDATE,
dbo.VDOCUMENT.FileName,
dbo.VDOCUMENT.FileSize,
dbo.VDOCUMENT.OriginalFileName,
dbo.VDOCUMENT.DocumentOwnerId,
dbo.VDOCUMENT.CheckedOutById,
dbo.VDOCUMENT.CheckedOutStatus,
dbo.VDOCUMENT.DOCUMENTTYPEID,
dbo.VDOCUMENT.DOCUMENTID,
dbo.VDOCUMENT.ARCHIVEID,
dbo.VDOCUMENT.ArchiveFixed,
dbo.VDOCUMENT.MIK_VALID,
dbo.VDOCUMENT.FileID,
dbo.VDOCUMENT.OBJECTTYPEID,
dbo.VDOCUMENT.OBJECTID,
dbo.VDOCUMENT.DOCUMENTTYPE,
dbo.VDOCUMENT.FileType,
dbo.VDOCUMENT.SOURCEFILEINFOID,
dbo.VDOCUMENT.ApprovalStatus,
dbo.VDOCUMENT.ApprovalStatusID,
dbo.VDOCUMENT.ApprovalStatusFixed,
dbo.VDOCUMENT.OBJECTID AS ContractId
FROM         dbo.VDOCUMENT INNER JOIN
                      dbo.TOBJECTTYPE ON dbo.VDOCUMENT.OBJECTTYPEID = dbo.TOBJECTTYPE.OBJECTTYPEID
WHERE     (dbo.TOBJECTTYPE.FIXED = N'CONTRACT')



GO
/****** Object:  View [dbo].[VDOCUMENTSPROJECT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VDOCUMENTSPROJECT]
AS
SELECT     
dbo.VDOCUMENT.Title,
dbo.VDOCUMENT.Version,
dbo.VDOCUMENT.MajorVersion,
dbo.VDOCUMENT.MinorVersion,
dbo.VDOCUMENT.Status,
dbo.VDOCUMENT.Owner,
dbo.VDOCUMENT.TemplateType,
dbo.VDOCUMENT.CheckedOutBy,
dbo.VDOCUMENT.VersionDate,
dbo.VDOCUMENT.Datecreated,
dbo.VDOCUMENT.CHECKEDOUTDATE,
dbo.VDOCUMENT.FileName,
dbo.VDOCUMENT.FileSize,
dbo.VDOCUMENT.OriginalFileName,
dbo.VDOCUMENT.DocumentOwnerId,
dbo.VDOCUMENT.CheckedOutById,
dbo.VDOCUMENT.CheckedOutStatus,
dbo.VDOCUMENT.DOCUMENTTYPEID,
dbo.VDOCUMENT.DOCUMENTID,
dbo.VDOCUMENT.ARCHIVEID,
dbo.VDOCUMENT.ArchiveFixed,
dbo.VDOCUMENT.MIK_VALID,
dbo.VDOCUMENT.FileID,
dbo.VDOCUMENT.OBJECTTYPEID,
dbo.VDOCUMENT.OBJECTID,
dbo.VDOCUMENT.DOCUMENTTYPE,
dbo.VDOCUMENT.FileType,
dbo.VDOCUMENT.SOURCEFILEINFOID,
dbo.VDOCUMENT.ApprovalStatus,
dbo.VDOCUMENT.ApprovalStatusID,
dbo.VDOCUMENT.ApprovalStatusFixed,
dbo.VDOCUMENT.OBJECTID AS ProjectId
FROM         dbo.VDOCUMENT INNER JOIN
                      dbo.TOBJECTTYPE ON dbo.VDOCUMENT.OBJECTTYPEID = dbo.TOBJECTTYPE.OBJECTTYPEID
WHERE     (dbo.TOBJECTTYPE.FIXED = N'PROJECT')




GO
/****** Object:  View [dbo].[V_TheCompany_RegForm_UserGrp]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_RegForm_UserGrp]

as

/* waiting for SSO for user joest */

select TOP 9999 
 ug.USERGROUP as 'CustomUserGroup'
, (CASE WHEN AutomaticUserGroupUploadFlag = 1 THEN 'Yes' ELSE 'No' END) as AutomaticUserGroupUpload
, GETDATE() as Last_Updated 
FROM  V_TheCompany_VDEPARTMENT_VUSERGROUP ug 
where 
 ug.MIK_VALID = 1
 and ug.usergroupid not in (20 /* Legal */, 130 /* Super users */, 137 /* Read All */,1089 /* Public */,3397 /* Read all Headers */, 4901 /* Top Secret */)
 and ug.DEPARTMENTID is null
order by ug.USERGROUP



GO
/****** Object:  View [dbo].[V_TheCompany_VDEPARTMENT_Entities_Diligent_Union_Alias_NoLINC]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_VDEPARTMENT_Entities_Diligent_Union_Alias_NoLINC]

as 

SELECT [EntityName] as DLE_EntityName /* Diligent name or Alias */
		, [EntityName] as DLE_EntityName_Main /* Diligent Name */
		, [EntityName_Clean] as DLE_EntityName_Clean /* Clean Diligent Name */
		, [AliasName] as DLE_EntityName_Alias /* Alias not in Diligent main name */
      ,[Country] as DLE_Country
      ,[SAP_Code] as DLE_SAP_Code
      ,[BP_QuickRef] as DLE_QuickRef

      ,[Status] as DLE_Status
      ,[Comments] as DLE_Comments
      ,[MaxNoSignatures] as DLE_MaxNoSignatures
      ,[SignatureRules] as DLE_SignatureRules
	  , left([dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]([EntityName]),255) as DLE_EntityName_NonFwSlash

	, dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([EntityName]) as DLE_EntityName_NonAlphaNonNum
	, 'NameMain' as DLE_EntMainNameOrAlias
from
	T_TheCompany_Entities_DiligentData

	UNION 

SELECT [AliasName] as DLE_EntityName /* Diligent name or Alias */
		, [EntityName] as DLE_EntityName_Main /* Diligent Name */
		, [EntityName_Clean] as DLE_EntityName_Clean /* Clean Diligent Name */
		, [AliasName] as DLE_EntityName_Alias /* Alias not in Diligent main name */
      ,[Country] as DLE_Country
      ,[SAP_Code] as DLE_SAP_Code
      ,[BP_QuickRef] as DLE_QuickRef
       
      ,[Status] as DLE_Status
      ,[Comments] as DLE_Comments
      ,[MaxNoSignatures] as DLE_MaxNoSignatures
      ,[SignatureRules] as DLE_SignatureRules
	  , left([dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]([AliasName]),255) as DLE_EntityName_NonFwSlash

	, dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([AliasName]) as DLE_EntityName_NonAlphaNonNum
	, 'NameAlias' as EntMainNameOrAlias
from
	T_TheCompany_Entities_DiligentData
	WHERE [AliasName] >''
		and AliasName <> 'Same'
		and AliasName <> [EntityName]
		and [dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]([AliasName]) <> [dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]([EntityName])


GO
/****** Object:  View [dbo].[V_TheCompany_VDEPARTMENT_Entities_Diligent_Roxana_Xt_InsertSQL]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_VDEPARTMENT_Entities_Diligent_Roxana_Xt_InsertSQL]
as

select r.*
/*, d.DLE_EntityName */
, d.DLE_EntityName_Main
, d.DLE_EntityName_Clean
, d.DLE_EntityName_Alias
, d.[DLE_EntMainNameOrAlias]
, 'INSERT INTO T_TheCompany_Entities_DiligentData (
	[EntityName]
      ,[Country]
      ,[SAP_Code]
	, [Date_Dissolved]
      ,[Status]
      ,[MaxNoSignatures]
      ,[SignatureRules])

	  VALUES ('  	  
	  + ''''+ replace(r.[DLE_EntityName],'''','''''') + ''','
      + ''''+ r.[DLE_Country] + ''','
      + '''' + isnull(r.[DLE_CompanyCode],'') + ''','
      + '''' + isnull(r.[DLE_Date_Dissolved],'') + ''','  
      + ''''+ r.[DLE_Status] + ''','
      + ''''+  isnull(r.[DLE_MaxNoSignatures],'') + ''','
      + ''''+ isnull(r.[DLE_SignatureRules],'') + ''''
		+ ')'
	as InsertSQL

from V_TheCompany_VDEPARTMENT_Entities_Diligent_Roxana r 
left join  V_TheCompany_VDEPARTMENT_Entities_Diligent_UNION_ALIAS_NoLINC d 
	on /* r.[DLE_EntityName_NonFwSlash_UPPER] = upper(d.[DLE_EntityName_NonFwSlash] )
		and */ r.[DLE_CompanyCode] = d.[DLE_SAP_Code] 
			 /* TheCompany Pharmaceuticals S.R.L. duplicate name in MD and RO*/
		where d.dle_entityname is null
		/*and r.[DLE_CompanyCode] is not null*/

GO
/****** Object:  View [dbo].[V_TheCompany_VCONTRACT_DEPARTMENTROLES]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  VIEW [dbo].[V_TheCompany_VCONTRACT_DEPARTMENTROLES] 

AS


SELECT     

		 c.CONTRACTNUMBER AS Number 

					  , c.CONTRACTID,
                          (SELECT     MAX(A.AUDITTRAILID)
                            FROM          TAUDITTRAIL A, TOBJECTTYPE O10
                            WHERE      A.OBJECTTYPEID = O10.OBJECTTYPEID AND O10.FIXED = 'CONTRACT' 
							AND A.OBJECTID = c.CONTRACTID) 
                      AS AUDITTRAILID

					  , c.REFERENCECONTRACTNUMBER, 
                      c.COUNTERPARTYNUMBER
					 /* , u.DISPLAYNAME AS CCDisplayName, */
                      , d.DEPARTMENTID AS ROLE_DEPARTMENTID
					  , d.ROLEID, 
                      dbo.TDEPARTMENT.DEPARTMENT AS ROLE_DEPARTMENT
					  , dbo.TDEPARTMENT.DEPARTMENT_CODE AS ROLE_DEPARTMENT_CODE, 
                      dbo.TROLE.ROLE
					  , dbo.TROLE.FIXED AS ROLE_FIXED

					  , dbo.TDEPARTMENT.PARENTID 
FROM         
                      dbo.TDEPARTMENTROLE_IN_OBJECT d 
						INNER JOIN dbo.TCONTRACT c 
							ON d.objectid = c.contractid and d.objecttypeid = 1 /* contract */
						INNER JOIN dbo.TDEPARTMENT 
							ON d.DEPARTMENTID = dbo.TDEPARTMENT.DEPARTMENTID 
						INNER JOIN dbo.TROLE 
							ON dbo.TROLE.ROLEID = d.ROLEID 

					/*	LEFT JOIN dbo.V_TheCompany_VUSER uo 
							ON c.ownerid = uo.PERSONID */

WHERE  d.objecttypeid = 1 /* contract */


GO
/****** Object:  UserDefinedFunction [dbo].[TVF_GetContractAwardedCompanyNames]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*\
    End of script from "20130828_1119_UpdateSystemSetting_EMAIL_FOLDERSCAN_FILTERS.sql" file.
\*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*\
    Start of script from "20130830_1500_AlterUDF_TVF_GetContractAwardedCompanyNames.sql" file.
\*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
/*----------------------------------------------------------------------------*\
	Date:    2013-08-30
	Purpose: Company name with '&' is not shown correctly in contract search result (TCS-614-52012)
	Author:  Artem A.
\*----------------------------------------------------------------------------*/
                                                                                         
CREATE FUNCTION [dbo].[TVF_GetContractAwardedCompanyNames](@ContractID BIGINT)
RETURNS TABLE 
AS 
RETURN
(
	  SELECT ISNULL(SUBSTRING((select ', '+ISNULL(c.COMPANY, '') FROM TCOMPANY c 
   		INNER JOIN TTENDERER t ON t.COMPANYID=c.COMPANYID
		   WHERE t.ISAWARDED=1  AND  t.CONTRACTID=con.CONTRACTID
	   	FOR XML PATH, TYPE).value('.[1]', 'nvarchar(max)')
   		,3,255), '') AS 'AwardedCompanyNames'
      FROM TCONTRACT con
	  WHERE con.contractID=@ContractID
)

GO
/****** Object:  View [dbo].[VCONTRACT_DEPARTMENTROLES]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW [dbo].[VCONTRACT_DEPARTMENTROLES] AS
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
                      dbo.TCONTRACT.COUNTERPARTYNUMBER, TPERSON_2.DISPLAYNAME AS CCDisplayName, 
                      dbo.TDEPARTMENTROLE_IN_OBJECT.DEPARTMENTID AS ROLE_DEPARTMENTID, dbo.TDEPARTMENTROLE_IN_OBJECT.ROLEID, 
                      dbo.TDEPARTMENT.DEPARTMENT AS ROLE_DEPARTMENT, dbo.TDEPARTMENT.DEPARTMENT_CODE AS ROLE_DEPARTMENT_CODE, 
                      dbo.TROLE.ROLE, dbo.TROLE.FIXED AS ROLE_FIXED, TSTATUS_1.STATUS AS ApprovalStatus, dbo.TCONTRACT.PUBLISH, dbo.TCONTRACT.SHAREDWITHSUPPLIER
FROM         dbo.TSTRATEGYTYPE RIGHT OUTER JOIN
                      dbo.TCOMPANY LEFT OUTER JOIN
                      dbo.TCOMPANYADDRESS INNER JOIN
                      dbo.TADDRESSTYPE ON dbo.TCOMPANYADDRESS.ADDRESSTYPEID = dbo.TADDRESSTYPE.ADDRESSTYPEID AND 
                      dbo.TADDRESSTYPE.FIXED = 'MAINADDRESS' LEFT OUTER JOIN
                      dbo.TCOUNTRY ON dbo.TCOMPANYADDRESS.COUNTRYID = dbo.TCOUNTRY.COUNTRYID ON 
                      dbo.TCOMPANY.COMPANYID = dbo.TCOMPANYADDRESS.COMPANYID RIGHT OUTER JOIN
                      dbo.TSTATUS INNER JOIN
                      dbo.TSTATUS_IN_OBJECTTYPE ON dbo.TSTATUS.STATUSID = dbo.TSTATUS_IN_OBJECTTYPE.STATUSID INNER JOIN
                      dbo.TCONTRACT INNER JOIN
                      dbo.TOBJECTTYPE INNER JOIN
                      dbo.TROLE INNER JOIN
                      dbo.TDEPARTMENTROLE_IN_OBJECT ON dbo.TROLE.ROLEID = dbo.TDEPARTMENTROLE_IN_OBJECT.ROLEID INNER JOIN
                      dbo.TDEPARTMENT ON dbo.TDEPARTMENTROLE_IN_OBJECT.DEPARTMENTID = dbo.TDEPARTMENT.DEPARTMENTID ON 
                      dbo.TOBJECTTYPE.OBJECTTYPEID = dbo.TDEPARTMENTROLE_IN_OBJECT.OBJECTTYPEID ON 
                      dbo.TCONTRACT.CONTRACTID = dbo.TDEPARTMENTROLE_IN_OBJECT.OBJECTID ON 
                      dbo.TSTATUS_IN_OBJECTTYPE.OBJECTTYPEID = dbo.TOBJECTTYPE.OBJECTTYPEID AND 
                      dbo.TSTATUS.STATUSID = dbo.TCONTRACT.STATUSID LEFT OUTER JOIN
                      dbo.TSTATUS TSTATUS_1 INNER JOIN
                      dbo.TOBJECTTYPE TOBJECTTYPE_1 INNER JOIN
                      dbo.TAPPROVALSTATUS_IN_OBJECTTYPE ON TOBJECTTYPE_1.OBJECTTYPEID = dbo.TAPPROVALSTATUS_IN_OBJECTTYPE.OBJECTTYPEID AND 
                      TOBJECTTYPE_1.FIXED = N'CONTRACT' ON TSTATUS_1.STATUSID = dbo.TAPPROVALSTATUS_IN_OBJECTTYPE.APPROVALSTATUSID ON 
                      dbo.TCONTRACT.APPROVALSTATUSID = TSTATUS_1.STATUSID 
					  ON dbo.TCOMPANY.COMPANYID = dbo.udf_get_companyid(dbo.TCONTRACT.CONTRACTID)
					  LEFT OUTER JOIN
                      dbo.TCONTRACTTYPE ON dbo.TCONTRACT.CONTRACTTYPEID = dbo.TCONTRACTTYPE.CONTRACTTYPEID ON 
                      dbo.TSTRATEGYTYPE.STRATEGYTYPEID = dbo.TCONTRACT.STRATEGYTYPEID LEFT OUTER JOIN
                      dbo.TCONTRACTRELATION ON dbo.TCONTRACT.CONTRACTRELATIONID = dbo.TCONTRACTRELATION.CONTRACTRELATIONID LEFT OUTER JOIN
                      dbo.TAGREEMENT_TYPE ON dbo.TCONTRACT.AGREEMENT_TYPEID = dbo.TAGREEMENT_TYPE.AGREEMENT_TYPEID FULL OUTER JOIN
                      dbo.TPERSON TPERSON_1 RIGHT OUTER JOIN
                      dbo.TEMPLOYEE TEMPLOYEE_1 ON TPERSON_1.PERSONID = TEMPLOYEE_1.PERSONID FULL OUTER JOIN
                      dbo.TUSER TUSER_1 ON TEMPLOYEE_1.EMPLOYEEID = TUSER_1.EMPLOYEEID ON 
                      dbo.TCONTRACT.CHECKEDOUTBY = TUSER_1.USERID FULL OUTER JOIN
                      dbo.TEMPLOYEE TEMPLOYEE_2 LEFT OUTER JOIN
                      dbo.TPERSON TPERSON_2 ON TEMPLOYEE_2.PERSONID = TPERSON_2.PERSONID FULL OUTER JOIN
                      dbo.TUSER TUSER_2 ON TEMPLOYEE_2.EMPLOYEEID = TUSER_2.EMPLOYEEID ON dbo.TCONTRACT.EXECUTORID = TUSER_2.USERID
WHERE     (dbo.TOBJECTTYPE.FIXED = N'CONTRACT')
ORDER BY dbo.TCONTRACT.CONTRACTID

GO
/****** Object:  View [dbo].[V_TheCompany_VCONTRACT_DPTROLES_FLAT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_VCONTRACT_DPTROLES_FLAT]

as

	SELECT

		'V_TheCompany_VCONTRACT_DPTROLES_FLAT' /*Number*/ as Dpt_ContractNumber
	, CONTRACTID AS Dpt_contractid

	/* All Roles */

 		, CAST( Replace(STUFF(
		(SELECT ',' + s.ROLE_DEPARTMENT
		FROM VCONTRACT_DEPARTMENTROLES s
		WHERE s.contractid =d.contractid
			AND s.ROLEID IN(1,19,20,34,23 /*Super User*/
			,2 /* Contract Owner*/
			,15,36 /* Contract Responsible*/ ) 
		FOR XML PATH('')),1,1,''),'&amp;','&') as varchar(255))
	AS Dpt_AllUserDpts

	/* SUPER USER */

		, CAST( left(Replace((SELECT s.ROLE_DEPARTMENT
		FROM VCONTRACT_DEPARTMENTROLES s
		WHERE s.contractid =d.contractid 
			AND s.ROLEID IN(1,19,20,34,23 /*Super User*/) 
		),'&amp;','&') ,255) as varchar(100))
	AS Dpt_SuperUserDpt

		,(SELECT s.ROLE_DEPARTMENTID
		FROM VCONTRACT_DEPARTMENTROLES s
		WHERE s.contractid =d.contractid 
			AND s.ROLEID IN(1,19,20,34,23 /*Super User*/)
		) 
	AS Dpt_SuperUserDpt_ID


		,(SELECT s.ROLE_DEPARTMENT_CODE
		FROM VCONTRACT_DEPARTMENTROLES s
		WHERE s.contractid =d.contractid 
			AND s.ROLEID IN(1,19,20,34,23 /*Super User*/)
		) 
	AS Dpt_SuperUserDpt_Code

				/* CONTRACT OWNER - one role per contract */


	,	(SELECT s.ROLE_DEPARTMENT
	FROM VCONTRACT_DEPARTMENTROLES s
	WHERE s.CONTRACTID =d.CONTRACTID 
		AND s.ROLEID = 2 /* Contract Owner*/
	) AS Dpt_ContractOwner /* contract owner name */


	,(SELECT top 1 ROLE_DEPARTMENTID
		FROM VCONTRACT_DEPARTMENTROLES s
		WHERE s.contractid =d.contractid 
			AND s.ROLEID = 2 /* Contract Owner*/ 
		)
	AS Dpt_ContractOwnerDpt_ID


	,CAST(Replace(STUFF(
	(SELECT ',' + s.ROLE_DEPARTMENT_CODE
	FROM VCONTRACT_DEPARTMENTROLES s
	WHERE s.CONTRACTID =d.CONTRACTID 
		AND s.ROLEID = 2 /* Contract Owner*/
	FOR XML PATH('')),1,1,''),'&amp;','&') as varchar(100))
	 AS Dpt_ContractOwnerDpt_Code

	/* CONTRACT RESPONSIBLE */


	,CAST(Replace(STUFF(
	(SELECT ',' + s.ROLE_DEPARTMENT
	FROM VCONTRACT_DEPARTMENTROLES s
	WHERE s.CONTRACTID =d.CONTRACTID 
		AND s.ROLEID IN(15 /* Contract responsible */, 36 /* 36 = Contract Responsible - AMD */) 
	FOR XML PATH('')),1,1,''),'&amp;','&') as varchar(100))
	AS Dpt_ContractResponsible


	,(SELECT top 1 ROLE_DEPARTMENTID
	FROM VCONTRACT_DEPARTMENTROLES s
	WHERE s.contractid =d.contractid 
		AND s.ROLEID = 15 /* Contract responsible */
	)
	AS Dpt_ContractResponsibleDpt_ID

	/* 110	Signatory/Signatories - only ONE role per contract, no list needed */

/*OK*/		, (SELECT s.ROLE_DEPARTMENT
	FROM VCONTRACT_DEPARTMENTROLES s
	WHERE s.CONTRACTID =d.CONTRACTID 
		AND s.ROLEID IN(110	/* Signatory/Signatories */) )
		 AS Dpt_ContractSignatory

/*OK*/	,CAST( Replace(STUFF(
	(SELECT ',' + s.ROLE_DEPARTMENT_CODE
	FROM VCONTRACT_DEPARTMENTROLES s
	WHERE s.CONTRACTID =d.CONTRACTID 
		AND s.ROLEID IN(15 /* Contract responsible */, 36 /* 36 = Contract Responsible - AMD */) 
	FOR XML PATH('')),1,1,''),'&amp;','&') as varchar(100))
	AS Dpt_ContractResponsibleDpt_Code

	/* INTERNAL PARTNERS */

	,CAST(Replace(STUFF(
	(SELECT ',' + s.ROLE_DEPARTMENT
	FROM VCONTRACT_DEPARTMENTROLES s
	WHERE s.CONTRACTID =d.CONTRACTID 
		AND s.ROLEID IN(0,6/*ENTITY*/,100 /*INTERNAL PARTNER*/) 
	FOR XML PATH('')),1,1,''),'&amp;','&') as varchar(255))
	 AS InternalPartners

		,CAST(Replace(STUFF(
		(SELECT ',' + s.ROLE_DEPARTMENT
		FROM V_TheCompany_VCONTRACT_DEPARTMENTROLES s
		WHERE s.CONTRACTID =d.CONTRACTID 
			AND s.ROLEID IN(0,6/*ENTITY*/,100 /*INTERNAL PARTNER*/) 
			AND s.PARENTID = 10004 /* Internal Partner Root */
		FOR XML PATH('')),1,1,''),'&amp;','&')  as varchar(255))
	AS InternalPartners_ACTIVE

		,
		(SELECT max(s.ROLE_DEPARTMENTID)
		FROM V_TheCompany_VCONTRACT_DEPARTMENTROLES s /* inner join [dbo].[V_TheCompany_VDepartment_ParsedDpt_InternalPartner] p
			on s.ROLE_DEPARTMENTID = p.departmentid */
		WHERE s.CONTRACTID =d.CONTRACTID 
			AND s.ROLEID IN(0,6/*ENTITY*/,100 /*INTERNAL PARTNER*/) 
			AND s.ROLE_DEPARTMENT_CODE like ',%' /* IP - other dpt codes found in mig file */
			/* AND s.PARENTID = 10004  Internal Partner Root = ACTIVE - 
			cannot filter by this, since many outdated entity names */
		/* AND P.IP_Rank = 0 /* 1 first, tpiz */ */ )
	AS InternalPartners_ACTIVE_MAX_DPTID

		,/* CAST(Replace(STUFF(
		(SELECT max(s.ROLE_DEPARTMENT)
		FROM V_TheCompany_VCONTRACT_DEPARTMENTROLES s /* inner join [dbo].[V_TheCompany_VDepartment_ParsedDpt_InternalPartner] p
			on s.ROLE_DEPARTMENTID = p.departmentid */
		WHERE s.CONTRACTID =d.CONTRACTID 
			AND s.ROLEID IN(0,6/*ENTITY*/,100 /*INTERNAL PARTNER*/) 
			AND s.PARENTID = 10004 /* Internal Partner Root = ACTIVE */
		/* AND P.IP_Rank = 0 /* 1 first, tpiz */ */
	FOR XML PATH('')),1,1,''),'&amp;','&')  as varchar(50))
	*/ '' AS InternalPartners_ACTIVE_MAX_NAME

		,CAST(Replace(STUFF(
		(SELECT ',' + s.ROLE_DEPARTMENT
		FROM V_TheCompany_VCONTRACT_DEPARTMENTROLES s
		WHERE s.CONTRACTID =d.CONTRACTID 
			AND s.ROLEID IN(0 /* ENTITY - CREATOR */, 6/*ENTITY*/, 100 /*INTERNAL PARTNER*/) 
			AND s.PARENTID <> 10004 /* Internal Partner Root */
			AND s.ROLE_DEPARTMENT_CODE like ',%' 
		FOR XML PATH('')),1,1,''),'&amp;','&') as varchar(255))
	AS InternalPartners_INACTIVE

		, CAST(STUFF(
		(SELECT ',' + STR(ROLE_DEPARTMENTID)
		FROM VCONTRACT_DEPARTMENTROLES s
		WHERE s.CONTRACTID =d.CONTRACTID 
			AND s.ROLEID IN(0 /* ENTITY - CREATOR */, 6/*ENTITY*/, 100 /*INTERNAL PARTNER*/) 
			AND s.ROLE_DEPARTMENT_CODE like ',%' 
		FOR XML PATH('')),1,1,'') as varchar(255))
	AS InternalPartners_IDs

		,CAST(Replace(STUFF(
		(SELECT DISTINCT ',' + SUBSTRING(s.ROLE_DEPARTMENT_CODE,2,2)
		FROM VCONTRACT_DEPARTMENTROLES s
		WHERE s.CONTRACTID =d.CONTRACTID 
			AND s.ROLEID IN(0 /* ENTITY - CREATOR */, 6/*ENTITY*/, 100 /*INTERNAL PARTNER*/) 
			AND s.ROLE_DEPARTMENT_CODE like ',%' 
		FOR XML PATH('')),1,1,''),'&amp;','&') as varchar(255))
	AS InternalPartners_Countries

		,CAST(Replace(STUFF(
		(SELECT DISTINCT ',' + s.ROLE_DEPARTMENT_CODE
		FROM VCONTRACT_DEPARTMENTROLES s
		WHERE s.CONTRACTID =d.CONTRACTID 
			AND s.ROLEID IN(0 /* ENTITY - CREATOR */, 6/*ENTITY*/, 100 /*INTERNAL PARTNER*/) 
			AND s.ROLE_DEPARTMENT_CODE like ',%' 
		FOR XML PATH('')),1,1,''),'&amp;','&')  as varchar(255))
	AS InternalPartners_DptCodeList

		,(SELECT COUNT(s.ROLEID)
		FROM VCONTRACT_DEPARTMENTROLES s
		WHERE s.CONTRACTID =d.CONTRACTID 
			AND s.ROLEID IN(0 /* ENTITY - CREATOR */, 6/*ENTITY*/, 100 /*INTERNAL PARTNER*/) 
			AND s.ROLE_DEPARTMENT_CODE like ',%' 
		GROUP BY s.number) 
	AS InternalPartners_COUNT

		,isnull((SELECT COUNT(s.ROLEID)
		FROM V_TheCompany_VCONTRACT_DEPARTMENTROLES s
		WHERE s.CONTRACTID =d.CONTRACTID 
			AND s.ROLEID IN(0 /* ENTITY - CREATOR */, 6/*ENTITY*/, 100 /*INTERNAL PARTNER*/) 
			AND s.PARENTID = 10004 /* Internal Partner Root = ACTIVE */
			AND s.ROLE_DEPARTMENT_CODE like ',%' 
		GROUP BY s.number) ,0) /* set to 0 if NO active entities , this should normally not happen */
	AS InternalPartners_COUNT_ACTIVE

		,isnull((SELECT COUNT(s.ROLEID)
		FROM V_TheCompany_VCONTRACT_DEPARTMENTROLES s
		WHERE s.CONTRACTID =d.CONTRACTID 
			AND s.ROLEID IN(0,6/*ENTITY*/,100 /*INTERNAL PARTNER*/)
			AND s.PARENTID <> 10004 /* Internal Partner NOT Root = INACTIVE */
			AND s.ROLE_DEPARTMENT_CODE like ',%' 
		GROUP BY s.number) ,0) /* set to 0 if NULL for expired contracts without active entities */
	AS InternalPartners_COUNT_INACTIVE
	/* TERRITORIES */

		,CAST(Replace(STUFF(
		(SELECT ',' + STR(s.ROLE_DEPARTMENTID)
		FROM VCONTRACT_DEPARTMENTROLES s
		WHERE s.CONTRACTID =d.CONTRACTID 
			AND s.ROLEID IN(3 /*TERRITORY*/) 
		FOR XML PATH('')),1,1,''),'&amp;','&') as varchar(255))
		 AS Territories_IDs

		,CAST(Replace(STUFF(
		(SELECT ',' + s.ROLE_DEPARTMENT
		FROM VCONTRACT_DEPARTMENTROLES s
		WHERE s.CONTRACTID =d.CONTRACTID 
			AND s.ROLEID IN(3 /*TERRITORY*/) 
		FOR XML PATH('')),1,1,''),'&amp;','&') as varchar(255))
		 AS Territories


		,(SELECT COUNT(s.ROLEID)
		FROM VCONTRACT_DEPARTMENTROLES s
		WHERE s.CONTRACTID =d.CONTRACTID 
			AND s.ROLEID IN(3 /*TERRITORY*/) 
		GROUP BY s.number) AS Territories_COUNT

	/* Hardcopy Archiving */

		,CAST(Replace(STUFF(
		(SELECT ',' + s.ROLE_DEPARTMENT
		FROM VCONTRACT_DEPARTMENTROLES s
		WHERE s.CONTRACTID =d.CONTRACTID 
			AND s.ROLEID IN(103 /* HARDCOPY ARCHIVING */) 
		FOR XML PATH('')),1,1,''),'&amp;','&') as varchar(255))
		 AS HardcopyArchiving
 
	FROM VCONTRACT_DEPARTMENTROLES d
	/*left join dbo.T_TheCompany_Hierarchy h on d.Dpt_ContractOwnerDpt_ID = h.departmentid_link */
	GROUP BY 
		CONTRACTID


GO
/****** Object:  View [dbo].[V_TheCompany_VCONTRACT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_VCONTRACT]

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
/*	, (CASE WHEN TCONTRACT.REV_EXPIRYDATE IS NULL 
		THEN  DATEADD(d,0,DATEADD(hh,1,TCONTRACT.EXPIRYDATE))
		ELSE DATEADD(d,0,DATEADD(hh,1,TCONTRACT.REV_EXPIRYDATE))
		END) AS FINAL_EXPIRYDATE */
		, (case when (CASE WHEN TCONTRACT.REV_EXPIRYDATE is not null then 
					REV_EXPIRYDATE 
					else EXPIRYDATE end) is null then null
				ELSE DATEADD(d,0,DATEADD(hh,1,(CASE WHEN TCONTRACT.REV_EXPIRYDATE is not null then REV_EXPIRYDATE else EXPIRYDATE end)))
				END)				
		AS FINAL_EXPIRYDATE
		/* (CASE WHEN TCONTRACT.REV_EXPIRYDATE is not null then REV_EXPIRYDATE else EXPIRYDATE end) */
	,  DATEADD(d,0,DATEADD(hh,1,TCONTRACT.REVIEWDATE)) AS REVIEWDATE
	, TCONTRACT.CHECKEDOUTDATE
, DEFINEDENDDATE
, TSTATUS.STATUS
, TCONTRACTRELATION.CONTRACTRELATION AS ContractRelations

/* Edit Flags */
	
/*		,(CASE WHEN TCONTRACT.STARTDATE IS NULL THEN 1 ELSE 0 END) AS
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

		, (CASE WHEN t.CompanyIDCount = 0 
		OR  t.CompanyIDCount is null 
		THEN 1 ELSE 0 END) AS 
	EDIT_NO_COMPANYID

		, (CASE WHEN
		 TCONTRACT.STARTDATE IS NULL 
		OR  (TCONTRACT.REV_EXPIRYDATE IS NULL AND  TCONTRACT.EXPIRYDATE IS NULL AND  TCONTRACT.REVIEWDATE IS NULL)
		OR  TCONTRACT.NUMBEROFFILES = 0
		THEN 1 ELSE 0 END) AS
	EDIT_VCONTRACT_FLAG

, TCONTRACT.EXECUTORID /* no longer used */
, TCONTRACT.OWNERID
, TCONTRACT.TECHCOORDINATORID
	commented 23-feb */
, TCONTRACT.NUMBEROFFILES

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
	, tcontract.LumpSumAmountID
	, cast(left(tcontract.COMMENTS,255) as varchar(255)) as Comments_255
	/*, tcontract.COMMENTS*/
	/*, ISNULL(left(TCONTRACTSUMMARY.SUMMARYBODY,255),'') AS 'SUMMARYBODY_255_Comments' *//* field was deleted as of V6.15, no replacement */
	/*, ISNULL(TCONTRACTSUMMARY.INGRESS,'') AS SUMMARY_INGRESS /* nvarchar 2000, only a handful of records have data */*/
	/*, ISNULL(TCONTRACTSUMMARY.SEARCHWORDS,'') as SUMMARY_SEARCHWORDS /* nvarchar 255, but currently not used */*/
	/* the other available field, summarybody currently considered to be not needed */
	, [TERMINATIONPERIOD]
	, [TERMINATIONCONDITIONS]
	, REFERENCECONTRACTID
FROM        
    TCONTRACT 

	INNER JOIN TSTATUS ON TSTATUS.STATUSID = TCONTRACT.STATUSID /* Mandatory field */
	INNER JOIN TCONTRACTTYPE ON TCONTRACT.CONTRACTTYPEID = TCONTRACTTYPE.CONTRACTTYPEID  /* Mandatory field */
	INNER JOIN TCONTRACTRELATION ON TCONTRACT.CONTRACTRELATIONID = TCONTRACTRELATION.CONTRACTRELATIONID  /* Mandatory field */


	LEFT JOIN TAGREEMENT_TYPE  on TAGREEMENT_TYPE.AGREEMENT_TYPEID = TCONTRACT.AGREEMENT_TYPEID
	/* LEFT JOIN V_TheCompany_TTENDERER_FLAT t ON TCONTRACT.CONTRACTID = t.CONTRACTID */
	/* LEFT JOIN  TCONTRACTSUMMARY ON TCONTRACT.CONTRACTID 
		= TCONTRACTSUMMARY.CONTRACTID /* not present for all contracts, only if filled in */*/
	LEFT JOIN TSTRATEGYTYPE s on tcontract.STRATEGYTYPEID = s.STRATEGYTYPEID 
WHERE  
	TCONTRACT.CONTRACTTYPEID NOT IN (	  5 /* Test Old */
									, 6 /* Access SAKSNR number Series*/		
									/*,  11	Case */					
									, 13 /* DELETE */
									, 102 /* Test New */								
									/*, 103, 104, 105  Lists */
									, 106 /* AutoDelete */
									)

GO
/****** Object:  View [dbo].[V_TheCompany_AgreementTypeRanked]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View [dbo].[V_TheCompany_AgreementTypeRanked]
as

select agreement_typeid,
       (case when rank <= 25 THEN 1 ELSE 0 END) as Agreement_Type_Top25Flag
from (
     select agreement_typeid
			,COUNT(*) as ContractCount
			,rank() OVER (ORDER BY count(*) desc) as rank
     from dbo.TCONTRACT as c
     group by
			agreement_typeid
     ) as c


GO
/****** Object:  View [dbo].[V_TheCompany_AgreementType]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_AgreementType]

as 

	select 
		a.[AGREEMENT_TYPEID] as AgrTypeID
		  ,a.[AGREEMENT_TYPE] as AgrType
		  /* ,[MIK_SEQUENCE] */ 
		  ,a.[MIK_VALID] as AgrMikValid /*'AgreementType is Valid' */
		  ,a.[FIXED] as AgrFixed

		  , (case 
				when a.FIXED like '%§Material%' then 1 
				when a.FIXED like  '%§NonMat%' then 0 /* override list */
				WHEN m.[Agr_IsMaterial_Flag] = 1 then 1
				else 0 
				END) 
				as Agr_IsMaterial_Flag

		  ,  (CASE 
				when a.FIXED like '%§Material%' then 'Yes'
				when a.FIXED like  '%§NonMat%' then 'No' /* override list */
				WHEN m.[Agr_IsMaterial_Flag] = 1 then 'Yes'
				else 'No' END)   
				as AgrIsMaterial
		  ,  (CASE 
				when a.FIXED like '%§Material%' then 'Yes'
				when a.FIXED like  '%§NonMat%' then 'No (AgType)' /* override list */
				WHEN m.[Agr_IsMaterial_Flag] = 1 then 'Yes (List)'
				else 'Unclassified' END)   
				as AgrIsMaterialDetail				
				/* 
					WHEN m.[Agr_IsMaterial_Flag]  IS NULL THEN 'Unclassified' /* if not in list, assume yes */
					WHEN m.[Agr_IsMaterial_Flag]  = 1 THEN 'Yes'
					WHEN m.[Agr_IsMaterial_Flag]  = 0 THEN 'No'
					ELSE 'Other' END)   as AgrIsMaterial
					*/
		  , m.[Agr_IsDivestment_Flag] /* separate table */

		  , (CASE 
					WHEN m.[Agr_IsDivestment_Flag] Is null THEN 'Unclassified' /* if not in list, assume yes */
					WHEN m.[Agr_IsDivestment_Flag] = 1 THEN 'Yes'
					WHEN m.[Agr_IsDivestment_Flag] = 0 THEN 'No'
					ELSE 'Other' END) 
					as AgrIsDivestment

		, r.Agreement_Type_Top25Flag as AgrType_Top25Flag

		, 	 (case when fixed like '%private%' then 1 
					when fixed like '%public%' then 0				
				else 2 /* Undetermined */	
			END) as AgreementType_IsPrivate_FLAG

		, 	 (case when fixed like '%public%' then 1
				when fixed like '%private%' then 0 
			else 2 /* Undetermined */	
			END) as AgreementType_IsPUBLIC_FLAG

		, 	 (case when fixed like '%public%' then 'Public' 
			when fixed like '%private%' then 'Private' 
			else 'Unclassified' END) as AgreementType_PublicPrivate

/* HCP/HCO FLAG */
			, (case when fixed like '%+HCX%' then 'HCP/HCO' 
					when fixed like '%-HCX%' then 'NON-HCP/HCO'
					else 'N/A' end) as AgrType_IsHCX
			, (case when fixed like '%+HCX%' then 1
					when fixed like '%-HCX%' then 0
					else 2 end) as AgrType_IsHCX_Flag

				, (CASE 
			WHEN FIXED like '%$LEGAL%' then 'LEGAL' /* Agreement Fixed Field in Agreement Type table is $LEGAL 
																		- this type is attributed to legal no matter what contract owner department */
			
			WHEN FIXED like '%$ARIBA%' then 'ARIBA'/* 'ARIBA' */ /* Agreement Fixed Field in Agreement Type table is $ARIBA  
																	- this type is attributed to legal no matter what contract owner department */
			WHEN FIXED like '%$SPLIT%' then 'SPLIT' /*'SPLIT(TO DO)'*/ /* Agreement Type that still needs to be split in two types of which one is Ariba and one Legal,
																	 or the agreements will have their type changed to other agreement types */
			WHEN FIXED like '%$DPT%' then 'DPT' /*'OWNER DPT'*/  /* Agreement Fixed Field in Agreement Type table is $DPT,
																			 meaning that it depends on the contract owner department if the contract is attributed to Ariba or Legal */
			WHEN FIXED like '%$LGMM%' then 'LG MATTER'
			WHEN FIXED like '%$TM%' then 'TM/IP' /* IP/Licensing */
			ELSE 'N/A' END)
		AS AgrType_LgArbSplitDptMtrTMIP_FLAG
/* ARIBA/CONTIKI FLAG */
/* V_TheCompany_ALL: CASE WHEN CompanyIDList = '1' /* intercompany */ THEN 4 /* Intercompany agreements always attributed to Legal no matter which other properties */
				WHEN title like '%GxP%' THEN 6 /* Gxp is also LEGAL, manually review */ */
		, (CASE 
			WHEN FIXED like '%$LGMM%' then 7 /* matter management */
			WHEN FIXED like '%$TM%' then 8 /* IP/Licensing */
			WHEN /*(FIXED like '%$LEGAL%' OR FIXED like '%$SPLIT%' OR FIXED like '%$DPT%'
					and */ fixed like '%-HCX%' then 0 /* Agreement Fixed Field in Agreement Type table is $LEGAL 
																		- this type is attributed to legal no matter what contract owner department */
			WHEN FIXED like '%+HCX%' /*'%$ARIBA%'*/ then 1 /* 0? was 1 , but now 0, DUE TO LINC */ /* Agreement Fixed Field in Agreement Type table is $ARIBA  
																	- this type is attributed to legal no matter what contract owner department */
			/*WHEN FIXED like '%$SPLIT%' then 2 /* was 2, now all to LINC */ /* Agreement Type that still needs to be split in two types of which one is Ariba and one Legal,
																	 or the agreements will have their type changed to other agreement types */
			
			WHEN FIXED like '%$DPT%' then 3 /* was 3 */ /* Agreement Fixed Field in Agreement Type table is $DPT,
																			 meaning that it depends on the contract owner department if the contract is attributed to Ariba or Legal */
			
			/* 4 = Intercompany = V_TheCompany_ALL *			
			/* 6 = GxP = V_TheCompany_ALL */
			/* 9 already in Ariba, = V_TheCompany_ALL */*/*/
			
			ELSE 2 /* Split - NO HCX flag yet 5 = other */
			END)
		AS TargetSystem_AgTypeFLAG

		, (CASE 
			WHEN FIXED like '%$LEGAL%' then 'LEGAL' /* Agreement Fixed Field in Agreement Type table is $LEGAL 
																		- this type is attributed to legal no matter what contract owner department */
			
			WHEN FIXED like '%$ARIBA%' then 'LEGAL (Procurement type)' /* 'ARIBA' */ /* Agreement Fixed Field in Agreement Type table is $ARIBA  
																	- this type is attributed to legal no matter what contract owner department */
			WHEN FIXED like '%$SPLIT%' then 'LEGAL (SPLIT)' /*'SPLIT(TO DO)'*/ /* Agreement Type that still needs to be split in two types of which one is Ariba and one Legal,
																	 or the agreements will have their type changed to other agreement types */
			WHEN FIXED like '%$DPT%' then 'LEGAL (Owner Dpt)' /*'OWNER DPT'*/  /* Agreement Fixed Field in Agreement Type table is $DPT,
																			 meaning that it depends on the contract owner department if the contract is attributed to Ariba or Legal */
			WHEN FIXED like '%$LGMM%' then 'LG MATTER'
			WHEN FIXED like '%$TM%' then 'TM/IP' /* IP/Licensing */
			ELSE 'N/A' END)
		AS TargetSystem_AgType

		, (select COUNT(contractid) from TCONTRACT c where c.AGREEMENT_TYPEID = a.[AGREEMENT_TYPEID] ) as AgrType_ContractCount

			, (select COUNT(documentid) from vdocument d where d.OBJECTTYPEID = 1 
					and OBJECTID in ( select contractid from TCONTRACT c 
								where c.AGREEMENT_TYPEID = a.[AGREEMENT_TYPEID] ) ) 
			as AgrType_DocumentCount

			, LEFT((select TOP 1 CONTRACTNUMBER +': '+ [CONTRACT] 
						from TCONTRACT c 
						where c.AGREEMENT_TYPEID = a.[AGREEMENT_TYPEID] 
							and statusid = 5 /* active */ and CONTRACTTYPEID <>11 /* case */) , 255)
			as AgrType_ActSampleContract
			, (case when m.Agr_LINC_MainType IS null or  m.Agr_LINC_MainType ='' then  'UNMAPPED Type: '+ a.AGREEMENT_TYPE else m.Agr_LINC_MainType end) as Agr_LINC_MainType_DefaultContiki
			, (case when m.Agr_LINC_SubType IS  null or m.Agr_LINC_SubType = '' then 'UNMAPPED SubType: '+ a.AGREEMENT_TYPE else m.Agr_LINC_SubType end) as Agr_LINC_SubType_DefaultContiki
			, m.Agr_LINC_MainType
			, m.Agr_LINC_SubType
			, m.[Agr_LNC_Comments]
	from [dbo].[TAGREEMENT_TYPE] a 
		left join [dbo].[T_TheCompany_AgreementType] m 
			on a.agreement_typeid = m.agr_typeid
		INNER join [V_TheCompany_AgreementTypeRanked] r /* made inner join - no WHERE filter */
			on a.AGREEMENT_TYPEID = r.agreement_typeid

GO
/****** Object:  View [dbo].[VWARNING]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VWARNING]
AS
SELECT     dbo.TWARNING.WARNINGID, dbo.TWARNING.WARNING, dbo.TWARNING.DESCRIPTION, dbo.TWARNING.OBJECTID, dbo.TWARNING.OBJECTTYPEID, 
                      dbo.TWARNING.OBJECTNAME, dbo.TWARNING.WARNINGDATE, dbo.TWARNING.ISACTIVE, dbo.TPERSON_IN_WARNING.PERSONID, 
                      dbo.TPERSON.DISPLAYNAME, dbo.TWARNING.RECURRINGSTART, dbo.TWARNING.RECURRENCEINTERVAL, dbo.TWARNING.RECURRINGNUMBER, 
                      dbo.TPERSON_IN_WARNING.EMAILWARNING, dbo.TPERSON.EMAIL, dbo.TOBJECTTYPE.FIXED AS OBJECTTYPE, 
                      dbo.TPERSON_IN_WARNING.INTERNALWARNING, dbo.TPERSON_IN_WARNING.ISTURNEDOFF, dbo.TWARNING.WARNINGFIELDDATE, 
                      dbo.TWARNING.WARNINGFIELDNAME, dbo.TWARNING.WARNINGFIELDDISPLAYNAME, dbo.TWARNING.USERID, 
                      dbo.TPERSON_IN_WARNING.TURNEDOFFDATE, DATEDIFF([DAY], dbo.TPERSON_IN_WARNING.TURNEDOFFDATE, GETDATE()) AS TURNEDOFFDAYS, 
                      dbo.TWARNINGTYPE.FIXED AS WARNINGTYPEFIXED, dbo.TWARNINGTYPE.WARNINGTYPEID, 
                      dbo.TOBJECTTYPE.OBJECTTYPE AS OBJECTTYPENAME
FROM         dbo.TPERSON INNER JOIN
                      dbo.TPERSON_IN_WARNING ON dbo.TPERSON.PERSONID = dbo.TPERSON_IN_WARNING.PERSONID INNER JOIN
                      dbo.TWARNING ON dbo.TPERSON_IN_WARNING.WARNINGID = dbo.TWARNING.WARNINGID INNER JOIN
                      dbo.TOBJECTTYPE ON dbo.TWARNING.OBJECTTYPEID = dbo.TOBJECTTYPE.OBJECTTYPEID INNER JOIN
                      dbo.TWARNINGTYPE ON dbo.TWARNING.WARNINGTYPEID = dbo.TWARNINGTYPE.WARNINGTYPEID

GO
/****** Object:  View [dbo].[V_TheCompany_TPERSON_IN_WARNING_GroupByWARNINGID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE View [dbo].[V_TheCompany_TPERSON_IN_WARNING_GroupByWARNINGID]

as

	SELECT 
		d.WARNINGID as WARNINGID_PIW

		, 	 convert(varchar(255), Replace(STUFF(
		(SELECT ',' + s.EMAIL
		FROM V_TheCompany_VUSER s inner join [TPERSON_IN_WARNING] sd on s.PERSONID = sd.PERSONID
		WHERE sd.warningid =d.WARNINGID
		FOR XML PATH('')),1,1,''),'&amp;','&'))
		 AS PersonEmail_List

		, Max([PERSON_IN_WARNINGID]) as PersonIDMax
		, Count(DISTINCT d.PERSONID) As PersonIDCount
	FROM  [dbo].[TPERSON_IN_WARNING] d inner join VWARNING w on d.WARNINGID = w.WARNINGID
	WHERE 
		/* w.WARNINGFIELDNAME = 'REVIEWDATE' AND  */
		w.TURNEDOFFDATE is null
		and d.PERSONID >0 /* dupes */
	GROUP BY d.WARNINGID

GO
/****** Object:  View [dbo].[V_TheCompany_REVIEWDATE_ACTIVE]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_REVIEWDATE_ACTIVE]

as

	SELECT 
		OBJECTID as 'RD_Contractid'
		, DATEADD(d,0,DATEADD(hh,1,MAX(WARNINGDATE))) as RD_ReviewDate_Warning /* MAX */
		, MAX(WARNINGID) as ReviewDate_WARNINGID_MAX
		, COUNT(DISTINCT WARNINGID) as ReviewDate_ActiveWarningID_Count
		, Max(P.personEmail_List) as ReviewDate_Reminder_RecipientList
	FROM VWARNING w inner join V_TheCompany_TPERSON_IN_WARNING_GroupByWARNINGID p on w.WARNINGID = P.WARNINGID_PIW
	WHERE 
		WARNINGFIELDNAME = 'REVIEWDATE' 
		AND TURNEDOFFDATE is null
	GROUP BY OBJECTID

GO
/****** Object:  View [dbo].[V_TheCompany_VEmployee]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[V_TheCompany_VEmployee]

AS

SELECT	U.USERID,
		U.USERINITIAL,
		U.PATHID,
		U.MIK_VALID AS USER_MIK_VALID,
		E.EMPLOYEEID,
		E.MIK_VALID AS EMPLOYEE_MIK_VALID,
		P.PERSONID,
		P.PERSONAL_CODE,
		P.TITLE,
		P.FIRSTNAME, /* is nvarchar(40) and stays that way in T_TheCompany_ALL */
		P.MIDDLENAME,
		P.LASTNAME, 
		P.INITIALS,
		P.DISPLAYNAME,
		P.EMAIL,
		P.COUNTRYID,
		UUG.USERGROUPID AS PRIMARYUSERGROUPID, 
		CAST(ISNULL(UG.USERGROUP ,'') AS VARCHAR(255)) AS PRIMARYUSERGROUP, /*otherwise it is nvarchar 450 which becomes a memo fld in Access */
		E.DEPARTMENTID,
		DEP.DEPARTMENT,
		dep.DEPARTMENT_CODE,
		U.ISEXTERNALUSER,
		U.DOMAINNETBIOSUSERNAME,
		LEFT(domainusername,CHARINDEX ('@', DOMAINUSERNAME)-1) as USERINITIAL_DOMAINUSERNAME,
		U.DOMAINUSERNAME,
		U.DOMAINUSERSID,
		U.UserProfileID,
		PF.UserProfile
		, (CASE WHEN pf.userprofile LIKE '%basic%' THEN 'Basic User' 
			WHEN pf.userprofile LIKE '%left%' THEN 'Has Left TheCompany'
			WHEN pf.USERPROFILE IS null then '' 
			ELSE 'Super User' END) as UserProfileGroup
		, (CASE WHEN pf.userprofile LIKE '%administrator%' THEN 'Administrator' 
			when pf.userprofile is null then ''
			ELSE 'Other' END) as UserProfileCategory

		,CASE
			WHEN (U.DOMAINUSERSID IS NOT NULL) AND (U.DOMAINUSERSID <> '') 
				THEN 'USER_INTERNAL_AD'
			WHEN U.ISEXTERNALUSER = 1 AND (
					SELECT	COUNT(*)
					  FROM	TCOMPANYCONTACT		CC
					 WHERE	CC.PersonID			= P.PersonID
					) > 1
				THEN 'USER_EXTERNAL_MULTICOMPANY'
			WHEN U.ISEXTERNALUSER = 1
				THEN 'USER_EXTERNAL'
			WHEN U.ISEXTERNALUSER = 0
				THEN 'USER_INTERNAL'
			ELSE	'USER_UNKNOWNCATEGORY'
		END AS USERCATEGORY
  FROM	
    dbo.TEMPLOYEE E
    left JOIN dbo.TPERSON				P on e.PERSONID = p.personid
	left join dbo.TUSER				U on e.employeeid = u.employeeid

  left JOIN	dbo.TUSER_IN_USERGROUP	UUG
	ON	UUG.USERID				= U.USERID
   AND	UUG.PRIMARYGROUP		= 1
  LEFT	OUTER
  JOIN	dbo.TUSERGROUP			UG
	ON	UG.USERGROUPID			= UUG.USERGROUPID
  LEFT	OUTER
  JOIN	dbo.TDEPARTMENT			DEP
	ON	E.DEPARTMENTID			= DEP.DEPARTMENTID
	LEFT	OUTER
   JOIN	dbo.TUserProfile		PF
	ON	U.UserProfileID			= PF.UserProfileID

GO
/****** Object:  View [dbo].[VCOMPANYADDRESS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VCOMPANYADDRESS]
AS
SELECT [DBO].[TCOMPANYADDRESS].[COMPANYADDRESSID],
       [DBO].[TCOMPANYADDRESS].[ADDRESSTYPEID],
       [DBO].[TCOMPANYADDRESS].[COMPANYID],
       [DBO].[TCOMPANYADDRESS].[ADDRESSLINE1],
       [DBO].[TCOMPANYADDRESS].[ADDRESSLINE2],
       [DBO].[TCOMPANYADDRESS].[ADDRESSLINE3],
       [DBO].[TCOMPANYADDRESS].[ADDRESSLINE4],
       [DBO].[TCOMPANYADDRESS].[ADDRESSLINE5],
       [DBO].[TCOMPANYADDRESS].[PHONE],
       [DBO].[TCOMPANYADDRESS].[FAX],
       [DBO].[TCOMPANYADDRESS].[WWW],
       [DBO].[TCOMPANYADDRESS].[EMAIL],
       [DBO].[TCOMPANYADDRESS].[COUNTRYID],
       [DBO].[TCOMPANYADDRESS].[MIK_DEFAULT] COMPANYADDRESSMIKDEFAULT,
       [DBO].[TCOMPANY].[COMPANY],
       [DBO].[TADDRESSTYPE].[ADDRESSTYPE],
       [DBO].[TADDRESSTYPE].[DESCRIPTION],
       [DBO].[TADDRESSTYPE].[FIXED] ADDRESSTYPEFIXED,
       [DBO].[TADDRESSTYPE].[MIK_DEFAULT] ADDRESSTYPEMIKDEFAULT,
       [DBO].[TADDRESSTYPE].[MIK_SEQUENCE] ADDRESSTYPEMIKSEQUENCE,
       [DBO].[TADDRESSTYPE].[MIK_VALID] ADDRESSTYPEMIKVALID,
       [DBO].[TCOUNTRY].[COUNTRY]
  FROM [DBO].[TCOMPANYADDRESS] INNER JOIN [DBO].[TADDRESSTYPE] ON ([DBO].[TCOMPANYADDRESS].[ADDRESSTYPEID] =
                                                                                          [DBO].[TADDRESSTYPE].[ADDRESSTYPEID]
                                                                                      )
       INNER JOIN [DBO].[TCOMPANY] ON ([DBO].[TCOMPANYADDRESS].[COMPANYID] =
                                                    [DBO].[TCOMPANY].[COMPANYID]
                                                )
       LEFT OUTER JOIN [DBO].[TCOUNTRY] ON ([DBO].[TCOMPANYADDRESS].[COUNTRYID] =
                                                         [DBO].[TCOUNTRY].[COUNTRYID]
                                                     )


GO
/****** Object:  View [dbo].[V_TheCompany_TTENDERER_FLAT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_TTENDERER_FLAT]

as

	SELECT
		CONTRACTID

		, (select (case when max(expirydate) is not null then MAX(Expirydate) 
						when max(EXPIRYDATE) is null then MAX(startdate)
			else null end)
			 from TCONTRACT 			 
			 where CONTRACTID = d.contractid
			  ) as CompanyActivityDateMax
		/* PDF */
		,COUNT(d.COMPANYID) AS CompanyCount

		, CAST( Replace(STUFF(
		(SELECT ';' + c.COMPANY + ' (' + c.COUNTRY + ')'
		FROM TTENDERER s inner join [VCOMPANYADDRESS] c on s.COMPANYID = c.COMPANYID 
		WHERE s.CONTRACTID =d.CONTRACTID and c.addresstypeid = 1 /* primary postal address, unique record */
		FOR XML PATH('')),1,1,''),'&amp;','&') as varchar(255))
		 AS CompanyCountryList

		,  CAST(  Replace(STUFF(
		(SELECT ';' + c.COMPANY 
		FROM TTENDERER s inner join [TCOMPANY] c on s.COMPANYID = c.COMPANYID 
		WHERE s.CONTRACTID =d.CONTRACTID 
		FOR XML PATH('')),1,1,''),'&amp;','&') as varchar(255))
		 AS CompanyList

		,  CAST( STUFF(
		(SELECT DISTINCT ';' + COUNTRY
		FROM TTENDERER s inner join [VCOMPANYADDRESS] c 
			on s.COMPANYID = c.COMPANYID 
			and c.countryid is not null
		WHERE s.CONTRACTID =d.CONTRACTID 
		FOR XML PATH('')),1,1,'') as varchar(255))
		 AS CountryList

		,
		(SELECT DISTINCT max((case /* US is Max to non-US */
			when countryid = 14 /* united states */ then 'US' 
			ELSE 'Non-US' 
			END))
		FROM TTENDERER s 
			inner join [VCOMPANYADDRESS] a 
				on s.COMPANYID = a.COMPANYID 
					/* and a.countryid = 14 */
		WHERE s.CONTRACTID =d.CONTRACTID ) AS CompanyCountry_IsUS

		, CAST( STUFF(
		(SELECT ';' + Convert(nvarchar(10),c.COMPANYID)
		FROM TTENDERER s, TCOMPANY c
		WHERE s.CONTRACTID =d.CONTRACTID and s.COMPANYID = c.COMPANYID  
		order by s.companyid /* so that intercompany is always 1 or 1; */
		FOR XML PATH('')),1,1,'') as varchar(255))
		 AS CompanyIDList

		,(SELECT count(c.COMPANYID)
		FROM TTENDERER s, TCOMPANY c
		WHERE s.CONTRACTID =d.CONTRACTID and s.COMPANYID = c.COMPANYID AND s.ISAWARDED=1) 
		AS CompanyIDAwardedCount

		,(SELECT count(c.COMPANYID)
		FROM TTENDERER s, TCOMPANY c
		WHERE s.CONTRACTID =d.CONTRACTID and s.COMPANYID = c.COMPANYID AND s.ISAWARDED=0) 
		AS CompanyIDUnawardedCount

		,(SELECT count(c.COMPANYID)
		FROM TTENDERER s, TCOMPANY c
		WHERE s.CONTRACTID =d.CONTRACTID and s.COMPANYID = c.COMPANYID) 
		AS CompanyIDCount


	FROM  TTENDERER d 
		/* inner join TCOMPANY c 
			on d.COMPANYID = c.companyid 
			DUPES !!!!!*/
	GROUP BY CONTRACTID


GO
/****** Object:  View [dbo].[V_TheCompany_VPRODUCTS_FLAT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_VPRODUCTS_FLAT]

as

SELECT
CONTRACTID AS VP_Contractid

/* ALL Product Group Names*/
, CAST( left(Replace(STUFF( /* cast * no perf. impact */
(SELECT ',' + s.PRODUCTGROUP
FROM VPRODUCTGROUPS_IN_CONTRACT s
WHERE s.CONTRACTID =d.CONTRACTID 
FOR XML PATH('')),1,1,''),'&amp;','&'),255) as varchar(255))
 AS VP_ProductGroups

/* ALL IDs */
, CAST( left(STUFF(
(SELECT ',' + Convert(nvarchar(10),s.PRODUCTGROUPID)
FROM VPRODUCTGROUPS_IN_CONTRACT s
WHERE s.CONTRACTID =d.CONTRACTID 
FOR XML PATH('')),1,1,''),255) as varchar(255))
 AS VP_ProductGroups_IDs

,(SELECT COUNT(s.PRODUCTGROUPID)
FROM VPRODUCTGROUPS_IN_CONTRACT s
WHERE s.CONTRACTID = d.CONTRACTID 
GROUP BY s.CONTRACTID) AS VP_ProductGroups_COUNT

/* ACTIVE INGREDIENTS */
, CAST( Replace(left(STUFF(
(SELECT ',' + s.PRODUCTGROUP
FROM VPRODUCTGROUPS_IN_CONTRACT s
WHERE s.CONTRACTID =d.CONTRACTID AND s.PRODUCTGROUPNOMENCLATUREID = 2
FOR XML PATH('')),1,1,''),255),'&amp;','&') as varchar(255))
 AS VP_ActiveIngredients

/* TRADE NAMES */
,CAST( left(Replace(STUFF(
(SELECT ',' + s.PRODUCTGROUP
FROM VPRODUCTGROUPS_IN_CONTRACT s
WHERE s.CONTRACTID =d.CONTRACTID AND s.PRODUCTGROUPNOMENCLATUREID = 3
FOR XML PATH('')),1,1,''),'&amp;','&'),255) as varchar(255))
 AS VP_TradeNames

/* DIRECT PROCUREMENT */
, CAST( Replace(left(STUFF(
(SELECT ',' + s.PRODUCTGROUP
FROM VPRODUCTGROUPS_IN_CONTRACT s
WHERE s.CONTRACTID =d.CONTRACTID AND s.PRODUCTGROUPNOMENCLATUREID = 4
FOR XML PATH('')),1,1,''),255),'&amp;','&') as varchar(255))
 AS VP_DirectProcurement

/* INDIRECT PROCUREMENT */
,CAST(  left(Replace(STUFF(
(SELECT ',' + s.PRODUCTGROUP
FROM VPRODUCTGROUPS_IN_CONTRACT s
WHERE s.CONTRACTID =d.CONTRACTID AND s.PRODUCTGROUPNOMENCLATUREID = 5
FOR XML PATH('')),1,1,''),'&amp;','&'),255) as varchar(255))
 AS VP_IndirectProcurement

FROM  VPRODUCTGROUPS_IN_CONTRACT d
/* where PRODUCTGROUP like '%&%' */
GROUP BY CONTRACTID

GO
/****** Object:  View [dbo].[V_TheCompany_Docs_FLAT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[V_TheCompany_Docs_FLAT]

as
/* Unique Contract IDs.... */
	SELECT

		OBJECTID AS CONTRACTID

		, COUNT(DOCUMENTID) AS COUNT_ALL

		, COUNT(CASE WHEN DOCUMENTTYPEID IN(139,135,134,115,1) /*SIGNED CONTRACTS*/ 
			THEN DOCUMENTID ELSE NULL END) AS COUNT_FOLDER_SIGNED

		, COUNT(CASE WHEN DOCUMENTTYPEID NOT IN(139,135,134,115,1) /*SIGNED CONTRACTS*/ 
			THEN DOCUMENTID ELSE NULL END) AS COUNT_FOLDER_OTHER

		/* PDF */
		,COUNT
		(CASE WHEN FileType='.pdf' THEN DOCUMENTID END) AS FileTypePDFCount

		/*TIF */
		,COUNT
		(CASE WHEN FileType in('.tif','.tiff') THEN DOCUMENTID END) AS FileTypeTIFCount

		/*EMAIL */
		, COUNT
		(CASE WHEN FileType in('.msg') THEN DOCUMENTID END) AS FileTypeMsgCount

		/* Doc Names Concat */
		, convert(varchar(255), LTRIM((case when LEN(STUFF(
			(SELECT '; ' + f.title + f.FileType
			FROM VDOCUMENT f
			WHERE f.OBJECTID =d.OBJECTID
			FOR XML PATH('')),1,1,''))<= 255
			THEN 
					STUFF(
				(SELECT '; ' + f.title 
				FROM VDocument f
				WHERE f.OBJECTID =d.OBJECTID
				FOR XML PATH('')),1,1,'')
			ELSE 
			SUBSTRING(STUFF(
				(SELECT '; ' + f.title 
				FROM VDOCUMENT f
				WHERE f.OBJECTID =d.OBJECTID
				FOR XML PATH('')),1,1,''),1,251) + ' ...'
			END
			)))
			 AS DocTitlesConcatWithTS_255

		/* Doc Names Concat AND file type */
		,  convert(varchar(255), LTRIM((case when LEN(STUFF(
			(SELECT '; ' + f.title + isnull(f.FileType,'')
			FROM VDOCUMENT f
			WHERE f.OBJECTID =d.OBJECTID
			FOR XML PATH('')),1,1,''))<= 255
			THEN 
					STUFF(
				(SELECT '; ' + f.title + isnull(f.FileType,'')
				FROM VDOCUMENT f
				WHERE f.OBJECTID =d.OBJECTID
				FOR XML PATH('')),1,1,'')
			ELSE 
			SUBSTRING(STUFF(
				(SELECT '; ' + f.title + isnull(f.FileType,'')
				FROM VDOCUMENT f
				WHERE f.OBJECTID =d.OBJECTID
				FOR XML PATH('')),1,1,''),1,251) + ' ...'
			END
			)))
			 AS DocTitlesFileTypeConcatWithTS_255

		/* Doc Names Concat AND file type */
			,  convert(varchar(255), LTRIM((case when LEN(STUFF(
				(SELECT '; ' + f.[DocumentTitle_TS_Redacted] + isnull(f.FileType,'')
				FROM V_TheCompany_VDocument f
				WHERE f.CONTRACTID = d.OBJECTID
				FOR XML PATH('')),1,1,''))<= 255
				THEN 
						STUFF(
					(SELECT '; ' + f.[DocumentTitle_TS_Redacted] + isnull(f.FileType,'')
					FROM V_TheCompany_VDocument f
					WHERE f.CONTRACTID = d.OBJECTID
					FOR XML PATH('')),1,1,'')
				ELSE 
				SUBSTRING(STUFF(
					(SELECT '; ' + f.[DocumentTitle_TS_Redacted]  + isnull(f.FileType,'')
					FROM V_TheCompany_VDocument f
					WHERE f.CONTRACTID = d.OBJECTID
					FOR XML PATH('')),1,1,''),1,251) + ' ...'
				END
				)))
				 AS DocTitlesFileTypeConcatTSRedacted_255
	FROM  VDOCUMENT d
	WHERE MIK_VALID = 1
	/*and objectid = '107762'*/
	GROUP BY OBJECTID

GO
/****** Object:  View [dbo].[VCONTRACT_LUMPSUM]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VCONTRACT_LUMPSUM]
AS
SELECT     dbo.TAMOUNT.Amount AS LUMPSUM, dbo.TAMOUNT.ExchangeDate AS LUMPSUM_EXDATE, dbo.TAMOUNT.CurrencyId AS LUMPSUM_CURRID, 
                      dbo.TCURRENCY.CURRENCY_CODE AS LUMPSUM_CURRCODE, dbo.TCURRENCY.CURRENCY_SYMBOL AS LUMPSUM_CURRSYM, 
                      dbo.TCONTRACT.LumpSumAmountID AS LUMPSUMAMOUNTID
FROM         dbo.TAMOUNT INNER JOIN
                      dbo.TCURRENCY ON dbo.TAMOUNT.CurrencyId = dbo.TCURRENCY.CURRENCYID INNER JOIN
                      dbo.TCONTRACT ON dbo.TAMOUNT.AmountId = dbo.TCONTRACT.LumpSumAmountID



GO
/****** Object:  View [dbo].[V_TheCompany_ALL_BAK]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[V_TheCompany_ALL_BAK]

as

SELECT 
	c.[Number]
      ,c.[CONTRACTID]
      ,(case when c.[Title] like '%TOP SECRET%' THEN '*** TOP SECRET ***' ELSE c.[Title] END) as Title
	,c.[Title] as Title_InclTopSecret
      ,c.[CONTRACTTYPE]
      ,c.[CONTRACTTYPEID]
		, (CASE WHEN cr.AgrType_Top25Flag =1 THEN c.AGREEMENT_TYPE ELSE 'Other' END) 
	  as Agreement_Type_Top25WithOther
      , cr.AgrType_Top25Flag as Agreement_Type_Top25Flag
      , c.[REFERENCENUMBER]
      , CONTRACTDATE
      /* , CONVERT(VARCHAR(11), c.CONTRACTDATE,106) as CONTRACTDATE_Char */
      /*, (CONVERT(VARCHAR(7), c.[CONTRACTDATE]), 120)) as RegisteredDate_YYYY_MM*/
      /* , TO_CHAR(c.[CONTRACTDATE], 'YYYY-MM') as RegisteredDate_YYYY_MM */
      , convert(varchar(7), CONTRACTDATE, 121) as RegisteredDate_YYYY_MM
      , (CASE 
			WHEN DATEDIFF(mm,c.contractdate,GetDate()) <=3 THEN '0-3 Months'
			WHEN DATEDIFF(mm,c.contractdate,GetDate()) Between 4 and 11 THEN '04-11 Months'
			WHEN DATEDIFF(mm,c.contractdate,GetDate()) Between 12 and 36 THEN '12-36 Months'
			WHEN DATEDIFF(mm,c.contractdate,GetDate()) > 36 THEN '36+ Months'
		END) as RegisteredDateNumMthCat
      , /* CONVERT(VARCHAR(11), */ c.[AWARDDATE] /*,106) as AWARDDATE */
      , /* CONVERT(VARCHAR(11), */ c.[STARTDATE] /*,106) as STARTDATE */
      , /* CONVERT(VARCHAR(11), */ c.[EXPIRYDATE] /*,106) as EXPIRYDATE */
      , /* CONVERT(VARCHAR(11), */ c.[REV_EXPIRYDATE] /*,106) as REV_EXPIRYDATE */
      , /* CONVERT(VARCHAR(11), */ c.[FINAL_EXPIRYDATE] /*,106) as FINAL_EXPIRYDATE */
      , /* CONVERT(VARCHAR(11), */ c.[REVIEWDATE] /*,106) as REVIEWDATE */
      , /* CONVERT(VARCHAR(11), */ rd.RD_ReviewDate_Warning /*,106) as RD_ReviewDate_Warning */
      , /* CONVERT(VARCHAR(11), */ c.[CHECKEDOUTDATE] /*,106) as CHECKEDOUTDATE */
      ,c.[DEFINEDENDDATE]
      ,c.[STATUS]
      ,c.[ContractRelations]
      /*,c.[EDIT_STARTDATE_BLANK]
      ,c.[EDIT_EXPIRYDATE_BLANK]
      ,c.[EDIT_REV_EXPIRYDATE_BLANK]
      ,c.[EDIT_FINAL_EXPIRYDATE_BLANK]
      ,c.[EDIT_REVIEWDATE_BLANK]
      ,c.[EDIT_NO_ENDDATE_OR_REMINDER]
      ,c.[EDIT_NO_PDF_ATTACHMENTS]
      ,c.[EDIT_NO_COMPANYID]
      ,c.[EDIT_VCONTRACT_FLAG]*/
      ,c.[NUMBEROFFILES]
      ,c.[EXECUTORID]
      ,c.[OWNERID]
      ,c.[TECHCOORDINATORID]
      ,c.[STATUSID]
      ,c.[StatusFixed]
      ,c.[REFERENCECONTRACTNUMBER]
      ,c.[COUNTERPARTYNUMBER]
      ,c.[AGREEMENT_TYPE]
      ,c.[AGREEMENT_TYPEID]
      ,c.[AGREEMENT_FIXED]
	  ,c.[STRATEGYTYPE] /* AS AGREEMENT_SUBTYPE HCP HCO */
      /* all Contract view items have their ISNULL in the source query */

	  ,CAST(ISNULL(t.[CompanyList],'') AS VARCHAR(255)) AS 'CompanyList' /* otherwise it is not available as a filter field in BO due to being long text */
      ,t.CompanyIDList
      ,t.[CompanyIDAwardedCount]
      ,t.[CompanyIDUnawardedCount]
      ,t.CompanyIDCount

      , (select [MIK_EDIT_VALUE] 
		FROM [TEXTRA_FIELD_IN_CONTRACT] ef
		WHERE [EXTRA_FIELDID] = 100002 /* Confidentiality Flag */
		AND ef.contractid = c.contractid) as ConfidentialityFlag /* heading field replaced, empty string '' field was deleted as of V6.15, no replacement */
      
/* User Roles */
      , us.*
      , uo.*
      , ur.*
            
/* Department Roles */
		
	, CAST(ISNULL(d.[Dpt_SuperUserDpt],'') AS VARCHAR(255)) AS 'Dpt_Name_US' /* nvarchar 4000 for some reason */
      ,ISNULL(d.[Dpt_SuperUserDpt_ID],'') AS 'Dpt_ID_US'
      ,ISNULL(d.[Dpt_SuperUserDpt_Code],'') AS 'Dpt_Code_US'
   /*
      ,ISNULL(d.[Dpt_ContractOwner],'') AS 'Dpt_Name_UO'
      ,ISNULL(d.[Dpt_ContractOwnerDpt_ID],'') AS 'Dpt_ID_UO'
      ,ISNULL(d.[Dpt_ContractOwnerDpt_Code],'') AS 'Dpt_Code_UO'
    
      ,ISNULL(d.[Dpt_ContractResponsible],'') AS 'Dpt_Name_UR'
      ,ISNULL(d.[Dpt_ContractResponsibleDpt_ID],'') AS 'Dpt_ID_UR' 
      ,ISNULL(d.[Dpt_ContractOwnerDpt_Code],'') AS 'Dpt_Code_UR' 

     */ 
	 ,CAST(ISNULL(d.[InternalPartners],'') AS VARCHAR(255)) AS 'InternalPartners'
      /* ,ISNULL(d.[InternalPartners],'') AS 'InternalPartners' */
      ,ISNULL(d.[InternalPartners_IDs],'') AS 'InternalPartners_IDs'
      ,ISNULL(d.[InternalPartners_COUNT],0) AS 'InternalPartners_COUNT'
      ,CAST(ISNULL(d.[Territories],'') AS VARCHAR(255)) AS 'Territories' /* LEN capped at 255 in concat statement but turns into varchar(4000) in T_TheCompany_ALL */
      ,CAST(ISNULL(d.[Territories_IDs],'') AS VARCHAR(255)) AS 'Territories_IDs' /* becomes varchar(max), max len is around 400 odd char */
      ,ISNULL(d.[Territories_COUNT],0) AS 'Territories_COUNT'

/* Products */
      ,CAST(ISNULL(p.[VP_ProductGroups],'') AS VARCHAR(255)) AS 'VP_ProductGroups'
      ,CAST(ISNULL(p.[VP_ProductGroups_IDs],'') AS VARCHAR(255)) AS 'VP_ProductGroups_IDs'
      ,ISNULL(p.[VP_ProductGroups_COUNT],0) AS 'VP_ProductGroups_COUNT'
      ,CAST([VP_ActiveIngredients] AS VARCHAR(255)) AS [VP_ActiveIngredients]
      ,CAST([VP_TradeNames] AS VARCHAR(255)) AS [VP_TradeNames]
      ,CAST([VP_DirectProcurement] AS VARCHAR(255)) AS [VP_DirectProcurement]
      ,CAST([VP_IndirectProcurement] AS VARCHAR(255)) AS [VP_IndirectProcurement] /* mark entries where this is longer than 255 char?*/
      
/* Commercial - Lump Sum */
      , ISNULL(vc.LumpSum,0) as LumpSum
      , ISNULL(vc.LUMPSUM_CURRCODE,0) as LumpSumCurrency
/* HIERARCHY */
      /* , h.* */
      , ISNULL(h.[REGION],'Other') as Region
      ,h.[DEPARTMENTID]
      ,h.[LEVEL]
      ,ISNULL(h.[L0],'No Department entered') as L0
      ,CAST(h.[L1] as varchar(25)) as L1
      ,CAST(h.[L2] as varchar(25)) as L2
      ,CAST(h.[L3] as varchar(25)) as L3
      ,CAST(h.[L4] as varchar(25)) as L4
      ,CAST(h.[L5] as varchar(25)) as L5
      ,CAST(h.[L6] as varchar(25)) as L6
      ,CAST(h.[L7] as varchar(25)) as L7
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
      , 'http://des80040.nycomed.local/ccs/builtin_modules/Contract.aspx?id=' + CONVERT(VARCHAR(10),c.contractid) as LinkToContractURL

	  /* Procurement Base Flag 1 for Agreement type, is needed as a basis for V_TheCompany_Mig_0ProcNetFlag (based on T_TheCompany_ALL) */
	, (CASE 
				WHEN COUNTERPARTYNUMBER like '%!ARIBA_W01%' 
					 OR COUNTERPARTYNUMBER like '%!ARIBA_W02%' THEN 9 /* already migrated to Ariba */
				WHEN CompanyIDList = '1' /* intercompany */ THEN 4 /* Intercompany agreements always attributed to Legal no matter which other properties */
				WHEN title like '%GxP%' THEN 6 /* Gxp is also LEGAL, manually review */
				/* WHEN AgrType_IsHCX_Flag = 0 /* HCP/HCO */ THEN 0 /* Legal = non-HCP/HCO */ 
				  WHEN AgrType_IsHCX_Flag = 1 /* HCP/HCO */ THEN 1 /* Ariba = hcP/HCO */ */

				/*WHEN cr.[TargetSystem_AgTypeFLAG]  IN (
							 1 /* Ariba */
							,2 /* Split Type */
							,3 /* department */) THEN cr.[TargetSystem_AgTypeFLAG]	/*(0, 1,2,3,5,7,8)	*/			
				
				*/
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
	, convert(varchar(255),rd.[ReviewDate_Reminder_RecipientList]) as ReviewDate_Reminder_RecipientList /* nvarchar max */

	, CAST(t.CompanyCountryList as varchar(255)) as CompanyCountryList
	, CAST(t.[CompanyCountry_IsUS] as varchar(7)) as CompanyCountry_IsUS
	, t.CompanyActivityDateMax
	, convert(varchar(255),left(c.COMMENTS,255)) as Comments /* if not truncated: nvarchar 2000 */
	, CAST(doc.[DocTitlesFileTypeConcatTSRedacted_255] as varchar(255))  as DocumentFileTitlesConcat /* Redacted */
	 , CAST(ISNULL(d.[InternalPartners_DptCodeList],'') AS VARCHAR(255)) AS InternalPartners_DptCodeList
	 , [TERMINATIONPERIOD]
	, convert(varchar(255),left([TERMINATIONCONDITIONS],255)) as TERMINATIONCONDITIONS /* nvarchar 512 */
	, REFERENCECONTRACTID

	/*, cr.[Agr_IsMaterial_Flag]
	, cr.[Agr_IsDivestment_Flag]v
	, cr.[AgrIsDivestment] */
	, cr.Agr_IsMaterial_Flag
	, cr.AgrIsMaterial
FROM 
/* V_TheCompany_VCONTRACT */
/* this view turns TCONTRACT nulls into empty strings etc., custom version of VCONTRACT */
/* fields like agreement_type etc  */
	V_TheCompany_VCONTRACT c 
	left join (SELECT userid as US_Userid
	, displayname as US_DisplayName
	, EMAIL as US_Email, FIRSTNAME as US_Firstname
	, PRIMARYUSERGROUP as US_PrimaryUserGroup /* field size in TUSERGROUP is 450 char */
	, USER_MIK_VALID US_USER_MIK_VALID 
	, DEPARTMENT_CODE as US_DPT_CODE
	, DEPARTMENT as US_DPT_NAME
	 from [V_TheCompany_VUSER]) us on c.executorid = us.us_userid

	left join (SELECT EMPLOYEEID as UO_employeeid
	, displayname as UO_DisplayName
	, EMAIL as UO_Email
	, FIRSTNAME as UO_Firstname
	, PRIMARYUSERGROUP as UO_PrimaryUserGroup /* field size in TUSERGROUP is 450 char */
	, USER_MIK_VALID as UO_USER_MIK_VALID 
	, DEPARTMENT_CODE as UO_DPT_CODE
	, DEPARTMENT as UO_DPT_NAME
	  FROM V_TheCompany_VEmployee) uo on c.ownerid = uo.UO_employeeid

	left join (SELECT employeeid as UR_employeeid
	, displayname as UR_DisplayName
	, EMAIL as UR_Email
	, FIRSTNAME as UR_Firstname
	, PRIMARYUSERGROUP as UR_PrimaryUserGroup /* field size in TUSERGROUP is 450 char */
	, USER_MIK_VALID as UR_USER_MIK_VALID 
	, DEPARTMENT_CODE as UR_DPT_CODE 
	, DEPARTMENT as UR_DPT_NAME
	  FROM V_TheCompany_VEmployee) ur on c.techcoordinatorid = ur.UR_employeeid

	left join [dbo].[V_TheCompany_VCONTRACT_DPTROLES_FLAT] d on c.contractid = d.Dpt_contractid
	left join [dbo].[V_TheCompany_VPRODUCTS_FLAT] p on c.contractid = p.vp_contractid
	/* left join dbo.VCOMMERCIAL vc on c.CONTRACTID = vc.ContractId */
	left join dbo.VCONTRACT_LUMPSUM vc on c.LUMPSUMAMOUNTID = vc.LUMPSUMAMOUNTID
	left join dbo.T_TheCompany_Hierarchy h /* 07-feb-19 instead of dbo.v_TheCompany_Hierarchy_maketable to improve performance */
		/* in the daily data load, the hierarchy is refreshed first, so this table is up to date */
		on d.Dpt_ContractOwnerDpt_ID = h.departmentid_link
	left join [dbo].[V_TheCompany_REVIEWDATE_ACTIVE] rd on c.contractid = rd.RD_Contractid
	left join V_TheCompany_AgreementType cr 
		on c.AGREEMENT_TYPEID = cr.[AgrTypeID]
	left join V_TheCompany_TTENDERER_FLAT t on c.contractid = t.CONTRACTID
	/* NOT working because t_TheCompany_all is used in view left join V_TheCompany_Mig_0ProcNetFlag m on c.contractid = m.Contractid_Proc /* for procurement flag */*/
	left join [dbo].[V_TheCompany_Docs_FLAT] doc on c.contractid = doc.CONTRACTID /* added 09-Dec-2020 */
	WHERE c.contracttypeid NOT IN (	  5 /* Test Old */
									, 6 /* Access SAKSNR number Series*/		
									/*,  11	Case */					
									, 13 /* DELETE */
									, 102 /* Test New */								
									, 103, 104, 105 /* Lists */
									, 106 /* AutoDelete */
									)
  /* and c.CONTRACTID = 148186 /* contractnumber = 'TEST-00000080' */*/
  
GO
/****** Object:  View [dbo].[V_TheCompany_TPRODUCT_ACTIVEINGREDIENT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_TPRODUCT_ACTIVEINGREDIENT]

as

	select 
		p.*
		, ga.productgroup as AI 
		, gp.PRODUCTGROUP as TN
		, gp.PARENTID as PARENTID_TN
		, gpp.PRODUCTGROUP as PARENT_PRODUCTGROUP
	FROM
		T_TheCompany_TPRODUCT_ACTIVEINGREDIENT p 
		inner join TPRODUCTGROUP ga on p.PRODUCTGROUPID_AI = ga.PRODUCTGROUPID and ga.PRODUCTGROUPNOMENCLATUREID = 2 /* AI */
		inner join TPRODUCTGROUP gp on p.PRODUCTGROUPID_TN = gp.PRODUCTGROUPID and gp.PRODUCTGROUPNOMENCLATUREID = 3 /* TN */
		left join TPRODUCTGROUP gpp 
			on gp.PARENTID = gpp.PRODUCTGROUPID 
				and gp.PRODUCTGROUPNOMENCLATUREID in (2,3) /* TN */
				and gpp.PRODUCTGROUP not like gp.PRODUCTGROUP + '%' /* Pantoprazol / Pantoprazole */
GO
/****** Object:  View [dbo].[V_TheCompany_KWS_00_Input_WithSubProducts]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE View [dbo].[V_TheCompany_KWS_00_Input_WithSubProducts]

as

		select * 
		from T_TheCompany_KeyWordSearch_INPUT

	union all

	/* Parent */
		select  
			pp.productgroup, 'Product','' /* [KeyWordVarchar255] */
			,'Product Hierarchy (' + p.PRODUCTGROUP + ')' /* KeyWordSource */
			,''											/* KeyWordSearchTag */
			,'' /* Custom 1 */
			,''											/* Custom 2 */
			,'' /* precision */
			,'' /* FILTER OR SHOW */
		from TPRODUCTGROUP p inner join T_TheCompany_KeyWordSearch_INPUT i 
			on upper(p.PRODUCTGROUP) = upper(i.KeyWordVarchar255)
			inner join TPRODUCTGROUP pp on pp.PARENTID = p.PRODUCTGROUPID
		where i.KeyWordType = 'Product'
		and pp.PRODUCTGROUP  not like i.KeyWordVarchar255 +'%'    /* only higher level, not lower, e.g. Abalgin, Abalgin Retard */
		/* and p.PRODUCTGROUP filter out wrong sub products calcium and sub etc. or better just remove subprod */
	
	UNION ALL
	/* TN contains AI */
		select 
			p.AI, 'Product','' /* [KeyWordVarchar255] */
			,'Product and AI (' + p.TN  + ' contains AI ' + p.AI + ')' /* KeyWordSource */
			,'' /* KeyWordSearchTag */
			,'' /* Custom 1 */
			,'' /* Custom 2 */
			,'' /* precision */
			,'' /* FILTER OR SHOW */
		from V_TheCompany_TPRODUCT_ACTIVEINGREDIENT p inner join T_TheCompany_KeyWordSearch_INPUT i 
			on upper(p.TN) = upper(i.KeyWordVarchar255)
			/* inner join TPRODUCTGROUP pp on pp.PARENTID = p.PRODUCTGROUPID_TN */
		where i.KeyWordType = 'Product'
	
	UNION ALL
	/* AI is only ingredient in TN */
		select 
			p.TN, 'Product','' /* [KeyWordVarchar255] */
			,'Product and AI (' + p.AI  + ' is main AI in ' + p.TN + ')' /* KeyWordSource */
			,'' /* KeyWordSearchTag */
			,'' /* Custom 1 */
			,'' /* Custom 2 */
			,'' /* precision */
			,'' /* FILTER OR SHOW */
		from V_TheCompany_TPRODUCT_ACTIVEINGREDIENT p inner join T_TheCompany_KeyWordSearch_INPUT i 
			on upper(p.AI) = upper(i.KeyWordVarchar255)
			/* inner join TPRODUCTGROUP pp on pp.PARENTID = p.PRODUCTGROUPID_TN */
		where i.KeyWordType = 'Product' and p.IsUniqueAI = 1 /* Unique AI */
		and upper(p.tn) not in (select upper(keywordvarchar255) from  T_TheCompany_KeyWordSearch_INPUT ) /* not already listed */

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_01_Input_Raw]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/****** Object:  View [dbo].[V_TheCompany_KeyWordSearch_0Input]    Script Date: 03.07.2019 14:04:51 ******/
CREATE view [dbo].[V_TheCompany_KWS_01_Input_Raw]

/* 
[dbo].[TheCompany_KeyWordSearch]
- elminiate double spaces
- ltrim, rtrim
*/
as

	select 
		[KeyWordVarchar255]
		, count([KeyWordVarchar255]) as KeyWordVarchar255Count /* if same keyword appears more than once */
		, [KeyWordType]
		, [KeyWordPrecision]
		, [KeyWordOperator]
		, max([KeyWordTypeID]) as [KeyWordTypeID]
		, MAX([KeyWordSource]) as [KeyWordSource] /* e.g. Scotch_2019_08_12 */
		, MAX([KeyWordSearchTag]) AS [KeyWordSearchTag]

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + gg.[KeyWordCustom1]
			FROM [dbo].[T_TheCompany_KeyWordSearch_Input] gg
			where gg.KeyWordVarchar255 = i.KeyWordVarchar255
			and gg.[KeyWordCustom1] is not null
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordCustom1 /* make sure to refresh T_TheCompany_KeyWordSearch_Results_Description_ContractID */

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + gg.[KeyWordCustom2]
			FROM [dbo].[T_TheCompany_KeyWordSearch_Input] gg
			where gg.KeyWordVarchar255 = i.KeyWordVarchar255
			and gg.[KeyWordCustom2] is not null
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordCustom2 /* make sure to refresh T_TheCompany_KeyWordSearch_Results_Description_ContractID */

		, UPPER(dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([KeyWordVarchar255]))
		as KeyWordLettersNumbersOnly_UPPER

		, UPPER(replace(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([KeyWordVarchar255]),'  ',' '))
		as KeyWordLettersNumbersSpacesOnly_UPPER /* e.g. Hansen & Rosenthal */

		, LEN(replace(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([KeyWordVarchar255]),'  ',' '))
			-LEN(dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([KeyWordVarchar255])) 
			as KeyWord_LettersNumbersOnly_NumSpacesWords

	from V_TheCompany_KWS_00_Input_WithSubProducts /*T_TheCompany_KeyWordSearch_Input */ i
	group by [KeyWordVarchar255], [KeyWordType],[KeyWordPrecision], [KeyWordOperator]

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_02_Input_AllFields]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[V_TheCompany_KWS_02_Input_AllFields]

as

	SELECT
		* 
		, UPPER([KeyWordLettersNumbersSpacesOnly_UPPER]) as KeyWordVarchar255_UPPER
	/*	, [KeyWordLettersNumbersOnly_UPPER] as KeyWordLettersNumbersOnly_UPPER /* leave numbers since companies can start with number like 3M */*/
		,'' as KeywordCategory
		, len([KeyWordVarchar255]) as KeyWordLength /* maybe better use [KeyWordLettersNumbersSpacesOnly_UPPER]?*/
		
			, (CASE WHEN 
			 (SELECT count(Kwe_Name) FROM [dbo].[T_TheCompany_KW_ExclusionList] 
			 WHERE Kwe_Name = [dbo].[TheCompany_GetFirstWordInString]([KeyWordVarchar255])) = 0
				THEN UPPER([dbo].[TheCompany_GetFirstWordInString]([KeyWordVarchar255]))  
				ELSE '(E)' END) /* (E) = short, less processing time */
		as KeyWordFirstWord_UPPER

			, (CASE WHEN 
			 (SELECT count(Kwe_Name) FROM [dbo].[T_TheCompany_KW_ExclusionList] 
			 WHERE Kwe_Name = [dbo].[TheCompany_GetFirstWordInString]([KeyWordLettersNumbersSpacesOnly_UPPER]) ) = 0
				THEN UPPER([dbo].[TheCompany_GetFirstWordInString]([KeyWordLettersNumbersSpacesOnly_UPPER])) 
				ELSE '(E)' END)
		as KeyWordFirstWord_LettersOnly_UPPER

			, (CASE WHEN 
			 (SELECT count(Kwe_Name) FROM [dbo].[T_TheCompany_KW_ExclusionList] 
			 WHERE Kwe_Name = [dbo].[TheCompany_GetFirstWordInString]([KeyWordLettersNumbersOnly_UPPER]) ) = 0
				THEN (CASE WHEN LEN([dbo].[TheCompany_GetFirstWordInString]([KeyWordVarchar255])) > 2
						THEN LEN([dbo].[TheCompany_GetFirstWordInString]([KeyWordVarchar255])) ELSE 0 END)
				ELSE -1 END)
		as KeyWordFirstWord_LEN /* no len if in exclusion list or when less than 3 char */


		/* two words or more */
		, UPPER((CASE WHEN [KeyWord_LettersNumbersOnly_NumSpacesWords] = 1 /* at least two words */
					THEN [KeyWordLettersNumbersSpacesOnly_UPPER] /* one space */
				WHEN KeyWord_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN SUBSTRING([KeyWordLettersNumbersSpacesOnly_UPPER],0,CHARINDEX(' ', [KeyWordLettersNumbersSpacesOnly_UPPER],
						CHARINDEX(' ', [KeyWordLettersNumbersSpacesOnly_UPPER],
									   CHARINDEX(' ', [KeyWordLettersNumbersSpacesOnly_UPPER],+1)+1)) )	/* e.g. SI Group */	
				ELSE NULL /* no space */ END))		
		as KeyWordFirstTwoWords_UPPER

				, UPPER((CASE WHEN [KeyWord_LettersNumbersOnly_NumSpacesWords] =2 /* at least three words */
					THEN  
						SUBSTRING([KeyWordLettersNumbersSpacesOnly_UPPER],charindex(' ',[KeyWordLettersNumbersSpacesOnly_UPPER],
							charindex(' ',[KeyWordLettersNumbersSpacesOnly_UPPER],
							+1)+1)+1 /* start pos */, 
							/* end pos */
							(CASE WHEN [KeyWord_LettersNumbersOnly_NumSpacesWords] >= 3 /* 3 or more words */
								THEN  charindex(' ',[KeyWordLettersNumbersSpacesOnly_UPPER],
									charindex(' ',[KeyWordLettersNumbersSpacesOnly_UPPER],
									charindex(' ',[KeyWordLettersNumbersSpacesOnly_UPPER],
									+1)+1)+1)+1
								ELSE LEN([KeyWordLettersNumbersSpacesOnly_UPPER]) - 1
							END))
				 
				ELSE '' END))

		as KeyWord_ThirdWord_UPPER /* e.g. TIEFENBACHER AE TIEFENBACHER */

		, UPPER((CASE WHEN [KeyWord_LettersNumbersOnly_NumSpacesWords] = 1 /* two words, one space */
					THEN [KeyWordLettersNumbersOnly_UPPER]
				WHEN KeyWord_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(SUBSTRING([KeyWordLettersNumbersSpacesOnly_UPPER],0,CHARINDEX(' ', [KeyWordLettersNumbersSpacesOnly_UPPER],
						CHARINDEX(' ', [KeyWordLettersNumbersSpacesOnly_UPPER],
									   CHARINDEX(' ', [KeyWordLettersNumbersSpacesOnly_UPPER],+1)+1)) ))	/* e.g. SI Group */	
				ELSE NULL /* no space */ END))		
		as KeyWordFirstTwoWords_LettersOnly_UPPER

			,  LEN((CASE WHEN [KeyWord_LettersNumbersOnly_NumSpacesWords] = 1 /* two words, one space */
					THEN [KeyWordLettersNumbersOnly_UPPER]
				WHEN KeyWord_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(SUBSTRING([KeyWordLettersNumbersSpacesOnly_UPPER],0,CHARINDEX(' ', [KeyWordLettersNumbersSpacesOnly_UPPER],
						CHARINDEX(' ', [KeyWordLettersNumbersSpacesOnly_UPPER],
									   CHARINDEX(' ', [KeyWordLettersNumbersSpacesOnly_UPPER],+1)+1)) ))	/* e.g. SI Group */	
				ELSE NULL /* no space */ END)	)	
		as KeyWordFirstTwoWords_LettersOnly_LEN

		, KeyWord_LettersNumbersOnly_NumSpacesWords as KeyWord_NumSpacesWords /* remove */
		, UPPER((CASE WHEN LEN(dbo.TheCompany_GetFirstLetterOfEachWord([KeyWordLettersNumbersOnly_UPPER])) >=3 THEN 
				dbo.TheCompany_GetFirstLetterOfEachWord([KeyWordLettersNumbersOnly_UPPER])
			WHEN LEN(dbo.TheCompany_GetFirstLetterOfEachWord([KeyWordLettersNumbersOnly_UPPER]))<3 
				and len(left([KeyWordLettersNumbersOnly_UPPER],3)) >=3 THEN
				left([KeyWordLettersNumbersOnly_UPPER],3)
			ELSE NULL END
			) )
			as KeyWord_FirstLetterOfEachWord_UPPER

		, (case when e.kwe_Flag is not null then e.kwe_Flag else 0 END) as KeyWord_ExclusionFlag

	from V_TheCompany_KWS_01_Input_Raw k 
		left join T_TheCompany_KW_ExclusionList e 
			on k.KeyWordVarchar255 like e.kwe_Name + '%' /* Vitamin */


GO
/****** Object:  View [dbo].[V_T_TheCompany_zALL]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_T_TheCompany_zALL]

as

select 
	*
	, contractid as Contractid_Proc
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
	/* , t.TargetSystem_AgType
	, t.TargetSystem_AgTypeFLAG
	, t.TargetSystem_AgType
	AS TargetSystem_MigrateTo  */

FROM T_TheCompany_ALL a
	INNER join [V_TheCompany_AgreementType] t /* TheCompany_2WEEKLY_Maintenance_AgreementTypes sets blank agreement types to type 'OTHER'*/
		on a.AGREEMENT_TYPEID = t.AgrTypeID
	

	/* need not filter with WHERE, used in V_TheCompany_ALL */
/* WHERE
	CONTRACTTYPEID not in (11 /* Legal matter / Case */
						, 13 /* Test old */
						, 106 /* Test new*/) 
	AND NUMBER not like 'Xt%' /* divested products or sites */ */


GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[V_T_TheCompany_ALL]

as

select 
	*
	
FROM T_TheCompany_ALL_xt
	

	/* need not filter with WHERE, used in V_TheCompany_ALL */
/* WHERE
	CONTRACTTYPEID not in (11 /* Legal matter / Case */
						, 13 /* Test old */
						, 106 /* Test new*/) 
	AND NUMBER not like 'Xt%' /* divested products or sites */ */


GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_TS_CFN]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_T_TheCompany_ALL_TS_CFN]

as

SELECT 

      a.[title] as 'Contract Description (TS)' /*  [Title_InclTopSecret] as 'Contract Description' */
 
	, b.*

		/* , AGREEMENT_TYPEID */
/* ,DptCode2Digit_Link */
FROM
	V_T_TheCompany_ALL a
		inner join [dbo].[V_T_TheCompany_ALL_NoTS_CommonFN] b 
		on A.contractid = B.contractid

GO
/****** Object:  View [dbo].[V_TheCompany_Duplicates]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE View [dbo].[V_TheCompany_Duplicates]
as

	/* criteria for suspected dupe:
	- same key properties OR
	- same title (hashed) OR
	- same document name (hashed)
	*/

SELECT 
	/* MIN criteria for potential duplicate */
		STARTDATE
		,EXPIRYDATE
		,CompanyIDList
	/* other */
	,MIN(CAST(CONTRACTID AS VARCHAR(10)))+';'+MAX(CAST(CONTRACTID AS VARCHAR(10))) AS UniqueDuplicateID
	, MIN(CONTRACTID) AS CONTRACTID_MIN
	, MAX(CONTRACTID) AS CONTRACTID_MAX
	, MIN(Number) AS ContractNumber_MIN
	, MAX(Number) AS ContractNumber_MAX
	, COUNT(CONTRACTID) as DupeCount
	, MAX( {fn year(( CONTRACTDATE ))}) as UniqueDuplicateMaxYear
	, MIN( {fn year(( CONTRACTDATE ))}) as UniqueDuplicateMinYear
	, MAX(Territories_IDs) as Territories_IDs_Max
	, MIN(Territories_IDs)  as Territories_IDs_Min
	, MAX(InternalPartners_IDs) as InternalPartners_IDs_Max
	, MIN(InternalPartners_IDs) as InternalPartners_IDs_Min
	, MAX(VP_ProductGroups_IDs) as VP_ProductGroups_IDs_Max
	, MIN(VP_ProductGroups_IDs)  as VP_ProductGroups_IDs_Min
	, MAX(LumpSum) as LumpSum_Max
	, MAX(COUNTERPARTYNUMBER) as COUNTERPARTYNUMBER_Max
	, MAX(REFERENCENUMBER) as REFERENCENUMBER_Max
	, MIN(dbo.TheCompany_RemoveNonAlphaCharacters(Title)) as TITLE_ALPHANUM_MIN
	, MAX(dbo.TheCompany_RemoveNonAlphaCharacters(Title)) as TITLE_ALPHANUM_MAX
	, MAX(AGREEMENT_TYPEID) as AGREEMENT_TYPEID_MAX
	, (SELECT MIN([DESCRIPTION]) FROM TDOCUMENT WHERE MIK_VALID = 1 AND DOCUMENTTYPEID = 1 /* Signed Contracts */ AND OBJECTID = MIN(CONTRACTID)) AS MIN_DOC
	, (SELECT MIN([DESCRIPTION]) FROM TDOCUMENT WHERE MIK_VALID = 1 AND DOCUMENTTYPEID = 1 /* Signed Contracts */ AND OBJECTID = MAX(CONTRACTID)) AS MAX_DOC
	, (SELECT MIN(dbo.TheCompany_RemoveNonAlphaCharacters([DESCRIPTION])) FROM TDOCUMENT WHERE OBJECTID = MIN(CONTRACTID)) AS MIN_DOC_ALPHANUM
	, (SELECT MIN(dbo.TheCompany_RemoveNonAlphaCharacters([DESCRIPTION])) FROM TDOCUMENT WHERE OBJECTID = MAX(CONTRACTID)) AS MAX_DOC_ALPHANUM
	, MIN([TITLE]) AS MIN_TITLE
	, MAX([TITLE]) AS MAX_TITLE
	/* Same Doc title */
	, (CASE WHEN (SELECT MIN(DescriptionFull) FROM T_TheCompany_Docx 
		WHERE OBJECTID = MIN(CONTRACTID))= 
		(SELECT MIN(DescriptionFull) 
		FROM T_TheCompany_Docx WHERE OBJECTID = MAX(CONTRACTID)) THEN 1 ELSE 0 END) AS SAME_DOC
	/* Same contract description */
	, (CASE WHEN MIN(dbo.TheCompany_RemoveNonAlphaCharacters(Title)) = MAX(dbo.TheCompany_RemoveNonAlphaCharacters(Title)) THEN 1 ELSE 0 END) AS SAME_TITLE
	, MIN(OWNERID) AS MIN_OWNERID
	, MAX(OWNERID) AS MAX_OWNERID
FROM 
	dbo.T_TheCompany_ALL
WHERE 
	CONTRACTTYPEID NOT IN (
		 6 /* Access SAKSNR number Series*/
		,5 /* Test Old */
		,102 /* Test New */
		,13 /* DELETE */ 
		,11 /* CASE */)	
	AND CompanyIDList > '' /* only consider contracts with the same counter party */
	AND (COUNTERPARTYNUMBER is null or COUNTERPARTYNUMBER not like '!ARIBA%')
GROUP BY 
	CompanyIDList
	, STARTDATE
	, EXPIRYDATE
HAVING 
	COUNT(CONTRACTID) >1
	AND (MAX( {fn year(( CONTRACTDATE ))}) >=2010 or min(statusid) = 5 /* active */)
	AND (
			(MIN(Territories_IDs) = MAX(Territories_IDs)
			AND MIN(InternalPartners_IDs) = MAX(InternalPartners_IDs)
			AND MIN(VP_ProductGroups_IDs) = MAX(VP_ProductGroups_IDs)
			AND MIN(LumpSum) = MAX(LumpSum)
			AND MIN(COUNTERPARTYNUMBER) = MAX(COUNTERPARTYNUMBER)
			AND MIN(REFERENCENUMBER) = MAX(REFERENCENUMBER)
			AND MIN(AGREEMENT_TYPEID) = MAX(AGREEMENT_TYPEID)
			AND MIN(OWNERID) = MAX(OWNERID)
			)
		OR
		/* same contract title */
			((MIN(dbo.TheCompany_RemoveNonAlphaCharacters(Title)) = MAX(dbo.TheCompany_RemoveNonAlphaCharacters(Title)) AND (MIN(REFERENCENUMBER) = MAX(REFERENCENUMBER) ))
		OR 
		/* same document name */
			(SELECT MIN(dbo.TheCompany_RemoveNonAlphaCharacters([DescriptionFull])) 
			FROM T_TheCompany_Docx
			WHERE OBJECTID = MIN(CONTRACTID)
			) = 
		(SELECT MIN(dbo.TheCompany_RemoveNonAlphaCharacters([DescriptionFull])) 
			FROM T_TheCompany_Docx WHERE 
			OBJECTID = MAX(CONTRACTID)) AND (MIN(REFERENCENUMBER) = MAX(REFERENCENUMBER))
			)
		)

GO
/****** Object:  View [dbo].[V_TheCompany_Duplicates_Final]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[V_TheCompany_Duplicates_Final]

as


SELECT
 CONTRACTID_MIN AS CONTRACTID_UNIQUE
, 'Min' As Type
, CONTRACTID_MIN AS CONTRACTID_MIN
, UniqueDuplicateID
, SAME_DOC
, SAME_TITLE
/* , a.* */
FROM
[V_TheCompany_Duplicates] d /* inner join T_TheCompany_ALL a on d.contractid_Min = a.contractid */
  
  
UNION ALL

SELECT 
 CONTRACTID_MAX AS CONTRACTID_UNIQUE
, 'Max' as Type
, CONTRACTID_MIN AS CONTRACTID_MIN
, UniqueDuplicateID
, SAME_DOC
, SAME_TITLE
/* , a.* */
FROM
[V_TheCompany_Duplicates] d /* inner join T_TheCompany_ALL a on d.contractid_max = a.contractid */





GO
/****** Object:  View [dbo].[V_TheCompany_LNC_GoldStandard]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[V_TheCompany_LNC_GoldStandard]

as

	SELECT 

      [CONTRACTID] /* 148186 */
	  ,/* 'CTK-' + */ [Number] as LegacyContikiContractNumber /* ,[REFERENCECONTRACTNUMBER] ? */
      ,[Title_InclTopSecret] as 'ContractTitle'

	  , [STATUS]

	  , [CONTRACTDATE] as 'Created_CONTRACTDATE'
      , [STARTDATE] as 'STARTDATE'
      , [FINAL_EXPIRYDATE] as 'EXPIRYDATE'
      , [REVIEWDATE] as 'REVIEWDATE'

		, Agr_LINC_MainType_DefaultContiki as 'Contract_type'	  		
		, Agr_LINC_SubType_DefaultContiki as 'Contract_subtype_AGREEMENT_TYPE'

	 /* Counter Party / Vendor */
	/*  , [CompanyList]
	  , [Company_EmailAddressList] as 'CompanyEmailList' /* Count: field EmailAddressCount */ */
	 /* primary contact email */
	,  'CTK-' + ltrim(str(InternalPartners_ACTIVE_MAX_DPTID))  as  'INTERNALPARTNERID_FirstParty_MAX'
	, (select DEPARTMENT from TDEPARTMENT 
			where DEPARTMENTID = InternalPartners_ACTIVE_MAX_DPTID) 
			as TheCompanyEntity_FirstPartyMAX
	/*  , [InternalPartners_ACTIVE_MAX_NAME] as 'TheCompanyEntity_FirstPartyMAX' /* V_TheCompany_VCONTRACT_DPTROLES_FLAT */ */
	 /* , [InternalPartners_ACTIVE]
      , [InternalPartners_INACTIVE] 
	  , [Territories] */

	     ,Comments_255 		 as 'Description_COMMENTS' /* max len is 1577 char , t_TheCompany_all truncated*/
	  ,[LumpSum] as 'TotalMaxValue_LUMP_SUM_AMOUNT'
      ,[LumpSumCurrency] as 'Currency_LUMP_SUM_CURRENCY'	

      /*,[Tags] /* include since concat is used */*/
	  /* ,[REFERENCECONTRACTNUMBER] use REFERENCECONTRACTID */
	  , REFERENCECONTRACTID /* LINKED TO NUMBER, Nycomed Pharma AS (Norway)-Perkin Elmer Instruments Purchase Agreement Aanalyst 800 020200, just added to T_TheCompany_ALL */
     /* ,[REFERENCENUMBER] as 'REFERENCENUMBER' /* contract numbers */
      ,[COUNTERPARTYNUMBER] */
	  , (case when [REFERENCENUMBER] >'' THEN [REFERENCENUMBER] ELSE '' END)
			+ (case when [COUNTERPARTYNUMBER]  >'' THEN ', ' ELSE '' END)
			+ (case when [COUNTERPARTYNUMBER]  >'' THEN [COUNTERPARTYNUMBER]  ELSE '' END)
		  as REFERENCE_COUNTERPARTY_NUMBER

	/* Business Unit */
		, (case 
				when [ConfidentialityFLAG_0123] = 1 THEN /* Top Secret */
					'BD CONFIDENTIAL (EUCAN)' 
							/* AND user list to be provided for non GGC persons allowed to view*/ 
				when [ConfidentialityFLAG_0123] IN(2,3) /* Strictly Confidential or Confidential */
						OR contracttypeid = 11 /* case rictly Confidential or Confidential */ 
						OR AGREEMENT_TYPE like '%Administration%' /* administration */
						 THEN 'TheCompany – Global General Counsel' /* GGC, Tax etc. allowed to see */
							/*AND user list to be provided for non GGC persons allowed to view*/ 
				when AgreementType_Isprivate_FLAG = 0 /* public, 1 private 2 unclassified - no confidential BU needed */ 
								then '' /* default to Workday BU IF legal ops takes responsibility */
				when AgreementType_Isprivate_FLAG = 1 /* PRIVATE*/ 
								then 'TheCompany – Global General Counsel' 
				when CompanyList like '%intercompany%'/* INTERCOMPANY */ 
								then 'TheCompany – Global General Counsel' 
				when InternalPartners_DptCodeList like ',AU%' THEN 'Australia Confidential Contracts' 
				when InternalPartners_DptCodeList like ',UK%' THEN 'UK Confidential Contracts' 
				when InternalPartners_DptCodeList like ',IE%' THEN 'Ireland Confidential Contracts' 
				when InternalPartners_DptCodeList like ',IT%' THEN 'Italy Confidential Contracts' 
			else '' END
				)
				as BusinessUnit_TBD

		 /* , [UO_DisplayName] as 'BusinessOwnerName_CONTRACT_OWNER' */
		  , [UO_Email] as 'BusinessOwnerEmail_CONTRACT_OWNER'

		  , Prs_ContractSignatoryEMAIL as ContractSignatoryEmail /* V_TheCompany_VCONTRACT_DPTROLES_FLAT */

		  ,[AgrIsMaterial] as 'MaterialContractYN'
		 /* , Agr_IsMaterial_Flag as 'MaterialContractFlag' */
		  , (SELECT l.MIK_LANGUAGE from TCONTRACT c 
				inner join TLANGUAGE l on c.LANGUAGEID = l.LANGUAGEID
				where c.CONTRACTID = a.CONTRACTID) 
				as 'ContractLanguage'

			/* Access Permissions */
			  , [TERMINATIONPERIOD]
			, ACL_AllPermissions_GroupAndUserList

			,[ConfidentialityFlagNAME] /* fyi only, not a field to migrate */
			  , [LinkToContractURL] as 'LinkToContractRecord'
		/*, A.CompanyAddressConcat */ /* removed since it duplicates addresses for 3 tenderers */
		, GETDATE() as DateRefreshed
		, NUMBEROFFILES
		,[DocumentFileTitlesConcat] 
	, (case when [DocumentFileTitlesConcat] like '%assoc%' and number like '%case%' then 'AoA' 
		else '' END) as AOA_FLAG
	, (case when [DocumentFileTitlesConcat] like '%assoc%' and number like '%case%' then 1
		else 0 END) as DELETE_FLAG
		, (case when number like 'CTK%' and MigrateYN_Flag = 1 
			then 1 else 0 end) as IsMigratedToLINC_Flag
			, MigrateYN_Flag
		, [InternalPartners] as InternalPartnerList
		, CompanyList
		, (select InternalPartner_Name from V_TheCompany_VDepartment_ParsedDpt_InternalPartner
			where DEPARTMENTID = InternalPartners_ACTIVE_MAX_DPTID) 
			as TheCompanyEntity_FirstPartyMAX_CompanyName

		, (select InternalPartner_Name_NonSpaceFwSlash from V_TheCompany_VDepartment_ParsedDpt_InternalPartner
			where DEPARTMENTID = InternalPartners_ACTIVE_MAX_DPTID) 
			as TheCompanyEntity_FirstPartyMAX_CompanyName_NonSpaceFwSlash
		, UPPER((select InternalPartner_Name_NonSpaceFwSlash from V_TheCompany_VDepartment_ParsedDpt_InternalPartner
			where DEPARTMENTID = InternalPartners_ACTIVE_MAX_DPTID) )
			as TheCompanyEntity_FirstPartyMAX_CompanyName_NonSpaceFwSlash_UPPER

		,(select InternalPartner_CountryPrefix from V_TheCompany_VDepartment_ParsedDpt_InternalPartner
			where DEPARTMENTID = InternalPartners_ACTIVE_MAX_DPTID) 
			as TheCompanyEntity_FirstPartyMAX_CompanyCountry

	FROM t_TheCompany_ALL_Xt a
	/* WHERE MigrateYN_Flag = 1 */

GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_V_T_TheCompany_ALL_STD_NoTS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_LNC_Mig_V_T_TheCompany_ALL_STD_NoTS]

as

	SELECT 
		MigrateToSystem_LNCCategory
		, MigrateToSystem
		, MigrateToSystem_Detail
		, MigrateYN_Flag
		, MigrateYN_Detail
		, s.*
		   , [DateTableRefreshed]      
		/* , [LinkToContractURL] */
	FROM 
		T_TheCompany_ALL_Xt a 
			inner join  [dbo].[V_TheCompany_LNC_GoldStandard] s 
			on a.CONTRACTID = s.CONTRACTID
	WHERE 
		/* [CONTRACTTYPEID] <> 11 /* Case */ */
		MigrateYN_Flag = 1
	/*	MigrateToSystem_LNCCategory
		, MigrateToSystem
		, MigrateToSystem_Detail
		, MigrateYN_Flag */
		
GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_DATA_COMPANY_TTENDERER_CONTRACTID_ProblemRecords]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_LNC_Mig_DATA_COMPANY_TTENDERER_CONTRACTID_ProblemRecords]

as

SELECT TOp 100 percent
	[Contractid_TT] as CONTRACTID
	, [CompanyID_tt] as COMPANYID
 	, RowNoPartitionByCONTRACTID_OrderByTENDERERID
      ,[COMPANY]
	  , Strategytype_IsHcpHCO_1_0_NULL
	  , a.Title
	  , a.AGREEMENT_TYPE
	  , a.[MigrateToSystem_LNCCategory]
	  , a.[MigrateToSystem]
	  , a.[MigrateToSystem_Detail]
  FROM [Contiki_app].[dbo].[v_TheCompany_TTENDERER_CompanyAddress_Primary] p 
	inner join V_TheCompany_LNC_Mig_V_T_TheCompany_ALL_STD_NoTS a on p.Contractid_TT = a.contractid
  where RowNoPartitionByCONTRACTID_OrderByTENDERERID >2
	and (Strategytype_IsHcpHCO_1_0_NULL = 0 
		or Strategytype_IsHcpHCO_1_0_NULL is null)
	and MigrateToSystem = 'LINC'
	order by RowNoPartitionByCONTRACTID_OrderByTENDERERID desc

GO
/****** Object:  View [dbo].[V_TheCompany_LNC_GoldStandard_GrantDonationSponsNotMigrated]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_LNC_GoldStandard_GrantDonationSponsNotMigrated]

as 


SELECT [CONTRACTID]
, [LegacyContikiContractNumber]
, [ContractTitle]
, [STARTDATE]
, [EXPIRYDATE]
, [Contract_subtype_AGREEMENT_TYPE]
, (case when expirydate is null then 'Evergreen' 
		when expirydate < getdate() then 'Expired' 
		else 'not expired' end) as ExpiredFlag
  FROM [DAQ-1445_Contiki_App_DESQL016_Divestment].[dbo].[V_TheCompany_LNC_GoldStandard]
  where 
[IsMigratedToLINC_Flag] = 0 and [MigrateYN_Flag] = 1
GO
/****** Object:  View [dbo].[V_TheCompany_NoActivityDomainNotTheCompany]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_NoActivityDomainNotTheCompany]

as

select 
	u.DISPLAYNAME
	, u.USERINITIAL
	, u.DOMAINNAME
	, u.DOMAINUSERNAME
	, u.DOMAINUSERSID
	, l.*
from V_TheCompany_VUSER u left join [dbo].[V_TheCompany_VLogon] l on u.userid = l.userid
where u.USER_MIK_VALID = 1
	and [MaxDt_AllActivity] is null
	and domainusername not like '%TheCompany%'

GO
/****** Object:  View [dbo].[V_TheCompany_VCOMPANYADDRESS_PrimaryAddress]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [dbo].[V_TheCompany_VCOMPANYADDRESS_PrimaryAddress]

as 

SELECT [COMPANYADDRESSID]
      ,[ADDRESSTYPEID]
      ,[COMPANYID] as CompanyID_Add
      ,[ADDRESSLINE1] as Street
      ,[ADDRESSLINE2] as POB
      ,[ADDRESSLINE3] as PostalCode /* ZIP */
      ,[ADDRESSLINE4] as City
      ,[ADDRESSLINE5] as County
	  ,[COUNTRY]

      ,[PHONE]
      ,[FAX]
      ,[WWW]
      ,[EMAIL]
      ,[COUNTRYID]
      ,[COMPANYADDRESSMIKDEFAULT]
      ,[COMPANY] as Company_Add
      ,[ADDRESSTYPE]
      ,[DESCRIPTION] as ADDRESSDESCRIPTION
      ,[ADDRESSTYPEFIXED]
      ,[ADDRESSTYPEMIKDEFAULT]
      ,[ADDRESSTYPEMIKSEQUENCE]
      ,[ADDRESSTYPEMIKVALID]
      
	  , (case 
			when countryid is null then ''
			when countryid = 14 /* united states */  		then 'US' 
			ELSE 'Non-US' 
			END) as Country_IsUS

		, ltrim(
			(CASE WHEN a.[ADDRESSLINE1] IS not null then a.[ADDRESSLINE1] + ' ' ELSE '' END) /* Street */
			+ (CASE WHEN a.[ADDRESSLINE3] IS not null then  ', ' + a.[ADDRESSLINE3] + ' ' ELSE '' END) /* Postal Code / ZIP */
			+ (CASE WHEN a.[ADDRESSLINE4] IS not null then  a.[ADDRESSLINE4] + ' ' ELSE '' END) /* City */
			+ (CASE WHEN a.[ADDRESSLINE5] >'' then '('+ a.[ADDRESSLINE5] + ')' ELSE '' END) /* County in brackets */
			+ (CASE WHEN a.[Country] IS not null then ', ' + UPPER(a.[Country]) + ' ' ELSE '' END)
			)
			as CompanyAddressConcat
			, ct.[CtyCode2Letter]
  FROM [Contiki_app].[dbo].[VCOMPANYADDRESS] a  		
		left join T_TheCompany_TCountries ct 
			on UPPER(a.COUNTRY) = UPPER(ct.ctyname)
  WHERE ADDRESSTYPEID = 1 /* Primary Address */


GO
/****** Object:  View [dbo].[VCompanyContact]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  View DBO.VCompanyContact			?????		*********/

CREATE VIEW [dbo].[VCompanyContact] AS
SELECT	CC.CompanyContactID,
		CC.MIK_Valid			AS CompanyContact_MikValid,
		CC.IsDefault,
		C.CompanyID,
		C.Company,
		C.CompanyNo,
		C.MIK_Valid				AS Company_MikValid,
		CA.ADDRESSLINE1,
		CA.ADDRESSLINE2,
		CA.ADDRESSLINE3,
		CA.ADDRESSLINE4,
		CA.ADDRESSLINE5,
		CA.PHONE				AS COMPANY_PHONE,
		CA.FAX					AS COMPANY_FAX,
		CA.WWW,
		CA.EMAIL				AS COMPANY_EMAIL,
		CCY.COUNTRY				AS COMPANY_COUNTRY,
		P.PersonID,
		P.Title,
		P.FirstName,
		P.MiddleName,
		P.LastName,
		P.Email,
		U.UserID,
		U.UserInitial,
		U.Mik_Valid				AS User_MikValid
  FROM	TCOMPANYCONTACT			CC
  JOIN	TCOMPANY				C
	ON	C.CompanyID				= CC.CompanyID
  JOIN	TCompanyAddress			CA
	ON	CA.CompanyID			= C.CompanyID
   AND	CA.AddressTypeID		= (
		SELECT	AddressTypeID
		  FROM	TAddressType	AT
		 WHERE	AT.Fixed		= 'MAINADDRESS' 
		)
  JOIN	TPerson					P
	ON	P.PersonID				= CC.PersonID
  LEFT	OUTER
  JOIN	TCOUNTRY				CCY
	ON	CCY.COUNTRYID			= CA.COUNTRYID
   AND	CCY.COUNTRYID			> 0
  LEFT	OUTER
  JOIN	TUser					U
	ON	U.PersonID				= CC.PersonID

GO
/****** Object:  View [dbo].[V_TheCompany_VCOMPANY_Contact_GroupByCompanyID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_VCOMPANY_Contact_GroupByCompanyID]

as 

	select 
		CompanyID as CompanyID_CC
		, SUBSTRING(STUFF(
		(SELECT ',' + s.Email
		FROM VcompanyContact s
		WHERE s.companyid =c.companyid
			and s.email > '' /* otherwise ,,, */
		FOR XML PATH('')),1,1,''),1,255) AS PrimaryCompanyContact_EmailAddressList

		, 		(SELECT count(s.Email)
		FROM VcompanyContact s
		WHERE s.companyid =c.companyid
			and s.email > '' /* otherwise ,,, */
		FOR XML PATH('')) AS PrimaryCompanyContact_EmailAddressCount
	from VcompanyContact c
	group by CompanyID

GO
/****** Object:  View [dbo].[v_TheCompany_TTENDERER_CompanyAddress_Primary]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view
[dbo].[v_TheCompany_TTENDERER_CompanyAddress_Primary] as

select 
	t.TENDERERID
	, t.COMPANYID as Companyid_TT
	, t.CONTRACTID as Contractid_TT

	, c.COMPANY as COMPANY_TT
	, c.[Company_SAP_ID]
	,  c.[Company_SAP_NAME]
	, c.[CompanyType]

/*company contact*/
	, cc.* 

/* Address */
	, a.* 

	/*, h.STRATEGYTYPEID /* HCP/HCO or not matters for # of vendors per contract, rim etc. */
	, (select strategytype from TSTRATEGYTYPE where strategytypeid = h.STRATEGYTYPEID) 
	as STRATEGYTYPE_HCP_HCO */
	, (case 
		when h.STRATEGYTYPEID = 21 /* yes */ then 1 
		when h.STRATEGYTYPEID = 22 /* no */ then 0
		else null end) as Strategytype_IsHcpHCO_1_0_NULL

	 , ROW_NUMBER() OVER(PARTITION BY t.CONTRACTID ORDER BY t.TENDERERID ASC) 
		AS RowNoPartitionByCONTRACTID_OrderByTENDERERID
		, h.[contract] as ContractTitle
from TTENDERER t 
	/*inner join T_TheCompany_VCOMPANY /* was tcompany */ c /* [dbo].[V_TheCompany_VCOMPANY_Contact_GroupByCompanyID] is slow */
		on t.COMPANYID = c.COMPANYID */
	inner join [dbo].[T_TheCompany_VCompany] /* TCOMPANY 12.May */ c
		 on t.COMPANYID = c.companyid_LN
	inner join TCONTRACT h /* for strategy type HCP/HCO */
		on t.CONTRACTID = h.CONTRACTID
	/* left join */
	left join [dbo].[V_TheCompany_VCOMPANYADDRESS_PrimaryAddress] a 
		on a.CompanyID_Add = t.COMPANYID 
	left join [dbo].[V_TheCompany_VCOMPANY_Contact_GroupByCompanyID] cc
		on t.COMPANYID = cc.companyid_cc
		/* SLOW */
	/*left join [dbo].[T_TheCompany_Ariba_Suppliers_SAPID_ValidMatchedCompanies] s
		on c.COMPANYID_LN = s.[Sup_COMPANYID] /* added 19-feb-21 */ */

/*	left join T_TheCompany_TCountries ct on UPPER(a.COUNTRY) = UPPER(ct.ctyname) */



GO
/****** Object:  View [dbo].[v_TheCompany_TTENDERER_CompanyAddress_Primary_GroupByContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view

[dbo].[v_TheCompany_TTENDERER_CompanyAddress_Primary_GroupByContractID] as

select 
	  Contractid_TT

		/* ALL IDs */
	, convert(varchar(255), SUBSTRING(STUFF(
	(SELECT ',' + s.[CompanyAddressConcat]
	FROM [v_TheCompany_TTENDERER_CompanyAddress_Primary] s
	WHERE s.CONTRACTID_TT =d.CONTRACTID_TT
			and s.[CompanyAddressConcat] > '' /* otherwise ,,, */
	FOR XML PATH('')),1,1,''),1,255))
	 AS CompanyAndAddressList

	, convert(varchar(255),  SUBSTRING(STUFF(
	(SELECT ',' + s.[EMAIL]
	FROM [v_TheCompany_TTENDERER_CompanyAddress_Primary] s
	WHERE s.CONTRACTID_TT =d.CONTRACTID_TT 
		and s.email > '' /* otherwise ,,, */
	FOR XML PATH('')),1,1,''),1,255))
	AS Company_EmailAddressList

	, 	(SELECT count(s.[EMAIL])
	FROM [v_TheCompany_TTENDERER_CompanyAddress_Primary] s
	WHERE s.CONTRACTID_TT =d.CONTRACTID_TT 
		and s.email > '' ) AS EmailAddressCount

	, 	(SELECT count(s.[CompanyAddressConcat])
	FROM [v_TheCompany_TTENDERER_CompanyAddress_Primary] s
	WHERE s.CONTRACTID_TT =d.CONTRACTID_TT 
		and s.CompanyAddressConcat > '')
		 AS CompanyAddressConcat_List

	,  convert(varchar(50), SUBSTRING(STUFF(
	(SELECT ',' + s.[Company_SAP_ID]
	FROM [v_TheCompany_TTENDERER_CompanyAddress_Primary] s
	WHERE s.CONTRACTID_TT =d.CONTRACTID_TT 
		and s.[Company_SAP_ID] > '' /* otherwise ,,, */
	FOR XML PATH('')),1,1,''),1,255))
	 AS Company_SAP_ID_List

	,  convert(varchar(255), replace(SUBSTRING(STUFF(
	(SELECT ',' + s.[Company_SAP_NAME]
	FROM [v_TheCompany_TTENDERER_CompanyAddress_Primary] s
	WHERE s.CONTRACTID_TT =d.CONTRACTID_TT 
		and s.[Company_SAP_NAME] > '' /* otherwise ,,, */
	FOR XML PATH('')),1,1,''),1,255),'&amp;','&'))
	 AS Company_SAP_NAME_List /* ERNST & YOUNG FRANCE */

from [dbo].[v_TheCompany_TTENDERER_CompanyAddress_Primary] d
/* where contractid_tt = 109133 */
group by 
	Contractid_TT




GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_Xt]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_T_TheCompany_ALL_Xt]

as

SELECT
		c.*

		, d.[InternalPartners_ACTIVE]
		, d.[InternalPartners_INACTIVE]

		, d.[InternalPartners_ACTIVE_MAX_DPTID] /* V_TheCompany_VCONTRACT_DPTROLES_FLAT */
		, d.[InternalPartners_ACTIVE_MAX_NAME] /* V_TheCompany_VCONTRACT_DPTROLES_FLAT */

		/* Company - LEFT JOIN, not 1:1 */
		, ca.Company_SAP_ID_List
		, ca.Company_SAP_NAME_List
		, ca.Company_EmailAddressList

		/* Registered category */
				, DATEDIFF(mm,c.contractdate,GetDate())  as RegisteredDateNumMth

			  , (CASE 
					WHEN DATEDIFF(mm,c.contractdate,GetDate()) <=12 THEN '12 Months'
					WHEN DATEDIFF(mm,c.contractdate,GetDate()) Between 13 and 24 THEN '13-24 Months'
					WHEN DATEDIFF(mm,c.contractdate,GetDate()) Between 25 and 36 THEN '25-36 Months'
					WHEN DATEDIFF(mm,c.contractdate,GetDate()) > 36 THEN '36+ Months'
				END) as RegisteredDateNumYrsCat

			  , (CASE 
					WHEN DATEDIFF(mm,c.contractdate,GetDate()) <=24 THEN '<= 2 Years'
					ELSE '> 2 Years'
				END) as RegisteredDate_Within2Years_Label

			  , (CASE 
					WHEN DATEDIFF(mm,c.contractdate,GetDate()) <=24 THEN 1
					ELSE 0
				END) as RegisteredDate_Within2Years_FLAG

/* Migration Flags */
	, m.[MigrateToSystem_LNCCategory] /* LINC or OTHER */
	, m.[MigrateToSystem] /* Ariba iManage */
	, m.[MigrateToSystem_Detail] /* LINC (Intercompany) */
	, m.MigrateYN_Flag
	, m.MigrateYN_Detail

	, P.Prs_ContractOwnerEMAIL
	, p.Prs_ContractSignatoryEMAIL
	/* , r.*/ , 'TBD' as ACL_AllPermissions_GroupAndUserList /* for linc mig */
		, Agr_LINC_MainType_DefaultContiki
			, Agr_LINC_SubType_DefaultContiki
			, Agr_LINC_MainType
			, Agr_LINC_SubType
		, year(c.STARTDATE) as STARTDATE_YYYY

FROM T_TheCompany_ALL c
	INNER JOIN [dbo].[V_T_TheCompany_ALL_0_MigFlags] m 
		on c.CONTRACTID = m.contractid_proc
	INNER JOIN [dbo].[V_TheCompany_AgreementType] a /* INNER JOIN OK */
		on c.AGREEMENT_TYPEID = a.AgrTypeID 
	LEFT JOIN T_TheCompany_VCONTRACT_DPTROLES_FLAT d  /* INNER JOIN OK */
		on c.CONTRACTID = d.Dpt_contractid
	LEFT JOIN [T_TheCompany_VCONTRACT_PERSONROLES_FLAT] p   /* INNER JOIN OK */
		on c.CONTRACTID = p.prs_CONTRACTID
	LEFT /*!*/ JOIN /* TTENDERER: inner JOIN LOSES ROWS because some contracts do NOT have a company / tenderer (cases etc.) */
	v_TheCompany_TTENDERER_CompanyAddress_Primary_GroupByContractID ca 	
		on c.contractid = ca.Contractid_TT 
/*	inner join V_TheCompany_VACL_FLAT r 
		on c.contractid = r.objectid */
	/* was left */

GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_NoTS_CFN]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[V_T_TheCompany_ALL_NoTS_CFN]

as

SELECT 

/* [ContractRelationFIXED] */
      [Number] as 'Contract Number'

      /* ,[Title] as 'Contract Description' */
      , [Title_InclTopSecret] as 'Contract Description' /*  [Title_InclTopSecret] as 'Contract Description' */
      ,[ContractRelations] as 'Contract Relation'
      ,[CONTRACTTYPE] as 'Contract Type'
	  ,  [AgreementTypeDivestment] 
			as 'Agreement Type Divestment'
      /* ,[CONTRACTTYPEID] as 'Contract Type ID' */
      /* ,[COMMENTS] */
      ,[STATUS] as 'Status'
      ,[CONTRACTDATE] AS 'Registered Date'
      , RegisteredDateNumMthCat as 'Reg Date Cat'
	  , [RegisteredDate_YYYY_MM] as 'Reg Dt YYYY-MM'
	  , RegisteredDateNumYrsCat as  'Reg Dt Cat Yrs'
	, [RegisteredDateNumMth] as 'Reg Dt Num Mth'
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
      /* ,[AGREEMENT_TYPEID] */
      /* ,[AGREEMENT_MIK_VALID] */
      ,[CompanyList] as 'Company Names'
		, CompanyCountryList as 'Company Country List'
      /* ,[CompanyIDList] as 'Company IDs' */
      ,[CompanyIDAwardedCount] as 'Company Count'

      /* , [CompanyIDUnawardedCount] as 'Company Count (Unawarded)' */
       , [ConfidentialityFlagNAME] as 'Confidentiality Flag'
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

		, CompanyActivityDateMax as 'Company Activity Date Max'
		, CompanyCountry_IsUS as 'Company Country is US'

		/* , AGREEMENT_TYPEID */
/* ,DptCode2Digit_Link */
FROM
V_T_TheCompany_ALL_Xt a

GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_TS_CFN_CommonFN]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_T_TheCompany_ALL_TS_CFN_CommonFN]

as

SELECT 

      a.[title] as 'Contract Description (TS)' /*  [Title_InclTopSecret] as 'Contract Description' */
 
	, b.*

		/* , AGREEMENT_TYPEID */
/* ,DptCode2Digit_Link */
FROM
	V_T_TheCompany_ALL a
		inner join [dbo].[V_T_TheCompany_ALL_NoTS_CFN] b 
		on A.contractid = B.contractid

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_1_ARB_MiscMetadataFields]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view 
[dbo].[V_TheCompany_KWS_1_ARB_MiscMetadataFields]

as 

	SELECT  
		s.KeyWordVarchar255
		, s.KeyWordType
		, s.KeyWordPrecision
		, s.KeyWordOperator
		, p.[Contract Type] as 'FieldContent'
		, p.contractinternalid as CONTRACTID

	FROM [V_TheCompany_KeyWordSearch] s 
		inner join T_TheCompany_AribaDump p 
			on p.[Contract Type] like '%'+s.KeyWordVarchar255+'%' 
			OR p.[Contract Description] like '%'+s.KeyWordVarchar255+'%' /* e.g. supply agreement does not exist as agreement type */
	where /* p.statusid = 5  active */
		s.KeyWordtype = 'AgreementType'

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_7_ARB_ContractID_SummaryByContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view

[dbo].[V_TheCompany_KWS_7_ARB_ContractID_SummaryByContractID]

as 
/* EXEC [dbo].[TheCompany_KeyWordSearch] */
	SELECT  
		u.contractid /* as ContractID_KWS */

/* COMPANY */
	
	/* EXACT */

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ',' + c.[KeyWordVarchar255] 
			FROM [T_TheCompany_KWS_3_ARB_TCompany_ContractID_Extended] c
			WHERE  c.contractid = u.contractid 
				AND c.companyMatch_Exact_Flag > 0
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [CompanyMatch_Exact]
		,
			(SELECT max(CompanyMatch_Exact_Flag)
			FROM [T_TheCompany_KWS_3_ARB_TCompany_ContractID_Extended] c
			WHERE  c.contractid = u.contractid)
			 AS [CompanyMatch_Exact_FLAG]

	/* LIKE */
			,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + c.[KeyWordVarchar255] /*+': ' 
			
				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM [T_TheCompany_KWS_3_ARB_TCompany_ContractID_Extended] c
			where  c.contractid = u.contractid   
				and [CompanyMatch_Like_FLAG] > 0
				and [CompanyMatch_Exact_FLAG] = 0
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [CompanyMatch_Like]	

		,
			(SELECT max(CompanyMatch_LIKE_Flag)
			FROM [T_TheCompany_KWS_3_ARB_TCompany_ContractID_Extended] c
			WHERE  c.contractid = u.contractid)
			 AS [CompanyMatch_LIKE_FLAG]

	/* Company ANY */
						,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + c.[KeyWordVarchar255] /*+': ' 
				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM [T_TheCompany_KWS_3_ARB_TCompany_ContractID_Extended] c
			where  c.contractid = u.contractid   
				and [CompanyMatch_Like_FLAG] = 0
				and [CompanyMatch_Exact_FLAG] = 0
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [CompanyMatch_NotExactNotLike]

						,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + c.[Companytype] /*+': ' 
				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM [T_TheCompany_KWS_3_ARB_TCompany_ContractID_Extended] c
			where  c.contractid = u.contractid   
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS CompanyType

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
				FROM T_TheCompany_KWS_3_ARB_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid)
					AS [CompanyMatch_Level]

	/* Level - Company Match Category */

			, (SELECT MIN( 
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
				FROM T_TheCompany_KWS_3_ARB_TCompany_ContractID_Extended c
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
				FROM T_TheCompany_KWS_3_ARB_TCompany_ContractID_Extended c
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
				FROM T_TheCompany_KWS_3_ARB_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid),255))
					AS [CompanyMatch_Name]

			, (SELECT MAX([KeyWordVarchar255]) from T_TheCompany_KWS_3_ARB_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid) 
					as CompanyMatch_KeyWord

			, (SELECT MAX([KeyWordVarchar255_UPPER]) from T_TheCompany_KWS_3_ARB_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid) 
					as CompanyMatch_KeyWord_UPPER									   
	/* COUNTRY - Company */

		/*				,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordVarchar255] /*+': ' 

				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM T_TheCompany_KWS_2_ARB_TCOMPANYCountry_ContractID rs
			where  rs.contractid = u.contractid   
			FOR XML PATH('')),1,1,''),'&amp;','&')) */, '' AS [CompanyCountryMatch]	
			

/* CUSTOM FIELDS */

		,Replace(STUFF(
			(
			SELECT DISTINCT ',' + rs.[KeyWordCustom1]
			FROM (select [KeyWordCustom1], contractid from T_TheCompany_KWS_2_ARB_TPRODUCT_ContractID
					UNION
					select [KeyWordCustom1], contractid from T_TheCompany_KWS_2_ARB_TCompany_ContractID
					) rs
			where  rs.contractid = u.contractid
				AND rs.[KeyWordCustom1] IS NOT NULL

			/* and rs.ProductExact_Flag = 1 */
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Custom1_Lists

		,Replace(STUFF(
			(SELECT DISTINCT ',' + rs.[KeyWordCustom2]
			FROM T_TheCompany_KWS_2_ARB_TPRODUCT_ContractID rs
			where  rs.contractid = u.contractid
			AND rs.[KeyWordCustom2] IS NOT NULL
			/* and rs.ProductExact_Flag = 1 */
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Custom2_Lists

	/* DESCRIPTION */

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[DescriptionKeyword]
			FROM [T_TheCompany_KWS_5c_ARB_DESCRIPTION_ContractID] rs
			where  rs.contractid = u.contractid
			/* only include records that are not a company match */
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS Description_Match

	/* INTERNAL PARTNER */

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordVarchar255]
			FROM [T_TheCompany_KWS_2_ARB_InternalPartner_ContractID] rs
			where  rs.contractid = u.contractid
			/* only include records that are not a company match */
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS InternalPartner_Match

	/* TERRITORIES */

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordVarchar255]
			FROM [T_TheCompany_KWS_2_ARB_Territories_ContractID] rs
			where  rs.contractid = u.contractid
			/* only include records that are not a company match */
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS Territory_Match

	/* PRODUCTS */

		,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[T_TheCompany_KWS_3_ARB_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and p.[ProductMatch_TN] = 1
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_TradeName

						 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[T_TheCompany_KWS_3_ARB_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and p.[ProductMatch_AI] = 1
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_ActiveIngredients

		 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup
		FROM [dbo].[T_TheCompany_KWS_3_ARB_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and p.[ProductMatch_Exact] = 1
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Product_EXACT

		 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[T_TheCompany_KWS_3_ARB_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and p.[ProductMatch_NotExact] = 1
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Product_NotExact

			 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[T_TheCompany_KWS_3_ARB_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and (p.[ProductMatch_AI] = 1 OR p.[ProductMatch_TN] = 1)
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Product_AIorTN

				 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup 
			+ (CASE WHEN PrdGrpMatch_EXACT_FLAG = 1 THEN '' ELSE ' ('+ p.keywordvarchar255 + ')' END)
		FROM [dbo].[T_TheCompany_KWS_3_ARB_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid 
		/* and (p.[ProductMatch_AI] = 1 OR p.[ProductMatch_TN] = 1) */
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS ProductKeyword_Any

	/* TAG */
				 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.tagcategory
		FROM [dbo].[T_TheCompany_KWS_2_ARB_Tag_ContractID] p 
		where  p.CONTRACTID = u.contractid 
		and P.keywordtype = 'TagCategory'
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS TagCategory_Match

		/*
				 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.tag
		FROM [dbo].[T_TheCompany_KWS_2_ARB_Tag_ContractID] p 
		where  p.CONTRACTID = u.contractid 
		and P.keywordtype = 'Tag'
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS Tag_Match */
				 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.FieldContent
		FROM [dbo].[V_TheCompany_KWS_1_ARB_MiscMetadataFields] p 
		where  p.CONTRACTID = u.contractid 
		and P.keywordtype = 'AgreementType'
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS AgreementType_Match

	FROM 
		T_TheCompany_KWS_6_ARB_ContractID_UNION  u /* product, company, description */
	group by 
		u.contractid


GO
/****** Object:  View [dbo].[V_TheCompany_DptID_DptRoleCount]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_DptID_DptRoleCount]

as 

SELECT top 999 d.usergroup, d.DEPARTMENTID, d.Department
, COUNT(r.DEPARTMENTROLE_IN_OBJECTID) as DptRoleInObjectIdCount
  FROM V_TheCompany_VDEPARTMENT_VUSERGROUP d left join TDEPARTMENTROLE_IN_OBJECT r 
  on d.DEPARTMENTID = r.DEPARTMENTID /* left join V_TheCompany_ALL a on r.OBJECTID = a.contractid */
  WHERE d.usergroup like 'Departments%' and d.MIK_VALID = 1
  /* and DEPARTMENT_CODE not like ':%' /* no area level nodes */ */
  GROUP BY d.usergroup, d.DEPARTMENTID, d.Department
  order by d.USERGROUP

GO
/****** Object:  View [dbo].[V_TheCompany_Mig_VDOCUMENT_Proc]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[V_TheCompany_Mig_VDOCUMENT_Proc]

as

select objectid as ContractIDKey, 
d.Title as DocTitle
      ,d.[Version]
      ,d.[MajorVersion]
      ,d.[MinorVersion]
      ,d.[Status] as DocStatus
      ,d.[Owner]
      /*,d.[TemplateType]
      ,d.[CheckedOutBy] */
      ,d.[VersionDate]
      ,d.[Datecreated]
      /*,d.[CHECKEDOUTDATE] */
      ,d.[FileName]
      ,d.[FileSize]
      ,d.[OriginalFileName]
      ,d.[DocumentOwnerId]
    /*  ,d.[CheckedOutById]
      ,d.[CheckedOutStatus] */
      ,d.[DOCUMENTTYPEID]
      ,d.[DOCUMENTID]
      ,d.[ARCHIVEID]
      ,d.[ArchiveFixed]
      ,d.[MIK_VALID]
      ,d.[FileID]
      ,d.[OBJECTTYPEID]
      ,d.[OBJECTID]
      ,d.[DOCUMENTTYPE]
      ,d.[FileType]
      ,d.[SOURCEFILEINFOID]
    /*  ,d.[ApprovalStatus]
      ,d.[ApprovalStatusID]
      ,d.[ApprovalStatusFixed] */

, c.*
from VDOCUMENT d inner join dbo.T_TheCompany_Mig_1T_TheCompany_All_ProcNetFlag c
on d.OBJECTID = c.contractid
 /*, f.FileType, f.LastChangedDate, f.MajorVersion 
left join TFILEinfo f on d.fileid = f.FileID */
where
OBJECTID in (select contractid_Proc 
from dbo.V_TheCompany_Mig_0ProcNetFlag
where Proc_NetFlag = 1)
and d.MIK_VALID = 1




GO
/****** Object:  View [dbo].[V_TheCompany_TROLE]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE View [dbo].[V_TheCompany_TROLE]

as

	select 
	*

	,(CASE 
			WHEN r.FIXED IN ('COMMERCIAL_CO_ORDINATOR' /*IN(1,19,20,34,23 /*Super User*/)*/
						,'BUDGET_OWNER' /*2 /* Contract Owner*/*/
						,'TECHNICAL_CO_ORDINATOR' /* 15 Contract responsible */
						, 'SIGNATORY/SIGNATORIES' /*110 */
						) THEN 'D'
			WHEN r.FIXED in ( 'CREATOR' /* 0 */
							, 'ENTITY' /* 6 */
							, 'YODAINTERNAL'/*100 '*/) THEN 'I' 
			WHEN r.FIXED =  'APPLIES_FOR'  /* 3, TERRITORY*/ Then 'T'
			WHEN r.FIXED = 'ARCHIVING' /* 103, HARDCOPY ARCHIVING */ THEN 'IA' 
			END) AS RoleCategory
				
	,(CASE 
			WHEN r.FIXED IN ('COMMERCIAL_CO_ORDINATOR'
						,'BUDGET_OWNER'
						,'TECHNICAL_CO_ORDINATOR'
						, 'SIGNATORY/SIGNATORIES'
						) THEN 'Department'
			WHEN r.FIXED in ( 'CREATOR' /* 0 */
							, 'ENTITY' /* 6 */
							, 'YODAINTERNAL'/*100 '*/) THEN 'Internal Partner'
			WHEN r.FIXED =  'APPLIES_FOR'  /* 3, TERRITORY*/ Then 'Territories'
			WHEN r.FIXED = 'ARCHIVING' THEN 'Internal Partner - Archiving' 
			WHEN r.FIXED = 'ADDITIONAL_DEPARTMENTS_INVOLVED_(OPTIONAL)' /* 109 */ THEN 'Department - Additional' 
			END) AS RoleCategoryFull
	FROM 
	TROLE r

GO
/****** Object:  View [dbo].[V_TheCompany_Edit_Wrong_DPTROLE_IN_OBJECT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_Edit_Wrong_DPTROLE_IN_OBJECT]

as

SELECT 
c.number as Dpt_ContractNumber
, d.DEPARTMENTROLE_IN_OBJECTID
, d.departmentid as ACTUAL_DepartmentID
, d.Dpt_Code_IP_RepOffice 
, d.OBJECTID 
, h.noderole
, (case when h.NodeRole = 'T' THEN 'Territories' 
		When h.NodeRole = 'I' Then 'Internal Partner' 
		WHEN h.NodeRole = 'D' THEN 'Department' END) as noderoleFull /* Wrong tree Value */
, h.DEPARTMENT as NodeDepartmentHierarchy
, c.DEPARTMENT as NodeDepartment
, hu.USERGROUP as NodeUserGroup
, r.roleid
, r.RoleCategory
, r.RoleCategoryFull /* Should be from tree */
, r.role
, h.DEPARTMENT_CODE
, (CASE WHEN d.ROLEID = 1 /* Super User */ THEN c.DEPARTMENT
		WHEN d.roleid = 2 /*contract owner */ THEN  c.DEPARTMENT
		WHEN d.roleid = 15 /* contract responsible */ THEN c.DEPARTMENT
		WHEN d.ROLEID = 3 /* Territories */ THEN c.Territories
		WHEN d.ROLEID = 100 /* Internal Partner */ THEN c.InternalPartners
		END) 
		ACTUAL_Department_Name
		
, (CASE WHEN d.ROLEID = 1 /* Super User */ THEN c.US_PrimaryUserGroup
		WHEN d.roleid = 2 /*contract owner */ THEN  c.UO_PrimaryUserGroup
		WHEN d.roleid = 15 /* contract responsible */ THEN c.UR_PrimaryUserGroup 
		WHEN d.ROLEID = 3 /* Territories */ THEN 
			STUFF(
			(SELECT ',' + d.USERGROUP
			FROM   V_TheCompany_Departmentrole_In_Object d /* use usergroup for full path? */
			WHERE d.objectid = c.contractid
			FOR XML PATH('')),1,1,'')
		WHEN d.ROLEID = 100 /* Internal Partner */ THEN 
			STUFF(
			(SELECT ',' + d.USERGROUP
			FROM   V_TheCompany_Departmentrole_In_Object d /* use usergroup for full path? */
			WHERE d.OBJECTID = c.contractid
			FOR XML PATH('')),1,1,'')
		END) 
		ACTUAL_PrimaryUserGroup

, (CASE WHEN d.ROLEID = 1 /* Super User */ THEN us.DEPARTMENT
		WHEN d.roleid = 2 /*contract owner */ THEN  uo.DEPARTMENT
		WHEN d.roleid = 15 /* contract responsible */ THEN Ur.DEPARTMENT
		WHEN d.ROLEID = 3 /* Territories */ THEN 
			STUFF(
			(SELECT ',' + d.DEPARTMENT
			FROM  TDEPARTMENT d /* use usergroup for full path? */
			WHERE SUBSTRING(d.department_code,2,2) =SUBSTRING(h.department_code,2,2)
			AND SUBSTRING(d.department_code,1,1)=';' /* Territory */
			AND SUBSTRING(d.department_code,4,1)=';' /* only 1 Territory */
			FOR XML PATH('')),1,1,'')
		WHEN d.ROLEID = 100 /* Internal Partner */ AND d.department_code not like '%,,%'/* is not rep office*/ THEN 
			STUFF(
			(SELECT ',' + d.DEPARTMENT
			FROM   TDEPARTMENT d /* use usergroup for full path? */
			WHERE SUBSTRING(d.department_code,2,2) =SUBSTRING(h.department_code,2,2)
			AND SUBSTRING(d.department_code,1,1)=',' /* Internal Partner */
			/* AND SUBSTRING(d.department_code,4,1)=',' */
			FOR XML PATH('')),1,1,'')
		WHEN d.ROLEID = 100 /* Internal Partner */ AND D.department_code like '%,,%'/* is rep office*/ THEN 
			
			(SELECT dpt.DEPARTMENT
			FROM   TDEPARTMENT dpt /* use usergroup for full path? */
			WHERE dpt.DEPARTMENT_CODE = d.Dpt_Code_IP_RepOffice 
			/* AND SUBSTRING(d.department_code,4,1)=',' */)
			
			END) 
		TARGET_Department_Name

, (CASE WHEN d.ROLEID = 1 /* Super User */ THEN us.PRIMARYUSERGROUP
		WHEN d.roleid = 2 /*contract owner */ THEN  uo.PRIMARYUSERGROUP
		WHEN d.roleid = 15 /* contract responsible */ THEN Ur.PRIMARYUSERGROUP
		WHEN d.ROLEID = 3 /* Territories */ THEN 
			STUFF(
			(SELECT ',' + d.USERGROUP
			FROM   dbo.V_TheCompany_VDEPARTMENT_VUSERGROUP d /* use usergroup for full path? */
			WHERE SUBSTRING(d.department_code,2,2) =SUBSTRING(h.department_code,2,2)
			AND SUBSTRING(d.department_code,1,1)=';' /* Territory */
			AND SUBSTRING(d.department_code,4,1)=';' /* only 1 Territory */
			FOR XML PATH('')),1,1,'')
		WHEN d.ROLEID = 100 /* Internal Partner */ THEN 
			STUFF(
			(SELECT ',' + d.USERGROUP
			FROM   dbo.V_TheCompany_VDEPARTMENT_VUSERGROUP d /* use usergroup for full path? */
			WHERE SUBSTRING(d.department_code,2,2) =SUBSTRING(h.department_code,2,2)
			AND SUBSTRING(d.department_code,1,1)=',' /* Internal Partner */
			/* AND SUBSTRING(d.department_code,4,1)=',' */
			FOR XML PATH('')),1,1,'')
		END) 
		TARGET_PrimaryUserGroup /*TARGET_UserGroup_FullPath */
		
/* , (CASE WHEN d.ROLEID = 1 /* Super User */ THEN US.PRIMARYUSERGROUP
		WHEN d.roleid = 2 /*contract owner */ THEN  UO.PRIMARYUSERGROUP
		WHEN d.roleid = 15 /* contract responsible */ THEN UR.PRIMARYUSERGROUP
		WHEN d.ROLEID = 3 /* Territories */ THEN ''
		WHEN d.ROLEID = 100 /* Internal Partner */ THEN ''
		END) 
		TARGET_PrimaryUserGroup */
		
, (CASE WHEN d.ROLEID = 1 /* Super User */ THEN US.DISPLAYNAME
		WHEN d.roleid = 2 /*contract owner */ THEN  UO.DISPLAYNAME
		WHEN d.roleid = 15 /* contract responsible */ THEN UR.DISPLAYNAME
		WHEN d.ROLEID = 3 /* Territories */ THEN ''
		WHEN d.ROLEID = 100 /* Internal Partner */ THEN ''
		END) 
		TARGET_UserDisplayName	
FROM
	V_TheCompany_Departmentrole_In_Object d 
	inner join V_TheCompany_TROLE r on d.roleid = r.roleid
	inner join t_TheCompany_Hierarchy h on d.DEPARTMENTID = h.DEPARTMENTID
	inner join TUSERGROUP hu on h.DEPARTMENTID = hu.DEPARTMENTID
	inner join T_TheCompany_ALL c on d.objectid = c.contractid
	left join /* dbo.V_TheCompany_VUSER_WITH_DPT US */ VUSER US on c.EXECUTORID = US.USERID
	left join /* dbo.V_TheCompany_VUSER_WITH_DPT US */ VUSER UO on c.OWNERID = UO.EMPLOYEEID
	left join /* dbo.V_TheCompany_VUSER_WITH_DPT US */ VUSER UR on c.TECHCOORDINATORID = UR.EMPLOYEEID 
WHERE 
	h.noderole <> r.RoleCategory
	and r.fixed <> 'ARCHIVING' /* exclude Archiving for now */
	and h.DEPARTMENT_CODE > ''
	AND CONTRACTTYPEID NOT in(
		'6' /* Access SAKSNR number Series*/
		, '5' /* Test Old */
		,'102' /* Test New */
		,'13' /* DELETE */
		,'11' /* CASE */ )
	AND c.CONTRACTDATE > '2014-01-01 00:00:00'



GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_ReviewDate_Analysis]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE View

[dbo].[V_T_TheCompany_ALL_ReviewDate_Analysis]

as

	select 
		(Case when CONTRACTTYPE ='Case' then 'Case' Else 'Contract' END) as CaseOrContract
		, 	(Case when AGREEMENT_TYPEID = 5 /* NOT CDA */ then 0
					when CompanyIDList = '1' then 0
					when CONTRACTTYPE ='Case' then 0
					when AGREEMENT_FIXED like '%!AD%' then 0
					Else 1 END) as ReviewDateRequired_FLAG
		, 	(Case when AGREEMENT_TYPEID = 5 /* NOT CDA */ then 'N/A (CDA)'
					when CompanyIDList = '1' then 'N/A (Intercompany)'
					when CONTRACTTYPE ='Case' then 'N/A (Case)'
					when AGREEMENT_FIXED like '%!AD%' then 'N/A (Admin)'
					Else 'Review Date Reminder' END) as ReviewDateRequired_Detail
		, Agr_IsMaterial_Flag
		,a.[REVIEWDATE]
		, (Case when a.[REVIEWDATE] is null then 0
				when a.[REVIEWDATE] >= Getdate() then 1
				when a.[REVIEWDATE] < Getdate() then 0		
				 END) as ReviewDateIsCurrent_FLAG
		, [RD_ReviewDate_Warning]
		, agreement_type
		, a.CONTRACTID
		, number as ContractNumber
		, Title as ContractTitle
		, (case when a.reviewdate is not null then a.reviewdate-getdate() else 0 end) as NumDaysExpired
	from t_TheCompany_all a inner join [dbo].[V_TheCompany_LNC_GoldStandard] g on a.contractid = g.CONTRACTID
	where [FINAL_EXPIRYDATE] is null
	and CONTRACTTYPE <>'Case'

GO
/****** Object:  View [dbo].[V_TheCompany_RegForm_UserGrpUsers]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_RegForm_UserGrpUsers]

as

/* waiting for SSO for user joest */

select TOP 9999 
	gu.USERGROUP
	, DISPLAYNAME as 'UserName'
	, COUNTRY as Country
	, PRIMARYUSERGROUP as 'PrimaryUserGroup'
	, UserProfileGroup as 'UserProfileGroup' /* Only Basic or super user, read all etc. not stated */
	, GETDATE() as Last_Updated 
FROM  V_TheCompany_VUSER u inner join [dbo].[TUSER_IN_USERGROUP] g on u.userid = g.userid
	inner join tusergroup gu on g.USERGROUPID = gu.usergroupid
where 
	 USER_MIK_VALID = 1
	 and gu.usergroupid not in (5197 /* Strictly Confidential */
								,3397 /* Read contract headers */
								, 1089 /* public contracts */
								, 130 /* super users */
								, 4901 /* top secret */
								, 20 /* corp legal */
								)
	and usergroup not like '%all contracts%'
	and usergroup not like 'departments%'
order by 
	gu.Usergroup, DISPLAYNAME

GO
/****** Object:  View [dbo].[V_TheCompany_VDepartment_ParsedDpt_InternalPartner_ACTIVE]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



 CREATE view [dbo].[V_TheCompany_VDepartment_ParsedDpt_InternalPartner_ACTIVE]

  as

  select * from V_TheCompany_VDepartment_ParsedDpt_InternalPartner
  WHERE MIK_VALID = 1
GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_ReviewDate_Analysis_Report]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View

[dbo].[V_T_TheCompany_ALL_ReviewDate_Analysis_Report]

as

	select 

		 (case when reviewdaterequired_flag = 1 and agr_IsMaterial_Flag = 0 and reviewdateiscurrent_flag =0 then 1 else 0 end) 
			as RD_Required_NONMaterial_ExpiredRD
		, (case when reviewdaterequired_flag = 1 and agr_IsMaterial_Flag = 1 and reviewdateiscurrent_flag =0 then 1 else 0 end) 
			as RD_Required_Material_ExpiredRD
		, (case when reviewdaterequired_flag = 1 and reviewdateiscurrent_flag = 1 then 1 else 0 end) 
			as RD_Required_CurrentRD
		, * 
	from 
		V_T_TheCompany_ALL_ReviewDate_Analysis
GO
/****** Object:  View [dbo].[V_TheCompany_ALL]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[V_TheCompany_ALL]

as

SELECT 
	c.[Number]
      ,c.[CONTRACTID]
    ,(case when c.[Title] like '%TOP SECRET%' THEN '*** TOP SECRET ***' ELSE c.[Title] END) as Title
	,c.[Title] as Title_InclTopSecret
      ,c.[CONTRACTTYPE]
      ,c.[CONTRACTTYPEID]

	  /* Agreement type hierarchy */
			, (CASE WHEN AgrType_Top25Flag =1 THEN c.AGREEMENT_TYPE ELSE 'Other' END) 
			  as Agreement_Type_Top25WithOther
			  , AgrType_Top25Flag as Agreement_Type_Top25Flag

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
      ,(case when c.status = 'Awarded' /* awareded */ 
		then 'Active' else c.[STATUS] end) as status /* awarded is changed */
      ,c.[ContractRelations]

      ,c.[NUMBEROFFILES]
      ,null as  [EXECUTORID] /* removed from vcontract 22-feb */
      ,null as  [OWNERID]
      ,null as  [TECHCOORDINATORID]
      ,(case when c.statusid = 4 /* awarded */ then 5 else c.[STATUSID] end) as statusid
      ,(case when c.[StatusFixed] = 'AWARDED' /* awareded */ then 'ACTIVE' else c.[StatusFixed]  end) as StatusFixed

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
      , (CASE
			 WHEN UPPER([Title]) like '%TOP SECRET%' THEN 'TOP SECRET'
			WHEN UPPER([Title]) like '%STRICTLY CONFIDENTIA[*]%' THEN 'STRICTLY CONFIDENTIAL'
			WHEN UPPER([Title]) like '%CONFIDENTIAL[*]%' THEN 'CONFIDENTIAL'
			ELSE 'N/A' END) /*(select [MIK_EDIT_VALUE] 
		FROM [TEXTRA_FIELD_IN_CONTRACT] ef
		WHERE [EXTRA_FIELDID] = 100002 /* Confidentiality Flag */
		AND ef.contractid = c.contractid) */ as ConfidentialityFlagNAME /* heading field replaced, empty string '' field was deleted as of V6.15, no replacement */
		
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

				ELSE [TargetSystem_AgTypeFLAG]	/*(0,1,2,7,8)	*/
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
 
	, [AgrIsDivestment] as AgreementTypeDivestment
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

	, Agr_IsMaterial_Flag
	, AgrIsMaterial
		, TargetSystem_AgTypeFLAG
		, TargetSystem_AgType 
		, AgreementType_IsPrivate_FLAG
		, AgreementType_PublicPrivate
      , (CASE
			 WHEN UPPER([Title]) like '%TOP SECRET%' THEN 1
			WHEN UPPER([Title]) like '%STRICTLY CONFIDENTIA[*]%' THEN 2
			WHEN UPPER([Title]) like '%CONFIDENTIAL[*]%' THEN 3
			ELSE 0 END) /*(select [MIK_EDIT_VALUE] 
		FROM [TEXTRA_FIELD_IN_CONTRACT] ef
		WHERE [EXTRA_FIELDID] = 100002 /* Confidentiality Flag */
		AND ef.contractid = c.contractid) */ as ConfidentialityFLAG_0123 /* heading field replaced, empty string '' field was deleted as of V6.15, no replacement */
	, (case 
		when FINAL_EXPIRYDATE IS not null 
				and DATEDIFF(yy,final_expirydate, getdate()) <=2 
				and statusid <> 5 /* active */ 
				then 1 
		ELSE 0 END) as
		InactiveWithExpiryDateWithinLast2Yrs
		/* (CASE WHEN REV_EXPIRYDATE is not null then REV_EXPIRYDATE else EXPIRYDATE end) */
		, [AgrType_IsHCX_Flag]
FROM 
 V_TheCompany_VCONTRACT c
/* this view turns TCONTRACT nulls into empty strings etc., custom version of VCONTRACT */
/* fields like agreement_type etc  */

	LEFT /*!!!*/ JOIN (SELECT 
		Contractid as US_Contractid
		, userid as US_Userid
	, displayname as US_DisplayName
	, EMAIL as US_Email
	, FIRSTNAME as US_Firstname
	, PRIMARYUSERGROUP as US_PrimaryUserGroup /* field size in TUSERGROUP is 450 char */
	, MIK_VALID US_USER_MIK_VALID 
	, DEPARTMENT_CODE as US_DPT_CODE
	, DEPARTMENT as US_DPT_NAME
	 from dbo.T_TheCompany_VPERSONROLE_IN_OBJECT where [Roleid_Cat2Letter]='US' ) us 
		on c.contractid = us.US_Contractid

	LEFT /*!!!*/ JOIN (SELECT 
		Contractid  as UO_Contractid
		, userid as UO_Userid
	, displayname as UO_DisplayName
	, EMAIL as UO_Email
	, FIRSTNAME as UO_Firstname 
	, PRIMARYUSERGROUP as UO_PrimaryUserGroup /* field size in TUSERGROUP is 450 char */
	, MIK_VALID as UO_USER_MIK_VALID 
	, DEPARTMENT_CODE as UO_DPT_CODE
	, DEPARTMENT as UO_DPT_NAME
	  FROM dbo.T_TheCompany_VPERSONROLE_IN_OBJECT   where [Roleid_Cat2Letter]='UO') uo 
		on c.contractid = uo.UO_Contractid

	LEFT /*!!!*/ JOIN (SELECT 
		Contractid as UR_Contractid
		, userid as UR_Userid
	, displayname as UR_DisplayName
	, EMAIL as UR_Email
	,  FIRSTNAME as UR_Firstname /*, FIRSTNAME */
	, PRIMARYUSERGROUP as UR_PrimaryUserGroup /* field size in TUSERGROUP is 450 char */
	, MIK_VALID as UR_USER_MIK_VALID 
	, DEPARTMENT_CODE as UR_DPT_CODE 
	, DEPARTMENT as UR_DPT_NAME
	  FROM dbo.T_TheCompany_VPERSONROLE_IN_OBJECT  where [Roleid_Cat2Letter]='UR') ur 
		on c.contractid = ur.UR_Contractid

	LEFT /*!!!*/ JOIN T_TheCompany_VCONTRACT_DPTROLES_FLAT d /* view too slow [dbo].[V_TheCompany_VCONTRACT_DPTROLES_FLAT] */ /* 5 SECONDS - made inner join 22-feb */
		on c.contractid = d.Dpt_contractid
				/* NOT NEEDED left join dbo.V_TheCompany_VCONTRACT_PERSONROLES_FLAT pf on c.CONTRACTID = pf.Prs_contractid */
				LEFT join dbo.T_TheCompany_Hierarchy h /* 16 seconds together with d table ; delete from then insert into in mktbl query */
			/* in the daily data load, the hierarchy is refreshed first, so this table is up to date */
				on d.Dpt_ContractOwnerDpt_ID = h.departmentid_link /* owner id can be BLANK so it is defaulted to ggc in data load */

	left join [dbo].[V_TheCompany_VPRODUCTS_FLAT] p /* 1 SECOND - optimized to use CAST and LEFT */
		on c.contractid = p.vp_contractid
				/* NOT NEEDED left join dbo.VCOMMERCIAL vc on c.CONTRACTID = vc.ContractId */

	left join dbo.VCONTRACT_LUMPSUM vc on c.LUMPSUMAMOUNTID = vc.LUMPSUMAMOUNTID /* 1 SECOND */

	left join [dbo].[V_TheCompany_REVIEWDATE_ACTIVE] rd /* 1 SECOND, optimized */
		on c.contractid = rd.RD_Contractid

	inner join V_TheCompany_AgreementType cr  /* 1 SECOND - made inner join 22-feb */
		on c.AGREEMENT_TYPEID = [AgrTypeID]

	left join T_TheCompany_TTENDERER_FLAT /* V_TheCompany_TTENDERER_FLAT */ t /* 1 second */
		on c.contractid = t.CONTRACTID

	/* NOT working because t_TheCompany_all is used in view left join V_TheCompany_Mig_0ProcNetFlag m on c.contractid = m.Contractid_Proc /* for procurement flag */*/
	left join [dbo].[V_TheCompany_Docs_FLAT] doc /* 1 sec, added 09-Dec-2020 */
		on c.contractid = doc.CONTRACTID 
/* done via v_TheCompany_vcontract */
	/* WHERE c.contracttypeid NOT IN (	/*  5 /* Test Old */
									, 6 /* Access SAKSNR number Series*/		
									/*,  11	Case */					
									, 13 /* DELETE */
									, 102 /* Test New */	*/							
								ONLY LISTS ARE NEW 	 103, 104, 105 /* Lists */
									/*, 106 /* AutoDelete */*/
									)
									*/
/* and c.CONTRACTID = 148186 /* contractnumber = 'TEST-00000080' */  */
GO
/****** Object:  View [dbo].[V_TheCompany_Edit_DupeCompanyContractIDs]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create VIEW [dbo].[V_TheCompany_Edit_DupeCompanyContractIDs]

as

SELECT DISTINCT c.CONTRACTID
FROM
V_TheCompany_ALL c inner join TTENDERER t on c.CONTRACTID = t.contractid
WHERE t.COMPANYID in (SELECT COMPANYIDMax 
						from V_TheCompany_Edit_DuplicateCompanies)
GO
/****** Object:  View [dbo].[V_TheCompany_KWS_4_ARB_TCOMPANY_summary_KeyWord]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view 
[dbo].[V_TheCompany_KWS_4_ARB_TCOMPANY_summary_KeyWord]

as 

	SELECT  
		CompanyMatch_KeyWord_UPPER
		, max(s.[Company Names]) AS CompanyMatch_NameList
		/* , companyid */
		, max(CompanyMatch_Name) AS CompanyMatch_Name_Max

		, max(Custom1_Lists) as Custom1_Lists_Max
		, max(Custom2_Lists) as Custom2_Lists_Max
			
		, count(DISTINCT CASE WHEN CompanyMatch_Exact_Flag = 1 
			THEN CompanyMatch_Name ELSE NULL END) as CompanyCount_Exact
		, count(DISTINCT CASE WHEN CompanyMatch_LIKE_FLAG = 1 
			THEN CompanyMatch_Name ELSE NULL END) as CompanyCount_Like
		, count(DISTINCT CASE WHEN 
			CompanyMatch_Exact_Flag = 0 
			AND CompanyMatch_LIKE_FLAG = 0 			
			THEN CompanyMatch_Name ELSE NULL END) as CompanyCount_Other

		, count(DISTINCT CASE WHEN CompanyMatch_Exact_Flag = 1 
			THEN u.[ContractID] ELSE NULL END) as ContractCount_Exact	

		, count(DISTINCT CASE WHEN CompanyMatch_LIKE_FLAG = 1 
			THEN u.[ContractID] ELSE NULL END) as ContractCount_LIKE

		, count(DISTINCT CASE WHEN 
			CompanyMatch_Exact_Flag = 0 
			AND CompanyMatch_LIKE_FLAG = 0 
			THEN u.[ContractID] ELSE NULL END) as ContractCount_Other

		, count(DISTINCT CompanyMatch_Name) as CompanyCount
		, COUNT(DISTINCT u.[ContractID]) as ContractCount

		, min(CompanyMatch_Level) as CompanyMatch_Level_Min

		/* Dates */
		, MAX(s.[End Date]) as StartDate_MIN
		, MAX(s.[End Date]) as EndDate_MIN
		, MAX(s.[End Date]) as StartDate_MAX
		, MAX(s.[End Date]) as EndDate_MAX

	 FROM   [Contiki_app].[dbo].[V_TheCompany_KWS_0_ContikiView_ARB] s
				inner join T_TheCompany_KWS_7_ARB_ContractID_SummaryByContractID u
				on s.contractid = u.[ContractID]
	WHERE 
		CompanyMatch_Score >0
	group by 
		[CompanyMatch_KeyWord_UPPER] /*, companyid */

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_4_LNC_TCOMPANY_summary_KeyWord]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view 
[dbo].[V_TheCompany_KWS_4_LNC_TCOMPANY_summary_KeyWord]

as 

	SELECT  
		CompanyMatch_KeyWord_UPPER
		, max(s.[Company Names]) AS CompanyMatch_NameList
		/* , companyid */
		, max(CompanyMatch_Name) AS CompanyMatch_Name_Max

		, max(Custom1_Lists) as Custom1_Lists_Max
		, max(Custom2_Lists) as Custom2_Lists_Max
			
		, count(DISTINCT CASE WHEN CompanyMatch_Exact_Flag = 1 
			THEN CompanyMatch_Name ELSE NULL END) as CompanyCount_Exact
		, count(DISTINCT CASE WHEN CompanyMatch_LIKE_FLAG = 1 
			THEN CompanyMatch_Name ELSE NULL END) as CompanyCount_Like
		, count(DISTINCT CASE WHEN 
			CompanyMatch_Exact_Flag = 0 
			AND CompanyMatch_LIKE_FLAG = 0 			
			THEN CompanyMatch_Name ELSE NULL END) as CompanyCount_Other

		, count(DISTINCT CASE WHEN CompanyMatch_Exact_Flag = 1 
			THEN u.[ContractID] ELSE NULL END) as ContractCount_Exact	

		, count(DISTINCT CASE WHEN CompanyMatch_LIKE_FLAG = 1 
			THEN u.[ContractID] ELSE NULL END) as ContractCount_LIKE

		, count(DISTINCT CASE WHEN 
			CompanyMatch_Exact_Flag = 0 
			AND CompanyMatch_LIKE_FLAG = 0 
			THEN u.[ContractID] ELSE NULL END) as ContractCount_Other

		, count(DISTINCT CompanyMatch_Name) as CompanyCount
		, COUNT(DISTINCT u.[ContractID]) as ContractCount

		, min(CompanyMatch_Level) as CompanyMatch_Level_Min

		/* Dates */
		, MAX(s.[End Date]) as StartDate_MIN
		, MAX(s.[End Date]) as EndDate_MIN
		, MAX(s.[End Date]) as StartDate_MAX
		, MAX(s.[End Date]) as EndDate_MAX

	 FROM   [Contiki_app].[dbo].[V_TheCompany_KWS_0_ContikiView_LNC] s
				inner join T_TheCompany_KWS_7_LNC_ContractID_SummaryByContractID u
				on s.contractid = u.[ContractID]
	WHERE 
		CompanyMatch_Score >0
	group by 
		[CompanyMatch_KeyWord_UPPER] /*, companyid */

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_4_JPS_TCOMPANY_summary_KeyWord]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view 
[dbo].[V_TheCompany_KWS_4_JPS_TCOMPANY_summary_KeyWord]

as 

	SELECT  
		CompanyMatch_KeyWord_UPPER
		, max(s.[Company Names]) AS CompanyMatch_NameList
		/* , companyid */
		, max(CompanyMatch_Name) AS CompanyMatch_Name_Max

		, max(Custom1_Lists) as Custom1_Lists_Max
		, max(Custom2_Lists) as Custom2_Lists_Max
			
		, count(DISTINCT CASE WHEN CompanyMatch_Exact_Flag = 1 
			THEN CompanyMatch_Name ELSE NULL END) as CompanyCount_Exact
		, count(DISTINCT CASE WHEN CompanyMatch_LIKE_FLAG = 1 
			THEN CompanyMatch_Name ELSE NULL END) as CompanyCount_Like
		, count(DISTINCT CASE WHEN 
			CompanyMatch_Exact_Flag = 0 
			AND CompanyMatch_LIKE_FLAG = 0 			
			THEN CompanyMatch_Name ELSE NULL END) as CompanyCount_Other

		, count(DISTINCT CASE WHEN CompanyMatch_Exact_Flag = 1 
			THEN u.[ContractID] ELSE NULL END) as ContractCount_Exact	

		, count(DISTINCT CASE WHEN CompanyMatch_LIKE_FLAG = 1 
			THEN u.[ContractID] ELSE NULL END) as ContractCount_LIKE

		, count(DISTINCT CASE WHEN 
			CompanyMatch_Exact_Flag = 0 
			AND CompanyMatch_LIKE_FLAG = 0 
			THEN u.[ContractID] ELSE NULL END) as ContractCount_Other

		, count(DISTINCT CompanyMatch_Name) as CompanyCount
		, COUNT(DISTINCT u.[ContractID]) as ContractCount

		, min(CompanyMatch_Level) as CompanyMatch_Level_Min

		/* Dates */
		, MAX(s.[End Date]) as StartDate_MIN
		, MAX(s.[End Date]) as EndDate_MIN
		, MAX(s.[End Date]) as StartDate_MAX
		, MAX(s.[End Date]) as EndDate_MAX

	 FROM   [Contiki_app].[dbo].[V_TheCompany_KWS_0_ContikiView_JPS] s
				inner join T_TheCompany_KWS_7_JPS_ContractID_SummaryByContractID u
				on s.contractid = u.[ContractID]
	WHERE 
		CompanyMatch_Score >0
	group by 
		[CompanyMatch_KeyWord_UPPER] /*, companyid */

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_5_AllSystems_CompanyKWSummary]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE View [dbo].[V_TheCompany_KWS_5_AllSystems_CompanyKWSummary]

as

	select 'Contiki' as DatabaseSource, * from 
	[dbo].[V_TheCompany_KWS_4_CNT_TCOMPANY_summary_KeyWord]

	union all

	select 'Ariba' as DatabaseSource, * from 
	[dbo].[V_TheCompany_KWS_4_ARB_TCOMPANY_summary_KeyWord] 

	union all
	
	select 'JP_Sunrise' as DatabaseSource, * from 
	[dbo].[V_TheCompany_KWS_4_JPS_TCOMPANY_summary_KeyWord] 

	union all
	
	select 'LINC(Axxerion)' as DatabaseSource, * from 
	[dbo].[V_TheCompany_KWS_4_LNC_TCOMPANY_summary_KeyWord] 
GO
/****** Object:  View [dbo].[V_TheCompany_DocxValidSignedNotRegForm]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view
[dbo].[V_TheCompany_DocxValidSignedNotRegForm]
as

SELECT 
	d.DOCUMENTID
	,d.OBJECTID
	,d.[Title] as DescriptionFull
	,hashbytes('SHA1', dbo.TheCompany_RemoveNonAlphaCharacters(d.[Title])) as DescRemNonAlphaHashbSHA1
	,hashbytes('SHA1', d.[Title]) as DescriptionFullHashbSHA1
	, d.Datecreated
	, d.FileType
	, d.FileSize
	/* ,d.MIK_VALID */
	, v.CompanyIDList
	/* , t.DOCUMENTTYPE as documenttype */
FROM VDOCUMENT d 
	INNER JOIN TCONTRACT c on d.OBJECTID = c.contractid
	left join dbo.V_TheCompany_TENDERER_FLAT v on c.contractid = v.contractid
	/* left join dbo.VDocumentTypes t on d.DOCUMENTTYPEID = t.DOCUMENTTYPEID */
WHERE 
	d.MIK_VALID = 1 
	AND d.DOCUMENTTYPEID = 1 /* Signed Contracts */ 
	AND  d.[Title] not like '%REGISTRATION%FORM%'
	/* AND LEN(dbo.TheCompany_RemoveNonAlphaCharacters(d.[DESCRIPTION]))>3 */
	AND c.CONTRACTTYPEID NOT IN (
		   '6' /* Access SAKSNR number Series*/
		,  '5' /* Test Old */
		,'102' /* Test New */
		, '13' /* DELETE */ 
		, '11' /* CASE */)
	AND c.CONTRACTDATE > '2014-01-01 00:00:00'
	



GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_MASTER_IP]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_LNC_Mig_MASTER_IP]

as
/*
select * from 
V_TheCompany_LNC_Mig_DATA_IP
where internalpartnerid not in (select internalpartnerid from [dbo].[V_TheCompany_LNC_Mig_MASTER_IP])
*/

Select 
		'CTK-' + convert(varchar(50),[DEPARTMENTID])
			as INTERNALPARTNERID
		  ,[InternalPartner_Name] as INTERNALPARTNERNAME
		  ,[DEPARTMENT_CODE] as INTERNALPARTNER_CODE
		  /*,[LenDptCode] */
		  ,[InternalPartnerType] as InternalPartnerOrBranch
		 /* ,[DptCode_BranchOffice]
		  ,[Dpt_Code_HeadOffice]
		  ,[DptID_HeadOffice]
		  ,[Code_Basic] */
		  ,[Code_Shortcut]
		  ,[Code_Areas]
		  ,[InternalPartnerStatus]

		 /* ,[InternalPartnerStatusFlag] */
		  ,[InternalPartner_CountryPrefix]
		  ,[DEPARTMENT]
		  ,[MIK_VALID]

			  , IP_ParentName
		  		  , PARENTID

		  ,[BP_CompanyName]
		  ,[Bp_CompanyQuickRef]
		  ,[Bp_CompanyStatus_Code]

		  ,[BC_CompanyNumber]
		  ,[BC_Country]
		  /*,[BC_CompanyStatus] */
		  ,[BC_CompanySubCategory]
		  ,[BC_CountryCode]
		 /* ,[BC_CountryRegion] */
		  ,[BC_CountryRegionCODE]
		  ,[BC_CompanyType]
		  ,[BC_CompanyOccupation]
		  ,[BC_CompanyType_CODE]
		  ,[BC_CompanyKey]
		  ,[BC_CompanyCategory]
		  ,[BC_EntityType]

		  , [IP_Count_Contracts]
		 ,  IP_CostCenter
		 , (case when IP_CostCenter >'' THEN 1 else 0 end) as Ip_CostCenter_IsPopulated
		 , DEPARTMENTID
 , GETDATE() as DateRefreshed
	FROM
		V_TheCompany_VDepartment_ParsedDpt_InternalPartner
	WHERE
		[IP_Count_Contracts]>0 
		/* OR InternalPartnerStatusflag = -1 /* active added 27-feb */ */
		/* missing: departmentid = 201797 */

GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_ReviewDate_Analysis_Report_Final]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE View

[dbo].[V_T_TheCompany_ALL_ReviewDate_Analysis_Report_Final]

as

	select 
	(case when [ReviewDateRequired_FLAG] = 0 then 'RD not required'
		when [ReviewDateIsCurrent_FLAG] = 1 then 'RD is current'
		when  [ReviewDateIsCurrent_FLAG] = 0 then 'RD expired - '
			+ (case when [Agr_IsMaterial_Flag] = 1 then 'Material' else 'NonMaterial' end)
		else '' END) as Category
	,*
	from 
		V_T_TheCompany_ALL_ReviewDate_Analysis_report
GO
/****** Object:  View [dbo].[V_TheCompany_KWS_Keywords_Title_Top5_Concat]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_KWS_Keywords_Title_Top5_Concat]

as

	select distinct

	Replace(STUFF(
	(SELECT top 5 ' ' + s.[KeyWordVarchar255]
	FROM  V_TheCompany_KeyWordSearch s
		
	FOR XML PATH('')),1,1,''),'&amp;','&') AS KeyWordVarchar255_Concat

	
	from V_TheCompany_KeyWordSearch d
GO
/****** Object:  View [dbo].[V_TheCompany_VUSER_MIK_VALID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_VUSER_MIK_VALID]
as

Select * from V_TheCompany_VUSER 
WHERE user_MIK_VALID = 1
GO
/****** Object:  View [dbo].[V_TheCompany_VDepartment_ParsedDpt_IP_DE_LN_IP]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE view [dbo].[V_TheCompany_VDepartment_ParsedDpt_IP_DE_LN_IP]

	as

		select *
	from   [dbo].[V_TheCompany_VDepartment_ParsedDpt_InternalPartner] d 	
	left join [dbo].[V_TheCompany_VDEPARTMENT_Entities_DiligentAndLINC] l
		on upper(d.[InternalPartner_Name_NonSpaceFwSlash]) = upper(l.[EntName_NonFwSlash])
	/*d.InternalPartner_Name = l.EntityName */
GO
/****** Object:  View [dbo].[V_T_TheCompany_ALL_ReviewDate_Analysis_Report_Final_2]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View

[dbo].[V_T_TheCompany_ALL_ReviewDate_Analysis_Report_Final_2]

as

	select 
	Category
   /*  , [RD_Required_Material_ExpiredRD]
	, [RD_Required_NONMaterial_ExpiredRD]
	[ReviewDateRequired_FLAG]
	,[ReviewDateRequired_Detail]


      ,[RD_Required_CurrentRD]*/
      ,[CaseOrContract]
      

      ,[Agr_IsMaterial_Flag]
      ,[REVIEWDATE]
      ,[ReviewDateIsCurrent_FLAG]
      /* ,[RD_ReviewDate_Warning] */
      ,[agreement_type]
      ,[CONTRACTID]
      ,[ContractNumber]
      ,[ContractTitle]
	  , NumDaysExpired
	from 
	[dbo].[V_T_TheCompany_ALL_ReviewDate_Analysis_Report_Final]

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_6_AllSystems_CompanyKeywordSummary]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE View [dbo].[V_TheCompany_KWS_6_AllSystems_CompanyKeywordSummary]

as
	select 'CNT' AS SRC, *
		, [ContractCount] AS 'ContractCount_CNT'
		, 0 AS 'ContractCount_ARB'
		, 0 AS 'ContractCount_LNC'	
		, 0 AS 'ContractCount_JPS'

		, [EndDate_MIN] AS 'CNT_EndDate_MIN'
		, NULL AS 'ARB_EndDate_MIN'
		, NULL AS 'LNC_EndDate_MIN'
		, NULL AS 'JPS_EndDate_MIN'

	from 
	[dbo].[V_TheCompany_KWS_4_CNT_TCOMPANY_summary_KeyWord]

	union all

	select 'ARB' AS SRC, * /* ARIBA */
		, 0 AS 'ContractCount_CNT'
		, [ContractCount] AS 'ContractCount_ARB'
		, 0 AS 'ContractCount_LNC'	
		, 0 AS 'ContractCount_JPS'

		, NULL AS 'CNT_EndDate_MIN'
		, [EndDate_MIN] AS 'ARB_EndDate_MIN'
		, NULL AS 'LNC_EndDate_MIN'
		, NULL AS 'JPS_EndDate_MIN'

	from 
	[dbo].[V_TheCompany_KWS_4_ARB_TCOMPANY_summary_KeyWord] 

	union all
	
	select 'LNC' AS SRC, * /* LNC */
		, 0 AS 'ContractCount_CNT'
		, 0 AS 'ContractCount_ARB'
		, [ContractCount] AS 'ContractCount_LNC'	
		, 0 AS 'ContractCount_JPS'

		, NULL AS 'CNT_EndDate_MIN'
		, NULL AS 'ARB_EndDate_MIN'
		, [EndDate_MIN] AS 'LNC_EndDate_MIN'
		, NULL AS 'JPS_EndDate_MIN'

	from 
	[dbo].[V_TheCompany_KWS_4_LNC_TCOMPANY_summary_KeyWord] 

	union all
	
	select 'JPS' AS SRC, * /* JPS */
		, 0 AS 'ContractCount_CNT'
		, 0 AS 'ContractCount_ARB'
		, 0 AS 'ContractCount_LNC'	
		, [ContractCount] AS 'ContractCount_JPS'

		, NULL AS 'CNT_EndDate_MIN'
		, NULL AS 'ARB_EndDate_MIN'
		, NULL AS 'LNC_EndDate_MIN'
		, [EndDate_MIN] AS 'JPS_EndDate_MIN'
	from 
	[dbo].[V_TheCompany_KWS_4_JPS_TCOMPANY_summary_KeyWord] 
GO
/****** Object:  View [dbo].[V_TheCompany_VDOCUMENT_XT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_VDOCUMENT_XT]

as 

select * 
, (case when d.title in (
	select title
	from V_TheCompany_VDOCUMENT a
	where mik_valid = 1 and a.contractid = d.contractid
	group by contractid, [title],filetype
	having count(*)>1)
		then 
		title + '_V'+ CONVERT(VARCHAR, versiondate ,23)+'_Doc'+cast(documentid as varchar(10)) 
		else title
		end) as Title_NoDupe
from v_TheCompany_VDOCUMENT d
/*
select contractid, documentid, title

/*+ '_' + cast(ROW_NUMBER() OVER(PARTITION BY contractid, title ORDER BY documentid ASC)  as varchar(10))
     
	 */
	 , 'UPDATE tdocument set description = ''' 
		+ title + '_V'+ CONVERT(VARCHAR, versiondate ,23)+'_Doc'+cast(documentid as varchar(25)) + ''' WHERE DOCUMENTID = ' + cast(documentid as varchar(25))
from v_TheCompany_vdocument d
where filetype = '.txt' and title in 
	order by contractid, title*/
GO
/****** Object:  View [dbo].[V_TheCompany_VDEPARTMENTROLE_IN_OBJECT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view

[dbo].[V_TheCompany_VDEPARTMENTROLE_IN_OBJECT]

AS

SELECT 
	*
	, 	(CASE 
		WHEN ROLEID IN(1,19,20,34,23 /*Super User*/) THEN 'US'
		WHEN ROLEID IN(2 /* Contract Owner*/) THEN 'UO'
		WHEN ROLEID IN(15 /* Contract responsible */, 36 /* 36 = Contract Responsible - AMD */) THEN 'UR'
		WHEN ROLEID IN(0,6/*ENTITY*/,100 /*INTERNAL PARTNER*/) THEN 'IP'
		WHEN ROLEID IN(3 /*TERRITORY*/) THEN 'TT'
		WHEN ROLEID IN(103 /* HARDCOPY ARCHIVING */) THEN 'HA'
		WHEN ROLEID IN(109 /* Additional Departments Involved (OPTIONAL) */) THEN 'DI'		 
		ELSE '' END)
		AS Roleid_Cat2Letter

			, 	(CASE 
		WHEN ROLEID IN(1,19,20,34,23 /*Super User*/) THEN 'P'
		WHEN ROLEID IN(2 /* Contract Owner*/) THEN 'P'
		WHEN ROLEID IN(15 /* Contract responsible */, 36 /* 36 = Contract Responsible - AMD */) THEN 'P'
		WHEN ROLEID IN(0,6/*ENTITY*/,100 /*INTERNAL PARTNER*/) THEN 'D'
		WHEN ROLEID IN(3 /*TERRITORY*/) THEN 'D'
		WHEN ROLEID IN(103 /* HARDCOPY ARCHIVING */) THEN 'D'
		WHEN ROLEID IN(109 /* Additional Departments Involved (OPTIONAL) */) THEN 'D'		 
		ELSE '' END)
		AS Roleid_TT_IP_or_US_UO_UR

FROM TDEPARTMENTROLE_IN_OBJECT d
/* where OBJECTTYPEID = 1 /* contract */ */

GO
/****** Object:  View [dbo].[V_TheCompany_VDEPARTMENTROLE_IN_OBJECT_Xt]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view

[dbo].[V_TheCompany_VDEPARTMENTROLE_IN_OBJECT_Xt]

AS

SELECT 
	d.DEPARTMENTROLE_IN_OBJECTID /*PK*/

	, d.OBJECTID
	, d.OBJECTTYPEID
	, d.[Roleid_Cat2Letter]
	, d.Roleid_TT_IP_or_US_UO_UR
	, r.* 

FROM V_TheCompany_VDEPARTMENTROLE_IN_OBJECT d
	inner join V_TheCompany_VDepartment_Parsed r
		on d.DEPARTMENTID = r.DEPARTMENTID
		and d.OBJECTTYPEID = 1 /* contract */

GO
/****** Object:  View [dbo].[V_TheCompany_VDEPARTMENTROLE_IN_OBJECT_Xt_IP]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[V_TheCompany_VDEPARTMENTROLE_IN_OBJECT_Xt_IP]
/* used in BO PROD Universe */
as 

	select 
	r.* 
	, p.Code_BasicIPWithCommaPrefix
	from V_TheCompany_VDepartmentrole_In_Object_Xt r 
		inner join V_TheCompany_VDepartment_ParsedDpt_InternalPartner p on r.departmentid = p.departmentid 
	where 
		[Roleid_TT_IP_or_US_UO_UR] = 'D' /* department */
		and [Roleid_Cat2Letter] = 'IP' /* internal partner */

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_7_AllSystems_CompanyKWSummary_Final]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[V_TheCompany_KWS_7_AllSystems_CompanyKWSummary_Final]

AS

SELECT [CompanyMatch_KeyWord_UPPER]
	/*, MAX([CompanyMatch_NameList]) as [CompanyMatch_NameList_Max] */
	,ltrim(Replace(STUFF(
		(SELECT ',' + s.CompanyMatch_NameList + ' (' + s.src + ') '
		FROM V_TheCompany_KWS_6_AllSystems_CompanyKeywordSummary s
		WHERE s.CompanyMatch_KeyWord_UPPER =k.CompanyMatch_KeyWord_UPPER
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS CompanyMatch_NameList


      , max([Custom1_Lists_Max]) as [Custom1_Lists_Max]
      , max([Custom2_Lists_Max]) as [Custom2_Lists_Max]
      , sum([CompanyCount_Exact]) as [CompanyCount_Exact]
      , sum([CompanyCount_Like]) as [CompanyCount_Like]
      , sum([CompanyCount_Other]) as  [CompanyCount_Other]
      , sum([ContractCount_Exact]) as [ContractCount_Exact]
      , sum([ContractCount_LIKE]) as [ContractCount_LIKE]
      , sum([ContractCount_Other]) as [ContractCount_Other]
      , sum([CompanyCount]) as [CompanyCount]

      , min([CompanyMatch_Level_Min]) as [CompanyMatch_Level_Min]

      , sum([ContractCount]) as [ContractCount]
      , sum([ContractCount_CNT]) as [CNT_CtCount]
      , sum([ContractCount_ARB]) as [ARB_CtCount]
      , sum([ContractCount_LNC]) as [LNC_CtCount]
      , sum([ContractCount_JPS]) as [JPS_CtCount]

	  , MIN(case 
		  when [CNT_EndDate_MIN] IS not null 
			AND ([ARB_EndDate_MIN] is null 
				OR [CNT_EndDate_MIN] < [ARB_EndDate_MIN]) THEN [CNT_EndDate_MIN] /*  + '(CNT)' */
		  when [ARB_EndDate_MIN] IS not null then [ARB_EndDate_MIN] /*+ '(ARB)' */
		  when [LNC_EndDate_MIN] IS not null then [LNC_EndDate_MIN] /*+ '(LNC)' */
		  when [JPS_EndDate_MIN] IS not null then [JPS_EndDate_MIN] /*+ '(JPS)' */
		  ELSE NULL END
		  ) AS EndDate_MIN

      , MIN([CNT_EndDate_MIN]) as [CNT_EndDate_MIN]
      , MIN([ARB_EndDate_MIN]) as [ARB_EndDate_MIN]
      , MIN([LNC_EndDate_MIN]) as [LNC_EndDate_MIN]
      , MIN([JPS_EndDate_MIN]) as [JPS_EndDate_MIN]


  FROM [Contiki_app].[dbo].[V_TheCompany_KWS_6_AllSystems_CompanyKeywordSummary] k
  where CompanyMatch_KeyWord_UPPER is not null
  GROUP BY [CompanyMatch_KeyWord_UPPER]

GO
/****** Object:  View [dbo].[VOBJECTNAME]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VOBJECTNAME]
AS
SELECT DISTINCT 
                      OT.OBJECTTYPEID, OT.OBJECTTYPE, OT.FIXED OBJECTTYPEFIXED, T.CONTRACTID OBJECTID, T.CONTRACTNUMBER + ISNULL(' - ' + T.CONTRACT, '') OBJECTNAME
FROM         TOBJECTTYPE OT, TCONTRACT T
WHERE     OT.FIXED = 'CONTRACT'
UNION
SELECT DISTINCT 
                      OT.OBJECTTYPEID, OT.OBJECTTYPE, OT.FIXED OBJECTTYPEFIXED, T.TENDERERID OBJECTID, C.CONTRACTNUMBER + ISNULL(' / ' + CY.COMPANY, '') OBJECTNAME
FROM         TOBJECTTYPE OT, TTENDERER T, TCOMPANY CY, TCONTRACT C
WHERE     OT.FIXED = 'TENDERER' AND C.CONTRACTID = ISNULL(T.CONTRACTID, (SELECT TOP 1 R.CONTRACTID FROM TRFX R WHERE R.RFXID = T.RFXID)) AND CY.COMPANYID = T.COMPANYID
UNION
SELECT DISTINCT 
                      OT.OBJECTTYPEID, OT.OBJECTTYPE, OT.FIXED OBJECTTYPEFIXED, T.AMENDMENTID OBJECTID, CONVERT(VARCHAR, T.AMENDMENTNUMBER) 
                      + ' - ' + T.AMENDMENT OBJECTNAME
FROM         TOBJECTTYPE OT, TAMENDMENT T
WHERE     OT.FIXED = 'AMENDMENT'
UNION
SELECT DISTINCT 
                      OT.OBJECTTYPEID, OT.OBJECTTYPE, OT.FIXED OBJECTTYPEFIXED, T.VOID OBJECTID, CONVERT(VARCHAR, T.VONUMBER) + ISNULL(' - ' + T.VO, '') OBJECTNAME
FROM         TOBJECTTYPE OT, TVO T
WHERE     OT.FIXED = 'VO'
UNION
SELECT DISTINCT 
                      OT.OBJECTTYPEID, OT.OBJECTTYPE, OT.FIXED OBJECTTYPEFIXED, T.CALLOFFID OBJECTID, ISNULL(CONVERT(VARCHAR, T.MIK_SEQUENCE), '') 
                      + ISNULL(' - ' + T.[DESCRIPTION], '') OBJECTNAME
FROM         TOBJECTTYPE OT, TCALLOFF T
WHERE     OT.FIXED = 'CALLOFF'
UNION
SELECT DISTINCT 
                      OT.OBJECTTYPEID, OT.OBJECTTYPE, OT.FIXED OBJECTTYPEFIXED, T.SERVICE_ORDERID OBJECTID, ISNULL(CONVERT(VARCHAR, T.SERVICE_ORDER_NUMBER), '') 
                      + ISNULL(' - ' + CONVERT(VARCHAR, T.REVISION), '') OBJECTNAME
FROM         TOBJECTTYPE OT, TSERVICE_ORDER T
WHERE     OT.FIXED = 'SERVICE_ORDER'
UNION
SELECT DISTINCT OT.OBJECTTYPEID, OT.OBJECTTYPE, OT.FIXED OBJECTTYPEFIXED, T.OPTIONID OBJECTID, ISNULL(T.OPTIONNAME, '') OBJECTNAME
FROM         TOBJECTTYPE OT, TOPTION T
WHERE     OT.FIXED = 'OPTION'
UNION
SELECT DISTINCT 
                      OT.OBJECTTYPEID, OT.OBJECTTYPE, OT.FIXED OBJECTTYPEFIXED, T.VORID OBJECTID, CONVERT(VARCHAR, T.VORNUMBER) + ISNULL(' - ' + T.VOR, '') OBJECTNAME
FROM         TOBJECTTYPE OT, TVOR T
WHERE     OT.FIXED = 'VOR'
UNION
SELECT DISTINCT OT.OBJECTTYPEID, OT.OBJECTTYPE, OT.FIXED OBJECTTYPEFIXED, T.VIID OBJECTID, CONVERT(VARCHAR, T.VINUMBER) + ISNULL(' - ' + T.VI, '') OBJECTNAME
FROM         TOBJECTTYPE OT, TVI T
WHERE     OT.FIXED = 'VI'
UNION
SELECT DISTINCT 
                      OT.OBJECTTYPEID, OT.OBJECTTYPE, OT.FIXED OBJECTTYPEFIXED, T.PROJECTID OBJECTID, ISNULL(T.PROJECT_NUMBER, '') + ISNULL(' - ' + T.PROJECT, '') OBJECTNAME
FROM         TOBJECTTYPE OT, TPROJECT T
WHERE     OT.FIXED = 'PROJECT'
UNION
SELECT DISTINCT OT.OBJECTTYPEID, OT.OBJECTTYPE, OT.FIXED OBJECTTYPEFIXED, T.COMPANYID OBJECTID, CASE ISNULL(T.COMPANYNO,'') WHEN '' THEN '' ELSE T.COMPANYNO+' - ' END + ISNULL(T.COMPANY, '') OBJECTNAME
FROM         TOBJECTTYPE OT, TCOMPANY T
WHERE     OT.FIXED = 'COMPANY'
UNION
SELECT DISTINCT OT.OBJECTTYPEID, OT.OBJECTTYPE, OT.FIXED OBJECTTYPEFIXED, T.RFXID OBJECTID, ISNULL(T.INTERNALNUMBER + ' - ', '') + ISNULL(T.RFX, '') OBJECTNAME
FROM         TOBJECTTYPE OT, TRFX T
WHERE     OT.FIXED = 'RFX'
UNION
SELECT DISTINCT OT.OBJECTTYPEID, OT.OBJECTTYPE, OT.FIXED OBJECTTYPEFIXED, T.RFXINTERESTID OBJECTID, ISNULL([EXTERNALNUMBER],ISNULL([INTERNALNUMBER], '')) + ISNULL(' - ' + [COMPANYNAME],'') OBJECTNAME
FROM         TOBJECTTYPE OT, TRFXINTEREST T
JOIN [TRFX] ON T.RFXID = [TRFX].RFXID LEFT OUTER JOIN [TRFXINTERESTEDPARTY] ON T.RFXINTERESTEDPARTYID = [TRFXINTERESTEDPARTY].RFXINTERESTEDPARTYID
WHERE     OT.FIXED = 'RFXINTEREST'
UNION
SELECT DISTINCT OT.OBJECTTYPEID, OT.OBJECTTYPE, OT.FIXED OBJECTTYPEFIXED, T.ORDERID OBJECTID, CONVERT(VARCHAR, T.ORDERNUMBER) + ISNULL(' - ' + T.ORDERNAME, '') OBJECTNAME
FROM         TOBJECTTYPE OT, TORDER T
WHERE     OT.FIXED = 'ORDER'
UNION
SELECT DISTINCT OT.OBJECTTYPEID, OT.OBJECTTYPE, OT.FIXED OBJECTTYPEFIXED, T.RPROCESSID OBJECTID, CONVERT(VARCHAR, T.RPROCESSNUMBER) + ISNULL(' - ' + T.DESCRIPTION, '') OBJECTNAME
FROM         TOBJECTTYPE OT, TRPROCESS T
WHERE     OT.FIXED = 'RPROCESS'


GO
/****** Object:  View [dbo].[V_TheCompany_VACL_Contract_ReadPrivilege]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_TheCompany_VACL_Contract_ReadPrivilege]

AS

SELECT /* TOP 1  */
                     a.ACLID
		 , a.OBJECTTYPEID
			, a.OBJECTID
			 , a.USERID
			, a.PRIVILEGEID

			, o.OBJECTNAME
			, o.OBJECTTYPE 
            , o.OBJECTTYPEFIXED

			, u.DISPLAYNAME
			, u.USERINITIAL
					  , g.USERGROUPID
					  , 'Read' as PRIVILEGE 



					/*  , u.ISEXTERNALUSER */
					  , g.USERGROUP
					  , g.GrpDptGroupIsGGC_Tax_Finance_FLAG
					  , u.USER_MIK_VALID AS USERMIKVALID
					  , g.FIXED AS USERGROUPFIXED
					  , g.MIK_VALID AS USERGROUPMIKVALID
					  , (case when u.userid IS not null then 'User' else 'Group' end) as ACL_UserOrGroup
					  , c.[ConfidentialityFLAG_0123]
FROM         
                      dbo.TACL a
						/* INNER JOIN dbo.TPRIVILEGE p ON a.PRIVILEGEID = p.PRIVILEGEID */
						INNER JOIN dbo.VOBJECTNAME o ON a.OBJECTID = o.OBJECTID 
						/* dbo.V_TheCompany_TCONTRACT_ACL_Auto_Excl_TstDelMig takes too long */
						INNER JOIN t_TheCompany_all c on a.objectid = c.contractid /* (tcontract changed to t_TheCompany_all excl Test etc. )*/

						LEFT JOIN dbo.VUSER u ON a.USERID = u.USERID
						LEFT JOIN V_TheCompany_VDEPARTMENT_VUSERGROUP /* 23-feb */
							g ON a.GROUPID = g.USERGROUPID /* for GrpDptGroupIsGGC_Tax_Finance_FLAG */
					WHERE 
						a.OBJECTID IS NOT NULL /* do not remove OBJECTID = null items, system permissions */						
						AND a.OBJECTTYPEID = 1 /* contract only */
						and a.PRIVILEGEID = 1 /* READ */
						and (a.GROUPID is not null or a.USERID is not null) /* hide system privileges */
						/* and g.GrpDptGroupIsGGC_Tax_Finance_FLAG = 0 /* not a read all user */*/
						/*
						and
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
							AND [COUNTERPARTYNUMBER] not like '!AUTODELETE%')) not needed if t_TheCompany_all*/
GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_DATA_ACL]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[V_TheCompany_LNC_Mig_DATA_ACL]

as 

SELECT 
       [OBJECTID] AS CONTRACTID /* do not filter out, needed to filter for gold standard id */
		/* ACL_UserOrGroup */
     /* , u.[DISPLAYNAME] as 'User Name' */
	  , u.EMAIL
      , p.userinitial as 'User ID'

	  , u.DEPARTMENT
	  , u.DEPARTMENT_CODE
     /* ,[USERGROUP] as 'User Group' */
    /*  ,[OBJECTTYPEFIXED] */
	 /*,  [OBJECTTYPEID] */ /* always 1 */

      ,[OBJECTNAME]

     /* ,[PRIVILEGE] */
      ,[USERMIKVALID]

		/*,[USERGROUPID] */
		      ,p.[USERID]
	/*	,[PRIVILEGEID]*/
	  ,[ACLID] /* don't hide until the end */

	, [ConfidentialityFLAG_0123] 
	 , GETDATE() as DateRefreshed
  FROM V_TheCompany_VACL_Contract_ReadPrivilege p 
		inner join V_TheCompany_VUSER u 
			on p.USERID = u.USERID 
				and u.USER_MIK_VALID = 1
  WHERE 
	/* OBJECTID = 148186 /* contractnumber = 'TEST-00000080' */ - filter in query */
	[ConfidentialityFLAG_0123] >0 /* individual permissions if confidential, strictly confidential or TS */	
	/* and (usergroupid is null or usergroupid not in  ( 0 /* sys admin */
									/*, 20 /* Legal */*/
									, 126 /* System Internal */
									/*, 130 /* Super users */
									, 137 /* Read All */
									, 1089 /* Public */
									, 3397 /* Read all Headers */
									, 4901 /* Top Secret */)*/
									)
		) */
	and ( p.USERID not in  (0, 1, 20134)) /* USERINITIAL = 'contikiadmin' */
	and u.[UserDepartment_Is_LegalFinanceTax_FLAG] = 0
	and u.UserPrimaryUserGroup_Is_LegalFinanceTax_FLAG = 0 /* not an all access user anyway, field has ISNULL */

GO
/****** Object:  View [dbo].[VPRODUCTGROUP]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VPRODUCTGROUP]
AS
SELECT     TOP 100 PERCENT dbo.TPRODUCTGROUP.PRODUCTGROUPID, dbo.TPRODUCTGROUP.PRODUCTGROUP, dbo.TPRODUCTGROUP.PARENTID, 
                      dbo.TPRODUCTGROUP.PRODUCTGROUPNOMENCLATUREID, dbo.TPRODUCTGROUP.MIK_VALID AS PRGMIK_VALID, 
                      dbo.TPRODUCTGROUP.PRODUCTGROUPCODE, dbo.TPRODUCTGROUPNOMENCLATURE.PRODUCTGROUPNOMENCLATURE, 
                      dbo.TPRODUCTGROUPNOMENCLATURE.FIXED AS NOMFIXED, dbo.TPRODUCTGROUPNOMENCLATURE.MIK_VALID AS NOMMIK_VALID
FROM         dbo.TPRODUCTGROUPNOMENCLATURE INNER JOIN
                      dbo.TPRODUCTGROUP ON 
                      dbo.TPRODUCTGROUPNOMENCLATURE.PRODUCTGROUPNOMENCLATUREID = dbo.TPRODUCTGROUP.PRODUCTGROUPNOMENCLATUREID
WHERE     (dbo.TPRODUCTGROUP.MIK_VALID = 1) AND (dbo.TPRODUCTGROUPNOMENCLATURE.MIK_VALID = 1)
ORDER BY dbo.TPRODUCTGROUPNOMENCLATURE.PRODUCTGROUPNOMENCLATURE, dbo.TPRODUCTGROUP.PRODUCTGROUPCODE



GO
/****** Object:  View [dbo].[V_TheCompany_RegForm_ProdGrp]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_RegForm_ProdGrp]

as

/* waiting for SSO for user joest */

select TOP 9999 
PRODUCTGROUPNOMENCLATURe as 'GroupName'
, PRODUCTGROUP as 'ProductName'
, (CASE WHEN PRODUCTGROUPNOMENCLATURE = 'Active Product Ingredients' THEN 'API'
		WHEN  PRODUCTGROUPNOMENCLATURE = 'Trade Names' THEN '_TN'
		WHEN  PRODUCTGROUPNOMENCLATURE = 'Indirect Procurement' THEN 'IP'
		WHEN  PRODUCTGROUPNOMENCLATURE = 'Direct Procurement' THEN 'DP'
ELSE PRODUCTGROUPNOMENCLATURE END) + ' - ' + PRODUCTGROUP as 'GroupNameAndProduct'
, PRODUCTGROUPCODE as 'ProductCode'
, GETDATE() as Last_Updated
FROM  vproductgroup
where 
 NOMMIK_VALID = 1 and PRGMIK_VALID = 1
order by PRODUCTGROUPNOMENCLATURE, PRODUCTGROUP


GO
/****** Object:  View [dbo].[v_TheCompany_WarningsFutureWithInactiveUsers]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[v_TheCompany_WarningsFutureWithInactiveUsers]

as

select w.WARNING
, w.description
,w.objectname
, w.WARNINGFIELDNAME
, w.WARNINGDATE
, w.WARNINGFIELDDATE
, w.ISACTIVE
, w.userid
, u.USER_MIK_VALID
, u.DISPLAYNAME
,c.NUMBER, c.Title
from TWARNING w inner join T_TheCompany_ALL c on w.OBJECTID = c.CONTRACTID
left join VUSER u on u.USERID = w.USERID
where WARNINGDATE > GETDATE()
and w.USERID not in (select USERID from VUSER where USER_MIK_VALID =1)
GO
/****** Object:  View [dbo].[V_TheCompany_KWS_0_ContikiView_ARB]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE view  [dbo].[V_TheCompany_KWS_0_ContikiView_ARB]

as 

select 

      [contractnumber] as [ContractNumber] /* LINC contracts are entered as e.g. LSHR_CON-20010346 */
      ,[Contract Description] as [Contract Description]
	  , [Hierarchy Type] as [Contract Relation]
      , [Contract Type] as [Agreement Type]
	  , (CASE WHEN [Contract Type] in (select AGREEMENT_TYPE from [dbo].[T_TheCompany_AgreementType_ARIBA]
			 where AgrIsMaterial =1) THEN 'Yes' ELSE 'No' END) as 'Agreement Type Divestment'	 
      ,[State] as [Status] /* State = 'Active', 'Completed' 
	  means [Contract Status] of Published, Draft, Draft Amendment, Pending, On Hold, or Expired */
      ,[Begin Date] AS [Registered Date] /* for migrated contracts this seems to be the import date */
      ,'' AS [Reg Date Cat]
      ,[Effective Date - Date] as [Start Date] /*[EndDateDate]*/

	  /* Expiration date - can be 2099 etc. 
		ETL Ariba data load 2: 	update T_TheCompany_Ariba_Dump_Raw_FLAT  set [Expiration Date - Date] = null WHERE 
			[state] = 'Active' /* 'term type' perpetual overrides expiration date */
			and ([Expiration Date - Date] < [datetablerefreshed])*/
      , [Expiration Date - Date] as [End Date] /*[ExpirationDateDate]*/

      ,[Due Date - Date] AS [Review Date]
      ,convert(date,NULL) AS [Review Date Reminder]
	  /* , isnull([study number],'') as [Study Number] */
	  ,[All Products]
      /* ,isnull([Additional Comments],'') as [Comments] */
      ,0 AS [Number of Attachments]

      , ISNULL([Affected Parties - Common Supplier Concat],'') as [Company Names] /* do not use all suppliers concat, since project name is also there */
      /* intercompany: not possible to pull out, attempts: select * from V_TheCompany_KWS_0_ContikiView_ARB where 
[Company Names] like '%intercompany%'
OR [Contract Description] like '%intercompany%'
/* NOT OR [Company Names] like '%TheCompany%' since internal and external mixed */ */
	  ,0 AS [Company Count] , '' as [Company Countries] 
      ,'' as [Confidentiality Flag]
       ,'' AS [Super User Email]
      ,'' AS [Super User Primary User Group]
      ,0 as [Super User Active Flag]
      ,[Owner Name Concat] as [Owner Name]
      ,[Business Owner - User] as [Owner Email]
      ,'' AS [Owner Primary User Group]
      , [Contract Signatory - User Concat] AS [Contract Responsible Email]
      ,'' AS [Responsible Primary User Group]
   
      ,[Contracting Legal Entity] AS [Internal Partners]  
      ,0 AS [Internal Partners Count]
      ,[Region - Region Concat] AS [Territories]
      ,[Region - Region Count] AS [Territories Count]
      ,'' AS [Active Ingredients]
      ,'' AS [Trade Names]
      ,[Amount_EUR] as [Lump Sum]
      ,'EUR' as [LumpSumCurrency]
      , [Tags]
      ,'' as [L0]
      ,[Region - Region Concat] as[L1] /* not the owner region like in Contiki but all we have */
      ,'' as [L2]
      ,'' as [L3]
      ,'' as [L4]
      ,'Contract' as [Contract Type (Contract Case)] /* do not mix up with agreement type */
	   	  , convert(varchar,[ContractInternalID] ) AS ContractID /* Letters */ 
		/*  	  , NULL as AGREEMENT_TYPEID */
		, '' AS [Company Country is US]
		, '' as Comments
		/* Link and Date Must be last 2 columns! */
      ,[LinkToContractURL]
      ,[DateTableRefreshed] as [DateTableRefreshed] 

  FROM [dbo].[T_TheCompany_AribaDump] d

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_DWH_AllSystems_Union]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [dbo].[V_TheCompany_KWS_DWH_AllSystems_Union]
/* purpose: Business Objects?? */
as

/* CONTIKI */

	SELECT 
	1 as SourceSystem,
	* 
	FROM T_TheCompany_ALL

	UNION ALL

/* ARIBA */

	SELECT 2 as SourceSystem,
	 [ContractNumber] as [Number] /* cannot use internal id otherwise Contiki numbers cannot be found by number e.g. matches pattern %11139903  */
		  ,0 as [CONTRACTID] /* cannot use true id since it is a string and Contiki a number, not unionable */
		  ,[Contract Description] as [Title]
		  ,'' as [Title_InclTopSecret]
		  ,'' as [CONTRACTTYPE]
		  , 12 /* Contract */ as [CONTRACTTYPEID] /* to make sure Ariba contracts not filtered out in BO on filter contracctypeid not test delete */
		  ,'' as [Agreement_Type_Top25WithOther]
		  ,'' as [Agreement_Type_Top25Flag]
		  , [contractid] as [REFERENCENUMBER] /* friendly Ariba number */
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
		  ,'' as [Confidentiality Flag]
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
		  , '' as AgreementTypeDivestment
		  , '' as ReviewDate_Reminder_RecipientList
		  , '' as CompanyCountryList
		  , '' as CompanyCountry_IsUS
		, '' as CompanyActivityDateMax
	  FROM 
	  V_TheCompany_KWS_0_ContikiView_ARB

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_1_LNC_MiscMetadataFields]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view 
[dbo].[V_TheCompany_KWS_1_LNC_MiscMetadataFields]

as 

	SELECT  
		s.KeyWordVarchar255
		, s.KeyWordType
		, s.KeyWordPrecision
		, s.KeyWordOperator
		, p.[Contract type] /* is agreement type */ + (case when p.[Contract type] /* is agreement type */ not like '%'+s.KeyWordVarchar255+'%' 
				THEN + ' - ' + p.Description ELSE ''
				END) 
				as 'FieldContent'
		, p.[Reference] as CONTRACTID

	FROM [V_TheCompany_KeyWordSearch] s 
		inner join T_TheCompany_KWS_0_Data_LINC p 
			on p.[Contract type] /* is agreement type */
				like '%'+s.KeyWordVarchar255+'%' /* NO type for e.g. supply */
			OR p.Description like '%'+s.KeyWordVarchar255+'%' /* e.g. supply agreement does not exist as agreement type */
	where /* p.statusid = 5  active */
		s.KeyWordtype = 'AgreementType'

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_7_LNC_ContractID_SummaryByContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view

[dbo].[V_TheCompany_KWS_7_LNC_ContractID_SummaryByContractID]

as 
/* EXEC [dbo].[TheCompany_KeyWordSearch] */
	SELECT  
		u.contractid /* as ContractID_KWS */

/* COMPANY */
	
	/* EXACT */

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ',' + c.[CompanyMatch_Exact] 
			FROM [T_TheCompany_KWS_3_LNC_TCompany_ContractID_Extended] c
			WHERE  c.contractid = u.contractid 
				AND c.companyMatch_Exact_Flag > 0
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [CompanyMatch_Exact]
		,
			(SELECT max(CompanyMatch_Exact_Flag)
			FROM [T_TheCompany_KWS_3_LNC_TCompany_ContractID_Extended] c
			WHERE  c.contractid = u.contractid)
			 AS [CompanyMatch_Exact_FLAG]
	/* LIKE */
			,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + c.[CompanyMatch_Like] /*+': ' 

				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM [T_TheCompany_KWS_3_LNC_TCompany_ContractID_Extended] c
			where  c.contractid = u.contractid   
				and [CompanyMatch_Like_FLAG] > 0
				and [CompanyMatch_Exact_FLAG] = 0
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [CompanyMatch_Like]	

	,		(SELECT max(CompanyMatch_LIKE_Flag)
			FROM [T_TheCompany_KWS_3_LNC_TCompany_ContractID_Extended] c
			WHERE  c.contractid = u.contractid)
			 AS [CompanyMatch_LIKE_FLAG]

	/* Company ANY */
						,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + c.[KeyWordVarchar255] /*+': ' 
	
				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM [T_TheCompany_KWS_3_LNC_TCompany_ContractID_Extended] c
			where  c.contractid = u.contractid   
				and [CompanyMatch_Like_FLAG] = 0
				and [CompanyMatch_Exact_FLAG] = 0
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [CompanyMatch_NotExactNotLike]	

						,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + c.[Companytype] /*+': ' 

				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM [T_TheCompany_KWS_3_LNC_TCompany_ContractID_Extended] c
			where  c.contractid = u.contractid   
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS CompanyType

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
				FROM T_TheCompany_KWS_3_LNC_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid)
					AS [CompanyMatch_Level]

	/* Level - Company Match Category */

			, (SELECT MIN( 
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
				FROM T_TheCompany_KWS_3_LNC_TCompany_ContractID_Extended c
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
				FROM T_TheCompany_KWS_3_LNC_TCompany_ContractID_Extended c
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
				FROM T_TheCompany_KWS_3_LNC_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid),255))
					AS [CompanyMatch_Name]

			, (SELECT MAX([KeyWordVarchar255]) from T_TheCompany_KWS_3_LNC_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid) 
					as CompanyMatch_KeyWord
			, (SELECT MAX([KeyWordVarchar255_UPPER]) from T_TheCompany_KWS_3_LNC_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid) 
					as CompanyMatch_KeyWord_UPPER									   
	/* COUNTRY - Company */

		/*				,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordVarchar255] /*+': ' 

				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM T_TheCompany_KWS_2_LNC_TCOMPANYCountry_ContractID rs
			where  rs.contractid = u.contractid   
			FOR XML PATH('')),1,1,''),'&amp;','&')) */, '' AS [CompanyCountryMatch]	
			

/* CUSTOM FIELDS */

		,Replace(STUFF(
			(
			SELECT DISTINCT ',' + rs.[KeyWordCustom1]
			FROM /*(select [KeyWordCustom1], contractid from T_TheCompany_KWS_2_LNC_TPRODUCT_ContractID
					UNION
					select [KeyWordCustom1], contractid from*/ T_TheCompany_KWS_2_LNC_TCompany_ContractID /*
					) */ rs
			where  rs.contractid = u.contractid
				AND rs.[KeyWordCustom1] IS NOT NULL

			/* and rs.ProductExact_Flag = 1 */
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Custom1_Lists

		,Replace(STUFF(
			(SELECT DISTINCT ',' + rs.[KeyWordCustom2]
			FROM T_TheCompany_KWS_2_LNC_tcompany_ContractID rs
			where  rs.contractid = u.contractid
			AND rs.[KeyWordCustom2] IS NOT NULL
			/* and rs.ProductExact_Flag = 1 */
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Custom2_Lists

	/* DESCRIPTION */

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[DescriptionKeyword]
			FROM [T_TheCompany_KWS_5c_LNC_DESCRIPTION_ContractID] rs
			where  rs.contractid = u.contractid
			/* only include records that are not a company match */
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS Description_Match

	/* INTERNAL PARTNER */

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordVarchar255]
			FROM [T_TheCompany_KWS_2_LNC_InternalPartner_ContractID] rs
			where  rs.contractid = u.contractid
			/* only include records that are not a company match */
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS InternalPartner_Match

	/* TERRITORIES */

	/*	,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordVarchar255]
			FROM [T_TheCompany_KWS_2_LNC_Territories_ContractID] rs
			where  rs.contractid = u.contractid
			/* only include records that are not a company match */
		FOR XML PATH('')),1,1,''),'&amp;','&')) */,'' AS Territory_Match

	/* PRODUCTS */

	/*	,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[T_TheCompany_KWS_3_LNC_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and p.[ProductMatch_TN] = 1
		FOR XML PATH('')),1,1,''),'&amp;','&'))*/,'' AS KeyWordMatch_TradeName

		/*				 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[T_TheCompany_KWS_3_LNC_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and p.[ProductMatch_AI] = 1
		FOR XML PATH('')),1,1,''),'&amp;','&'))*/,'' AS KeyWordMatch_ActiveIngredients

		/* ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup
		FROM [dbo].[T_TheCompany_KWS_3_LNC_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and p.[ProductMatch_Exact] = 1
		FOR XML PATH('')),1,1,''),'&amp;','&'))*/,''  AS KeyWordMatch_Product_EXACT

		/* ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[T_TheCompany_KWS_3_LNC_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and p.[ProductMatch_NotExact] = 1
		FOR XML PATH('')),1,1,''),'&amp;','&'))*/,''  AS KeyWordMatch_Product_NotExact

		/*	 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[T_TheCompany_KWS_3_LNC_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and (p.[ProductMatch_AI] = 1 OR p.[ProductMatch_TN] = 1)
		FOR XML PATH('')),1,1,''),'&amp;','&'))*/,''  AS KeyWordMatch_Product_AIorTN

		/*		 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup 
			+ (CASE WHEN PrdGrpMatch_EXACT_FLAG = 1 THEN '' ELSE ' ('+ p.keywordvarchar255 + ')' END)
		FROM [dbo].[T_TheCompany_KWS_3_LNC_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid 
		/* and (p.[ProductMatch_AI] = 1 OR p.[ProductMatch_TN] = 1) */
		FOR XML PATH('')),1,1,''),'&amp;','&'))*/,''  AS ProductKeyword_Any

	/* TAG */
	/*			 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.tagcategory
		FROM [dbo].[T_TheCompany_KWS_2_LNC_Tag_ContractID] p 
		where  p.CONTRACTID = u.contractid 
		and P.keywordtype = 'TagCategory'
		FOR XML PATH('')),1,1,''),'&amp;','&')) */,'' AS TagCategory_Match

		/*
				 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.tag
		FROM [dbo].[T_TheCompany_KWS_2_LNC_Tag_ContractID] p 
		where  p.CONTRACTID = u.contractid 
		and P.keywordtype = 'Tag'
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS Tag_Match */
				 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.FieldContent
		FROM [dbo].[V_TheCompany_KWS_1_LNC_MiscMetadataFields] p 
		where  p.CONTRACTID = u.contractid 
		and P.keywordtype = 'AgreementType'
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS AgreementType_Match	

	FROM 
		T_TheCompany_KWS_6_LNC_ContractID_UNION  u /* product, company, description */
	group by 
		u.contractid


GO
/****** Object:  View [dbo].[V_TheCompany_LNC_GoldStandard_Documents]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view 

[dbo].[V_TheCompany_LNC_GoldStandard_Documents]

as

	select 
			 a.[CONTRACTID]
			 , 'CTK-' + ltrim(STR(DOCUMENTID)) as DOCUMENTID_CTK
		   ,[FileID] as 'FILEID'
			, [VersionDate] as 'VersionDate'
			,[Datecreated] as 'DateCreated'
			, d.[Title]  as 'Document_Title'
			,[FileName] as 'FileName' /* pdf, pptx etc. */
			,[FileType] as 'FileType_Format' /* pdf, pptx etc. */
			,[FileSize] as 'FileSize' /* not migrated, calculated */
			,[DOCUMENTTYPE] as 'Folder_Status_CannotMigrate'
			,[OwnerEmail] as 'OwnerEmail'
			, [DocumentTags] as 'DocumentTags_GapID95'	

			, 'Folder: ' 
				+ (case when [DOCUMENTTYPE] IS null then '' else [DOCUMENTTYPE] END)
				 + (case when [DocumentTags]>'' THEN  ', Tags: ' + [DocumentTags] 
					else '' END)			
					 as CommentsInclFolderAndTags /* for ancilliary info such as tags,  ? */
			,[DOCUMENTID] /* turn into CTK_11111 */
			/*  ,[OBJECTTYPEID] - not needed,  V_TheCompany_VDOCUMENT filters for 1 Contract only but be sure to move amd docs */
	  	, GETDATE() as LastUpdated

		, (case when A.statusid = 5 then '1_ACTIVE_' 
				+ (case when contract_type = 'MSA' then '1_MSA'
					when contract_type = 'Confidentiality' then '2_Confidentiality'
					when contract_type = 'PSA' then '3_PSA'
					when contract_type = 'PRODUCT' then '5_PRODUCT'
					when contract_type = 'LegalAdmin' then '9_LegalAdmin'
					else '8_OTHER' END)
				
				/* when d.amendmentid is not null then 'AMENDMENT' */
				when a.Agr_IsMaterial_Flag = 1 or a.[ConfidentialityFLAG_0123] > 0 then '2_MATERIAL_CONF_'
				/*	+ (case when CONTRACTTYPEID = 11 then '_2Case' else '_1Contract' end) */
				+ (case when contract_type = 'MSA' then '1_MSA'
						+ (case when [DOCUMENTTYPE] = 'Signed Contracts' then '_SignedFolder' else '_OtherFolder' END)
						+ (case when filetype = '.pdf' then '_pdf' else '_NonPdf' end) 
				/*	when contract_type = 'Confidentiality' then '2_Confidentiality' */
					when contract_type = 'PSA' then '3_PSA'
					when contract_type = 'PRODUCT' then '5_PRODUCT'
					/* when contract_type = 'LegalAdmin' then '9_LegalAdmin' */
					else '8_OTHER' END)

				when a.InactiveWithExpiryDateWithinLast2Yrs = 1 then '3_2YRS_'
				+ (case when contract_type = 'MSA' then '1_MSA'
				/*	when contract_type = 'Confidentiality' then '2_Confidentiality' */
					when contract_type = 'PSA' then '3_PSA'
					when contract_type = 'PRODUCT' then '5_PRODUCT'
					/* when contract_type = 'LegalAdmin' then '9_LegalAdmin' */
					else '8_OTHER' END)
				ELSE '4_OTHER'
				end) 				
				as MigFolder

		, /* (case when [DOCUMENTTYPE] = 'Signed Contracts' then 'Signed_Contracts' */
			(case when filetype = '.pdf' then '_pdf' else '_NonPdf' end) 
 
			as MigFolder_Sub
/*
	, (CASE when (COUNTERPARTYNUMBER like '!ARIBA_W%' OR COUNTERPARTYNUMBER like 'Xt_%') then 0
			when contractid not in (select contractid from [V_TheCompany_VDOCUMENT]) then 0 /* no valid files - only Contikimail etc. */
			when a.[AgrType_IsHCX_Flag] = 1 then 0 /* 2 = undetermined */
			WHEN a.statusid = 5 /* active */ then 1 /* all active agreements */	
			When a.[ConfidentialityFLAG_0123] > 0 /*ConfidentialityFlagNAME <>'N/A'*/ then 1 /* if top secret or confidential */
			when a.Agr_IsMaterial_flag = 1 then 1 /* material agreements */

			WHEN a.[InactiveWithExpiryDateWithinLast2Yrs] = 1  THEN 1
			else 0 end)
		as MigrateYN_Flag

		*/
	/*	, (case when d.amendmentid is not null then 'AMENDMENT'
				when A.statusid = 5 then 'ACTIVE'
				when a.Agr_IsMaterial_Flag = 1 then 'MATERIAL'
				when a.InactiveWithExpiryDateWithinLast2Yrs = 1 then '2YRS'
				ELSE 'OTHER'
				end) as MigFolder1 */

			, a.[AgrType_IsHCX_Flag]
			, a.[Agr_IsMaterial_Flag]	
			, a.[status] as ContractStatus
			, a.AGREEMENT_TYPE
			, g.contract_type
			, (case when d.amendmentid is null then 'Contract' else 'AMENDMENT' end) as IsContractOrAmendment
		, GETDATE() as DateRefreshed
		, a.[DocumentFileTitlesConcat]
		, a.Number
	  from V_TheCompany_VDOCUMENT d
		inner join  [dbo].[V_TheCompany_LNC_GoldStandard] g on d.contractid = g.contractid
		inner join T_TheCompany_ALL_Xt a on g.contractid = A.contractid
GO
/****** Object:  View [dbo].[V_TheCompany_LNC_V_ContractDocuments]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view

[dbo].[V_TheCompany_LNC_V_ContractDocuments]

as

select 
		MigrateToSystem_LNCCategory
		, MigrateToSystem
		, MigrateToSystem_Detail
		, MigrateYN_Flag
		, MigrateYN_Detail
	, d.*


FROM V_TheCompany_LNC_GoldStandard_Documents d
	inner join V_T_TheCompany_ALL_0_MigFlags m /* inner join excludes case, test, delete */
		on d.CONTRACTID = m.contractid_proc
/*
		select * from V_TheCompany_VDocumentContractSummary_TS_Redacted where OBJECTID not in (select contractid_proc from V_T_TheCompany_ALL_0_MigFlags)

	select * from TCONTRACT where CONTRACT like '% test %'
	*/
GO
/****** Object:  View [dbo].[V_TheCompany_VUSER_WithHierarchy]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_VUSER_WithHierarchy]
AS

	SELECT 
		u.*
      ,[LEVEL]
      ,[REGION]
      ,[L0]
      ,[L1]
      ,[L2]
      ,[L3]
      ,[L4]
      ,[L5]
      ,[L6]
      ,[L7]
 
      ,[DEPARTMENT_CONCAT]
      ,[DPT_LOWEST_ID_TO_SHOW]
      ,[DEPARTMENT_CODE_TTREGION]

      ,[DEPARTMENT_CODE_BASE]
      ,[DPT_CODE_2Digit_InternalPartner]
      ,[DPT_CODE_2Digit_TerritoryRegion]
      ,[DPT_CODE_2Digit]
      ,[DPT_CODE_FirstChar]
      ,[FieldCategory]
      ,[NodeType]
      ,[NodeMajorFlag]
      ,[NodeRole]
      ,[PARENTID]
	FROM	V_TheCompany_VUSER u
		LEFT OUTER join T_TheCompany_Hierarchy h 
		on u.departmentid = h.departmentid
	WHERE u.USER_MIK_VALID = 1 /* user valid */

GO
/****** Object:  View [dbo].[V_TheCompany_CheckAuditTrailHistory]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_CheckAuditTrailHistory]

as 

select u.DISPLAYNAME, h.* from TAUDITTRAIL_HISTORY h left join VUSER u on h.USERID = u.USERID
where OBJECTID in (select contractid from TCONTRACT where CONTRACTNUMBER = 'Delete-11137421')
GO
/****** Object:  View [dbo].[V_TheCompany_Mig_VWARNING_Proc]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_Mig_VWARNING_Proc]
as
select Objectid as ContractIDKey, *
from VWARNING
 /*, f.FileType, f.LastChangedDate, f.MajorVersion 
left join TFILEinfo f on d.fileid = f.FileID */
where
OBJECTID in (select contractid_Proc 
	from dbo.V_TheCompany_Mig_0ProcNetFlag
	where Proc_NetFlag = 1)
and ISTURNEDOFF = 0
GO
/****** Object:  View [dbo].[V_TheCompany_Mig_ReferenceContracts_Proc]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_Mig_ReferenceContracts_Proc]
as
select contractid as ContractIDKey, REFERENCECONTRACTID, REFERENCECONTRACTNUMBER
from Tcontract
where
contractid in (select contractid_Proc 
from  dbo.V_TheCompany_Mig_0ProcNetFlag
where Proc_NetFlag = 1)







GO
/****** Object:  View [dbo].[V_TheCompany_FullText_OcrProblem]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_FullText_OcrProblem]

as

select fileid,'corrupt file' as Issue from vdocument where title like '%corrupt file%' /*CORRUPT FILE*/
union all 
select fileid,'password protected' as Issue from vdocument where title like '%PASSWORD PROTECTED%' /*PASSWORD PROTECTED*/

union all 
select fileid,'write protected' as Issue from vdocument where title like '%WRITE PROTECTED%' /*WRITE PROTECTED*/


GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_ARB_InternalPartner_ContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view

[dbo].[V_TheCompany_KWS_2_ARB_InternalPartner_ContractID]
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

		, t.[Internal Partners] as InternalPartners
		, t.CONTRACTID

	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		inner join V_TheCompany_KWS_0_ContikiView_ARB t 
			on upper(t.[Internal Partners]) LIKE 
				(CASE WHEN keywordprecision = 'EXACT' THEN
					upper(s.KeyWordVarchar255)
					ELSE
					'%'+ s.KeyWordVarchar255 +'%'
					END)
	WHERE 
		s.KeyWordType = 'InternalPartner'
GO
/****** Object:  View [dbo].[V_TheCompany_KWS_6_ARB_ContractID_UNION]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[V_TheCompany_KWS_6_ARB_ContractID_UNION]
as

	select [ContractID] 
	from T_TheCompany_KWS_2_ARB_TCompany_ContractID 
/*
		UNION ALL /* Union returns nothing if one item has no records */

	select [ContractID] 
	from V_TheCompany_KWS_3_ARB_TProduct_ContractID_Extended /* no table available */
	*/
		UNION ALL
		
	select DISTINCT ContractID
	FROM V_TheCompany_KWS_2_ARB_InternalPartner_ContractID
	/* NO WHERES this will falsify concat results use select distinct for union 
	WHERE contractid not in (select contractid from T_TheCompany_KWS_2_ARB_TCompany_ContractID)*/
	/*	UNION ALL

	select ContractID 
	FROM V_TheCompany_KWS_2_ARB_Territories_ContractID

		UNION ALL

	select ContractID 
	FROM T_TheCompany_KWS_2_ARB_Tag_ContractID
	*/
		UNION ALL 
		/* V_TheCompany_KWS_5c_ARB_DESCRIPTION_ContractID must be edited to match!! */
	select ContractID 
	from T_TheCompany_KWS_5c_ARB_DESCRIPTION_ContractID
	/*WHERE contractid not in (select contractid from T_TheCompany_KWS_2_ARB_TCompany_ContractID)*/
	/*
		UNION
	select ContractID 
	from V_TheCompany_KWS_1_ARB_MiscMetadataFields */
/*	WHERE KeyWordOperator is null /* NOT 'FILTER' */ or KeyWordOperator = 'SHOW' */


GO
/****** Object:  View [dbo].[VPRODUCTGROUP_IN_OBJECT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VPRODUCTGROUP_IN_OBJECT]
AS
SELECT DISTINCT 
                      PGI.CONTRACTID OBJECTID, O.OBJECTTYPEID, O.FIXED OBJECTTYPEFIXED, P.PRODUCTGROUPID, P.PARENTID, P.PRODUCTGROUPCODE, 
                      P.PRODUCTGROUP, P.MIK_VALID PRODUCTGROUPMIKVALID, N .PRODUCTGROUPNOMENCLATUREID, N .PRODUCTGROUPNOMENCLATURE, N 
                      .MIK_VALID NOMENCLATUREMIKVALID
FROM         TPROD_GROUP_IN_CONTRACT PGI, TOBJECTTYPE O, TPRODUCTGROUP P, TPRODUCTGROUPNOMENCLATURE N
WHERE     O.FIXED = 'CONTRACT' AND PGI.PRODUCTGROUPID = P.PRODUCTGROUPID AND P.PRODUCTGROUPNOMENCLATUREID = N 
                      .PRODUCTGROUPNOMENCLATUREID
UNION
SELECT DISTINCT 
                      PGI.COMPANYID OBJECTID, O.OBJECTTYPEID, O.FIXED OBJECTTYPEFIXED, P.PRODUCTGROUPID, P.PARENTID, P.PRODUCTGROUPCODE, 
                      P.PRODUCTGROUP, P.MIK_VALID PRODUCTGROUPMIKVALID, N .PRODUCTGROUPNOMENCLATUREID, N .PRODUCTGROUPNOMENCLATURE, N 
                      .MIK_VALID NOMENCLATUREMIKVALID
FROM         TPROD_GROUP_IN_COMPANY PGI, TOBJECTTYPE O, TPRODUCTGROUP P, TPRODUCTGROUPNOMENCLATURE N
WHERE     O.FIXED = 'COMPANY' AND PGI.PRODUCTGROUPID = P.PRODUCTGROUPID AND P.PRODUCTGROUPNOMENCLATUREID = N 
                      .PRODUCTGROUPNOMENCLATUREID
UNION
SELECT DISTINCT 
                      PGI.MODELID OBJECTID, O.OBJECTTYPEID, O.FIXED OBJECTTYPEFIXED, P.PRODUCTGROUPID, P.PARENTID, P.PRODUCTGROUPCODE, 
                      P.PRODUCTGROUP, P.MIK_VALID PRODUCTGROUPMIKVALID, N .PRODUCTGROUPNOMENCLATUREID, N .PRODUCTGROUPNOMENCLATURE, N 
                      .MIK_VALID NOMENCLATUREMIKVALID
FROM         TPROD_GROUP_IN_MODEL PGI, TOBJECTTYPE O, TPRODUCTGROUP P, TPRODUCTGROUPNOMENCLATURE N
WHERE     O.FIXED = 'MODEL' AND PGI.PRODUCTGROUPID = P.PRODUCTGROUPID AND P.PRODUCTGROUPNOMENCLATUREID = N 
                      .PRODUCTGROUPNOMENCLATUREID
UNION
SELECT DISTINCT 
                      PGI.MODULEID OBJECTID, O.OBJECTTYPEID, O.FIXED OBJECTTYPEFIXED, P.PRODUCTGROUPID, P.PARENTID, P.PRODUCTGROUPCODE, 
                      P.PRODUCTGROUP, P.MIK_VALID PRODUCTGROUPMIKVALID, N .PRODUCTGROUPNOMENCLATUREID, N .PRODUCTGROUPNOMENCLATURE, N 
                      .MIK_VALID NOMENCLATUREMIKVALID
FROM         TPROD_GROUP_IN_MODULE PGI, TOBJECTTYPE O, TPRODUCTGROUP P, TPRODUCTGROUPNOMENCLATURE N
WHERE     O.FIXED = 'MODULE' AND PGI.PRODUCTGROUPID = P.PRODUCTGROUPID AND P.PRODUCTGROUPNOMENCLATUREID = N 
                      .PRODUCTGROUPNOMENCLATUREID
UNION
SELECT DISTINCT 
                      PGI.ASSESSMENTID OBJECTID, O.OBJECTTYPEID, O.FIXED OBJECTTYPEFIXED, P.PRODUCTGROUPID, P.PARENTID, P.PRODUCTGROUPCODE, 
                      P.PRODUCTGROUP, P.MIK_VALID PRODUCTGROUPMIKVALID, N .PRODUCTGROUPNOMENCLATUREID, N .PRODUCTGROUPNOMENCLATURE, N 
                      .MIK_VALID NOMENCLATUREMIKVALID
FROM         TPROD_GROUP_IN_ASSESSMENT PGI, TOBJECTTYPE O, TPRODUCTGROUP P, TPRODUCTGROUPNOMENCLATURE N
WHERE     O.FIXED = 'PREQUALIFICATION' AND PGI.PRODUCTGROUPID = P.PRODUCTGROUPID AND P.PRODUCTGROUPNOMENCLATUREID = N 
                      .PRODUCTGROUPNOMENCLATUREID
UNION
SELECT DISTINCT 
                      PGI.CLAUSEID OBJECTID, O.OBJECTTYPEID, O.FIXED OBJECTTYPEFIXED, P.PRODUCTGROUPID, P.PARENTID, P.PRODUCTGROUPCODE, 
                      P.PRODUCTGROUP, P.MIK_VALID PRODUCTGROUPMIKVALID, N .PRODUCTGROUPNOMENCLATUREID, N .PRODUCTGROUPNOMENCLATURE, N 
                      .MIK_VALID NOMENCLATUREMIKVALID
FROM         TPROD_GROUP_IN_CLAUSE PGI, TOBJECTTYPE O, TPRODUCTGROUP P, TPRODUCTGROUPNOMENCLATURE N
WHERE     O.FIXED = 'CLAUSE' AND PGI.PRODUCTGROUPID = P.PRODUCTGROUPID AND P.PRODUCTGROUPNOMENCLATUREID = N 
                      .PRODUCTGROUPNOMENCLATUREID
UNION
SELECT DISTINCT 
                      PGI.ACTIVITY_TEMPLATEID OBJECTID, O.OBJECTTYPEID, O.FIXED OBJECTTYPEFIXED, P.PRODUCTGROUPID, P.PARENTID, 
                      P.PRODUCTGROUPCODE, P.PRODUCTGROUP, P.MIK_VALID PRODUCTGROUPMIKVALID, N .PRODUCTGROUPNOMENCLATUREID, N 
                      .PRODUCTGROUPNOMENCLATURE, N .MIK_VALID NOMENCLATUREMIKVALID
FROM         TPROD_GROUP_IN_ACT_TEMPLATE PGI, TOBJECTTYPE O, TPRODUCTGROUP P, TPRODUCTGROUPNOMENCLATURE N
WHERE     O.FIXED = 'PLAN' AND PGI.PRODUCTGROUPID = P.PRODUCTGROUPID AND P.PRODUCTGROUPNOMENCLATUREID = N 
                      .PRODUCTGROUPNOMENCLATUREID
UNION
SELECT DISTINCT 
                      PGI.RFXID OBJECTID, O.OBJECTTYPEID, O.FIXED OBJECTTYPEFIXED, P.PRODUCTGROUPID, P.PARENTID, P.PRODUCTGROUPCODE, 
                      P.PRODUCTGROUP, P.MIK_VALID PRODUCTGROUPMIKVALID, N .PRODUCTGROUPNOMENCLATUREID, N .PRODUCTGROUPNOMENCLATURE, N 
                      .MIK_VALID NOMENCLATUREMIKVALID
FROM         TPROD_GROUP_IN_RFX PGI, TOBJECTTYPE O, TPRODUCTGROUP P, TPRODUCTGROUPNOMENCLATURE N
WHERE     O.FIXED = 'RFX' AND PGI.PRODUCTGROUPID = P.PRODUCTGROUPID AND P.PRODUCTGROUPNOMENCLATUREID = N 
                      .PRODUCTGROUPNOMENCLATUREID
UNION
SELECT DISTINCT 
                      PGI.AMENDMENTID OBJECTID, O.OBJECTTYPEID, O.FIXED OBJECTTYPEFIXED, P.PRODUCTGROUPID, P.PARENTID, P.PRODUCTGROUPCODE, 
                      P.PRODUCTGROUP, P.MIK_VALID PRODUCTGROUPMIKVALID, N .PRODUCTGROUPNOMENCLATUREID, N .PRODUCTGROUPNOMENCLATURE, N 
                      .MIK_VALID NOMENCLATUREMIKVALID
FROM         TPROD_GROUP_IN_AMENDMENT PGI, TOBJECTTYPE O, TPRODUCTGROUP P, TPRODUCTGROUPNOMENCLATURE N
WHERE     O.FIXED = 'AMENDMENT' AND PGI.PRODUCTGROUPID = P.PRODUCTGROUPID AND P.PRODUCTGROUPNOMENCLATUREID = N 
                      .PRODUCTGROUPNOMENCLATUREID
                      
UNION

SELECT DISTINCT 
                      PGI.OBJECTID OBJECTID, O.OBJECTTYPEID, O.FIXED OBJECTTYPEFIXED, P.PRODUCTGROUPID, P.PARENTID, P.PRODUCTGROUPCODE, 
                      P.PRODUCTGROUP, P.MIK_VALID PRODUCTGROUPMIKVALID, N .PRODUCTGROUPNOMENCLATUREID, N .PRODUCTGROUPNOMENCLATURE, N 
                      .MIK_VALID NOMENCLATUREMIKVALID
FROM         TPRODUCTGROUP_IN_OBJECT PGI, TOBJECTTYPE O, TPRODUCTGROUP P, TPRODUCTGROUPNOMENCLATURE N
WHERE     O.FIXED = 'ORDER' AND PGI.PRODUCTGROUPID = P.PRODUCTGROUPID AND P.PRODUCTGROUPNOMENCLATUREID = N 
                      .PRODUCTGROUPNOMENCLATUREID


GO
/****** Object:  View [dbo].[V_TheCompany_Mig_VPRODUCTGROUP_Proc]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_Mig_VPRODUCTGROUP_Proc]
as
select o.OBJECTID as ContractID, p.*
from dbo.VPRODUCTGROUP p inner join dbo.VPRODUCTGROUP_IN_OBJECT o on o.PRODUCTGROUPID = p.PRODUCTGROUPID
where
o.OBJECTID in (select contractid_Proc from dbo.V_TheCompany_Mig_0ProcNetFlag
where Proc_NetFlag = 1)





GO
/****** Object:  View [dbo].[V_TheCompany_UserID_CountractRoleCount_VUSER_UserSetup]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_UserID_CountractRoleCount_VUSER_UserSetup]

as 

SELECT 
	USERINITIAL as USERINITIAL_INFRONT
	, *

FROM 
[dbo].[V_TheCompany_UserID_CountractRoleCount_VUSER]
GO
/****** Object:  View [dbo].[V_TheCompany_CL_VUSER_WithHierarchy]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_CL_VUSER_WithHierarchy]

as

select TOP 1000
        [L1]
      , [L2]
      , [L3]
      , [L4]
      , [DEPARTMENT]
      , [DISPLAYNAME]

      , [UserProfileGroup]
	  , [CustomUserGrp_List] as 'Access Group(s)' /* uk all access etc. */

	  /* surplus */
      , [USERINITIAL] as 'WindowsUserID'
      , [EMAIL]
      , [PRIMARYUSERGROUP]
      , [COUNTRY]

      FROM [V_TheCompany_VUSER_WithHierarchy]
      /* WHERE  L2 = 'EUROPE (CEE - CENTRAL & EASTERN)' */
      ORDER BY L1, L2, L3, L4


GO
/****** Object:  View [dbo].[V_TheCompany_Ariba_Products_In_Contracts_UNION]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_Ariba_Products_In_Contracts_UNION]

as
	select c.[ContractNumber]
		  /*,[DateAdded]*/
		  , c.MatchLevel
		  ,[Source]	  
		  ,c.[ProductgroupID]
		  ,c.[ContractInternalID]
		,p.PRODUCTGROUP 
	FROM
		T_TheCompany_Ariba_Products_In_Contracts  c inner join TPRODUCTGROUP p 
			on c.productgroupid = p.productgroupid
	where c.matchlevel = 1 /* full match */ 
		OR (c.matchlevel = 2 /* fuzzy like match */ 
			AND len(productgroup) >3 )/* if only 3 chars or less then the match has to be exact */

	UNION ALL

	select c.[ContractNumber]
		  /*,[DateAdded]*/
		  , c.MatchLevel
		  ,c.[Source]
		  ,c.[ProductgroupID]
		  ,c.[ContractInternalID]
		,p.PRODUCTGROUP 
	FROM
		T_TheCompany_Ariba_Products_In_Contracts_FullText  c inner join TPRODUCTGROUP p on c.productgroupid = p.productgroupid
			left join T_TheCompany_Ariba_Products_In_Contracts d
			on (c.[ContractInternalID]=d.[ContractInternalID] AND c.[ProductgroupID] = d.[ProductgroupID])
	WHERE d.[ID] is null

GO
/****** Object:  View [dbo].[V_TheCompany_Ariba_Dump_Raw_FLAT_AllProducts]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_Ariba_Dump_Raw_FLAT_AllProducts]

as

SELECT ContractInternalID
	, CAST(Replace(SUBSTRING(STUFF(
		(SELECT DISTINCT ', ' + p.[Productgroup]
		FROM [dbo].[TPRODUCTGROUP] p inner join V_TheCompany_Ariba_Products_In_Contracts_UNION u 
			on p.PRODUCTGROUPID = u.ProductgroupID
			and p.PRODUCTGROUPNOMENCLATUREID in (2,3) /* only active ingredients and trade names, not studies etc. */
		WHERE u.ContractInternalID = d.ContractInternalID
		FOR XML PATH('')),1,1,''),1,1000),'&amp;','&') AS VARCHAR(1000)) AS [All Products] 
		
		/*,(case when (d.[Affected Parties - Common Supplier Concat] like '%legacy supplier%' or d.[Affected Parties - Common Supplier Concat] like '%nclassifie%') /* e.g. Contiki contracts */ AND contractnumber like 'cntk%'
			then (select CompanyList from T_TheCompany_ALL where number = rtrim(substring(d.ContractNumber,6,25)))
			else d.[Affected Parties - Common Supplier Concat] end)
		 as 'AllSuppliers'*/
  FROM [Contiki_app].[dbo].[V_TheCompany_Ariba_Dump_Raw_FLAT] d

GO
/****** Object:  View [dbo].[V_TheCompany_UserID_CountractRoleCount_VUSER_EmailDistroAct]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view

[dbo].[V_TheCompany_UserID_CountractRoleCount_VUSER_EmailDistroAct]

AS


select TOP 1500 email
, mik_valid
, NumTotalRoles
, NumTotalRolesactive 
, Personid_Personrole_ContractIDCount
from dbo.V_TheCompany_UserID_CountractRoleCount_VUSER
where MIK_VALID = 1 and NumTotalRoles >0
order by email

GO
/****** Object:  View [dbo].[V_TheCompany_LNC_MIG_Summary]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_LNC_MIG_Summary]

as

select MigrateYN_Flag, migfolder
, count(distinct a.contractid) as ContractCount
, count(distinct d.documentid) as DocCount
from t_TheCompany_all_xt a inner join [dbo].[V_TheCompany_LNC_GoldStandard_Documents] d on a.contractid = d.contractid
group by MigrateYN_Flag, migfolder
GO
/****** Object:  View [dbo].[V_TheCompany_RegForm_DptUsers]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  view [dbo].[V_TheCompany_RegForm_DptUsers]

as

/* waiting for SSO for user joest */

	select top 9999
		u.DISPLAYNAME as 'UserName'
		, u.EMAIL
		,u.primaryusergroup as 'PrimaryUserGroup'
		, u.DEPARTMENT as Department
		, u.DEPARTMENT_CODE as Department_Code 
		, u.COUNTRY as Country
		, u.UserProfileGroup as 'UserProfileGroup'
		/* , u.DEPARTMENT + ' - ' + u.country as 'DepartmentCountryLookup' */
		, g.[CustomUserGrp_List] as CustomUserGroupList
		, GETDATE() as Last_Updated
	FROM V_TheCompany_VUSER u 
		left join T_TheCompany_Hierarchy h 
			on u.DEPARTMENTID = h.departmentid
		left join [Contiki_app].[dbo].[V_TheCompany_VUSER_IN_USERGROUP] g 
			on u.userid = g.userid
	where u.primaryUSERGROUP like 'Departments%' /* and USERGROUP <>'Territories' */
		and u.DEPARTMENT_CODE<>'-SYS'
		AND u.USER_MIK_VALID = 1
	order by u.DISPLAYNAME

GO
/****** Object:  View [dbo].[V_TheCompany_ContractData_ARB_0VCOMPANY_0RAW]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_ContractData_ARB_0VCOMPANY_0RAW]

/* 
[dbo].[TheCompany_KeyWordSearch]
- elminiate double spaces
- ltrim, rtrim
 - use all supplier field to capture legacy vendors
*/
as

	select 
		/* * 
		, */ [Project - Project Id] as ContractInternalID
		, [Project - Project Id] as ContractID
		, [Contract Id] as ContractNumber
		, [AllSupplier]
		/* supplier parsing */
		, UPPER(dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([AllSupplier]))
			as Company_LettersNumbersOnly_UPPER

		,  UPPER(replace(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([AllSupplier]),'  ',' '))
			as Company_LettersNumbersSpacesOnly_UPPER /* e.g. Hansen & Rosenthal */

		, LEN(replace(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([AllSupplier]),'  ',' '))
			- LEN(dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([AllSupplier])) 
				as Company_LettersNumbersOnly_NumSpacesWords
		
		, [dbo].[TheCompany_CompanyOrIndividual]([AllSupplier]) AS CompanyType

	FROM 
		T_TheCompany_Ariba_Dump_Raw
	WHERE 
		[AllSupplier] is not null /* internal partner or company is populated */
		AND LEN([AllSupplier])>2 /* at least 3 char */
		AND [AllSupplier] NOT like '%[?]%' /* junk entries like ?????? ???????????????? ?.?.? ??? */
		AND [AllSupplier] NOT LIKE N'%[А-Я]%' /* not Cyrillic, erratic results like ???, taken out in Ariba data load but this is for other records */

GO
/****** Object:  View [dbo].[V_TheCompany_ContractData_ARB_1VCOMPANY]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_ContractData_ARB_1VCOMPANY]
/* refreshed via TheCompany_Company_Search */
as

	select 
		c.*
		, [AllSupplier] as Company
		, UPPER([AllSupplier]) as Company_UPPER
		, len([AllSupplier]) as Company_Length
			, UPPER([dbo].[TheCompany_GetFirstWordInString](Company_LettersNumbersSpacesOnly_UPPER))
		as Company_FirstWord_UPPER

			, UPPER([dbo].[TheCompany_GetFirstWordInString]([Company_LettersNumbersSpacesOnly_UPPER]))
		as Company_FirstWord_LettersOnly_UPPER

			, LEN([dbo].[TheCompany_GetFirstWordInString]([AllSupplier])) 
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

	from [dbo].[V_TheCompany_ContractData_ARB_0VCOMPANY_0RAW] c
	/* WHERE c.MIK_VALID = 1 /* and company = 'Svedberg, Agneta' */*/

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_0_ContikiView_CNT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[V_TheCompany_KWS_0_ContikiView_CNT]
/* used for Contiki Keyword search result and merged Ariba table
V_TheCompany_Ariba_ContikiUnion must be updated if field changes 
simply add new t_TheCompany_ all fields at the bottom of ariba table part */
as

select

 [Contract Number]
      ,[Contract Description]
	  , [Contract Relation] 
	  , [Agreement Type]
	  , [Agreement Type Divestment] as 'Divestment Agreement Type'
	  ,[Status]          
      ,convert(date, [Registered Date] ) as 'Registered Date'
      ,[Reg Date Cat]
	,convert(date, [Start Date]) as 'Start Date'
	,convert(date, [End Date] ) as 'End Date'
	,convert(date, [Review Date]) as 'Review Date'
	,convert(date, [Review Date Reminder]) as 'RV Dt Reminder'
 	,[All Products]
      /*,[Defined End Date Flag] */
      ,[Number of Attachments]     as 'File Count'  
      , ISNULL([Company Names],'') AS [Company Names]
     ,[Company Count] as 'Company #'
	   , [Company Country List]
       , [Confidentiality Flag]
      /*,[Super User Name]*/
       ,[Super User Email]
      /*,[Super User First Name] */
      ,[Super User Primary User Group]
      ,[Super User Active Flag] as 'SU Active'
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
     ,[Internal Partners] as 'Internal Partners (IP)'
      ,[Internal Partners Count] as 'IP #'
      ,[Territories] as 'Territories (TT)'
      ,[Territories Count] as 'TT #'

      ,[Active Ingredients]
      ,[Trade Names]
      ,[Lump Sum]
      ,[LumpSumCurrency] as 'Lump Sum Curr'
	  ,[Tags]      
      ,[L0]
      ,[L1]
      ,[L2]
      ,[L3]
      ,[L4]
		/*,[Contract Relation]*/
      , [Contract Type] as [Contract Type (Contract Case)] /* e.g. 'Contract', 'Case'*/
	   , convert(varchar, [CONTRACTID]) AS CONTRACTID
	  , [Company Country is US] 
	, '' as Comments

		/* Link and Date Must be last 2 columns! */
      ,[LinkToContractURL] as 'Link to Contract'
      ,[DateTableRefreshed] 'Date Refreshed'  	

  FROM [dbo].[V_T_TheCompany_ALL_NoTS_CFN] /* was [Contiki_app].[dbo].[V_T_TheCompany_ALL_CommonFN] */ c

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_JPS_InternalPartner_ContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view

[dbo].[V_TheCompany_KWS_2_JPS_InternalPartner_ContractID]
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

		, t.[Internal Partners] as InternalPartners
		, t.CONTRACTID

	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		inner join V_TheCompany_KWS_0_ContikiView_JPS t 
			on upper(t.[Internal Partners]) LIKE 
				(CASE WHEN keywordprecision = 'EXACT' THEN
					upper(s.KeyWordVarchar255)
					ELSE
					'%'+ s.KeyWordVarchar255 +'%'
					END)
	WHERE 
		s.KeyWordType = 'InternalPartner'
GO
/****** Object:  View [dbo].[V_TheCompany_Mig_VDPTROLE_IN_OBJECT_Proc]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view

[dbo].[V_TheCompany_Mig_VDPTROLE_IN_OBJECT_Proc]
as

Select o.objectid as ContractIDKey
, o.DEPARTMENTROLE_IN_OBJECTID , r.ROLEID
, r.ROLE, r.ISPERSONROLE, r.ISDEPARTMENTROLE, d.* 
from dbo.TDEPARTMENTROLE_IN_OBJECT o 
left join TDEPARTMENT d 
on o.DEPARTMENTID = d.DEPARTMENTID 
left join TROLE r on o.ROLEID = r.ROLEid
WHERE OBJECTID in (select contractid_Proc from dbo.V_TheCompany_Mig_0ProcNetFlag
where Proc_NetFlag = 1)


GO
/****** Object:  View [dbo].[V_TheCompany_KWS_1_CNT_MiscMetadataFields]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view 
[dbo].[V_TheCompany_KWS_1_CNT_MiscMetadataFields]

as 

	SELECT  
		s.KeyWordVarchar255
		, s.KeyWordType
		, s.KeyWordPrecision
		, s.KeyWordOperator
		, p.[Agreement_Type] /* is agreement type */ + (case when p.[Agreement_Type] /* is agreement type */ not like '%'+s.KeyWordVarchar255+'%' 
				THEN + ' - ' + p.[title] ELSE ''
				END) 
				as 'FieldContent'
		, p.CONTRACTID

	FROM [V_TheCompany_KeyWordSearch] s 
		inner join T_TheCompany_ALL p 
			on p.AGREEMENT_TYPE like '%'+s.KeyWordVarchar255+'%' 
			OR p.[Title] like '%'+s.KeyWordVarchar255+'%' /* e.g. supply agreement does not exist as agreement type */
	where /* p.statusid = 5  active */
		s.KeyWordtype = 'AgreementType'

GO
/****** Object:  View [dbo].[V_TheCompany_Mig_VUSER_Proc]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[V_TheCompany_Mig_VUSER_Proc]
as

Select * from V_TheCompany_VUSER
	where Personid in (select PERSONID from dbo.TPERSONROLE_IN_OBJECT
		where OBJECTID in (select contractid_Proc 
			from dbo.V_TheCompany_Mig_0ProcNetFlag
			where Proc_NetFlag = 1)
			)



GO
/****** Object:  View [dbo].[V_TheCompany_KWS_2_JPS_Territories_ContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view

[dbo].[V_TheCompany_KWS_2_JPS_Territories_ContractID]
/* to do: include spaces with Productgroup name */
as 

	SELECT DISTINCT 
		s.*
		, i.ContractID

	FROM T_TheCompany_KeyWordSearch s 	
		/* left join must encompass all hits, narrow down with WHERE */
		inner join V_TheCompany_kws_0_ContikiView_JPS i 
			on i.[Territories] like  '%'+ s.KeyWordVarchar255 +'%'
	WHERE 
	s.KeyWordType = 'Territory'
	/* AND ContractInternalID not in (select ContractInternalID 
			from  [V_TheCompany_KWS_2_ARB_InternalPartner_ContractID])
	*/
GO
/****** Object:  View [dbo].[V_TheCompany_KWSR_0_ARB]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[V_TheCompany_KWSR_0_ARB]
/* be sure to run [TheCompany_KeyWordSearch] */
as

		SELECT
		 LTRIM((CASE WHEN isnull(u.ProductKeyword_Any,'') >'' THEN ' Product' ELSE '' END)
		 + 	(CASE WHEN isnull(u.CompanyMatch_score,0) >0 THEN u.CompanyMatch_LevelCategory
				  ELSE '' END)
		 + 	(CASE WHEN isnull(u.Description_Match,'') >'' THEN ' ' + ' Description' ELSE '' END)
		 + 	(CASE WHEN isnull(u.AgreementType_Match,'') >'' THEN ' ' + ' AgreementType' ELSE '' END)
		 + 	(CASE WHEN isnull(u.InternalPartner_Match,'') >'' THEN ' ' + ' InternalPartner' ELSE '' END)
		 + 	(CASE WHEN isnull(u.Territory_Match,'') >'' THEN ' ' + ' Territory' ELSE '' END)	
		 + 	(CASE WHEN isnull(u.CompanyCountryMatch,'') >'' THEN ' ' + ' Country(Company)' ELSE '' END)	
		 + 	(CASE WHEN isnull(u.TagCategory_Match,'') >'' THEN ' ' + ' TagCategory' ELSE '' END)			 
		 )
			 as MatchLevel

	/* FOUND KEYWORD - found in search, not original keyword */
		, convert(varchar(255),left(LTRIM((CASE WHEN isnull(u.ProductKeyword_Any,'') > '' 
			then isnull(u.ProductKeyword_Any,'') + ' (Product); ' ELSE '' END)
			 + (CASE WHEN isnull(u.CompanyMatch_Score,0) >0 THEN  ' ' /* is the keyword not found company */
			/*			+ u.companyMatch_Name + ' (Company, ' + convert(varchar(2),u.companymatch_score) + ');' ELSE '' END)*/
				+ isnull(u.CompanyMatch_Name,'') /* keyword instead */+ ' (Company); ' ELSE '' END)
			 + (CASE WHEN isnull(u.Description_Match,'') >'' THEN ' ' 
				+ u.Description_Match + ' (Desc); ' ELSE '' END)
			 + (CASE WHEN isnull(u.AgreementType_Match,'') >'' THEN ' ' 
				+ u.AgreementType_Match + ' (AgrmtType); ' ELSE '' END)
			 + (CASE WHEN isnull(u.InternalPartner_Match,'') >'' THEN ' ' 
				+ u.InternalPartner_Match + ' (IP); ' ELSE '' END)
			 + (CASE WHEN isnull(u.Territory_Match,'') >'' THEN ' ' 
				+ u.Territory_Match + ' (TT); ' ELSE '' END) 
			 + (CASE WHEN u.CompanyCountryMatch >'' THEN ' ' 
				+ u.CompanyCountryMatch + ' (CompanyCty); ' ELSE '' END) 
			 + (CASE WHEN isnull(u.TagCategory_Match,'') >'' THEN ' ' 
				+ u.TagCategory_Match + ' (TagCat); ' ELSE '' END) 
				),255))
			 as KeywordMatch_Found

	/* ORIGINAL KEYWORD - from input list */

		, convert(varchar(255),left(LTRIM((CASE WHEN isnull(u.ProductKeyword_Any,'') > '' 
			then u.ProductKeyword_Any + ' (Product); ' ELSE '' END)
			 + (CASE WHEN isnull(u.CompanyMatch_score,0) >0 THEN  ' ' /* is the keyword not found company */
			/*			+ u.companyMatch_Name + ' (Company, ' + convert(varchar(2),u.companymatch_score) + ');' ELSE '' END)*/
				+ companymatch_keyword /* keyword instead *//*+ ' (Company)*/ +'; ' ELSE '' END)
			 + (CASE WHEN isnull(u.Description_Match,'') >'' THEN ' ' 
				+ u.Description_Match + ' (Desc); ' ELSE '' END)
			 + (CASE WHEN isnull(u.AgreementType_Match,'') >'' THEN ' ' 
				+ u.AgreementType_Match + ' (AgrmtType); ' ELSE '' END)
			 + (CASE WHEN isnull(u.InternalPartner_Match,'') >'' THEN ' ' 
				+ u.InternalPartner_Match + ' (IP); ' ELSE '' END)
			 + (CASE WHEN isnull(u.Territory_Match,'') >'' THEN ' ' 
				+ u.Territory_Match + ' (TT); ' ELSE '' END) 
			 + (CASE WHEN isnull(u.CompanyCountryMatch,'') >'' THEN ' ' 
				+ u.CompanyCountryMatch + ' (CompanyCty); ' ELSE '' END) 
			 + (CASE WHEN isnull(u.TagCategory_Match,'') >'' THEN ' ' 
				+ u.TagCategory_Match + ' (TagCat); ' ELSE '' END) 
				),255))
			 as KeywordMatch_Original

/*		, LTRIM((CASE WHEN u.ProductKeyword_Any > '' 
			then 1 ELSE 0 END)
			 + (CASE WHEN u.CompanyMatch_score >0 THEN companymatch_Score ELSE o END)
	/*		 + (CASE WHEN u.Description_Match >'' THEN ' ' 
				+ u.Description_Match + ' (Desc); ' ELSE '' END)
			 + (CASE WHEN u.InternalPartner_Match >'' THEN ' ' 
				+ u.InternalPartner_Match + ' (IP); ' ELSE '' END)
			 + (CASE WHEN u.Territory_Match >'' THEN ' ' 
				+ u.Territory_Match + ' (TT); ' ELSE '' END) 
			 + (CASE WHEN u.CompanyCountryMatch >'' THEN ' ' 
				+ u.CompanyCountryMatch + ' (CompanyCty); ' ELSE '' END) 
			 + (CASE WHEN u.TagCategory_Match >'' THEN ' ' 
				+ u.TagCategory_Match + ' (TagCat); ' ELSE '' END) */
				)
			 as KeywordMatch_Score
		*/

		/* PRODUCT */
			, u.ProductKeyword_Any as 'Product (Any)'
			 /*, p.[KeyWordMatch_TradeName]
			 , p.[KeyWordMatch_ActiveIngredients] */

		 /* COMPANY */
			, u.CompanyMatch_Score
			, u.companyMatch_Level
			, convert(varchar(255), u.CompanyMatch_Name) /* any */ as 'Company (ALL)'

			, convert(varchar(255), u.CompanyMatch_NotExactNotLike) as 'Company (Other)'/* CompanyMatch_KeyWord */
			, convert(varchar(255), u.CompanyMatch_Like) as 'Company (Like)'
			, convert(varchar(255), u.CompanyMatch_Exact) as 'Company (Exact)'
			, convert(varchar(1), U.companyType) as 'C. Type' /* I = Individual, C = Company, U = Undefined */

		/* COUNTRY */
			, convert(varchar(255), u.CompanyCountryMatch) as 'Company Country Match'

		/* DESCRIPTION */
			, u.Description_Match as 'Description Match Only'

		/* LISTS */
			, '' as 'KeyWordSource Lists'
			, convert(varchar(255), u.[Custom1_Lists]) as [Custom1_Lists]
			, convert(varchar(255), u.[Custom2_Lists]) as [Custom2_Lists]
		
		/* TERRITORIES, INTERNAL PARTNERS */
			, convert(varchar(255), u.Territory_Match) AS 'Territory Match'
			, convert(varchar(255), u.InternalPartner_Match) AS 'Internal Partner Match'
			, U.[TagCategory_Match] AS 'Full Text Tag Match'
			, u.AgreementType_Match AS 'Agreement Type Match'
					 
		 /* ALL */
		 , s.*
	 FROM   [Contiki_app].[dbo].[V_TheCompany_KWS_0_ContikiView_ARB] s
				inner join T_TheCompany_KWS_7_ARB_ContractID_SummaryByContractID u
				on s.contractid = u.[ContractID]

GO
/****** Object:  View [dbo].[V_TheCompany_KWSR_0_LNC]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[V_TheCompany_KWSR_0_LNC]
/* be sure to run [TheCompany_KeyWordSearch] */
as

			SELECT
		 LTRIM((CASE WHEN isnull(u.ProductKeyword_Any,'') >'' THEN ' Product' ELSE '' END)
		 + 	(CASE WHEN isnull(u.CompanyMatch_score,0) >0 THEN u.CompanyMatch_LevelCategory
				  ELSE '' END)
		 + 	(CASE WHEN isnull(u.Description_Match,'') >'' THEN ' ' + ' Description' ELSE '' END)
		 + 	(CASE WHEN isnull(u.AgreementType_Match,'') >'' THEN ' ' + ' AgreementType' ELSE '' END)
		 + 	(CASE WHEN isnull(u.InternalPartner_Match,'') >'' THEN ' ' + ' InternalPartner' ELSE '' END)
		 + 	(CASE WHEN isnull(u.Territory_Match,'') >'' THEN ' ' + ' Territory' ELSE '' END)	
		 + 	(CASE WHEN isnull(u.CompanyCountryMatch,'') >'' THEN ' ' + ' Country(Company)' ELSE '' END)	
		 + 	(CASE WHEN isnull(u.TagCategory_Match,'') >'' THEN ' ' + ' TagCategory' ELSE '' END)			 
		 )
			 as MatchLevel

	/* FOUND KEYWORD - found in search, not original keyword */
		, convert(varchar(255),left(LTRIM((CASE WHEN isnull(u.ProductKeyword_Any,'') > '' 
			then isnull(u.ProductKeyword_Any,'') + ' (Product); ' ELSE '' END)
			 + (CASE WHEN isnull(u.CompanyMatch_Score,0) >0 THEN  ' ' /* is the keyword not found company */
			/*			+ u.companyMatch_Name + ' (Company, ' + convert(varchar(2),u.companymatch_score) + ');' ELSE '' END)*/
				+ isnull(u.CompanyMatch_Name,'') /* keyword instead */+ ' (Company); ' ELSE '' END)
			 + (CASE WHEN isnull(u.Description_Match,'') >'' THEN ' ' 
				+ u.Description_Match + ' (Desc); ' ELSE '' END)
			 + (CASE WHEN isnull(u.AgreementType_Match,'') >'' THEN ' ' 
				+ u.AgreementType_Match + ' (AgrmtType); ' ELSE '' END)
			 + (CASE WHEN isnull(u.InternalPartner_Match,'') >'' THEN ' ' 
				+ u.InternalPartner_Match + ' (IP); ' ELSE '' END)
			 + (CASE WHEN isnull(u.Territory_Match,'') >'' THEN ' ' 
				+ u.Territory_Match + ' (TT); ' ELSE '' END) 
			 + (CASE WHEN u.CompanyCountryMatch >'' THEN ' ' 
				+ u.CompanyCountryMatch + ' (CompanyCty); ' ELSE '' END) 
			 + (CASE WHEN isnull(u.TagCategory_Match,'') >'' THEN ' ' 
				+ u.TagCategory_Match + ' (TagCat); ' ELSE '' END) 
				),255))
			 as KeywordMatch_Found

	/* ORIGINAL KEYWORD - from input list */

		, convert(varchar(255),left(LTRIM((CASE WHEN isnull(u.ProductKeyword_Any,'') > '' 
			then u.ProductKeyword_Any + ' (Product); ' ELSE '' END)
			 + (CASE WHEN isnull(u.CompanyMatch_score,0) >0 THEN  ' ' /* is the keyword not found company */
			/*			+ u.companyMatch_Name + ' (Company, ' + convert(varchar(2),u.companymatch_score) + ');' ELSE '' END)*/
				+ companymatch_keyword /* keyword instead *//*+ ' (Company)*/ +'; ' ELSE '' END)
			 + (CASE WHEN isnull(u.Description_Match,'') >'' THEN ' ' 
				+ u.Description_Match + ' (Desc); ' ELSE '' END)
			 + (CASE WHEN isnull(u.AgreementType_Match,'') >'' THEN ' ' 
				+ u.AgreementType_Match + ' (AgrmtType); ' ELSE '' END)
			 + (CASE WHEN isnull(u.InternalPartner_Match,'') >'' THEN ' ' 
				+ u.InternalPartner_Match + ' (IP); ' ELSE '' END)
			 + (CASE WHEN isnull(u.Territory_Match,'') >'' THEN ' ' 
				+ u.Territory_Match + ' (TT); ' ELSE '' END) 
			 + (CASE WHEN isnull(u.CompanyCountryMatch,'') >'' THEN ' ' 
				+ u.CompanyCountryMatch + ' (CompanyCty); ' ELSE '' END) 
			 + (CASE WHEN isnull(u.TagCategory_Match,'') >'' THEN ' ' 
				+ u.TagCategory_Match + ' (TagCat); ' ELSE '' END) 
				),255))
			 as KeywordMatch_Original

/*		, LTRIM((CASE WHEN u.ProductKeyword_Any > '' 
			then 1 ELSE 0 END)
			 + (CASE WHEN u.CompanyMatch_score >0 THEN companymatch_Score ELSE o END)
	/*		 + (CASE WHEN u.Description_Match >'' THEN ' ' 
				+ u.Description_Match + ' (Desc); ' ELSE '' END)
			 + (CASE WHEN u.InternalPartner_Match >'' THEN ' ' 
				+ u.InternalPartner_Match + ' (IP); ' ELSE '' END)
			 + (CASE WHEN u.Territory_Match >'' THEN ' ' 
				+ u.Territory_Match + ' (TT); ' ELSE '' END) 
			 + (CASE WHEN u.CompanyCountryMatch >'' THEN ' ' 
				+ u.CompanyCountryMatch + ' (CompanyCty); ' ELSE '' END) 
			 + (CASE WHEN u.TagCategory_Match >'' THEN ' ' 
				+ u.TagCategory_Match + ' (TagCat); ' ELSE '' END) */
				)
			 as KeywordMatch_Score
		*/

		/* PRODUCT */
			, u.ProductKeyword_Any as 'Product (Any)'
			 /*, p.[KeyWordMatch_TradeName]
			 , p.[KeyWordMatch_ActiveIngredients] */

		 /* COMPANY */
			, u.CompanyMatch_Score
			, u.companyMatch_Level
			, convert(varchar(255), u.CompanyMatch_Name) /* any */ as 'Company (ALL)'

			, convert(varchar(255), u.CompanyMatch_NotExactNotLike) as 'Company (Other)'/* CompanyMatch_KeyWord */
			, convert(varchar(255), u.CompanyMatch_Like) as 'Company (Like)'
			, convert(varchar(255), u.CompanyMatch_Exact) as 'Company (Exact)'
			, convert(varchar(1), U.companyType) as 'C. Type' /* I = Individual, C = Company, U = Undefined */

		/* COUNTRY */
			, convert(varchar(255), u.CompanyCountryMatch) as 'Company Country Match'

		/* DESCRIPTION */
			, u.Description_Match as 'Description Match Only'

		/* LISTS */
			, '' as 'KeyWordSource Lists'
			, convert(varchar(255), u.[Custom1_Lists]) as [Custom1_Lists]
			, convert(varchar(255), u.[Custom2_Lists]) as [Custom2_Lists]
		
		/* TERRITORIES, INTERNAL PARTNERS */
			, convert(varchar(255), u.Territory_Match) AS 'Territory Match'
			, convert(varchar(255), u.InternalPartner_Match) AS 'Internal Partner Match'
			, '' /* U.[TagCategory_Match] */ AS 'Full Text Tag Match'
			, u.AgreementType_Match AS 'Agreement Type Match'
					 
		 /* ALL */
		 , s.*
	 FROM   [Contiki_app].[dbo].[V_TheCompany_KWS_0_ContikiView_LNC] s
				inner join T_TheCompany_KWS_7_LNC_ContractID_SummaryByContractID u
				on s.contractid = u.[ContractID]

GO
/****** Object:  View [dbo].[V_TheCompany_KWSR_0_CNT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_KWSR_0_CNT]
/* be sure to run [TheCompany_KeyWordSearch] */
as

		SELECT
		 LTRIM((CASE WHEN isnull(u.ProductKeyword_Any,'') >'' THEN ' Product' ELSE '' END)
		 + 	(CASE WHEN isnull(u.CompanyMatch_score,0) >0 THEN u.CompanyMatch_LevelCategory
				  ELSE '' END)
		 + 	(CASE WHEN isnull(u.Description_Match,'') >'' THEN ' ' + ' Description' ELSE '' END)
		 + 	(CASE WHEN isnull(u.AgreementType_Match,'') >'' THEN ' ' + ' AgreementType' ELSE '' END)
		 + 	(CASE WHEN isnull(u.InternalPartner_Match,'') >'' THEN ' ' + ' InternalPartner' ELSE '' END)
		 + 	(CASE WHEN isnull(u.Territory_Match,'') >'' THEN ' ' + ' Territory' ELSE '' END)	
		 + 	(CASE WHEN isnull(u.CompanyCountryMatch,'') >'' THEN ' ' + ' Country(Company)' ELSE '' END)	
		 + 	(CASE WHEN isnull(u.TagCategory_Match,'') >'' THEN ' ' + ' TagCategory' ELSE '' END)			 
		 )
			 as MatchLevel

	/* FOUND KEYWORD - found in search, not original keyword */
		, convert(varchar(255),left(LTRIM((CASE WHEN isnull(u.ProductKeyword_Any,'') > '' 
			then isnull(u.ProductKeyword_Any,'') + ' (Product); ' ELSE '' END)
			 + (CASE WHEN isnull(u.CompanyMatch_Score,0) >0 THEN  ' ' /* is the keyword not found company */
			/*			+ u.companyMatch_Name + ' (Company, ' + convert(varchar(2),u.companymatch_score) + ');' ELSE '' END)*/
				+ isnull(u.CompanyMatch_Name,'') /* keyword instead */+ ' (Company); ' ELSE '' END)
			 + (CASE WHEN isnull(u.Description_Match,'') >'' THEN ' ' 
				+ u.Description_Match + ' (Desc); ' ELSE '' END)
			 + (CASE WHEN isnull(u.AgreementType_Match,'') >'' THEN ' ' 
				+ u.AgreementType_Match + ' (AgrmtType); ' ELSE '' END)
			 + (CASE WHEN isnull(u.InternalPartner_Match,'') >'' THEN ' ' 
				+ u.InternalPartner_Match + ' (IP); ' ELSE '' END)
			 + (CASE WHEN isnull(u.Territory_Match,'') >'' THEN ' ' 
				+ u.Territory_Match + ' (TT); ' ELSE '' END) 
			 + (CASE WHEN u.CompanyCountryMatch >'' THEN ' ' 
				+ u.CompanyCountryMatch + ' (CompanyCty); ' ELSE '' END) 
			 + (CASE WHEN isnull(u.TagCategory_Match,'') >'' THEN ' ' 
				+ u.TagCategory_Match + ' (TagCat); ' ELSE '' END) 
				),255))
			 as KeywordMatch_Found

	/* ORIGINAL KEYWORD - from input list */

		, convert(varchar(255),left(LTRIM((CASE WHEN isnull(u.ProductKeyword_Any,'') > '' 
			then u.ProductKeyword_Any + ' (Product); ' ELSE '' END)
			 + (CASE WHEN isnull(u.CompanyMatch_score,0) >0 THEN  ' ' /* is the keyword not found company */
			/*			+ u.companyMatch_Name + ' (Company, ' + convert(varchar(2),u.companymatch_score) + ');' ELSE '' END)*/
				+ companymatch_keyword /* keyword instead *//*+ ' (Company)*/ +'; ' ELSE '' END)
			 + (CASE WHEN isnull(u.Description_Match,'') >'' THEN ' ' 
				+ u.Description_Match + ' (Desc); ' ELSE '' END)
			 + (CASE WHEN isnull(u.AgreementType_Match,'') >'' THEN ' ' 
				+ u.AgreementType_Match + ' (AgrmtType); ' ELSE '' END)
			 + (CASE WHEN isnull(u.InternalPartner_Match,'') >'' THEN ' ' 
				+ u.InternalPartner_Match + ' (IP); ' ELSE '' END)
			 + (CASE WHEN isnull(u.Territory_Match,'') >'' THEN ' ' 
				+ u.Territory_Match + ' (TT); ' ELSE '' END) 
			 + (CASE WHEN isnull(u.CompanyCountryMatch,'') >'' THEN ' ' 
				+ u.CompanyCountryMatch + ' (CompanyCty); ' ELSE '' END) 
			 + (CASE WHEN isnull(u.TagCategory_Match,'') >'' THEN ' ' 
				+ u.TagCategory_Match + ' (TagCat); ' ELSE '' END) 
				),255))
			 as KeywordMatch_Original

/*		, LTRIM((CASE WHEN u.ProductKeyword_Any > '' 
			then 1 ELSE 0 END)
			 + (CASE WHEN u.CompanyMatch_score >0 THEN companymatch_Score ELSE o END)
	/*		 + (CASE WHEN u.Description_Match >'' THEN ' ' 
				+ u.Description_Match + ' (Desc); ' ELSE '' END)
			 + (CASE WHEN u.InternalPartner_Match >'' THEN ' ' 
				+ u.InternalPartner_Match + ' (IP); ' ELSE '' END)
			 + (CASE WHEN u.Territory_Match >'' THEN ' ' 
				+ u.Territory_Match + ' (TT); ' ELSE '' END) 
			 + (CASE WHEN u.CompanyCountryMatch >'' THEN ' ' 
				+ u.CompanyCountryMatch + ' (CompanyCty); ' ELSE '' END) 
			 + (CASE WHEN u.TagCategory_Match >'' THEN ' ' 
				+ u.TagCategory_Match + ' (TagCat); ' ELSE '' END) */
				)
			 as KeywordMatch_Score
		*/

		/* PRODUCT */
			, u.ProductKeyword_Any as 'Product (Any)'
			 /*, p.[KeyWordMatch_TradeName]
			 , p.[KeyWordMatch_ActiveIngredients] */

		 /* COMPANY */
			, u.CompanyMatch_Score
			, u.companyMatch_Level
			, convert(varchar(255), u.CompanyMatch_Name) /* any */ as 'Company (ALL)'

			, convert(varchar(255), u.CompanyMatch_NotExactNotLike) as 'Company (Other)'/* CompanyMatch_KeyWord */
			, convert(varchar(255), u.CompanyMatch_Like) as 'Company (Like)'
			, convert(varchar(255), u.CompanyMatch_Exact) as 'Company (Exact)'
			, convert(varchar(1), U.companyType) as 'C. Type' /* I = Individual, C = Company, U = Undefined */

		/* COUNTRY */
			, convert(varchar(255), u.CompanyCountryMatch) as 'Company Country Match'

		/* DESCRIPTION */
			, u.Description_Match as 'Description Match Only'

		/* LISTS */
			, '' as 'KeyWordSource Lists'
			, convert(varchar(255), u.[Custom1_Lists]) as [Custom1_Lists]
			, convert(varchar(255), u.[Custom2_Lists]) as [Custom2_Lists]
		
		/* TERRITORIES, INTERNAL PARTNERS */
			, convert(varchar(255), u.Territory_Match) AS 'Territory Match'
			, convert(varchar(255), u.InternalPartner_Match) AS 'Internal Partner Match'
			, U.[TagCategory_Match] AS 'Full Text Tag Match'
			, u.AgreementType_Match AS 'Agreement Type Match'
					 
		 /* ALL */
		 , s.*
	 FROM   [Contiki_app].[dbo].[T_TheCompany_KWS_0_ContikiView_CNT] s
				inner join T_TheCompany_KWS_7_CNT_ContractID_SummaryByContractID u
				on s.contractid = u.[ContractID]

GO
/****** Object:  View [dbo].[V_TheCompany_KWSR_1_CNT_ARB]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[V_TheCompany_KWSR_1_CNT_ARB]

as

	select 0 as 'Download File', 'Contiki' as DatabaseSource, * from 
	[dbo].[V_TheCompany_KWSR_0_CNT]

	union all

	select 0 as 'Download File','Ariba' as DatabaseSource, * from 
	[dbo].[V_TheCompany_KWSR_0_ARB] 

	union all
	
	select 0 as 'Download File','JP_Sunrise' as DatabaseSource, * from 
	[dbo].[V_TheCompany_KWSR_0_JPS] 

	union all
	
	select 0 as 'Download File','LINC(Axxerion)' as DatabaseSource, * from 
	[dbo].[V_TheCompany_KWSR_0_LNC] 

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_1_JPS_MiscMetadataFields]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view 
[dbo].[V_TheCompany_KWS_1_JPS_MiscMetadataFields]

as 

	SELECT  
		s.KeyWordVarchar255
		, s.KeyWordType
		, s.KeyWordPrecision
		, s.KeyWordOperator
		, p.[Agreement Type] /* is agreement type */ + (case when p.[Agreement Type] /* is agreement type */ not like '%'+s.KeyWordVarchar255+'%' 
				THEN + ' - ' + p.[Contract Description] ELSE ''
				END) 
				as 'FieldContent'
		, p.CONTRACTID

	FROM [V_TheCompany_KeyWordSearch] s 
		inner join V_TheCompany_KWS_0_ContikiView_JPS p 
			on p.[Agreement Type] like '%'+s.KeyWordVarchar255+'%' /* NO type for e.g. supply */
			OR p.[Contract Description] like '%'+s.KeyWordVarchar255+'%' /* e.g. supply agreement does not exist as agreement type */
	where /* p.statusid = 5  active */
		s.KeyWordtype = 'AgreementType'

GO
/****** Object:  View [dbo].[V_TheCompany_VDEPARTMENTROLE_IN_OBJECT_OLD]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[V_TheCompany_VDEPARTMENTROLE_IN_OBJECT_OLD]
/* used in BO PROD Universe */
as 

select 
	o.DEPARTMENTROLE_IN_OBJECTID
	, o.OBJECTID
	, o.ROLEID
	, u.* 
	, (CASE WHEN d.DEPARTMENT_CODE not like ',%' /* not internal partner */ 
		and d.DEPARTMENT_CODE like '%.%,,%' /* is Rep Office */ then 
		/* pick up rep office Department codes like .RS**,DET(TAK-DE),, */
			replace(SUBSTRING(d.DEPARTMENT_CODE, CHARINDEX(',', d.DEPARTMENT_CODE)
				, CHARINDEX(',,', d.DEPARTMENT_CODE)),',,','')
		ELSE '' END
		) as Dpt_Code_IP_RepOffice
	, d.DEPARTMENT
	, d.DEPARTMENT_CODE
	, d.DPT_CODE_2Digit
	, d.DPT_CODE_2Digit_InternalPartner
	, d.DPT_CODE_2Digit_TerritoryRegion
	, d.FieldCategory
	, d.NodeRole
	, d.NodeType
	/*, d.ISDEPARTMENT */
	, r.[ROLE]
	/* , di. */
FROM TDEPARTMENTROLE_IN_OBJECT o 
	inner join TUSERGROUP u on o.DEPARTMENTID = u.DEPARTMENTID
	inner join TROLE r on o.ROLEID = r.ROLEID
	left join [dbo].[V_TheCompany_VDepartment_Parsed] /* TDEPARTMENT */ d 
		on u.DEPARTMENTID = d.DEPARTMENTID
	/* left join [V_TheCompany_VDepartment_InternalPartner_ParsedDpt] di 
		on o.DEPARTMENTID = di.DEPARTMENTID */
WHERE d.noderole = 'I'

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_7_JPS_ContractID_SummaryByContractID]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
















CREATE view

[dbo].[V_TheCompany_KWS_7_JPS_ContractID_SummaryByContractID]

as 
/* EXEC [dbo].[TheCompany_KeyWordSearch] */
	SELECT  
		u.contractid /* as ContractID_KWS */

/* COMPANY */
	
	/* EXACT */

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ',' + c.[CompanyMatch_Exact] 
			FROM [T_TheCompany_KWS_3_JPS_TCompany_ContractID_Extended] c
			WHERE  c.contractid = u.contractid 
				AND c.companyMatch_Exact_Flag > 0
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [CompanyMatch_Exact]
		,
			(SELECT max(CompanyMatch_Exact_Flag)
			FROM [T_TheCompany_KWS_3_JPS_TCompany_ContractID_Extended] c
			WHERE  c.contractid = u.contractid
				AND c.companyMatch_Exact_Flag > 0
				)
			 AS [CompanyMatch_Exact_FLAG]

	/* LIKE */
			,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + c.[CompanyMatch_Like] /*+': ' 

				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM [T_TheCompany_KWS_3_JPS_TCompany_ContractID_Extended] c
			where  c.contractid = u.contractid   
				and [CompanyMatch_Like_FLAG] > 0
				and [CompanyMatch_Exact_FLAG] = 0
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [CompanyMatch_Like]	

		,
			(SELECT max(CompanyMatch_LIKE_Flag)
			FROM [T_TheCompany_KWS_3_JPS_TCompany_ContractID_Extended] c
			WHERE  c.contractid = u.contractid
				and [CompanyMatch_Like_FLAG] > 0
				and [CompanyMatch_Exact_FLAG] = 0
			)
			 AS [CompanyMatch_LIKE_FLAG]

	/* Company ANY */
						,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + c.[KeyWordVarchar255] /*+': ' 

				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM [T_TheCompany_KWS_3_JPS_TCompany_ContractID_Extended] c
			where  c.contractid = u.contractid   
				and [CompanyMatch_Like_FLAG] = 0
				and [CompanyMatch_Exact_FLAG] = 0
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS CompanyMatch_NotExactNotLike	

						,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + c.[Companytype] /*+': ' 

				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM [T_TheCompany_KWS_3_JPS_TCompany_ContractID_Extended] c
			where  c.contractid = u.contractid   
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS CompanyType

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
				FROM T_TheCompany_KWS_3_JPS_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid)
					AS [CompanyMatch_Level]

	/* Level - Company Match Category */

			, (SELECT MIN( 
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
				FROM T_TheCompany_KWS_3_JPS_TCompany_ContractID_Extended c
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
				FROM T_TheCompany_KWS_3_JPS_TCompany_ContractID_Extended c
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
				FROM T_TheCompany_KWS_3_JPS_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid),255))
					AS [CompanyMatch_Name]

			, (SELECT MAX([KeyWordVarchar255]) from T_TheCompany_KWS_3_JPS_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid) 
					as CompanyMatch_KeyWord
			, (SELECT MAX([KeyWordVarchar255_UPPER]) from T_TheCompany_KWS_3_JPS_TCompany_ContractID_Extended c
					where  c.contractid = u.contractid) 
					as CompanyMatch_KeyWord_UPPER					   
	/* COUNTRY - Company */

						,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordVarchar255] /*+': ' 
				+ rs.[CompanyMatch_Name]  + ' (Keyword: '+ rs.keywordvarchar255 
				+ ', Company: ' + rs.[Company_LettersNumbersSpacesOnly] +')' */
			FROM T_TheCompany_KWS_2_JPS_TCOMPANYCountry_ContractID rs
			where  rs.contractid = u.contractid   
			FOR XML PATH('')),1,1,''),'&amp;','&')) AS [CompanyCountryMatch]	
			

/* CUSTOM FIELDS */

		,Replace(STUFF(
			(
			SELECT DISTINCT ',' + rs.[KeyWordCustom1]
			FROM (select [KeyWordCustom1], contractid from T_TheCompany_KWS_2_JPS_TPRODUCT_ContractID
					UNION
					select [KeyWordCustom1], contractid from T_TheCompany_KWS_2_JPS_TCompany_ContractID
					) rs
			where  rs.contractid = u.contractid
				AND rs.[KeyWordCustom1] IS NOT NULL

			/* and rs.ProductExact_Flag = 1 */
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Custom1_Lists

		,Replace(STUFF(
			(SELECT DISTINCT ',' + rs.[KeyWordCustom2]
			FROM T_TheCompany_KWS_2_JPS_TPRODUCT_ContractID rs
			where  rs.contractid = u.contractid
			AND rs.[KeyWordCustom2] IS NOT NULL
			/* and rs.ProductExact_Flag = 1 */
			FOR XML PATH('')),1,1,''),'&amp;','&') AS Custom2_Lists

	/* DESCRIPTION */

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[DescriptionKeyword]
			FROM [T_TheCompany_KWS_5c_JPS_DESCRIPTION_ContractID] rs
			where  rs.contractid = u.contractid
			/* only include records that are not a company match */
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS Description_Match

	/* INTERNAL PARTNER */

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordVarchar255]
			FROM [T_TheCompany_KWS_2_JPS_InternalPartner_ContractID] rs
			where  rs.contractid = u.contractid
			/* only include records that are not a company match */
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS InternalPartner_Match

	/* TERRITORIES */

		,LTRIM(Replace(STUFF(
			(SELECT DISTINCT ', ' + rs.[KeyWordVarchar255]
			FROM [T_TheCompany_KWS_2_JPS_Territories_ContractID] rs
			where  rs.contractid = u.contractid
			/* only include records that are not a company match */
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS Territory_Match

	/* PRODUCTS */

		,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[T_TheCompany_KWS_3_JPS_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and p.[ProductMatch_TN] = 1
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_TradeName

						 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[T_TheCompany_KWS_3_JPS_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and p.[ProductMatch_AI] = 1
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_ActiveIngredients

		 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup
		FROM [dbo].[T_TheCompany_KWS_3_JPS_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and p.[ProductMatch_Exact] = 1
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Product_EXACT

		 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[T_TheCompany_KWS_3_JPS_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and p.[ProductMatch_NotExact] = 1
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Product_NotExact

			 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup + ' ('+ p.keywordvarchar255 + ')' 
		FROM [dbo].[T_TheCompany_KWS_3_JPS_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid and (p.[ProductMatch_AI] = 1 OR p.[ProductMatch_TN] = 1)
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordMatch_Product_AIorTN

				 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.productgroup 
			+ (CASE WHEN PrdGrpMatch_EXACT_FLAG = 1 THEN '' ELSE ' ('+ p.keywordvarchar255 + ')' END)
		FROM [dbo].[T_TheCompany_KWS_3_JPS_TProduct_ContractID_Extended] p 
		where  p.CONTRACTID = u.contractid 
		/* and (p.[ProductMatch_AI] = 1 OR p.[ProductMatch_TN] = 1) */
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS ProductKeyword_Any

	/* TAG */
	/*			 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.tagcategory
		FROM [dbo].[T_TheCompany_KWS_2_JPS_Tag_ContractID] p 
		where  p.CONTRACTID = u.contractid 
		and P.keywordtype = 'TagCategory'
		FOR XML PATH('')),1,1,''),'&amp;','&')) */, '' AS TagCategory_Match

		/*
				 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.tag
		FROM [dbo].[T_TheCompany_KWS_2_JPS_Tag_ContractID] p 
		where  p.CONTRACTID = u.contractid 
		and P.keywordtype = 'Tag'
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS Tag_Match */
				 ,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + p.FieldContent
		FROM [dbo].[V_TheCompany_KWS_1_JPS_MiscMetadataFields] p 
		where  p.CONTRACTID = u.contractid 
		and P.keywordtype = 'AgreementType'
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS AgreementType_Match

	FROM 
		T_TheCompany_KWS_6_JPS_ContractID_UNION  u /* product, company, description */
	group by 
		u.contractid


GO
/****** Object:  View [dbo].[V_TheCompany_FullText_TFILEINFO_OCR_FileIDsInScope]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View [dbo].[V_TheCompany_FullText_TFILEINFO_OCR_FileIDsInScope]

as
/* View will result in duplicate file ids if there is more than one version of a file */
/* corrupt pdfs are given a fetch counter of 99, to exclude them */
	select top 5000 
		(case when (OCRFetchCounter is null OR OCRFetchCounter = 0) /* no full text content */
			THEN 1 ELSE 0 END) as InScopeFlag /* file must be at least 48 hours old 
			to make sure it is included in the full text index
			otherwise it might have full text content but that is not yet recognized */
		,* 		
	from
		[dbo].[TFILEINFO]
	 where 
		filetype = '.pdf'
		and filesize >0
		and [LastChangedDate] < dateadd(dd,-7,getdate())
		and LastChangedBy <>83663 /* not modified by user joest, i.e. uploaded via document pumper or modified manually */
		and (OCRFetchCounter is null OR OCRFetchCounter = 0)
		/* do signed contracts first if too many */
		and documentid in (select documentid 
								from tdocument 
								where documenttypeid = 1 /* signed contracts */)
		and fileid not in (select fileid from tfileinfo where OCRFetchCounter > 0) 
			/* file not previously picked for ocr scan with the fetch counter set to 1 or higher
			, if the file is uploaded yet again, it will have fetch counter 0 again */
	order by LastChangedDate desc /* make sure latest files get scanned first! */

GO
/****** Object:  View [dbo].[V_TheCompany_FullText_IncludeOverview]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View 

[dbo].[V_TheCompany_FullText_IncludeOverview]

as

	select 
		[InScopeFlag]
		, c.InternalPartners
		, d.Title
		, d.FileType
		, c.number
		, f.[FileID]
		, f.[DocumentID]
		, [OCRFetchCounter]
		, LastChangedDate
		, LastChangedBy			
	from
		[dbo].[V_TheCompany_FullText_TFILEINFO_OCR_FileIDsInScope] f 
			inner join Vdocument d on f.documentid = d.documentid
			inner join T_TheCompany_ALL c on d.objectid = c.contractid
GO
/****** Object:  View [dbo].[V_TheCompany_VPRODUCTGROUP_ALL_NOMENCLATURES]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create view [dbo].[V_TheCompany_VPRODUCTGROUP_ALL_NOMENCLATURES]

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
	,(CASE WHEN p.PRODUCTGROUPID IN(select PRODUCTGROUPID from dbo.VPRODUCTGROUPS_IN_CONTRACT) THEN 1 ELSE 0 END) as ProductGroup_IsUsed
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
/*	WHERE 
		(p.PRODUCTGROUPNOMENCLATUREID IN('2' /* API */,'3' /* TN */) 
		OR (p.PRODUCTGROUPNOMENCLATUREID = '7' /* Project ID, only if valid */ 
			AND p.MIK_VALID = 1))
		/*	and p.parentid = 2629 */
	/* AND LEN(PRODUCTGROUP)>3  e.g. GEM */
	/* and Productgroupid in (6196) */
	*/
GO
/****** Object:  View [dbo].[V_SEARCHENGINE_SEARCHSIMPLEDOCUMENT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  View [dbo].[V_SEARCHENGINE_SEARCHSIMPLEDOCUMENT]******/
CREATE VIEW [dbo].[V_SEARCHENGINE_SEARCHSIMPLEDOCUMENT] 
AS 
SELECT	
        CASE
			WHEN	OWN.ObjectTypeFixed	= N'TENDERER' 
			THEN ISNULL(C.ContractNumber,N'')
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
		dbo.udf_get_companyid(C.CONTRACTID)    			AS CONTRACT_COMPANYID, 
		ST_Contract.Fixed								AS CONTRACT_STATUS_FIXED, 
		C.SharedWithSupplier							AS CONTRACT_SHAREDWITHSUPPLIER,
		CONVERT(BIT,	CASE WHEN EXISTS
				(	SELECT TOP 1 DU.DOCUMENTID 
					FROM TDOCUMENT_SHARED_WITH_CCS_USER DU 
					WHERE D.DOCUMENTID = DU.DOCUMENTID
				)	
				THEN 1 
				ELSE 0 
		END	)											AS SHAREDONCCS,
		SFI.ModuleID										AS MODULEID  
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
  LEFT	OUTER 
  JOIN	dbo.TFileInfo									SFI 
	ON	D.SOURCEFILEINFOID								= SFI.FileInfoID
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
				CASE WHEN T.ContractID IS NOT NULL THEN T.ContractID
					WHEN T.RfxID IS NOT NULL  THEN (SELECT TRFX.CONTRACTID FROM dbo.TRFX WHERE TRFX.RFXID=T.RFXID)
					ELSE NULL END						AS ContractID,
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
/****** Object:  View [dbo].[V_TheCompany_FullText_Vipidia_WithFilterOnContractNumber]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_FullText_Vipidia_WithFilterOnContractNumber]

as

SELECT 'Vipidia' as txt_kwd, 1 as Relevance,
t.* FROM [V_SEARCHENGINE_SEARCHSIMPLEDOCUMENT] t  INNER JOIN TFILE 
ON TFILE.FileId = t.FileId 
WHERE TFILE.FileId IN (SELECT KEY_TBL.[KEY] 
						FROM CONTAINSTABLE(TFILE, [File], '"Vipidia"' ) 
						AS KEY_TBL WHERE KEY_TBL.RANK > 10) 
						AND (1=1 AND t.MIKVALID = N'1') 
						and t.OBJECTOWNERNAME like 'CTK-Case-00001451%'
GO
/****** Object:  View [dbo].[V_TheCompany_LNC_Mig_MASTER_Products_ALL]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_LNC_Mig_MASTER_Products_ALL]

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
/****** Object:  View [dbo].[V_TheCompany_TPERSONROLE_IN_OBJECT_FLAT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_TPERSONROLE_IN_OBJECT_FLAT]

as


SELECT
d.objectid 
, MIN(PERSONROLE_IN_OBJECTID) as MIN_PERSONROLE_IN_OBJECTID
,
(SELECT s.personid
FROM TPERSONROLE_IN_OBJECT s
WHERE s.objecttypeid = 1 AND s.objectid =d.OBJECTID AND s.ROLEID = 1 /* SU *//*IN(1,19,20,34,23 /*Super User*/) */
) AS Tpr_SuperUser_Prs_ID

,
(SELECT s.personid
FROM TPERSONROLE_IN_OBJECT s
WHERE s.objecttypeid = 1 AND s.objectid =d.OBJECTID AND s.ROLEID = 2 /* CO */
) AS Tpr_ContractOwner_Prs_ID

, (select employeeid from TEMPLOYEE where PERSONID = (SELECT s.personid
FROM TPERSONROLE_IN_OBJECT s
WHERE s.objecttypeid = 1 AND s.objectid =d.OBJECTID AND s.ROLEID = 2 /* CO */
)) as Tpr_ContractOwner_EmpID
,
(SELECT s.personid
FROM TPERSONROLE_IN_OBJECT s
WHERE s.objecttypeid = 1 AND s.objectid = d.OBJECTID AND s.ROLEID = 15 /* CR */
) AS Tpr_ContractResponsible_Prs_ID

, (select employeeid from TEMPLOYEE where PERSONID = (SELECT s.personid
FROM TPERSONROLE_IN_OBJECT s
WHERE s.objecttypeid = 1 AND s.objectid =d.OBJECTID AND s.ROLEID = 15 /* CR */
)) as Tpr_ContractResponsible_EmpID

,COUNT(ROLEID)AS PersonRoles_Total_COUNT
, max(a.contractnumber) as Contractnumber
, MAX(a.statusid) as ContractStatusID

, max(a.EXECUTORID) as SU_UserID
, max(a.OWNERID) as CO_EmpID
, max(a.TECHCOORDINATORID) as CR_EmpID

, (SELECT Personid from VUSER where userid = max(a.EXECUTORID)) as SU_PrsID
, (SELECT Personid from TEMPLOYEE where EMPLOYEEID = max(a.OWNERID)) as CO_PrsID
, (SELECT Personid from TEMPLOYEE where EMPLOYEEID = max(a.TECHCOORDINATORID)) as CR_PrsID

, (CASE WHEN 
		(SELECT s.personid
		FROM TPERSONROLE_IN_OBJECT s
		WHERE s.objecttypeid = 1 AND s.objectid =d.OBJECTID AND s.ROLEID = 1 /* SU */) is null then NULL
	WHEN
	(SELECT s.personid
	FROM TPERSONROLE_IN_OBJECT s
	WHERE s.objecttypeid = 1 AND s.objectid =d.OBJECTID AND s.ROLEID = 1 /* SU */)
	= (SELECT Personid from VUSER where USERID = max(a.EXECUTORID)) THEN 1 
	ELSE 0 END)
	as SU_PrsID_Match
	
, (CASE WHEN 
	(SELECT s.personid
		FROM TPERSONROLE_IN_OBJECT s
		WHERE s.objecttypeid = 1 AND s.objectid =d.OBJECTID AND s.ROLEID = 2 /* CO */) IS NULL THEN NULL
	WHEN
	(SELECT s.personid
	FROM TPERSONROLE_IN_OBJECT s
	WHERE s.objecttypeid = 1 AND s.objectid =d.OBJECTID AND s.ROLEID = 2 /* CO */)
	= (SELECT Personid from TEMPLOYEE where EMPLOYEEID = max(a.OWNERID)) THEN 1 ELSE 0 END)
	as CO_PrsID_Match

, (CASE WHEN 
(SELECT s.personid
	FROM TPERSONROLE_IN_OBJECT s
	WHERE s.objecttypeid = 1 AND s.objectid = d.OBJECTID AND s.ROLEID = 15 /* CR */) is null THEN NULL
	WHEN
		(SELECT s.personid
	FROM TPERSONROLE_IN_OBJECT s
	WHERE s.objecttypeid = 1 AND s.objectid = d.OBJECTID AND s.ROLEID = 15 /* CR */)
	= (SELECT Personid from TEMPLOYEE where EMPLOYEEID = max(a.TECHCOORDINATORID)) THEN 1 ELSE 0 END)
	as CR_PrsID_Match


FROM TPERSONROLE_IN_OBJECT d inner join TCONTRACT a on d.OBJECTID = a.contractid
/* WHERE d.CONTRACTID not in(select CONTRACTID from tcontract where CONTRACTTYPEID  IN  ('6' /* Access SAKSNR number Series*/, '5' /* Test Old */,'102' /* Test New */,'13' /* DELETE */ )) */
WHERE OBJECTTYPEID = 1
GROUP BY 
OBJECTID



GO
/****** Object:  View [dbo].[V_TheCompany_VPRODUCT_RAW]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_VPRODUCT_RAW]

/* 
[dbo].[TheCompany_KeyWordSearch]
- elminiate double spaces
- ltrim, rtrim
*/
as

	select 
		* 
		, dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([PRODUCTGROUP]) as Product_LettersNumbersOnly
		, replace(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([PRODUCTGROUP]),'  ',' ') as Product_LettersNumbersSpacesOnly /* e.g. Hansen & Rosenthal */
		, LEN(replace(dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([PRODUCTGROUP]),'  ',' '))
			-LEN(dbo.TheCompany_RemoveNonAlphaNonNumericCharacters([PRODUCTGROUP])) as Product_LettersNumbersOnly_NumSpacesWords
		/*, (CASE 
			WHEN UPPER([COMPANY]) like '% GMBH%' 
				OR UPPER([COMPANY]) like '% LTD%' 
				OR UPPER([COMPANY]) like '% LIMITED'
				OR UPPER([COMPANY]) like '%CORPORATION%'
				OR UPPER([COMPANY]) like '%INCORPORATED'
				OR UPPER([COMPANY]) like '%GESELLSCHAFT%'
				OR UPPER([COMPANY]) like '% GROUP%'
				OR UPPER([COMPANY]) like '% AG' /* Lundberg, Agneta */
				OR UPPER([COMPANY]) like '%[^A-Z]AS'
				OR UPPER([COMPANY]) like '%[^A-Z]A/S%'
				OR UPPER([COMPANY]) like '%[^A-Z]%INC[^A-Z]%'
				THEN 'C'
			WHEN LEN([Company]) < 7 THEN 'C' /*individuals have at least first last name and title */
			WHEN [Company] not like '%,%' THEN 'C' /* Individuals should have a comma in the name */
			WHEN UPPER([COMPANY]) like '%, DR.%'
				OR  [COMPANY] like '%, PROF.%'
				OR  [COMPANY] like '%, MR.%'
				THEN 'I' 
			ELSE 'U' END) AS CompanyType */
	from TPRODUCTGROUP 
	/* where [KeyWordVarchar255] like 'Si%' */
	/* where dbo.TheCompany_RemoveNonAlphaNonNumNonSpace([KeyWordVarchar255]) like '%  %' */

GO
/****** Object:  View [dbo].[V_TheCompany_VPRODUCT]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_TheCompany_VPRODUCT]
/* refreshed via TheCompany_Product_Search */
as

	select 
		c.*
		,  Upper([PRODUCTGROUP]) as Productgroup_UPPER
		, (CASE WHEN (PRODUCTGROUPID IN (select PRODUCTGROUPID from TTENDERER) )
							THEN 1 ELSE 0 END) as ProductIDExists
			/* , dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(c.COMPANY) 
		as CompanyName_RemoveNonAlphaNonNumericChar /* leave numbers, e.g. 3M */ */

		, len([PRODUCTGROUP]) as Product_Length

			, SUBSTRING(Product_LettersNumbersSpacesOnly,1,(CHARINDEX(' ',Product_LettersNumbersSpacesOnly + ' ')-1)) 
		as Product_FirstWord
			,SUBSTRING([Product_LettersNumbersOnly],1,(CHARINDEX(' ',[Product_LettersNumbersOnly] + ' ')-1))
		as Product_FirstWord_LettersOnly
			, LEN(SUBSTRING([PRODUCTGROUP],1,(CHARINDEX(' ',[PRODUCTGROUP] + ' ')-1))) 
		as Product_FirstWord_LEN

		/* two words or more */
		, (CASE WHEN [Product_LettersNumbersOnly_NumSpacesWords] = 1 
					THEN [Product_LettersNumbersSpacesOnly] /* one space */
				WHEN Product_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN SUBSTRING([Product_LettersNumbersSpacesOnly],0,CHARINDEX(' ', [Product_LettersNumbersSpacesOnly],
						CHARINDEX(' ', [Product_LettersNumbersSpacesOnly],
									   CHARINDEX(' ', [Product_LettersNumbersSpacesOnly],+1)+1)) )	/* e.g. SI Group */	
				ELSE NULL /* no space */ END)			
		as Product_FirstTwoWords

		, (CASE WHEN [Product_LettersNumbersOnly_NumSpacesWords] = 1 /* two words, one space */
					THEN [Product_LettersNumbersOnly]
				WHEN Product_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(SUBSTRING([Product_LettersNumbersSpacesOnly],0,CHARINDEX(' ', [Product_LettersNumbersSpacesOnly],
						CHARINDEX(' ', [Product_LettersNumbersSpacesOnly],
									   CHARINDEX(' ', [Product_LettersNumbersSpacesOnly],+1)+1)) ))	/* e.g. SI Group */	
				ELSE NULL /* no space */ END)			
		as Product_FirstTwoWords_LettersOnly

			,  LEN((CASE WHEN [Product_LettersNumbersOnly_NumSpacesWords] = 1 /* two words, one space */
					THEN [Product_LettersNumbersOnly]
				WHEN Product_LettersNumbersOnly_NumSpacesWords > 1 /* two spaces or more, make sure there is at least one space, otherwise '' */
					THEN dbo.TheCompany_RemoveNonAlphaNonNumericCharacters(SUBSTRING([Product_LettersNumbersSpacesOnly],0,CHARINDEX(' ', [Product_LettersNumbersSpacesOnly],
						CHARINDEX(' ', [Product_LettersNumbersSpacesOnly],
									   CHARINDEX(' ', [Product_LettersNumbersSpacesOnly],+1)+1)) ))	/* e.g. SI Group */	
				ELSE NULL /* no space */ END)	)	
		as Product_FirstTwoWords_LettersOnly_LEN

		, (CASE WHEN LEN(dbo.TheCompany_GetFirstLetterOfEachWord([Product_LettersNumbersSpacesOnly])) >=3 
			/* AND c.CompanyType = 'C' */ THEN 
				/* dbo.TheCompany_GetFirstLetterOfEachWord([Product_LettersNumbersOnly])
			WHEN LEN(dbo.TheCompany_GetFirstLetterOfEachWord([Product_LettersNumbersOnly]))<3 
				and len(left([[Product_LettersNumbersOnly],3)) >=3 THEN */
				left([Product_LettersNumbersOnly],3)
			ELSE NULL END
			) 
			as Product_FirstLetterOfEachWord

	from V_TheCompany_VPRODUCT_RAW c 


GO
/****** Object:  View [dbo].[V_TheCompany_Audittrail_HardcopyArchiving]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view 

[dbo].[V_TheCompany_Audittrail_HardcopyArchiving]

as

select 
	c.Number
	, c.InternalPartners
	, r.[HardcopyArchiving]
	/* , a.PARENTOBJECTID
	, a.objectid
	, a.userid */
	, a.time
	/* , a.xml
	, a.OBJECTDESCRIPTION */
	, u.DISPLAYNAME
from 
	TAUDITTRAIL a /* oruse V_TheCompany_Audittrail_WithHistory for more than 3 months 
	but then query needs tuning or audittrail first saved as table 
	with objectid for all hardcopy edits */
	inner join vuser u on a.userid = u.USERID
	inner join V_TheCompany_All c on a.PARENTOBJECTID = c.contractid
	inner join V_TheCompany_VCONTRACT_DPTROLES_FLAT r on r.Dpt_contractid = c.contractid
where OBJECTDESCRIPTION like '%Hardcopy Archive%'
GO
/****** Object:  View [dbo].[V_TheCompany_DupeDocs_CustID_MinDocID_DescExactMatch]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_DupeDocs_CustID_MinDocID_DescExactMatch]

as

SELECT Descriptionfull
, COUNT(DISTINCT OBJECTID) as DupeObjectIDCount
, COUNT(DOCUMENTID) as CountDocID
, MIN(documentid) as MinDocID 
, MAX(Documentid) as MaxDocID
FROM T_TheCompany_Docx 
group by DescriptionFull, CompanyIDList
having COUNT(Documentid) >1
GO
/****** Object:  View [dbo].[V_TheCompany_DupeDocs_CustID_MinDocID_SameHash_FileSize]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_TheCompany_DupeDocs_CustID_MinDocID_SameHash_FileSize]

as

SELECT DescRemNonAlphaHashbSHA1
, filesize
, COUNT(DISTINCT OBJECTID) as DupeObjectIDCount
, COUNT(DOCUMENTID) as CountDocID
, MIN(documentid) as MinDocID 
, MAX(Documentid) as MaxDocID
FROM T_TheCompany_Docx 
group by DescRemNonAlphaHashbSHA1, filesize,CompanyIDList
having COUNT(Documentid) >1
GO
/****** Object:  View [dbo].[V_TheCompany_DuplicateDocuments]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[V_TheCompany_DuplicateDocuments]

as 

SELECT 
d.OBJECTID
, d.DOCUMENTID
, d.DescriptionFull

, tblvw.DP_Doc_IDs
, tblvw.DP_Object_IDs
, tblvw.DupeCountNonAlpha
, tblvw.DupeObjectIDCount
, tblvw.DP_Contract_Numbers
, tblvw.SameTitle
, tblvw.SameHashAndFileSize	

, DupeMinDocIDNonAlpha
, DupeMaxDocIDNonAlpha
, left(d.DescRemNonAlphaHashbSHA1,255) as DescRemNonAlphaHashbSHA1
, tblvw.CompanyIDList
, d.datecreated
, d.filetype
, d.filesize
FROM T_TheCompany_Docx d /* generated from [dbo].[V_TheCompany_DocxValidSignedNotRegForm] */
INNER JOIN 
(
		SELECT 
			DescRemNonAlphaHashbSHA1
			, COUNT(DISTINCT OBJECTID) as DupeObjectIDCount
			,COUNT(Documentid) as DupeCountNonAlpha
			,MIN(Documentid) as DupeMinDocIDNonAlpha
			,MAX(Documentid) as DupeMaxDocIDNonAlpha
			/* ,COUNT(DescriptionFullHashbSHA1) as DupeCountFull */
			/* ALL IDs */
			,SUBSTRING(STUFF(
				(SELECT ',' + Convert(nvarchar(10),s.DOCUMENTID)
				FROM T_TheCompany_Docx s
				WHERE s.DescRemNonAlphaHashbSHA1 = r.DescRemNonAlphaHashbSHA1 AND s.CompanyIDList = r.CompanyIDList 
				FOR XML PATH('')),1,1,''),1,255) 
				AS DP_Doc_IDs
			, (select MinDocID from dbo.[V_TheCompany_DupeDocs_CustID_MinDocID_DescExactMatch]
				where minDocID = MIN(r.Documentid)) as SameTitle
			, (select MinDocID from dbo.[V_TheCompany_DupeDocs_CustID_MinDocID_SameHash_FileSize]
				where minDocID = MIN(r.Documentid)) as SameHashAndFileSize			
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
		) tblvw on 
		tblvw.DescRemNonAlphaHashbSHA1 = d.DescRemNonAlphaHashbSHA1 
		and tblvw.CompanyIDList = d.CompanyIDList
		





GO
/****** Object:  View [dbo].[V_TheCompany_UserID_CountractRoleCount_VUSER_DEL]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view
[dbo].[V_TheCompany_UserID_CountractRoleCount_VUSER_DEL] 
as

select * from dbo.V_TheCompany_UserID_CountractRoleCount_VUSER 
WHERE userid = 85072 /* and
	NumTotalRoles = 0 
	and MIK_VALID = 0 
	and Dt_Logoff_Max is null
	and count_warning is null
	and count_acl is null
	and Count_PersonInWarning is null
	and primaryusergroup not like 'Departments\Legal\Contiki Sys%'
	/* <>3529  'Departments\Legal\Contiki Sys%' */
	and userid not in (0 /* all emps */,1 /* sysadm */)
	and (employeeid is null or employeeid <>0)
	and (personid is null or personid <>0) */




GO
/****** Object:  View [dbo].[V_TheCompany_KWS_4_CNT_TPRODUCT_Summary]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view 
[dbo].[V_TheCompany_KWS_4_CNT_TPRODUCT_Summary]

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

		, count(/* DISTINCT */ p.contractid) as ContractCount

	FROM [V_TheCompany_KWS_3_CNT_TPRODUCT_ContractID_Extended] p
	GROUP BY 
		p.KeyWordVarchar255
		, p.PRODUCTGROUP
		, p.PRODUCTGROUPID
		, p.PRODUCTGROUPNOMENCLATUREID

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_5a_CNT_TPRODUCT_Summary_KeyWord]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view 
[dbo].[V_TheCompany_KWS_5a_CNT_TPRODUCT_Summary_KeyWord]

as 

	SELECT  r.KeyWordVarchar255
			,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + rs.productgroup
		FROM V_TheCompany_KWS_4_CNT_TPRODUCT_Summary rs
		where  rs.keywordvarchar255 = r.keywordvarchar255
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS Product_List


			,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + rs.[KeyWordSource_List]
		FROM V_TheCompany_KWS_4_CNT_TPRODUCT_Summary rs
		where  rs.keywordvarchar255 = r.keywordvarchar255
		AND rs.[KeyWordSource_List] IS NOT NULL
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS KeyWordSource_List
			
			,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + rs.[Custom1_List]
		FROM V_TheCompany_KWS_4_CNT_TPRODUCT_Summary rs
		where  rs.keywordvarchar255 = r.keywordvarchar255
		AND rs.[Custom1_List] IS NOT NULL
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS Custom1_List

			,LTRIM(Replace(STUFF(
		(SELECT DISTINCT ', ' + rs.[Custom2_List]
		FROM V_TheCompany_KWS_4_CNT_TPRODUCT_Summary rs
		where  rs.keywordvarchar255 = r.keywordvarchar255
		AND rs.[Custom2_List] IS NOT NULL
		FOR XML PATH('')),1,1,''),'&amp;','&')) AS Custom2_List
	, count(Productgroupid) as ProductCount

	, sum(contractcount) as ContractCount
	
	,LEFT(LTRIM(Replace(STUFF(
		(SELECT DISTINCT ',' + c.CONTRACTNUMBER
		FROM [dbo].[T_TheCompany_KWS_2_CNT_TPRODUCT_CONTRACTID] rs 
			inner join tcontract c on rs.contractid = c.contractid
		where  rs.keywordvarchar255 = r.keywordvarchar255
		FOR XML PATH('')),1,1,''),'&amp;','&')),255) AS Contract_List
	FROM V_TheCompany_KWS_4_CNT_TPRODUCT_Summary r
	group by r.KeyWordVarchar255

GO
/****** Object:  View [dbo].[V_TheCompany_KWS_5b_CNT_TPRODUCT_Summary_KeyWord_GAP]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view  [dbo].[V_TheCompany_KWS_5b_CNT_TPRODUCT_Summary_KeyWord_GAP]

as

	select top 10000 
	'Contiki' as System
	 , s.KeyWordType
	 /* ,s.sourcedocs */
	 ,s.KeyWordVarchar255

		, r.Product_List
		, r.ProductCount
		, r.KeyWordSource_List
		, r.Custom1_List
		, r.Custom2_List
		, r.ContractCount

	from V_TheCompany_KeyWordSearch s 
		left join V_TheCompany_KWS_5a_CNT_TPRODUCT_Summary_KeyWord  r 
		on s.KeyWordVarchar255 = r.KeyWordVarchar255
	where 
	[KeyWordType] = 'Product'  
	and ([KeyWordSource] is null
		or  [KeyWordSource] not like 'Product Hierarchy%' /*products added from hierarchy not to be gapped */)
	order by s.keywordcategory desc, s.KeyWordVarchar255

GO
/****** Object:  View [dbo].[V_TheCompany_FullTextNonCompete]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[V_TheCompany_FullTextNonCompete]

as

SELECT 'non-compete, non-competition' as txt_kwd, 1 as Relevance,
t.* FROM [V_SEARCHENGINE_SEARCHSIMPLEDOCUMENT] t  INNER JOIN TFILE 
ON TFILE.FileId = t.FileId 
WHERE TFILE.FileId IN (SELECT KEY_TBL.[KEY] 
						FROM CONTAINSTABLE(TFILE, [File], '"non-compete" OR "non-competition"' ) 
						AS KEY_TBL WHERE KEY_TBL.RANK > 10) 
						AND (1=1 AND t.MIKVALID = N'1') 
GO
