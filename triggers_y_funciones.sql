USE CLASE_S05_STREAMING;
GO
--EJERCICIO 1
--1.Tabla de auditoría
CREATE TABLE AuditoriaExamenUsuarios 
(
    AuditoriaID INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioID INT,
    Nombre VARCHAR(100),
    Email VARCHAR(100),
    Accion VARCHAR(20),
    Fecha DATETIME DEFAULT GETDATE()
);
GO
--2.Trigger
CREATE TRIGGER tgr_UsuarioInsertado
ON Usuarios
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditoriaExamenUsuarios (UsuarioID, Nombre, Email, Accion, Fecha)
    SELECT UsuarioID, Nombre, Email, 'INSERT', GETDATE()
    FROM inserted;
END;
GO
--3.Prueba
INSERT INTO Usuarios (Nombre, Email, Pais, FechaRegistro, Estado)
VALUES ('Diana', 'diana@mail.com', 'Perú', GETDATE(), 'Activo');

SELECT * FROM AuditoriaExamenUsuarios;
GO
--EJERCICIO 2
--1.Tabla auditoria
CREATE TABLE AuditoriaExamenPlanes 
(
    AuditoriaID INT IDENTITY(1,1) PRIMARY KEY,
    PlanID INT,
    PrecioAnterior DECIMAL(10,2),
    PrecioNuevo DECIMAL(10,2),
    FechaCambio DATETIME DEFAULT GETDATE()
);
GO

--2.Trigger
CREATE TRIGGER tgr_CambioPrecioPlanes
ON Planes
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditoriaExamenPlanes (PlanID, PrecioAnterior, PrecioNuevo, FechaCambio)
    SELECT d.PlanID, d.Precio, i.Precio, GETDATE()
    FROM deleted d
    INNER JOIN inserted i ON d.PlanID = i.PlanID
    WHERE d.Precio <> i.Precio;
END;
GO

--3.Prueba
UPDATE Planes
SET Precio = Precio + 1
WHERE PlanID = 2;

SELECT * FROM AuditoriaExamenPlanes;
GO

--EJERCICIO 3
--1.Trigger
CREATE TRIGGER tgr_NoEliminarContenidos
ON Contenidos
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Reproducciones r
        INNER JOIN deleted d
        ON r.ContenidoID = d.ContenidoID
    )
    BEGIN
        PRINT 'El contenido tiene reproducciones NO SE PUEDE BORRAR';
    END
    ELSE
    BEGIN
        DELETE FROM Contenidos
        WHERE ContenidoID IN (SELECT ContenidoID FROM deleted);
    END
END;
GO
--2.Prueba
DELETE FROM Contenidos WHERE ContenidoID = 1;
GO

--EJERCICIO 4
--1.Tabla auditoria
CREATE TABLE AuditoriaExamenEstadoUsuario
(
    AuditoriaID INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioID INT,
    Nombre VARCHAR(100),
    EstadoAnterior VARCHAR(20),
    EstadoNuevo VARCHAR(20),
    Fecha DATETIME DEFAULT GETDATE()
);
GO

--2.Trigger
CREATE TRIGGER tgr_CambioEstadoUsuario
ON Usuarios
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditoriaExamenEstadoUsuario
    (UsuarioID, Nombre, EstadoAnterior, EstadoNuevo, Fecha)
    SELECT i.UsuarioID, i.Nombre, d.Estado, i.Estado, GETDATE()
    FROM inserted i
    INNER JOIN deleted d
    ON i.UsuarioID = d.UsuarioID
    WHERE d.Estado <> i.Estado;
END;
GO

--3.Prueba
UPDATE Usuarios
SET Estado = 'Inactivo'
WHERE UsuarioID = 2;

SELECT * FROM AuditoriaExamenEstadoUsuario;
GO

