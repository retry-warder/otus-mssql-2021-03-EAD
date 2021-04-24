/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

DECLARE @sales TABLE
(InvoiceID INT, 
 CustomerName NVARCHAR(100),
 InvoiceDate DATE,
 InvoiceMonth DATE,
 Totalsum DECIMAL(18,2));

 INSERT INTO @sales 
(InvoiceID, CustomerName, InvoiceDate, InvoiceMonth, Totalsum)
SELECT        H.InvoiceID, C.CustomerName, H.InvoiceDate, dateadd (day, -day (H.InvoiceDate) + 1,H.InvoiceDate), SUM(L.UnitPrice * L.Quantity) AS TotalSum
FROM            Sales.Invoices AS H INNER JOIN
                         Sales.Customers AS C ON C.CustomerID = H.CustomerID INNER JOIN
                         Sales.InvoiceLines AS L ON H.InvoiceID = L.InvoiceID
WHERE        (YEAR(H.InvoiceDate) >= 2015)
GROUP BY H.InvoiceID, H.InvoiceDate, C.CustomerName
ORDER BY H.InvoiceDate

/*
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 63 мс, истекшее время = 70 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.
Таблица "InvoiceLines". Число просмотров 2, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 341, lob физических чтений 3, lob упреждающих чтений 778.
Таблица "InvoiceLines". Считано сегментов 1, пропущено 0.
Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Invoices". Число просмотров 1, логических чтений 292215, физических чтений 468, упреждающих чтений 7512, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Customers". Число просмотров 1, логических чтений 40, физических чтений 1, упреждающих чтений 31, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

 Время работы SQL Server:
   Время ЦП = 312 мс, затраченное время = 965 мс.

(затронуто строк: 31440)

(затронуто строк: 31440)
Таблица "#B641E07A". Число просмотров 31441, логических чтений 9558064, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 299, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

 Время работы SQL Server:
   Время ЦП = 131110 мс, затраченное время = 131260 мс.
*/

select a.InvoiceID, a.CustomerName, a.InvoiceDate, a.Totalsum, ISNULL((select sum(b.Totalsum) from @sales as b where b.InvoiceMonth <= a.InvoiceMonth),0) as Total
from  @sales as a
ORDER BY a.InvoiceDate, a.InvoiceID

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

DECLARE @sales TABLE
(InvoiceID INT, 
 CustomerName NVARCHAR(100),
 InvoiceDate DATE,
 InvoiceMonth DATE,
 Totalsum DECIMAL(18,2));

 INSERT INTO @sales 
(InvoiceID, CustomerName, InvoiceDate, InvoiceMonth, Totalsum)
SELECT        H.InvoiceID, C.CustomerName, H.InvoiceDate, dateadd (day, -day (H.InvoiceDate) + 1,H.InvoiceDate), SUM(L.UnitPrice * L.Quantity) AS TotalSum
FROM            Sales.Invoices AS H INNER JOIN
                         Sales.Customers AS C ON C.CustomerID = H.CustomerID INNER JOIN
                         Sales.InvoiceLines AS L ON H.InvoiceID = L.InvoiceID
WHERE        (YEAR(H.InvoiceDate) >= 2015)
GROUP BY H.InvoiceID, H.InvoiceDate, C.CustomerName
ORDER BY H.InvoiceDate

select S.InvoiceID, S.CustomerName, S.InvoiceDate, S.Totalsum, SUM(S.Totalsum) OVER (ORDER BY S.InvoiceMonth ) as Total
from  @sales as S
ORDER BY S.InvoiceDate, S.InvoiceID

/*
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 31 мс, истекшее время = 61 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.
Таблица "InvoiceLines". Число просмотров 2, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 341, lob физических чтений 3, lob упреждающих чтений 778.
Таблица "InvoiceLines". Считано сегментов 1, пропущено 0.
Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Invoices". Число просмотров 1, логических чтений 280437, физических чтений 601, упреждающих чтений 6448, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Customers". Число просмотров 1, логических чтений 40, физических чтений 1, упреждающих чтений 31, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

 Время работы SQL Server:
   Время ЦП = 282 мс, затраченное время = 956 мс.

(затронуто строк: 31440)

(затронуто строк: 31440)
Таблица "Worktable". Число просмотров 18, логических чтений 66879, физических чтений 0, упреждающих чтений 874, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "#B82A28EC". Число просмотров 1, логических чтений 304, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

 Время работы SQL Server:
   Время ЦП = 171 мс, затраченное время = 562 мс.
*/

--Явно, быстрее отрабатывает оконная функция

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

DECLARE @sales TABLE
(
 InvoiceMonth DATE,
 StockItemName NVARCHAR(150),
 Quantity int);

INSERT INTO @sales 
(InvoiceMonth, StockItemName, Quantity)
SELECT        dateadd (day, -day (Sales.Invoices.InvoiceDate) + 1,Sales.Invoices.InvoiceDate) as InvoiceMonth, Warehouse.StockItems.StockItemName, SUM(Sales.InvoiceLines.Quantity) AS Quantity
FROM            Sales.Invoices INNER JOIN
                         Sales.InvoiceLines ON Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID INNER JOIN
                         Warehouse.StockItems ON Sales.InvoiceLines.StockItemID = Warehouse.StockItems.StockItemID
GROUP BY dateadd (day, -day (Sales.Invoices.InvoiceDate) + 1,Sales.Invoices.InvoiceDate), Warehouse.StockItems.StockItemName
ORDER BY InvoiceMonth, StockItemName, Quantity desc

