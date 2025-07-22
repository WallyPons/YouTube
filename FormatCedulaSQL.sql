/*
-------------------------------------------------------
Ejemplo de manipulacion para formato de cedula 
de la RepUblica Dominicana utilizando MS SQL Server
-------------------------------------------------------
Este tutorial fue creado por Wally Pons - Abril 2025
DBA de MS SQL Server con mas de 25 años de experiencia.
-------------------------------------------------------
Ingeniero, consultor, escritor, instructor y 
socio fundador de Datagrupo, PBSoft.
-------------------------------------------------------
Para contactactarme:
Web: https://datagrupo.com
Email: wpons@datagrupo.com
-------------------------------------------------------
Funciones a usarse en este proceso:
	a. LEN
	b. LEFT
	c. SUBSTRING
	d. RIGHT
-------------------------------------------------------
*/

-- 1. Tabla temporal
DROP TABLE IF EXISTS #CedulaTemp -- Borrar en caso de que exista, esto no afecta la ejecucion del CREATE TABLE
CREATE TABLE #CedulaTemp -- Crear tabla
(
	Cedula VARCHAR(11)
);
GO

-- 2. Insertar 1 registro de ejemplo
INSERT INTO #CedulaTemp
(
    Cedula
)
VALUES ('00112345674'); -- Normalmente se ve asi: 001-1234567-4
GO

-- 3. Leer registro
Select Top 1
    *
From #CedulaTemp;
GO

-- 4. LongitUd registro
Select Top 1
    LEN(Cedula) AS [Longitud Columna]
From #CedulaTemp;
GO

-- Extraccion de registro por partes: 3 Primeros valores a la izquierda
Select Top 1
    LEFT(Cedula, 3) AS [Tres Izquierda]
From #CedulaTemp;
GO

-- Extraccion de registro por partes: 7 valores centrales
Select Top 1
    SUBSTRING(Cedula, 4, 7) AS [Siete Centro]
From #CedulaTemp;
GO

-- Extraccion de registro por partes: Ultimo valor
Select Top 1
    RIGHT(Cedula, 1) AS [Ultimo Valor]
From #CedulaTemp;
GO

-- Extraccion con guiones
Select LEFT(Cedula, 3) 
	+ '-' -- Primer guion
	+ SUBSTRING(Cedula, 4, 7) 
	+ '-' -- Segundo guion
	+ RIGHT(Cedula, 1) 
	AS [Cedula Completa]
From #CedulaTemp;
GO


-- Ejemplo con una variable
Declare @cedvar VARCHAR(11);

	Set @cedvar = '00276543210';
	Select @cedvar AS [Cedula];
	Select LEN(@cedvar) AS [LongitUd Columna];
	Select LEFT(@cedvar, 3) AS [Tres Izquierda];
	Select SUBSTRING(@cedvar, 4, 7) AS [Siete Centro];
	Select RIGHT(@cedvar, 1) AS [Ultimo Valor];

	-- Cedula completa

	Select LEFT(@cedvar, 3) 
		+ '-' -- Primer guion 
		+ SUBSTRING(@cedvar, 4, 7) 
		+ '-' -- Segundo guion 
		+ RIGHT(@cedvar, 1) 
	AS [Cedula Completa];
GO