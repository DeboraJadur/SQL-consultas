CREATE TABLE DEPA (
	Cod_departamento INTEGER PRIMARY KEY,
  	Descripcion VARCHAR(255),
  	Gerente INTEGER,
  	Cod_Dep_Padre INTEGER,
  	FOREIGN KEY (Cod_Dep_Padre) REFERENCES DEPA (Cod_departamento)
);

CREATE TABLE EMP (
	Cod_Empleado INTEGER PRIMARY KEY,
    Nombre VARCHAR(255),
    Apellido VARCHAR(255),
    Direccion VARCHAR(255),
    Codigo_Postal VARCHAR(10),
    Cod_Departamento INTEGER,
    Sueldo_basico REAL,
    Fecha_ingreso DATE,
    Fecha_nacimiento DATE,
    Telefono INTEGER,
    Jefe INTEGER,
    FOREIGN KEY (Cod_Departamento) REFERENCES DEPA (Cod_departamento),
    FOREIGN KEY (Jefe) REFERENCES EMP (Cod_Empleado)
);

CREATE TABLE ART (
	Cod_Articulo INTEGER PRIMARY KEY,
 	Descripcion VARCHAR(255),
  	Tipo_Articulo CHAR(1) CHECK (Tipo_Articulo IN ('A', 'B', 'C')),
  	Precio REAL
);

CREATE TABLE DEP (
	Cod_deposito INTEGER PRIMARY KEY,
  	Ubicacion_deposito VARCHAR(255)
);

CREATE TABLE ART_DEP (
	Cod_Articulo INTEGER,
  	Cod_Deposito INTEGER,
  	Stock_actual INTEGER,
  	Punto_Reorden INTEGER,
  	PRIMARY KEY (Cod_Articulo, Cod_Deposito),
 	FOREIGN KEY (Cod_Articulo) REFERENCES ART (Cod_Articulo),
  	FOREIGN KEY (Cod_Deposito) REFERENCES DEP (Cod_deposito)
);

CREATE TABLE CLI (
	Cod_Cliente INTEGER PRIMARY KEY,
  	Razon_Social VARCHAR(255),
  	Direccion VARCHAR(255)
);

CREATE TABLE PED (
	Nro_pedido INTEGER PRIMARY KEY,
  	Cod_Cliente INTEGER,
  	Cod_Empleado INTEGER,
  	Fecha_pactada_entrega DATE,
  	Fecha_real_entrega DATE,
  	Deposito_entrega INTEGER,
  	FOREIGN KEY (Cod_Cliente) REFERENCES CLI (Cod_Cliente),
  	FOREIGN KEY (Cod_Empleado) REFERENCES EMP (Cod_Empleado),
  	FOREIGN KEY (Deposito_entrega) REFERENCES DEP (Cod_deposito)
);

CREATE TABLE DET (
	Nro_pedido INTEGER,
  	Cod_articulo INTEGER,
  	Cantidad INTEGER,
  	PRIMARY KEY (Nro_pedido, Cod_articulo),
  	FOREIGN KEY (Nro_pedido) REFERENCES PED (Nro_pedido),
  	FOREIGN KEY (Cod_articulo) REFERENCES ART (Cod_Articulo)
);


--1. 	Recuperar los números de pedidos y los nombres de los clientes para los pedidos que
--		vencen mañana. La fecha de entrega representa la fecha en que vence el plazo
--		comprometido con el cliente ( AR) 
SELECT p.Nro_pedido, c.Razon_Social FROM PED p JOIN CLI c on p.Cod_Cliente = c.Cod_Cliente WHERE (Fecha_pactada_entrega = '2024-04-29')

-- 2. 	Recuperar los renglones de todos los pedidos, incluyendo la descripción del artículo
SELECT PED.*, DET.Cantidad, ART.Descripcion 
FROM PED 
JOIN DET ON DET.Nro_pedido = PED.Nro_pedido
JOIN ART ON DET.Cod_articulo = ART.Cod_Articulo

