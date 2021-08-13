USE [Accounting of metering devices]
GO
/****** Object:  Schema [DOC]    Script Date: 14.08.2021 1:27:23 ******/
CREATE SCHEMA [DOC]
GO
/****** Object:  Schema [LOCATIONS]    Script Date: 14.08.2021 1:27:23 ******/
CREATE SCHEMA [LOCATIONS]
GO
/****** Object:  Schema [MD]    Script Date: 14.08.2021 1:27:23 ******/
CREATE SCHEMA [MD]
GO
/****** Object:  UserDefinedFunction [dbo].[GEN_EAN_13]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  FUNCTION [dbo].[GEN_EAN_13]
(    
	@id			int, 
	@type_doc	decimal(1)
)
RETURNS nvarchar(13)
AS
BEGIN
    DECLARE
        @chk_digit  int,
        @chk        int,
		@barcode	nvarchar(13)
    DECLARE    @num TABLE
    (
        num    int
    )
	SET @barcode =  '2' + CAST(@type_doc AS nvarchar) + RIGHT('000000000' + CAST(@id AS nvarchar),10); 
    INSERT INTO @num 
    SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL  SELECT  5 UNION ALL SELECT  6 UNION ALL
    SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
 
    SELECT    @chk_digit = SUM(CONVERT(int, SUBSTRING(@barcode, LEN(@barcode) - num + 1, 1)) * CASE WHEN num % 2 = 1 THEN 3 ELSE 1 END)
    FROM    @num
    WHERE    num    <= LEN(@barcode)
 
    SELECT    @chk_digit = (10 - (@chk_digit % 10)) % 10
 
    RETURN  @barcode + CAST(CHAR(ASCII('0') + @chk_digit) AS nvarchar)
END
GO
/****** Object:  UserDefinedFunction [dbo].[GEN_EAN_13_DOP]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  FUNCTION [dbo].[GEN_EAN_13_DOP]
(    
	@id			decimal(6), 
	@year		decimal(4),
	@type_doc	decimal(1)
)
RETURNS nvarchar(13)
AS
BEGIN
DECLARE @bc nvarchar(13);
SET @bc =  '2' + CAST(@id AS nvarchar) + RIGHT('000000' + CAST(@year AS nvarchar),10);

DECLARE @even int = 0;
DECLARE @odd int = 0;
DECLARE @i int = 1;
WHILE @i < 13
BEGIN
	SET @even = @even + CAST(SUBSTRING(@bc,2*@i,1) AS int)
	SET @odd = @odd + CAST(SUBSTRING(@bc,2*@i-1,1) AS int)
	SET @i = @i + 1;
END
SET @even = @even*3;
DECLARE @chk_digit int = 10 - (@even + @odd)%10;
SET @bc =  @bc + CAST(@chk_digit AS nvarchar)
    RETURN @bc;
END
GO
/****** Object:  UserDefinedFunction [DOC].[GET_Calibration_barcode]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  FUNCTION [DOC].[GET_Calibration_barcode]
(    
	@id			int
)
RETURNS nvarchar(13)
AS
BEGIN
	DECLARE @barcode nvarchar(13);
	SELECT @barcode = [dbo].[GEN_EAN_13] (@id,0);
	RETURN @barcode;
END
GO
/****** Object:  UserDefinedFunction [DOC].[GET_Responsible_person_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  FUNCTION [DOC].[GET_Responsible_person_by_id]
(    
	@id			int
)
RETURNS nvarchar(50)
AS
BEGIN
	DECLARE @Type_metering_device nvarchar(50);
	SELECT @Type_metering_device = t.responsible_person FROM [DOC].[Responsible_persons] AS T WHERE T.id_responsible_person = @id;
	RETURN @Type_metering_device;
END

GO
/****** Object:  UserDefinedFunction [DOC].[GET_Supplier_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  FUNCTION [DOC].[GET_Supplier_by_id]
(    
	@id			int
)
RETURNS nvarchar(150)
AS
BEGIN
	DECLARE @supplier nvarchar(150);
	SELECT @supplier = t.supplier FROM [DOC].[Suppliers] AS T WHERE T.id_supplier = @id;
	RETURN @supplier;
END

GO
/****** Object:  UserDefinedFunction [DOC].[GET_Type_diagnostic_result_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  FUNCTION [DOC].[GET_Type_diagnostic_result_by_id]
(    
	@id			int
)
RETURNS nvarchar(200)
AS
BEGIN
	DECLARE @diagnostic_result nvarchar(200);
	SELECT @diagnostic_result = t.diagnostic_result FROM [DOC].[Types_diagnostic_results] AS T WHERE T.id_type_diagnostic_result = @id;
	RETURN @diagnostic_result;
END

GO
/****** Object:  UserDefinedFunction [DOC].[GET_Type_doc_calibration_result_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  FUNCTION [DOC].[GET_Type_doc_calibration_result_by_id]
(    
	@id			int
)
RETURNS nvarchar(200)
AS
BEGIN
	DECLARE @Types_doc_calibrations_result nvarchar(200);
	SELECT @Types_doc_calibrations_result = t.type_doc_calibration_result FROM [DOC].[Types_doc_calibrations_result] AS T WHERE T.id_type_doc_calibration_result = @id;
	RETURN @Types_doc_calibrations_result;
END

GO
/****** Object:  UserDefinedFunction [DOC].[GET_Type_of_repair_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  FUNCTION [DOC].[GET_Type_of_repair_by_id]
(    
	@id			int
)
RETURNS nvarchar(200)
AS
BEGIN
	DECLARE @Type_of_repair nvarchar(200);
	SELECT @Type_of_repair = t.type_of_repair FROM [DOC].[Types_of_repairs] AS T WHERE T.id_type_of_repair = @id;
	RETURN @Type_of_repair;
END

GO
/****** Object:  UserDefinedFunction [DOC].[GET_Type_transaction_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  FUNCTION [DOC].[GET_Type_transaction_by_id]
(    
	@id			int
)
RETURNS nvarchar(50)
AS
BEGIN
	DECLARE @type_transaction nvarchar(50);
	SELECT @type_transaction = t.type_transaction FROM [DOC].[Types_transactions] AS T WHERE T.id_type_transaction = @id;
	RETURN @type_transaction;
END

GO
/****** Object:  UserDefinedFunction [DOC].[GET_Types_unserviceability_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  FUNCTION [DOC].[GET_Types_unserviceability_by_id]
(    
	@id			int
)
RETURNS nvarchar(200)
AS
BEGIN
	DECLARE @Type_unserviceability nvarchar(200);
	SELECT @Type_unserviceability = t.type_unserviceability FROM [DOC].[Types_unserviceability] AS T WHERE T.id_type_unserviceability = @id;
	RETURN @Type_unserviceability;
END

GO
/****** Object:  UserDefinedFunction [LOCATIONS].[GET_Connection_point_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  FUNCTION [LOCATIONS].[GET_Connection_point_by_id]
(    
	@id			int
)
RETURNS nvarchar(150)
AS
BEGIN
	DECLARE @connection_point nvarchar(150);
	SELECT @connection_point = t.connection_point FROM [LOCATIONS].[Connection_points] AS T WHERE T.id_connection_point = @id;
	RETURN @connection_point;
END
GO
/****** Object:  UserDefinedFunction [LOCATIONS].[GET_Customer_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  FUNCTION [LOCATIONS].[GET_Customer_by_id]
(    
	@id			int
)
RETURNS nvarchar(150)
AS
BEGIN
	DECLARE @customer nvarchar(150);
	SELECT @customer = t.customer FROM [LOCATIONS].[Customers] AS T WHERE T.id_customer = @id;
	RETURN @customer;
END
GO
/****** Object:  UserDefinedFunction [LOCATIONS].[GET_Delivery_point_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  FUNCTION [LOCATIONS].[GET_Delivery_point_by_id]
(    
	@id			int
)
RETURNS nvarchar(150)
AS
BEGIN
	DECLARE @delivery_point nvarchar(150);
	SELECT @delivery_point = t.delivery_point FROM [LOCATIONS].[Delivery_points] AS T WHERE T.id_delivery_point = @id;
	RETURN @delivery_point;
END

GO
/****** Object:  UserDefinedFunction [LOCATIONS].[GET_Dislocation_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  FUNCTION [LOCATIONS].[GET_Dislocation_by_id]
(    
	@id			int
)
RETURNS nvarchar(max)
AS
BEGIN
	DECLARE @diclocation nvarchar(max);
	SELECT
		@diclocation = 
		TRIM(ENR.enr)  
		+ ' \ ' + 
		TRIM(Delivery_points.delivery_point)  
		+ ' \ ' + 
		TRIM(Installation_sites.installation_site)  
		+ ' \ ' + 	
		TRIM(Customers.customer)  
		+ ' \ ' + 	
		TRIM(Connection_points.connection_point)  
	FROM
		[LOCATIONS].[Locations_metering_devices] AS LOCATIONS 
		INNER JOIN [LOCATIONS].[Regions] AS Regions ON LOCATIONS.id_region = Regions.id_region
		INNER JOIN [LOCATIONS].[ENR] AS ENR ON LOCATIONS.id_enr = ENR.id_enr
		INNER JOIN [LOCATIONS].[Delivery_points] AS Delivery_points ON LOCATIONS.id_delivery_point = Delivery_points.id_delivery_point
		INNER JOIN [LOCATIONS].[Installation_sites] AS Installation_sites ON LOCATIONS.id_installation_site = Installation_sites.id_installation_site
		INNER JOIN [LOCATIONS].[Customers] AS Customers ON LOCATIONS.id_customer = Customers.id_customer
		INNER JOIN [LOCATIONS].[Connection_points] AS Connection_points ON LOCATIONS.id_connection_point = Connection_points.id_connection_point
	WHERE LOCATIONS.id_location_metering_device = @id;
	RETURN @diclocation;
END

GO
/****** Object:  UserDefinedFunction [LOCATIONS].[GET_ENR_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  FUNCTION [LOCATIONS].[GET_ENR_by_id]
(    
	@id			int
)
RETURNS nvarchar(150)
AS
BEGIN
	DECLARE @ENR nvarchar(150);
	SELECT @ENR = t.enr FROM [LOCATIONS].[ENR] AS T WHERE T.id_enr = @id;
	RETURN @ENR;
END

GO
/****** Object:  UserDefinedFunction [LOCATIONS].[GET_Installation_site_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  FUNCTION [LOCATIONS].[GET_Installation_site_by_id]
(    
	@id			int
)
RETURNS nvarchar(150)
AS
BEGIN
	DECLARE @installation_site nvarchar(150);
	SELECT @installation_site = t.installation_site FROM [LOCATIONS].[Installation_sites] AS T WHERE T.id_installation_site = @id;
	RETURN @installation_site;
END

GO
/****** Object:  UserDefinedFunction [LOCATIONS].[GET_Region_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  FUNCTION [LOCATIONS].[GET_Region_by_id]
(    
	@id			int
)
RETURNS nvarchar(150)
AS
BEGIN
	DECLARE @region nvarchar(150);
	SELECT @region = t.region FROM [LOCATIONS].[Regions] AS T WHERE T.id_region = @id;
	RETURN @region;
END

GO
/****** Object:  UserDefinedFunction [LOCATIONS].[GET_Type_accounting_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  FUNCTION [LOCATIONS].[GET_Type_accounting_by_id]
(    
	@id			int
)
RETURNS nvarchar(100)
AS
BEGIN
	DECLARE @type_accounting nvarchar(100);
	SELECT @type_accounting = t.type_accounting FROM [LOCATIONS].[Types_accounting] AS T WHERE T.id_type_accounting = @id;
	RETURN @type_accounting;
END

GO
/****** Object:  UserDefinedFunction [LOCATIONS].[GET_Type_customer_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  FUNCTION [LOCATIONS].[GET_Type_customer_by_id]
(    
	@id			int
)
RETURNS nvarchar(150)
AS
BEGIN
	DECLARE @type_customer nvarchar(150);
	SELECT @type_customer = t.type_customer FROM [LOCATIONS].[Types_customers] AS T WHERE T.id_type_customer = @id;
	RETURN @type_customer;
END

GO
/****** Object:  UserDefinedFunction [MD].[GET_Descr_Metering_devices_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  FUNCTION [MD].[GET_Descr_Metering_devices_by_id]
(    
	@id			int
)
RETURNS nvarchar(max)
AS
BEGIN
	DECLARE @descr nvarchar(max);
	SELECT @descr = '№' + MD.serial_number + ' (' + TRIM(Types_metering_devices.type_metering_device) + '/' + TRIM(Models.model) + '/' + TRIM(Category.category) +')'
	FROM [MD].[Metering_devices] AS MD 
	INNER JOIN [MD].[Types_metering_devices] as Types_metering_devices ON MD.id_type_metering_device = Types_metering_devices.id_type_metering_device
	INNER JOIN [MD].[Models] as Models ON MD.id_model = Models.id_model
	INNER JOIN [MD].[Category] as Category ON MD.id_category = Category.id_category
	WHERE MD.id_metering_device = @id;
	RETURN @descr;
END

GO
/****** Object:  UserDefinedFunction [MD].[GET_Metering_devices_barcode_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  FUNCTION [MD].[GET_Metering_devices_barcode_by_id]
(    
	@id			int
)
RETURNS nvarchar(13)
AS
BEGIN
	DECLARE @barcode nvarchar(13);
	SELECT @barcode = [dbo].[GEN_EAN_13] (@id,1);
	RETURN @barcode;
END
GO
/****** Object:  UserDefinedFunction [MD].[GET_Metering_devices_id_by_barcode]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  FUNCTION [MD].[GET_Metering_devices_id_by_barcode]
(    
	@barcode	nvarchar(max)
)
RETURNS int
AS
BEGIN
	DECLARE @id int;
	SELECT @id = T.id_metering_device FROM [MD].[Metering_devices] AS T WHERE T.barcode = @barcode;
	RETURN @id;
END
GO
/****** Object:  UserDefinedFunction [MD].[GET_Metering_devices_id_by_serial_number]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  FUNCTION [MD].[GET_Metering_devices_id_by_serial_number]
(    
	@id_model int,
	@serial_number nvarchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @id int;
	SELECT @id = T.id_metering_device 
	FROM [MD].[Metering_devices] AS T 
	WHERE T.id_model = @id_model
	AND T.serial_number = @serial_number;
	RETURN @id;
END
GO
/****** Object:  UserDefinedFunction [MD].[GET_Model_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  FUNCTION [MD].[GET_Model_by_id]
(    
	@id			int
)
RETURNS nvarchar(150)
AS
BEGIN
	DECLARE @model nvarchar(200);
	SELECT @model = t.model FROM [MD].[Models] AS T WHERE T.id_model = @id;
	RETURN @model;
END

GO
/****** Object:  UserDefinedFunction [MD].[GET_Type_metering_device_by_id]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  FUNCTION [MD].[GET_Type_metering_device_by_id]
(    
	@id			int
)
RETURNS nvarchar(50)
AS
BEGIN
	DECLARE @Type_metering_device nvarchar(50);
	SELECT @Type_metering_device = t.model FROM [MD].[Models] AS T WHERE T.id_model = @id;
	RETURN @Type_metering_device;
END

GO
/****** Object:  Table [DOC].[Types_transactions]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DOC].[Types_transactions](
	[id_type_transaction] [int] IDENTITY(1,1) NOT NULL,
	[type_transaction] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Types_transactions] PRIMARY KEY CLUSTERED 
(
	[id_type_transaction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [DOC].[Mounting]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DOC].[Mounting](
	[id_mounting] [int] IDENTITY(1,1) NOT NULL,
	[id_location_metering_device] [int] NOT NULL,
	[date_mounting] [date] NOT NULL,
	[id_metering_device] [int] NOT NULL,
	[doc_date] [date] NOT NULL,
	[doc_nom] [nvarchar](50) NOT NULL,
	[id_responsible_persons] [int] NOT NULL,
	[barcode] [nvarchar](100) NOT NULL,
	[comments] [nvarchar](1000) NULL,
 CONSTRAINT [PK_Mounting] PRIMARY KEY CLUSTERED 
(
	[id_mounting] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [DOC].[Removal]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DOC].[Removal](
	[id_removal] [int] IDENTITY(1,1) NOT NULL,
	[id_location_metering_device] [int] NOT NULL,
	[date_removal] [date] NOT NULL,
	[id_metering_device] [int] NOT NULL,
	[doc_date] [date] NOT NULL,
	[doc_nom] [nvarchar](50) NOT NULL,
	[id_responsible_persons] [int] NOT NULL,
	[barcode] [nvarchar](100) NOT NULL,
	[comments] [nvarchar](1000) NULL,
 CONSTRAINT [PK_Removal] PRIMARY KEY CLUSTERED 
(
	[id_removal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [DOC].[Calibration]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DOC].[Calibration](
	[id_calibration] [int] IDENTITY(1,1) NOT NULL,
	[id_task_of_calibration] [int] NOT NULL,
	[date_calibration_plan] [date] NOT NULL,
	[doc_date] [date] NOT NULL,
	[doc_nom] [nvarchar](32) NOT NULL,
	[barcode] [nvarchar](100) NULL,
	[id_metering_device] [int] NOT NULL,
	[id_location_metering_device] [int] NULL,
	[comments] [nvarchar](1000) NULL,
	[id_supplier] [int] NULL,
	[calibration_passed] [bit] NULL,
	[payment_invoice] [nvarchar](50) NULL,
	[id_type_doc_calibration_result] [int] NULL,
	[doc_calibration_result_nom] [nvarchar](50) NULL,
	[doc_calibration_result_date] [date] NULL,
	[result_notes] [nvarchar](1000) NULL,
 CONSTRAINT [PK_Calibration] PRIMARY KEY CLUSTERED 
(
	[id_calibration] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [DOC].[Diagnostics]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DOC].[Diagnostics](
	[id_diagnostic] [int] IDENTITY(1,1) NOT NULL,
	[id_metering_device] [int] NOT NULL,
	[batch_number] [nvarchar](50) NOT NULL,
	[date_of_sending] [date] NOT NULL,
	[barcode] [nvarchar](100) NOT NULL,
	[id_supplier] [int] NOT NULL,
	[supplier_order] [nvarchar](100) NOT NULL,
	[comments] [nvarchar](1000) NULL,
	[date_of_receipt] [date] NULL,
	[id_type_diagnostic_result] [int] NULL,
	[payment_invoice] [nvarchar](50) NULL,
	[notes] [nvarchar](1000) NULL,
 CONSTRAINT [PK_Diagnostics] PRIMARY KEY CLUSTERED 
(
	[id_diagnostic] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [DOC].[Repairs]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DOC].[Repairs](
	[id_repair] [int] IDENTITY(1,1) NOT NULL,
	[id_metering_device] [int] NOT NULL,
	[batch_number] [nvarchar](50) NOT NULL,
	[date_of_sending] [date] NOT NULL,
	[barcode] [nvarchar](100) NOT NULL,
	[id_supplier] [int] NOT NULL,
	[supplier_order] [nvarchar](100) NOT NULL,
	[comments] [nvarchar](1000) NULL,
	[date_of_receipt] [date] NULL,
	[id_type_of_repair] [int] NULL,
	[repair_passed] [bit] NULL,
	[payment_invoice] [nvarchar](50) NULL,
	[notes] [nvarchar](1000) NULL,
 CONSTRAINT [PK_Repairs] PRIMARY KEY CLUSTERED 
(
	[id_repair] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [DOC].[Disposal]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DOC].[Disposal](
	[id_disposal] [int] IDENTITY(1,1) NOT NULL,
	[doc_date] [date] NOT NULL,
	[doc_nom] [nvarchar](50) NOT NULL,
	[id_type_unserviceability] [int] NOT NULL,
	[barcode] [nvarchar](100) NOT NULL,
	[comments] [nvarchar](1000) NULL,
	[id_metering_device] [int] NOT NULL,
 CONSTRAINT [PK_Disposal] PRIMARY KEY CLUSTERED 
(
	[id_disposal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [DOC].[LAST_TRANSACTION_AT_METERING_DEVICES]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [DOC].[LAST_TRANSACTION_AT_METERING_DEVICES]
AS
WITH TRANSACTION_LINE AS(
SELECT        Mounting.id_mounting AS id_transaction, 0 AS id_type_transaction, Mounting.id_location_metering_device, Mounting.date_mounting AS date_transaction, Mounting.id_metering_device
FROM            DOC.Mounting AS Mounting
UNION ALL
SELECT        Calibration.id_calibration AS id_transaction, 1 AS id_type_transaction, Calibration.id_location_metering_device, Calibration.doc_date AS date_transaction, Calibration.id_metering_device
FROM            DOC.Calibration AS Calibration
WHERE        Calibration.doc_calibration_result_date IS NULL
UNION ALL
SELECT        Calibration.id_calibration AS id_transaction, 2 AS id_type_transaction, Calibration.id_location_metering_device, Calibration.doc_calibration_result_date AS date_transaction, Calibration.id_metering_device
FROM            DOC.Calibration AS Calibration
WHERE        Calibration.doc_calibration_result_date IS NOT NULL
UNION ALL
SELECT        Removal.id_removal AS id_transaction, 3 AS id_type_transaction, Removal.id_location_metering_device, Removal.date_removal AS date_transaction, Removal.id_metering_device
FROM            DOC.Removal AS Removal
UNION ALL
SELECT        Diagnostics.id_diagnostic AS id_transaction, 4 AS id_type_transaction, NULL, Diagnostics.date_of_sending AS date_transaction, Diagnostics.id_metering_device
FROM            DOC.Diagnostics AS Diagnostics
WHERE        Diagnostics.date_of_receipt IS NULL
UNION ALL
SELECT        Diagnostics.id_diagnostic AS id_transaction, 5 AS id_type_transaction, NULL, Diagnostics.date_of_receipt AS date_of_receipt, Diagnostics.id_metering_device
FROM            DOC.Diagnostics AS Diagnostics
WHERE        Diagnostics.date_of_receipt IS NOT NULL
UNION ALL
SELECT        Repairs.id_repair AS id_transaction, 6 AS id_type_transaction, NULL, Repairs.date_of_sending AS date_transaction, Repairs.id_metering_device
FROM            DOC.Repairs AS Repairs
WHERE        Repairs.date_of_receipt IS NULL
UNION ALL
SELECT        Repairs.id_repair AS id_transaction, 6 AS id_type_transaction, NULL, Repairs.date_of_receipt AS date_transaction, Repairs.id_metering_device
FROM            DOC.Repairs AS Repairs
WHERE        Repairs.date_of_receipt IS NOT NULL
UNION ALL
SELECT        Disposal.id_disposal AS id_transaction, 7 AS id_type_transaction, NULL, Disposal.doc_date AS date_transaction, Disposal.id_metering_device
FROM            DOC.Disposal AS Disposal)
    SELECT        R.id_metering_device, R.id_location_metering_device, R.id_transaction, R.date_transaction, R.id_type_transaction, Types_transactions.type_transaction
     FROM            (SELECT        T .id_metering_device, T .id_location_metering_device, T.id_transaction, T .date_transaction, T .id_type_transaction, ROW_NUMBER() OVER (PARTITION BY T .id_metering_device
                               ORDER BY T .date_transaction DESC, T .id_type_transaction DESC) AS TransactionRank
     FROM            TRANSACTION_LINE AS T) AS R INNER JOIN
DOC.Types_transactions AS Types_transactions ON R.id_type_transaction = Types_transactions.id_type_transaction
WHERE        R.TransactionRank = 1
GO
/****** Object:  UserDefinedFunction [LOCATIONS].[GET_TRANSACTION_LINE_BY_METERIG_DEVICE]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [LOCATIONS].[GET_TRANSACTION_LINE_BY_METERIG_DEVICE] 
(	
	@id_metering_device int
)
RETURNS TABLE 
AS
RETURN
(WITH TRANSACTION_LINE AS (
SELECT        Mounting.id_mounting AS id_transaction, 0 AS id_type_transaction, Mounting.id_location_metering_device, Mounting.date_mounting AS date_transaction, Mounting.id_metering_device
FROM            DOC.Mounting AS Mounting 
WHERE Mounting.id_metering_device = @id_metering_device 
UNION ALL
SELECT        Calibration.id_calibration AS id_transaction, 1 AS id_type_transaction, Calibration.id_location_metering_device, Calibration.doc_date AS date_transaction, Calibration.id_metering_device
FROM            DOC.Calibration AS Calibration 
WHERE Calibration.id_metering_device = @id_metering_device
UNION ALL
SELECT        Calibration.id_calibration AS id_transaction, 2 AS id_type_transaction, Calibration.id_location_metering_device, Calibration.doc_calibration_result_date AS date_transaction, Calibration.id_metering_device
FROM            DOC.Calibration AS Calibration
WHERE Calibration.id_metering_device = @id_metering_device       
AND Calibration.doc_calibration_result_date IS NOT NULL AND Calibration.calibration_passed = 0
UNION ALL
SELECT        Calibration.id_calibration AS id_transaction, 3 AS id_type_transaction, Calibration.id_location_metering_device, Calibration.doc_calibration_result_date AS date_transaction, Calibration.id_metering_device
FROM            DOC.Calibration AS Calibration
WHERE Calibration.id_metering_device = @id_metering_device       
AND Calibration.doc_calibration_result_date IS NOT NULL AND Calibration.calibration_passed = 1
UNION ALL
SELECT        Removal.id_removal AS id_transaction, 4 AS id_type_transaction, Removal.id_location_metering_device, Removal.date_removal AS date_transaction, Removal.id_metering_device
FROM            DOC.Removal AS Removal
WHERE Removal.id_metering_device = @id_metering_device 
UNION ALL
SELECT        Diagnostics.id_diagnostic AS id_transaction, 5 AS id_type_transaction, NULL, Diagnostics.date_of_sending AS date_transaction, Diagnostics.id_metering_device
FROM            DOC.Diagnostics AS Diagnostics
WHERE Diagnostics.id_metering_device = @id_metering_device 
UNION ALL
SELECT        Diagnostics.id_diagnostic AS id_transaction, 6 AS id_type_transaction, NULL, Diagnostics.date_of_receipt AS date_of_receipt, Diagnostics.id_metering_device
FROM            DOC.Diagnostics AS Diagnostics
WHERE Diagnostics.id_metering_device = @id_metering_device 
AND Diagnostics.date_of_receipt IS NOT NULL
UNION ALL
SELECT        Repairs.id_repair AS id_transaction, 7 AS id_type_transaction, NULL, Repairs.date_of_sending AS date_transaction, Repairs.id_metering_device
FROM            DOC.Repairs AS Repairs
WHERE Repairs.id_metering_device = @id_metering_device 
UNION ALL
SELECT        Repairs.id_repair AS id_transaction, 8 AS id_type_transaction, NULL, Repairs.date_of_receipt AS date_transaction, Repairs.id_metering_device
FROM            DOC.Repairs AS Repairs
WHERE Repairs.id_metering_device = @id_metering_device 
AND        Repairs.date_of_receipt IS NOT NULL
UNION ALL
SELECT        Disposal.id_disposal AS id_transaction, 9 AS id_type_transaction, NULL, Disposal.doc_date AS date_transaction, Disposal.id_metering_device
FROM            DOC.Disposal AS Disposal
WHERE Disposal.id_metering_device = @id_metering_device)

SELECT TRANSACTION_LINE.id_metering_device
      ,TRANSACTION_LINE.id_location_metering_device
      ,TRANSACTION_LINE.date_transaction
      ,TRANSACTION_LINE.id_type_transaction
      ,TYPES_TRANSACTIONS.type_transaction
FROM TRANSACTION_LINE AS TRANSACTION_LINE
INNER JOIN [DOC].[Types_transactions] AS TYPES_TRANSACTIONS ON TRANSACTION_LINE.id_type_transaction = TYPES_TRANSACTIONS.id_type_transaction )
GO
/****** Object:  Table [LOCATIONS].[Locations_metering_devices]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [LOCATIONS].[Locations_metering_devices](
	[id_location_metering_device] [int] IDENTITY(0,1) NOT NULL,
	[id_region] [int] NOT NULL,
	[id_enr] [int] NOT NULL,
	[id_delivery_point] [int] NOT NULL,
	[id_installation_site] [int] NOT NULL,
	[id_customer] [int] NULL,
	[id_connection_point] [int] NOT NULL,
	[id_type_accounting] [int] NOT NULL,
	[comments] [nvarchar](1000) NULL,
 CONSTRAINT [PK_Locations_metering_devices] PRIMARY KEY CLUSTERED 
(
	[id_location_metering_device] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MD].[Models]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MD].[Models](
	[id_model] [int] IDENTITY(1,1) NOT NULL,
	[model] [nvarchar](200) NOT NULL,
	[calibration_interval] [int] NOT NULL,
 CONSTRAINT [PK_MODELS] PRIMARY KEY CLUSTERED 
(
	[id_model] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [LOCATIONS].[Customers]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [LOCATIONS].[Customers](
	[id_customer] [int] IDENTITY(1,1) NOT NULL,
	[customer] [nvarchar](150) NOT NULL,
	[id_type_customer] [int] NOT NULL,
	[comments] [nvarchar](1000) NULL,
	[contacts] [nvarchar](1000) NULL,
 CONSTRAINT [PK_CUSTOMERS] PRIMARY KEY CLUSTERED 
(
	[id_customer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [LOCATIONS].[Regions]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [LOCATIONS].[Regions](
	[id_region] [int] IDENTITY(1,1) NOT NULL,
	[region] [nvarchar](150) NOT NULL,
 CONSTRAINT [PK_REGIONS] PRIMARY KEY CLUSTERED 
(
	[id_region] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [LOCATIONS].[ENR]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [LOCATIONS].[ENR](
	[id_enr] [int] IDENTITY(1,1) NOT NULL,
	[enr] [nvarchar](150) NOT NULL,
 CONSTRAINT [PK_ENR] PRIMARY KEY CLUSTERED 
(
	[id_enr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [LOCATIONS].[Delivery_points]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [LOCATIONS].[Delivery_points](
	[id_delivery_point] [int] IDENTITY(1,1) NOT NULL,
	[delivery_point] [nvarchar](150) NOT NULL,
 CONSTRAINT [PK_Delivery_points] PRIMARY KEY CLUSTERED 
(
	[id_delivery_point] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [LOCATIONS].[Installation_sites]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [LOCATIONS].[Installation_sites](
	[id_installation_site] [int] IDENTITY(1,1) NOT NULL,
	[installation_site] [nvarchar](150) NOT NULL,
 CONSTRAINT [PK_Installation_sites] PRIMARY KEY CLUSTERED 
(
	[id_installation_site] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [LOCATIONS].[Connection_points]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [LOCATIONS].[Connection_points](
	[id_connection_point] [int] IDENTITY(1,1) NOT NULL,
	[connection_point] [nvarchar](150) NOT NULL,
	[comments] [nvarchar](1000) NULL,
	[adr] [nvarchar](1000) NULL,
 CONSTRAINT [PK_Connection_points] PRIMARY KEY CLUSTERED 
(
	[id_connection_point] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MD].[Metering_devices]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MD].[Metering_devices](
	[id_metering_device] [int] IDENTITY(1,1) NOT NULL,
	[id_model] [int] NOT NULL,
	[serial_number] [nvarchar](50) NOT NULL,
	[passport_number] [nvarchar](50) NOT NULL,
	[id_category] [int] NOT NULL,
	[id_type_metering_device] [int] NOT NULL,
	[date_calibration] [date] NOT NULL,
	[comments] [nvarchar](1000) NULL,
	[barcode] [nvarchar](100) NULL,
	[certificate] [nvarchar](100) NOT NULL,
	[nominal_value] [decimal](8, 3) NOT NULL,
 CONSTRAINT [PK_Metering_devices] PRIMARY KEY CLUSTERED 
(
	[id_metering_device] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [LOCATIONS].[Types_accounting]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [LOCATIONS].[Types_accounting](
	[id_type_accounting] [int] IDENTITY(0,1) NOT NULL,
	[type_accounting] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Types_accounting] PRIMARY KEY CLUSTERED 
(
	[id_type_accounting] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [DOC].[LOCATIONS_METERING_DEVICES]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [DOC].[LOCATIONS_METERING_DEVICES]
AS
SELECT
	LOCATIONS.id_location_metering_device,
	LOCATIONS.id_region,
	Regions.region,
	LOCATIONS.id_enr,
	ENR.enr,
	LOCATIONS.id_delivery_point,
	Delivery_points.delivery_point,
	LOCATIONS.id_installation_site,
	Installation_sites.installation_site,
	LOCATIONS.id_customer,
	Customers.customer,
	LOCATIONS.id_connection_point,
	Connection_points.connection_point,
	LOCATIONS.id_type_accounting,
	Types_accounting.type_accounting,
	STRING_AGG(Metering_devices.serial_number + ' (' +Models.model + ')',';') as Metering_devices
FROM
[LOCATIONS].[Locations_metering_devices] AS LOCATIONS 
INNER JOIN [LOCATIONS].[Regions] AS Regions ON LOCATIONS.id_region = Regions.id_region
INNER JOIN [LOCATIONS].[ENR] AS ENR ON LOCATIONS.id_enr = ENR.id_enr
INNER JOIN [LOCATIONS].[Delivery_points] AS Delivery_points ON LOCATIONS.id_delivery_point = Delivery_points.id_delivery_point
INNER JOIN [LOCATIONS].[Installation_sites] AS Installation_sites ON LOCATIONS.id_installation_site = Installation_sites.id_installation_site
INNER JOIN [LOCATIONS].[Customers] AS Customers ON LOCATIONS.id_customer = Customers.id_customer
INNER JOIN [LOCATIONS].[Connection_points] AS Connection_points ON LOCATIONS.id_connection_point = Connection_points.id_connection_point
INNER JOIN [LOCATIONS].[Types_accounting] AS Types_accounting ON LOCATIONS.id_type_accounting = Types_accounting.id_type_accounting
LEFT OUTER JOIN
(SELECT
	T.id_location_metering_device,
	T.id_metering_device
FROM
(SELECT
	MOUNTING_REMOVAL.id_type_transaction, 
	MOUNTING_REMOVAL.id_location_metering_device, 
	MOUNTING_REMOVAL.date_transaction, 
	MOUNTING_REMOVAL.id_metering_device,
	ROW_NUMBER() OVER (PARTITION BY MOUNTING_REMOVAL.id_metering_device ORDER BY MOUNTING_REMOVAL.date_transaction DESC,MOUNTING_REMOVAL.id_type_transaction DESC) AS TransactionRank
FROM
(SELECT 
	Mounting.id_mounting AS id_transaction, 
	0 AS id_type_transaction, 
	Mounting.id_location_metering_device, 
	Mounting.date_mounting AS date_transaction, 
	Mounting.id_metering_device
FROM DOC.Mounting as Mounting
	INNER JOIN [LOCATIONS].[Locations_metering_devices] AS Locations_metering_devices
		ON Mounting.id_location_metering_device = Locations_metering_devices.id_location_metering_device
		AND Locations_metering_devices.id_enr = 3
UNION ALL
SELECT 
	Removal.id_removal AS id_transaction, 
	3 AS id_type_transaction, 
	Removal.id_location_metering_device, 
	Removal.date_removal AS date_transaction, 
	Removal.id_metering_device
FROM DOC.Removal as Removal
	INNER JOIN [LOCATIONS].[Locations_metering_devices] AS Locations_metering_devices
		ON Removal.id_location_metering_device = Locations_metering_devices.id_location_metering_device
		AND Locations_metering_devices.id_enr = 3) AS MOUNTING_REMOVAL
) AS T
WHERE T.TransactionRank = 1 AND T.id_type_transaction = 0) AS MOUNTING_MD
ON LOCATIONS.id_location_metering_device = MOUNTING_MD.id_location_metering_device
LEFT OUTER JOIN [MD].[Metering_devices] ON MOUNTING_MD.id_metering_device = Metering_devices.id_metering_device
LEFT OUTER JOIN [MD].[Models] ON Models.id_model = Metering_devices.id_model
GROUP BY
	LOCATIONS.id_location_metering_device,
	LOCATIONS.id_region,
	Regions.region,
	LOCATIONS.id_enr,
	ENR.enr,
	LOCATIONS.id_delivery_point,
	Delivery_points.delivery_point,
	LOCATIONS.id_installation_site,
	Installation_sites.installation_site,
	LOCATIONS.id_customer,
	Customers.customer,
	LOCATIONS.id_connection_point,
	Connection_points.connection_point,
	LOCATIONS.id_type_accounting,
	Types_accounting.type_accounting
GO
/****** Object:  View [DOC].[LOCATIONS_METERING_DEVICES_CALIBRATIONS]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [DOC].[LOCATIONS_METERING_DEVICES_CALIBRATIONS]
AS
SELECT
	LOCATIONS.id_location_metering_device,
	LOCATIONS.id_region,
	Regions.region,
	LOCATIONS.id_enr,
	ENR.enr,
	LOCATIONS.id_delivery_point,
	Delivery_points.delivery_point,
	LOCATIONS.id_installation_site,
	Installation_sites.installation_site,
	LOCATIONS.id_customer,
	Customers.customer,
	LOCATIONS.id_connection_point,
	Connection_points.connection_point,
	LOCATIONS.id_type_accounting,
	Types_accounting.type_accounting,
	Metering_devices.id_metering_device,
	Metering_devices.serial_number + ' (' +Metering_devices.model + ')' as Metering_devices,
	Metering_devices.date_calibration_plan,
	Metering_devices.date_calibration_last
FROM
[LOCATIONS].[Locations_metering_devices] AS LOCATIONS 
INNER JOIN [LOCATIONS].[Regions] AS Regions ON LOCATIONS.id_region = Regions.id_region
INNER JOIN [LOCATIONS].[ENR] AS ENR ON LOCATIONS.id_enr = ENR.id_enr
INNER JOIN [LOCATIONS].[Delivery_points] AS Delivery_points ON LOCATIONS.id_delivery_point = Delivery_points.id_delivery_point
INNER JOIN [LOCATIONS].[Installation_sites] AS Installation_sites ON LOCATIONS.id_installation_site = Installation_sites.id_installation_site
INNER JOIN [LOCATIONS].[Customers] AS Customers ON LOCATIONS.id_customer = Customers.id_customer
INNER JOIN [LOCATIONS].[Connection_points] AS Connection_points ON LOCATIONS.id_connection_point = Connection_points.id_connection_point
INNER JOIN [LOCATIONS].[Types_accounting] AS Types_accounting ON LOCATIONS.id_type_accounting = Types_accounting.id_type_accounting
LEFT OUTER JOIN
(SELECT
	T.id_location_metering_device,
	T.id_metering_device
FROM
(SELECT
	MOUNTING_REMOVAL.id_type_transaction, 
	MOUNTING_REMOVAL.id_location_metering_device, 
	MOUNTING_REMOVAL.date_transaction, 
	MOUNTING_REMOVAL.id_metering_device,
	ROW_NUMBER() OVER (PARTITION BY MOUNTING_REMOVAL.id_metering_device ORDER BY MOUNTING_REMOVAL.date_transaction DESC,MOUNTING_REMOVAL.id_type_transaction DESC) AS TransactionRank
FROM
(SELECT 
	Mounting.id_mounting AS id_transaction, 
	0 AS id_type_transaction, 
	Mounting.id_location_metering_device, 
	Mounting.date_mounting AS date_transaction, 
	Mounting.id_metering_device
FROM DOC.Mounting as Mounting
	INNER JOIN [LOCATIONS].[Locations_metering_devices] AS Locations_metering_devices
		ON Mounting.id_location_metering_device = Locations_metering_devices.id_location_metering_device
		AND Locations_metering_devices.id_enr = 3
UNION ALL
SELECT 
	Removal.id_removal AS id_transaction, 
	3 AS id_type_transaction, 
	Removal.id_location_metering_device, 
	Removal.date_removal AS date_transaction, 
	Removal.id_metering_device
FROM DOC.Removal as Removal
	INNER JOIN [LOCATIONS].[Locations_metering_devices] AS Locations_metering_devices
		ON Removal.id_location_metering_device = Locations_metering_devices.id_location_metering_device
		AND Locations_metering_devices.id_enr = 3) AS MOUNTING_REMOVAL
) AS T
WHERE T.TransactionRank = 1 AND T.id_type_transaction = 0) AS MOUNTING_MD
ON LOCATIONS.id_location_metering_device = MOUNTING_MD.id_location_metering_device
LEFT OUTER JOIN 
(SELECT
	Metering_devices.id_metering_device,
	Models.model,
	Metering_devices.serial_number,
	ISNULL(LAST_CALIBRATIONS.DATE_CALIBRATION, Metering_devices.date_calibration) as date_calibration_last,
	(DATEADD(month, Models.calibration_interval, ISNULL(LAST_CALIBRATIONS.DATE_CALIBRATION, Metering_devices.date_calibration))) AS date_calibration_plan
FROM
	[MD].[Metering_devices] AS Metering_devices
	INNER JOIN [MD].[Models] AS Models ON Metering_devices.id_model = Models.id_model
	LEFT OUTER JOIN  (SELECT id_metering_device,MAX(doc_date) AS DATE_CALIBRATION FROM	DOC.Calibration WHERE  calibration_passed = 1 GROUP BY id_metering_device) AS LAST_CALIBRATIONS
	ON Metering_devices.id_metering_device = LAST_CALIBRATIONS.id_metering_device) AS Metering_devices
ON MOUNTING_MD.id_metering_device = Metering_devices.id_metering_device
GO
/****** Object:  View [DOC].[ORDERS_ON_CALIBRATIONS]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [DOC].[ORDERS_ON_CALIBRATIONS]
AS
WITH Orders_on_calibration AS (SELECT        id_metering_device, id_transaction, id_location_metering_device
                                                                       FROM            DOC.LAST_TRANSACTION_AT_METERING_DEVICES AS Orders_on_calibration
                                                                       WHERE        (id_type_transaction = 1))
    SELECT        Orders_on_calibration.id_metering_device, Calibration.date_calibration_plan, Orders_on_calibration.id_transaction, Calibration.doc_date, Calibration.doc_nom, Calibration.barcode, Calibration.comments, 
                              Locations_metering_devices.id_region, Regions.region, Locations_metering_devices.id_enr, ENR.enr, Locations_metering_devices.id_delivery_point, Delivery_points.delivery_point, 
                              Locations_metering_devices.id_installation_site, Installation_sites.installation_site, Locations_metering_devices.id_customer, Customers.customer, Locations_metering_devices.id_connection_point, 
                              Connection_points.connection_point, Locations_metering_devices.id_type_accounting, Types_accounting.type_accounting
     FROM            Orders_on_calibration AS Orders_on_calibration INNER JOIN
                              DOC.Calibration AS Calibration ON Orders_on_calibration.id_transaction = Calibration.id_calibration INNER JOIN
                              LOCATIONS.Locations_metering_devices AS Locations_metering_devices ON Orders_on_calibration.id_location_metering_device = Locations_metering_devices.id_location_metering_device INNER JOIN
                              LOCATIONS.Regions AS Regions ON Locations_metering_devices.id_region = Regions.id_region INNER JOIN
                              LOCATIONS.ENR AS ENR ON Locations_metering_devices.id_enr = ENR.id_enr INNER JOIN
                              LOCATIONS.Delivery_points AS Delivery_points ON Locations_metering_devices.id_delivery_point = Delivery_points.id_delivery_point INNER JOIN
                              LOCATIONS.Installation_sites AS Installation_sites ON Locations_metering_devices.id_installation_site = Installation_sites.id_installation_site INNER JOIN
                              LOCATIONS.Customers AS Customers ON Locations_metering_devices.id_customer = Customers.id_customer INNER JOIN
                              LOCATIONS.Connection_points AS Connection_points ON Locations_metering_devices.id_connection_point = Connection_points.id_connection_point INNER JOIN
                              LOCATIONS.Types_accounting AS Types_accounting ON Locations_metering_devices.id_type_accounting = Types_accounting.id_type_accounting
GO
/****** Object:  Table [DOC].[Suppliers]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DOC].[Suppliers](
	[id_supplier] [int] IDENTITY(1,1) NOT NULL,
	[supplier] [nvarchar](150) NOT NULL,
	[comments] [nvarchar](1000) NULL,
	[contacts] [nvarchar](1000) NULL,
 CONSTRAINT [PK_Suppliers] PRIMARY KEY CLUSTERED 
(
	[id_supplier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [DOC].[Types_doc_calibrations_result]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DOC].[Types_doc_calibrations_result](
	[id_type_doc_calibration_result] [int] IDENTITY(1,1) NOT NULL,
	[type_doc_calibration_result] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_Types_doc_calibrations_result] PRIMARY KEY CLUSTERED 
(
	[id_type_doc_calibration_result] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [DOC].[FAILED_CALIBRATIONS]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Скрипт для команды SelectTopNRows из среды SSMS  ******/
