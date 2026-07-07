/*
EJERCICIO 1: CURSOR DE REPORTE (READ_ONLY)
Crear un cursor que recorra la tabla Usuarios y muestre mediante un mensaje de
texto formatrado el nombre del usuario, su país y su estado actual.

Usamos un cursor aquí porque requerimos formatear y enviar mensajes individuales 
uno a uno a la consola de salida simulando un proceso de notificación secuncial.
*/

--1. DECLARACIÓN DE VARIABLES PARA ALMACENAR LOS DATOS DE LA FILA ACTUAL.
DECLARE @Nombre VARCHAR(100);
DECLARE @Pais VARCHAR(50);
DECLARE @Estado VARCHAR(20);
--2.DECLARACIÓN DEL CURSOR ESPECIFICANDO QUE SERÁ SOLO DE LECTURA.
DECLARE cur_usuarios CURSOR READ_ONLY FOR
SELECT Nombre, Pais, Estado FROM Usuarios;
--3.APERTURA DEL CURSOR.
OPEN cur_usuarios;
--4.PRIMERA LECTURA DE FILA.
FETCH NEXT FROM cur_usuarios INTO @Nombre, @Pais, @Estado;
--5.BUCLE DE RECORRIDO (Mientras existan filas por procesar).
WHILE @@FETCH_STATUS = 0
BEGIN
    --PROCESAMIENTO DE LA FILA ACTUAL.
    PRINT 'Usuario: ' + @Nombre + ' | Pais: ' + @Pais + ' | Estado: ' + @Estado;
    --LECTURA DE LAS SIGUIENTE FILA
    FETCH NEXT FROM cur_usuarios INTO @Nombre, @Pais, @Estado;
END;
--6.CIERRE DEL CURSOR Y LIBERACIÓN DE RECURSOS.
CLOSE cur_usuarios;
DEALLOCATE cur_usuarios;
GO
/*
Ejercicio 2: CURSOR CON CÁLCULO EN HISTORIAL DE REPRODUCCIÓN (READ_ONLY)
Crear un cursor que recorra las reproducciones de la plataforma, mostrando
el nombre del usuario, el título del contenido visto y que porcentaje 
de la duración total del contenido consumió en esa sesión.

Usamos cursor aquí para evaluar fila por fila la relación de consumo de 
tiempo y generar una alerta por consola si el usuario vio más del 80% del
contenido.
*/
--1.DECLARACIÓN DE VARIABLES PARA ALMACENAR LOS DATOS DE LA FILA ACTUAL.
DECLARE @Usuario VARCHAR(100);
DECLARE @Contenido VARCHAR(120);
DECLARE @MinutosVistos INT;
DECLARE @DuracionTotal INT;
DECLARE @Porcentaje INT;
--2.DECLARACIÓN DEL CURSOR ESPECIFICANDO QUE SERA SOLO DE LECTURA.
DECLARE cur_reproducciones CURSOR READ_ONLY FOR 
SELECT u.Nombre, c.Titulo, r.MinutosVistos, c.DuracionMin
FROM Reproducciones r
INNER JOIN Usuarios u ON r.UsuarioID = u.UsuarioID
INNER JOIN Contenidos c ON r.ContenidoID = c.ContenidoID;
--3.APERTURA DEL CURSOR
OPEN cur_reproducciones;
--4.PRIMERA LECTURA DE FILA
FETCH NEXT FROM cur_reproducciones
INTO @Usuario, @Contenido, @MinutosVistos, @DuracionTotal;
--5.BUCLE DE RECORRIDO(MIENTRAS EXISTAN FILAS POR PROCESAR)
WHILE @@FETCH_STATUS = 0
BEGIN
    --Evitar división por cero y calcular porcentaje.
    IF @DuracionTotal > 0
        SET @Porcentaje = (@MinutosVistos * 100) / @DuracionTotal;
    ELSE
        SET @Porcentaje = 0;
    PRINT 'El usuario: ' + @Usuario + ' vio ' + CAST(@Porcentaje AS VARCHAR(3)) + ' % de: ' + @Contenido; 
    --Lógica condicional dentro del cursor.
    IF @Porcentaje >= 80
        PRINT 'ALERTA: ¡Este cotenido enganchó al usuario por completo!';
    FETCH NEXT FROM cur_reproducciones INTO  @Usuario, @Contenido, @MinutosVistos, @DuracionTotal;
END;

CLOSE cur_reproducciones;
DEALLOCATE cur_reproducciones;
GO