--3. 	Calcular para cada renglón de pedido el costo del mismo (total de renglón más 21% de IVA).
SELECT DET.*, ART.Descripcion, ART.Precio*1.21*DET.Cantidad Total FROM DET JOIN ART ON DET.Cod_articulo = ART.Cod_Articulo

--4. 	Listar los datos de los artículos que se encuentren a menos de un 10% de su punto de reorden.
SELECT Cod_Articulo, Cod_Deposito, Stock_actual, Punto_Reorden from ART_DEP WHERE (Stock_actual < Punto_Reorden*0.1)

--5.	5. Recuperar los apellidos de los empleados (sin repeticiones). 
SELECT DISTINCT Apellido FROM EMP

--6. Recuperar todos los números de los clientes cuyo nombre empiece con M. 
SELECT Cod_Cliente FROM CLI WHERE (Razon_Social LIKE 'M%')

--7. Recuperar todos los datos de los empleados de apellido Perez. 
SELECT * FROM EMP WHERE (Apellido = 'Perez')
SELECT * FROM EMP WHERE (Apellido LIKE 'Perez')

--8. Recuperar los números de los pedidos que compraron el artículo, 2, 4, 6,8 ó 10 ( AR) 
SELECT Nro_pedido, Cod_articulo FROM DET WHERE Cod_articulo = 2 OR Cod_articulo = 54 OR Cod_articulo = 6 OR Cod_articulo = 8 OR Cod_articulo = 10
SELECT Nro_pedido, Cod_articulo FROM DET WHERE Cod_articulo IN (2,54)
SELECT * FROM DET

--9. Listar los artículos cuyo precio esté entre 20.000 y 50.000. 
SELECT * FROM ART WHERE 20 < Precio AND Precio < 50

--10. Listar los pedidos que vencen la semana próxima. 
SELECT *
FROM PED
WHERE Fecha_pactada_entrega BETWEEN GETDATE() 
                               AND DATEADD(DAY, 7, GETDATE());

--11. Recuperar los pedidos para los cuales no se informó el cliente. 
SELECT * FROM PED WHERE Cod_Cliente IS null
SELECT * FROM PED

--12. Recuperar los artículos cuya primera letra sea una R o una T y que luego continúan con S500. 
SELECT * FROM ART WHERE Descripcion like '[R,T]%S500%'
SELECT * FROM ART

--13. Recuperar los nombres de los diferentes artículos que tienen pedidos. ( AR) 
SELECT a.Descripcion FROM ART a WHERE Cod_articulo IN (SELECT DET.Cod_articulo FROM DET)

--14. Recuperar los artículos que nunca fueron pedidos. ( AR) 
SELECT a.Descripcion FROM ART a WHERE Cod_articulo NOT IN (SELECT DET.Cod_articulo FROM DET)

--15. Recuperar el nombre de los empleados que no efectuaron ningún pedido esta semana. (AR) 
SELECT e.Nombre FROM EMP e WHERE e.Cod_Empleado NOT IN (SELECT p.Cod_Empleado FROM PED p)

--16. Crear una tabla con nuevos pedidos. Listar los pedidos “viejos” y los nuevos 
CREATE TABLE NUEVOS_PED (
	Nro_pedido INTEGER PRIMARY KEY,
  	Cod_Cliente INTEGER,
  	Cod_Empleado INTEGER,
  	Fecha_pactada_entrega DATE,
  	Fecha_real_entrega DATE,
  	Deposito_entrega INTEGER,
  	FOREIGN KEY (Cod_Cliente) REFERENCES CLI (Cod_Cliente),
  	FOREIGN KEY (Cod_Empleado) REFERENCES EMP (Cod_Empleado),
  	FOREIGN KEY (Deposito_entrega) REFERENCES DEP (Cod_deposito)
);

INSERT INTO NUEVOS_PED (Nro_pedido, Cod_Cliente, Cod_Empleado, Fecha_pactada_entrega, Fecha_real_entrega, Deposito_entrega)
VALUES
(1001, 1, 1, '2024-06-18', NULL, 1),
(1002, 2, 2, '2024-06-19', NULL, 2),
(1003, 3, 3, '2024-06-20', NULL, 3);

SELECT * FROM PED UNION (SELECT * from NUEVOS_PED)

