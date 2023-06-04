-- 1. Usando subconsultas, obtener Id y nombre de los productos que hayan sido vendidos durante el año 2013.

SELECT p.ProductID, p.Name
FROM Production.Product p
WHERE p.ProductID IN (
    SELECT sod.ProductID
    FROM Sales.SalesOrderDetail sod, Sales.SalesOrderHeader soh
    WHERE sod.SalesOrderID = soh.SalesOrderID
    AND YEAR(soh.OrderDate) = 2013
)

-- 2. Usando subconsultas, obtener Id y nombre de los productos que no hayan sido vendidos nunca.

SELECT p.ProductID, p.Name
FROM Production.Product p
WHERE p.ProductID NOT IN (
    SELECT sod.ProductID
    FROM Sales.SalesOrderDetail sod, Sales.SalesOrderHeader soh
    WHERE sod.SalesOrderID = soh.SalesOrderID
)

-- 3. Obtener los productos vendidos de mayor precio unitario, entre los vendidos en el año 2013.


SELECT P.Name, P.ListPrice
FROM Production.Product p
WHERE p.ListPrice = (
    SELECT MAX(pp.ListPrice)
    FROM Sales.SalesOrderDetail sod, Sales.SalesOrderHeader soh, Production.Product pp
    WHERE sod.SalesOrderID = soh.SalesOrderID
    AND sod.ProductID = pp.ProductID
    AND YEAR(soh.OrderDate) = 2013
)

-- 4. Mostrar los departamentos que tengan máxima cantidad de empleados.

SELECT edh.DepartmentID
FROM HumanResources.EmployeeDepartmentHistory edh
GROUP BY edh.DepartmentID
HAVING COUNT(*) >= ALL (
    SELECT COUNT(*)
    FROM HumanResources.EmployeeDepartmentHistory edh
    GROUP BY edh.DepartmentID
)

-- 5. Hallar los empleados que con menor antiguedad dentro de cada departamento.

SELECT p.FirstName, p.LastName, edh1.StartDate
FROM HumanResources.EmployeeDepartmentHistory edh1, Person.Person p
WHERE edh1.BusinessEntityID = p.BusinessEntityID
AND edh1.StartDate = (
    SELECT MAX (ed2.StartDate)
    FROM HumanResources.EmployeeDepartmentHistory ed2
    WHERE ed2.DepartmentID = edh1.DepartmentID
)

-- 6. Hallar las provincias que tengan más cantidad de domicilios que los que tiene la provincia con Id 58.

SELECT a.StateProvinceID
FROM Person.Address a
GROUP BY a.StateProvinceID
HAVING COUNT(*) > (
    SELECT COUNT(*)
    FROM Person.Address a2 
    WHERE a2.StateProvinceID = 58
    )

-- 7. Hallar año y mes de fechas de modificación coincidentes entre los registros de la tabla Person para el tipo de persona “EM” y los registros de la tabla Address 
--para la provincia con nombre “Washington”.

SELECT YEAR(p.ModifiedDate), MONTH(p.ModifiedDate)
FROM Person.Person p, Person.BusinessEntityAddress bea
WHERE p.BusinessEntityID = bea.BusinessEntityID
AND p.PersonType = 'EM'
AND bea.AddressID IN (
    SELECT bea2.AddressID
    FROM Person.BusinessEntityAddress bea2, Person.Address a2, Person.StateProvince st
    WHERE bea2.AddressID = a2.AddressID
    AND a2.StateProvinceID = st.StateProvinceID
    AND st.Name = 'Washington'
)

-- 8. Determinar si existen empleados y clientes con mismo Id, usando subconsultas

--- Hay coincidencia entre CustomerID y BusinessEntityID

SELECT e.BusinessEntityID
FROM HumanResources.Employee e 
WHERE e.BusinessEntityID IN (
    SELECT c.CustomerID
    FROM Sales.Customer c
)

--- Pero no entre PersonID y BusinessEntityID

SELECT e.BusinessEntityID
FROM HumanResources.Employee e 
WHERE e.BusinessEntityID IN (
    SELECT c.PersonID
    FROM Sales.Customer c
)

-- 9. Mostrar los años de las ventas registradas y de las compras registradas. Identificar para cada año, si corresponde a ventas ó a compras.


-- 10. Para la anterior consulta, ordenarla por año descendente


-- 11. Para cada venta, encontrar la denominación del producto de mayor precio total (precio x cantidad) de su propia orden.

--- CORREGIR, esto no funciona, devuelve multiples SalesOrderID
SELECT p.ProductID, p.Name, sod.SalesOrderID
FROM Sales.SalesOrderDetail sod, Production.Product p
WHERE sod.ProductID = p.ProductID
AND sod.UnitPrice = (
    SELECT MAX(sod2.UnitPrice)
    FROM Sales.SalesOrderDetail sod2
    WHERE sod2.SalesOrderID = sod.SalesOrderID
) 


-- 12. Encontrar el nombre de los productos que no pertenezcan a la subcategoría “Wheels”. Usar EXISTS.

SELECT p.Name, p.ProductSubcategoryID
FROM Production.Product p
WHERE EXISTS (
    SELECT pp.ProductID
    FROM Production.Product pp, Production.ProductSubcategory s
    WHERE pp.ProductID = p.ProductID
    AND pp.ProductSubcategoryID = s.ProductSubcategoryID
    AND s.Name <> 'Wheels'
)

-- 13. Encontrar el nombre de los productos cuyo precio de lista es mayor o igual al máximo precio de lista de cualquier subcategoría de producto.

SELECT p.ProductSubcategoryID , p.Name , p.ListPrice 	
FROM Production.Product p
WHERE p.ListPrice IN (
    SELECT MAX(p.ListPrice)
	FROM Production.Product p
	GROUP BY p.ProductSubcategoryID) 

-- 14. Encontrar los nombres de los empleados que también sean vendedores. Usar subconsultas anidadas.

SELECT p.FirstName, p.LastName
FROM HumanResources.Employee e , Person.Person p 
WHERE e.BusinessEntityID = p.BusinessEntityID
AND e.BusinessEntityID IN (
    SELECT e.BusinessEntityID 
	FROM HumanResources.Employee e
	WHERE e.JobTitle = 'Sales Representative')
