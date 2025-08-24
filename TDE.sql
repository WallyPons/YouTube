/*
TDE, or Transparent Data Encryption, is a security feature that encrypts data at rest in databases. 
It's used to protect sensitive information stored on disk, including database files, backups, and 
transaction logs by encrypting them before they are written to storage and decrypting them when accessed. 

A more detailed explanation in features includes:

Encryption at Rest:
TDE encrypts data while it's stored on the database server's hard drive or other storage media, making it 
unreadable to unauthorized users who might try to access the files directly. 

Real-time Encryption/Decryption:
TDE performs encryption and decryption operations on the fly as data is written to and read from the 
database without requiring changes to the application using the database. 

Key Management:
TDE relies on encryption keys to secure the data. These keys are typically stored separately from the encrypted 
data to further enhance security. 

Compliance:
TDE can help organizations meet various regulatory requirements, such as PCI DSS, HIPAA, and GDPR which mandate 
the protection of sensitive data. 
*/


-- 1. Before enabling TDE, check if the database is already encrypted:
-- Note: DO NOT RUN THIS ON A PRODUCTION ENVIRONMENT, ALWAYS RUN IN TEST OR STAGING FIRST
USE [master];
GO
SELECT name, is_encrypted
FROM sys.databases 
WHERE is_encrypted = 1
--WHERE name = 'databasename';

/*
If is_encrypted = 1, TDE is already enabled.
If is_encrypted = 0, proceed with the next steps.
*/

-- 2. If a Database Master Key (DMK) does not exist then proceed to create it 
-- List all DMKs
USE [master];
GO
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

USE [master];
GO
CREATE CERTIFICATE [TDE_Cert_2]
WITH SUBJECT = 'TDE Certificate #2 for Database Encryption';
GO

USE [master];
GO
CREATE CERTIFICATE [TDE_Cert_3]
WITH SUBJECT = 'TDE Certificate #3 for Database Encryption';
GO


-- 4. Switch to the target database and create the DEK, encrypting it with the certificate:
USE [TDE_DEMO];
GO
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE [TDE_Cert];
GO

USE [TDE_DEMO_2];
GO
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE [TDE_Cert_2];
GO

USE [TDE_DEMO_3];
GO
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE [TDE_Cert_3];
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

ALTER DATABASE [TDE_DEMO_2]
SET ENCRYPTION ON;
GO

ALTER DATABASE [TDE_DEMO_3]
SET ENCRYPTION ON;
GO
-- TDE is now enabled for your database!

-- 6. Since the certificate is required for database restores, back it up securely:
USE [master];
GO
BACKUP CERTIFICATE [TDE_Cert]
TO FILE = 'J:\MSSQL\BACKUP\TDE_Cert.bak'
WITH PRIVATE KEY (
    FILE = 'J:\MSSQL\BACKUP\TDE_Cert_Key.pvk',
    ENCRYPTION BY PASSWORD = 'Cv3IlfYRPzuLdzypHxCN'
);
GO

BACKUP CERTIFICATE [TDE_Cert_2]
TO FILE = 'J:\MSSQL\BACKUP\TDE_Cert_2.bak'
WITH PRIVATE KEY (
    FILE = 'J:\MSSQL\BACKUP\TDE_Cert_2_Key.pvk',
    ENCRYPTION BY PASSWORD = 'Cv3IlfYRPzuLdzypHxCN'
);
GO

BACKUP CERTIFICATE [TDE_Cert_3]
TO FILE = 'J:\MSSQL\BACKUP\TDE_Cert_3.bak'
WITH PRIVATE KEY (
    FILE = 'J:\MSSQL\BACKUP\TDE_Cert_3_Key.pvk',
    ENCRYPTION BY PASSWORD = 'Cv3IlfYRPzuLdzypHxCN'
);
GO


-- Important: Keep both the .bak and .pvk files safe, as you will need them to restore 
-- the database on another server.

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

BACKUP DATABASE [TDE_DEMO_2] TO DISK = N'J:\MSSQL\BACKUP\TDE_DEMO_2_FULL.BAK'
WITH COMPRESSION, FORMAT, INIT, STATS = 1;

BACKUP DATABASE [TDE_DEMO_3] TO DISK = N'J:\MSSQL\BACKUP\TDE_DEMO_3_FULL.BAK'
WITH COMPRESSION, FORMAT, INIT, STATS = 1;


-- 8. Switch instance, copy backup, cert and private key to a location accesible to the instance

-- 9. Attemp restore to test database security, copy and paste error below:
RESTORE DATABASE [TDE_DEMO] FROM DISK = N'D:\MSSQL.EUCLID\BACKUP\TDE_DEMO_FULL.BAK'
WITH --REPLACE, 
MOVE 'TDE_DEMO' TO 'D:\MSSQL.EUCLID\USERDATABASE\DATA\TDE_DEMO.mdf',
MOVE 'TDE_DEMO_Log' TO 'D:\MSSQL.EUCLID\USERDATABASE\LOGS\TDE_DEMO_log.ldf',
STATS = 1

-- TDE_DEMO_2
RESTORE DATABASE [TDE_DEMO_2] FROM DISK = N'D:\MSSQL.EUCLID\BACKUP\TDE_DEMO_2_FULL.BAK'
WITH -- REPLACE, 
MOVE 'TDE_DEMO_2' TO 'D:\MSSQL.EUCLID\USERDATABASE\DATA\TDE_DEMO_2.mdf',
MOVE 'TDE_DEMO_2_Log' TO 'D:\MSSQL.EUCLID\USERDATABASE\LOGS\TDE_DEMO_2_log.ldf',
STATS = 1

