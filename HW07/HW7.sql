/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Опционально - если вы знакомы с insert, update, merge, то загрузить эти данные в таблицу Warehouse.StockItems.
Существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 
*/

DECLARE @xmlDocument  xml

SELECT @xmlDocument = BulkColumn
FROM OPENROWSET
(BULK 'C:\DATA\StockItems.xml', 
 SINGLE_CLOB)
as data 

-- Проверяем, что в @xmlDocument
SELECT @xmlDocument as [@xmlDocument]

DECLARE @docHandle int
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument

-- docHandle - это просто число
SELECT @docHandle as docHandle

SELECT T.Name, T.SupplierID, T.UnitPackageID, T.OuterPackageID, T.QuantityPerOuter, T.TypicalWeightPerUnit, T.LeadTimeDays, T.IsChillerStock, T.TaxRate, T.UnitPrice
FROM OPENXML(@docHandle, N'/StockItems/Item') 
WITH ( 
	Name nvarchar(100)  '@Name',
	SupplierID int 'SupplierID',
	UnitPackageID	int	'Package/UnitPackageID',
	OuterPackageID	int	'Package/OuterPackageID',
	QuantityPerOuter	int	'Package/QuantityPerOuter',
	TypicalWeightPerUnit	decimal(15,3)	'Package/TypicalWeightPerUnit',
	LeadTimeDays int	'LeadTimeDays',
	IsChillerStock int  'IsChillerStock',
	TaxRate decimal(15,3)  'TaxRate',
	UnitPrice decimal(15,3)  'UnitPrice') as T

MERGE [WideWorldImporters].[Warehouse].[StockItems] AS S
USING
(SELECT T.StockItemName, T.SupplierID, T.UnitPackageID, T.OuterPackageID, T.QuantityPerOuter, T.TypicalWeightPerUnit, T.LeadTimeDays, T.IsChillerStock, T.TaxRate, T.UnitPrice
FROM OPENXML(@docHandle, N'/StockItems/Item') 
WITH ( 
	StockItemName nvarchar(100)  '@Name',
	SupplierID int 'SupplierID',
	UnitPackageID	int	'Package/UnitPackageID',
	OuterPackageID	int	'Package/OuterPackageID',
	QuantityPerOuter	int	'Package/QuantityPerOuter',
	TypicalWeightPerUnit	decimal(15,3)	'Package/TypicalWeightPerUnit',
	LeadTimeDays int	'LeadTimeDays',
	IsChillerStock int  'IsChillerStock',
	TaxRate decimal(15,3)  'TaxRate',
	UnitPrice decimal(15,3)  'UnitPrice') as T) AS T
ON S.StockItemName = T.StockItemName
	WHEN MATCHED THEN 
UPDATE SET	S.SupplierID			= T.SupplierID, 
			S.UnitPackageID			= T.UnitPackageID, 
			S.OuterPackageID		= T.OuterPackageID, 
			S.QuantityPerOuter		= T.QuantityPerOuter, 
			S.TypicalWeightPerUnit	= T.TypicalWeightPerUnit, 
			S.LeadTimeDays			= T.LeadTimeDays, 
			S.IsChillerStock		= T.IsChillerStock, 
			S.TaxRate				= T.TaxRate, 
			S.UnitPrice				= T.UnitPrice
WHEN NOT MATCHED THEN
	INSERT (StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, LastEditedBy) 
                 VALUES (T.StockItemName, T.SupplierID, T.UnitPackageID, T.OuterPackageID, T.QuantityPerOuter, T.TypicalWeightPerUnit, T.LeadTimeDays, T.IsChillerStock, T.TaxRate, T.UnitPrice, 1);

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

SELECT
    T.StockItemName AS [@Name], 
	T.SupplierID AS [SupplierID], 
	T.UnitPackageID AS [Package/UnitPackageID], 
	T.OuterPackageID AS [Package/OuterPackageID], 
	T.QuantityPerOuter AS [Package/QuantityPerOuter], 
	T.TypicalWeightPerUnit AS [Package/TypicalWeightPerUnit], 
	T.LeadTimeDays AS [LeadTimeDays],
	T.IsChillerStock AS [IsChillerStock], 
	T.TaxRate AS [TaxRate], 
	T.UnitPrice AS [UnitPrice]
FROM [WideWorldImporters].[Warehouse].[StockItems] AS T
FOR XML PATH('Item'), ROOT('StockItems')


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

SELECT [StockItemID]
      ,[StockItemName]
	  ,JSON_VALUE([CustomFields], '$.CountryOfManufacture') AS CountryOfManufacture
	  ,JSON_VALUE([CustomFields], '$.Tags[0]') AS FirstTag
FROM [WideWorldImporters].[Warehouse].[StockItems]

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/


SELECT [StockItemID]
      ,[StockItemName]
	  ,JSON_VALUE([CustomFields], '$.CountryOfManufacture') AS CountryOfManufacture
	  ,JSON_VALUE([CustomFields], '$.Tags[0]') AS FirstTag
FROM [WideWorldImporters].[Warehouse].[StockItems]
WHERE JSON_VALUE([CustomFields], '$.Tags[0]') = 'Vintage'

GO

SELECT [StockItemID]
      ,[StockItemName]
	  ,STRING_AGG(cast(Tags.Value as nvarchar(max)), ', ') as Tags

FROM [WideWorldImporters].[Warehouse].[StockItems]
CROSS APPLY OPENJSON([CustomFields], '$.Tags') AS Tags
GROUP BY [StockItemID],[StockItemName]

GO

SELECT [StockItemID]
      ,[StockItemName]
FROM [WideWorldImporters].[Warehouse].[StockItems]
CROSS APPLY OPENJSON([CustomFields], '$.Tags') AS Tags
WHERE Tags.Value = 'Vintage'
