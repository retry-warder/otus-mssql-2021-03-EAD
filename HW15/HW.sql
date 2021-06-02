CREATE DATABASE [AccountingObjects]
 CONTAINMENT = NONE
 ON  PRIMARY 
(NAME = N'AO_Primary', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\DATA\AccountingObjects.mdf' , SIZE = 1048576KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'AO_Log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\DATA\Accounting Objects.ldf' , SIZE = 364544KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO

CREATE TABLE [Objects_hierarchy] (
	id_object int NOT NULL,
	id_parent int NOT NULL,
	date_of_change datetime2 NOT NULL,
	active bit NOT NULL,
	id int NOT NULL,
  CONSTRAINT [PK_OBJECTS_HIERARCHY] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [Objects] (
	id_object int NOT NULL,
	id_type_objects int NOT NULL,
	object nvarchar(200) NOT NULL,
	description nvarchar(200) NOT NULL,
  CONSTRAINT [PK_OBJECTS] PRIMARY KEY CLUSTERED
  (
  [id_object] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [Types_objects] (
	id_type_object int NOT NULL,
	type_objects nvarchar(150) NOT NULL,
  CONSTRAINT [PK_TYPES_OBJECTS] PRIMARY KEY CLUSTERED
  (
  [id_type_object] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [Locations] (
	id_location int NOT NULL,
	location nvarchar(150) NOT NULL,
	comments nvarchar(1000),
	address nvarchar(1000) NOT NULL,
	id_regions int NOT NULL,
	id_customer int NOT NULL,
  CONSTRAINT [PK_LOCATIONS] PRIMARY KEY CLUSTERED
  (
  [id_location] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [Object_metering_devices] (
	id_object int NOT NULL,
	id_location int NOT NULL,
	id_metering_device int NOT NULL,
	date_removal datetime2,
	id int NOT NULL,
  CONSTRAINT [PK_OBJECT_METERING_DEVICES] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [Metering_devices] (
	id_metering_device int NOT NULL,
	id_model int NOT NULL,
	serial_number nvarchar(50) NOT NULL,
	passport_number nvarchar(50) NOT NULL,
	id_type_metering_device int NOT NULL,
	date_calibration datetime2 NOT NULL,
	comments nvarchar(1000),
	defective bit NOT NULL,
  CONSTRAINT [PK_METERING_DEVICES] PRIMARY KEY CLUSTERED
  (
  [id_metering_device] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [Models] (
	id_model int NOT NULL,
	model nvarchar(200) NOT NULL,
	calibration_interval int NOT NULL,
  CONSTRAINT [PK_MODELS] PRIMARY KEY CLUSTERED
  (
  [id_model] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [Types_Metering_devices] (
	id_type_metering_device int NOT NULL,
	type_metering_device nvarchar(200) NOT NULL,
  CONSTRAINT [PK_TYPES_METERING_DEVICES] PRIMARY KEY CLUSTERED
  (
  [id_type_metering_device] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [Calibration_metering_devices] (
	id int NOT NULL,
	id_metering_device int NOT NULL,
	doc_date datetime2 NOT NULL,
	doc_no nvarchar(50) NOT NULL,
	comments nvarchar(1000),
	date_calibration datetime2,
	defective bit NOT NULL,
  CONSTRAINT [PK_CALIBRATION_METERING_DEVICES] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [Checks_CSM] (
	id int NOT NULL,
	id_metering_device int NOT NULL,
	doc_date datetime2 NOT NULL,
	doc_no nvarchar(50) NOT NULL,
	comments nvarchar(1000),
	defective bit NOT NULL,
	id_calibration int NOT NULL,
  CONSTRAINT [PK_CHECKS_CSM] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [Docs_mounting] (
	id int NOT NULL,
	id_object_metering_device int NOT NULL,
	date_mounting datetime2 NOT NULL,
	doc_date datetime2,
	doc_no nvarchar(50),
	comments nvarchar(1000),
	meter_readings decimal,
  CONSTRAINT [PK_DOCS_MOUNTING] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [Docs_removal] (
	id int NOT NULL,
	id_object_metering_device int NOT NULL,
	date_removal datetime2 NOT NULL,
	doc_date datetime2,
	doc_no nvarchar(50),
	comments nvarchar(1000),
	meter_readings decimal,
  CONSTRAINT [PK_DOCS_REMOVAL] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [Regions] (
	id_region int NOT NULL,
	region nvarchar(150) NOT NULL,
  CONSTRAINT [PK_REGIONS] PRIMARY KEY CLUSTERED
  (
  [id_region] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [Customers] (
	id_customer int NOT NULL,
	customer nvarchar(150) NOT NULL,
	comments nvarchar(1000),
	contacts nvarchar(1000),
	id_type_customer int NOT NULL,
  CONSTRAINT [PK_CUSTOMERS] PRIMARY KEY CLUSTERED
  (
  [id_customer] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [Metering_devices_customers] (
	id int NOT NULL,
	date_of_change datetime2 NOT NULL,
	id_customer int,
	id_metering_device int NOT NULL,
	comments nvarchar(1000),
  CONSTRAINT [PK_METERING_DEVICES_CUSTOMERS] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [Types_customers] (
	id_type_customer int NOT NULL,
	Types_customers nvarchar(150) NOT NULL,
	comments nvarchar(1000) NOT NULL,
  CONSTRAINT [PK_TYPES_CUSTOMERS] PRIMARY KEY CLUSTERED
  (
  [id_type_customer] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)

GO
ALTER TABLE [Objects] WITH CHECK ADD CONSTRAINT [Objects_fk0] FOREIGN KEY ([id_type_objects]) REFERENCES [Types_objects]([id_type_object])
ON UPDATE CASCADE
GO
ALTER TABLE [Objects] CHECK CONSTRAINT [Objects_fk0]
GO
ALTER TABLE [Locations] WITH CHECK ADD CONSTRAINT [Locations_fk0] FOREIGN KEY ([id_regions]) REFERENCES [Regions]([id_region])
ON UPDATE CASCADE
GO
ALTER TABLE [Locations] CHECK CONSTRAINT [Locations_fk0]
GO
ALTER TABLE [Locations] WITH CHECK ADD CONSTRAINT [Locations_fk1] FOREIGN KEY ([id_customer]) REFERENCES [Customers]([id_customer])
ON UPDATE CASCADE
GO
ALTER TABLE [Locations] CHECK CONSTRAINT [Locations_fk1]
GO
ALTER TABLE [Object_metering_devices] WITH CHECK ADD CONSTRAINT [Object_metering_devices_fk0] FOREIGN KEY ([id_object]) REFERENCES [Objects]([id_object])
ON UPDATE CASCADE
GO
ALTER TABLE [Object_metering_devices] CHECK CONSTRAINT [Object_metering_devices_fk0]
GO
ALTER TABLE [Object_metering_devices] WITH CHECK ADD CONSTRAINT [Object_metering_devices_fk1] FOREIGN KEY ([id_location]) REFERENCES [Locations]([id_location])
ON UPDATE CASCADE
GO
ALTER TABLE [Object_metering_devices] CHECK CONSTRAINT [Object_metering_devices_fk1]
GO
ALTER TABLE [Object_metering_devices] WITH CHECK ADD CONSTRAINT [Object_metering_devices_fk2] FOREIGN KEY ([id_metering_device]) REFERENCES [Metering_devices]([id_metering_device])
ON UPDATE CASCADE
GO
ALTER TABLE [Object_metering_devices] CHECK CONSTRAINT [Object_metering_devices_fk2]
GO
ALTER TABLE [Metering_devices] WITH CHECK ADD CONSTRAINT [Metering_devices_fk0] FOREIGN KEY ([id_model]) REFERENCES [Models]([id_model])
ON UPDATE CASCADE
GO
ALTER TABLE [Metering_devices] CHECK CONSTRAINT [Metering_devices_fk0]
GO
ALTER TABLE [Metering_devices] WITH CHECK ADD CONSTRAINT [Metering_devices_fk1] FOREIGN KEY ([id_type_metering_device]) REFERENCES [Types_Metering_devices]([id_type_metering_device])
ON UPDATE CASCADE
GO
ALTER TABLE [Metering_devices] CHECK CONSTRAINT [Metering_devices_fk1]
GO

--//////////////////////////

ALTER TABLE [Calibration_metering_devices] WITH CHECK ADD CONSTRAINT [Calibration_metering_devices_fk0] FOREIGN KEY ([id_metering_device]) REFERENCES [Metering_devices]([id_metering_device])
ON UPDATE CASCADE
GO
ALTER TABLE [Calibration_metering_devices] CHECK CONSTRAINT [Calibration_metering_devices_fk0]
GO

ALTER TABLE [Checks_CSM] WITH CHECK ADD CONSTRAINT [Checks_CSM_fk0] FOREIGN KEY ([id_metering_device]) REFERENCES [Metering_devices]([id_metering_device])
ON UPDATE CASCADE
GO
ALTER TABLE [Checks_CSM] CHECK CONSTRAINT [Checks_CSM_fk0]
GO
ALTER TABLE [Checks_CSM] WITH CHECK ADD CONSTRAINT [Checks_CSM_fk1] FOREIGN KEY ([id_calibration]) REFERENCES [Calibration_metering_devices]([id])
ON UPDATE NO ACTION
GO
ALTER TABLE [Checks_CSM] CHECK CONSTRAINT [Checks_CSM_fk1]
GO
ALTER TABLE [Docs_mounting] WITH CHECK ADD CONSTRAINT [Docs_mounting_fk0] FOREIGN KEY ([id_object_metering_device]) REFERENCES [Object_metering_devices]([id])
ON UPDATE CASCADE
GO
ALTER TABLE [Docs_mounting] CHECK CONSTRAINT [Docs_mounting_fk0]
GO
ALTER TABLE [Docs_removal] WITH CHECK ADD CONSTRAINT [Docs_removal_fk0] FOREIGN KEY ([id_object_metering_device]) REFERENCES [Object_metering_devices]([id])
ON UPDATE CASCADE
GO
ALTER TABLE [Docs_removal] CHECK CONSTRAINT [Docs_removal_fk0]
GO
ALTER TABLE [Customers] WITH CHECK ADD CONSTRAINT [Customers_fk0] FOREIGN KEY ([id_type_customer]) REFERENCES [Types_customers]([id_type_customer])
ON UPDATE CASCADE
GO
ALTER TABLE [Customers] CHECK CONSTRAINT [Customers_fk0]
GO
ALTER TABLE [Metering_devices_customers] WITH CHECK ADD CONSTRAINT [Metering_devices_customers_fk0] FOREIGN KEY ([id_customer]) REFERENCES [Customers]([id_customer])
ON UPDATE CASCADE
GO
ALTER TABLE [Metering_devices_customers] CHECK CONSTRAINT [Metering_devices_customers_fk0]
GO
ALTER TABLE [Metering_devices_customers] WITH CHECK ADD CONSTRAINT [Metering_devices_customers_fk1] FOREIGN KEY ([id_metering_device]) REFERENCES [Metering_devices]([id_metering_device])
ON UPDATE CASCADE
GO
ALTER TABLE [Metering_devices_customers] CHECK CONSTRAINT [Metering_devices_customers_fk1]
GO
ALTER TABLE [Objects_hierarchy] WITH CHECK ADD CONSTRAINT [Objects_hierarchy_fk0] FOREIGN KEY ([id_object]) REFERENCES [Objects]([id_object])
ON UPDATE CASCADE
GO
ALTER TABLE [Objects_hierarchy] CHECK CONSTRAINT [Objects_hierarchy_fk0]
GO
ALTER TABLE [Objects_hierarchy] WITH CHECK ADD CONSTRAINT [Objects_hierarchy_fk1] FOREIGN KEY ([id_parent]) REFERENCES [Objects]([id_object])
ON UPDATE NO ACTION
GO
ALTER TABLE [Objects_hierarchy] CHECK CONSTRAINT [Objects_hierarchy_fk1]
GO

