USE [DAQ-1445_Contiki_App_DESQL016_Divestment]
GO
/****** Object:  UserDefinedFunction [dbo].[TheCompany_fn_TitleCase]    Script Date: 24 Jun 2024 11:12:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[TheCompany_fn_TitleCase]
(@Value varchar(8000), @Exceptions varchar(8000),@UCASEWordLength tinyint)
returns varchar(8000)
as
/*
INPUTS:

@Value :                This is the text to be converted to Proper Case
@Exceptions:            A list of exceptions to the default Proper Case rules. e.g. [|RAM|CPU|HDD|TFT|]
                              Without exception list they would display as Ram, Cpu, Hdd and Tft
                              Note the use of the Pipe "|" symbol to separate exceptions.
                              (You can change the @sep variable to something else if you prefer)
@UCASEWordLength: You can specify that words less than a certain length are automatically displayed in UPPERCASE

USAGE1:

Convert text to ProperCase, without any exceptions

select dbo.fProperCase('CONVERT this to proper case',null,null)

USAGE2:

Convert text to Proper Case, with exception for Xception

select dbo.fProperCase('convert to propercase except Xception','|Xception|',null)

USAGE3:

Convert text to Proper Case and default words less than 3 chars to UPPERCASE

select dbo.fProperCase('SIMPSON, Homer',null,3)
>> Simpson, Homer

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
