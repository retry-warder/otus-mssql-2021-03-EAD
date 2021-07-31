use WideWorldImporters;

--создадим файловую группу
ALTER DATABASE [WideWorldImporters] ADD FILEGROUP [TransactionTypeID]
GO

--добавляем файл БД
ALTER DATABASE [WideWorldImporters] ADD FILE 
( NAME = N'TransactionTypeID', FILENAME = N'C:\DATA\SQL_TransactionTypeID\TransactionTypeID.ndf' , 
SIZE = 109715KB , FILEGROWTH = 65536KB ) TO FILEGROUP [TransactionTypeID]
GO

--создаем функцию партиционирования по ID транзакции
CREATE PARTITION FUNCTION [fnTransactionTypeIDPartition](int) AS RANGE RIGHT FOR VALUES
(10,11,12);																																																									
GO

-- партиционируем, используя созданную нами функцию
CREATE PARTITION SCHEME [schmTransactionTypeIDPartition] AS PARTITION [fnTransactionTypeIDPartition] 
ALL TO ([TransactionTypeID])
GO

CREATE TABLE [Warehouse].[StockItemTransactions_TransactionTypeID](
	[StockItemTransactionID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[TransactionTypeID] [int] NOT NULL,
	[CustomerID] [int] NULL,
	[InvoiceID] [int] NULL,
	[SupplierID] [int] NULL,
	[PurchaseOrderID] [int] NULL,
	[TransactionOccurredWhen] [datetime2](7) NOT NULL,
	[Quantity] [decimal](18, 3) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
) ON [schmTransactionTypeIDPartition]([TransactionTypeID])
 
ALTER TABLE [Warehouse].[StockItemTransactions_TransactionTypeID] ADD CONSTRAINT PK_StockItemTransactions_TransactionTypeID 
PRIMARY KEY CLUSTERED  (TransactionTypeID,StockItemTransactionID)
 ON [schmTransactionTypeIDPartition]([TransactionTypeID]);

GO

SELECT * INTO Warehouse.StockItemTransactionsPartitioned
FROM Warehouse.StockItemTransactions;

GO
INSERT INTO [Warehouse].[StockItemTransactions_TransactionTypeID]
           ([StockItemTransactionID]
           ,[StockItemID]
           ,[TransactionTypeID]
           ,[CustomerID]
           ,[InvoiceID]
           ,[SupplierID]
           ,[PurchaseOrderID]
           ,[TransactionOccurredWhen]
           ,[Quantity]
           ,[LastEditedBy]
           ,[LastEditedWhen])
SELECT [StockItemTransactionID]
      ,[StockItemID]
      ,[TransactionTypeID]
      ,[CustomerID]
      ,[InvoiceID]
      ,[SupplierID]
      ,[PurchaseOrderID]
      ,[TransactionOccurredWhen]
      ,[Quantity]
      ,[LastEditedBy]
      ,[LastEditedWhen]
  FROM [Warehouse].[StockItemTransactionsPartitioned]

 GO

 SELECT  $PARTITION.fnTransactionTypeIDPartition(TransactionTypeID) AS Partition
		, COUNT(*) AS [COUNT]
		, MIN(TransactionTypeID)
		, MAX(TransactionTypeID) 
FROM [Warehouse].[StockItemTransactions_TransactionTypeID]
GROUP BY $PARTITION.fnTransactionTypeIDPartition(TransactionTypeID) 
ORDER BY Partition ;  

/*
DROP TABLE IF EXISTS [Warehouse].[StockItemTransactionsPartitioned];
DROP TABLE IF EXISTS [Warehouse].[StockItemTransactions_TransactionTypeID];
DROP  PARTITION SCHEME [schmTransactionTypeIDPartition];
DROP PARTITION FUNCTION [fnTransactionTypeIDPartition];

ALTER DATABASE [WideWorldImporters]  REMOVE FILE [TransactionTypeID];
GO
ALTER DATABASE [WideWorldImporters] REMOVE FILEGROUP [TransactionTypeID];
*/
