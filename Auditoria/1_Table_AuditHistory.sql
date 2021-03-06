--Creacion de tabla auditoria
/******************************************************************************
**  Name: AuditHistory
**  Desc: Table Audit History
** 
**  Called by: SSI-D
**
**  Author: Jesús David Piérola Alvarado
**
**  Date: 17/05/2018
*******************************************************************************
**                            Change History
*******************************************************************************
**   Date:      Author:                            Description:
** --------    --------              -------------------------------------------
** 17/05/2018   J.David Piérola A.   Initial version
*******************************************************************************/

--Tabla de Auditoria
IF NOT EXISTS(SELECT * FROM sys.objects WHERE Type = 'U' AND object_id = OBJECT_ID('dbo.AuditHistory'))
BEGIN
	CREATE TABLE [dbo].[AuditHistory]
	(
		[AuditHistoryId]  INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_AuditHistory] PRIMARY KEY,
		[Type]			  CHAR(1) NULL,
		[TableName]		  VARCHAR(50) NULL,
		[PrimaryKeyField] VARCHAR(1000) NULL,
		[PrimaryKeyValue] VARCHAR(1000) NULL,
		[ColumnName]	  VARCHAR(50) NULL,
		[OldValue]        VARCHAR(MAX) NULL,
		[NewValue]        VARCHAR(MAX) NULL,
		[ModifiedDate]    DATETIME NOT NULL,
		[ModifiedBy]      INT
	);

	ALTER TABLE [dbo].[AuditHistory] ADD CONSTRAINT [DF_AuditHistory_ModifiedDate]  DEFAULT (GETUTCDATE()) FOR [ModifiedDate]
END
GO