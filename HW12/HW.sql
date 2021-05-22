/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

USE [WideWorldImporters]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION Sales.CustomerMaxSumma()
RETURNS NVARCHAR(150)
WITH EXECUTE AS OWNER
AS
BEGIN
RETURN
	(SELECT TOP 1	Sales.Customers.CustomerName
		FROM		Sales.Invoices INNER JOIN
                    Sales.InvoiceLines ON Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID INNER JOIN
                    Sales.Customers ON Sales.Invoices.CustomerID = Sales.Customers.CustomerID
		GROUP BY Sales.Customers.CustomerID, Sales.Customers.CustomerName
	ORDER BY SUM(Sales.InvoiceLines.Quantity*Sales.InvoiceLines.UnitPrice) DESC)
END
GO

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

USE WideWorldImporters;  
GO  
CREATE PROCEDURE Sales.CustomerSumma     
    @CustomerID int   
AS   
SET NOCOUNT ON;  
SELECT	SUM(Sales.InvoiceLines.Quantity*Sales.InvoiceLines.UnitPrice) as SUMMA
FROM	Sales.Invoices INNER JOIN
        Sales.InvoiceLines ON Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID INNER JOIN
        Sales.Customers ON Sales.Invoices.CustomerID = Sales.Customers.CustomerID
WHERE	Sales.Customers.CustomerID = @CustomerID
RETURN
GO 

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

USE [WideWorldImporters]
GO
CREATE FUNCTION Sales.F_CustomerSumma(@CustomerID int)
RETURNS DECIMAL(18,2)
WITH EXECUTE AS OWNER
AS
BEGIN
RETURN
	(SELECT	SUM(Sales.InvoiceLines.Quantity*Sales.InvoiceLines.UnitPrice) as SUMMA
FROM	Sales.Invoices INNER JOIN
        Sales.InvoiceLines ON Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID INNER JOIN
        Sales.Customers ON Sales.Invoices.CustomerID = Sales.Customers.CustomerID
WHERE	Sales.Customers.CustomerID = @CustomerID)
END
GO
USE WideWorldImporters;  
GO  

CREATE PROCEDURE Sales.P_CustomerSumma     
    @CustomerID int   
AS   
SET NOCOUNT ON;  
SELECT	SUM(Sales.InvoiceLines.Quantity*Sales.InvoiceLines.UnitPrice) as SUMMA
FROM	Sales.Invoices INNER JOIN
        Sales.InvoiceLines ON Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID INNER JOIN
        Sales.Customers ON Sales.Invoices.CustomerID = Sales.Customers.CustomerID
WHERE	Sales.Customers.CustomerID = @CustomerID
RETURN
GO 

--Сервер не держит в буффере предыдущие запуски функций, в отличии от процедур, поэтому хранимые процедуры обычно выполняются быстрее, чем обычные SQL-инструкции.
--Код процедур компилируется один раз при первом ее запуске, а затем сохраняется в скомпилированной форме.

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

CREATE FUNCTION Sales.Invoices_for_customer(@customerid int)  
RETURNS TABLE  
AS  
RETURN  
(SELECT	Sales.Invoices.InvoiceID, Sales.Invoices.InvoiceDate, SUM(Sales.InvoiceLines.Quantity*Sales.InvoiceLines.UnitPrice) as SUMMA
FROM	Sales.Invoices INNER JOIN
        Sales.InvoiceLines ON Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID INNER JOIN
        Sales.Customers ON Sales.Invoices.CustomerID = Sales.Customers.CustomerID
WHERE	Sales.Customers.CustomerID = @CustomerID
GROUP BY Sales.Invoices.InvoiceID, Sales.Invoices.InvoiceDate
)
GO

--Может быть не правильно понял задание, но на ум пришло только такое решение

SELECT T.CustomerID, T.CustomerName, S.InvoiceID, S.InvoiceDate, S.SUMMA
FROM  Sales.Customers as T
CROSS APPLY Sales.Invoices_for_customer(T.CustomerID) AS S
ORDER BY T.CustomerID, S.InvoiceDate

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/

--READ COMITTED
