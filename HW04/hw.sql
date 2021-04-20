/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

with Sales AS 
(SELECT			
				Replace(LEFT(Sales.Customers.CustomerName,LEN(Sales.Customers.CustomerName)-1),'Tailspin Toys (','') AS CustomerName, 
				dateadd (day, -day (Sales.Invoices.InvoiceDate) + 1,Sales.Invoices.InvoiceDate) as Invoice_month,
				(Sales.InvoiceLines.Quantity )AS Quantity
FROM            Sales.Invoices INNER JOIN
				Sales.Customers ON Sales.Invoices.CustomerID IN (2,3,4,5,6) AND Sales.Invoices.CustomerID = Sales.Customers.CustomerID AND Sales.Invoices.CustomerID = Sales.Customers.CustomerID
                INNER JOIN Sales.InvoiceLines ON Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID 
)

Select FORMAT(Invoice_month,'dd.MM.yyyy') Invoice_month, "Peeples Valley, AZ", "Medicine Lodge, KS", "Gasport, NY", "Sylvanite, MT", "Jessie, ND"  from Sales
PIVOT (SUM(Quantity) FOR CustomerName IN ("Peeples Valley, AZ", "Medicine Lodge, KS", "Gasport, NY", "Sylvanite, MT", "Jessie, ND")) as pvt
ORDER BY Invoice_month

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

WITH CustomerAdr as (
SELECT        CustomerName, DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2
FROM            Sales.Customers
WHERE        (CustomerName LIKE 'Tailspin Toys%'))

SELECT unpt.CustomerName, unpt.Adr  FROM CustomerAdr as t
UNPIVOT (Adr FOR TypeAdr IN (DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2)) AS unpt

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

WITH CountriesCodes as (
SELECT C.CountryName, Convert(nvarchar,C.IsoAlpha3Code) as IsoAlpha3Code, Convert(nvarchar,C.IsoNumericCode) as IsoNumericCode
FROM Application.Countries as C)
SELECT unpt.CountryName, unpt.Code  FROM CountriesCodes as C
UNPIVOT (Code FOR TypeCode IN (IsoAlpha3Code, IsoNumericCode)) AS unpt

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT C.CustomerName, O.StockItemID, O.StockItemName, O.UnitPrice, O.InvoiceDate
FROM Sales.Customers AS C
CROSS APPLY (SELECT  TOP 2    Sales.Invoices.CustomerID, Sales.InvoiceLines.StockItemID, Warehouse.StockItems.StockItemName, Max(Sales.Invoices.InvoiceDate) as InvoiceDate, Max(Sales.InvoiceLines.UnitPrice) as UnitPrice
FROM 
Sales.Invoices INNER JOIN
	Sales.InvoiceLines 
         ON Sales.InvoiceLines.InvoiceID = Sales.Invoices.InvoiceID AND Sales.InvoiceLines.InvoiceID = Sales.Invoices.InvoiceID INNER JOIN
			Warehouse.StockItems ON Sales.InvoiceLines.StockItemID = Warehouse.StockItems.StockItemID AND Sales.InvoiceLines.StockItemID = Warehouse.StockItems.StockItemID
WHERE Sales.Invoices.CustomerID = C.CustomerID
GROUP BY Sales.Invoices.CustomerID,  Sales.InvoiceLines.StockItemID, Warehouse.StockItems.StockItemName
ORDER BY UnitPrice DESC
) AS O
