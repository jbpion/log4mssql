IF OBJECT_ID('LoggerBase.Layout_JsonEscape') IS NOT NULL
SET NOEXEC ON
GO

CREATE FUNCTION LoggerBase.Layout_JsonEscape(@Text NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN NULL
END
GO

SET NOEXEC OFF
GO

/*********************************************************************************************

    FUNCTION LoggerBase.Layout_JSONLayout

    Date:           02/14/2019
    Author:         Jerome Pion
    Description:    A layout for converting a delimited token string to a JSON string.

    --TEST
	DECLARE @TestString NVARCHAR(100) ='"Quotes". This is a backslash \. And a tab	'
	SET @TestString = @TestString + CHAR(2)
	SELECT @TestString
	SELECT LoggerBase.Layout_JsonEscape(@TestString)

**********************************************************************************************/
ALTER FUNCTION LoggerBase.Layout_JsonEscape(@Text NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN

	SET @Text = REPLACE(@Text, '\', '\\')
	SELECT @Text = REPLACE(@Text, SpecialCharacter, EncodedSequence)
	FROM (
		SELECT EncodingName = 'Quotation mark', SpecialCharacter = '"', EncodedSequence = '\"'
		--UNION ALL SELECT RowId = 1,EncodingName = 'Reverse solidus', SpecialCharacter = '\', EncodedSequence = '\\'
		UNION ALL SELECT EncodingName = 'Solidus', SpecialCharacter = '/', EncodedSequence = '\/'
		UNION ALL SELECT EncodingName = 'Backspace', SpecialCharacter = CHAR(8), EncodedSequence = '\b'
		UNION ALL SELECT EncodingName = 'Form feed', SpecialCharacter = CHAR(12), EncodedSequence = '\f'
		UNION ALL SELECT EncodingName = 'New line', SpecialCharacter = CHAR(10), EncodedSequence = '\n'
		UNION ALL SELECT EncodingName = 'Carriage Return', SpecialCharacter = CHAR(13), EncodedSequence = '\r'
		UNION ALL SELECT EncodingName = 'Horizontal tab', SpecialCharacter = CHAR(9), EncodedSequence = '\t'
		UNION ALL SELECT EncodingName = 'CHAR(0)/null', SpecialCharacter = CHAR(0), EncodedSequence = '\u0000'
		UNION ALL SELECT EncodingName = 'CHAR(1)/Start Of Heading', SpecialCharacter = CHAR(1), EncodedSequence = '\u0001'
		UNION ALL SELECT EncodingName = 'CHAR(2)/Start Of Text', SpecialCharacter = CHAR(2), EncodedSequence = '\u0002'
		UNION ALL SELECT EncodingName = 'CHAR(3)/End Of Text', SpecialCharacter = CHAR(3), EncodedSequence = '\u0003'
		UNION ALL SELECT EncodingName = 'CHAR(4)/End Of Transmission', SpecialCharacter = CHAR(4), EncodedSequence = '\u0004'
		UNION ALL SELECT EncodingName = 'CHAR(5)/Enquiry', SpecialCharacter = CHAR(5), EncodedSequence = '\u0005'
		UNION ALL SELECT EncodingName = 'CHAR(6)/Acknowledge', SpecialCharacter = CHAR(6), EncodedSequence = '\u0006'
		UNION ALL SELECT EncodingName = 'CHAR(7)/Bell', SpecialCharacter = CHAR(7), EncodedSequence = '\u0007'
		UNION ALL SELECT EncodingName = 'CHAR(11)/Vertical Tab', SpecialCharacter = CHAR(11), EncodedSequence = '\u000B'
		UNION ALL SELECT EncodingName = 'CHAR(14)/Shift Out', SpecialCharacter = CHAR(14), EncodedSequence = '\u000E'
		UNION ALL SELECT EncodingName = 'CHAR(15)/Shift In', SpecialCharacter = CHAR(15), EncodedSequence = '\u000F'
		UNION ALL SELECT EncodingName = 'CHAR(16)/Synchronous Idle', SpecialCharacter = CHAR(16), EncodedSequence = '\u0010'
		UNION ALL SELECT EncodingName = 'CHAR(17)/Device Control 1', SpecialCharacter = CHAR(17), EncodedSequence = '\u0011'
		UNION ALL SELECT EncodingName = 'CHAR(18)/Device Control 2', SpecialCharacter = CHAR(18), EncodedSequence = '\u0012'
		UNION ALL SELECT EncodingName = 'CHAR(19)/Device Control 3', SpecialCharacter = CHAR(19), EncodedSequence = '\u0013'
		UNION ALL SELECT EncodingName = 'CHAR(20)/Device Control 4', SpecialCharacter = CHAR(20), EncodedSequence = '\u0014'
		UNION ALL SELECT EncodingName = 'CHAR(21)/Negative Acknowledge', SpecialCharacter = CHAR(21), EncodedSequence = '\u0015'
		UNION ALL SELECT EncodingName = 'CHAR(22)/Synchronous Idle', SpecialCharacter = CHAR(22), EncodedSequence = '\u0016'
		UNION ALL SELECT EncodingName = 'CHAR(23)/End Of Trans Block', SpecialCharacter = CHAR(23), EncodedSequence = '\u0017'
		UNION ALL SELECT EncodingName = 'CHAR(24)/Cancel', SpecialCharacter = CHAR(24), EncodedSequence = '\u0018'
		UNION ALL SELECT EncodingName = 'CHAR(25)/End Of Medium', SpecialCharacter = CHAR(25), EncodedSequence = '\u0019'
		UNION ALL SELECT EncodingName = 'CHAR(26)/Substitute', SpecialCharacter = CHAR(26), EncodedSequence = '\u001A'
		UNION ALL SELECT EncodingName = 'CHAR(27)/Escape', SpecialCharacter = CHAR(27), EncodedSequence = '\u001B'
		UNION ALL SELECT EncodingName = 'CHAR(28)/File Separator', SpecialCharacter = CHAR(28), EncodedSequence = '\u001C'
		UNION ALL SELECT EncodingName = 'CHAR(29)/Group Separator', SpecialCharacter = CHAR(29), EncodedSequence = '\u001D'
		UNION ALL SELECT EncodingName = 'CHAR(30)/Record Separator', SpecialCharacter = CHAR(30), EncodedSequence = '\u001E'
		UNION ALL SELECT EncodingName = 'CHAR(31)/Unit Separator', SpecialCharacter = CHAR(31), EncodedSequence = '\u001F'
	) AS E

	RETURN @Text

END
