USE [DAQ-1445_Contiki_App_DESQL016_Divestment]
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_Reminders_Deactivate_ContractID]    Script Date: 24 Jun 2024 11:12:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[TheCompany_Reminders_Deactivate_ContractID](
                  @CONTRACTID bigint
                /* , @XtPrefix as VARCHAR(255) /* Wave # 01 etc... !ARIBA_WXX */ */
                , @ExpiryDate as date /* e.g. 19 Dec 2017 for W1 */
)
AS

DECLARE @RESULTSTRING AS VARCHAR(255)

/* Contract ID must be valid */
	IF NOT EXISTS ( SELECT  1
					FROM    dbo.tcontract
					WHERE   Contractid = @CONTRACTID)
		BEGIN
			SET @RESULTSTRING = 'Contract ID does not exist: ' + (CASE WHEN @CONTRACTID IS NULL THEN 'NULL' ELSE STR(@CONTRACTID) END)
			GOTO lblTerminate 
		END

BEGIN

	/* TWARNING , review date only (maybe extend to all) */
		UPDATE TWARNING
			set ISACTIVE = 0
		WHERE 
			OBJECTID = @CONTRACTID
			AND ISACTIVE = 1 /* is never NULL */
		/* AND WARNINGFIELDNAME = 'REVIEWDATE' remove? we want all reminders gone */

	/* recurring reminders must also have recurrence info deleted */
	/* select * from twarning where objectid = 151058 */
		update twarning
		  set warningtypeid = 1 /* Single Date */
			, recurringnumber = null
			, recurringstart = null
			, RECURRENCEINTERVAL = null
			, recurrencexml = null
		where 
			OBJECTID = @CONTRACTID
			and warningtypeid = 3 /* recurring date */

			
	/* tperson_in_warning */

	/* select * from  tperson_in_warning where warningid in (select warningid from twarning w inner join TCONTRACT c on c.contractid = w.objectid
						WHERE w.OBJECTID = 151058) */

		/* ISTURNEDOFF */
		update tperson_in_warning
			set isturnedoff = 1 /* OFF */
		where 
			(isturnedoff = 0 /* ON */ 
				OR isturnedoff is null  /* ON */)
		AND warningid in (select warningid from twarning w inner join TCONTRACT c on c.contractid = w.objectid
						WHERE 
						w.OBJECTID = @CONTRACTID
						/* AND WARNINGFIELDNAME = 'REVIEWDATE' */)

	/* Turnedoffdate */
		update tperson_in_warning
			set turnedoffdate = @ExpiryDate /* getdate() */
		where 
			TURNEDOFFDATE is null
			and warningid in (select warningid 
								from twarning w inner join TCONTRACT c on c.contractid = w.objectid
								WHERE 
								w.OBJECTID = @CONTRACTID
								/* AND WARNINGFIELDNAME = 'REVIEWDATE' */)

	/* above is not enough - emailwarningflag too, and emailwarningsent ? H. Wagner received repeating reminder */

	/* EMAILWARNING flag */

	/* select * from tperson_in_warning 
	 where emailwarning = 1 and
	 warningid in (select warningid 
								from twarning w inner join TCONTRACT c on c.contractid = w.objectid
								WHERE 
								COUNTERPARTYNUMBER like '!ARIBA%'
								/* AND WARNINGFIELDNAME = 'REVIEWDATE' */) */
								 
		update tperson_in_warning
			set EMAILWARNING = 0 /* deactivated */
		where 
			emailwarning = 1
			AND warningid in (select warningid 
								from twarning w inner join TCONTRACT c on c.contractid = w.objectid
								WHERE 
								w.OBJECTID = @CONTRACTID)

	/* Emailwarningsent - better, EMAILWARNING = 0 */
	/*	update tperson_in_warning
			set EMAILWARNINGSENT = @ExpiryDate /* getdate() */
		where 
			EMAILWARNINGSENT is null
			and warningid in (select warningid 
								from twarning w inner join TCONTRACT c on c.contractid = w.objectid
								WHERE 
								w.OBJECTID = @CONTRACTID
								/* AND WARNINGFIELDNAME = 'REVIEWDATE' */) */

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
