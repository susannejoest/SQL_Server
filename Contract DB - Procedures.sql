USE [DAQ-1445_ContractsDB_App_DESQL016_Divestment]
GO
/****** Object:  UserDefinedFunction [dbo].[CUF_GETCONTRACTPRODUCTGROUPS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CUF_GETCONTRACTPRODUCTGROUPS](@CONTRACTID BIGINT)
RETURNS NVARCHAR(4000)
AS
BEGIN
	RETURN ISNULL(SUBSTRING((SELECT ';' + ISNULL(X.PRODUCTGROUP, '') + ISNULL('(CODE: ' + X.PRODUCTGROUPCODE + ')', '') 
	FROM DBO.TPRODUCTGROUP X INNER JOIN TPROD_GROUP_IN_CONTRACT Y ON Y.PRODUCTGROUPID = X.PRODUCTGROUPID
	WHERE Y.CONTRACTID = @CONTRACTID
	FOR XML PATH, TYPE).value('.[1]', 'nvarchar(max)'), 2, 4000), '')  

END

GO
/****** Object:  UserDefinedFunction [dbo].[dch_fColumnExists]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[dch_fColumnExists](
	@TableName		VARCHAR(256),
	@ColumnName		VARCHAR(256)
	) RETURNS INT
AS
BEGIN
	DECLARE	@OrdinalPosition		INT

	SELECT	@OrdinalPosition		= ORDINAL_POSITION
	  FROM	INFORMATION_SCHEMA.COLUMNS
	 WHERE	TABLE_SCHEMA			= 'dbo'
	   AND	TABLE_NAME				= @TableName
	   AND	COLUMN_NAME				= @ColumnName

	IF	@OrdinalPosition	IS NOT NULL
		RETURN	1

	RETURN 0
END

GO
/****** Object:  UserDefinedFunction [dbo].[dch_fGetFKName]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------
--	Constraints management procedures and functions
--------------------------------------------------------------------------------
--	Function returns foreign key constraint name if exists,
--	otherwise it returns NULL value
CREATE FUNCTION  [dbo].[dch_fGetFKName]	(
	@MasterTable	VARCHAR(256),	--	Name of master table (referenced table)
	@MasterField	VARCHAR(256),	--	Name of field in master table where constraint references to
	@DetailTable	VARCHAR(256),	--	Name of detail table (referencing table)
	@DetailField	VARCHAR(256)	--	Name of field in detail table where constraint references from
	) RETURNS VARCHAR(256)
AS
BEGIN
	DECLARE
		@ConstraintName	VARCHAR(256)

	SELECT  @ConstraintName	= RC.CONSTRAINT_NAME
	  FROM  INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE	CCU
	  JOIN	INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS  RC
		ON	RC.CONSTRAINT_NAME		= CCU.CONSTRAINT_NAME
	  JOIN  INFORMATION_SCHEMA.KEY_COLUMN_USAGE			KCU
		ON	KCU.CONSTRAINT_NAME				= RC.UNIQUE_CONSTRAINT_NAME
	 WHERE  CCU.COLUMN_NAME					= @DetailField
	   AND  CCU.TABLE_SCHEMA				= 'DBO'
	   AND  CCU.TABLE_NAME					= @DetailTable
	   AND  CCU.CONSTRAINT_CATALOG			= DB_NAME()
	   AND	RC.CONSTRAINT_CATALOG			= DB_NAME()
	   AND  RC.UNIQUE_CONSTRAINT_SCHEMA		= 'DBO'
	   AND	KCU.CONSTRAINT_CATALOG			= DB_NAME()
	   AND  KCU.CONSTRAINT_SCHEMA			= 'DBO'
	   AND  KCU.TABLE_SCHEMA				= 'DBO'
	   AND	KCU.TABLE_CATALOG				= DB_NAME()
	   AND  KCU.TABLE_NAME					= @MasterTable
	   AND  KCU.COLUMN_NAME					= @MasterField

	IF  @@ROWCOUNT = 0
		SET	@ConstraintName	= NULL

	RETURN	@ConstraintName
END

GO
/****** Object:  UserDefinedFunction [dbo].[dch_fTableExists]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------
--	Tables/columns management procedures and functions
--------------------------------------------------------------------------------
--	Function returns 1 if table exists, and 0 if doesn't
CREATE FUNCTION [dbo].[dch_fTableExists](
	@TableName		VARCHAR(256)
	) RETURNS INT
AS
BEGIN
	IF	EXISTS(
		SELECT	1
		  FROM	INFORMATION_SCHEMA.TABLES
		 WHERE	TABLE_SCHEMA		= 'dbo'
		   AND	TABLE_TYPE			= 'BASE TABLE'
		   AND	TABLE_NAME			= @TableName
		)
		RETURN 1

	RETURN 0
END

GO
/****** Object:  UserDefinedFunction [dbo].[FASSESSMENTPRODUCTGROUPS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FASSESSMENTPRODUCTGROUPS] (@ASSESSMENTID BIGINT)
RETURNS NVARCHAR(4000)
AS
BEGIN
	RETURN ISNULL(SUBSTRING((SELECT ', ' + ISNULL(X.PRODUCTGROUPCODE, '') + ISNULL(' - ' + X.PRODUCTGROUP, '') 
    FROM TPRODUCTGROUP X INNER JOIN TPROD_GROUP_IN_ASSESSMENT Y ON Y.PRODUCTGROUPID = X.PRODUCTGROUPID
    WHERE Y.ASSESSMENTID = @ASSESSMENTID
    FOR XML PATH, TYPE).value('.[1]', 'nvarchar(max)'), 3, 4000), '')
END

GO
/****** Object:  UserDefinedFunction [dbo].[FCONTRACTPRODUCTGROUPS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FCONTRACTPRODUCTGROUPS] (@CONID BIGINT)
RETURNS NVARCHAR(4000)
AS
BEGIN
	RETURN ISNULL(SUBSTRING((SELECT ',' + ISNULL(X.PRODUCTGROUPCODE, '') + ISNULL(' - ' + X.PRODUCTGROUP, '') 
    FROM TPRODUCTGROUP X INNER JOIN TPROD_GROUP_IN_CONTRACT Y ON Y.PRODUCTGROUPID = X.PRODUCTGROUPID
    WHERE Y.CONTRACTID = @CONID
    FOR XML PATH, TYPE).value('.[1]', 'nvarchar(max)'), 2, 4000), '')
END

GO
/****** Object:  UserDefinedFunction [dbo].[FDEPARTMENTINOBJECTTYPEROLE]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FDEPARTMENTINOBJECTTYPEROLE] (@ROLEFIXED NVARCHAR(50), @OBJTYPEFIXED NVARCHAR(50), @OBJID BIGINT)
RETURNS NVARCHAR(4000)
AS
BEGIN
	RETURN ISNULL(SUBSTRING((SELECT ', ' + ISNULL(D.DEPARTMENT, '') 
	FROM TDEPARTMENTROLE_IN_OBJECT DIO
        INNER JOIN 	TDEPARTMENT D ON (DIO.DEPARTMENTID = D.DEPARTMENTID)
	INNER JOIN  TOBJECTTYPE O ON (DIO.OBJECTTYPEID = O.OBJECTTYPEID)
	INNER JOIN  TROLE R ON (DIO.ROLEID = R.ROLEID)
	WHERE
	DIO.OBJECTID = @OBJID
	AND O.FIXED = @OBJTYPEFIXED
	AND R.FIXED = @ROLEFIXED
	ORDER BY
	DIO.ROLEID ASC, 
	D.DEPARTMENT ASC 
	FOR XML PATH, TYPE).value('.[1]', 'nvarchar(max)'), 2, 4000), '')  
END


GO
/****** Object:  UserDefinedFunction [dbo].[FDEPARTMENTSWITHOBJECTROLES]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FDEPARTMENTSWITHOBJECTROLES] (@OBJTYPEFIXED NVARCHAR(50), @OBJID BIGINT)
RETURNS NVARCHAR(4000)
AS
BEGIN
	RETURN ISNULL(SUBSTRING((SELECT '|' + ISNULL(D.DEPARTMENT, '') 
	FROM TDEPARTMENTROLE_IN_OBJECT DIO
        INNER JOIN 	TDEPARTMENT D ON (DIO.DEPARTMENTID = D.DEPARTMENTID)
	INNER JOIN  TOBJECTTYPE O ON (DIO.OBJECTTYPEID = O.OBJECTTYPEID)
	WHERE
	DIO.OBJECTID = @OBJID
	AND O.FIXED = @OBJTYPEFIXED
	ORDER BY
	DIO.ROLEID ASC, 
	D.DEPARTMENT ASC 
	FOR XML PATH, TYPE).value('.[1]', 'nvarchar(max)'), 2, 4000), '')  
END

GO
/****** Object:  UserDefinedFunction [dbo].[FN_GET_NETBIOSNAME_FROM_DNSNAME]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FN_GET_NETBIOSNAME_FROM_DNSNAME] (@DOMAINUSERNAME NVARCHAR(1024)) 
RETURNS NVARCHAR(1024) 
AS BEGIN
			--1.DNSDOMAINMAPPING SYSTEM SETTING PARSER. RESULT IN @RESULT_TABLE TABLE VARIABLE IN FORM (DNSNAME,NETBIOSNAME)
			DECLARE @RESULT_TABLE TABLE (DNSNAME NVARCHAR(1024), NETBIOSNAME NVARCHAR(1024))
			DECLARE @ORIGINAL_STRING NVARCHAR(1024)
			DECLARE @WORKING_STRING  NVARCHAR(1024)
			DECLARE @DNSNAME NVARCHAR(1024)
			DECLARE @NETBIOSNAME NVARCHAR(1024)
			DECLARE @RESULT  NVARCHAR(1024)
			SELECT @ORIGINAL_STRING = ISNULL(SETTINGVALUE,'') FROM  DBO.TPROFILESETTING
			WHERE PROFILEKEYID IN (SELECT PROFILEKEYID FROM DBO.TPROFILEKEY WHERE FIXED='DNSDOMAINMAPPING')
			--CHECK IF RETRIEVED <DNS AND NETBIOS DOMAIN MAPPING> SETTING IS CORRECT
			IF  LEN(@ORIGINAL_STRING)= 0  GOTO GETNETBIOSNAME
			IF  CHARINDEX('=' ,@ORIGINAL_STRING) =0 GOTO GETNETBIOSNAME
			SET @ORIGINAL_STRING= @ORIGINAL_STRING + ','
			WHILE  CHARINDEX(',' ,@ORIGINAL_STRING) > 1
			BEGIN
				SET @WORKING_STRING = LEFT(@ORIGINAL_STRING,CHARINDEX(',',@ORIGINAL_STRING)-1)
				SET @DNSNAME = LEFT(@WORKING_STRING,CHARINDEX('=',@WORKING_STRING)-1)
				SET @NETBIOSNAME = REVERSE(LEFT(REVERSE(@WORKING_STRING),CHARINDEX('=',REVERSE(@WORKING_STRING))-1))
				INSERT @RESULT_TABLE VALUES (@DNSNAME,@NETBIOSNAME)
				SET @ORIGINAL_STRING = REPLACE(@ORIGINAL_STRING,LEFT(@ORIGINAL_STRING,CHARINDEX(',',@ORIGINAL_STRING)),'')
			END
			--2.GET NETBIOSNAME CALCULATED FROM @DOMAINUSERNAME 
			GETNETBIOSNAME:
			DECLARE @USERNAME NVARCHAR(1024)
			DECLARE @USERDOMAIN NVARCHAR(1024)
			IF CHARINDEX('@',@DOMAINUSERNAME) IN (0,1) OR CHARINDEX('@',REVERSE(@DOMAINUSERNAME))IN (0,1) OR @DOMAINUSERNAME IS NULL RETURN ''
			SET @USERNAME=LEFT(@DOMAINUSERNAME,CHARINDEX('@',@DOMAINUSERNAME)-1)
			SELECT @USERDOMAIN=NETBIOSNAME FROM @RESULT_TABLE
			WHERE DNSNAME = REVERSE(LEFT(REVERSE(@DOMAINUSERNAME),CHARINDEX('@',REVERSE(@DOMAINUSERNAME))-1))   
			IF @USERDOMAIN IS NULL OR @USERDOMAIN = ''
			SET @RESULT= LEFT((REVERSE(LEFT(REVERSE(@DOMAINUSERNAME+'.'),CHARINDEX('@',REVERSE(@DOMAINUSERNAME+'.'))-1))),CHARINDEX('.',(REVERSE(LEFT(REVERSE(@DOMAINUSERNAME+'.'),CHARINDEX('@',REVERSE(@DOMAINUSERNAME+'.'))-1))))-1)+'\'+@USERNAME 
			ELSE SET @RESULT=@USERDOMAIN+'\'+@USERNAME
			RETURN @RESULT
	END
GO
/****** Object:  UserDefinedFunction [dbo].[FN_IsPersonRole]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FN_IsPersonRole](@RoleInObjectTypeID	BIGINT)
RETURNS BIT
AS
BEGIN
	RETURN	(
	   SELECT	R.ISPERSONROLE
		 FROM	dbo.TROLE	R
		 INNER JOIN dbo.TROLE_IN_OBJECTTYPE rio on rio.ROLEID = R.ROLEID
		 WHERE rio.ROLE_IN_OBJECTTYPEID = @RoleInObjectTypeID
			   AND	R.MIK_VALID		= 1			
			)
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnFirsties]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnFirsties] ( @str NVARCHAR(4000) )
RETURNS NVARCHAR(4000)
AS
BEGIN
    DECLARE @retval NVARCHAR(4000);
    SET @str=RTRIM(LTRIM(@str));
    SET @retval=LEFT(@str,1);
    WHILE CHARINDEX(' ',@str,1)>0 BEGIN
        SET @str=LTRIM(RIGHT(@str,LEN(@str)-CHARINDEX(' ',@str,1)));
        SET @retval+=LEFT(@str,1);
    END
    RETURN @retval;
END
GO
/****** Object:  UserDefinedFunction [dbo].[FPERSONINOBJECTTYPEROLE]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FPERSONINOBJECTTYPEROLE] (@ROLEFIXED NVARCHAR(50), @OBJTYPEFIXED NVARCHAR(50), @OBJID BIGINT)
RETURNS NVARCHAR(4000)
AS
BEGIN
	RETURN ISNULL(SUBSTRING((SELECT ', ' + ISNULL(P.FIRSTNAME, '') + ' ' + ISNULL(P.LASTNAME, '')  
	FROM TPERSONROLE_IN_OBJECT PIO
	INNER JOIN 	TPERSON P ON PIO.PERSONID = P.PERSONID
	INNER JOIN 	TOBJECTTYPE O ON PIO.OBJECTTYPEID = O.OBJECTTYPEID
	INNER JOIN  TROLE R ON PIO.ROLEID = R.ROLEID
	WHERE
	PIO.OBJECTID = @OBJID AND
	O.FIXED = @OBJTYPEFIXED AND
	R.FIXED = @ROLEFIXED
	ORDER BY
	PIO.ROLEID ASC,
	P.DISPLAYNAME ASC 	
	FOR XML PATH, TYPE).value('.[1]', 'nvarchar(max)'), 2, 4000), '')  
END


GO
/****** Object:  UserDefinedFunction [dbo].[FPERSONSWITHOBJECTROLES]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FPERSONSWITHOBJECTROLES] (@OBJTYPEFIXED NVARCHAR(50), @OBJID BIGINT)
RETURNS NVARCHAR(4000)
AS
BEGIN
	RETURN ISNULL(SUBSTRING((SELECT '|' + ISNULL(P.DISPLAYNAME, '') 
	FROM TPERSONROLE_IN_OBJECT PIO
	INNER JOIN 	TPERSON P ON PIO.PERSONID = P.PERSONID
	INNER JOIN 	TOBJECTTYPE O ON PIO.OBJECTTYPEID = O.OBJECTTYPEID
	WHERE
	PIO.OBJECTID = @OBJID AND
	O.FIXED = @OBJTYPEFIXED
	ORDER BY
	PIO.ROLEID ASC,
	P.DISPLAYNAME ASC 	
	FOR XML PATH, TYPE).value('.[1]', 'nvarchar(max)'), 2, 4000), '')  
END

GO
/****** Object:  UserDefinedFunction [dbo].[FRFXPRODUCTGROUPS]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FRFXPRODUCTGROUPS] (@RFXID BIGINT)
RETURNS NVARCHAR(4000)
AS
BEGIN
	RETURN ISNULL(SUBSTRING((SELECT ', ' + ISNULL(X.PRODUCTGROUPCODE, '') + ISNULL(' - ' + X.PRODUCTGROUP, '') 
    FROM TPRODUCTGROUP X INNER JOIN TPROD_GROUP_IN_RFX Y ON Y.PRODUCTGROUPID = X.PRODUCTGROUPID
    WHERE Y.RFXID = @RFXID
    FOR XML PATH, TYPE).value('.[1]', 'nvarchar(max)'), 3, 4000), '')
END

GO
/****** Object:  UserDefinedFunction [dbo].[GET_ACL_PRIVILEGES]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GET_ACL_PRIVILEGES]( @OBJECTTYPEID BIGINT, @OBJECTID BIGINT, @USERID BIGINT, @PRIVILEGEID BIGINT)
	RETURNS BIT
BEGIN
	DECLARE @R BIT
	DECLARE @CreatePrivilegeId BIGINT
	SET @CreatePrivilegeId = 3

	;WITH 
	RCR_ACL(LVL, ACLID, USERID, GROUPID,
		  INITIAL_OBJECT_TYPE_ID, INITIAL_OBJECT_ID, 
		  OBJECTTYPEID, OBJECTID, 
		  PARENTOBJECTTYPEID, PARENTOBJECTID, 
		  OWNER_OBJECTTYPEID, OWNER_OBJECTID,
		  PRIVILEGEID, NONHERITABLE, INHERITFROMPARENTOBJECT) AS
	(
	SELECT 0 AS LVL, A.ACLID, A.USERID, A.GROUPID
	  ,A.OBJECTTYPEID, A.OBJECTID
	  ,A.OBJECTTYPEID, A.OBJECTID
	  ,A.PARENTOBJECTTYPEID, A.PARENTOBJECTID
	  ,A.OBJECTTYPEID, A.OBJECTID
	  ,A.PRIVILEGEID, A.NONHERITABLE, A.INHERITFROMPARENTOBJECT
	FROM TACL A 
	 WHERE A.OBJECTID=@OBJECTID AND A.OBJECTTYPEID=@OBJECTTYPEID

	UNION ALL 
	 
	SELECT CHILD.LVL+1 AS LVL, A.ACLID, A.USERID, A.GROUPID
	  ,CHILD.INITIAL_OBJECT_TYPE_ID, CHILD.INITIAL_OBJECT_ID
	  ,A.OBJECTTYPEID, A.OBJECTID
	  ,A.PARENTOBJECTTYPEID, A.PARENTOBJECTID
	  ,CHILD.PARENTOBJECTTYPEID, CHILD.PARENTOBJECTID
	  ,A.PRIVILEGEID, A.NONHERITABLE, A.INHERITFROMPARENTOBJECT
	FROM RCR_ACL as CHILD
	JOIN TACL A ON CHILD.PRIVILEGEID=@CreatePrivilegeId and
		CHILD.PARENTOBJECTID=A.OBJECTID AND CHILD.PARENTOBJECTTYPEID=A.OBJECTTYPEID
		
	WHERE ISNULL(CHILD.INHERITFROMPARENTOBJECT,0)=1 
	)
	
	SELECT TOP 1 @R = 1
	FROM RCR_ACL A 
	WHERE  A.INITIAL_OBJECT_ID=@OBJECTID AND A.INITIAL_OBJECT_TYPE_ID=@OBJECTTYPEID 
		AND PRIVILEGEID=@PRIVILEGEID
		AND (LVL=0 OR (LVL>0 and A.NONHERITABLE<>1))
		AND(A.USERID=@USERID OR A.GROUPID IN ( SELECT UUG.USERGROUPID FROM TUSER_IN_USERGROUP UUG WHERE UUG.USERID=@USERID))

		
	RETURN ISNULL(@R, 0)
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetDocumentParentObjects]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetDocumentParentObjects]
(
	@DocumentId bigint, 
	@UserId bigint,
	@TopLevelOnly bit
)
RETURNS @TABLE TABLE (
	ObjectFixed varchar(20) NOT NULL, 
	ObjectId bigint NOT NULL,
	ParentId bigint,
	ParentFixed varchar(20),
	HasAccess bit)
AS
BEGIN

	DECLARE @Result TABLE( 
	ObjectFixed varchar(20) NOT NULL, 
	ObjectId bigint NOT NULL,
	ParentId bigint,
	ParentFixed varchar(20),
	HasAccess bit
	);

	declare @DocumentTypeId bigint
	declare @ObjectTypeId bigint
	declare @ObjectId bigint
	declare @ObjectTypeFixed varchar(20)
	declare @ParentObjectAccess bit

	select @DocumentTypeId=d.DOCUMENTTYPEID
	, @ObjectTypeId=d.OBJECTTYPEID
	, @ObjectId=d.OBJECTID  
	from TDOCUMENT d WHERE d.DOCUMENTID=@DocumentId;

	select @ObjectTypeFixed= t.FIXED from TOBJECTTYPE t WHERE t.OBJECTTYPEID=@ObjectTypeId;

	IF ISNULL(@ObjectTypeFixed, '') != ''
	BEGIN
		IF @ObjectTypeFixed != 'PROJECT'
		BEGIN
			with cte(DOCUMENTTYPEID, ParentID)
			as
			(
				select dt.DOCUMENTTYPEID, dt.ParentID
				FROM TDOCUMENTTYPE dt
				where dt.DOCUMENTTYPEID=@DocumentTypeId
				UNION ALL
				select c.DOCUMENTTYPEID, c.ParentID
				FROM cte
				INNER JOIN TDOCUMENTTYPE c ON c.DOCUMENTTYPEID=cte.ParentID
			)
			INSERT INTO @Result
			select 'DOCUMENTTYPE' as ObjectFixed, DOCUMENTTYPEID as ObjectId, ISNULL(ParentID, @ObjectId) as ParentId, CASE WHEN ParentID IS NULL THEN @ObjectTypeFixed ELSE 'DOCUMENTTYPE' END as ParentFixed, NULL as HasAccess
			from cte
			UNION ALL
			select 'VOR' as ObjectFixed, vor.VORID as ObjectId, ISNULL(vor.VOID, vor.CONTRACTID) as ParentId, CASE WHEN VOID IS NULL THEN 'CONTRACT' ELSE 'VO' END as ParentFixed, NULL as HasAccess
			from TVOR vor
			where @ObjectTypeFixed = 'VOR' and vor.VORID = @ObjectId 
			UNION ALL
			select 'VO' as ObjectFixed, vo.VOID as ObjectId, vo.CONTRACTID as ParentId, 'CONTRACT' as ParentFixed, dbo.GET_ACL_PRIVILEGES((select tt.OBJECTTYPEID from TOBJECTTYPE tt where tt.FIXED = 'VO'), vo.VOID, @UserId, 1) as HasAccess
			from TVO vo
			where @ObjectTypeFixed = 'VO' and vo.VOID = @ObjectId
			UNION ALL
			select 'OPTION' as ObjectFixed, oe.OPTIONID as ObjectId, oe.CONTRACTID as ParentId, 'CONTRACT' as ParentFixed, NULL as HasAccess
			from TOPTION oe
			where @ObjectTypeFixed = 'OPTION' and oe.OPTIONID = @ObjectId
			UNION ALL
			select 'ORDER' as ObjectFixed, o.ORDERID as ObjectId, o.CONTRACTID as ParentId, 'CONTRACT' as ParentFixed, NULL as HasAccess
			from TORDER o
			where @ObjectTypeFixed = 'ORDER' and o.ORDERID = @ObjectId
			UNION ALL
			select 'RPROCESS' as ObjectFixed, rp.RPROCESSID as ObjectId, rp.CONTRACTID as ParentId, 'CONTRACT' as ParentFixed, dbo.GET_ACL_PRIVILEGES((select tt.OBJECTTYPEID from TOBJECTTYPE tt where tt.FIXED = 'RPROCESS'), rp.RPROCESSID, @UserId, 1) as HasAccess
			from TRPROCESS rp
			where @ObjectTypeFixed = 'RPROCESS' and rp.RPROCESSID = @ObjectId
			UNION ALL
			select 'AMENDMENT' as ObjectFixed, a.AMENDMENTID as ObjectId, a.CONTRACTID as ParentId, 'CONTRACT' as ParentFixed, dbo.GET_ACL_PRIVILEGES((select tt.OBJECTTYPEID from TOBJECTTYPE tt where tt.FIXED = 'AMENDMENT'), a.AMENDMENTID, @UserId, 1) as HasAccess
			from TAMENDMENT a
			where @ObjectTypeFixed = 'AMENDMENT' and a.AMENDMENTID = @ObjectId
			UNION ALL
			select 'TENDERER' as ObjectFixed, t.TENDERERID as ObjectId, ISNULL(t.RFXID, t.CONTRACTID) as ParentId, CASE WHEN t.RFXID IS NULL THEN 'CONTRACT' ELSE 'RFX' END as ParentFixed, NULL as HasAccess
			from TTENDERER t
			where @ObjectTypeFixed = 'TENDERER' and t.TENDERERID = @ObjectId
			UNION ALL
			select 'RFX' as ObjectFixed, r.RFXID as ObjectId, r.CONTRACTID as ParentId, 'CONTRACT' as ParentFixed, dbo.GET_ACL_PRIVILEGES((select tt.OBJECTTYPEID from TOBJECTTYPE tt where tt.FIXED = 'RFX'), r.RFXID, @UserId, 1) as HasAccess
			from TRFX r
			where @ObjectTypeFixed = 'RFX' and r.RFXID = @ObjectId
			UNION ALL
			select 'CONTRACT' as ObjectFixed, @ObjectId as ObjectId, NULL as ParentId, NULL as ParentFixed, dbo.GET_ACL_PRIVILEGES((select tt.OBJECTTYPEID from TOBJECTTYPE tt where tt.FIXED = 'CONTRACT'), @ObjectId, @UserId, 1) as HasAccess
			where @ObjectTypeFixed = 'CONTRACT'

			INSERT INTO @Result
			select 'VO' as ObjectFixed, vo.VOID as ObjectId, vo.CONTRACTID as ParentId, 'CONTRACT' as ParentFixed, NULL as HasAccess
			from TVO vo
			where vo.VOID in
			(
				select ParentId
				from @Result
				where ParentFixed = 'VO'
			)

			INSERT INTO @Result
			select 'TENDERER' as ObjectFixed, t.TENDERERID as ObjectId, ISNULL(t.RFXID, t.CONTRACTID) as ParentId, 'CONTRACT' as ParentFixed, NULL as HasAccess
			from TTENDERER t
			where @ObjectTypeFixed = 'TENDERER' and t.TENDERERID = @ObjectId
			and t.ISAWARDED = 1 and not exists
			(
				select 1
				from @Result
				where ObjectFixed = 'TENDERER' and ObjectId = t.TENDERERID
			)

			INSERT INTO @Result
			select 'RFX' as ObjectFixed, r.RFXID as ObjectId, r.CONTRACTID as ParentId, 'CONTRACT' as ParentFixed, dbo.GET_ACL_PRIVILEGES((select tt.OBJECTTYPEID from TOBJECTTYPE tt where tt.FIXED = 'RFX'), r.RFXID, @UserId, 1) as HasAccess
			from TRFX r
			where r.RFXID in
			(
				select ParentId
				from @Result
				where ParentFixed = 'RFX'
			)
			and not exists
			(
				select 1
				from @Result
				where ObjectFixed = 'RFX' and ObjectId = r.RFXID
			)

			INSERT INTO @Result
			select 'CONTRACT' as ObjectFixed, c.CONTRACTID as ObjectId, NULL as ParentId, NULL as ParentFixed, dbo.GET_ACL_PRIVILEGES((select tt.OBJECTTYPEID from TOBJECTTYPE tt where tt.FIXED = 'CONTRACT'), c.CONTRACTID, @UserId, 1) as HasAccess
			from TCONTRACT c
			where c.CONTRACTID in
			( 
				select ParentId
				from @Result
				where ParentFixed = 'CONTRACT'
			)
			and not exists
			(
				select 1
				from @Result
				where ObjectFixed = 'CONTRACT' and ObjectId = c.CONTRACTID
			)
						
			UPDATE c
			set HasAccess = p.HasAccess
			from @Result c
			inner join @Result p
			on c.ParentId = p.ObjectId and c.ParentFixed = p.ObjectFixed
			where c.HasAccess is null
			and ((c.ObjectFixed in ('TENDERER', 'VO', 'AMENDMENT', 'ORDER', 'OPTION'))
			or (c.ObjectFixed = 'VOR' and c.ParentFixed != 'VO'))

			UPDATE c
			set HasAccess = p.HasAccess
			from @Result c
			inner join @Result p
			on c.ParentId = p.ObjectId and c.ParentFixed = p.ObjectFixed
			where c.HasAccess is null
			and (c.ObjectFixed = 'VOR' and c.ParentFixed = 'VO')

			select @ParentObjectAccess = HasAccess
			from @Result
			where ObjectFixed = @ObjectTypeFixed

			UPDATE @Result
			set HasAccess = @ParentObjectAccess
			where HasAccess is null
			and ObjectFixed = 'DOCUMENTTYPE'

		END

		ELSE --IF @ObjectTypeFixed = 'PROJECT'
		BEGIN		
			with cte(DOCUMENTTYPEID, ParentID)
			as
			(
				select dt.DOCUMENTTYPEID, dt.ParentID
				FROM TDOCUMENTTYPE dt
				where dt.DOCUMENTTYPEID=@DocumentTypeId
				UNION ALL
				select c.DOCUMENTTYPEID, c.ParentID
				FROM cte
				INNER JOIN TDOCUMENTTYPE c ON c.DOCUMENTTYPEID=cte.ParentID
			)
			INSERT INTO @Result
			select 'DOCUMENTTYPE' as ObjectFixed, DOCUMENTTYPEID as ObjectId, ISNULL(ParentID, @ObjectId) as ParentId, CASE WHEN ParentID IS NULL THEN @ObjectTypeFixed ELSE 'DOCUMENTTYPE' END as ParentFixed, dbo.GET_ACL_PRIVILEGES(@ObjectTypeId, @ObjectId, @UserId, 1) as HasAccess
			from cte
			UNION ALL
			select 'PROJECT' as ObjectFixed, @ObjectId as ObjectId, NULL as ParentId, NULL as ParentFixed, dbo.GET_ACL_PRIVILEGES((select tt.OBJECTTYPEID from TOBJECTTYPE tt where tt.FIXED = 'PROJECT'), @ObjectId, @UserId, 1) as HasAccess

		END
	END	
	
	declare @HasAccess bit
	select @HasAccess =  ~CONVERT(bit, Count(1)) from @Result where ISNULL(HasAccess,0) = 0

	INSERT INTO @TABLE
	select ObjectFixed, ObjectId, NULL, NULL, @HasAccess from @Result
	where @TopLevelOnly = 1 and ParentId is null
	UNION ALL
	select ObjectFixed, ObjectId, ParentId, ParentFixed, HasAccess from @Result
	where @TopLevelOnly = 0

	RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[ModifySetting]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ModifySetting](@init_str nvarchar(200), @pref nvarchar(50), @suff nvarchar(20))
RETURNS varchar(200)
AS
BEGIN
declare @return nvarchar(200)
declare @prefix_len int
declare @suffix_len int
declare @str_len int

set @str_len = LEN(@init_str)
set @prefix_len = LEN(@pref) + 1
set @suffix_len = LEN(@suff)
set @return = @init_str

IF (@prefix_len + 2 < @str_len and @suffix_len < @prefix_len and @suffix_len + @prefix_len < @str_len)
BEGIN
set @return =	UPPER(SUBSTRING(@init_str, @prefix_len + 1, 1)) + 
				SUBSTRING(@init_str, @prefix_len + 2, @str_len - @prefix_len) + 
				' - ' + SUBSTRING(@init_str, 0, @prefix_len - @suffix_len)
END

return @return

END

GO
/****** Object:  UserDefinedFunction [dbo].[SVF_GetContractAwardedCompanyNames]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[SVF_GetContractAwardedCompanyNames](@ContractID BIGINT)
RETURNS NVARCHAR(255)
AS
BEGIN
   DECLARE @companyNames nvarchar(255);
   SELECT @companyNames=AwardedCompanyNames from [DBO].[TVF_GetContractAwardedCompanyNames](@ContractID)
   RETURN @companyNames
END
GO
/****** Object:  UserDefinedFunction [dbo].[Takeda_CompanyOrIndividual]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[Takeda_CompanyOrIndividual](@Temp VarChar(255))
/* call Select dbo.Takeda_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
Returns VarChar(250)

AS

Begin

	DECLARE @result varchar(255)

	BEGIN
	
	SET @Temp = UPPER(@Temp)

	SET @result = (CASE 
				WHEN @Temp like '% GMBH%' 
					OR @Temp like '%[^A-Z]LTD%' 
					/*OR @Temp like '%[^A-Z]LTD'*/
					OR @Temp like '%[^A-Z]LIMITED%'
					OR @Temp like '%[^A-Z]LDA%' /* Logista Transportes, Lda */
			
					OR @Temp like '%CORPORATION%'
					OR @Temp like '%INCORPORATED%'
					OR @Temp like '%GESELLSCHAFT%'
					OR @Temp like '%[^A-Z]GROUP%'

					OR @Temp like '%[^A-Z]AG' /* Lundberg, Agneta */
					OR @Temp like '%[^A-Z]AG[^A-Z]%' /* Lundberg, Agneta */

					OR @Temp like '%[^A-Z]AS'
					OR @Temp like '%[^A-Z]AB' /* Kronans Droghandel Apotek AB */
					OR @Temp like '%[^A-Z]A/S%'
					OR @Temp like '%[^A-Z]APS'

					OR @Temp like '%[^A-Z]INC'
					OR @Temp like '%[^A-Z]INC[^A-Z]%'


					OR @Temp like '%[^A-Z]S.A.' /* Gruenenthal Pharma, S.A. */
					OR @Temp like '%[^A-Z]SA' /* Gruenenthal Pharma, S.A. */
					OR @Temp like '%[^A-Z]SA[^A-Z]%' /* Gruenenthal Pharma, S.A. */

					OR @Temp like '%[^A-Z]SAU' /* Cafosa Gum, SAU */
					OR @Temp like '%[^A-Z]UAB' /*Nemuno Vaistinė, UAB */
					OR @Temp like '%[^A-Z]UAB[^A-Z]%' /*Konica Minolta Baltia Eesti filiaal, UAB */

					OR @Temp like '%[^A-Z]S.L.' /* Elmuquimica Farmaceutica, S.L. */
					OR @Temp like '%[^A-Z]S.L' /* Pharmaphenix, S.L */
					OR @Temp like '%[^A-Z]C.V.' /* Laboratorios Euroceltic, S.A. de C.V. */			
					OR @Temp like '%[^A-Z]S.C.' /* Galaz, Yamazaki , Ruiz Urquiza S.C  */	
					OR @Temp like '%[^A-Z]S.C' /* Galaz, Yamazaki , Ruiz Urquiza S.C  */		
					OR @Temp like '%[^A-Z]D.O.%' /* AMATIS, svetovanje in izvedba konferenc, d.o.o.*/					
						
					OR @Temp like '%[^A-Z]S.R.O%' /* G-Data servis, spol. s r.o. */				
					/*OR @Temp like '%[^A-Z]LLC' /* PharmaCircle, LLC */	*/
					OR @Temp like '%[^A-Z]LLC%' /* CUREnCARE Research, LLC (Moon, Hanlim) */	
					
	
					OR @Temp like '%[^A-Z]EG' /*Niederrhein Netzwerk eG (Moenchengladbach, Germany) */				
					OR @Temp like '%[^A-Z]EG[^A-Z]%' /*Niederrhein Netzwerk eG (Moenchengladbach, Germany) */				
					OR @Temp like '%[^A-Z]AG[^A-Z]%' /* HEITEC AG (Crailsheim) (Beck, Walter) */	
						
					OR @Temp like '%SA%dE%C%V%' /* Carnot Productor Cientificos, SA de CV */	
					OR @Temp like '%[^A-Z]E.V%' /*  e.V. */	

					OR @Temp like '%SERVICES%'
					OR @Temp like '%CENTRE%'
					OR @Temp like '%CENTER%'
																		
					OR @Temp like '%KLINIK%' 
					OR @Temp like '%AP%OTHEK%' 
					OR @Temp like '%[^A-Z]APTEEKKI[^A-Z]%' 
					OR @Temp like '%KRANKENHAUS%' 
					OR @Temp like '%UNIVERSIT%' 

					OR @Temp like '%INSTITUT%' 
					/* OR @Temp like '%[^A-Z]INSTITUTE[^A-Z]%' */

					OR @Temp like '%WHOLESAL%' /*  Wholesalers */	
					OR @Temp like '%ASSOCIA%ION%' /*  Wholesalers */	
					OR @Temp like '%UNTERNEHME%' /*  Wholesalers */		
					OR @Temp like '%CONSULT%' /*  Wholesalers */		
												
					OR @Temp like '%PHARMACEUTICAL%' /*  e.V. */		
					OR @Temp like '%AGENTUR%' /* 2strom, Die Healthcare Agentur */
					OR @Temp like '%SOCIEDAD%' /* Blend Hr , Sociedad de hecho de Maximiliano Ratosnik y Astrid Wernli */				
					OR @Temp like '%HOSPITAL%' /* Blend Hr , Sociedad de hecho de Maximiliano Ratosnik y Astrid Wernli */				
						
					/*OR @Temp like '% INC' /* Lundberg, Agneta */*/
					THEN 'C'
				WHEN LEN(@Temp) < 7 THEN 'C' /*individuals have at least first last name and title */
				WHEN @Temp like '%[^A-Z]DR[^A-Z]%'
					OR  @Temp like 'DR[^A-Z]%'

					OR  @Temp like '%[^A-Z]PROF[^A-Z]%'
					OR  @Temp like 'PROF[^A-Z]%'

					OR  @Temp like '%[^A-Z]MR[^A-Z]%'
					OR  @Temp like 'MR[^A-Z]%'
					THEN 'I' 
				WHEN	LEN(replace(dbo.Takeda_RemoveNonAlphaNonNumNonSpace(@Temp),'  ',' '))
					- LEN(dbo.Takeda_RemoveNonAlphaNonNumericCharacters(@Temp)) = 1 /* one space, first and last name? */
					THEN 'I'
				WHEN @Temp not like '%,%' THEN 'C' /* Individuals should have a comma in the name for Last, First */
				WHEN @Temp like '%[A-Z], [A-Z]%' /* Smith, Joe */ THEN 'I'/* T for test */
				ELSE 'U' END)

	END

    Return @result

