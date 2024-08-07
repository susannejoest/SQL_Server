﻿USE [DAQ-1445_TheVendor_App_DESQL016_Divestment]
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_ProductGroupUpload_ObjectidProductgroupID]    Script Date: 24 Jun 2024 11:12:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Takeda_ProductGroupUpload_ObjectidProductgroupID](
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

PRINT '********************** ([dbo].[Takeda_ProductGroupUpload_ObjectidProductgroupID])'
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
			
			INSERT INTO T_Takeda_Product_Upload ( PRODUCTGROUPID       
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
