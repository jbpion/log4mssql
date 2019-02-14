CREATE PROCEDURE [loggerbasetests].[test Assert Layout_JsonEscape Adds Escape Characters]
AS
BEGIN

	DECLARE @TestString NVARCHAR(100) ='"Quotes" No Quotes'
	DECLARE @Actual NVARCHAR(1000)
	DECLARE @Expected NVARCHAR(1000)
	SELECT @Actual = LoggerBase.Layout_JsonEscape(@TestString)
	SET @Expected = '\"Quotes\" No Quotes'

	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

	SET @TestString = '\'
	SET @Expected = '\\'
	SELECT @Actual = LoggerBase.Layout_JsonEscape(@TestString)
	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

	SET @TestString = '/'
	SET @Expected = '\/'
	SELECT @Actual = LoggerBase.Layout_JsonEscape(@TestString)
	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

	SET @TestString = CHAR(8)
	SET @Expected = '\b'
	SELECT @Actual = LoggerBase.Layout_JsonEscape(@TestString)
	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

	SET @TestString = CHAR(12)
	SET @Expected = '\f'
	SELECT @Actual = LoggerBase.Layout_JsonEscape(@TestString)
	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

	SET @TestString = CHAR(10)
	SET @Expected = '\n'
	SELECT @Actual = LoggerBase.Layout_JsonEscape(@TestString)
	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

	SET @TestString = CHAR(13)
	SET @Expected = '\r'
	SELECT @Actual = LoggerBase.Layout_JsonEscape(@TestString)
	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

	SET @TestString = '	'
	SET @Expected =  '\t' --tab
	SELECT @Actual = LoggerBase.Layout_JsonEscape(@TestString)
	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual

	SET @TestString = '
'
	SET @Expected =  '\r\n' --CRLF
	SELECT @Actual = LoggerBase.Layout_JsonEscape(@TestString)
	EXEC tSQLt.AssertEquals @Expected = @Expected, @Actual = @Actual
  
END;


