============================================================
PARTE 1. CREACIÓN DE LA BASE DE DATOS Y TABLAS
============================================================

-- Reiniciar la base de datos si ya existe
IF DB_ID('CLASE_S05_STREAMING') IS NOT NULL
BEGIN
    ALTER DATABASE CLASE_S05_STREAMING SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CLASE_S05_STREAMING;
END
GO

CREATE DATABASE CLASE_S05_STREAMING;
GO

USE CLASE_S05_STREAMING;
GO

CREATE TABLE Usuarios (
    UsuarioID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Pais VARCHAR(50) NOT NULL,
    FechaRegistro DATE NOT NULL,
    Estado VARCHAR(20) NOT NULL DEFAULT 'Activo'
);
GO

CREATE TABLE Planes (
    PlanID INT IDENTITY(1,1) PRIMARY KEY,
    NombrePlan VARCHAR(50) NOT NULL,
    Precio DECIMAL(10,2) NOT NULL,
    CantidadPantallas INT NOT NULL
);
GO

CREATE TABLE Suscripciones (
    SuscripcionID INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioID INT NOT NULL,
    PlanID INT NOT NULL,
    FechaInicio DATE NOT NULL,
    FechaFin DATE NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID),
    FOREIGN KEY (PlanID) REFERENCES Planes(PlanID)
);
GO

CREATE TABLE Contenidos (
    ContenidoID INT IDENTITY(1,1) PRIMARY KEY,
    Titulo VARCHAR(120) NOT NULL,
    Tipo VARCHAR(30) NOT NULL,
    Categoria VARCHAR(50) NOT NULL,
    Anio INT NOT NULL,
    DuracionMin INT NOT NULL,
    Disponible BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE Reproducciones (
    ReproduccionID INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioID INT NOT NULL,
    ContenidoID INT NOT NULL,
    FechaReproduccion DATE NOT NULL,
    MinutosVistos INT NOT NULL,
    FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID),
    FOREIGN KEY (ContenidoID) REFERENCES Contenidos(ContenidoID)
);
GO

CREATE TABLE Pagos (
    PagoID INT IDENTITY(1,1) PRIMARY KEY,
    SuscripcionID INT NOT NULL,
    FechaPago DATE NOT NULL,
    Monto DECIMAL(10,2) NOT NULL,
    MetodoPago VARCHAR(50) NOT NULL,
    EstadoPago VARCHAR(20) NOT NULL,
    FOREIGN KEY (SuscripcionID) REFERENCES Suscripciones(SuscripcionID)
);
GO

============================================================
PARTE 2. INSERCIÓN DE DATOS INICIALES
============================================================

INSERT INTO Planes (NombrePlan, Precio, CantidadPantallas)
VALUES
('Básico', 19.90, 1),
('Estándar', 29.90, 2),
('Premium', 44.90, 4);
GO

INSERT INTO Usuarios (Nombre, Email, Pais, FechaRegistro, Estado)
VALUES
('Carlos Mendoza', 'carlos.mendoza@email.com', 'Perú', '2025-01-10', 'Activo'),
('María Torres', 'maria.torres@email.com', 'Perú', '2025-01-15', 'Activo'),
('Luis Ramírez', 'luis.ramirez@email.com', 'Chile', '2025-02-01', 'Activo'),
('Ana Gómez', 'ana.gomez@email.com', 'Colombia', '2025-02-12', 'Activo'),
('Pedro Salazar', 'pedro.salazar@email.com', 'Perú', '2025-03-05', 'Inactivo'),
('Lucía Fernández', 'lucia.fernandez@email.com', 'México', '2025-03-20', 'Activo'),
('Jorge Castillo', 'jorge.castillo@email.com', 'Perú', '2025-04-01', 'Activo'),
('Valeria Rojas', 'valeria.rojas@email.com', 'Argentina', '2025-04-18', 'Activo');
GO

INSERT INTO Suscripciones (UsuarioID, PlanID, FechaInicio, FechaFin, Activo)
VALUES
(1, 2, '2025-01-10', NULL, 1),
(2, 3, '2025-01-15', NULL, 1),
(3, 1, '2025-02-01', NULL, 1),
(4, 2, '2025-02-12', NULL, 1),
(5, 1, '2025-03-05', '2025-04-05', 0),
(6, 3, '2025-03-20', NULL, 1),
(7, 2, '2025-04-01', NULL, 1),
(8, 1, '2025-04-18', NULL, 1);
GO

INSERT INTO Contenidos (Titulo, Tipo, Categoria, Anio, DuracionMin, Disponible)
VALUES
('Código Final', 'Película', 'Acción', 2022, 120, 1),
('La Base Perdida', 'Serie', 'Drama', 2021, 45, 1),
('Risas en Casa', 'Serie', 'Comedia', 2023, 30, 1),
('Misterio Andino', 'Película', 'Suspenso', 2024, 110, 1),
('Planeta Azul', 'Documental', 'Documental', 2020, 60, 1),
('Amor de Verano', 'Película', 'Romance', 2021, 95, 1),
('Tecnología del Futuro', 'Documental', 'Tecnología', 2023, 70, 1),
('Zona de Riesgo', 'Serie', 'Acción', 2024, 50, 1),
('Cocina Fácil', 'Serie', 'Cocina', 2022, 25, 1),
('La Última Señal', 'Película', 'Ciencia Ficción', 2025, 130, 1);
GO

INSERT INTO Reproducciones (UsuarioID, ContenidoID, FechaReproduccion, MinutosVistos)
VALUES
(1, 1, '2025-04-01', 120),
(1, 2, '2025-04-03', 40),
(2, 3, '2025-04-04', 30),
(2, 4, '2025-04-06', 100),
(3, 5, '2025-04-07', 60),
(4, 1, '2025-04-08', 80),
(4, 6, '2025-04-09', 95),
(6, 7, '2025-04-10', 70),
(7, 8, '2025-04-11', 50),
(8, 10, '2025-04-12', 130),
(1, 8, '2025-04-15', 45),
(2, 10, '2025-04-16', 100);
GO

INSERT INTO Pagos (SuscripcionID, FechaPago, Monto, MetodoPago, EstadoPago)
VALUES
(1, '2025-04-10', 29.90, 'Tarjeta', 'Pagado'),
(2, '2025-04-15', 44.90, 'Yape', 'Pagado'),
(3, '2025-04-20', 19.90, 'Tarjeta', 'Pendiente'),
(4, '2025-04-22', 29.90, 'Transferencia', 'Pagado'),
(6, '2025-04-25', 44.90, 'Tarjeta', 'Pagado'),
(7, '2025-04-28', 29.90, 'Yape', 'Pagado'),
(8, '2025-04-30', 19.90, 'Tarjeta', 'Pendiente');
GO