--EJERCICIO 5
--1.Funcion
CREATE FUNCTION dbo.fn_ObtenerEstadoSuscripcion
(
    @UsuarioID INT
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @Estado VARCHAR(20);

    IF EXISTS (
        SELECT 1
        FROM Suscripciones
        WHERE UsuarioID = @UsuarioID
        AND Activo = 1
    )
        SET @Estado = 'Activa';
    ELSE
        SET @Estado = 'Inactiva';

    RETURN @Estado;
END;
GO

--2.Prueba
SELECT dbo.fn_ObtenerEstadoSuscripcion(1) AS EstadoSuscripcion;
GO

--EJERCICIO 6
--1.Funcion
CREATE FUNCTION dbo.fn_ClasificarContenidoPorDuracion
(
    @Duracion INT
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @Resultado VARCHAR(20);

    IF @Duracion < 60
        SET @Resultado = 'Corto';
    ELSE IF @Duracion <= 120
        SET @Resultado = 'Medio';
    ELSE
        SET @Resultado = 'Largo';

    RETURN @Resultado;
END;
GO

--2.Prueba
SELECT Titulo, DuracionMin,
dbo.fn_ClasificarContenidoPorDuracion(DuracionMin) AS Clasificacion
FROM Contenidos;
GO

--EJERCICIO 7
--1.Funcion
CREATE FUNCTION dbo.fn_HistorialUsuario
(
    @UsuarioID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        u.UsuarioID,
        u.Nombre,
        c.Titulo,
        c.Tipo,
        c.Categoria,
        r.FechaReproduccion
    FROM Reproducciones r
    INNER JOIN Usuarios u ON r.UsuarioID = u.UsuarioID
    INNER JOIN Contenidos c ON r.ContenidoID = c.ContenidoID
    WHERE u.UsuarioID = @UsuarioID
);
GO
--2.Prueba
SELECT * FROM dbo.fn_HistorialUsuario(1);
GO
--EJERCICIO 8
--1.Funcion
CREATE FUNCTION dbo.fn_ContenidosPorCategoriaYTipo
(
    @Categoria VARCHAR(50),
    @Tipo VARCHAR(30)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        ContenidoID,
        Titulo,
        Tipo,
        Categoria,
        DuracionMin
    FROM Contenidos
    WHERE Categoria = @Categoria
    AND Tipo = @Tipo
);
GO
--2.Prueba
SELECT * FROM dbo.fn_ContenidosPorCategoriaYTipo('Drama', 'Serie');
GO

--EJERCICIO 9
DECLARE @Titulo VARCHAR(120);
DECLARE @Duracion INT;
DECLARE @Clasificacion VARCHAR(20);

DECLARE cursor_contenidos CURSOR FOR
SELECT Titulo, DuracionMin
FROM Contenidos;

OPEN cursor_contenidos;

FETCH NEXT FROM cursor_contenidos INTO @Titulo, @Duracion;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Clasificacion =
    CASE
        WHEN @Duracion < 60 THEN 'Corto'
        WHEN @Duracion <= 120 THEN 'Medio'
        ELSE 'Largo'
    END;

    PRINT @Titulo + ' - ' + @Clasificacion;

    FETCH NEXT FROM cursor_contenidos INTO @Titulo, @Duracion;
END;

CLOSE cursor_contenidos;
DEALLOCATE cursor_contenidos;
GO

--EJERCICIO 10
DECLARE @Nombre VARCHAR(100);

DECLARE cursor_suscripciones CURSOR FOR
SELECT u.Nombre
FROM Usuarios u
INNER JOIN Suscripciones s ON u.UsuarioID = s.UsuarioID
WHERE s.Activo = 1;

OPEN cursor_suscripciones;

FETCH NEXT FROM cursor_suscripciones INTO @Nombre;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'El usuario ' + @Nombre + ' tiene una suscripción activa.';

    FETCH NEXT FROM cursor_suscripciones INTO @Nombre;
END;

CLOSE cursor_suscripciones;
DEALLOCATE cursor_suscripciones;
GO