End

GO
/****** Object:  UserDefinedFunction [dbo].[Takeda_CountQuestionMarkCharChineseEtc_Varchar255]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[Takeda_CountQuestionMarkCharChineseEtc_Varchar255](@Temp VarChar(255))
/* call Select dbo.Takeda_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
Returns int

AS

Begin

    Declare @SpecialCharCount as int
	set @SpecialCharCount = 0

	if(DATALENGTH(@Temp) - 
       DATALENGTH(REPLACE(@Temp,char(63) /* ? undefined */,'')) > 0)
		BEGIN
		set  @SpecialCharCount = DATALENGTH(@Temp) - 
			DATALENGTH(REPLACE(@Temp,char(63),''))
			goto lblEnd
		END

	if(DATALENGTH(@Temp) - 
       DATALENGTH(REPLACE(@Temp,char(165) /* ¥ */,'')) > 0)
		BEGIN
		set  @SpecialCharCount = DATALENGTH(@Temp) - 
			DATALENGTH(REPLACE(@Temp,char(165),''))
			goto lblEnd
		END

	if(DATALENGTH(@Temp) - 
       DATALENGTH(REPLACE(@Temp,char(128) /* € */,'')) > 0)
		BEGIN
		set  @SpecialCharCount = DATALENGTH(@Temp) - 
			DATALENGTH(REPLACE(@Temp,char(128),''))
			goto lblEnd
		END