CREATE VIEW [DOC].[FAILED_CALIBRATIONS]
AS
WITH Orders_on_calibration AS (SELECT        id_metering_device, id_transaction, id_location_metering_device
                                                                       FROM            DOC.LAST_TRANSACTION_AT_METERING_DEVICES AS Orders_on_calibration
                                                                       WHERE        (id_type_transaction = 2))
    SELECT        Orders_on_calibration.id_metering_device, Calibration.date_calibration_plan, Orders_on_calibration.id_transaction, Calibration.barcode, Calibration.comments, Calibration.id_supplier, Suppliers.supplier, 
                              Calibration.payment_invoice, Calibration.id_type_doc_calibration_result, Types_doc_calibrations_result.type_doc_calibration_result, Calibration.doc_nom, Calibration.doc_date, Calibration.result_notes, 
                              Locations_metering_devices.id_region, Regions.region, Locations_metering_devices.id_enr, ENR.enr, Locations_metering_devices.id_delivery_point, Delivery_points.delivery_point, 
                              Locations_metering_devices.id_installation_site, Installation_sites.installation_site, Locations_metering_devices.id_customer, Customers.customer, Locations_metering_devices.id_connection_point, 
                              Connection_points.connection_point, Locations_metering_devices.id_type_accounting, Types_accounting.type_accounting
     FROM            Orders_on_calibration AS Orders_on_calibration INNER JOIN
                              DOC.Calibration AS Calibration ON Orders_on_calibration.id_transaction = Calibration.id_calibration AND Calibration.calibration_passed = 0 INNER JOIN
                              LOCATIONS.Locations_metering_devices AS Locations_metering_devices ON Orders_on_calibration.id_location_metering_device = Locations_metering_devices.id_location_metering_device INNER JOIN
                              LOCATIONS.Regions AS Regions ON Locations_metering_devices.id_region = Regions.id_region INNER JOIN
                              LOCATIONS.ENR AS ENR ON Locations_metering_devices.id_enr = ENR.id_enr INNER JOIN
                              LOCATIONS.Delivery_points AS Delivery_points ON Locations_metering_devices.id_delivery_point = Delivery_points.id_delivery_point INNER JOIN
                              LOCATIONS.Installation_sites AS Installation_sites ON Locations_metering_devices.id_installation_site = Installation_sites.id_installation_site INNER JOIN
                              LOCATIONS.Customers AS Customers ON Locations_metering_devices.id_customer = Customers.id_customer INNER JOIN
                              LOCATIONS.Connection_points AS Connection_points ON Locations_metering_devices.id_connection_point = Connection_points.id_connection_point INNER JOIN
                              LOCATIONS.Types_accounting AS Types_accounting ON Locations_metering_devices.id_type_accounting = Types_accounting.id_type_accounting INNER JOIN
                              DOC.Suppliers AS Suppliers ON Calibration.id_supplier = Suppliers.id_supplier INNER JOIN
                              DOC.Types_doc_calibrations_result AS Types_doc_calibrations_result ON Calibration.id_type_doc_calibration_result = Types_doc_calibrations_result.id_type_doc_calibration_result
