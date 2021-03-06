-- Creacion de Funcion
/******************************************************************************
**  Name: fnSplit
**  Desc: Transform a VARCHAR in a select result by a delimiter
** 
**  Called by: SSI-D
**
**  Author: Jesús David Piérola Alvarado
**
**  Date: 20/05/2018
*******************************************************************************
**                            Change History
*******************************************************************************
**   Date:     Author:                            Description:
** --------   --------                      -----------------------------------
** 20/05/2018 Jesús David Piérola Alvarado   Initial version
*******************************************************************************/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnSplit]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].fnSplit
	PRINT ('SE HA BORRADO LA FUNCION fnSplit')
GO

CREATE FUNCTION [dbo].[fnSplit](
	@sInputList VARCHAR(MAX), -- List of delimited items
	@sDelimiter CHAR(1) = ',' -- delimiter that separates items
) 
RETURNS @List TABLE (item VARCHAR(8000))

BEGIN
	DECLARE @sItem VARCHAR(8000)
	
	WHILE CHARINDEX(@sDelimiter,@sInputList,0) <> 0
	BEGIN
		SELECT
			@sItem=RTRIM(LTRIM(SUBSTRING(@sInputList,1,CHARINDEX(@sDelimiter,@sInputList,0)-1))),
			@sInputList=RTRIM(LTRIM(SUBSTRING(@sInputList,CHARINDEX(@sDelimiter,@sInputList,0)+LEN(@sDelimiter),LEN(@sInputList))))
		 
		IF LEN(@sItem) > 0
			INSERT INTO @List SELECT @sItem
	END

	IF LEN(@sInputList) > 0
	BEGIN
		INSERT INTO @List SELECT @sInputList -- Put the last item in
	END

	RETURN
END
GO