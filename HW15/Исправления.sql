CREATE TABLE [Accounting_Objects] (
	id_object int NOT NULL,
	id_type_objects int NOT NULL,
	descr_object nvarchar(200) NOT NULL,
	descr nvarchar(200) NOT NULL,
  CONSTRAINT [PK_ACCOUNTING_OBJECTS] PRIMARY KEY CLUSTERED
  (
  [id_object] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [Locations] (
	id_location int NOT NULL,
	descr_location nvarchar(150) NOT NULL,
	comments nvarchar(1000),
	adr nvarchar(1000) NOT NULL,
	id_regions int(1000) NOT NULL,
	id_customer int NOT NULL,
  CONSTRAINT [PK_LOCATIONS] PRIMARY KEY CLUSTERED
  (
  [id_location] ASC
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
ALTER TABLE [Customers] WITH CHECK ADD CONSTRAINT [Customers_fk0] FOREIGN KEY ([id_type_customer]) REFERENCES [Types_customers]([id_type_customer])
GO
ALTER TABLE [Customers] CHECK CONSTRAINT [Customers_fk0]
GO
ALTER TABLE [Accounting_Objects] WITH CHECK ADD CONSTRAINT [Accounting_Objects_fk0] FOREIGN KEY ([id_type_objects]) REFERENCES [Types_objects]([id_type_object])
GO
ALTER TABLE [Accounting_Objects] CHECK CONSTRAINT [Accounting_Objects_fk0]
GO


ALTER TABLE [Locations] WITH CHECK ADD CONSTRAINT [Locations_fk0] FOREIGN KEY ([id_regions]) REFERENCES [Regions]([id_region])
GO
ALTER TABLE [Locations] CHECK CONSTRAINT [Locations_fk0]
GO
ALTER TABLE [Locations] WITH CHECK ADD CONSTRAINT [Locations_fk1] FOREIGN KEY ([id_customer]) REFERENCES [Customers]([id_customer])
GO
ALTER TABLE [Locations] CHECK CONSTRAINT [Locations_fk1]
GO