--17. Listar todos los pedidos de la tabla anterior ordenados por fecha de entrega decreciente 
SELECT * FROM PED UNION (SELECT * from NUEVOS_PED) ORDER BY Fecha_pactada_entrega DESC

--18. Recuperar el total de sueldos y el promedio de sueldos para cada departamento. 
SELECT DEPA.Descripcion, SUM(EMP.Sueldo_basico) as TOTAL, AVG(EMP.Sueldo_basico) AS Promedio
FROM EMP
JOIN
	DEPA ON EMP.Cod_Departamento = DEPA.Cod_departamento
GROUP BY DEPA.Cod_Departamento, DEPA.Descripcion

--19. Recuperar el costo total de cada pedido.
SELECT DET.*,ART.Descripcion, ART.Precio FROM DET JOIN ART ON DET.Cod_articulo = ART.Cod_Articulo ORDER BY DET.Nro_pedido

SELECT DET.Nro_pedido, SUM(ART.Precio * DET.Cantidad) as TOTAL_PEDIDO from DET
JOIN
	ART ON DET.Cod_articulo = ART.Cod_Articulo
GROUP BY DET.Nro_pedido

--20. Recuperar el total de unidades de cada artículo que hay que entregar la próxima semana. 
SELECT * FROM PED

SELECT ART.Descripcion, SUM(DET.Cantidad) FROM DET
JOIN
	ART ON DET.Cod_articulo = ART.Cod_Articulo
JOIN
	PED ON DET.Nro_pedido = PED.Nro_pedido
	WHERE 
    	PED.Fecha_pactada_entrega BETWEEN GETDATE() 
                               AND DATEADD(DAY, 7, GETDATE())
GROUP BY ART.Descripcion

SELECT 
    det.Cod_articulo, 
    SUM(det.Cantidad) AS totalunidades
FROM 
    DET
JOIN 
    PED ON DET.Nro_pedido = PED.Nro_pedido
WHERE  
    fecha_pactada_entrega BETWEEN DATEADD(day,7,GETDATE()) AND DATEADD(DAY, 14, GETDATE())
GROUP BY 
    det.Cod_articulo;

--21. Recuperar los datos de los empleados que tienen más de 3 pedidos pendientes de entrega. 
SELECT * FROM PED
SELECT EMP.*, COUNT(PED.Cod_Empleado) AS Total_Pedidos FROM PED
JOIN
	EMP ON PED.Cod_Empleado = EMP.Cod_Empleado
WHERE
	PED.Fecha_real_entrega IS NULL
GROUP BY
	EMP.Cod_Empleado, 
    EMP.Nombre, 
    EMP.Apellido, 
    EMP.Direccion, 
    EMP.Codigo_Postal, 
    EMP.Cod_Departamento, 
    EMP.Sueldo_basico, 
    EMP.Fecha_ingreso, 
    EMP.Fecha_nacimiento, 
    EMP.Telefono, 
    EMP.Jefe
HAVING COUNT(PED.Cod_Empleado) > 3

--22. Recuperar la cantidad de pedidos para cada empleado indicando el código y el nombre del mismo. 
SELECT * from PED ORDER BY PED.Cod_Empleado
SELECT EMP.Cod_Empleado, EMP.Nombre, EMP.Apellido, COUNT(PED.Nro_pedido) as Cantidad_Pedidos FROM EMP
JOIN
	PED on EMP.Cod_Empleado = PED.Cod_Empleado
GROUP BY EMP.Cod_Empleado, EMP.Nombre, EMP.Apellido

--23. Recuperar la cantidad pedida pendiente de entrega para cada artículo. 
SELECT PED.Nro_pedido, ART.Descripcion, DET.Cantidad from PED 
JOIN
	DET ON PED.Nro_pedido = DET.Nro_pedido
JOIN
	ART ON DET.Cod_articulo = ART.Cod_Articulo
WHERE
	PED.Fecha_real_entrega IS NULL
ORDER BY ART.Descripcion

SELECT DET.Cod_articulo, ART.Descripcion, SUM(DET.Cantidad) from PED
JOIN
	DET ON PED.Nro_pedido = DET.Nro_pedido