-- TDE_DEMO_3
RESTORE DATABASE [TDE_DEMO_3] FROM DISK = N'D:\MSSQL.EUCLID\BACKUP\TDE_DEMO_3_FULL.BAK'
WITH -- REPLACE, 
MOVE 'TDE_DEMO_3' TO 'D:\MSSQL.EUCLID\USERDATABASE\DATA\TDE_DEMO_3.mdf',
MOVE 'TDE_DEMO_3_Log' TO 'D:\MSSQL.EUCLID\USERDATABASE\LOGS\TDE_DEMO_3_log.ldf',
STATS = 1

-- Error message:
/* 
Locate and compare the SHA-1 hash of the certificate (thumbprint)

*/

-- 10. Import certificate
-- a. Create a master key on the master database
USE master;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'xPU8jJzUA6n0Zoa2iyRA'; -- Can be different from the source
GO

-- b. Restore the certificate and private key and if successful, then try to restore the database:
USE [master]
GO
CREATE CERTIFICATE [TDE_Cert]
FROM FILE = 'D:\MSSQL.EUCLID\BACKUP\TDE_Cert.bak'
WITH PRIVATE KEY (
    FILE = 'D:\MSSQL.EUCLID\BACKUP\TDE_Cert_Key.pvk',
    DECRYPTION BY PASSWORD = 'Cv3IlfYRPzuLdzypHxCN'
);
GO

CREATE CERTIFICATE [TDE_Cert_2]
FROM FILE = 'D:\MSSQL.EUCLID\BACKUP\TDE_Cert_2.bak'
WITH PRIVATE KEY (
    FILE = 'D:\MSSQL.EUCLID\BACKUP\TDE_Cert_2_Key.pvk',
    DECRYPTION BY PASSWORD = 'Cv3IlfYRPzuLdzypHxCN'
);
GO

CREATE CERTIFICATE [TDE_Cert_3]
FROM FILE = 'D:\MSSQL.EUCLID\BACKUP\TDE_Cert_3.bak'
WITH PRIVATE KEY (
    FILE = 'D:\MSSQL.EUCLID\BACKUP\TDE_Cert_3_Key.pvk',
    DECRYPTION BY PASSWORD = 'Cv3IlfYRPzuLdzypHxCN'
);
GO

-- 11. Query some data from TDE_DEMO
Select Top 10
    CASE
        WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
            '(local)'
        ELSE
            '.\' + CAST(SERVERPROPERTY('InstanceName') AS VARCHAR(128))
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
/*
Run on default instance to create databases:
CREATE DATABASE [TDE_DEMO];
GO
CREATE DATABASE [TDE_DEMO_2];
GO
CREATE DATABASE [TDE_DEMO_3];
GO
*/


-- Create sample table and populate, change the DB connection and scope
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

-- Don't forget to change the database scope:	
INSERT INTO [TDE_DEMO].[dbo].[TDE_Logs] (ManualGUID) Values (Newid())
GO 1000

/*
-- Drop all databases
DROP DATABASE [TDE_DEMO];
GO
DROP DATABASE [TDE_DEMO_2];
GO
DROP DATABASE [TDE_DEMO_3];
GO
*/

-- Additional Scripts

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
       c.thumbprint
FROM sys.certificates AS c
    LEFT JOIN sys.dm_database_encryption_keys AS dek
        ON c.thumbprint = dek.encryptor_thumbprint
    LEFT JOIN sys.databases AS db
        ON dek.database_id = db.database_id
WHERE dek.encryptor_type = 'CERTIFICATE'
ORDER BY CertificateName;

-- Drop all
-- 1
USE [master]
GO
ALTER DATABASE [TDE_DEMO]
SET ENCRYPTION OFF;
GO

ALTER DATABASE [TDE_DEMO_2]
SET ENCRYPTION OFF;
GO

ALTER DATABASE [TDE_DEMO_3]
SET ENCRYPTION OFF;
GO

-- 2
USE [TDE_DEMO];
GO
DROP DATABASE ENCRYPTION KEY;
GO

USE [TDE_DEMO_2];
GO
DROP DATABASE ENCRYPTION KEY;
GO

USE [TDE_DEMO_3];
GO
DROP DATABASE ENCRYPTION KEY;
GO
-- 3
USE [master];
GO
DROP CERTIFICATE TDE_Cert;
GO

USE [master];
GO
DROP CERTIFICATE TDE_Cert_2;
GO

USE [master];
GO
DROP CERTIFICATE TDE_Cert_3;
GO
-- 4
USE [master];
GO
DROP MASTER KEY;
GO

-- Sample certification rotation for when they expire
-- 1. In master, create a new certificate
USE master;
CREATE CERTIFICATE TDE_Cert_2025
  WITH SUBJECT = 'TDE rotation 2025';

-- 2. In the user DB, re-encrypt DEK by the new cert
USE [TDE_DEMO];
ALTER DATABASE ENCRYPTION KEY
ENCRYPTION BY SERVER CERTIFICATE TDE_Cert_2025;

-- 2. (Optional) Drop the old cert after verifying backups are usable
USE master;
DROP CERTIFICATE TDE_Cert; -- only when safe
