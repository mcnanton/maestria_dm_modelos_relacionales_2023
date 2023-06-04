-- 1. La tabla Employee no contiene el nombre de los empleados. Ese dato se encuentra en la tabla Person. La columna que relaciona ambas tablas es BusinessEntityID

--- a) Si existe una FK entre ambas tablas, cómo podemos corroborar su existencia?

---- Hacer un AED sobre ambas tablas. BusinessEntityID está presente en ambas, posee la misma estructura y tipo de datos.
---- También veo que el resultado de estas 2 querys es idéntico, por lo que todas las ids de Employee se encuentran en Person
SELECT Count(*)
FROM HumanResources.Employee e 
WHERE e.BusinessEntityID IN (SELECT BusinessEntityID FROM Person.Person)

SELECT COUNT(*)
FROM HumanResources.Employee, 

--- b) Obtener el nombre, apellido, cargo y fecha de nacimiento de todos los empleados.

SELECT p.FirstName, p.LastName, e.JobTitle, e.BirthDate
FROM HumanResources.Employee e LEFT OUTER JOIN Person.Person p
ON e.BusinessEntityID = p.BusinessEntityID

--- c) Obtener el nombre y apellido de los empleados que nacieron durante el año 1986 y su “género” es F.

SELECT p.FirstName, p.LastName
FROM HumanResources.Employee e LEFT OUTER JOIN Person.Person p
ON e.BusinessEntityID = p.BusinessEntityID
WHERE YEAR(e.BirthDate) = 1986 AND e.Gender = 'F'

--- d) Contar la cantidad de empleados cuyo nombre comience con la letra “J” y hayan nacido después del año 1977.

SELECT COUNT(*)
FROM HumanResources.Employee e LEFT OUTER JOIN Person.Person p
ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.FirstName LIKE 'J%' AND YEAR(e.BirthDate) > 1977

--- e) Para las mismas condiciones del punto anterior, cuántos empleados están registrados según su género?

SELECT e.Gender, COUNT(*)
FROM HumanResources.Employee e LEFT OUTER JOIN Person.Person p
ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.FirstName LIKE 'J%' AND YEAR(e.BirthDate) > 1977
GROUP BY e.Gender

-- 2. La tabla Customers tampoco contiene el nombre de los clientes. La columna que las relaciona es, PersonID

--- a) Obtener nombre, apellido, storeId para aquellos clientes que estén en el TerritoryID = 4 ó que pertenezcan al tipo de persona 4 (PersonType)

SELECT p.FirstName, p.LastName, p.PersonType, c.StoreID
FROM Sales.Customer c, Person.Person p
WHERE c.PersonID = p.BusinessEntityID
AND (c.TerritoryID = 4 OR p.PersonType = '4')

--- b) ¿cuáles son el nombre, apellido y número de orden de venta (SaleOrderID) para los clientes que pertenecen al tipo de persona 4?

SELECT p.FirstName, p.LastName, soh.SalesOrderID, p.PersonType
FROM Sales.Customer c, Person.Person p, Sales.SalesOrderHeader soh
WHERE c.PersonID = p.BusinessEntityID AND c.CustomerID = soh.CustomerID
AND p.PersonType = '4'
---- Esto devuelve 0 porque no existe PersonType 4, es char

-- 3. La tabla Product contiene los productos y la tabla ProductModel, los modelos.

--- a) Encontrar la descripción del producto, su tamaño y la descripción del modelo relacionado, para aquellos productos que no tengan color indicado 
--- y para los cuales el nivel seguro de stock (SafetyStockLevel) sea menor estricto a 1000.

SELECT p.Name, p.Size, pm.Name as modelo
FROM Production.Product p, Production.ProductModel pm
WHERE p.ProductModelID = pm.ProductModelID
AND p.Color IS NULL
AND p.SafetyStockLevel < 1000

