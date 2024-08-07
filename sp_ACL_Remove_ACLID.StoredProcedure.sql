USE [DAQ-1445_Contiki_App_DESQL016_Divestment]
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_ACL_Remove_ACLID]    Script Date: 24 Jun 2024 11:12:13 ******/
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
						AND USERID in (1 /*sysadm*/, 20134 /* contikiadmin */, 81995 /* systemservice */) 
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
