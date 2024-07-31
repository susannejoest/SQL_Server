USE [DAQ-1445_Contiki_App_DESQL016_Divestment]
GO
/****** Object:  View [dbo].[V_Takeda_VACL_FLAT]    Script Date: 24 Jun 2024 11:12:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[V_Takeda_VACL_FLAT]
/* could also use string_agg(concat(name,', '),'') */
as 

SELECT /* top 1 */
		OBJECTID

	/* group */
		, (SELECT string_agg(s.USERGROUP,', ')
		FROM V_Takeda_VACL_Contract_ReadPrivilege s
		WHERE s.objectid =p1.objectid)

	AS ACL_AllPermissions_GroupList

	/* user */
		, (SELECT string_agg(s.[DISPLAYNAME],';') 
		FROM V_Takeda_VACL_Contract_ReadPrivilege s
		WHERE s.objectid =p1.objectid
		)
	AS ACL_AllPermissions_UserList

	/* group and user */
		, 'GROUPS: ' 
		+ (SELECT string_agg(s.USERGROUP, ';')
		FROM V_Takeda_VACL_Contract_ReadPrivilege s
		WHERE s.objectid =p1.objectid
		)
		+ ', USERS: ' 
		+ 
		(SELECT string_agg(s.[DISPLAYNAME],';')
		FROM V_Takeda_VACL_Contract_ReadPrivilege s
		WHERE s.objectid =p1.objectid
		)
	AS ACL_AllPermissions_GroupAndUserList

		, (SELECT COUNT(DISTINCT ACLID) as CountACLID
		FROM V_Takeda_VACL_Contract_ReadPrivilege s
		WHERE s.objectid =p1.objectid
		and USERID is not null
		)
	AS ACL_UserPermissions_Count

		, (SELECT COUNT(DISTINCT ACLID) as CountACLID
		FROM V_Takeda_VACL_Contract_ReadPrivilege s
		WHERE s.objectid =p1.objectid
		and USERGROUPID is not null
		)
	AS ACL_GroupPermissions_Count

		, (SELECT COUNT(DISTINCT ACLID) as CountACLID
		FROM V_Takeda_VACL_Contract_ReadPrivilege s
		WHERE s.objectid =p1.objectid			
		)
	AS ACL_GroupAndUserPermissions_Count

  FROM V_Takeda_VACL_Contract_ReadPrivilege p1
  /*  WHERE 
	OBJECTID = 148186 /* contractnumber = 'TEST-00000080' */ */
	/* AND OBJECTTYPEID = 1 *//* already filtered in the view, contract only, since LINC does not have separate document permissions */
  group by OBJECTID


GO