lblEnd:
    Return  @SpecialCharCount

/*
167 
§


 166 
¦

*/


End

/* select [dbo].[Takeda_CountQuestionMarkCharChineseEtc_Varchar255] ('Колоркон Лимитед test') as idx
 from TCONTRACTRELATION

exec [dbo].[Takeda_CountQuestionMarkCharChineseEtc_Varchar255] 'test' */
GO
/****** Object:  UserDefinedFunction [dbo].[Takeda_fn_TitleCase]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Takeda_fn_TitleCase]
(@Value varchar(8000), @Exceptions varchar(8000),@UCASEWordLength tinyint)
returns varchar(8000)
as
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Function Purpose: To convert text to Proper Case.
Created By:             David Wiseman
Website:                http://www.wisesoft.co.uk
Created:                2005-10-03
Updated:                2006-06-22
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
INPUTS:

@Value :                This is the text to be converted to Proper Case
@Exceptions:            A list of exceptions to the default Proper Case rules. e.g. |RAM|CPU|HDD|TFT|
                              Without exception list they would display as Ram, Cpu, Hdd and Tft
                              Note the use of the Pipe "|" symbol to separate exceptions.
                              (You can change the @sep variable to something else if you prefer)
@UCASEWordLength: You can specify that words less than a certain length are automatically displayed in UPPERCASE

USAGE1:

Convert text to ProperCase, without any exceptions

select dbo.fProperCase('THIS FUNCTION WAS CREATED BY DAVID WISEMAN',null,null)
>> This Function Was Created By David Wiseman

USAGE2:

Convert text to Proper Case, with exception for WiseSoft

select dbo.fProperCase('THIS FUNCTION WAS CREATED BY DAVID WISEMAN @ WISESOFT','|WiseSoft|',null)
>> This Function Was Created By David Wiseman @ WiseSoft

USAGE3:

Convert text to Proper Case and default words less than 3 chars to UPPERCASE

select dbo.fProperCase('SIMPSON, HJ',null,3)
>> Simpson, HJ

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
begin
      declare @sep char(1) -- Seperator character for exceptions
      declare @i int -- counter
      declare @ProperCaseText varchar(5000) -- Used to build our Proper Case string for Function return
      declare @Word varchar(1000) -- Temporary storage for each word
      declare @IsWhiteSpace as bit -- Used to indicate whitespace character/start of new word
      declare @c char(1) -- Temp storage location for each character

      set @Word = ''
      set @i = 1
      set @IsWhiteSpace = 1
      set @ProperCaseText = ''
      set @sep = '|'

      -- Set default UPPERCASEWord Length
      if @UCASEWordLength is null set @UCASEWordLength = 1
      -- Convert user input to lower case (This function will UPPERCASE words as required)
      set @Value = LOWER(@Value)

      -- Loop while counter is less than text lenth (for each character in...)
      while (@i <= len(@Value)+1)
      begin

            -- Get the current character
            set @c = SUBSTRING(@Value,@i,1)

            -- If start of new word, UPPERCASE character
            if @IsWhiteSpace = 1 set @c = UPPER(@c)

            -- Check if character is white space/symbol (using ascii values)
            set @IsWhiteSpace = case when (ASCII(@c) between 48 and 58) then 0
                                          when (ASCII(@c) between 64 and 90) then 0
                                          when (ASCII(@c) between 96 and 123) then 0
                                          else 1 end

            if @IsWhiteSpace = 0
            begin
                  -- Append character to temp @Word variable if not whitespace
                  set @Word = @Word + @c
            end
            else
            begin
                  -- Character is white space/punctuation/symbol which marks the end of our current word.
                  -- If word length is less than or equal to the UPPERCASE word length, convert to upper case.
                  -- e.g. you can specify a @UCASEWordLength of 3 to automatically UPPERCASE all 3 letter words.
                  set @Word = case when len(@Word) <= @UCASEWordLength then UPPER(@Word) else @Word end

                  -- Check word against user exceptions list. If exception is found, use the case specified in the exception.
                  -- e.g. WiseSoft, RAM, CPU.
                  -- If word isn't in user exceptions list, check for "known" exceptions.
                  set @Word = case when charindex(@sep + @Word + @sep,@exceptions collate Latin1_General_CI_AS) > 0
                                    then substring(@exceptions,charindex(@sep + @Word + @sep,@exceptions collate Latin1_General_CI_AS)+1,len(@Word))
                                    when @Word = 's' and substring(@Value,@i-2,1) = '''' then 's' -- e.g. Who's
                                    when @Word = 't' and substring(@Value,@i-2,1) = '''' then 't' -- e.g. Don't
                                    when @Word = 'm' and substring(@Value,@i-2,1) = '''' then 'm' -- e.g. I'm
                                    when @Word = 'll' and substring(@Value,@i-3,1) = '''' then 'll' -- e.g. He'll
                                    when @Word = 've' and substring(@Value,@i-3,1) = '''' then 've' -- e.g. Could've
                                    else @Word end

                  -- Append the word to the @ProperCaseText along with the whitespace character
                  set @ProperCaseText = @ProperCaseText + @Word + @c
                  -- Reset the Temp @Word variable, ready for a new word
                  set @Word = ''
            end
            -- Increment the counter
            set @i = @i + 1
      end
      return @ProperCaseText
end

/*
update tcontract
set contract = dbo.Takeda_fn_TitleCase(contract,'IT|HR|TP|SG',2)
where executorid = 86302
*/

