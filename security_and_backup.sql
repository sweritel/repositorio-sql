/*
- 2 Logins.
- 2 Usuarios.
- 2 Roles personalizados.
- Asignar permisos diferentes a cada rol.
- Demostrar mediante consultas qué operaciones puede realizar cada usuario.
*/

--1..LOGIN
USE master;
GO
CREATE LOGIN login1
WITH PASSWORD = '<STRONG_PASSWORD_PLACEHOLDER_1>';
GO    

CREATE LOGIN login2
WITH PASSWORD = '<STRONG_PASSWORD_PLACEHOLDER_2>';
GO

--2. Usuarios los asociamos
USE CLASE_S05_STREAMING;
GO

CREATE USER user1 
FOR LOGIN login1;
GO

CREATE USER user2
FOR LOGIN login2;
GO

--3. Roles y --4. Asignar permisos al rol
CREATE ROLE rol1;
GO
GRANT SELECT ON Pagos TO rol1;
GO

CREATE ROLE rol2;
GO
GRANT SELECT ON Planes TO rol2;
GO

--5. Agregar los usuarios a los roles correspondientes.
ALTER ROLE rol1 ADD MEMBER user1;
GO

ALTER ROLE rol2 ADD MEMBER user2;
GO

-- Demostrar mediante consultas qué operaciones puede realizar cada usuario.
/* Si hace SELECT * FROM Usuarios con user1:
The SELECT permission was denied on the object 'Usuarios', database 'CLASE_S05_STREAMING', schema 'dbo'.

Si hace SELECT * FROM Pagos con user1:
(7 rows affected)
Completion time: 2026-07-07T10:54:06.9113933-05:00
*/


--6. Crear un Login llamado editor_streaming.
USE master;
GO
CREATE LOGIN editor_Streaming
WITH PASSWORD = '<STRONG_PASSWORD_PLACEHOLDER_EDITOR>';
GO


--7. Crear un usuario asociado al Login anterior dentro de la base de datos.
USE CLASE_S05_STREAMING;
GO
CREATE USER user01
FOR LOGIN editor_Streaming;
GO

--8. Otorgar permisos para insertar nuevos registros únicamente en la tabla Contenidos.
GRANT INSERT ON Contenidos TO user01;
GO

--9. Otorgar permisos para actualizar únicamente la tabla Usuarios.
GRANT UPDATE ON Usuarios TO user01;
GO

--10. Revocar el permiso SELECT sobre la tabla Usuarios al usuario creado.
-- para dar permisos: TO / para quitar o revocar es FROM
REVOKE SELECT ON Usuarios FROM user01;
GO

--11. Crear un rol llamado RolEdicionContenido.
CREATE ROLE RolEdicionContenido;
GO
--12. Asignar al rol permisos INSERT y UPDATE sobre la tabla Contenidos.
GRANT INSERT, UPDATE ON Contenidos TO RolEdicionContenido;
GO


--13. Agregar el usuario editor_streaming al rol creado
ALTER ROLE RolEdicionContenido ADD MEMBER user01;
GO


--14. Crear un Login llamado auditor_streaming.
USE master;
GO
CREATE LOGIN auditor_steaming
WITH PASSWORD = '<STRONG_PASSWORD_PLACEHOLDER_AUDITOR>';
GO

--15. Crear un usuario asociado al Login auditor_streaming.
USE CLASE_S05_STREAMING;
GO
CREATE USER user_1
FOR LOGIN auditor_steaming;
GO

--16. Asignar únicamente permisos SELECT sobre todas las tablas principales del sistema.
GRANT SELECT ON SCHEMA::dbo TO user_1;
GO

--17. Revocar todos los permisos otorgados al usuario que usa el login editor_streaming
REVOKE ALL ON Contenidos FROM user01;
REVOKE ALL ON Usuarios FROM user01;
GO


--18. Eliminar el usuario auditor_streaming de la base de datos.
DROP USER user_1;
GO

--19. Eliminar el Login auditor_streaming del servidor.
USE master;
GO
DROP LOGIN auditor_steaming;
GO


--20. Realizar un respaldo (Backup) de la base de datos CLASE_S05_STREAMING utilizando T-SQL.
BACKUP DATABASE CLASE_S05_STREAMING
TO DISK = 'D:\backupsql\CLASE_S05_STREAMING.bak'
WITH FORMAT,
     NAME = 'Backup Completo de CLASE_S05_STREAMING';
GO

/*
Processed 912 pages for database 'CLASE_S05_STREAMING', file 'CLASE_S05_STREAMING' on file 1.
Processed 1 pages for database 'CLASE_S05_STREAMING', file 'CLASE_S05_STREAMING_log' on file 1.
BACKUP DATABASE successfully processed 913 pages in 0.962 seconds (7.407 MB/sec).

Completion time: 2026-07-07T12:00:00.0104120-05:00
*/
