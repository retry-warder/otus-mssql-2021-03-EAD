/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/


DECLARE @dml AS NVARCHAR(MAX),
		@ColumnName AS NVARCHAR(MAX),
		@ReplaceVal AS NVARCHAR(MAX),
		@Id AS NVARCHAR(MAX)

DECLARE	@Id_Customers table(value int)
insert into @Id_Customers (value) values (2), (3), (4), (5), (6)

SET @ReplaceVal = 'Tailspin Toys ('

SELECT @ColumnName = ISNULL(@ColumnName + ',','') + 
		QUOTENAME(Replace(LEFT(T.CustomerName,LEN(T.CustomerName)-1),@ReplaceVal,''),'"') 
		FROM Sales.Customers AS T INNER JOIN @Id_Customers AS C ON C.value = T.CustomerID;

SELECT @Id = ISNULL(@Id + ',','') + STR(C.value) FROM @Id_Customers AS C

SET @dml =
N'with Sales AS 
(SELECT			
				Replace(LEFT(Sales.Customers.CustomerName,LEN(Sales.Customers.CustomerName)-1),' + QUOTENAME(@ReplaceVal,'''') + ','''') AS CustomerName, 
				dateadd (day, -day (Sales.Invoices.InvoiceDate) + 1,Sales.Invoices.InvoiceDate) as Invoice_month,
				(Sales.InvoiceLines.Quantity )AS Quantity
FROM            Sales.Invoices INNER JOIN
				Sales.Customers ON Sales.Invoices.CustomerID IN (' + @Id + ') AND Sales.Invoices.CustomerID = Sales.Customers.CustomerID AND Sales.Invoices.CustomerID = Sales.Customers.CustomerID
                INNER JOIN Sales.InvoiceLines ON Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID 
)

Select FORMAT(Invoice_month,' +  QUOTENAME('dd.MM.yyyy','''') + ') as Invoice_month, ' + @ColumnName + '  from Sales
PIVOT (SUM(Quantity) FOR CustomerName IN (' + @ColumnName + ')) as pvt
ORDER BY Invoice_month'

EXEC sp_executesql @dml
