-- Creacion de Funcion
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ETL].[GetDatabaseRowVersion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [ETL].GetDatabaseRowVersion
	PRINT ('SE HA BORRADO LA FUNCION GetDatabaseRowVersion')
GO

/******************************************************************************
**  Name: GetDatabaseRowVersion
**  Desc: Used by DW ETL Process to return INT lastest version
** 
**  Called by: SSI-D
**
**  Author: Jesús David Piérola Alvarado
**
**  Date: 27/05/2018
*******************************************************************************
**                            Change History
*******************************************************************************
**   Date:     Author:                            Description:
** --------   --------                      -----------------------------------
** 27/05/2018 Jesús David Piérola Alvarado   Release 3.0 - DW
*******************************************************************************/

CREATE FUNCTION [ETL].[GetDatabaseRowVersion] ()
RETURNS BIGINT
AS
BEGIN
  RETURN CONVERT(BIGINT, MIN_ACTIVE_ROWVERSION()) - 1;
END
GO