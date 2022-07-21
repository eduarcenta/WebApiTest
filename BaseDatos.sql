CREATE DATABASE testDB
GO
USE testDB
GO

IF OBJECT_ID('[dbo].Personas', 'U') IS NOT NULL 
  DROP TABLE dbo.Personas;  
GO

GO
CREATE TABLE dbo.Personas
	(
	Identificacion varchar(13) NOT NULL,
	Nombres varchar(200) NOT NULL,
	Genero int NOT NULL,
	FechaNacimiento date NOT NULL,
	Direccion varchar(150) NULL,
	Telefono varchar(13) NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Personas ADD CONSTRAINT
	PK_Personas PRIMARY KEY CLUSTERED 
	(
	Identificacion
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO


IF OBJECT_ID('[dbo].Clientes', 'U') IS NOT NULL 
  DROP TABLE dbo.Clientes;  
GO

GO
CREATE TABLE dbo.Clientes
	(
	Id int NOT NULL IDENTITY (1, 1),
	Contrasena varchar(100) NOT NULL,
	Estado bit NOT NULL,
	Identificacion varchar(13) NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Clientes ADD CONSTRAINT
	PK_Clientes PRIMARY KEY CLUSTERED 
	(
	Id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.Clientes ADD CONSTRAINT
	FK_Clientes_Personas FOREIGN KEY
	(
	Identificacion
	) REFERENCES dbo.Personas
	(
	Identificacion
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO

GO

IF OBJECT_ID('[dbo].Cuentas', 'U') IS NOT NULL 
  DROP TABLE dbo.Cuentas;  
GO

CREATE TABLE dbo.Cuentas
	(
	NumeroCuenta varchar(15) NOT NULL,
	TipoCuenta int NOT NULL,
	SaldoInicial decimal(10, 2) NOT NULL,
	SaldoDisponible decimal(10, 2) NOT NULL,
	Estado bit NOT NULL,
	ClienteId int NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Cuentas ADD CONSTRAINT
	PK_Cuentas_1 PRIMARY KEY CLUSTERED 
	(
	NumeroCuenta
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.Cuentas ADD CONSTRAINT
	FK_Cuentas_Clientes FOREIGN KEY
	(
	ClienteId
	) REFERENCES dbo.Clientes
	(
	Id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO

IF OBJECT_ID('[dbo].Movimientos', 'U') IS NOT NULL 
  DROP TABLE dbo.Movimientos;  
GO

GO
CREATE TABLE dbo.Movimientos
	(
	Id int NOT NULL IDENTITY (1, 1),
	Fecha datetime NOT NULL,
	TipoMovimiento int NOT NULL,
	Valor decimal(10, 2) NOT NULL,
	Saldo decimal(10, 2) NOT NULL,
	NumeroCuenta varchar(15) NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Movimientos ADD CONSTRAINT
	PK_Movimientos PRIMARY KEY CLUSTERED 
	(
	Id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.Movimientos ADD CONSTRAINT
	FK_Movimientos_Cuentas FOREIGN KEY
	(
	NumeroCuenta
	) REFERENCES dbo.Cuentas
	(
	NumeroCuenta
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO


IF OBJECT_ID('[dbo].EstadoCuenta', 'V') IS NOT NULL 
  DROP TABLE dbo.EstadoCuenta;  
GO

CREATE TRIGGER dbo.trgInsertMovimiento 
   ON dbo.Movimientos
   AFTER INSERT, UPDATE
AS   
BEGIN
	SET NOCOUNT ON;
	UPDATE dbo.Cuentas SET SaldoDisponible = inserted.Saldo
	FROM inserted
	WHERE dbo.Cuentas.NumeroCuenta = inserted.NumeroCuenta;
END;
GO

CREATE VIEW EstadoCuenta--(Fecha, Cliente, NumeroCuenta, Tipo, SaldoInicial, Estado, Valor, SaldoDisponible, Identificacion)
AS 
   SELECT Fecha,Nombres as Cliente, Movimientos.NumeroCuenta as NumeroCuenta, TipoMovimiento as Tipo, 
		IIF(TipoMovimiento=0,Saldo - Valor, Saldo + Valor) as SaldoInicial, Cuentas.Estado as Estado, 
		Valor, SaldoDisponible, Clientes.Identificacion as Identificacion
   FROM Movimientos INNER JOIN Cuentas ON Movimientos.NumeroCuenta = Cuentas.NumeroCuenta
   INNER JOIN Clientes ON Clientes.Id = Cuentas.ClienteId
   INNER JOIN Personas ON Personas.Identificacion = Clientes.Identificacion
GO