/*
	select contract
	/*,	SUBSTRING([contract],PatIndex('%, [A-Z][A-Z] -%',[contract])+2,2)*/
	,Substring([contract] ,PatIndex('%[A-Z][A-Z][A-Z][A-Z][A-Z] %' COLLATE LATIN1_gENERAL_BIN,[contract]),1)
	from tcontract 
	where Substring([contract] ,PatIndex('%[A-Z][A-Z][A-Z][A-Z][A-Z] %' COLLATE LATIN1_gENERAL_BIN,[contract]),1) >'a'
	and [contract] not like ('%NEMEA%')

	*/
GO
/****** Object:  UserDefinedFunction [dbo].[Takeda_GetFirstLetterOfEachWord]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[Takeda_GetFirstLetterOfEachWord](@Temp VarChar(1000))
/* call Select dbo.Takeda_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
Returns VarChar(250)

AS

Begin

	DECLARE @allowed varchar(100); SET @allowed = 'A-Z0-9' -- characters allowed in the result
	DECLARE @i INT; SET @i = 0
	DECLARE @result varchar(8000)

	SET @Temp = Replace(@Temp,'"','')

	WHILE @i is not null

	BEGIN

		SET @result = ISNULL(@result,'')+ISNULL(SUBSTRING(@Temp,@i+1,1),'')

		SET @i = @i + NULLIF(PATINDEX('%[^('+@allowed+')]['+@allowed+']%',SUBSTRING(@Temp,@i+1,8000)),0)

	END

    Return UPPER(@result)

End


GO
/****** Object:  UserDefinedFunction [dbo].[Takeda_GetFirstWordInString]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Function [dbo].[Takeda_GetFirstWordInString](@Temp VarChar(255))
/* call Select dbo.Takeda_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
Returns VarChar(250)

AS

Begin

	DECLARE @allowed varchar(100); SET @allowed = 'A-Z0-9' -- characters allowed in the result
	DECLARE @i INT; SET @i = 0
	DECLARE @result varchar(8000)
    Declare @KeepValues as varchar(50)	

	BEGIN

	SET @Temp = Replace(@Temp,'"','')

	/* remove any special characters, except for letters, numbers and spaces */
	Set @KeepValues = '%[^a-z0-9A-Z" "]%' /* was  '%[^0-z," "]%' */
    While PatIndex(@KeepValues, @Temp) > 0
        Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '')
	Set @Temp = REPLACE(@Temp,'Copy of','')

	SET @result = SUBSTRING(@Temp,0,(CHARINDEX(' ',@Temp + ' ')))

	END

    Return @result /* was upper, removed 10-oct */

