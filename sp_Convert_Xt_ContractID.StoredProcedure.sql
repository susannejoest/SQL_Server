USE [DAQ-1445_Contiki_App_DESQL016_Divestment]
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Convert_Xt_ContractID]    Script Date: 24 Jun 2024 11:12:13 ******/
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