/*
Ejercicio 3: CURSOR DE MODIFICACIÓN DE DATOS (SCROLL_LOCKS)
La plataforma quiere penalizar o cambiar de estado a las suscriociones inactivas o aquellas cuyo pago
está en estado  'Pendiente'. Crea un cursor que evalúe los pagos pendientes y cambie  el estado 
del usuario correspondiente a 'Inactivo' en la tabla Usuarios.
Usamos cursor aunque se puede hacer con un UPDATE masivo, el cursor nos permite bloquear los registros
durante la edición secuncial   (SCROLL_LOCKS) y registrar en texto exactamente a quiénes se les 
aplicó a suspensión administrativa en tiempo real.
*/
--1.DECLARACIÓN DE VARIABLES PARA ALMACENAR LOS DATOS DE LA FILA ACTUAL.
DECLARE @UsuarioID INT;
DECLARE @NombreUsuario VARCHAR(100);
--2.DECLARACIÓN DEL CURSOR ESPECIFICANDO QUE SERÁ DE asegurar la consistencia de los datos durante las operaciones de modificación.
DECLARE cur_suspensiones CURSOR SCROLL_LOCKS FOR
SELECT u.UsuarioID, u.Nombre FROM Pagos p INNER JOIN Suscripciones s ON p.SuscripcionID = s.SuscripcionID INNER JOIN Usuarios u ON s.UsuarioID = u.UsuarioID
WHERE p.EstadoPago = 'Pendiente'; --aqui
--3.APERTURA DE CURSOR
OPEN cur_suspensiones;
--4.PRIMERA LECTURA DE FILA
FETCH NEXT FROM cur_suspensiones INTO @UsuarioID, @NombreUsuario; --aqui (columnas del select = columnas del into posicional)
--5.BUCLE DE RECORRIDO (Mientras existan filas por recorrer)
WHILE @@FETCH_STATUS = 0
BEGIN
--Accion de actualización basada en la fila actual del cursor.
UPDATE Usuarios SET Estado = 'Inactivo' WHERE UsuarioID = @UsuarioID;
PRINT 'ADMINISTRACIÓN: El usuario ' + @NombreUsuario + ' (ID: ' + CAST(@UsuarioID AS VARCHAR(5)) + ') ha sido inactivado por falta de pago.';
FETCH NEXT FROM cur_suspensiones INTO @UsuarioID, @NombreUsuario;
END;

CLOSE cur_suspensiones;
DEALLOCATE cur_suspensiones;
GO

--Para poder observar la respuesta DEL EJERCICIO 3--
/*
UPDATE Usuarios SET Estado = 'Activo';
UPDATE Pagos SET EstadoPago='Pendiente' WHERE EstadoPago='Pagado'; 
*/

/*
EJERCICIO PROPUESTO 1

Enunciado: Desarrollar un cursor de tipo READ_ONLY que recorra la tabla Planes.
Por cada fila, debe imprimir el nombre del plan y calcular el costo por pantalla (Precio dividido entre la Cantidad de Pantallas).

*/

--1.DECLARACIÓN DE VARIABLES PARA ALMACENAR LOS DATOS DE LA FILA ACTUAL.
DECLARE @NombrePlan VARCHAR(50);
DECLARE @Precio DECIMAL(10,2);
DECLARE @CantidadPantallas INT;
DECLARE @CostoPorPantalla DECIMAL(10,2);

--2.DECLARACIÓN DEL CURSOR ESPECIFICANDO QUE SERÁ DE asegurar la consistencia de los datos durante las operaciones de modificación.
DECLARE cur_planes CURSOR READ_ONLY FOR
SELECT NombrePlan, Precio, CantidadPantallas FROM Planes;   
--3.APERTURA DE CURSOR
OPEN cur_planes;
--4.PRIMERA LECTURA DE FILA
FETCH NEXT FROM cur_planes INTO @NombrePlan, @Precio, @CantidadPantallas; --aqui (columnas del select = columnas del into posicional)
--5.BUCLE DE RECORRIDO (Mientras existan filas por recorrer)
WHILE @@FETCH_STATUS = 0
BEGIN

IF @CantidadPantallas > 0
    SET @CostoPorPantalla = @Precio/@CantidadPantallas;
ELSE
    SET @CantidadPantallas = 0;

PRINT 'PLAN: ' + @NombrePlan + ' | Precio Original: ' + CAST(@Precio AS VARCHAR(10)) + '  | COSTO POR PANTALLA: ' + CAST(@CostoPorPantalla AS VARCHAR(10));
FETCH NEXT FROM cur_planes INTO @NombrePlan, @Precio, @CantidadPantallas;
END;
CLOSE cur_planes;
DEALLOCATE cur_planes;
GO


SELECT * FROM Pagos; --MetodoPago = 'Tarjeta

DECLARE @PagoID INT;
DECLARE @MontoOriginal DECIMAL(10,2);
DECLARE @MontoConComision DECIMAL(10,2);

DECLARE cur_comisiones CURSOR READ_ONLY FOR
SELECT PagoID, Monto FROM Pagos WHERE MetodoPago = 'Tarjeta';
OPEN cur_comisiones;
FETCH NEXT FROM cur_comisiones INTO @PagoID, @MontoOriginal;
WHILE @@FETCH_STATUS = 0
BEGIN
--CALCULAMOS EL MONTO FINALSUMANDOLES EL 5% DE COMISION
--si yo quiero solo comision = monto original * 0.05
--si yo quiero sumarlo al monto original = monto original * (montoorignal * 0.05)
SET @MontoConComision = @MontoOriginal * 1.05;

PRINT 'PAGO ID: ' + CAST(@PagoID AS VARCHAR(10)) + ' |Monto Original: ' + CAST(@MontoOriginal AS  VARCHAR(10)) + 'CON COMISION: ' + CAST(@MontoConComision AS VARCHAR(10));
FETCH NEXT FROM cur_comisiones INTO @PagoID, @MontoOriginal; 
END;

CLOSE cur_comisiones;
DEALLOCATE cur_comisiones;
GO