-- 1. Before enabling TDE, check if the database is already encrypted:
-- Note: DO NOT RUN THIS ON A PRODUCTION ENVIRONMENT, ALWAYS RUN IN TEST OR STAGING FIRST
SELECT name, is_encrypted 
FROM sys.databases 
WHERE is_encrypted = 1
--WHERE name = 'databasename';

/*
If is_encrypted = 1, TDE is already enabled.
If is_encrypted = 0, proceed with the next steps.
*/

-- 2. If a Database Master Key (DMK) does not exist then proceed to create it 
--    on the destination database
-- List all DMKs
SELECT 
	d.name AS DatabaseName,
    d.is_master_key_encrypted_by_server AS IsEncryptedByServiceMasterKey,
    CASE 
        WHEN dek.database_id IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS HasDatabaseMasterKey
FROM 
    sys.databases d
LEFT JOIN 
    sys.dm_database_encryption_keys dek ON d.database_id = dek.database_id
ORDER BY 
    d.name;

USE [master];
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'xPU8jJzUA6n0Zoa2iyRA';
GO
-- The password is required for recovery, so store it securely.
-- 3. Now, create a certificate that will be used to encrypt the Database Encryption Key (DEK)
--    SUBJECT column has a 128 character limit on SQL for windows and 64 on SQL for Linux:

USE [master];
GO
CREATE CERTIFICATE [TDE_Cert]
WITH SUBJECT = 'TDE Certificate for Database Encryption';
GO

-- 4. Switch to the target database and create the DEK, encrypting it with the certificate:
USE [TDE_DEMO];
GO
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE [TDE_Cert];
GO

/*
1. AES_128, AES_192, AES_256 (most used).
2. TRIPLE_DES_3KEY (least recommended due to security and performance).
*/

-- AES_256 is the strongest encryption algorithm recommended.

-- 5. Finally, turn on TDE encryption for the database:
ALTER DATABASE [TDE_DEMO]
SET ENCRYPTION ON;
GO
-- TDE is now enabled for your database!

-- 6. Since the certificate is required for database restores, back it up securely:
USE [master];
GO
BACKUP CERTIFICATE TDE_Cert 
TO FILE = 'J:\MSSQL\BACKUP\TDE_Cert.bak'
WITH PRIVATE KEY (
    FILE = 'J:\MSSQL\BACKUP\TDE_Cert_Key.pvk',
    ENCRYPTION BY PASSWORD = 'Cv3IlfYRPzuLdzypHxCN'
);
GO
-- Important: Keep both the .bak and .pvk files safe, as you will need them to restore the database on another server.

/*
To test the certificate:

1. Backup TDE_DEMO database
2. Switch SQL instance
3. Test restore without certificate, an error is expected
4. Import certificate
5. Restore database and query the data in it
*/

-- 7. Backup TDE_DEMO on default instance
BACKUP DATABASE [TDE_DEMO] TO DISK = N'J:\MSSQL\BACKUP\TDE_DEMO_FULL.BAK'
WITH COMPRESSION, FORMAT, INIT, STATS = 1;

-- 8. Switch instance, copy backup, cert and private key to a location accesible to the instance

-- 9. Attemp restore to test database security, copy and paste error below:
RESTORE DATABASE [TDE_DEMO] FROM DISK = N'D:\MSSQL.EUCLID\BACKUP\TDE_DEMO_FULL.BAK'
WITH
MOVE 'TDE_DEMO' TO 'D:\MSSQL.EUCLID\USERDATABASE\DATA\TDE_DEMO.mdf',
MOVE 'TDE_DEMO_Log' TO 'D:\MSSQL.EUCLID\USERDATABASE\LOGS\TDE_DEMO_log.ldf',
STATS = 1

-- Error message:
/* 


*/

-- 10. Import certificate
-- a. Create a master key on the master database
USE master;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'xPU8jJzUA6n0Zoa2iyRA'; -- Can be different from the source
GO

-- b. Restore the certificate and private key and if successful, then try to restore the database:
CREATE CERTIFICATE TDE_Cert
FROM FILE = 'D:\MSSQL.EUCLID\BACKUP\TDE_Cert.bak'
WITH PRIVATE KEY (
    FILE = 'D:\MSSQL.EUCLID\BACKUP\TDE_Cert_Key.pvk',
    DECRYPTION BY PASSWORD = 'Cv3IlfYRPzuLdzypHxCN'
);
GO

-- 11. Query some data from TDE_DEMO
Select Top 10
    CASE
        WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
            '(local)'
        ELSE
            '.' + CAST(SERVERPROPERTY('InstanceName') AS VARCHAR(128))
    END AS ServerName,
    Id,
    TimeMarker,
    ProcessMarker,
    ManualGUID
From [TDE_DEMO].[dbo].[TDE_logs]
Order by NEWID() ASC;

-- Additional scripts:

USE master;
GO

-- List all DMKs
SELECT 
	d.name AS DatabaseName,
    d.is_master_key_encrypted_by_server AS IsEncryptedByServiceMasterKey,
    CASE 
        WHEN dek.database_id IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS HasDatabaseMasterKey
FROM 
    sys.databases d
LEFT JOIN 
    sys.dm_database_encryption_keys dek ON d.database_id = dek.database_id
ORDER BY 
    d.name;


-- List certificates
SELECT dek.create_date,
       dek.key_algorithm,
       dek.key_length,
       dek.encryption_state,
       dek.encryption_state_desc,
       dek.encryption_scan_modify_date,
       dek.encryption_scan_state,
       dek.encryption_scan_state_desc,
       c.name AS CertificateName,
       c.subject,
       c.start_date,
       c.expiry_date,
       c.thumbprint,
       db.name AS EncryptedDatabase
FROM sys.certificates AS c
    LEFT JOIN sys.dm_database_encryption_keys AS dek
        ON c.thumbprint = dek.encryptor_thumbprint
    LEFT JOIN sys.databases AS db
        ON dek.database_id = db.database_id
WHERE dek.encryptor_type = 'CERTIFICATE'

ORDER BY CertificateName;
-- Table

USE [TDE_DEMO]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [TDE_DEMO].[dbo].[TDE_Logs](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[GUIDMarker] [uniqueidentifier] NULL,
	[TimeMarker] [time](0) NULL,
	[ProcessMarker] [int] NULL,
	[ManualGUID] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TDE_Logs] ADD  DEFAULT (newid()) FOR [GUIDMarker]
GO

ALTER TABLE [dbo].[TDE_Logs] ADD  DEFAULT (getdate()) FOR [TimeMarker]
GO

ALTER TABLE [dbo].[TDE_Logs] ADD  DEFAULT (@@spid) FOR [ProcessMarker]
GO

INSERT INTO [TDE_DEMO].[dbo].[TDE_Logs] (ManualGUID) Values (Newid())
GO 1000
