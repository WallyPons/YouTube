-- Crear prueba rápida

-- 1. Crear prueba rápida

-- a. Drop table (if exists)
DROP TABLE IF EXISTS #ValidarCedula;

-- b. Create local temp table
CREATE TABLE #ValidarCedula
(
    Usuario VARCHAR(25),
    Cedula CHAR(11)
);

-- c. Insert fake data
INSERT INTO #ValidarCedula
(
    [Usuario],
    [Cedula]
)
VALUES
('Usuario1', '00000000000'),
('Usuario2', '00000000001');

-- d. Select data
Select * From #ValidarCedula;


USE [DB_DEMO]
GO

CREATE OR ALTER FUNCTION dbo.fn_ValidaCedula
(
    @Cedula CHAR(11)
)
RETURNS BIT
AS
BEGIN
    -- 1. Validar longitud
    
	SET @Cedula = REPLACE(@Cedula, '-', '');

	IF LEN(@Cedula) <> 11
        RETURN 0;

    -- 2. Declarar variables
    DECLARE @Sum INT = 0;
    DECLARE @i INT = 1;
    DECLARE @Digit INT;
    DECLARE @Multiplier INT;
    DECLARE @Product INT;

    WHILE @i <= 10
    BEGIN
        -- a. Alternar multiplicador
        SET @Multiplier = CASE WHEN @i % 2 = 1 THEN 1 ELSE 2 END;

        -- b. Digito en posición i
        SET @Digit = CONVERT(INT, SUBSTRING(@Cedula, @i, 1));

        -- c. Producto y suma
        SET @Product = @Digit * @Multiplier;

        -- d. Ajuste si producto > 9
        IF @Product < 10
            SET @Sum += @Product;
        ELSE
            SET @Sum += (@Product % 10) + 1;

        SET @i += 1;
    END

    -- 3. Calcular y validar dígito verificador
    DECLARE @ExpectedCheckDigit INT = (10 - (@Sum % 10)) % 10;
    DECLARE @ActualCheckDigit INT = CONVERT(INT, RIGHT(@Cedula, 1));

    RETURN CASE WHEN @ExpectedCheckDigit = @ActualCheckDigit THEN 1 ELSE 0 END;
END


/*
-- Probar la función:

-- One Liner
SELECT dbo.fn_ValidaCedula('00000000000') AS [¿Es Valida?];

SELECT dbo.fn_ValidaCedula('00000000001') AS [¿Es Valida?];

-- Tabla
SELECT	Top 10 Usuario, Cedula, 
		CASE  
		WHEN dbo.fn_ValidaCedula(Cedula) = 1 Then 'Cédula Valida'
		WHEN dbo.fn_ValidaCedula(Cedula) != 1 Then 'Cédula Invalida'
		END AS [¿Es valida?]
FROM #ValidarCedula;

*/