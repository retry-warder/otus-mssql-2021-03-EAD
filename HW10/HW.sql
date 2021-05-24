sp_configure 'clr enabled', 1  
GO  
RECONFIGURE  
GO  
USE [master]
GO
CREATE ASYMMETRIC KEY CLR_SP_Key
FROM EXECUTABLE FILE = 'C:\DATA\SQL_DLL\MD5CS.dll'
GO

CREATE LOGIN MD5CS_Login FROM ASYMMETRIC KEY CLR_SP_Key
GO

GRANT EXTERNAL ACCESS ASSEMBLY TO MD5CS_Login
GO

GRANT UNSAFE ASSEMBLY to MD5CS_Login
GO
--///////////////////////////////////////////////////
USE [WideWorldImporters]
GO
CREATE USER MD5CS_Login FOR LOGIN MD5CS_Login
GO

CREATE ASSEMBLY MD5CS FROM 'C:\DATA\SQL_DLL\MD5CS.dll'
WITH PERMISSION_SET=EXTERNAL_ACCESS
GO

CREATE PROCEDURE MD5CSSUM 
@binData varbinary(MAX), 
@md5sum varbinary(MAX) OUTPUT
AS EXTERNAL NAME MD5CS.StoredProcedures.MD5CS;

DECLARE @binData varbinary(MAX);
DECLARE @md5sum varbinary(MAX);
SET @binData = 1111110000011111
EXEC dbo.MD5CSSUM @binData, @md5sum OUTPUT;
SELECT
	@md5sum AS 'МойХэш'
	, HashBytes('MD5', @binData) AS 'SQLХэш'