GO
/****** Object:  UserDefinedFunction [LOCATIONS].[GET_Dislocation_Metering_devices_by_Enr]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [LOCATIONS].[GET_Dislocation_Metering_devices_by_Enr] 
(	
	@id_enr int
)
RETURNS TABLE 
AS
RETURN
(SELECT
	T.id_location_metering_device,
	[LOCATIONS].[GET_Dislocation_by_id](T.id_location_metering_device) as location_metering_device,
	T.id_metering_device
FROM
(SELECT
	MOUNTING_REMOVAL.id_type_transaction, 
	MOUNTING_REMOVAL.id_location_metering_device, 
	MOUNTING_REMOVAL.date_transaction, 
	MOUNTING_REMOVAL.id_metering_device,
	ROW_NUMBER() OVER (PARTITION BY MOUNTING_REMOVAL.id_metering_device ORDER BY MOUNTING_REMOVAL.date_transaction DESC,MOUNTING_REMOVAL.id_type_transaction DESC) AS TransactionRank
FROM
(SELECT 
	Mounting.id_mounting AS id_transaction, 
	0 AS id_type_transaction, 
	Mounting.id_location_metering_device, 
	Mounting.date_mounting AS date_transaction, 
	Mounting.id_metering_device
FROM DOC.Mounting as Mounting
	INNER JOIN [LOCATIONS].[Locations_metering_devices] AS Locations_metering_devices
		ON Mounting.id_location_metering_device = Locations_metering_devices.id_location_metering_device
		AND Locations_metering_devices.id_enr = @id_enr
UNION ALL
SELECT 
	Removal.id_removal AS id_transaction, 
	3 AS id_type_transaction, 
	Removal.id_location_metering_device, 
	Removal.date_removal AS date_transaction, 
	Removal.id_metering_device
FROM DOC.Removal as Removal
	INNER JOIN [LOCATIONS].[Locations_metering_devices] AS Locations_metering_devices
		ON Removal.id_location_metering_device = Locations_metering_devices.id_location_metering_device
		AND Locations_metering_devices.id_enr = @id_enr) AS MOUNTING_REMOVAL
) AS T
WHERE T.TransactionRank = 1 AND T.id_type_transaction = 0)
GO
/****** Object:  UserDefinedFunction [MD].[NEXT_CALIBRATION_MD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [MD].[NEXT_CALIBRATION_MD] 
(	
	-- Add the parameters for the function here
	@FOR_MONTH int, 
	@ON_DATE date,
	@ID_ENR int
)
RETURNS TABLE 
AS
RETURN 
(
WITH LAST_CALIBRATIONS AS
(SELECT id_metering_device, 
		MAX(doc_date) AS DATE_CALIBRATION
 FROM	DOC.Calibration
 WHERE  calibration_passed = 1 
GROUP BY id_metering_device)

SELECT 
	Mounting_Metering_devices.id_location_metering_device,
	Mounting_Metering_devices.id_metering_device,
	(DATEADD(month, Models.calibration_interval, ISNULL(LAST_CALIBRATIONS.DATE_CALIBRATION, Metering_devices.date_calibration))) AS date_calibration_plan
FROM [LOCATIONS].[GET_Dislocation_Metering_devices_by_Enr] (3) AS Mounting_Metering_devices
	INNER JOIN [MD].[Metering_devices] AS Metering_devices ON  Mounting_Metering_devices.id_metering_device = Metering_devices.id_metering_device
	INNER JOIN [MD].[Models] AS Models ON Metering_devices.id_model = Models.id_model
	LEFT OUTER JOIN LAST_CALIBRATIONS AS LAST_CALIBRATIONS ON Mounting_Metering_devices.id_metering_device = LAST_CALIBRATIONS.id_metering_device
WHERE
	(DATEADD(month, Models.calibration_interval - 3, ISNULL(LAST_CALIBRATIONS.DATE_CALIBRATION, Metering_devices.date_calibration)) < GETDATE())
AND NOT EXISTS (SELECT * FROM [DOC].[Calibration] AS T WHERE  T.id_metering_device = Mounting_Metering_devices.id_metering_device 
		   AND  T.date_calibration_plan = (DATEADD(month, Models.calibration_interval, ISNULL(LAST_CALIBRATIONS.DATE_CALIBRATION, Metering_devices.date_calibration)))
		   AND T.calibration_passed IS NULL)
)
GO
/****** Object:  Table [DOC].[Responsible_persons]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DOC].[Responsible_persons](
	[id_responsible_person] [int] IDENTITY(1,1) NOT NULL,
	[responsible_person] [nvarchar](200) NOT NULL,
	[comments] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_Responsible_persons] PRIMARY KEY CLUSTERED 
(
	[id_responsible_person] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [DOC].[Tasks_of_calibration]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DOC].[Tasks_of_calibration](
	[id_task_of_calibration] [int] NOT NULL,
	[id_enr] [int] NOT NULL,
	[doc_date] [date] NOT NULL,
	[comments] [nvarchar](1000) NULL,
 CONSTRAINT [PK_Tasks_of_calibration] PRIMARY KEY CLUSTERED 
(
	[id_task_of_calibration] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [DOC].[Types_diagnostic_results]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DOC].[Types_diagnostic_results](
	[id_type_diagnostic_result] [int] IDENTITY(0,1) NOT NULL,
	[diagnostic_result] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_Types_diagnostic_results] PRIMARY KEY CLUSTERED 
(
	[id_type_diagnostic_result] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [DOC].[Types_of_repairs]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DOC].[Types_of_repairs](
	[id_type_of_repair] [int] IDENTITY(0,1) NOT NULL,
	[type_of_repair] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_Types_of_repairs] PRIMARY KEY CLUSTERED 
(
	[id_type_of_repair] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [DOC].[Types_unserviceability]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DOC].[Types_unserviceability](
	[id_type_unserviceability] [int] IDENTITY(0,1) NOT NULL,
	[type_unserviceability] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_Types_unserviceability] PRIMARY KEY CLUSTERED 
(
	[id_type_unserviceability] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [LOCATIONS].[Types_customers]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [LOCATIONS].[Types_customers](
	[id_type_customer] [int] IDENTITY(1,1) NOT NULL,
	[type_customer] [nvarchar](150) NOT NULL,
	[comments] [nvarchar](1000) NULL,
 CONSTRAINT [PK_TYPES_CUSTOMERS] PRIMARY KEY CLUSTERED 
(
	[id_type_customer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MD].[Category]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MD].[Category](
	[id_category] [int] IDENTITY(1,1) NOT NULL,
	[category] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
(
	[id_category] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MD].[Types_metering_devices]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MD].[Types_metering_devices](
	[id_type_metering_device] [int] IDENTITY(1,1) NOT NULL,
	[type_metering_device] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Types_metering_devices] PRIMARY KEY CLUSTERED 
(
	[id_type_metering_device] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [DOC].[Diagnostics] ADD  CONSTRAINT [DF_Diagnostics_batch_number]  DEFAULT ('n\a') FOR [batch_number]
GO
ALTER TABLE [DOC].[Diagnostics] ADD  CONSTRAINT [DF_Diagnostics_supplier_order]  DEFAULT ('n\a') FOR [supplier_order]
GO
ALTER TABLE [LOCATIONS].[Locations_metering_devices] ADD  CONSTRAINT [DF_Metering_devices_id_barcode]  DEFAULT ((0)) FOR [id_type_accounting]
GO
ALTER TABLE [DOC].[Calibration]  WITH CHECK ADD  CONSTRAINT [FK_Calibration_Locations_metering_devices] FOREIGN KEY([id_location_metering_device])
REFERENCES [LOCATIONS].[Locations_metering_devices] ([id_location_metering_device])
GO
ALTER TABLE [DOC].[Calibration] CHECK CONSTRAINT [FK_Calibration_Locations_metering_devices]
GO
ALTER TABLE [DOC].[Calibration]  WITH CHECK ADD  CONSTRAINT [FK_Calibration_Metering_devices] FOREIGN KEY([id_metering_device])
REFERENCES [MD].[Metering_devices] ([id_metering_device])
GO
ALTER TABLE [DOC].[Calibration] CHECK CONSTRAINT [FK_Calibration_Metering_devices]
GO
ALTER TABLE [DOC].[Calibration]  WITH CHECK ADD  CONSTRAINT [FK_Calibration_Suppliers] FOREIGN KEY([id_supplier])
REFERENCES [DOC].[Suppliers] ([id_supplier])
GO
ALTER TABLE [DOC].[Calibration] CHECK CONSTRAINT [FK_Calibration_Suppliers]
GO
ALTER TABLE [DOC].[Calibration]  WITH CHECK ADD  CONSTRAINT [FK_Calibration_Tasks_of_calibration] FOREIGN KEY([id_task_of_calibration])
REFERENCES [DOC].[Tasks_of_calibration] ([id_task_of_calibration])
GO
ALTER TABLE [DOC].[Calibration] CHECK CONSTRAINT [FK_Calibration_Tasks_of_calibration]
GO
ALTER TABLE [DOC].[Calibration]  WITH CHECK ADD  CONSTRAINT [FK_Calibration_Types_doc_calibrations_result] FOREIGN KEY([id_type_doc_calibration_result])
REFERENCES [DOC].[Types_doc_calibrations_result] ([id_type_doc_calibration_result])
GO
ALTER TABLE [DOC].[Calibration] CHECK CONSTRAINT [FK_Calibration_Types_doc_calibrations_result]
GO
ALTER TABLE [DOC].[Diagnostics]  WITH CHECK ADD  CONSTRAINT [FK_Diagnostics_Metering_devices] FOREIGN KEY([id_metering_device])
REFERENCES [MD].[Metering_devices] ([id_metering_device])
GO
ALTER TABLE [DOC].[Diagnostics] CHECK CONSTRAINT [FK_Diagnostics_Metering_devices]
GO
ALTER TABLE [DOC].[Diagnostics]  WITH CHECK ADD  CONSTRAINT [FK_Diagnostics_Suppliers] FOREIGN KEY([id_supplier])
REFERENCES [DOC].[Suppliers] ([id_supplier])
GO
ALTER TABLE [DOC].[Diagnostics] CHECK CONSTRAINT [FK_Diagnostics_Suppliers]
GO
ALTER TABLE [DOC].[Diagnostics]  WITH CHECK ADD  CONSTRAINT [FK_Diagnostics_Types_diagnostic_results] FOREIGN KEY([id_type_diagnostic_result])
REFERENCES [DOC].[Types_diagnostic_results] ([id_type_diagnostic_result])
GO
ALTER TABLE [DOC].[Diagnostics] CHECK CONSTRAINT [FK_Diagnostics_Types_diagnostic_results]
GO
ALTER TABLE [DOC].[Disposal]  WITH CHECK ADD  CONSTRAINT [FK_Disposal_DOC.Types_unserviceability] FOREIGN KEY([id_type_unserviceability])
REFERENCES [DOC].[Types_unserviceability] ([id_type_unserviceability])
GO
ALTER TABLE [DOC].[Disposal] CHECK CONSTRAINT [FK_Disposal_DOC.Types_unserviceability]
GO
ALTER TABLE [DOC].[Disposal]  WITH CHECK ADD  CONSTRAINT [FK_Disposal_MD.Metering_devices] FOREIGN KEY([id_metering_device])
REFERENCES [MD].[Metering_devices] ([id_metering_device])
GO
ALTER TABLE [DOC].[Disposal] CHECK CONSTRAINT [FK_Disposal_MD.Metering_devices]
GO
ALTER TABLE [DOC].[Mounting]  WITH CHECK ADD  CONSTRAINT [FK_Mounting_Locations_metering_devices] FOREIGN KEY([id_location_metering_device])
REFERENCES [LOCATIONS].[Locations_metering_devices] ([id_location_metering_device])
GO
ALTER TABLE [DOC].[Mounting] CHECK CONSTRAINT [FK_Mounting_Locations_metering_devices]
GO
ALTER TABLE [DOC].[Mounting]  WITH CHECK ADD  CONSTRAINT [FK_Mounting_Metering_devices] FOREIGN KEY([id_metering_device])
REFERENCES [MD].[Metering_devices] ([id_metering_device])
GO
ALTER TABLE [DOC].[Mounting] CHECK CONSTRAINT [FK_Mounting_Metering_devices]
GO
ALTER TABLE [DOC].[Mounting]  WITH CHECK ADD  CONSTRAINT [FK_Mounting_Responsible_persons] FOREIGN KEY([id_responsible_persons])
REFERENCES [DOC].[Responsible_persons] ([id_responsible_person])
GO
ALTER TABLE [DOC].[Mounting] CHECK CONSTRAINT [FK_Mounting_Responsible_persons]
GO
ALTER TABLE [DOC].[Removal]  WITH CHECK ADD  CONSTRAINT [FK_Removal_Locations_metering_devices] FOREIGN KEY([id_location_metering_device])
REFERENCES [LOCATIONS].[Locations_metering_devices] ([id_location_metering_device])
GO
ALTER TABLE [DOC].[Removal] CHECK CONSTRAINT [FK_Removal_Locations_metering_devices]
GO
ALTER TABLE [DOC].[Removal]  WITH CHECK ADD  CONSTRAINT [FK_Removal_Metering_devices] FOREIGN KEY([id_metering_device])
REFERENCES [MD].[Metering_devices] ([id_metering_device])
GO
ALTER TABLE [DOC].[Removal] CHECK CONSTRAINT [FK_Removal_Metering_devices]
GO
ALTER TABLE [DOC].[Removal]  WITH CHECK ADD  CONSTRAINT [FK_Removal_Responsible_persons] FOREIGN KEY([id_responsible_persons])
REFERENCES [DOC].[Responsible_persons] ([id_responsible_person])
GO
ALTER TABLE [DOC].[Removal] CHECK CONSTRAINT [FK_Removal_Responsible_persons]
GO
ALTER TABLE [DOC].[Repairs]  WITH CHECK ADD  CONSTRAINT [FK_Repairs_Metering_devices] FOREIGN KEY([id_metering_device])
REFERENCES [MD].[Metering_devices] ([id_metering_device])
GO
ALTER TABLE [DOC].[Repairs] CHECK CONSTRAINT [FK_Repairs_Metering_devices]
GO
ALTER TABLE [DOC].[Repairs]  WITH CHECK ADD  CONSTRAINT [FK_Repairs_Suppliers] FOREIGN KEY([id_supplier])
REFERENCES [DOC].[Suppliers] ([id_supplier])
GO
ALTER TABLE [DOC].[Repairs] CHECK CONSTRAINT [FK_Repairs_Suppliers]
GO
ALTER TABLE [DOC].[Repairs]  WITH CHECK ADD  CONSTRAINT [FK_Repairs_Types_of_repairs] FOREIGN KEY([id_type_of_repair])
REFERENCES [DOC].[Types_of_repairs] ([id_type_of_repair])
GO
ALTER TABLE [DOC].[Repairs] CHECK CONSTRAINT [FK_Repairs_Types_of_repairs]
GO
ALTER TABLE [DOC].[Tasks_of_calibration]  WITH CHECK ADD  CONSTRAINT [FK_Tasks_of_calibration_ENR] FOREIGN KEY([id_enr])
REFERENCES [LOCATIONS].[ENR] ([id_enr])
GO
ALTER TABLE [DOC].[Tasks_of_calibration] CHECK CONSTRAINT [FK_Tasks_of_calibration_ENR]
GO
ALTER TABLE [LOCATIONS].[Customers]  WITH CHECK ADD  CONSTRAINT [FK_Customers_Type_customers] FOREIGN KEY([id_type_customer])
REFERENCES [LOCATIONS].[Types_customers] ([id_type_customer])
GO
ALTER TABLE [LOCATIONS].[Customers] CHECK CONSTRAINT [FK_Customers_Type_customers]
GO
ALTER TABLE [LOCATIONS].[Locations_metering_devices]  WITH CHECK ADD  CONSTRAINT [FK_Locations_metering_devices_Connection_points] FOREIGN KEY([id_connection_point])
REFERENCES [LOCATIONS].[Connection_points] ([id_connection_point])
GO
ALTER TABLE [LOCATIONS].[Locations_metering_devices] CHECK CONSTRAINT [FK_Locations_metering_devices_Connection_points]
GO
ALTER TABLE [LOCATIONS].[Locations_metering_devices]  WITH CHECK ADD  CONSTRAINT [FK_Locations_metering_devices_Customers] FOREIGN KEY([id_customer])
REFERENCES [LOCATIONS].[Customers] ([id_customer])
GO
ALTER TABLE [LOCATIONS].[Locations_metering_devices] CHECK CONSTRAINT [FK_Locations_metering_devices_Customers]
GO
ALTER TABLE [LOCATIONS].[Locations_metering_devices]  WITH CHECK ADD  CONSTRAINT [FK_Locations_metering_devices_Delivery_points] FOREIGN KEY([id_delivery_point])
REFERENCES [LOCATIONS].[Delivery_points] ([id_delivery_point])
GO
ALTER TABLE [LOCATIONS].[Locations_metering_devices] CHECK CONSTRAINT [FK_Locations_metering_devices_Delivery_points]
GO
ALTER TABLE [LOCATIONS].[Locations_metering_devices]  WITH CHECK ADD  CONSTRAINT [FK_Locations_metering_devices_ENR] FOREIGN KEY([id_enr])
REFERENCES [LOCATIONS].[ENR] ([id_enr])
GO
ALTER TABLE [LOCATIONS].[Locations_metering_devices] CHECK CONSTRAINT [FK_Locations_metering_devices_ENR]
GO
ALTER TABLE [LOCATIONS].[Locations_metering_devices]  WITH CHECK ADD  CONSTRAINT [FK_Locations_metering_devices_Installation_sites] FOREIGN KEY([id_installation_site])
REFERENCES [LOCATIONS].[Installation_sites] ([id_installation_site])
GO
ALTER TABLE [LOCATIONS].[Locations_metering_devices] CHECK CONSTRAINT [FK_Locations_metering_devices_Installation_sites]
GO
ALTER TABLE [LOCATIONS].[Locations_metering_devices]  WITH CHECK ADD  CONSTRAINT [FK_Locations_metering_devices_Regions] FOREIGN KEY([id_region])
REFERENCES [LOCATIONS].[Regions] ([id_region])
GO
ALTER TABLE [LOCATIONS].[Locations_metering_devices] CHECK CONSTRAINT [FK_Locations_metering_devices_Regions]
GO
ALTER TABLE [LOCATIONS].[Locations_metering_devices]  WITH CHECK ADD  CONSTRAINT [FK_Locations_metering_devices_Types_accounting] FOREIGN KEY([id_type_accounting])
REFERENCES [LOCATIONS].[Types_accounting] ([id_type_accounting])
GO
ALTER TABLE [LOCATIONS].[Locations_metering_devices] CHECK CONSTRAINT [FK_Locations_metering_devices_Types_accounting]
GO
ALTER TABLE [MD].[Metering_devices]  WITH CHECK ADD  CONSTRAINT [FK_Metering_devices_Category] FOREIGN KEY([id_category])
REFERENCES [MD].[Category] ([id_category])
GO
ALTER TABLE [MD].[Metering_devices] CHECK CONSTRAINT [FK_Metering_devices_Category]
GO
ALTER TABLE [MD].[Metering_devices]  WITH CHECK ADD  CONSTRAINT [FK_Metering_devices_Models] FOREIGN KEY([id_model])
REFERENCES [MD].[Models] ([id_model])
GO
ALTER TABLE [MD].[Metering_devices] CHECK CONSTRAINT [FK_Metering_devices_Models]
GO
ALTER TABLE [MD].[Metering_devices]  WITH CHECK ADD  CONSTRAINT [FK_Metering_devices_Types_metering_devices] FOREIGN KEY([id_type_metering_device])
REFERENCES [MD].[Types_metering_devices] ([id_type_metering_device])
GO
ALTER TABLE [MD].[Metering_devices] CHECK CONSTRAINT [FK_Metering_devices_Types_metering_devices]
GO
ALTER TABLE [MD].[Models]  WITH CHECK ADD  CONSTRAINT [CK_Models] CHECK  (([calibration_interval]<=(120)))
GO
ALTER TABLE [MD].[Models] CHECK CONSTRAINT [CK_Models]
GO
/****** Object:  StoredProcedure [DOC].[Calibration_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [DOC].[Calibration_ADD_NEW]
	@id_task_of_calibration int,
	@date_calibration_plan date,
	@doc_date			date,
	@doc_nom			nvarchar(50),
	@id_metering_device int,
	@id_location_metering_device int,
	@id_supplier		int,
	@calibration_passed bit,
	@payment_invoice	nvarchar(50),
	@comments			nvarchar(1000) = null,
	@id_type_doc_calibration_result int,
	@doc_calibration_result_nom nvarchar(50), 
	@doc_calibration_result_date date,
	@result_notes nvarchar(1000)
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [DOC].[Calibration]
           ([id_task_of_calibration]
		   ,[date_calibration_plan]
		   ,[doc_date]
           ,[doc_nom]
           ,[id_metering_device]
		   ,[id_location_metering_device]
		   ,[id_supplier]
		   ,[calibration_passed]
		   ,[payment_invoice]
		   ,[comments]
		   ,[id_type_doc_calibration_result]
		   ,[doc_calibration_result_nom]
		   ,[doc_calibration_result_date]
		   ,[result_notes])
     VALUES
           (@id_task_of_calibration
		   ,@date_calibration_plan
		   ,@doc_date
           ,@doc_nom
           ,@id_metering_device
		   ,@id_location_metering_device
		   ,@id_supplier
		   ,@calibration_passed
		   ,@payment_invoice
		   ,@comments
		   ,@id_type_doc_calibration_result
		   ,@doc_calibration_result_nom
		   ,@doc_calibration_result_date
		   ,@result_notes)
END
GO
/****** Object:  StoredProcedure [DOC].[Calibration_ADD_NEW_ORDER]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [DOC].[Calibration_ADD_NEW_ORDER]
	@id_task_of_calibration int,
	@date_calibration_plan date,
	@doc_date			date,
	@doc_nom			nvarchar(50),
	@id_metering_device int,
	@id_location_metering_device int,
	@comments			nvarchar(1000) = NULL
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [DOC].[Calibration]
           ([id_task_of_calibration]
		   ,[date_calibration_plan]
		   ,[doc_date]
           ,[doc_nom]
           ,[id_metering_device]
		   ,[id_location_metering_device]
		   ,[comments])
     VALUES
           (@id_task_of_calibration
		   ,@date_calibration_plan
		   ,@doc_date
           ,@doc_nom
           ,@id_metering_device
		   ,@id_location_metering_device
		   ,@comments)
END
GO
/****** Object:  StoredProcedure [DOC].[Calibration_barcode_NOT_PASSED]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [DOC].[Calibration_barcode_NOT_PASSED]
	@barcode nvarchar(100),
	@id_supplier int,
	@payment_invoice nvarchar(50),
	@comments nvarchar(1000),
	@id_type_doc_calibration_result int,
	@doc_calibration_result_nom nvarchar(50), 
	@doc_calibration_result_date date,
	@result_notes nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
UPDATE [DOC].[Calibration]
   SET [calibration_passed]				= 0,
	   [id_supplier]					= @id_supplier,
	   [payment_invoice]				= @payment_invoice,
	   [comments]						= @comments,
	   [id_type_doc_calibration_result] = @id_type_doc_calibration_result,
	   [doc_calibration_result_nom]		= @doc_calibration_result_nom,
	   [doc_calibration_result_date]	= @doc_calibration_result_date,
	   [result_notes]					= @result_notes
 WHERE [barcode]=@barcode
END
GO
/****** Object:  StoredProcedure [DOC].[Calibration_barcode_PASSED]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [DOC].[Calibration_barcode_PASSED]
	@barcode nvarchar(100),
	@id_supplier int,
	@payment_invoice nvarchar(50),
	@comments nvarchar(1000),
	@id_type_doc_calibration_result int,
	@doc_calibration_result_nom nvarchar(50), 
	@doc_calibration_result_date date,
	@result_notes nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
UPDATE [DOC].[Calibration]
   SET [calibration_passed]				= 1,
       [id_supplier]					= @id_supplier,
	   [payment_invoice]				= @payment_invoice,
	   [comments]						= @comments,
	   [id_type_doc_calibration_result] = @id_type_doc_calibration_result,
	   [doc_calibration_result_nom]		= @doc_calibration_result_nom,
	   [doc_calibration_result_date]	= @doc_calibration_result_date,
	   [result_notes]					= @result_notes
 WHERE [barcode]=@barcode
END
GO
/****** Object:  StoredProcedure [DOC].[Calibration_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [DOC].[Calibration_DEL]
	@id_calibration int
AS
BEGIN
SET NOCOUNT ON
DELETE FROM [DOC].[Calibration]
      WHERE [id_calibration] = @id_calibration
END
GO
/****** Object:  StoredProcedure [DOC].[Calibration_NOT_PASSED]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [DOC].[Calibration_NOT_PASSED]
	@id_calibration int,
	@id_supplier int,
	@payment_invoice nvarchar(50),
	@comments nvarchar(1000),
	@id_type_doc_calibration_result int,
	@doc_calibration_result_nom nvarchar(50), 
	@doc_calibration_result_date date,
	@result_notes nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
UPDATE [DOC].[Calibration]
   SET [calibration_passed]				= 0,
       [id_supplier]					= @id_supplier,
	   [payment_invoice]				= @payment_invoice,
	   [comments]						= @comments,
	   [id_type_doc_calibration_result] = @id_type_doc_calibration_result,
	   [doc_calibration_result_nom]		= @doc_calibration_result_nom,
	   [doc_calibration_result_date]	= @doc_calibration_result_date,
	   [result_notes]					= @result_notes
 WHERE [id_calibration]=@id_calibration
END
GO
/****** Object:  StoredProcedure [DOC].[Calibration_PASSED]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [DOC].[Calibration_PASSED]
	@id_calibration int,
	@id_supplier int,
	@payment_invoice nvarchar(50),
	@comments nvarchar(1000),
	@id_type_doc_calibration_result int,
	@doc_calibration_result_nom nvarchar(50), 
	@doc_calibration_result_date date,
	@result_notes nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
UPDATE [DOC].[Calibration]
   SET [calibration_passed]				= 1,
       [id_supplier]					= @id_supplier,
	   [payment_invoice]				= @payment_invoice,
	   [comments]						= @comments,
	   [id_type_doc_calibration_result] = @id_type_doc_calibration_result,
	   [doc_calibration_result_nom]		= @doc_calibration_result_nom,
	   [doc_calibration_result_date]	= @doc_calibration_result_date,
	   [result_notes]					= @result_notes
 WHERE [id_calibration]=@id_calibration
END
GO
/****** Object:  StoredProcedure [DOC].[Calibration_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [DOC].[Calibration_UPD]
	@id_calibration int,
	@id_task_of_calibration int,
	@date_calibration_plan date,
	@doc_date			date,
	@doc_nom			nvarchar(50),
	@id_metering_device int,
	@id_location_metering_device int,
	@comments			nvarchar(1000),
	@id_supplier		int,
	@calibration_passed bit,
	@payment_invoice	nvarchar(50),
	@id_type_doc_calibration_result int,
	@doc_calibration_result_nom nvarchar(50), 
	@doc_calibration_result_date date,
	@result_notes nvarchar(1000)
AS
BEGIN
SET NOCOUNT ON
UPDATE [DOC].[Calibration]
   SET [id_task_of_calibration]			= @id_task_of_calibration,
	   [date_calibration_plan]			= @date_calibration_plan,
	   [doc_date]						= @doc_date,
	   [doc_nom]						= @doc_nom,
	   [id_metering_device]				= @id_metering_device,
	   [id_location_metering_device]    = @id_location_metering_device,
	   [comments]						= @comments,
	   [id_supplier]					= @id_supplier,
	   [calibration_passed]				= @calibration_passed,
	   [payment_invoice]				= @payment_invoice,
	   [id_type_doc_calibration_result] = @id_type_doc_calibration_result,
	   [doc_calibration_result_nom]		= @doc_calibration_result_nom,
	   [doc_calibration_result_date]	= @doc_calibration_result_date,
	   [result_notes]					= @result_notes
 WHERE [id_calibration]=@id_calibration
END
GO
/****** Object:  StoredProcedure [DOC].[Diagnostics_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [DOC].[Diagnostics_ADD_NEW]
	@id_metering_device int,
	@batch_number int,
	@date_of_sending date,
	@barcode nvarchar(100),
	@id_supplier int,
	@supplier_order nvarchar(100),
	@comments nvarchar(1000)=null,
	@date_of_receipt date,
	@id_type_diagnostic_result int,
	@payment_invoice nvarchar(50),
	@notes nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [DOC].[Diagnostics]
           ([id_metering_device]
           ,[batch_number]
		   ,[date_of_sending]
		   ,[barcode]
		   ,[id_supplier]
		   ,[supplier_order]
		   ,[comments]
		   ,[date_of_receipt]
		   ,[id_type_diagnostic_result]
		   ,[payment_invoice]
		   ,[notes])
     VALUES
           (@id_metering_device,
			@batch_number,
			@date_of_sending,
			@barcode,
			@id_supplier,
			@supplier_order,
			@comments,
			@date_of_receipt,
			@id_type_diagnostic_result,
			@payment_invoice,
			@notes)
END
GO
/****** Object:  StoredProcedure [DOC].[Diagnostics_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [DOC].[Diagnostics_DEL]
	@id_diagnostic int
AS
BEGIN
	DELETE FROM [DOC].[Diagnostics]
		WHERE [id_diagnostic]=@id_diagnostic
END
GO
/****** Object:  StoredProcedure [DOC].[Diagnostics_RETURN_MD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [DOC].[Diagnostics_RETURN_MD]
	@id_diagnostic int,
	@date_of_receipt date,
	@id_type_diagnostic_result int,
	@payment_invoice nvarchar(50),
	@notes nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
	SET NOCOUNT ON
	UPDATE [DOC].[Diagnostics]
		SET 
		 [date_of_receipt] = @date_of_receipt
		,[id_type_diagnostic_result] = @id_type_diagnostic_result
		,[payment_invoice] = @payment_invoice
		,[notes] = @notes
	WHERE [id_diagnostic]=@id_diagnostic
END
GO
/****** Object:  StoredProcedure [DOC].[Diagnostics_SEND_MD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [DOC].[Diagnostics_SEND_MD]
	@id_metering_device int,
	@batch_number int,
	@date_of_sending date,
	@barcode nvarchar(100),
	@id_supplier int,
	@supplier_order nvarchar(100),
	@comments nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [DOC].[Diagnostics]
           ([id_metering_device]
           ,[batch_number]
		   ,[date_of_sending]
		   ,[barcode]
		   ,[id_supplier]
		   ,[supplier_order]
		   ,[comments]
		   )
     VALUES
           (@id_metering_device,
			@batch_number,
			@date_of_sending,
			@barcode,
			@id_supplier,
			@supplier_order,
			@comments)
END
GO
/****** Object:  StoredProcedure [DOC].[Diagnostics_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [DOC].[Diagnostics_UPD]
	@id_diagnostic int,
	@id_metering_device int,
	@batch_number int,
	@date_of_sending date,
	@barcode nvarchar(100),
	@id_supplier int,
	@supplier_order nvarchar(100),
	@comments nvarchar(1000)=null,
	@date_of_receipt date,
	@id_type_diagnostic_result int,
	@payment_invoice nvarchar(50),
	@notes nvarchar(1000)=null
AS
BEGIN
	SET NOCOUNT ON
	UPDATE [DOC].[Diagnostics]
		SET 
		[id_metering_device] = @id_metering_device
		,[batch_number]	= @batch_number	
		,[date_of_sending] = @date_of_sending
		,[barcode] = @barcode
		,[id_supplier] = @id_supplier
		,[supplier_order] = @supplier_order
		,[comments] = @comments
		,[date_of_receipt] = @date_of_receipt
		,[id_type_diagnostic_result] = @id_type_diagnostic_result
		,[payment_invoice] = @payment_invoice
		,[notes] = @notes
	WHERE [id_diagnostic]=@id_diagnostic
END
GO
/****** Object:  StoredProcedure [DOC].[Disposal_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [DOC].[Disposal_ADD_NEW]
	@id_metering_device int,
	@doc_date date,
	@doc_nom nvarchar(50),
	@barcode nvarchar(100),
	@id_type_unserviceability int,
	@comments nvarchar(1000)=null
AS
BEGIN
	SET NOCOUNT ON
	INSERT INTO [DOC].[Disposal]
           ([id_metering_device]
           ,[doc_date]
           ,[doc_nom]
		   ,[barcode]
           ,[id_type_unserviceability]
           ,[comments])
     VALUES
           (@id_metering_device
           ,@doc_date
           ,@doc_nom
		   ,@barcode
           ,@id_type_unserviceability
           ,@comments)
END
GO
/****** Object:  StoredProcedure [DOC].[Disposal_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [DOC].[Disposal_DEL]
	@id_disposal int
AS
BEGIN
	DELETE FROM [DOC].[Disposal]
		WHERE [id_disposal]=@id_disposal
END
GO
/****** Object:  StoredProcedure [DOC].[Disposal_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [DOC].[Disposal_UPD]
	@id_disposal int,
	@id_metering_device int,
	@doc_date date,
	@doc_nom nvarchar(50),
	@barcode nvarchar(100),
	@id_type_unserviceability int,
	@comments nvarchar(1000)=null
AS
BEGIN
	SET NOCOUNT ON
	UPDATE [DOC].[Disposal]
		SET 
		[id_metering_device] = @id_metering_device,
		[doc_date] = @doc_date,
		[doc_nom] = @doc_nom,
		[barcode] = @barcode,
		[id_type_unserviceability] = @id_type_unserviceability,
		[comments] = @comments
	WHERE [id_disposal]=@id_disposal
END
GO
/****** Object:  StoredProcedure [DOC].[Mounting_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [DOC].[Mounting_ADD_NEW]
	@id_location_metering_device int,
	@date_mounting date,
	@id_metering_device int,
	@doc_date date = @date_mounting,
	@doc_nom nvarchar(50),
	@id_responsible_persons int,
	@barcode nvarchar(100),
	@comments nvarchar(1000)=null
AS
BEGIN
	SET NOCOUNT ON
	INSERT INTO [DOC].[Mounting]
           ([id_location_metering_device]
           ,[date_mounting]
           ,[doc_date]
           ,[doc_nom]
           ,[id_responsible_persons]
           ,[barcode]
           ,[comments]
		   ,[id_metering_device])
     VALUES
           (@id_location_metering_device
           ,@date_mounting
           ,@doc_date
           ,@doc_nom
           ,@id_responsible_persons
           ,@barcode
           ,@comments
		   ,@id_metering_device)
END
GO
/****** Object:  StoredProcedure [DOC].[Mounting_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [DOC].[Mounting_DEL]
	@id_mounting int
AS
BEGIN
	DELETE FROM [DOC].[Mounting]
		WHERE [id_mounting]=@id_mounting
END
GO
/****** Object:  StoredProcedure [DOC].[Mounting_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [DOC].[Mounting_UPD]
	@id_mounting int,
	@id_location_metering_device int,
	@date_mounting date,
	@id_metering_device int,
	@doc_date date,
	@doc_nom nvarchar(50),
	@id_responsible_persons int,
	@barcode nvarchar(100),
	@comments nvarchar(1000)=null
AS
BEGIN
UPDATE [DOC].[Mounting]
   SET [id_location_metering_device] = @id_location_metering_device,
	   [date_mounting] = @date_mounting,
	   [doc_date] = @doc_date,
	   [doc_nom] = @doc_nom,
	   [id_responsible_persons] = @id_responsible_persons,
	   [barcode] = @barcode,
	   [comments] = @comments
 WHERE [id_mounting]=@id_mounting
END
GO
/****** Object:  StoredProcedure [DOC].[Removal_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [DOC].[Removal_ADD_NEW]
	@id_location_metering_device int,
	@date_removal date,
	@id_metering_device int,
	@doc_date date = @date_removal,
	@doc_nom nvarchar(50),
	@id_responsible_persons int,
	@barcode nvarchar(100),
	@comments nvarchar(1000)=null
AS
BEGIN
INSERT INTO [DOC].[Removal]
           ([id_location_metering_device]
           ,[date_removal]
		   ,[id_metering_device]
           ,[doc_date]
           ,[doc_nom]
           ,[id_responsible_persons]
           ,[barcode]
           ,[comments])
     VALUES
           (@id_location_metering_device
           ,@date_removal
		   ,@id_metering_device
           ,@doc_date
           ,@doc_nom
           ,@id_responsible_persons
           ,@barcode
           ,@comments)
END
GO
/****** Object:  StoredProcedure [DOC].[Removal_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [DOC].[Removal_DEL]
	@id_removal int
AS
BEGIN
	DELETE FROM [DOC].[Removal]
		WHERE [id_removal]=@id_removal
END
GO
/****** Object:  StoredProcedure [DOC].[Removal_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [DOC].[Removal_UPD]
	@id_removal int,
	@id_location_metering_device int,
	@date_removal date,
	@id_metering_device int,
	@doc_date date,
	@doc_nom nvarchar(50),
	@id_responsible_persons int,
	@barcode nvarchar(100),
	@comments nvarchar(1000)=null
AS
BEGIN
UPDATE [DOC].[Removal]
   SET [id_location_metering_device] = @id_location_metering_device,
	   [date_removal] = @date_removal,
	   [id_metering_device] = @id_metering_device,
	   [doc_date] = @doc_date,
	   [doc_nom] = @doc_nom,
	   [id_responsible_persons] = @id_responsible_persons,
	   [barcode] = @barcode,
	   [comments] = @comments
 WHERE [id_removal]=@id_removal
END
GO
/****** Object:  StoredProcedure [DOC].[Repairs_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [DOC].[Repairs_ADD_NEW]
	@id_metering_device int,
	@batch_number int,
	@date_of_sending date,
	@barcode nvarchar(100),
	@id_supplier int,
	@supplier_order nvarchar(100),
	@comments nvarchar(1000)=null,
	@date_of_receipt date,
	@id_type_of_repair int,
	@repair_passed bit,
	@payment_invoice nvarchar(50),
	@notes nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [DOC].[Repairs]
           ([id_metering_device]
           ,[batch_number]
		   ,[date_of_sending]
		   ,[barcode]
		   ,[id_supplier]
		   ,[supplier_order]
		   ,[comments]
		   ,[date_of_receipt]
		   ,[id_type_of_repair]
		   ,[repair_passed]
		   ,[payment_invoice]
		   ,[notes])
     VALUES
           (@id_metering_device,
			@batch_number,
			@date_of_sending,
			@barcode,
			@id_supplier,
			@supplier_order,
			@comments,
			@date_of_receipt,
			@id_type_of_repair,
			@repair_passed,
			@payment_invoice,
			@notes)
END
GO
/****** Object:  StoredProcedure [DOC].[Repairs_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [DOC].[Repairs_DEL]
	@id_repair int
AS
BEGIN
	DELETE FROM [DOC].[Repairs]
		WHERE [id_repair]=@id_repair
END
GO
/****** Object:  StoredProcedure [DOC].[Repairs_RETURN_MD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [DOC].[Repairs_RETURN_MD]
	@id_repair int,
	@date_of_receipt date,
	@id_type_of_repair int,
	@repair_passed bit,
	@payment_invoice nvarchar(50),
	@notes nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
	SET NOCOUNT ON
	UPDATE [DOC].[Repairs]
		SET 
		 [date_of_receipt] = @date_of_receipt
		,[id_type_of_repair] = @id_type_of_repair
		,[repair_passed] = @repair_passed
		,[payment_invoice] = @payment_invoice
		,[notes] = @notes
	WHERE [id_repair]=@id_repair
END
GO
/****** Object:  StoredProcedure [DOC].[Repairs_SEND_MD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [DOC].[Repairs_SEND_MD]
	@id_metering_device int,
	@batch_number int,
	@date_of_sending date,
	@barcode nvarchar(100),
	@id_supplier int,
	@supplier_order nvarchar(100),
	@comments nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [DOC].[Repairs]
           ([id_metering_device]
           ,[batch_number]
		   ,[date_of_sending]
		   ,[barcode]
		   ,[id_supplier]
		   ,[supplier_order]
		   ,[comments]
		   )
     VALUES
           (@id_metering_device,
			@batch_number,
			@date_of_sending,
			@barcode,
			@id_supplier,
			@supplier_order,
			@comments)
END
GO
/****** Object:  StoredProcedure [DOC].[Repairs_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [DOC].[Repairs_UPD]
	@id_repair int,
	@id_metering_device int,
	@batch_number int,
	@date_of_sending date,
	@barcode nvarchar(100),
	@id_supplier int,
	@supplier_order nvarchar(100),
	@comments nvarchar(1000)=null,
	@date_of_receipt date,
	@id_type_of_repair int,
	@repair_passed bit,
	@payment_invoice nvarchar(50),
	@notes nvarchar(1000)=null
AS
BEGIN
	SET NOCOUNT ON
	UPDATE [DOC].[Repairs]
		SET 
		[id_metering_device] = @id_metering_device
		,[batch_number]	= @batch_number	
		,[date_of_sending] = @date_of_sending
		,[barcode] = @barcode
		,[id_supplier] = @id_supplier
		,[supplier_order] = @supplier_order
		,[comments] = @comments
		,[date_of_receipt] = @date_of_receipt
		,[id_type_of_repair] = @id_type_of_repair
		,[repair_passed] = @repair_passed
		,[payment_invoice] = @payment_invoice
		,[notes] = @notes
	WHERE [id_repair]=@id_repair
END
GO
/****** Object:  StoredProcedure [DOC].[Responsible_persons_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [DOC].[Responsible_persons_ADD_NEW]
	@responsible_person nvarchar(200),
	@comments nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [DOC].[Responsible_persons]
           ([responsible_person]
           ,[comments])
     VALUES
           (@responsible_person
           ,@comments)
END
GO
/****** Object:  StoredProcedure [DOC].[Responsible_persons_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [DOC].[Responsible_persons_DEL]
	@id_responsible_person int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [DOC].[Responsible_persons]
		WHERE [id_responsible_person]=@id_responsible_person
END
GO
/****** Object:  StoredProcedure [DOC].[Responsible_persons_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [DOC].[Responsible_persons_UPD]
	@id_responsible_person int,
	@responsible_person nvarchar(200),
	@comments nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
UPDATE [DOC].[Responsible_persons]
   SET [responsible_person] = @responsible_person,
	   [comments] = @comments
 WHERE [id_responsible_person]=@id_responsible_person
END
GO
/****** Object:  StoredProcedure [DOC].[Suppliers_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [DOC].[Suppliers_ADD_NEW]
	@supplier			nvarchar(150),
	@comments			nvarchar(1000)=null,
	@contacts			nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [DOC].[Suppliers]
           ([supplier]
		   ,[comments]
		   ,[contacts])
     VALUES
           (@supplier
           ,@comments
		   ,@contacts)
END
GO
/****** Object:  StoredProcedure [DOC].[Suppliers_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [DOC].[Suppliers_DEL]
	@id_supplier int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [DOC].[Suppliers]
		WHERE [id_supplier]=@id_supplier
END
GO
/****** Object:  StoredProcedure [DOC].[Suppliers_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [DOC].[Suppliers_UPD]
	@id_supplier int,
	@supplier			nvarchar(150),
	@comments			nvarchar(1000)=null,
	@contacts			nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
UPDATE [DOC].[Suppliers]
   SET [supplier] = @supplier
      ,[comments] = @comments
      ,[contacts] = @contacts

 WHERE [id_supplier]=@id_supplier
END
GO
/****** Object:  StoredProcedure [DOC].[Tasks_of_calibration_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [DOC].[Tasks_of_calibration_ADD_NEW]
	@id_enr int,
	@auto bit=0,
	@doc_date date = NULL,
	@comments nvarchar(1000) = NULL
AS
BEGIN
SET NOCOUNT ON
DECLARE @id_task_of_calibration int = NEXT VALUE FOR [DOC].[SEQ_Tasks_of_calibration]
DECLARE @doc_nom int = 1, @id_metering_device int, @id_location_metering_device int, @date_calibration_plan date, @doc_date_calibration date, @doc_nom_str nvarchar(32)
	IF @doc_date IS NULL SET @doc_date = GETDATE()
	BEGIN TRAN;
	INSERT INTO [DOC].[Tasks_of_calibration]
           ([id_task_of_calibration]
		   ,[id_enr]
		   ,[doc_date]
           ,[comments])
     VALUES
           (@id_task_of_calibration
		   ,@id_enr
		   ,@doc_date
           ,@comments)
	IF @auto=1
	BEGIN
		DECLARE TO_CALIBRATION CURSOR FOR
		SELECT T.id_metering_device, T. id_location_metering_device, T.date_calibration_plan FROM [MD].[NEXT_CALIBRATION_MD] (3,GETDATE(),@id_enr) AS T
		OPEN TO_CALIBRATION
		BEGIN TRY
			FETCH NEXT FROM TO_CALIBRATION INTO @id_metering_device, @id_location_metering_device, @date_calibration_plan
			IF @@FETCH_STATUS != 0 
				BEGIN
					ROLLBACK TRAN
				END
			ELSE
				BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @doc_nom_str = CAST(@id_task_of_calibration AS nvarchar) + '-' + RIGHT('0000000' + CAST(@doc_nom AS nvarchar),8)
					SET @doc_date_calibration = DATEADD(month, 1, @date_calibration_plan)
					exec DOC.Calibration_ADD_NEW_ORDER @id_task_of_calibration, @date_calibration_plan ,@doc_date_calibration,	@doc_nom_str,	@id_metering_device,	@id_location_metering_device 
					SET @doc_nom = @doc_nom + 1;
					FETCH NEXT FROM TO_CALIBRATION INTO @id_metering_device, @id_location_metering_device, @date_calibration_plan
				END
				COMMIT TRAN;
			END
			CLOSE TO_CALIBRATION
			DEALLOCATE TO_CALIBRATION
		END TRY
		BEGIN CATCH
			CLOSE TO_CALIBRATION
			DEALLOCATE TO_CALIBRATION
			ROLLBACK TRAN
		END CATCH
	END
END
GO
/****** Object:  StoredProcedure [DOC].[Tasks_of_calibration_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [DOC].[Tasks_of_calibration_DEL]
	@id_task_of_calibration int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [DOC].[Tasks_of_calibration]
		WHERE [id_task_of_calibration]=@id_task_of_calibration
END
GO
/****** Object:  StoredProcedure [DOC].[Tasks_of_calibration_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [DOC].[Tasks_of_calibration_UPD]
	@id_task_of_calibration int,
	@doc_date date,
	@comments nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
UPDATE [DOC].[Tasks_of_calibration]
   SET [doc_date] = @doc_date,
	   [comments] = @comments
 WHERE [id_task_of_calibration]=@id_task_of_calibration
END
GO
/****** Object:  StoredProcedure [DOC].[Types_diagnostic_results_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [DOC].[Types_diagnostic_results_ADD_NEW]
	@diagnostic_result		nvarchar(200)
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [DOC].[Types_diagnostic_results]
           ([diagnostic_result])
     VALUES
           (@diagnostic_result)
END
GO
/****** Object:  StoredProcedure [DOC].[Types_diagnostic_results_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [DOC].[Types_diagnostic_results_DEL]
	@id_type_diagnostic_result int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [DOC].[Types_diagnostic_results]
		WHERE [id_type_diagnostic_result]=@id_type_diagnostic_result
END
GO
/****** Object:  StoredProcedure [DOC].[Types_diagnostic_results_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [DOC].[Types_diagnostic_results_UPD]
	@id_type_diagnostic_result	int,
	@diagnostic_result			nvarchar(200)
AS
BEGIN
SET NOCOUNT ON
UPDATE [DOC].[Types_diagnostic_results]
   SET [diagnostic_result] = @diagnostic_result

 WHERE [id_type_diagnostic_result]=@id_type_diagnostic_result
END
GO
/****** Object:  StoredProcedure [DOC].[Types_doc_calibrations_result_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [DOC].[Types_doc_calibrations_result_ADD_NEW]
	@type_doc_calibration_result		nvarchar(200)
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [DOC].[Types_doc_calibrations_result]
           ([type_doc_calibration_result])
     VALUES
           (@type_doc_calibration_result)
END
GO
/****** Object:  StoredProcedure [DOC].[Types_doc_calibrations_result_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [DOC].[Types_doc_calibrations_result_DEL]
	@id_type_doc_calibration_result int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [DOC].[Types_doc_calibrations_result]
		WHERE [id_type_doc_calibration_result]=@id_type_doc_calibration_result
END
GO
/****** Object:  StoredProcedure [DOC].[Types_doc_calibrations_result_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [DOC].[Types_doc_calibrations_result_UPD]
	@id_type_doc_calibration_result		int,
	@type_doc_calibration_result		nvarchar(200)
AS
BEGIN
SET NOCOUNT ON
UPDATE [DOC].[Types_doc_calibrations_result]
   SET [type_doc_calibration_result] = @type_doc_calibration_result

 WHERE [id_type_doc_calibration_result]=@id_type_doc_calibration_result
END
GO
/****** Object:  StoredProcedure [DOC].[Types_of_repairs_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [DOC].[Types_of_repairs_ADD_NEW]
	@type_of_repair		nvarchar(200)
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [DOC].[Types_of_repairs]
           ([type_of_repair])
     VALUES
           (@type_of_repair)
END
GO
/****** Object:  StoredProcedure [DOC].[Types_of_repairs_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [DOC].[Types_of_repairs_DEL]
	@id_type_of_repair int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [DOC].[Types_of_repairs]
		WHERE [id_type_of_repair]=@id_type_of_repair
END
GO
/****** Object:  StoredProcedure [DOC].[Types_of_repairs_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [DOC].[Types_of_repairs_UPD]
	@id_type_of_repair	int,
	@type_of_repair		nvarchar(200)
AS
BEGIN
SET NOCOUNT ON
UPDATE [DOC].[Types_of_repairs]
   SET [type_of_repair] = @type_of_repair

 WHERE [id_type_of_repair]=@id_type_of_repair
END
GO
/****** Object:  StoredProcedure [DOC].[Types_transactions_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [DOC].[Types_transactions_ADD_NEW]
	@type_transaction		nvarchar(50)
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [DOC].[Types_transactions]
           ([type_transaction])
     VALUES
           (@type_transaction)
END
GO
/****** Object:  StoredProcedure [DOC].[Types_transactions_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [DOC].[Types_transactions_DEL]
	@id_type_transaction int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [DOC].[Types_transactions]
		WHERE [id_type_transaction]=@id_type_transaction
END
GO
/****** Object:  StoredProcedure [DOC].[Types_transactions_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [DOC].[Types_transactions_UPD]
	@id_type_transaction	int,
	@type_transaction		nvarchar(50)
AS
BEGIN
SET NOCOUNT ON
UPDATE [DOC].[Types_transactions]
   SET [type_transaction] = @type_transaction

 WHERE [id_type_transaction]=@id_type_transaction
END
GO
/****** Object:  StoredProcedure [DOC].[Types_unserviceability_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [DOC].[Types_unserviceability_ADD_NEW]
	@type_unserviceability		nvarchar(200)
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [DOC].[Types_unserviceability]
           ([type_unserviceability])
     VALUES
           (@type_unserviceability)
END
GO
/****** Object:  StoredProcedure [DOC].[Types_unserviceability_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [DOC].[Types_unserviceability_DEL]
	@id_type_unserviceability int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [DOC].[Types_unserviceability]
		WHERE [id_type_unserviceability]=@id_type_unserviceability
END
GO
/****** Object:  StoredProcedure [DOC].[Types_unserviceability_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [DOC].[Types_unserviceability_UPD]
	@id_type_unserviceability	int,
	@type_unserviceability		nvarchar(200)
AS
BEGIN
SET NOCOUNT ON
UPDATE [DOC].[Types_unserviceability]
   SET [type_unserviceability] = @type_unserviceability

 WHERE [id_type_unserviceability]=@id_type_unserviceability
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Connection_points_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [LOCATIONS].[Connection_points_ADD_NEW]
	@connection_point nvarchar(150),
	@comments nvarchar(1000)=null,
	@adr nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [LOCATIONS].[Connection_points]
           ([connection_point]
           ,[comments]
		   ,[adr])
     VALUES
           (@connection_point
           ,@comments
           ,@adr)
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Connection_points_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [LOCATIONS].[Connection_points_DEL]
	@id_connection_point int
AS
BEGIN
SET NOCOUNT ON
	DELETE FROM [LOCATIONS].[Connection_points]
		WHERE [id_connection_point]=@id_connection_point
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Connection_points_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [LOCATIONS].[Connection_points_UPD]
	@id_connection_point int,
	@connection_point nvarchar(150),
	@comments nvarchar(1000)=null,
	@adr nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
UPDATE [LOCATIONS].[Connection_points]
   SET [connection_point] = @connection_point
      ,[comments] = @comments
      ,[adr] = @adr

 WHERE [id_connection_point]=@id_connection_point
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Customers_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [LOCATIONS].[Customers_ADD_NEW]
	@customer			nvarchar(150),
	@id_type_customer	int,
	@comments			nvarchar(1000)=null,
	@contacts			nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [LOCATIONS].[Customers]
           ([customer]
           ,[id_type_customer]
		   ,[comments]
		   ,[contacts])
     VALUES
           (@customer
           ,@id_type_customer
           ,@comments
		   ,@contacts)
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Customers_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [LOCATIONS].[Customers_DEL]
	@id_customer int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [LOCATIONS].[Customers]
		WHERE [id_customer]=@id_customer
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Customers_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [LOCATIONS].[Customers_UPD]
	@id_customer int,
	@customer			nvarchar(150),
	@id_type_customer	int,
	@comments			nvarchar(1000)=null,
	@contacts			nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
UPDATE [LOCATIONS].[Customers]
   SET [customer] = @customer
	  ,[id_type_customer]=@id_type_customer
      ,[comments] = @comments
      ,[contacts] = @contacts

 WHERE [id_customer]=@id_customer
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Delivery_points_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [LOCATIONS].[Delivery_points_ADD_NEW]
	@delivery_point			nvarchar(150)
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [LOCATIONS].[Delivery_points]
           ([delivery_point])
     VALUES
           (@delivery_point)
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Delivery_points_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [LOCATIONS].[Delivery_points_DEL]
	@id_delivery_point int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [LOCATIONS].[Delivery_points]
		WHERE [id_delivery_point]=@id_delivery_point
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Delivery_points_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [LOCATIONS].[Delivery_points_UPD]
	@id_delivery_point	int,
	@delivery_point		nvarchar(150)
AS
BEGIN
SET NOCOUNT ON
UPDATE [LOCATIONS].[Delivery_points]
   SET [delivery_point] = @delivery_point

 WHERE [id_delivery_point]=@id_delivery_point
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[ENR_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [LOCATIONS].[ENR_ADD_NEW]
	@enr		nvarchar(150)
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [LOCATIONS].[ENR]
           ([enr])
     VALUES
           (@enr)
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[ENR_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [LOCATIONS].[ENR_DEL]
	@id_enr int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [LOCATIONS].[ENR]
		WHERE [id_enr]=@id_enr
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[ENR_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [LOCATIONS].[ENR_UPD]
	@id_enr	int,
	@enr		nvarchar(150)
AS
BEGIN
SET NOCOUNT ON
UPDATE [LOCATIONS].[ENR]
   SET [enr] = @enr

 WHERE [id_enr]=@id_enr
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Installation_sites_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [LOCATIONS].[Installation_sites_ADD_NEW]
	@installation_site		nvarchar(150)
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [LOCATIONS].[Installation_sites]
           ([installation_site])
     VALUES
           (@installation_site)
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Installation_sites_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [LOCATIONS].[Installation_sites_DEL]
	@id_installation_site int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [LOCATIONS].[Installation_sites]
		WHERE [id_installation_site]=@id_installation_site
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Installation_sites_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [LOCATIONS].[Installation_sites_UPD]
	@id_installation_site	int,
	@installation_site	nvarchar(150)
AS
BEGIN
SET NOCOUNT ON
UPDATE [LOCATIONS].[Installation_sites]
   SET [installation_site] = @installation_site

 WHERE [id_installation_site]=@id_installation_site
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Locations_metering_devices_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [LOCATIONS].[Locations_metering_devices_ADD_NEW]
	@id_region				int,
	@id_enr					int,
	@id_delivery_point		int,
	@id_installation_site	int,
	@id_customer			int,
	@id_connection_point	int,
	@id_type_accounting		int,
	@comments		nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [LOCATIONS].[Locations_metering_devices]
           ([id_region]
           ,[id_enr]
           ,[id_delivery_point]
           ,[id_installation_site]
           ,[id_customer]
           ,[id_connection_point]
           ,[id_type_accounting]
           ,[comments])
     VALUES
           (@id_region
           ,@id_enr
           ,@id_delivery_point
           ,@id_installation_site
           ,@id_customer
           ,@id_connection_point
           ,@id_type_accounting
           ,@comments)
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Locations_metering_devices_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [LOCATIONS].[Locations_metering_devices_DEL]
	@id_location_metering_device int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [LOCATIONS].[Locations_metering_devices]
		WHERE [id_location_metering_device]=@id_location_metering_device
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Locations_metering_devices_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [LOCATIONS].[Locations_metering_devices_UPD]
	@id_location_metering_device int,
	@id_type_accounting		int,
	@comments		nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
UPDATE [LOCATIONS].[Locations_metering_devices]
   SET	[id_type_accounting]	= @id_type_accounting,
		[comments] = @comments

 WHERE [id_location_metering_device]=@id_location_metering_device
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Regions_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [LOCATIONS].[Regions_ADD_NEW]
	@region		nvarchar(150)
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [LOCATIONS].[Regions]
           ([region])
     VALUES
           (@region)
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Regions_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [LOCATIONS].[Regions_DEL]
	@id_region int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [LOCATIONS].[Regions]
		WHERE [id_region]=@id_region
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Regions_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [LOCATIONS].[Regions_UPD]
	@id_region	int,
	@region		nvarchar(150)
AS
BEGIN
SET NOCOUNT ON
UPDATE [LOCATIONS].[Regions]
   SET [region] = @region

 WHERE [id_region]=@id_region
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Types_accounting_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [LOCATIONS].[Types_accounting_ADD_NEW]
	@type_accounting		nvarchar(100)
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [LOCATIONS].[Types_accounting]
           ([type_accounting])
     VALUES
           (@type_accounting)
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Types_accounting_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [LOCATIONS].[Types_accounting_DEL]
	@id_type_accounting int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [LOCATIONS].[Types_accounting]
		WHERE [id_type_accounting]=@id_type_accounting
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Types_accounting_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [LOCATIONS].[Types_accounting_UPD]
	@id_type_accounting	int,
	@type_accounting	nvarchar(100)
AS
BEGIN
SET NOCOUNT ON
UPDATE [LOCATIONS].[Types_accounting]
   SET [type_accounting] = @type_accounting

 WHERE [id_type_accounting]=@id_type_accounting
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Types_customers_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [LOCATIONS].[Types_customers_ADD_NEW]
	@type_customer		nvarchar(150),
	@comments			nvarchar(1000)=null
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [LOCATIONS].[Types_customers]
           ([type_customer],[comments])
     VALUES
           (@type_customer, @comments)
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Types_customers_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [LOCATIONS].[Types_customers_DEL]
	@id_type_customer int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [LOCATIONS].[Types_customers]
		WHERE [id_type_customer]=@id_type_customer
END
GO
/****** Object:  StoredProcedure [LOCATIONS].[Types_customers_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [LOCATIONS].[Types_customers_UPD]
	@id_type_customer	int,
	@type_customer			nvarchar(150),
	@comments				nvarchar(1000)
AS
BEGIN
SET NOCOUNT ON
UPDATE [LOCATIONS].[Types_customers]
   SET [type_customer] = @type_customer,
	   [comments] = @comments

 WHERE [id_type_customer]=@id_type_customer
END
GO
/****** Object:  StoredProcedure [MD].[Category_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [MD].[Category_ADD_NEW]
	@category		nvarchar(200)
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [MD].[Category]
           ([category])
     VALUES
           (@category)
END
GO
/****** Object:  StoredProcedure [MD].[Category_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [MD].[Category_DEL]
	@id_category int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [MD].[Category]
		WHERE [id_category]=@id_category
END
GO
/****** Object:  StoredProcedure [MD].[Category_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [MD].[Category_UPD]
	@id_category	int,
	@category	nvarchar(200)
AS
BEGIN
SET NOCOUNT ON
UPDATE [MD].[Category]
   SET [category] = @category

 WHERE [id_category]=@id_category
END
GO
/****** Object:  StoredProcedure [MD].[Metering_devices_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [MD].[Metering_devices_ADD_NEW]
	@id_model					int,		
	@serial_number				nvarchar(50),
	@passport_number			nvarchar(50),
	@id_category				int,
	@id_type_metering_device	int,
	@date_calibration			date,
	@nominal_value				decimal(8,3),
	@comments					nvarchar(1000)=null,
	@barcode					nvarchar(100),
	@certificate				nvarchar(100)
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [MD].[Metering_devices]
           ([id_model],[serial_number],[passport_number],[id_category],[id_type_metering_device],[nominal_value],[date_calibration],[comments],[barcode],[certificate])
     VALUES
           (@id_model,@serial_number,@passport_number,@id_category,@id_type_metering_device,@nominal_value,@date_calibration,@comments,@barcode,@certificate)
END
GO
/****** Object:  StoredProcedure [MD].[Metering_devices_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MD].[Metering_devices_DEL]
	@id_metering_devices int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [MD].[Metering_devices]
		WHERE [id_metering_device]=@id_metering_devices
END
GO
/****** Object:  StoredProcedure [MD].[Metering_devices_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MD].[Metering_devices_UPD]
	@id_metering_device			int,
	@id_model					int,		
	@serial_number				nvarchar(50),
	@passport_number			nvarchar(50),
	@id_category				int,
	@id_type_metering_device	int,
	@date_calibration			date,
	@nominal_value				decimal(8,3),
	@comments					nvarchar(1000)=null,
	@barcode					nvarchar(100),
	@certificate				nvarchar(100)
AS
BEGIN
SET NOCOUNT ON
UPDATE [MD].[Metering_devices]
   SET	 [id_model] = @id_model
		,[serial_number] = @serial_number
		,[passport_number] = @passport_number
		,[id_category] = @id_category
		,[id_type_metering_device] = @id_type_metering_device
		,[date_calibration] = @date_calibration
		,[nominal_value] = @nominal_value
		,[comments] = @comments
		,[barcode] = @barcode
		,[certificate] = @certificate

 WHERE [id_metering_device]=@id_metering_device
END
GO
/****** Object:  StoredProcedure [MD].[Models_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [MD].[Models_ADD_NEW]
	@model		nvarchar(200),
	@calibration_interval int
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [MD].[Models]
           ([model],[calibration_interval])
     VALUES
           (@model,@calibration_interval)
END
GO
/****** Object:  StoredProcedure [MD].[Models_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [MD].[Models_DEL]
	@id_model int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [MD].[Models]
		WHERE [id_model]=@id_model
END
GO
/****** Object:  StoredProcedure [MD].[Models_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [MD].[Models_UPD]
	@id_model int,
	@model		nvarchar(200),
	@calibration_interval int
AS
BEGIN
SET NOCOUNT ON
UPDATE [MD].[Models]
   SET [model] = @model
      ,[calibration_interval] = @calibration_interval
 WHERE [id_model] = @id_model
END
GO
/****** Object:  StoredProcedure [MD].[Types_metering_devices_ADD_NEW]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [MD].[Types_metering_devices_ADD_NEW]
	@type_metering_device		nvarchar(50)
AS
BEGIN
SET NOCOUNT ON
INSERT INTO [MD].[Types_metering_devices]
           ([type_metering_device])
     VALUES
           (@type_metering_device)
END
GO
/****** Object:  StoredProcedure [MD].[Types_metering_devices_DEL]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [MD].[Types_metering_devices_DEL]
	@id_type_metering_device int
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM [MD].[Types_metering_devices]
		WHERE [id_type_metering_device]=@id_type_metering_device
END
GO
/****** Object:  StoredProcedure [MD].[Types_metering_devices_UPD]    Script Date: 14.08.2021 1:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [MD].[Types_metering_devices_UPD]
	@id_type_metering_device	int,
	@type_metering_device	nvarchar(50)
AS
BEGIN
SET NOCOUNT ON
UPDATE [MD].[Types_metering_devices]
   SET [type_metering_device] = @type_metering_device

 WHERE [id_type_metering_device]=@id_type_metering_device
END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Orders_on_calibration"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 119
               Right = 277
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Calibration"
            Begin Extent = 
               Top = 6
               Left = 315
               Bottom = 136
               Right = 562
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Locations_metering_devices"
            Begin Extent = 
               Top = 6
               Left = 600
               Bottom = 136
               Right = 839
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Regions"
            Begin Extent = 
               Top = 6
               Left = 877
               Bottom = 102
               Right = 1051
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ENR"
            Begin Extent = 
               Top = 6
               Left = 1089
               Bottom = 102
               Right = 1263
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Delivery_points"
            Begin Extent = 
               Top = 102
               Left = 877
               Bottom = 198
               Right = 1055
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Installation_sites"
            Begin Extent = 
               Top = 102
               Left = 1093
               Bottom = 198
               Right = ' , @level0type=N'SCHEMA',@level0name=N'DOC', @level1type=N'VIEW',@level1name=N'FAILED_CALIBRATIONS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'1278
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Customers"
            Begin Extent = 
               Top = 120
               Left = 38
               Bottom = 250
               Right = 220
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Connection_points"
            Begin Extent = 
               Top = 138
               Left = 258
               Bottom = 268
               Right = 455
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Types_accounting"
            Begin Extent = 
               Top = 138
               Left = 493
               Bottom = 234
               Right = 685
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Suppliers"
            Begin Extent = 
               Top = 198
               Left = 723
               Bottom = 328
               Right = 897
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Types_doc_calibrations_result"
            Begin Extent = 
               Top = 198
               Left = 935
               Bottom = 294
               Right = 1182
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'DOC', @level1type=N'VIEW',@level1name=N'FAILED_CALIBRATIONS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'DOC', @level1type=N'VIEW',@level1name=N'FAILED_CALIBRATIONS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'DOC', @level1type=N'VIEW',@level1name=N'LAST_TRANSACTION_AT_METERING_DEVICES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'DOC', @level1type=N'VIEW',@level1name=N'LAST_TRANSACTION_AT_METERING_DEVICES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'DOC', @level1type=N'VIEW',@level1name=N'LOCATIONS_METERING_DEVICES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'DOC', @level1type=N'VIEW',@level1name=N'LOCATIONS_METERING_DEVICES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'DOC', @level1type=N'VIEW',@level1name=N'LOCATIONS_METERING_DEVICES_CALIBRATIONS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'DOC', @level1type=N'VIEW',@level1name=N'LOCATIONS_METERING_DEVICES_CALIBRATIONS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Orders_on_calibration"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 119
               Right = 277
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Calibration"
            Begin Extent = 
               Top = 6
               Left = 315
               Bottom = 136
               Right = 562
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Locations_metering_devices"
            Begin Extent = 
               Top = 6
               Left = 600
               Bottom = 136
               Right = 839
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Regions"
            Begin Extent = 
               Top = 6
               Left = 877
               Bottom = 102
               Right = 1051
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ENR"
            Begin Extent = 
               Top = 6
               Left = 1089
               Bottom = 102
               Right = 1263
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Delivery_points"
            Begin Extent = 
               Top = 102
               Left = 877
               Bottom = 198
               Right = 1055
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Installation_sites"
            Begin Extent = 
               Top = 102
               Left = 1093
               Bottom = 198
               Right = ' , @level0type=N'SCHEMA',@level0name=N'DOC', @level1type=N'VIEW',@level1name=N'ORDERS_ON_CALIBRATIONS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'1278
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Customers"
            Begin Extent = 
               Top = 120
               Left = 38
               Bottom = 250
               Right = 220
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Connection_points"
            Begin Extent = 
               Top = 138
               Left = 258
               Bottom = 268
               Right = 455
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Types_accounting"
            Begin Extent = 
               Top = 138
               Left = 493
               Bottom = 234
               Right = 685
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'DOC', @level1type=N'VIEW',@level1name=N'ORDERS_ON_CALIBRATIONS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'DOC', @level1type=N'VIEW',@level1name=N'ORDERS_ON_CALIBRATIONS'
GO
