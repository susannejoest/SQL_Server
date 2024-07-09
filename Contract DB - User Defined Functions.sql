/****** Object:  UserDefinedFunction [dbo].[TheCompany_GetFirstLetterOfEachWord]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[TheCompany_GetFirstLetterOfEachWord](@Temp VarChar(1000))
/* call Select dbo.TheCompany_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
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
/****** Object:  UserDefinedFunction [dbo].[TheCompany_GetFirstWordInString]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Function [dbo].[TheCompany_GetFirstWordInString](@Temp VarChar(255))
/* call Select dbo.TheCompany_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
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
/****** Object:  UserDefinedFunction [dbo].[TheCompany_RemoveAccents_Varchar255]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Function [dbo].[TheCompany_RemoveAccents_Varchar255](@Temp VarChar(255))
/* call Select dbo.TheCompany_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
Returns VarChar(255)

AS

Begin

	SET @Temp = Replace(@Temp,'"','') /* "" leads to issues */
	      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'a', 'a' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'œ', 'oe' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'æ', 'ae' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'ß', 'ss' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'Œ', 'OE' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'Æ', 'AE' )

      SET @TEMP = Replace( @TEMP COLLATE Latin1_General_CS_AI, 'ß', 'SS' )




    Return ltrim(@Temp)

End



GO
/****** Object:  UserDefinedFunction [dbo].[TheCompany_RemoveNonAlphaCharacters]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[TheCompany_RemoveNonAlphaCharacters](@Temp VarChar(1000))
/* call Select dbo.TheCompany_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
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
/****** Object:  UserDefinedFunction [dbo].[TheCompany_RemoveNonAlphaNonNumericCharacters]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[TheCompany_RemoveNonAlphaNonNumericCharacters](@Temp VarChar(255))
/* call Select dbo.TheCompany_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
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
/****** Object:  UserDefinedFunction [dbo].[TheCompany_RemoveNonAlphaNonNumNonSpace]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[TheCompany_RemoveNonAlphaNonNumNonSpace](@Temp VarChar(1000))
/* call Select dbo.TheCompany_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
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
/****** Object:  UserDefinedFunction [dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonFwSlash](@Temp VarChar(1000))
/* TheCompany A/S etc. */
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
/****** Object:  UserDefinedFunction [dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonHyphen]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[TheCompany_RemoveNonAlphaNonNumNonSpaceNonHyphen](@Temp VarChar(1000))
/* call Select dbo.TheCompany_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
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
/****** Object:  UserDefinedFunction [dbo].[TheCompany_RemoveNonAlphaNonSpace]    Script Date: 24 Jun 2024 08:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[TheCompany_RemoveNonAlphaNonSpace](@Temp VarChar(1000))
/* call Select dbo.TheCompany_RemoveNonAlphaCharacters('abc1234def5678ghi90jkl') */
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