--- b) Obtener todas las ventas de los meses de junio y julio del 2011. Mostrar el nombre y apellido del cliente, el nro de venta, su fecha, nombre y modelo del producto vendido.

SELECT soh.SalesOrderID
FROM Sales.SalesOrderHeader soh, Sales.Customer c, Person.Person p
WHERE soh.CustomerID = c.CustomerID
AND c.PersonID = p.BusinessEntityID
AND (MONTH(soh.OrderDate)= 6 OR MONTH(soh.OrderDate) = 7) 
AND YEAR(soh.OrderDate)= 2011 

-- 4. Mostrar todos la descripción de los productos y el id de la orden de venta. Incluir aquellos productos que nunca se hayan vendido.

SELECT soh.SalesOrderID, p.Name
FROM Production.Product p, Sales.SalesOrderHeader soh, Sales.SalesOrderDetail sod
WHERE soh.SalesOrderID = sod.SalesOrderID
AND sod.ProductID = p.ProductID

-- 5. Mostrar la descripción de los productos que nunca hayan sido vendidos.

SELECT p.Name, p.ProductID
FROM Production.Product p
WHERE p.ProductID NOT IN (
    SELECT soh.ProductID
    FROM sales.SalesOrderDetail soh)

--- Opc b

SELECT p.Name, p.ProductID
FROM Production.Product p
LEFT JOIN Sales.SalesOrderDetail soh 
ON p.ProductID = soh.ProductID
AND soh.ProductID IS NULL

-- 6. En la tabla SalesPerson se modelan los vendedores. Mostrar el id de todos los vendedores junto al id de la venta, para aquellas con numero de revisión igual a 9 
--y que se hayan vendido en el 2013. Incluir a aquellos vendedores que no hayan efectuados ventas.

SELECT sp.BusinessEntityID, soh.SalesOrderID
FROM Sales.SalesPerson sp
LEFT OUTER JOIN (
    SELECT s.SalesPersonID, s.SalesOrderID
    FROM Sales.SalesOrderHeader s
    WHERE s.RevisionNumber = 9
    AND YEAR(s.OrderDate) = 2013) AS soh
ON sp.BusinessEntityID = soh.SalesPersonID

-- 7. Modificar la resolución del punto anterior para agregar el nombre del vendedor, que se encuentra en la tabla Person.

SELECT sp.BusinessEntityID, soh.SalesOrderID, p.FirstName, p.LastName
FROM Sales.SalesPerson sp
LEFT OUTER JOIN (
    SELECT pp.FirstName, pp.LastName, pp.BusinessEntityID
    FROM Person.Person pp
) as p
ON sp.BusinessEntityID = p.BusinessEntityID
LEFT OUTER JOIN (
    SELECT s.SalesPersonID, s.SalesOrderID
    FROM Sales.SalesOrderHeader s
    WHERE s.RevisionNumber = 9
    AND YEAR(s.OrderDate) = 2013) AS soh
ON sp.BusinessEntityID = soh.SalesPersonID

-- 8. Mostrar todas los valores de BusinessEntityID de la tabla SalesPerson junto a cada valor ProductID de la tabla Product
--- Interpreto que pide los ID de todos los vendedores junto a los ID de los productos vendidos. Si no vendió, no figurará en la tabla. Lo resuelvo via inner join.

SELECT sp.BusinessEntityID, pr.ProductID
FROM Sales.SalesPerson sp, Production.Product pr, Sales.SalesOrderHeader soh, Sales.SalesOrderDetail sod
WHERE soh.SalesPersonID = sp.BusinessEntityID
AND soh.SalesOrderID = sod.SalesOrderID
AND sod.ProductID = pr.ProductID

-- 9. Calcular para los tipos de contacto, cuántas personas asociadas están registradas. Ordenar el resultado por cantidad, descendente. (esquema Person)