End

 
GO
/****** Object:  UserDefinedFunction [dbo].[Takeda_RemoveAccents_Varchar255]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Function [dbo].[Takeda_RemoveAccents_Varchar255](@Temp VarChar(255))
/* call Select dbo.Takeda_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
Returns VarChar(255)

AS

Begin

	SET @Temp = Replace(@Temp,'"','') /* "" leads to issues */
	      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'a', 'a' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'e', 'e' )
      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'i', 'i' )
      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'o', 'o' )
      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'u', 'u' )
      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'y', 'y' )
      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'n', 'n' )
      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'œ', 'oe' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'æ', 'ae' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'ß', 'ss' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 's', 's' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'A', 'A' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'E', 'E' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'I', 'I' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'O', 'O' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'U', 'U' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'Y', 'Y' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'N', 'N' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'Œ', 'OE' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'Æ', 'AE' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'ß', 'SS' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'S', 'S' )


    Return ltrim(@Temp)

End



GO
/****** Object:  UserDefinedFunction [dbo].[Takeda_RemoveNonAlphaCharacters]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[Takeda_RemoveNonAlphaCharacters](@Temp VarChar(1000))
/* call Select dbo.Takeda_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
Returns VarChar(1000)
AS
Begin

    Declare @KeepValues as varchar(50)
	SET @Temp = Replace(@Temp,'"','')

    Set @KeepValues = '%[^a-z]%'
    While PatIndex(@KeepValues, @Temp) > 0
        Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '')
	Set @Temp = REPLACE(@Temp,'Copy of','')
    Return UPPER(@Temp)
End
GO
/****** Object:  UserDefinedFunction [dbo].[Takeda_RemoveNonAlphaNonNumericCharacters]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[Takeda_RemoveNonAlphaNonNumericCharacters](@Temp VarChar(255))
/* call Select dbo.Takeda_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
Returns VarChar(255)

AS

Begin

    Declare @KeepValues as varchar(255)

    Set @KeepValues = '%[^0-z]%'

    While PatIndex(@KeepValues, @Temp) > 0
        Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '')
	Set @Temp = REPLACE(@Temp,'Copy of','')

    Return UPPER(@Temp)

End
GO
/****** Object:  UserDefinedFunction [dbo].[Takeda_RemoveNonAlphaNonNumNonSpace]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[Takeda_RemoveNonAlphaNonNumNonSpace](@Temp VarChar(1000))
/* call Select dbo.Takeda_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
Returns VarChar(1000)

AS

Begin

    Declare @KeepValues as varchar(50)
	SET @Temp = Replace(@Temp,'"','') /* "" leads to issues */
	SET @Temp = Replace(@Temp,'-',' ') /* replace - with space so that e.g. INTROGRAF-LUBLIN is not concatted to INTROGRAFLUBLIN */

    Set @KeepValues = '%[^a-z0-9A-Z" "]%' /* was  '%[^0-z," "]%' */
    While PatIndex(@KeepValues, @Temp) > 0
        Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '')
	Set @Temp = REPLACE(@Temp,'Copy of','')
    Return UPPER(@Temp)
