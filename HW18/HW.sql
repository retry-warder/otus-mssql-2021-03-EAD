USE [AccountingObjects]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_Accounting_Objects_DESCR_OBJECT] ON [dbo].[Accounting_Objects]
(
	[descr_object] ASC
)
GO
CREATE NONCLUSTERED INDEX [IDX_Accounting_Objects_ID_TYPE_OBJECT] ON [dbo].[Accounting_Objects]
(
	[id_type_object] ASC
)
GO
CREATE NONCLUSTERED INDEX [IDX_Calibration_metering_devices_DOC_DATE] ON [dbo].[Calibration_metering_devices]
(
	[doc_date] ASC
)
GO
CREATE NONCLUSTERED INDEX [IDX_Calibration_metering_devices_DOC_DATE_DOC_NO] ON [dbo].[Calibration_metering_devices]
(
	[doc_date] ASC,
	[doc_no] ASC
)
GO
CREATE NONCLUSTERED INDEX [IDX_Calibration_metering_devices_ID_METERING_DEVICE] ON [dbo].[Calibration_metering_devices]
(
	[id_metering_device] ASC
)
GO
CREATE NONCLUSTERED INDEX [IDX_Calibration_metering_devices_DOC_DATE] ON [dbo].[Calibration_metering_devices]
(
	[doc_date] ASC
)
GO
CREATE NONCLUSTERED INDEX [IDX_Calibration_metering_devices_DOC_DATE_DOC_NO] ON [dbo].[Calibration_metering_devices]
(
	[doc_date] ASC,
	[doc_no] ASC
)
GO
CREATE NONCLUSTERED INDEX [IDX_Checks_CSM_ID_CALIBRATION] ON [dbo].[Checks_CSM]
(
	[id_calibration] ASC
)
GO
CREATE NONCLUSTERED INDEX [IDX_Checks_CSM_ID_METERING_DEVICE] ON [dbo].[Checks_CSM]
(
	[id_metering_device] ASC
)
GO
CREATE NONCLUSTERED INDEX [IDX_Checks_CSM_DOC_DATE] ON [dbo].[Checks_CSM]
(
	[doc_date] ASC
)
GO
CREATE NONCLUSTERED INDEX [IDX_Checks_CSM_DOC_DATE_DOC_NO] ON [dbo].[Checks_CSM]
(
	[doc_date] ASC,
	[doc_no] ASC
)
GO
CREATE NONCLUSTERED INDEX [IDX_Customers_CUSTOMER] ON [dbo].[Customers]
(
	[customer] ASC
)
GO
