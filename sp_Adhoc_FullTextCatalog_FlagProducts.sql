USE [DAQ-1445_TheVendor_App_DESQL016_Divestment]
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_KWS_FullText_AdhocNewProducts]    Script Date: 7 Jul 2024 11:40:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TheCompany_KWS_FullText_AdhocNewProducts] 
	( @Keyword as VARCHAR(255))
AS

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

				FETCH NEXT FROM curContracts INTO @PRODUCTGROUPID, /* @PRODUCTGROUP, */ @OBJECTID , 
					@OBJECTTYPEID, @DOCUMENTID, @DOC_COUNT /*, @CONTRACTNUMBER, @DATEREGISTERED */
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
