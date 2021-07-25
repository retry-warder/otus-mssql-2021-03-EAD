SET STATISTICS TIME ON
GO
SELECT ordTotal.CustomerID 
	INTO #CUSTOMERS
	FROM Sales.Orders  AS ordTotal 
	INNER HASH JOIN Sales.OrderLines AS Total 
	On ordTotal.OrderID = Total.OrderID 
	GROUP BY ordTotal.CustomerID
	HAVING SUM(Total.UnitPrice*Total.Quantity)  > 250000

SELECT 
	N.StockItemID
	INTO #PHONE_COMPANY_StockItem
	FROM [WideWorldImporters].[Warehouse].[StockItemTransactions] AS N
	INNER JOIN Warehouse.StockItems AS T
	ON N.StockItemID = T.StockItemID
	AND T.SupplierId = 12;
CREATE NONCLUSTERED INDEX IDX_#PHONE_COMPANY_StockItem ON #PHONE_COMPANY_StockItem (StockItemID)


SELECT I.OrderID, I.BillToCustomerID, I.InvoiceDate 
INTO #Invoices
FROM   #CUSTOMERS AS C 
INNER HASH JOIN Sales.Invoices AS I ON C.CustomerID  = I.CustomerID
INNER HASH JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = I.InvoiceID 
OPTION (MAXDOP 1)
CREATE NONCLUSTERED INDEX IDX_#Invoices ON #Invoices (OrderID, InvoiceDate)

Select 
ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
FROM 
Sales.Orders AS ord
INNER HASH JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID 
INNER HASH JOIN #PHONE_COMPANY_StockItem AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
WHERE
EXISTS
(SELECT * FROM #Invoices AS Inv WHERE Inv.OrderID = ord.OrderID AND Inv.InvoiceDate =  ord.OrderDate AND Inv.BillToCustomerID != ord.CustomerID)
GROUP BY ord.CustomerID, det.StockItemID ORDER BY ord.CustomerID, det.StockItemID

DROP TABLE #CUSTOMERS
DROP TABLE #PHONE_COMPANY_StockItem
DROP TABLE #Invoices

GO
SET STATISTICS TIME OFF
