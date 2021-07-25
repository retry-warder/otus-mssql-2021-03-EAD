Select 
ord.CustomerID, det.StockItemID, det.UnitPrice, det.Quantity, ord.OrderID
INTO #ord
FROM 
Sales.Orders AS ord
INNER HASH JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID 
INNER HASH JOIN Warehouse.StockItems AS SI ON SI.StockItemID = det.StockItemID AND SI.SupplierId = 12
INNER HASH JOIN Sales.Invoices AS Inv  ON Inv.OrderID = ord.OrderID
INNER HASH JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
WHERE
Inv.BillToCustomerID != ord.CustomerID 
AND Inv.InvoiceDate =  ord.OrderDate --DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) убрал т.к. все равно тип данных date, так, что выражение не имеет смысла
AND (SELECT SUM(Total.UnitPrice*Total.Quantity) FROM Sales.OrderLines AS Total INNER HASH JOIN Sales.Orders AS ordTotal On ordTotal.OrderID = Total.OrderID WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000 
CREATE NONCLUSTERED INDEX IDX_#ord ON [dbo].[#ord] (StockItemID)

SELECT T.CustomerID, T.StockItemID, SUM(T.UnitPrice), SUM(T.Quantity), COUNT(T.OrderID) FROM #ord AS T
INNER JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = T.StockItemID
GROUP BY T.CustomerID, T.StockItemID ORDER BY T.CustomerID, T.StockItemID

DROP TABLE #ord

--ИЛИ

Select 
ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
FROM 
Sales.Orders AS ord
INNER HASH JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID 
INNER JOIN Warehouse.StockItems AS SI ON SI.SupplierId = 12 AND SI.StockItemID = det.StockItemID
INNER HASH JOIN Sales.Invoices AS Inv  
ON Inv.OrderID = ord.OrderID
INNER HASH JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
INNER HASH JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
WHERE
Inv.BillToCustomerID != ord.CustomerID
AND
Inv.InvoiceDate =  ord.OrderDate  --DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) убрал т.к. все равно тип данных date, так, что выражение не имеет смысла
AND
(SELECT SUM(Total.UnitPrice*Total.Quantity) FROM Sales.OrderLines AS Total INNER HASH JOIN Sales.Orders AS ordTotal On ordTotal.OrderID = Total.OrderID WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
GROUP BY ord.CustomerID, det.StockItemID ORDER BY ord.CustomerID, det.StockItemID
OPTION (MAXDOP 1)
