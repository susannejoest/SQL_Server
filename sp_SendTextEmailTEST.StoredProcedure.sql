USE [DAQ-1445_TheVendor_App_DESQL016_Divestment]
GO
/****** Object:  StoredProcedure [dbo].[usp_TheCompany_SendTextEmailTEST]    Script Date: 24 Jun 2024 11:12:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_TheCompany_zSendTextEmailTEST]  @ServerAddr nvarchar(128),
@From nvarchar(128),
@To nvarchar(1024),
@Subject nvarchar(256),
@Bodytext nvarchar(max) = 'This is a test text email from MS SQL server, do not reply.',
@User nvarchar(128) = '',
@Password nvarchar(128) = '',
@SSLConnection int = 0,
@ServerPort int = 25

AS

DECLARE @hr int
DECLARE @oSmtp int
DECLARE @result int
DECLARE @description nvarchar(255)

EXEC @hr = sp_OACreate 'EASendMailObj.Mail',@oSmtp OUT 
If @hr <> 0 
BEGIN
    PRINT 'Please make sure you have EASendMail Component installed!'
    EXEC @hr = sp_OAGetErrorInfo @oSmtp, NULL, @description OUT
    IF @hr = 0
    BEGIN
        PRINT @description
    END
    RETURN
End

EXEC @hr = sp_OASetProperty @oSmtp, 'LicenseCode', 'TryIt'
EXEC @hr = sp_OASetProperty @oSmtp, 'ServerAddr', @ServerAddr
EXEC @hr = sp_OASetProperty @oSmtp, 'ServerPort', @ServerPort

EXEC @hr = sp_OASetProperty @oSmtp, 'UserName', @User
EXEC @hr = sp_OASetProperty @oSmtp, 'Password', @Password

EXEC @hr = sp_OASetProperty @oSmtp, 'FromAddr', @From

EXEC @hr = sp_OAMethod @oSmtp, 'AddRecipientEx', NULL,  @To, 0

EXEC @hr = sp_OASetProperty @oSmtp, 'Subject', @Subject 
EXEC @hr = sp_OASetProperty @oSmtp, 'BodyText', @BodyText 


If @SSLConnection > 0 
BEGIN
    EXEC @hr = sp_OAMethod @oSmtp, 'SSL_init', NULL
END

/* you can also add an attachment like this */
/*EXEC @hr = sp_OAMethod @oSmtp, 'AddAttachment', @result OUT, 'd:\test.jpg'*/
/*If @result <> 0 */
/*BEGIN*/
/*   EXEC @hr = sp_OAMethod @oSmtp, 'GetLastErrDescription', @description OUT*/
/*    PRINT 'failed to add attachment with the following error:'*/
/*    PRINT @description*/
/*END*/

PRINT 'Start to send email ...' 

EXEC @hr = sp_OAMethod @oSmtp, 'SendMail', @result OUT 

If @hr <> 0 
BEGIN
    EXEC @hr = sp_OAGetErrorInfo @oSmtp, NULL, @description OUT
    IF @hr = 0
    BEGIN
        PRINT @description
    END
    RETURN
End

If @result <> 0 
BEGIN
    EXEC @hr = sp_OAMethod @oSmtp, 'GetLastErrDescription', @description OUT
    PRINT 'failed to send email with the following error:'
    PRINT @description
END
ELSE 
BEGIN
    PRINT 'Email was sent successfully!'
END

EXEC @hr = sp_OADestroy @oSmtp

GO
