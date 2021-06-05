USE [AccountingObjects]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UNQ_IDX_Object_metering_devices_] ON [dbo].[Object_metering_devices]
(
	[id_object] ASC,
	[id_location] ASC,
	[id_metering_device] ASC
)
GO
CREATE NONCLUSTERED INDEX [IDX_Object_metering_devices_ID_OBJECT] ON [dbo].[Object_metering_devices]
(
	[id_object] ASC
)
GO
CREATE NONCLUSTERED INDEX [IDX_Object_metering_devices_ID_LOCATION] ON [dbo].[Object_metering_devices]
(
	[id_location] ASC
)
GO
CREATE NONCLUSTERED INDEX [IDX_Object_metering_devices_ID_METERING_DEVICES] ON [dbo].[Object_metering_devices]
(
	[id_metering_device] ASC
)
GO

ALTER TABLE [dbo].[Models]  WITH CHECK ADD  CONSTRAINT [CK_Models] CHECK  (([calibration_interval]<=(120)))
GO

ALTER TABLE [dbo].[Models] CHECK CONSTRAINT [CK_Models]
GO

ALTER TABLE [dbo].[Locations] CHECK CONSTRAINT [CK_Models]
GO

ALTER TABLE [dbo].[Locations] ADD CONSTRAINT descr_location_un UNIQUE (descr_location)

GO

ALTER TABLE [dbo].[Regions] ADD CONSTRAINT region_un UNIQUE (region)

GO

ALTER TABLE [dbo].[Types_customers] ADD CONSTRAINT types_customers_un UNIQUE (types_customers)

GO

ALTER TABLE [dbo].[Types_customers] ADD CONSTRAINT type_customers_un UNIQUE (type_customers)

GO

ALTER TABLE [dbo].[Types_Metering_devices] ADD CONSTRAINT type_metering_device_un UNIQUE (type_metering_device)

GO

ALTER TABLE [dbo].[Types_objects] ADD CONSTRAINT type_objects_un UNIQUE (type_objects)

GO
