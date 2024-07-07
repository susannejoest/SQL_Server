USE [DAQ-1445_TheVendor_App_DESQL016_Divestment]
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_0_ARIBADataLoad_02]    Script Date: 24 Jun 2024 08:39:02 ******/
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

ALTER PROCEDURE [dbo].[TheCompany_0_ARIBADataLoad_02]

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