JOIN
	ART ON DET.Cod_articulo = ART.Cod_Articulo
WHERE
	PED.Fecha_real_entrega IS NULL
GROUP BY DET.Cod_articulo, ART.Descripcion

--24. Recuperar los departamentos para los cuales el promedio de sueldo de sus empleados sea superior a 3000. 
SELECT DEPA.Cod_departamento, DEPA.Descripcion, AVG(EMP.Sueldo_basico) AS Sueldo_Promedio FROM DEPA
JOIN
	EMP ON DEPA.Cod_departamento = EMP.Cod_Departamento
GROUP BY DEPA.Cod_departamento, DEPA.Descripcion
HAVING AVG(EMP.Sueldo_basico) > 3000

--25. Recuperar los artículos para los cuales la cantidad pendiente de entrega supere el stock.
--Los pedidos pendientes de entrega son los que no tienen informado el campo fecha_real_entrega.
SELECT ART.Descripcion, SUM(DET.Cantidad) as Cantidad,ART_DEP.Cod_Deposito, ART_DEP.Stock_actual from PED
JOIN
	DET ON PED.Nro_pedido = DET.Nro_pedido
JOIN
	ART ON DET.Cod_articulo = ART.Cod_Articulo
JOIN
	ART_DEP ON PED.Deposito_entrega = ART_DEP.Cod_Deposito
WHERE
	PED.Fecha_real_entrega IS NULL
GROUP BY ART.Descripcion, ART_DEP.Stock_actual,ART_DEP.Cod_Deposito
HAVING SUM(DET.Cantidad) > ART_DEP.Stock_actual

--26. Insertar en la tabla Empleados un empleado con todos sus datos. 
INSERT INTO EMP (Cod_Empleado, Nombre, Apellido, Direccion, Codigo_Postal, Cod_Departamento, Sueldo_basico, Fecha_ingreso, Fecha_nacimiento, Telefono, Jefe)
VALUES
(100,'Joaquin', 'Gutierrez', 'Damian 266', '7601',2,10000, '2024-06-12', '1995-10-13', '235462295',NULL)

--27. Insertar en la tabla Empleados un empleado indicando su código de empleado, su nombre
--y nulos o defaults en el resto de sus campos.
INSERT INTO EMP (Cod_Empleado, Nombre, Apellido)
VALUES
(101, 'Debora','Jadur')

--28. Elegir un empleado y actualizar su domicilio. 
Select * FROM EMP WHERE Cod_Empleado = 101

UPDATE EMP
SET Direccion = 'Italia'
WHERE Cod_Empleado = 101

--29. Agregar los empleados de la tabla Nuevos_empleados a la tabla Empleados. La tabla
--nuevos_empleados tiene la misma estructura que la tabla Empleados. 
CREATE TABLE NUEVOS_EMP (
	Cod_Empleado INTEGER PRIMARY KEY,
    Nombre VARCHAR(255),
    Apellido VARCHAR(255),
    Direccion VARCHAR(255),
    Codigo_Postal VARCHAR(10),
    Cod_Departamento INTEGER,
    Sueldo_basico REAL,
    Fecha_ingreso DATE,
    Fecha_nacimiento DATE,
    Telefono INTEGER,
    Jefe INTEGER,
    FOREIGN KEY (Cod_Departamento) REFERENCES DEPA (Cod_departamento),
    FOREIGN KEY (Jefe) REFERENCES EMP (Cod_Empleado)
);
INSERT INTO NUEVOS_EMP (Cod_Empleado, Nombre, Apellido, Direccion, Codigo_Postal, Cod_Departamento, Sueldo_basico, Fecha_ingreso, Fecha_nacimiento, Telefono, Jefe)
VALUES
(1000,'Joaquin', 'Gutierrez', 'Damian 266', '7601',2,10000, '2024-06-12', '1995-10-13', '235462295',NULL)

SELECT * FROM EMP

INSERT INTO EMP
SELECT * FROM NUEVOS_EMP;

