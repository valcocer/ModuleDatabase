IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'ETL.GetAreaChangesByRowVersion') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
BEGIN
	DROP PROCEDURE ETL.GetAreaChangesByRowVersion
	PRINT 'SE HA ELIMINADO EL SP ETL.GetAreaChangesByRowVersion';
END
GO

/******************************************************************************
**  Name: GetAreaChangesByRowVersion
**  Desc: Pulls Changes and Inserts from the dbo.Areas table (Area Data)
**  Called By: ETL SQL Job.
**
**  Author: Jesus David Piérola Alvarado
**
**  Created: 27/05/2018
*******************************************************************************
**                            Change History
*******************************************************************************
**  Date:       Author:						Description:
**  --------    --------					----------------------------------
**  27/05/2018  Jesus David Piérola Alvarado Release 3.0 - DW
******************************************************************************/
CREATE PROCEDURE ETL.GetAreaChangesByRowVersion
(
	@LastRowVersionID BIGINT,
	@CurrentDBTS      BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	SELECT AreaID       = a.area_id
		  ,AreaName     = a.area_name
	FROM dbo.areas a
	WHERE a.[Rowversion] > CONVERT(ROWVERSION, @LastRowVersionID)
	AND a.[Rowversion] <= CONVERT(ROWVERSION, @CurrentDBTS)
	GROUP BY a.area_id
			,a.area_name
END
GO