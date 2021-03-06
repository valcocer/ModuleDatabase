-- Creacion de Store Procedures - Auditorias
/******************************************************************************
**  Name: SSID_SPs_CREATE_TRIGGERS
**  Desc: Store procedures for delete and create TRIGGERS Audit in tables
** 
** 1) SSID_SP_CREA_TRIGGERS_INSERT
** 2) SSID_SP_CREA_TRIGGERS_UPDATE
** 3) SSID_SP_CREA_TRIGGERS_DELETE
** 4) SSID_SP_DELETE_TRIGGERS
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

-- 1) SSID_SP_CREA_TRIGGERS_INSERT, Store procedure for Delete TRIGGERS in a table
IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[SSID_SP_CREA_TRIGGERS_INSERT]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
	BEGIN
		DROP PROCEDURE SSID_SP_CREA_TRIGGERS_INSERT
		PRINT 'SE HA ELIMINADO EL SP SSID_SP_CREA_TRIGGERS_INSERT';
	END
GO

CREATE PROCEDURE SSID_SP_CREA_TRIGGERS_INSERT
	@TABLA VARCHAR(50),
	@COLUMNAS VARCHAR(MAX)
AS    
BEGIN   
	
	-- Es necesario que a las tablas que se agreguen los triggers tengan los campos CreatedBy, UpdatedBy


	DECLARE @SQL VARCHAR(MAX)    
    
	SET @SQL = 'CREATE TRIGGER SSID_TRGINS_' + @TABLA     
	SET @SQL = @SQL + ' ON ' + @TABLA + '      
		AFTER INSERT    
		AS 
		BEGIN    
			DECLARE @PrimaryKeyField VARCHAR(1000)    
			DECLARE @PrimaryKeyValue VARCHAR(1000) 
			
			IF TRIGGER_NESTLEVEL(@@ProcID) > 1 
			BEGIN 
				RETURN; 
			END 
 
			SET NOCOUNT ON; 
			SET XACT_ABORT ON; 
 
			DECLARE @CurrDate DATETIME = GETUTCDATE(); '
     
	SELECT ROW_NUMBER() OVER (ORDER BY item) AS Consecutivo, *      
	INTO #Columnas
	FROM fnSplit(@COLUMNAS, ',')
     
	DECLARE @conteo INT,    
	@filas INT
	SET @conteo = 0    
	SET @filas = (SELECT COUNT(1) FROM #Columnas)    
     
	WHILE (@conteo != @filas)
	BEGIN
		SET @SQL = @SQL + 'DECLARE @' + (SELECT item FROM #Columnas WHERE Consecutivo = @conteo + 1) + ' VARCHAR(MAX) '
		SET @SQL = @SQL + 'DECLARE @Value' + (SELECT item FROM #Columnas WHERE Consecutivo = @conteo + 1) + ' VARCHAR(MAX) '
		SET @conteo = @conteo + 1
	END
     
	DECLARE @PrimaryKeyField VARCHAR(100)
	SET @PrimaryKeyField  = (
								SELECT column_name
								FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE    
								WHERE OBJECTPROPERTY(OBJECT_ID(constraint_name), 'IsPrimaryKey') = 1    
								AND table_name = @TABLA
							)
      
	IF(@PrimaryKeyField != '')    
	BEGIN
		SET @SQL = @SQL + ' SET @PrimaryKeyField = (SELECT column_name 
			FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
			WHERE OBJECTPROPERTY(OBJECT_ID(constraint_name), ''IsPrimaryKey'') = 1 
			AND table_name = ''' + @TABLA + ''') 
           
			IF(@PrimaryKeyField IS NOT NULL)    
			BEGIN 
				SELECT @PrimaryKeyValue = ' + @PrimaryKeyField + ' FROM inserted 
			END '
	END
     
	SET @conteo = 0    
	DECLARE @Columna VARCHAR(100)    
	
	WHILE(@conteo != @filas)    
	BEGIN
		SET @Columna = (SELECT item FROM #Columnas WHERE Consecutivo = @conteo + 1)
		SET @SQL = @SQL + ' SELECT @Value' + @Columna + ' = ' + @Columna + ' FROM Inserted '    
		SET @SQL = @SQL + ' INSERT INTO AuditHistory '
		SET @SQL = @SQL + ' SELECT ''I''
		,''' + @TABLA + '''
		,''' + @PrimaryKeyField + '''
		, @PrimaryKeyValue 
		, ''' + @Columna + '''
		, ''''
		, @Value' + @Columna + '
		, GETDATE()
		, i.CreatedBy
		FROM Inserted i 
		'
		SET @conteo = @conteo + 1    
	END
     
	SET @SQL = @SQL + ' END '
	DROP TABLE #Columnas
	-- PRINT @SQL
	EXECUTE (@SQL)
END
GO

-- 2) SSID_SP_CREA_TRIGGERS_UPDATE, Store procedure for Delete TRIGGERS in a table
IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[SSID_SP_CREA_TRIGGERS_UPDATE]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
	BEGIN
		DROP PROCEDURE SSID_SP_CREA_TRIGGERS_UPDATE
		PRINT 'SE HA ELIMINADO EL SP SSID_SP_CREA_TRIGGERS_UPDATE';
	END
GO

CREATE PROCEDURE [dbo].[H3i_SP_CREA_TRIGGERS_UPDATE]
	@TABLA VARCHAR(150),
	@COLUMNAS VARCHAR(MAX)
AS  
BEGIN   
	-- Es necesario que a las tablas que se agreguen los triggers tengan los campos CreatedBy, UpdatedBy

	DECLARE @SQL VARCHAR(MAX)      
      
	SET @SQL = 'CREATE TRIGGER SSID_TRGUPD_' + @TABLA       
	SET @SQL = @SQL + ' ON ' + @TABLA + '        
	   FOR UPDATE      
	   AS       
	   BEGIN      
		DECLARE @PrimaryKeyField varchar(1000)      
		DECLARE @PrimaryKeyValue varchar(1000) '
        
	DECLARE @PrimaryKeyField VARCHAR(100)      
	SET @PrimaryKeyField  = (SELECT column_name      
							FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE      
							WHERE OBJECTPROPERTY(OBJECT_ID(constraint_name), 'IsPrimaryKey') = 1      
								AND table_name = @TABLA)
         
	IF(@PrimaryKeyField != '')      
	BEGIN
		SET @SQL = @SQL + ' SET @PrimaryKeyField = (SELECT column_name      
													FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE      
													WHERE OBJECTPROPERTY(OBJECT_ID(constraint_name), ''IsPrimaryKey'') = 1      
													AND table_name = ''' + @TABLA + ''')      
              
			IF(@PrimaryKeyField IS NOT NULL)      
			BEGIN     
				SELECT @PrimaryKeyValue = ' + @PrimaryKeyField + ' FROM inserted      
			END '
	END
    
	SELECT ROW_NUMBER() OVER (ORDER BY item) AS Consecutivo, *        
	INTO #Columnas      
	FROM fnSplit(@COLUMNAS, ',')
        
	DECLARE @conteo INT
			,@filas INT
	SET @conteo = 0
	SET @filas = (SELECT COUNT(1) FROM #Columnas)      
        
	DECLARE @Columna VARCHAR(100)     
	WHILE(@conteo != @filas)      
	BEGIN      
		SET @Columna = (SELECT item FROM #Columnas WHERE Consecutivo = @conteo + 1)    
		SET @SQL = @SQL + ' IF (UPDATE (' + @Columna + ' )) BEGIN '      
		SET @SQL = @SQL + ' DECLARE @OLD' + @Columna + ' Varchar(MAX) '      
		SET @SQL = @SQL + ' SET @OLD' + @Columna + ' = (SELECT ' + @Columna + ' FROM DELETED) '      
		SET @SQL = @SQL + ' DECLARE @NEW' + @Columna + ' Varchar(MAX) '      
		SET @SQL = @SQL + ' SET @NEW' + @Columna + ' = (SELECT ' + @Columna + ' FROM INSERTED) '     
		SET @SQL = @SQL + ' INSERT INTO AuditHistory '      
		SET @SQL = @SQL + ' SELECT ''U''
									,''' + @TABLA + '''
									,''' + @PrimaryKeyField + '''
									, @PrimaryKeyValue 
									, ''' + @Columna + '''
									, @OLD' + @Columna + '
									, @NEW' + @Columna + '
									, GETDATE()
									, i.UpdatedBy
								FROM INSERTED i 
								'      
		SET @SQL = @SQL + ' END ' --END IF UDPATE
		SET @conteo = @conteo + 1      
	END
  
	SET @SQL = @SQL + 'END' -- END SP
	DROP TABLE #Columnas
	--PRINT @SQL
	EXECUTE(@SQL)      
END
GO

-- 3) SSID_SP_CREA_TRIGGERS_DELETE, Store procedure for Delete TRIGGERS in a table
IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[SSID_SP_CREA_TRIGGERS_DELETE]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
BEGIN
	DROP PROCEDURE SSID_SP_CREA_TRIGGERS_DELETE
	PRINT 'SE HA ELIMINADO EL SP SSID_SP_CREA_TRIGGERS_DELETE';
END
GO

CREATE PROCEDURE [dbo].[H3i_SP_CREA_TRIGGERS_ELIMINAR]      
	@TABLA VARCHAR(150),          
	@COLUMNAS VARCHAR(MAX)          
AS          
BEGIN
	-- Es necesario que a las tablas que se agreguen los triggers tengan los campos CreatedBy, UpdatedBy

	DECLARE @SQL VARCHAR(MAX)          
          
	SET @SQL = 'CREATE TRIGGER SSID_TRGDEL_' + @TABLA           
	SET @SQL = @SQL + ' ON ' + @TABLA + '            
		AFTER DELETE          
		AS           
		BEGIN          
		DECLARE @PrimaryKeyField VARCHAR(1000)          
		DECLARE @PrimaryKeyValue VARCHAR(1000)'          
           
	SELECT ROW_NUMBER() OVER (ORDER BY item) AS Consecutivo, *            
	INTO #Columnas
	FROM fnSplit(@COLUMNAS, ',')           
           
	DECLARE @conteo INT,          
	@filas INT
	SET @conteo = 0          
	SET @filas = (SELECT count(1) FROM #Columnas)          
           
	WHILE(@conteo != @filas)          
	BEGIN
		SET @SQL = @SQL + ' DECLARE @Value' + (SELECT item FROM #Columnas WHERE Consecutivo = @conteo + 1) + ' VARCHAR(MAX) '          
		SET @conteo = @conteo + 1
	END
           
	DECLARE @PrimaryKeyField VARCHAR(100)
	SET @PrimaryKeyField  = (SELECT column_name          
							FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE          
							WHERE OBJECTPROPERTY(OBJECT_ID(constraint_name), 'IsPrimaryKey') = 1          
							AND table_name = @TABLA)          
            
	IF(@PrimaryKeyField != '')
	BEGIN
		SET @SQL = @SQL + ' SET @PrimaryKeyField = (SELECT column_name          
													FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE          
													WHERE OBJECTPROPERTY(OBJECT_ID(constraint_name), ''IsPrimaryKey'') = 1          
													AND table_name = ''' + @TABLA + ''')          
                 
			IF(@PrimaryKeyField IS NOT NULL)          
			BEGIN          
				SELECT @PrimaryKeyValue = ' + @PrimaryKeyField + ' FROM Deleted          
			END '          
    END
  
	SET @conteo = 0
	DECLARE @Columna VARCHAR(100)
	WHILE(@conteo != @filas)
	BEGIN
		SET @Columna = (SELECT item FROM #Columnas WHERE Consecutivo = @conteo + 1)          
		SET @SQL = @SQL + ' SELECT @Value' + @Columna + ' = ' + @Columna + ' FROM Deleted '          
		SET @SQL = @SQL + ' INSERT INTO AuditHistory '          
		SET @SQL = @SQL + ' SELECT ''D''
									, ''' + @TABLA + '''
									, ''' + @PrimaryKeyField + '''
									, @PrimaryKeyValue 
									, ''' + @Columna + '''
									, @Value' + @Columna + '
									, ''  ''
									, GETDATE()
									, d.UpdatedBy 
							FROM DELETED d 
							'          
		SET @conteo = @conteo + 1          
	END
           
	SET @SQL = @SQL + ' END'--END CREATE

	DROP TABLE #Columnas
	-- PRINT @SQL
	EXECUTE(@SQL)
END
GO

-- 4) SSID_SP_DELETE_TRIGGERS, Store procedure for Delete TRIGGERS in a table
IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[SSID_SP_DELETE_TRIGGERS]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
	BEGIN
		DROP PROCEDURE SSID_SP_DELETE_TRIGGERS
		PRINT 'SE HA ELIMINADO EL SP SSID_SP_DELETE_TRIGGERS';
	END
GO

CREATE PROCEDURE SSID_SP_DELETE_TRIGGERS
	@TABLA VARCHAR(100) ,  
	@TIPO INT   
AS      
BEGIN      
	DECLARE @SQL VARCHAR(100)      
      
	IF (@TIPO = 1)
	BEGIN  
		IF (
			(SELECT COUNT(*) FROM SYS.OBJECTS      
			WHERE NAME = 'SSID_TRGINS_' + @TABLA      
			AND TYPE = 'TR') > 0
			)      
		BEGIN      
			SET @SQL = 'DROP TRIGGER SSID_TRGINS_' + @TABLA      
			EXEC (@SQL)      
		END      
	END  
   
	IF (@TIPO = 2)  
	BEGIN  
		IF (
			(SELECT COUNT(*) FROM SYS.OBJECTS      
			WHERE NAME = 'SSID_TRGUPD_' + @TABLA      
			AND TYPE = 'TR') > 0
			)      
		BEGIN      
			SET @SQL = 'DROP TRIGGER SSID_TRGUPD_' + @TABLA      
			EXEC (@SQL)      
		END     
	END  
   
	IF (@TIPO = 3)  
	BEGIN  
		IF (
			(SELECT COUNT(*) FROM SYS.OBJECTS      
			WHERE NAME = 'SSID_TRGDEL_' + @TABLA      
			AND TYPE = 'TR') > 0
			)      
		BEGIN      
			SET @SQL = 'DROP TRIGGER SSID_TRGDEL_' + @TABLA      
			EXEC (@SQL)      
		END 
	END  
END 
GO