SELECT COUNT(*)
FROM Person.ContactType ct, Person.Person p, Person.BusinessEntityContact bec 
WHERE ct.ContactTypeID = bec.ContactTypeID
AND bec.PersonID = p.BusinessEntityID -- Me confunde por qué bec tiene tanto BusinessEntityID como PersonID
GROUP BY CT.Name
ORDER BY COUNT(*) DESC

-- 10. Mostrar nombre y apellido de los empleados del estado de “Oregon” (esquemas Person y HumanResources)

SELECT p.FirstName, p.LastName
FROM HumanResources.Employee e, Person.BusinessEntityAddress bea, Person.Person  p, Person.Address a, Person.StateProvince sp
WHERE e.BusinessEntityID = bea.BusinessEntityID
AND p.BusinessEntityID = e.BusinessEntityID
AND bea.AddressID = a.AddressID
AND a.StateProvinceID = sp.StateProvinceID
AND sp.Name = 'Oregon'

-- 11. Calcular la suma de las ventas (SalesQuota) históricas por persona y año. Mostrar el apellido de la persona. (esquemas Sales (SalesPersonQuotaHistory) y Person)

--- Manera a, desprolija 

SELECT soh.SalesPersonID, p.LastName, COUNT(soh.SalesOrderID) as total_vtas,  YEAR(SOH.OrderDate) as anio
FROM Sales.SalesOrderHeader soh, Person.Person p, Sales.SalesPersonQuotaHistory h
WHERE soh.SalesPersonID = p.BusinessEntityID
AND h.BusinessEntityID = soh.SalesPersonID
GROUP BY soh.SalesPersonID, p.LastName, YEAR(SOH.OrderDate)

--- Manera b, devuelve los rdos en distinto orden

SELECT sub.SalesPersonID, p.LastName, sub.total_vtas, sub.anio
FROM Person.Person p
LEFT OUTER JOIN (
    SELECT soh.SalesPersonID, COUNT(soh.SalesOrderID) as total_vtas,  YEAR(SOH.OrderDate) as anio
    FROM Person.Person p, Sales.SalesOrderHeader soh, Sales.SalesPersonQuotaHistory h
    WHERE soh.SalesPersonID = p.BusinessEntityID
    AND h.BusinessEntityID = soh.SalesPersonID
    GROUP BY soh.SalesPersonID, p.LastName, YEAR(SOH.OrderDate)
)  sub
ON p.BusinessEntityID = sub.SalesPersonID

-- 12. Calcular el total vendido por territorio, para aquellos que tengan más de 100 ventas a nivel producto. Considerar precio unitario y cantidad vendida. (esquema Sales)
--- Interpreto que la consigna refiere a territorios que hayan vendido mas de 100 unidades de un producto cualquiera
--- Y que "total vendido" es el total de productos vendidos

SELECT DISTINCT(soh.TerritoryID)
FROM Sales.SalesOrderHeader soh
WHERE soh.TerritoryID IN (
    SELECT soh.TerritoryID
    FROM Sales.SalesOrderHeader soh, Sales.SalesOrderDetail sod
    WHERE soh.SalesOrderID = sod.SalesOrderID
    GROUP BY soh.TerritoryID, sod.ProductID
    HAVING COUNT(*) > 100
)
--- Esto da que todos los territorios vendieron al menos 100 unidades de un mismo producto

-- 13. Mostrar para cada provincia (id y nombre), la cantidad de domicilios que tenga registrados, sólo para aquellas provincias que tengan más de 1000 domicilios.

SELECT sp.StateProvinceID, sp.Name
FROM Person.StateProvince sp
WHERE sp.StateProvinceID IN (
    SELECT sp.StateProvinceID
    FROM Person.BusinessEntityAddress bea, Person.StateProvince sp, Person.Address a
    WHERE bea.AddressID = a.AddressID
    AND a.StateProvinceID = sp.StateProvinceID
    GROUP BY sp.StateProvinceID
    HAVING COUNT(*) > 1000
)