End
GO
/****** Object:  UserDefinedFunction [dbo].[Takeda_RemoveNonAlphaNonNumNonSpaceNonFwSlash]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[Takeda_RemoveNonAlphaNonNumNonSpaceNonFwSlash](@Temp VarChar(1000))
/* Takeda A/S etc. */
Returns VarChar(1000)

AS

	Begin

		Declare @KeepValues as varchar(50)
		/*SET @Temp = Replace(@Temp,'"','') /* "" leads to issues */
		SET @Temp = Replace(@Temp,'-',' ') /* replace - with space so that e.g. INTROGRAF-LUBLIN is not concatted to INTROGRAFLUBLIN */
		*/
		Set @KeepValues = '%[^a-z0-9A-Z"/"]%' /* was  '%[^a-z0-9A-Z" ""/"]%' */
		While PatIndex(@KeepValues, @Temp) > 0
			Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '')
		Set @Temp = REPLACE(@Temp,'Copy of','')

		Return @Temp /* upper removed */
	End

GO
/****** Object:  UserDefinedFunction [dbo].[Takeda_RemoveNonAlphaNonNumNonSpaceNonHyphen]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[Takeda_RemoveNonAlphaNonNumNonSpaceNonHyphen](@Temp VarChar(1000))
/* call Select dbo.Takeda_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
Returns VarChar(1000)

AS

Begin

    Declare @KeepValues as varchar(50)
	SET @Temp = Replace(@Temp,'"','') /* "" leads to issues */
	/* Products can have hyphens and spaces */
	SET @Temp = Replace(@Temp,'/',' ') /* e.g. Xylometazoline/ZYCOMB */

    Set @KeepValues = '%[^a-z0-9A-Z" "\-]%' /* was  '%[^0-z," "]%' */
    While PatIndex(@KeepValues, @Temp) > 0
        Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '')
	Set @Temp = REPLACE(@Temp,'Copy of','')
    Return UPPER(@Temp)
