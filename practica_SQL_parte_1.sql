-- 1. Mostrar el contenido de la tabla Person, del esquema Person.

SELECT *
FROM Person.Person


-- 2. Mostrar los nombres y apelllido de cada persona que tenga como tratamiento “Ms.”

SELECT p.FirstName, p.LastName
FROM Person.Person p
WHERE p.Title = 'Ms.'

-- 3. Mostrar el Id y apellido de las personas que se los llame como “Mr.” y su apellido sea “White”.

SELECT p.BusinessEntityID, p.LastName
FROM Person.Person p
WHERE p.Title = 'Ms.' AND p.LastName = 'White'

-- 4. ¿Cuáles son los tipos de personas existentes en la tabla?

SELECT DISTINCT(p.PersonType)
FROM Person.Person p

-- 5. Mostrar los datos de las personas que tengan asignado el tipo “SP” ó el tipo “VC”.

SELECT *
FROM Person.Person p
WHERE p.PersonType = 'SP' OR p.PersonType = 'VC'

-- 6. Mostrar el contenido de la tabla Employee, del esquema HumanResources

SELECT *
FROM HumanResources.Employee

-- 7. Hallar el Id y fecha de nacimiento de los empleados que tengan como función “Research and Development Manager” y que tengan menos de 10 “VacationHours”.

SELECT e.BusinessEntityID, e.BirthDate
FROM HumanResources.Employee e
WHERE e.JobTitle = 'Research and Development Manager'
AND e.VacationHours < 10

-- 8. ¿Cuáles son los tipos de “género” que figuran en la tabla de empleados?

SELECT DISTINCT(e.Gender)
FROM HumanResources.Employee e

-- 9. Mostrar el id, nombres, apellido de los empleados ordenados desde el de fecha de nacimiento más antigua.

SELECT e.BusinessEntityID, p.FirstName, p.LastName
FROM HumanResources.Employee e, Person.Person p
WHERE E.BusinessEntityID = p.BusinessEntityID
ORDER BY e.BirthDate ASC

-- 10.Mostrar el contenido de la tabla Departments

SELECT *
From HumanResources.Department d

-- 11.¿Cuáles son los departamentos que están agrupados como “Manufacturing” ó como “Quality Assurance”?

SELECT *
From HumanResources.Department d
WHERE d.GroupName = 'Manufacturing' OR d.GroupName = 'Quality Assurance'

-- 12.¿Cuáles son los datos de los departamentos cuyo nombre esté relacionado con “Production”?

SELECT *
From HumanResources.Department d
WHERE d.Name LIKE '%Production%'

-- 13.Mostrar los datos de los departamentos que no estén agrupados como “Research and Develpment”

SELECT *
From HumanResources.Department d
WHERE d.GroupName != 'Research and Development'

-- 14.Mostrar los datos de la tabla Product del esquema Production

SELECT *
FROM Production.Product p

-- 15.Hallar los productos que no tengan asignado color.

SELECT *
FROM Production.Product p
WHERE p.Color IS NULL

-- 16.Para todos los productos que tengan asignado algún color y que tengan un stock (SafetyStockLevel) mayor a 900, mostrar su id, nombre y color. Ordernarlo por id descendente y por color ascendente. 

SELECT p.ProductID, p.Name, p.Color
FROM Production.Product p
WHERE p.Color IS NOT NULL
AND p.SafetyStockLevel > 900
ORDER BY p.ProductID DESC

-- 17.Hallar el Id y el nombre de los productos cuyo nombre comience con “Chain”

SELECT p.ProductID, p.Name
FROM Production.Product p
WHERE p.Name LIKE 'Chain%'

-- 18.Hallar el Id y el nombre de los productos cuyo nombre contenga “helmet”

SELECT p.ProductID, p.Name
FROM Production.Product p
WHERE p.Name LIKE '%helmet%'

-- 19.Modificar la consulta anterior para que retorne aquellos productos cuyo nombre no contenga “helmet”

SELECT p.ProductID, p.Name
FROM Production.Product p
WHERE p.Name NOT LIKE '%helmet%'

-- 20.Mostrar los datos principales de las personas (tabla Person) cuyo LastName termine con “es” y contenga en total 5 caracteres.

SELECT p.BusinessEntityID, p.FirstName, p.LastName
FROM Person.Person p
WHERE p.LastName LIKE '%es'
AND LEN(p.LastName) = 5

-- 21.Usando la tabla SpecialOffer del esquema Sales, mostrar la diferencia entre MinQty y MaxQty, con el id y descripción.

SELECT so.SpecialOfferID, so.Category, (so.MaxQty - so.MinQty) as 'dif'
FROM Sales.SpecialOffer so

-- 22.¿Cómo el motor resuelve la anterior consulta cuando no tiene asignado valor MinQty ó MaxQty?

--- Devuelve un NULL 

-- 23.Para resolver el problema anterior, usar la función ISNULL para, cuando no tengan asignado valor, reemplazarlo - en el cálculo – por 0 (cero).

SELECT so.SpecialOfferID, so.Category, (ISNULL(so.MaxQty, 0) - isnull(so.MinQty, 0)) as 'dif'
FROM Sales.SpecialOffer so

-- 24.¿Cuántos clientes están almacenados en la tabla Customers?

SELECT COUNT(c.CustomerID) as 'n_clientes'
FROM Sales.Customer c

-- 25. ¿Cuál es la cantidad de clientes por tienda? 

SELECT c.StoreID, COUNT(c.CustomerID) as 'n_clientes'
FROM Sales.Customer c
GROUP BY c.StoreID

---Y cuál es la cantidad de clientes por territorio para aquellos territorios que tengan más de 100 clientes? 

SELECT c.StoreID, COUNT(c.CustomerID) as n_clientes
FROM Sales.Customer c
GROUP BY c.StoreID
HAVING COUNT(*) > 100

--- Opc b rebuscada

SELECT *
FROM (
    SELECT c.StoreID, COUNT(*) AS n_clientes
    FROM Sales.Customer c
    GROUP BY c.StoreID
) AS subquery
WHERE n_clientes > 5

---¿Cuáles son las tiendas (su Id) asociadas al territorio Id 4 que tienen menos de 2 clientes?

SELECT c.StoreID, COUNT(c.CustomerID) as n_clientes
FROM Sales.Customer c
WHERE c.TerritoryID = 4 -- Se ejecuta antes que el group by
GROUP BY c.StoreID
HAVING COUNT(*) < 2

-- 26.Para la tabla SalesOrderDetail del esquema Sales, calcular cuál es la cantidad total de items ordenados (OrderQty) para el producto con Id igual a 778.

SELECT sod.ProductID, SUM(sod.OrderQty) as n_productos
FROM Sales.SalesOrderDetail sod
WHERE sod.ProductID = 778
GROUP BY sod.ProductID

-- 27.Usando la misma tabla,

--- a) Cuál es el precio unitario más caro vendido?

SELECT MAX(sod.UnitPrice) as precio_mas_caro
FROM Sales.SalesOrderDetail sod

--- b) Cuál es el número total de items ordenado para cada producto?

SELECT sod.ProductID, SUM(sod.OrderQty) as n_items_ordenados
FROM Sales.SalesOrderDetail sod
GROUP BY sod.ProductID

--- c) Cuál es la cantidad de líneas de cada orden?

SELECT sod.SalesOrderID, SUM(sod.LineTotal) as n_lineas_orden
FROM Sales.SalesOrderDetail sod
GROUP BY sod.SalesOrderID