--30. Eliminar todos los empleados con código postal 9999 
SELECT * from EMP WHERE codigo_postal = '9999'

DELETE FROM EMP WHERE Codigo_Postal = '9999'

--31. Dar de alta 3 artículos del tipo C con todos sus datos y uno del tipo B, indicando para este
--último un stock de 2126 unidades. 
INSERT INTO ART (Cod_Articulo, Descripcion, Tipo_Articulo, Precio)
VALUES
(100, 'Mesa','C',4399.99),
(101, 'Silla','C',2499.99),
(102, 'Plato','C',499.99),
(103, 'Televisor','B',25499.99)

INSERT INTO ART_DEP (Cod_Articulo, Cod_Deposito, Stock_actual, Punto_Reorden)
VALUES
(100, 1, 10,5),
(101,1,4,10),
(102,1,10,20),
(103,1,2126,2126)
--32. Todos los artículos del tipo C pasaron a formar parte del tipo A. Actualizar la tabla con 1
--instrucción. 
UPDATE ART SET tipo_articulo = 'A' WHERE tipo_articulo = 'C'

--33. Restar 268 unidades al stock de los artículos de tipo B 
UPDATE ART_DEP 
SET stock_actual = stock_actual - 268
WHERE
	cod_articulo IN (
      SELECT 
      	cod_articulo 
      from 
      	ART 
      WHERE 
      	tipo_articulo = 'B'
    )

--34. Aumentar en un 5,5% el precio de los artículos del grupo A 
UPDATE ART
SET precio = precio * 1.055
WHERE
	tipo_articulo = 'A'
    
--35. Disminuir en un 10% el precio de los artículos con el mayor stock. 
UPDATE ART
SET precio = precio*0.9
WHERE
	cod_articulo IN (
    SELECT
      cod_articulo
   	FROM
      ART_DEP
    WHERE
      stock_actual = (
        SELECT MAX(stock_actual)
        FROM ART_DEP
      )
    )

--36. Aumentar un 20% el sueldo básico de los empleados con el menor sueldo básico. 
UPDATE EMP
SET sueldo_basico = sueldo_basico * 1.2
WHERE
	sueldo_basico = (
    	SELECT MIN(sueldo_basico)
      	FROM EMP
    )
    
--37. Aumentar un 15% a los empleados con más de 20 años en la empresa. 
UPDATE EMP
SET sueldo_basico = sueldo_basico * 1.15
WHERE
	DATEDIFF(YEAR, Fecha_ingreso, GETDATE()) > 20

--38. Aumentar en $500,00 el sueldo de los jefes de departamento que tengan el menor sueldo
--básico.
SELECT * from EMP WHERE cod_empleado IN (SELECT gerente from DEPA)

UPDATE EMP
SET cod_empleado = 102
WHERE cod_empleado = 100
 
UPDATE EMP
SET sueldo_basico = sueldo_basico + 500
WHERE
	cod_empleado IN (
      SELECT gerente from DEPA)
   	AND (
    	sueldo_basico = (
        	SELECT MIN(sueldo_basico)
      		FROM EMP
        )
    )

--39. Actualizar el precio de todos los artículos que no tienen pedidos reduciéndolo en un 10% 
SELECT * from ART WHERE cod_articulo NOT IN (SELECT cod_articulo FROM DET)
UPDATE ART
SET precio = precio * 0.9
WHERE
	cod_articulo NOT IN (
    	SELECT cod_articulo FROM DET
    )

--40. Borrar todos los artículos cuyo stock es 0 y nunca han tenido pedidos. 
DELETE from ART
WHERE
	cod_articulo NOT IN (
    	SELECT cod_articulo from DET
    ) 
    AND (
    	cod_articulo IN (
        	SELECT cod_articulo FROM ART_DEP
          	WHERE stock_actual = 0
        )
    )

--41. Recuperar los artículos cuya descripción tiene al comienzo la sílaba MA y luego continúa
--con S550 ó S750. 
SELECT * FROM ART WHERE descripcion LIKE 'MA%S[57]50%'

--42. Listar el sotck de los artículos cuya primera sílaba es ME o TE y luego continúan con R200
--o R980. 