SELECT
T.InvoiceMonth, T.StockItemName, T.Quantity
FROM
(SELECT S.InvoiceMonth, S.StockItemName, S.Quantity, ROW_NUMBER() OVER (PARTITION BY S.InvoiceMonth ORDER BY S.Quantity DESC) AS StockRank
FROM @Sales as S) AS T
WHERE StockRank <=2
ORDER BY T.InvoiceMonth, T.StockItemName, T.Quantity desc

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT  StockItemID, 
		SUBSTRING(StockItemName,1,1) AS L, 
		StockItemName, Brand, 
		UnitPrice,
		TypicalWeightPerUnit,
		ROW_NUMBER() OVER (PARTITION BY SUBSTRING(StockItemName,1,1) ORDER BY StockItemName) AS StockRow,
		COUNT(StockItemID) OVER() AS StockTotal,
		COUNT(StockItemID) OVER(PARTITION BY SUBSTRING(StockItemName,1,1)) AS StockTotalRow,
		LAG(StockItemID) OVER (ORDER BY StockItemName) as Prev,
		LEAD(StockItemID) OVER (ORDER BY StockItemName) as Follow,
		ISNULL(LAG(StockItemName,2) OVER (ORDER BY StockItemName),'No items') as Prev_2,
		NTILE(30) OVER (ORDER BY TypicalWeightPerUnit)
FROM            Warehouse.StockItems
ORDER BY L, StockItemName

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/
--НЕ ПОНЯЛ КАК В ИТОГЕ ДОЛЖНО БЫТЬ
--1Й ВАРИАНТ
WITH Sales as(
SELECT        Application.People.FullName, Application.People.PersonID, Sales.Invoices.InvoiceID, Sales.Invoices.InvoiceDate, Sales.Customers.CustomerName, SUM(Sales.InvoiceLines.Quantity*Sales.InvoiceLines.UnitPrice) AS TotalSum
FROM            Sales.Invoices INNER JOIN
                         Application.People ON Sales.Invoices.SalespersonPersonID = Application.People.PersonID INNER JOIN
                         Sales.Customers ON Sales.Invoices.CustomerID = Sales.Customers.CustomerID INNER JOIN
                         Sales.InvoiceLines ON Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID
GROUP BY Application.People.FullName, Application.People.PersonID, Sales.Invoices.InvoiceID, Sales.Invoices.InvoiceDate, Sales.Customers.CustomerName)

SELECT 
	S.FullName, S.PersonID, S.InvoiceID, S.InvoiceDate, S.CustomerName, S.TotalSum, LAST_VALUE (S.CustomerName) OVER (ORDER BY S.PersonID) as Last_v
FROM Sales as S 
ORDER BY S.PersonID, S.InvoiceDate

GO
--2Й ВАРИАНТ
DECLARE @sales TABLE
(InvoiceID INT);
INSERT INTO @sales 
(InvoiceID)
SELECT T.InvoiceID FROM
(
SELECT  S.SalespersonPersonID, S.InvoiceID, S.InvoiceDate, ROW_NUMBER() OVER (PARTITION BY S.SalespersonPersonID ORDER BY S.InvoiceDate desc) AS RowNum
FROM Sales.Invoices AS S
) 
AS T
WHERE RowNum = 1

SELECT        Application.People.FullName, Application.People.PersonID, Sales.Invoices.InvoiceID, Sales.Invoices.InvoiceDate, Sales.Customers.CustomerName, SUM(Sales.InvoiceLines.Quantity*Sales.InvoiceLines.UnitPrice) AS TotalSum
FROM            Sales.Invoices INNER JOIN
						 @sales	as T ON Sales.Invoices.InvoiceID = T.InvoiceID	
						 INNER JOIN
                         Application.People ON Sales.Invoices.SalespersonPersonID = Application.People.PersonID INNER JOIN
                         Sales.Customers ON Sales.Invoices.CustomerID = Sales.Customers.CustomerID INNER JOIN
                         Sales.InvoiceLines ON Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID
GROUP BY Application.People.FullName, Application.People.PersonID, Sales.Invoices.InvoiceID, Sales.Invoices.InvoiceDate, Sales.Customers.CustomerName
/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

DECLARE @sales TABLE
(CustomerID INT,
 StockItemID INT,
 UnitPrice DECIMAL(18,2),
 InvoiceDate DATE);
INSERT INTO @sales 
(CustomerID, StockItemID, UnitPrice, InvoiceDate)
SELECT
T.CustomerID, T.StockItemID, T.UnitPrice, T.InvoiceDate
FROM
(SELECT        Sales.Invoices.CustomerID, Sales.InvoiceLines.StockItemID, Sales.InvoiceLines.UnitPrice, Sales.Invoices.InvoiceDate, Sales.Invoices.InvoiceID
			  ,ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY UnitPrice desc) AS RowNum
FROM            Sales.Invoices INNER JOIN
                         Sales.InvoiceLines ON Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID) AS T
WHERE T.RowNum <=2

SELECT 
T.CustomerID,
C.CustomerName,
T.StockItemID, 
W.StockItemName,
T.UnitPrice, 
T.InvoiceDate
FROM @sales AS T INNER JOIN Sales.Customers AS C ON T.CustomerID = C.CustomerID
INNER JOIN Warehouse.StockItems AS W ON T.StockItemID = W.StockItemID

Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 