End


GO
/****** Object:  UserDefinedFunction [dbo].[Takeda_RemoveNonAlphaNonSpace]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[Takeda_RemoveNonAlphaNonSpace](@Temp VarChar(1000))
/* call Select dbo.Takeda_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
Returns VarChar(1000)

AS

Begin

    Declare @KeepValues as varchar(50)
	SET @Temp = Replace(@Temp,'"','') /* "" leads to issues */

    Set @KeepValues = '%[^a-zA-Z" "]%' /* was  '%[^0-z," "]%' */
    While PatIndex(@KeepValues, @Temp) > 0
        Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '')
	Set @Temp = REPLACE(@Temp,'Copy of','')
    Return ltrim(@Temp)

End
GO
/****** Object:  UserDefinedFunction [dbo].[TFN_TUSER_FOR_REPORT_MODEL]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[TFN_TUSER_FOR_REPORT_MODEL]
(
)
RETURNS @RESULT TABLE (USERID BIGINT PRIMARY KEY, DOMAINUSERNAME NVARCHAR(1024),UNIQUE  (DOMAINUSERNAME,UserID))
AS
BEGIN
	INSERT @RESULT
	  (
	    USERID,
	    DOMAINUSERNAME
	  )
	SELECT USERID,
	       CASE 
	            WHEN EXISTS (
	                     SELECT TPROFILESETTING.PROFILESETTINGID
	                     FROM   TPROFILESETTING
	                            INNER JOIN TPROFILEKEY
	                                 ON  TPROFILEKEY.PROFILEKEYID = 
	                                     TPROFILESETTING.PROFILEKEYID
	                     WHERE  TPROFILEKEY.FIXED = 
	                            'SSRS_ENABLE_CUSTOM_AUTHENTICATION'
	                            AND TPROFILESETTING.SETTINGVALUE = 'TRUE'
	                 ) THEN TUSER.USERINITIAL
	            ELSE DBO.FN_GET_NETBIOSNAME_FROM_DNSNAME(TUSER.DOMAINUSERNAME)
	       END AS DOMAINUSERNAME
	       FROM TUSER
	WHERE  TUSER.MIK_VALID=1 AND TUSER.ISEXTERNALUSER = 0
	       AND (
	               TUSER.DOMAINUSERNAME IS NOT NULL
	               OR EXISTS (
	                      SELECT TPROFILESETTING.PROFILESETTINGID
	                      FROM   TPROFILESETTING
	                             INNER JOIN TPROFILEKEY
	                                  ON  TPROFILEKEY.PROFILEKEYID = 
	                                      TPROFILESETTING.PROFILEKEYID
	                      WHERE  TPROFILEKEY.FIXED = 
	                             'SSRS_ENABLE_CUSTOM_AUTHENTICATION'
	                             AND TPROFILESETTING.SETTINGVALUE = 'TRUE'
	                  )
	           )
	
	RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[udf_get_companyid]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[udf_get_companyid] (@contractid bigint)
returns bigint
as
begin
declare @companyid bigint
select  @companyid= companyid from 
	(
		select r.companyid,
		count(r.companyid) over (partition by r.contractid) as company_count
		from  ttenderer r
		where  r.isawarded = 1 and r.contractid = @contractid
     ) ci where ci.company_count = 1 
return @companyid
end 
GO
/****** Object:  UserDefinedFunction [dbo].[udf_get_companyname]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[udf_get_companyname] (@contractid bigint)
returns nvarchar(255)
as
begin
declare @companyname nvarchar(255)
select  @companyname= company from 
	(
		select cm.company,
		count(r.companyid) over (partition by r.contractid) as company_count
		from  ttenderer r
		inner join tcompany cm
		on r.companyid = cm.companyid
		where  r.isawarded = 1 and r.contractid = @contractid
     ) ci where ci.company_count = 1 
return @companyname
end 
GO
/****** Object:  UserDefinedFunction [dbo].[udf_is_internal_user_profile_editable]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION  [dbo].[udf_is_internal_user_profile_editable] ( @UserID			bigint,	
	                                                            @UserProfileID	bigint
											                   ) 
RETURNS bit
AS
BEGIN

	-- check if the profile is restricted
	if( not exists( select 1 from dbo.[TUserProfile] up
		inner join dbo.[TUSERPROFILERELATION] r on up.[USERPROFILEID] = r.[USERPROFILEID]
			where up.[USERPROFILEID] = @UserProfileID and up.[RESTRICTED] = 1)
	  )
		return 1; 
	
	-- check if the user is allowed to edit the profile
	if( exists( select 1 from dbo.[TUSER] u 
				inner join dbo.[TUSERPROFILERELATION] r on u.[UserProfileID] = r.[EDITORUSERPROFILEID]
					where r.[USERPROFILEID] = @UserProfileID and u.[USERID] = @UserID)
	  )
		return 1;
	
	return 0;

END
GO
