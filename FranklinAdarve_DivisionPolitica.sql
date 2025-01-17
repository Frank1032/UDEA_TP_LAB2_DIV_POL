--Ejecutar primero
DROP DATABASE DivisionPolitica WITH (FORCE);
--Ejecutar segundo
CREATE DATABASE DivisionPoliticaFranklin; 

/*
-- Consulta para conocer la estructura de una tabla
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME='Pais'

-- Consulta para conocer la estructura de los indices de una tabla	
SELECT sys.indexes.name AS Indice, 
	INFORMATION_SCHEMA.COLUMNS.COLUMN_NAME AS Campo,
	sys.indexes.is_primary_key 
	FROM INFORMATION_SCHEMA.COLUMNS INNER JOIN sys.indexes 
			ON OBJECT_ID(TABLE_NAME) = [object_id] 
		INNER JOIN sys.index_columns 
			ON sys.indexes.index_id = sys.index_columns.index_id
			AND sys.indexes.[object_id] = sys.index_columns.[object_id]
			AND ORDINAL_POSITION=column_id 
	WHERE sys.indexes.[object_id] = OBJECT_ID('Ciudad') 
	ORDER BY sys.indexes.name, 
		sys.index_columns.index_column_id,
		INFORMATION_SCHEMA.COLUMNS.COLUMN_NAME
*/

--Para las siguientes instrucciones, se debe cambiar la conexión


-------------1° PASO---------------- CREAR LAS TABLAS--------------
-- Crear tabla CONTINENTE
CREATE TABLE Continente( 
	Id SERIAL PRIMARY KEY,
	Nombre VARCHAR(50) NOT NULL
);

-- Crear indice para CONTINENTE	ordenado por NOMBRE
CREATE UNIQUE INDEX ixContinente_Nombre
	ON Continente(Nombre);

-- Crear tabla TIPOREGION
CREATE TABLE TipoRegion( 
	Id SERIAL PRIMARY KEY,
	TipoRegion VARCHAR(50) NOT NULL
);

-- Crear indice para TIPOREGION	ordenado por NOMBRE
CREATE UNIQUE INDEX ixTipoRegion_TipoRegion
	ON TipoRegion(TipoRegion);

-- Crear tabla PAIS 
CREATE TABLE Pais( 
	Id SERIAL PRIMARY KEY,
	Nombre VARCHAR(50) NOT NULL, 
	IdContinente INTEGER NOT NULL, 
	CONSTRAINT fkPais_IdContinente FOREIGN KEY (IdContinente)
		REFERENCES Continente(Id),
	IdTipoRegion INTEGER NOT NULL,
	CONSTRAINT fkPais_IdTipoRegion FOREIGN KEY (IdTipoRegion)
		REFERENCES TipoRegion(Id),
	Moneda VARCHAR(30) NULL
);

-- Crear indice para PAIS ordenado por NOMBRE
CREATE UNIQUE INDEX ixPais_Nombre
	ON Pais(Nombre);

-- Crear tabla REGION
CREATE TABLE Region( 
	Id SERIAL PRIMARY KEY,
	Nombre VARCHAR(50) NOT NULL, 
	IdPais INTEGER NOT NULL, 
	CONSTRAINT fkRegion_IdPais FOREIGN KEY (IdPais)
		REFERENCES Pais(Id),
	Area FLOAT NULL, 
	Poblacion INTEGER NULL
);

-- Crear indice para REGION	ordenado por PAIS y NOMBRE
CREATE UNIQUE INDEX ixRegion_IdPais_Nombre
	ON Region(IdPais,Nombre);
    
-- Crear tabla CIUDAD
CREATE TABLE Ciudad( 
	Id SERIAL PRIMARY KEY,
	Nombre VARCHAR(50) NOT NULL, 
	IdRegion INTEGER NOT NULL, 
	CONSTRAINT fkCiudad_IdRegion FOREIGN KEY (IdRegion)
		REFERENCES Region(Id),
	Area FLOAT NULL, 
	Poblacion INTEGER NULL,
	CapitalPais BOOLEAN DEFAULT false NOT NULL,
	CapitalRegion BOOLEAN DEFAULT false NOT NULL,
	AreaMetropolitana BOOLEAN DEFAULT false NOT NULL
);

-- Crear indice para CIUDAD	ordenado por REGION y NOMBRE 
CREATE UNIQUE INDEX ixCiudad_IdRegion_Nombre
	ON Ciudad(IdRegion,Nombre);
	
--	Creacion de Vista de Paises, Regiones y Ciudades
CREATE VIEW vwCiudades AS
	SELECT C.Id IdCiudad, C.Nombre Ciudad,
		R.Id IdRegion, R.Nombre Region,
		P.Id IdPais, P.Nombre Pais,
		C.CapitalPais, C.CapitalRegion
	FROM Pais P
		LEFT JOIN Region R ON R.IdPais=P.Id
		LEFT JOIN Ciudad C ON C.IdRegion = R.Id;
		
	--SE CREA LA TABLA DE LA MONEDA
CREATE TABLE Moneda(
	Id SERIAL PRIMARY KEY,
	Moneda VARCHAR(30) NOT NULL,
	Sigla VARCHAR (5) NULL,
	Imagen BYTEA
);


-------------------2°paso------------------- IMPORTAR LA BASE DE DATOS--------------------
-----------------------------------------------------------------------------------------------------------------------------
---PUNTO 7-------------------------
-------------------3° PASO------------- CREAR LA TABLA
-- PARA EL INDICE DE LA MONEDA 
CREATE UNIQUE INDEX ixMoneda_moneda ON Moneda(moneda);

ALTER TABLE Pais 
ADD COLUMN IdMoneda INTEGER NULL;

-- AHORA SE ACUATLIZA LA COLUMNA DE LA MONEDA QUE CORRESPONDE A CADA PAIS
UPDATE Pais
	SET IdMoneda = m.Id
	FROM Moneda m
	WHERE Pais.Moneda = m.Moneda;

--ACA SE AGREGA LA COLUMNA DEL MAPA Y LA BANDERA AL PAIS CORRESPONDE A PUNTO 7

ALTER TABLE Pais 
	ADD COLUMN Mapa BYTEA,
	ADD COLUMN Bandera BYTEA;

-- ACA SE ISERTA LAS MONEDAS EN LA NUEVA TABLA PARA TAL FIN
INSERT INTO Moneda(Moneda)
	SELECT DISTINCT Moneda FROM Pais;

--SE AGREGAN LOS VALORES DE LA ID MONEDA A CADA PAIS
UPDATE Pais
	SET IdMoneda = Moneda.Id
	FROM Moneda
WHERE Pais.Moneda = Moneda.Moneda;


--FINAL MENTE SE ELIMINA LA TABLA DE MONEDA DEL PAIS
ALTER TABLE Pais
	DROP COLUMN Moneda;
	
	
	------LISTO---------------------------------------------------------------
	-- PARA VERIFICAR ------------
SELECT *
	FROM Moneda M
		JOIN Pais P
			ON P.IdMoneda = M.Id
	
SELECT *
	FROM Continente
	
SELECT *
	FROM TipoRegion
	
SELECT *
	FROM Moneda

SELECT *
	FROM Pais
	
SELECT *
	FROM Region
	
SELECT *
	FROM Ciudad
	
SELECT * FROM Moneda
	WHERE moneda='EURO'








