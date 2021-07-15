USE [WideWorldImporters]
GO

/****** Object:  StoredProcedure [Sales].[ConfirmReport]    Script Date: 15.07.2021 23:14:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

USE [WideWorldImporters]
GO

/****** Object:  Table [dbo].[InvoiceReport]    Script Date: 15.07.2021 23:28:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[InvoiceReport](
	[Date_report] [datetime2](7) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[DateBegin] [date] NOT NULL,
	[DateEnd] [date] NOT NULL,
	[Report] [xml] NULL
) ON [USERDATA] TEXTIMAGE_ON [USERDATA]
GO

--процедура изначальной отправки запроса в очередь таргета
CREATE PROCEDURE [Sales].[SendReport]
	@CustomerID INT,
	@DateBegin Date, 
	@DateEnd Date
AS
BEGIN
	SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER; --open init dialog
	DECLARE @RequestMessage NVARCHAR(4000); --сообщение, которое будем отправлять
	
	BEGIN TRAN --начинаем транзакцию

	--Prepare the Message  !!!auto generate XML
	SELECT @RequestMessage = (SELECT Item.CustomerID, Item.CustomerName, Item.DateBegin, Item.DateEnd, Item.CNT_ORDERS FROM
						(SELECT	Sales.Invoices.CustomerID AS CustomerID, 
								@DateBegin AS DateBegin,
								@DateEND AS DateEnd,
								Sales.Customers.CustomerName AS CustomerName, 
								COUNT(DISTINCT Sales.Invoices.OrderID) AS CNT_ORDERS
						FROM	Sales.Invoices INNER JOIN
								Sales.Customers ON Sales.Invoices.CustomerID = Sales.Customers.CustomerID
						WHERE 
								Sales.Invoices.CustomerID = @CustomerID
								AND
								Sales.Invoices.InvoiceDate BETWEEN @DateBegin AND  @DateEND
								GROUP BY Sales.Invoices.CustomerID, Sales.Customers.CustomerName) AS Item
								FOR XML AUTO, ROOT('REPORT'))
	--Determine the Initiator Service, Target Service and the Contract 
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/InitiatorService]
	TO SERVICE
	'//WWI/SB/TargetService'
	ON CONTRACT
	[//WWI/SB/Contract]
	WITH ENCRYPTION=OFF; 

	--Send the Message
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/RequestMessage]
	(@RequestMessage);
	--SELECT @RequestMessage AS SentRequestMessage;--we can write data to log
	COMMIT TRAN 
END
GO

CREATE   PROCEDURE [Sales].[GetReport]
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER, --идентификатор диалога
			@Message NVARCHAR(4000),--полученное сообщение
			@MessageType Sysname,--тип полученного сообщения
			@ReplyMessage NVARCHAR(4000),--ответное сообщение
			@CustomerID INT,
			@DateBegin Date, 
			@DateEnd Date,
			@xml XML; 
	
	BEGIN TRAN; 

	--Receive message from Initiator
	--можно выбирать и не по 1 сообщению
	--1 рекомендация от MS
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.TargetQueueWWI; 

	SELECT @Message; --выводим в консоль полученный месседж

	SET @xml = CAST(@Message AS XML); -- получаем xml из мессаджа

	--получаем InvoiceID из xml
	SELECT 
		@CustomerID = T.Item.value('@CustomerID','int'),
		@DateBegin = T.Item.value('@DateBegin','date'),
		@DateEnd = T.Item.value('@DateEnd','date')
	FROM @xml.nodes('/REPORT/Item') as T(Item);

	--проставим дату в пустое поле для InvoiceID
	INSERT INTO [dbo].[InvoiceReport]
           ([Date_report]
           ,[CustomerID]
		   ,[DateBegin]
		   ,[DateEnd]
           ,[Report])
     VALUES
           (GETDATE()
           ,@CustomerID
		   ,@DateBegin
		   ,@DateEnd
           ,@xml)
	
	SELECT @Message AS ReceivedRequestMessage, @MessageType; --в лог. замедляет работу
	
	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/RequestMessage'
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received </ReplyMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;--закроем диалог со стороны таргета
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; --в лог

	COMMIT TRAN;
END
GO

CREATE PROCEDURE [Sales].[ConfirmReport]
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER, --хэндл диалога
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

	--получим сообщение из очереди инициатора
		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueueWWI; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; --закроем диалог со стороны инициатора
		--оба участника диалога должны завершить его
		--https://docs.microsoft.com/ru-ru/sql/t-sql/statements/end-conversation-transact-sql?view=sql-server-ver15
		
		SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; --в консоль

	COMMIT TRAN; 
END


GO

ALTER QUEUE [dbo].[InitiatorQueueWWI] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF) 
	, ACTIVATION (   STATUS = ON ,
        PROCEDURE_NAME = Sales.ConfirmReport, MAX_QUEUE_READERS = 100, EXECUTE AS OWNER) ; 

GO
ALTER QUEUE [dbo].[TargetQueueWWI] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF)
	, ACTIVATION (  STATUS = ON ,
        PROCEDURE_NAME = Sales.GetReport, MAX_QUEUE_READERS = 100, EXECUTE AS OWNER) ; 

GO



