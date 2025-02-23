--
-- Tenga en cuenta adaptar la ruta de creación acorde a la configuración de su servidor SQL Server
--
CREATE DATABASE buynlarge
ON PRIMARY
(
    NAME = buynlarge, -- Nombre lógico del archivo de datos
    FILENAME = 'C:\Ruta\MiBaseDeDatos.mdf', -- Ruta física del archivo de datos
    SIZE = 10MB, -- Tamaño inicial del archivo de datos
    MAXSIZE = 50MB, -- Tamaño máximo del archivo de datos
    FILEGROWTH = 5MB -- Incremento automático del archivo de datos
)
LOG ON
(
    NAME = MiBaseDeDatos_Log, -- Nombre lógico del archivo de registro
    FILENAME = 'C:\Ruta\MiBaseDeDatos_Log.ldf', -- Ruta física del archivo de registro
    SIZE = 5MB, -- Tamaño inicial del archivo de registro
    MAXSIZE = 50MB, -- Tamaño máximo del archivo de registro
    FILEGROWTH = 2MB -- Incremento automático del archivo de registro
);

USE [buynlarge]
GO

CREATE TABLE [dbo].[Productos](
    [ID] [int] IDENTITY(1,1) NOT NULL,
    [Nombre] [nvarchar](100) NOT NULL,
    [Marca] [nvarchar](50) NULL,
    [Descripcion] [nvarchar](max) NULL,
    [Precio] [decimal](18, 2) NOT NULL,
    [Stock] [int] NOT NULL,
    [Categoria] [nvarchar](50) NULL,
    PRIMARY KEY CLUSTERED
(
[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    GO

    USE [buynlarge]
    GO

CREATE TABLE [dbo].[Ventas](
    [ID] [int] IDENTITY(1,1) NOT NULL,
    [ProductoID] [int] NULL,
    [Cantidad] [int] NOT NULL,
    [FechaVenta] [datetime] NOT NULL,
    PRIMARY KEY CLUSTERED
(
[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY]
    GO

ALTER TABLE [dbo].[Ventas]  WITH CHECK ADD FOREIGN KEY([ProductoID])
    REFERENCES [dbo].[Productos] ([ID])
    GO