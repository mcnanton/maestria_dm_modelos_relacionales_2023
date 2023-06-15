-- 1. Enumerar las tuplas de la tabla SalesOrderHeader de tal manera que primero numere las anteriores a '2013/12/31' y después a las posteriores a esa fecha.

SELECT OrderDate, RowNumber 
FROM (
	SELECT *,
    ROW_NUMBER() OVER (PARTITION BY
        CASE WHEN soh.OrderDate <= '2013-12-31' THEN 0 ELSE 1 END
		ORDER BY soh.OrderDate) 
		AS RowNumber
FROM Sales.SalesOrderHeader soh) AS helper
---WHERE RowNumber < 10 ---Para chequear rdos

-- 2. Obtener por cada año para cada cliente el total vendido en ese año y además el total general del cliente

SELECT OrderDate, CustomerID,
SUM(TotalDue) OVER(PARTITION BY CustomerID) AS total_cliente,
SUM(TotalDue) OVER(PARTITION BY YEAR(OrderDate)) AS total_anio
FROM Sales.SalesOrderHeader 

-- 3. Obtener las 4 ordenes con mayor precio de cada mes en el año 2013. (SalesOrderHeader)

WITH helper AS 
(SELECT OrderDate, CustomerID, TotalDue, MONTH(OrderDate) as mes_orden,
ROW_NUMBER() OVER(PARTITION BY MONTH(OrderDate) ORDER BY TotalDue) as RowNumber
FROM Sales.SalesOrderHeader)
SELECT *
FROM helper
WHERE RowNumber <= 4

-- 4. En la tabla EmployeePayHistory está la historia de pago de los empleados. Obtener los valores de Rate más frecuentes.

WITH helper AS (
    SELECT Rate, Count(*) as n_apariciones
FROM HumanResources.EmployeePayHistory
GROUP BY Rate)
SELECT *,
DENSE_RANK() OVER(ORDER BY n_apariciones DESC) AS rank
FROM helper

-- 5. Obtener para cada producto la cantidad vendida y el promedio vendido de los acumulando cada 3 meses. Las tablas a consultar serían SalesOrderHeader, SalesOrderDetail y Product.

WITH 
helper AS (
SELECT MONTH(soh.OrderDate) as mes_venta, sod.ProductID, SUM(sod.OrderQty) as suma_cantidad_mes
FROM Sales.SalesOrderHeader soh, Sales.SalesOrderDetail sod 
WHERE soh.SalesOrderID = sod.SalesOrderID
GROUP BY MONTH(soh.OrderDate), sod.ProductID )
SELECT mes_venta, ProductID, suma_cantidad_mes,
AVG(suma_cantidad_mes) OVER(PARTITION BY ProductID ORDER BY mes_venta ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as promedio_3m,
SUM(suma_cantidad_mes) OVER(PARTITION BY ProductID ORDER BY mes_venta ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as suma_3m
FROM helper

-- 6. Obtener para cada cliente y para cada orden: el id del cliente, el id de la orden, la fecha de la orden, la cantidad de días desde la orden anterior y la cantidad de días hasta la próxima orden. Pista usar: DATEDIFF.

SELECT CustomerID, OrderDate, SalesOrderID,
LAG(CAST(OrderDate as DATE)) OVER(PARTITION BY CustomerID ORDER BY SalesOrderID) As PrevOrderDate,
  LEAD(CAST(OrderDate as DATE)) OVER(PARTITION BY CustomerID ORDER BY SalesOrderID) As NextOrderDate
FROM Sales.SalesOrderHeader

-- 7. Obtener para cada trimestre de cada año el total de ventas comparado con el total del año anterior. Pista 1) MONTH(OrderDate)/4 + 1 nos da el trimestre. 2) Usar CTE

WITH helper1 AS
(
SELECT YEAR (OrderDate) as anio_vta,(MONTH(OrderDate)/4 + 1) AS trimestre, COUNT(*) as total_vtas
FROM Sales.SalesOrderHeader
GROUP BY (MONTH(OrderDate)/4 + 1), YEAR (OrderDate)
),
helper2 AS
(
    SELECT *,
    LAG(total_vtas,4) OVER(ORDER BY anio_vta,  trimestre) AS PrevTrimSales
    FROM helper1
)
SELECT *,
FORMAT(total_vtas,'C') AS total_vtas,
FORMAT(PrevTrimSales,'C') AS PrevTrimSales_f,
FORMAT((total_vtas-PrevTrimSales)/PrevTrimSales,'P') AS YOY_Growth 
FROM helper2
ORDER BY anio_vta, trimestre

-- 8. Calcular el promedio de importes de las órdenes sacando los extremos (la orden de mayor importe y la de menor importe).

WITH helper AS (
SELECT SalesOrderID, TotalDue,
ROW_NUMBER() OVER(ORDER BY TotalDue) as orden_total
FROM Sales.SalesOrderHeader)
SELECT *,
AVG(TotalDue) OVER() as promedio
FROM helper
WHERE orden_total >1 
AND orden_total < (SELECT COUNT(*) FROM Sales.SalesOrderHeader)

-- 9. Obtener para cada mes del año 2013 la cantidad total de órdenes y la mediana, además el percentil.

WITH helper AS (
SELECT MONTH(OrderDate) as mes_orden, YEAR (OrderDate) as anio_orden, COUNT(*) AS total_ordenes
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013
GROUP BY MONTH(OrderDate), YEAR (OrderDate))
SELECT *,
PERCENT_RANK() OVER(ORDER BY total_ordenes) as "Percent Rank"
FROM helper