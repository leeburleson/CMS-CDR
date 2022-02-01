USE [master]
GO

/****** Object:  Database [CMS_CDR]    Script Date: 08-Jul-21 14:42:46 ******/
CREATE DATABASE [CMS_CDR]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = 'CMS_CDR', FILENAME = 'CMS_CDR.mdf' , SIZE = 65536KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = 'CMS_CDR_log', FILENAME = 'CMS_CDR_log.ldf' , SIZE = 65536KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [CMS_CDR] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [CMS_CDR].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [CMS_CDR] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [CMS_CDR] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [CMS_CDR] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [CMS_CDR] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [CMS_CDR] SET ARITHABORT OFF 
GO
ALTER DATABASE [CMS_CDR] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [CMS_CDR] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [CMS_CDR] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [CMS_CDR] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [CMS_CDR] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [CMS_CDR] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [CMS_CDR] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [CMS_CDR] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [CMS_CDR] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [CMS_CDR] SET  DISABLE_BROKER 
GO
ALTER DATABASE [CMS_CDR] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [CMS_CDR] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [CMS_CDR] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [CMS_CDR] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [CMS_CDR] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [CMS_CDR] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [CMS_CDR] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [CMS_CDR] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [CMS_CDR] SET  MULTI_USER 
GO
ALTER DATABASE [CMS_CDR] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [CMS_CDR] SET DB_CHAINING OFF 
GO
ALTER DATABASE [CMS_CDR] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [CMS_CDR] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [CMS_CDR] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [CMS_CDR] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'CMS_CDR', N'ON'
GO
ALTER DATABASE [CMS_CDR] SET QUERY_STORE = OFF
GO
USE [CMS_CDR]
GO
/****** Object:  User [cmscdr]    Script Date: 08-Jul-21 14:42:46 ******/
CREATE USER [cmscdr] FOR LOGIN [cmscdr] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [cmscdr]
GO
/****** Object:  UserDefinedFunction [dbo].[fConvertToBit]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================

CREATE FUNCTION [dbo].[fConvertToBit](
    @Input varchar(8)
)
RETURNS bit

AS BEGIN

DECLARE @Result as bit
SET @Result=(
	CONVERT(bit, 
		CASE @Input
			WHEN 'True'     THEN 1
			WHEN 'Yes'      THEN 1
			WHEN '1'        THEN 1
			WHEN 'False'    THEN 0
			WHEN 'No'       THEN 0
			WHEN '0'        THEN 0
		END
	)
)

RETURN @Result
END

GO
/****** Object:  UserDefinedFunction [dbo].[fGetCallLegEndReasonID]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fGetCallLegEndReasonID](
	@Reason varchar(64)
)
RETURNS int
AS
BEGIN
	DECLARE @Result AS int
	SET @Result = (SELECT ID FROM tblCallLegEndReasonCodes WHERE vcReason=@Reason)
	RETURN @Result

END
GO
/****** Object:  Table [dbo].[tblCallStart]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCallStart](
	[intRawRecordID] [int] NOT NULL,
	[Session] [uniqueidentifier] NOT NULL,
	[CallBridge] [uniqueidentifier] NOT NULL,
	[dtTime] [datetime2](7) NOT NULL,
	[intCorrelatorIndex] [int] NOT NULL,
	[CallID] [uniqueidentifier] NOT NULL,
	[vcName] [varchar](128) NULL,
	[vcOwnerName] [varchar](128) NULL,
	[vcCallType] [varchar](64) NULL,
	[CoSpace] [uniqueidentifier] NULL,
	[CallCorrelator] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCallEnd]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCallEnd](
	[intRawRecordID] [int] NOT NULL,
	[Session] [uniqueidentifier] NULL,
	[CallBridge] [uniqueidentifier] NOT NULL,
	[dtTime] [datetime2](7) NOT NULL,
	[intCorrelatorIndex] [int] NOT NULL,
	[CallID] [uniqueidentifier] NOT NULL,
	[intCallLegsCompleted] [int] NULL,
	[intCallLegsMaxActive] [int] NULL,
	[intDurationSeconds] [int] NULL,
	[intYYYYMM]  AS (datepart(year,[dtTime])*(100)+datepart(month,[dtTime])) PERSISTED
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[View_1]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_1]
AS
SELECT t1.intYYYYMM, t1.intCallLegsMaxActive, t1.dtTime, dbo.tblCallStart.vcName
FROM   dbo.tblCallEnd AS t1 INNER JOIN
             dbo.tblCallStart ON t1.CallID = dbo.tblCallStart.CallID LEFT OUTER JOIN
             dbo.tblCallEnd AS t2 ON t1.intYYYYMM = t2.intYYYYMM AND (t1.intCallLegsMaxActive < t2.intCallLegsMaxActive OR
             t1.intCallLegsMaxActive = t2.intCallLegsMaxActive AND t1.CallID < t2.CallID)
WHERE (t2.CallID IS NULL)
GO
/****** Object:  Table [dbo].[tblRawRecords]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRawRecords](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[xmlBody] [xml] NOT NULL,
	[bitProcessed] [bit] NOT NULL,
	[dtProcessed] [datetime2](7) NULL,
	[dtReceived] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vuRecentRawRecords]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vuRecentRawRecords]
AS
SELECT TOP (10) ID, xmlBody, bitProcessed, dtProcessed, dtReceived
FROM   dbo.tblRawRecords
ORDER BY dtReceived DESC
GO
/****** Object:  Table [dbo].[tblCallLegEnd]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCallLegEnd](
	[intRawRecordID] [int] NOT NULL,
	[CallBridge] [uniqueidentifier] NOT NULL,
	[CallLegID] [uniqueidentifier] NOT NULL,
	[dtTime] [datetime2](7) NOT NULL,
	[intCorrelatorIndex] [int] NOT NULL,
	[intReason] [int] NULL,
	[bitRemoteTeardown] [bit] NULL,
	[intDurationSeconds] [int] NULL,
	[intActivatedDuration] [int] NULL,
	[vcAlarmType] [varchar](64) NULL,
	[numAlarmDurationPercentage] [numeric](9, 3) NULL,
	[bitUnencryptedMedia] [bit] NULL,
	[vcRxAudioCodec] [varchar](64) NULL,
	[numRxAudioPacketLossBurstsDuration] [numeric](9, 3) NULL,
	[numRxAudioPacketLossBurstsDensity] [numeric](9, 3) NULL,
	[numintRxAudioPacketGapDuration] [numeric](9, 3) NULL,
	[numRxAudioPacketGapDensity] [numeric](9, 3) NULL,
	[vcTxAudioCodec] [varchar](64) NULL,
	[vcRxVideoCodec] [varchar](64) NULL,
	[numRxVideoPacketLossBurstsDuration] [numeric](9, 3) NULL,
	[numRxVideoPacketLossBurstsDensity] [numeric](9, 3) NULL,
	[numRxVideoPacketGapDuration] [numeric](9, 3) NULL,
	[numRxVideoPacketGapDensity] [numeric](9, 3) NULL,
	[vcTxVideoCodec] [varchar](64) NULL,
	[intTxVideoMaxSizeWidth] [int] NULL,
	[intTxVideoMaxSizeHeight] [int] NULL,
	[vcSipCallId] [varchar](128) NULL,
	[intYYYYMM]  AS (datepart(year,[dtTime])*(100)+datepart(month,[dtTime])) PERSISTED
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCallLegEndReasonCodes]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCallLegEndReasonCodes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[vcReason] [varchar](64) NOT NULL,
	[vcDescription] [varchar](512) NULL,
 CONSTRAINT [PK_tblCallLegEndReasonCodes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCallLegStart]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCallLegStart](
	[intRawRecordID] [int] NOT NULL,
	[CallBridge] [uniqueidentifier] NOT NULL,
	[CallLegID] [uniqueidentifier] NOT NULL,
	[dtTime] [datetime2](7) NOT NULL,
	[intCorrelatorIndex] [int] NOT NULL,
	[vcRemoteParty] [varchar](128) NULL,
	[vcLocalAddress] [varchar](128) NULL,
	[vcDisplayName] [varchar](128) NULL,
	[vcRemoteAddress] [varchar](128) NULL,
	[vcType] [varchar](64) NULL,
	[vcSubType] [varchar](64) NULL,
	[vcDirection] [varchar](64) NULL,
	[bitGuestConnection] [bit] NULL,
	[bitRecording] [bit] NULL,
	[bitStreaming] [bit] NULL,
	[GroupId] [uniqueidentifier] NULL,
	[vcSipCallId] [varchar](128) NULL,
	[vcConfirmationStatus] [varchar](64) NULL,
	[bitCanMove] [bit] NULL,
	[CallID] [uniqueidentifier] NULL,
	[MovedCallLeg] [uniqueidentifier] NULL,
	[vcReplacesSipCallId] [varchar](128) NULL,
	[MovedCallLegCallBridge] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCallLegUpdate]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCallLegUpdate](
	[intRawRecordID] [int] NOT NULL,
	[CallBridge] [uniqueidentifier] NOT NULL,
	[dtTime] [datetime2](7) NOT NULL,
	[intCorrelatorIndex] [int] NOT NULL,
	[CallLegID] [uniqueidentifier] NOT NULL,
	[vcState] [varchar](64) NULL,
	[bitIVR] [bit] NULL,
	[GroupID] [uniqueidentifier] NULL,
	[vcSipCallId] [varchar](128) NULL,
	[CallID] [uniqueidentifier] NULL,
	[vcDisplayName] [varchar](128) NULL,
	[vcRemoteAddress] [varchar](128) NULL,
	[bitCanMove] [bit] NULL,
	[vcConfirmationStatus] [varchar](64) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRecordingEnd]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRecordingEnd](
	[intRawRecordID] [int] NOT NULL,
	[ID] [uniqueidentifier] NOT NULL,
	[dtReceived] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRecordingStart]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRecordingStart](
	[intRawRecordID] [int] NOT NULL,
	[ID] [uniqueidentifier] NOT NULL,
	[vcPath] [varchar](128) NULL,
	[vcRecorderUrl] [varchar](256) NULL,
	[vcRecorderUri] [varchar](256) NULL,
	[Call] [uniqueidentifier] NULL,
	[CallLeg] [uniqueidentifier] NULL,
	[dtReceived] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblStreamingEnd]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblStreamingEnd](
	[intRawRecordID] [int] NOT NULL,
	[ID] [uniqueidentifier] NOT NULL,
	[dtReceived] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblStreamingStart]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblStreamingStart](
	[intRawRecordID] [int] NOT NULL,
	[ID] [uniqueidentifier] NOT NULL,
	[dtReceived] [datetime2](7) NOT NULL,
	[vcStreamUrl] [varchar](256) NULL,
	[vcStreamerUrl] [varchar](256) NULL,
	[Call] [uniqueidentifier] NULL,
	[CallLeg] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblRawRecords] ADD  CONSTRAINT [DF_tblRawRecords_bitProcessed]  DEFAULT ((0)) FOR [bitProcessed]
GO
ALTER TABLE [dbo].[tblRawRecords] ADD  CONSTRAINT [DF_tblRawRecords_dtReceived]  DEFAULT (getdate()) FOR [dtReceived]
GO
ALTER TABLE [dbo].[tblRecordingEnd] ADD  CONSTRAINT [DF_tblRecordingEnd_dtReceived]  DEFAULT (getdate()) FOR [dtReceived]
GO
ALTER TABLE [dbo].[tblRecordingStart] ADD  CONSTRAINT [DF_tblRecordingStart_dtReceived]  DEFAULT (getdate()) FOR [dtReceived]
GO
ALTER TABLE [dbo].[tblStreamingEnd] ADD  CONSTRAINT [DF_StreamingEnd_dtReceived]  DEFAULT (getdate()) FOR [dtReceived]
GO
ALTER TABLE [dbo].[tblStreamingStart] ADD  CONSTRAINT [DF_tblStreamingStart_dtReceived]  DEFAULT (getdate()) FOR [dtReceived]
GO
ALTER TABLE [dbo].[tblCallLegEnd]  WITH CHECK ADD  CONSTRAINT [FK_tblCallLegEnd_tblCallLegEndReasonCodes] FOREIGN KEY([intReason])
REFERENCES [dbo].[tblCallLegEndReasonCodes] ([ID])
GO
ALTER TABLE [dbo].[tblCallLegEnd] CHECK CONSTRAINT [FK_tblCallLegEnd_tblCallLegEndReasonCodes]
GO
/****** Object:  StoredProcedure [dbo].[spAYearOfMonths]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spAYearOfMonths]
	@intYear int
AS
BEGIN

DECLARE @StartDate smalldatetime

SET @StartDate= DATEFROMPARTS(@intYear, 1, 1)
--SET @StartDate=DATEADD(month,-6, CONVERT(CHAR(10),GETDATE(),121))
--SET @EndDate = DATEFROMPARTS(@intYear, 2, 1)

;with AllDates AS
(
--SELECT @StartDate AS SD, DateAdd(month, 1, @StartDate) AS ED, 1 as Number
SELECT DATEFROMPARTS(@intYear, 1, 1) AS SD, DATEFROMPARTS(@intYear, 2, 1) AS ED --,  1 as Number

UNION ALL

SELECT DateAdd(month,1 ,SD), DateAdd(month, 1, ED)  --, 1
FROM AllDates
WHERE MONTH(SD) < 12
)
SELECT *
FROM AllDates

END
GO
/****** Object:  StoredProcedure [dbo].[spLoadRawRecords]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spLoadRawRecords]
	@xml xml
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	INSERT INTO tblRawRecords
	(xmlBody)
	VALUES (@xml)

END
GO
/****** Object:  StoredProcedure [dbo].[spProcessAll]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spProcessAll]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

	DECLARE @intRetVal int
	PRINT 'Start time:' + CONVERT(varchar, SYSDATETIME(), 121)

	BEGIN TRANSACTION

	EXEC @intRetVal = spProcessCallStart;
	IF @intRetVal = -1 GOTO ErrExit

	EXEC @intRetVal = spProcessCallEnd; 
	IF @intRetVal = -1 GOTO ErrExit

	EXEC @intRetVal = spProcessCallLegStart; 
	IF @intRetVal = -1 GOTO ErrExit

	EXEC @intRetVal = spProcessCallLegEnd; 
	IF @intRetVal = -1 GOTO ErrExit

	EXEC @intRetVal = spProcessCallLegUpdate; 
	IF @intRetVal = -1 GOTO ErrExit

NormalExit:
	IF @@TRANCOUNT=1 COMMIT TRANSACTION
	PRINT 'Normal completion time:' + CONVERT(varchar, SYSDATETIME(), 121)
	RETURN(0)
	GOTO FinalExit

ErrExit:
	ROLLBACK TRANSACTION
	PRINT 'ERROR time:' + CONVERT(varchar, SYSDATETIME(), 121)
	RETURN(-1)

FinalExit:
END


GO
/****** Object:  StoredProcedure [dbo].[spProcessCallEnd]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spProcessCallEnd]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
	PRINT 'spProcessCallEnd: Begin'

DECLARE @tblProcessed TABLE (intRawRecordID int)

INSERT tblCallEnd
OUTPUT INSERTED.intRawRecordID INTO @tblProcessed
SELECT * FROM (

select ID as intRawRecordID, 
	Records.col.value('@session','uniqueidentifier') as 'Session',
	Records.col.value('@callBridge','uniqueidentifier') as CallBridge,
	Record.col.value('(@time)[1]','varchar(64)') as dtTime,
	Record.col.value('(@correlatorIndex)[1]','int') as intCorrelatorIndex,
	Record.col.value('(call/@id)[1]','uniqueidentifier') as CallID,
	Record.col.value('(call/callLegsCompleted)[1]','int') as intCallLegsCompleted,
	Record.col.value('(call/callLegsMaxActive)[1]','int') as intCallLegsMaxActive,
	Record.col.value('(call/durationSeconds)[1]','int') as intDurationSeconds

from tblRawRecords

OUTER APPLY tblRawRecords.xmlBody.nodes('records') as Records(col)
OUTER APPLY tblRawRecords.xmlBody.nodes('records/record') as Record(col)

where not bitProcessed=1
AND
Record.col.value('(@type)[1]','varchar(64)') = 'callEnd'

)
AS Garbage

UPDATE tblRawRecords
SET bitProcessed=1, dtProcessed=SYSDATETIME()
WHERE tblRawRecords.ID in (SELECT intRawRecordID FROM @tblProcessed)

IF @@ERROR >0 RETURN -1

PRINT 'spProcessCallEnd: Ending'

END
GO
/****** Object:  StoredProcedure [dbo].[spProcessCallLegEnd]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE PROCEDURE [dbo].[spProcessCallLegEnd]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

PRINT 'spProcessCallLegEnd: Begin'

DECLARE @tblProcessed TABLE (intRawRecordID int)

INSERT INTO tblCallLegEnd
OUTPUT INSERTED.intRawRecordID INTO @tblProcessed
SELECT * FROM (

SELECT ID as intRawRecordID, 
	Records.col.value('@callBridge','uniqueidentifier') as CallBridge,
	CallLeg.col.value('(@id)[1]','uniqueidentifier') as CallLegID,
	Record.col.value('(@time)[1]','varchar(64)') as dtTime,
	Record.col.value('(@correlatorIndex)[1]','int') as intCorrelatorIndex,
    dbo.fGetCallLegEndReasonID(CallLeg.col.value('(reason)[1]','varchar(64)')) as intReason,
	dbo.fConvertToBit(CallLeg.col.value('(remoteTeardown)[1]','varchar(64)')) as bitRemoteTeardown,
	CallLeg.col.value('(durationSeconds)[1]','int') as intDurationSeconds,
	CallLeg.col.value('(activatedDuration)[1]','int') as intActivatedDuration,
	CallLeg.col.value('(alarm/@type)[1]','varchar(64)') as vcAlarmType,
	CallLeg.col.value('(alarm/@durationPercentage)[1]','numeric(9,3)') as numAlarmDurationPercentage,
	dbo.fConvertToBit(CallLeg.col.value('(unencryptedMedia)[1]','varchar(64)')) as bitUnencryptedMedia,
	RxAudio.col.value('(codec)[1]','varchar(64)') as vcRxAudioCodec,
	RxAudio.col.value('(packetStatistics/packetLossBursts/duration)[1]','numeric(9, 3)') as numRxAudioPacketLossBurstsDuration,
	RxAudio.col.value('(packetStatistics/packetLossBursts/density)[1]','numeric(9,3)') as numRxAudioPacketLossBurstsDensity,
	RxAudio.col.value('(packetStatistics/packetGap/duration)[1]','numeric(9,3)') as numRxAudioPacketGapDuration,
	RxAudio.col.value('(packetStatistics/packetGap/density)[1]','numeric(9,3)') as numRxAudioPacketGapDensity,
	CallLeg.col.value('(txAudio/codec)[1]','varchar(64)') as vcTxAudioCodec,
	CallLeg.col.value('(rxVideo/codec)[1]','varchar(64)') as vcRxVideoCodec,
	RxVideo.col.value('(packetStatistics/packetLossBursts/duration)[1]','numeric(9,3)') as numRxVideoPacketLossBurstsDuration,
	RxVideo.col.value('(packetStatistics/packetLossBursts/density)[1]','numeric(9,3)') as numRxVideoPacketLossBurstsDensity,
	RxVideo.col.value('(packetStatistics/packetGap/duration)[1]','numeric(9,3)') as numRxVideoPacketGapDuration,
	RxVideo.col.value('(packetStatistics/packetGap/density)[1]','numeric(9,3)') as numRxVideoPacketGapDensity,
	CallLeg.col.value('(txVideo/codec)[1]','varchar(64)') as vcTxVideoCodec,
	CallLeg.col.value('(txVideo/maxSizeWidth)[1]','varchar(64)') as intTxVideoMaxSizeWidth,
	CallLeg.col.value('(txVideo/maxSizeHeight)[1]','varchar(64)') as intTxVideoMaxSizeHeight,
	CallLeg.col.value('(sipCallId)[1]','varchar(128)') as vcSipCallId

FROM tblRawRecords

OUTER APPLY tblRawRecords.xmlBody.nodes('records') as Records(col)
OUTER APPLY tblRawRecords.xmlBody.nodes('records/record') as Record(col)
OUTER APPLY tblRawRecords.xmlBody.nodes('records/record/callLeg') as CallLeg(col)
OUTER APPLY tblRawRecords.xmlBody.nodes('records/record/callLeg/rxAudio') as RxAudio(col)
OUTER APPLY tblRawRecords.xmlBody.nodes('records/record/callLeg/rxVideo') as RxVideo(col)

WHERE not bitProcessed=1
AND
Record.col.value('(@type)[1]','varchar(64)') = 'callLegEnd'
)
AS Garbage

UPDATE tblRawRecords
SET bitProcessed=1, dtProcessed=SYSDATETIME()
WHERE tblRawRecords.ID in (SELECT intRawRecordID FROM @tblProcessed)


IF @@ERROR >0 RETURN -1

PRINT 'spProcessCallLegEnd: Ending'

END
GO
/****** Object:  StoredProcedure [dbo].[spProcessCallLegStart]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE PROCEDURE [dbo].[spProcessCallLegStart]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

PRINT 'spProcessCallLegStart: Begin'

DECLARE @tblProcessed TABLE (intRawRecordID int)

INSERT INTO tblCallLegStart
OUTPUT INSERTED.intRawRecordID INTO @tblProcessed
SELECT * FROM (
SELECT ID as intRawRecordID,
	Records.col.value('@callBridge','uniqueidentifier') as CallBridge,
	CallLeg.col.value('(@id)[1]','uniqueidentifier') as CallLegID,
	Record.col.value('(@time)[1]','varchar(64)') as dtTime,
	Record.col.value('(@correlatorIndex)[1]','int') as intCorrelatorIndex,
	CallLeg.col.value('(remoteParty)[1]','varchar(128)') as vcRemoteParty,
	CallLeg.col.value('(localAddress)[1]','varchar(128)') as vcLocalAddress,
    CallLeg.col.value('(displayName)[1]','varchar(64)') as vcDisplayName,
	CallLeg.col.value('(remoteAddress)[1]','varchar(128)') as vcRemoteAddress,
    CallLeg.col.value('(type)[1]','varchar(64)') as vcType,
    CallLeg.col.value('(subtype)[1]','varchar(64)') as vcSubType,
	CallLeg.col.value('(direction)[1]','varchar(64)') as vcDirection,
	dbo.fConvertToBit(CallLeg.col.value('(guestConnection)[1]','varchar(64)')) as bitGuestConnection,
	dbo.fConvertToBit(CallLeg.col.value('(recording)[1]','varchar(64)')) as bitRecording,
	dbo.fConvertToBit(CallLeg.col.value('(streaming)[1]','varchar(64)')) as bitStreaming,
	CallLeg.col.value('(groupId)[1]','uniqueidentifier') as GroupId,
	CallLeg.col.value('(sipCallId)[1]','varchar(128)') as vcSipCallId,
	CallLeg.col.value('(confirmationStatus)[1]','varchar(64)') as vcConfirmationStatus,
	dbo.fConvertToBit(CallLeg.col.value('(canMove)[1]','varchar(64)')) as bitCanMove,
	CallLeg.col.value('(call)[1]','uniqueidentifier') as CallID,
	CallLeg.col.value('(movedCallLeg)[1]','uniqueidentifier') as MovedCallLeg,
	CallLeg.col.value('(replacesSipCallId)[1]','varchar(128)') as vcReplacesSipCallId,
	CallLeg.col.value('(movedCallLegCallBridge)[1]','uniqueidentifier') as MovedCallLegCallBridge

FROM tblRawRecords

OUTER APPLY tblRawRecords.xmlBody.nodes('records') as Records(col)
OUTER APPLY tblRawRecords.xmlBody.nodes('records/record') as Record(col)
OUTER APPLY tblRawRecords.xmlBody.nodes('records/record/callLeg') as CallLeg(col)

WHERE not bitProcessed=1
AND
Record.col.value('(@type)[1]','varchar(64)') = 'callLegStart'
)
AS Garbage

PRINT 'spProcessCallLegStart: Updating Raw Records'
UPDATE tblRawRecords
SET bitProcessed=1, dtProcessed=SYSDATETIME()
WHERE tblRawRecords.ID in (SELECT intRawRecordID FROM @tblProcessed)

IF @@ERROR >0 RETURN -1

PRINT 'spProcessCallLegStart: Ending'

END
GO
/****** Object:  StoredProcedure [dbo].[spProcessCallLegUpdate]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE PROCEDURE [dbo].[spProcessCallLegUpdate]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

PRINT 'spProcessCallLegUpdate: Begin'

DECLARE @tblProcessed TABLE (intRawRecordID int)

INSERT INTO tblCallLegUpdate
OUTPUT INSERTED.intRawRecordID INTO @tblProcessed
SELECT * FROM (
SELECT ID as intRawRecordID,
	Records.col.value('@callBridge','uniqueidentifier') as CallBridge,
	Record.col.value('(@time)[1]','smalldatetime') as dtTime,
	Record.col.value('(@correlatorIndex)[1]','int') as intCorrelatorIndex,
	CallLeg.col.value('(@id)[1]','uniqueidentifier') as CallLegID,
	CallLeg.col.value('(state)[1]','varchar(64)') as vcState,
	CallLeg.col.exist('(ivr)') as bitIVR,
	CallLeg.col.value('(groupId)[1]','uniqueidentifier') as GroupId,
	CallLeg.col.value('(sipCallId)[1]','varchar(128)') as vcSipCallId,
	CallLeg.col.value('(call)[1]','uniqueidentifier') as CallID,
    CallLeg.col.value('(displayName)[1]','varchar(128)') as vcDisplayName,
	CallLeg.col.value('(remoteAddress)[1]','varchar(128)') as vcRemoteAddress,
	dbo.fConvertToBit(CallLeg.col.value('(canMove)[1]','varchar(64)')) as bitCanMove,
	CallLeg.col.value('(confirmationStatus)[1]','varchar(64)') as vcConfirmationStatus

FROM tblRawRecords

OUTER APPLY tblRawRecords.xmlBody.nodes('records') as Records(col)
OUTER APPLY tblRawRecords.xmlBody.nodes('records/record') as Record(col)
OUTER APPLY tblRawRecords.xmlBody.nodes('records/record/callLeg') as CallLeg(col)

WHERE not bitProcessed=1
AND
Record.col.value('(@type)[1]','varchar(64)') = 'callLegUpdate'

) AS Garbage

UPDATE tblRawRecords
SET bitProcessed=1, dtProcessed=SYSDATETIME()
WHERE tblRawRecords.ID in (SELECT intRawRecordID FROM @tblProcessed)

IF @@ERROR >0 RETURN -1

PRINT 'spProcessCallLegUpdate: Ending'

END
GO
/****** Object:  StoredProcedure [dbo].[spProcessCallStart]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spProcessCallStart]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

PRINT 'spProcessCallStart: Begin'

DECLARE @tblProcessed TABLE (intRawRecordID int)

INSERT INTO tblCallStart
OUTPUT INSERTED.intRawRecordID INTO @tblProcessed
SELECT * FROM (

select ID as intRawRecordID,
	Records.col.value('@session','uniqueidentifier') as 'Session',
	Records.col.value('@callBridge','uniqueidentifier') as CallBridge,
	Record.col.value('(@time)[1]','varchar(64)') as dtTime,
	Record.col.value('(@correlatorIndex)[1]','int') as intCorrelatorIndex,
	Record.col.value('(call/@id)[1]','uniqueidentifier') as CallID,
	Record.col.value('(call/name)[1]','varchar(64)') as vcName,
	Record.col.value('(call/ownerName)[1]','varchar(64)') as vcOwnerName,
	Record.col.value('(call/callType)[1]','varchar(64)') as vcCallType,
	Record.col.value('(call/coSpace)[1]','uniqueidentifier') as CoSpace,
	Record.col.value('(call/callCorrelator)[1]','uniqueidentifier') as CallCorrelator

from tblRawRecords

OUTER APPLY tblRawRecords.xmlBody.nodes('records') as Records(col)
OUTER APPLY tblRawRecords.xmlBody.nodes('records/record') as Record(col)

where not bitProcessed=1
AND
Record.col.value('(@type)[1]','varchar(64)') = 'callStart'

)
as Garbage

UPDATE tblRawRecords
SET bitProcessed=1, dtProcessed=SYSDATETIME()
WHERE tblRawRecords.ID in (SELECT intRawRecordID FROM @tblProcessed)

IF @@ERROR >0 RETURN -1

PRINT 'spProcessCallStart: Ending'

END

GO
/****** Object:  StoredProcedure [dbo].[spRemoveInvalidRawRecords]    Script Date: 01-Feb-22 13:18:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[spRemoveInvalidRawRecords]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- This section removes records that do not have a callBridge attribute
-- Discovered 01-Feb-2022 under CMS 3.3.0.6
DELETE 
FROM tblRawRecords
WHERE ID IN (
	SELECT  [ID]
	FROM [tblRawRecords]
	OUTER APPLY tblRawRecords.xmlBody.nodes('records') as Records(col)
	WHERE bitProcessed = 0
	AND Records.col.value('@callBridge','uniqueidentifier') is  null
)

END

GO
/****** Object:  StoredProcedure [dbo].[spResetAll]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spResetAll]

AS
BEGIN

TRUNCATE TABLE tblCallEnd
TRUNCATE TABLE tblCallLegStart
TRUNCATE TABLE tblCallLegUpdate
TRUNCATE TABLE tblCallStart
TRUNCATE TABLE tblCallLegEnd

UPDATE tblRawRecords
SET bitProcessed=0, dtProcessed=NULL


END
GO
/****** Object:  StoredProcedure [dbo].[spRpt_GetLargestMeetingsByMonth]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[spRpt_GetLargestMeetingsByMonth]
	@intYear smallint
AS
BEGIN


---SELECT t1.intYYYYMM as 'YYYYMM', t1.intCallLegsMaxActive, t1.dtTime
SELECT  t1.dtTime as 'Date/Time', 
	t1.intCallLegsMaxActive as 'Max Active Connections',
	tblCallStart.vcName as 'Room Name',
	tblCallStart.CallID AS 'Call ID'
FROM tblCallEnd AS t1
 LEFT OUTER JOIN tblCallEnd AS t2
  ON (t1.intYYYYMM = t2.intYYYYMM) AND ((t1.intCallLegsMaxActive < t2.intCallLegsMaxActive)
  OR (t1.intCallLegsMaxActive = t2.intCallLegsMaxActive) AND t1.CallID < t2.CallID)
  INNER JOIN
             tblCallStart ON t1.CallID = tblCallStart.CallID
   
WHERE t2.CallID IS NULL
 AND t1.dtTime >= DATEFROMPARTS(@intYear,01,01) AND t1.dtTime < DATEFROMPARTS(@intYear +1,01,01)

ORDER BY t1.intYYYYMM DESC


END
GO
/****** Object:  StoredProcedure [dbo].[spRpt_GetLargestMeetingsOfMonth]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spRpt_GetLargestMeetingsOfMonth]
	@vcMonth varchar(max)	-- yyyy-mm

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @intYear as smallint,
		@intMonth as smallint,
		@dtStart as datetime2,
		@dtEnd as datetime2

SET @intYear = cast(LEFT( @vcMonth, 4) as smallint)
SET @intMonth = cast(RIGHT( @vcMonth, 2) as smallint)
SET @dtStart = DATEFROMPARTS(@intYear,@intMonth,01)
SET @dtEnd = DATEADD(m,1,@dtStart)

SELECT TOP (10) ROW_NUMBER() OVER (ORDER BY tblCallEnd.intCallLegsMaxActive DESC, tblCallStart.dtTime ASC) AS ' ', 
	tblCallEnd.intCallLegsMaxActive as 'Max Active Connections', 
	tblCallStart.vcName as 'Room Name', 
	tblCallStart.dtTime as 'Date/Time',
	tblCallStart.CallID AS 'Call ID'

FROM   tblCallEnd INNER JOIN
             tblCallStart ON tblCallEnd.CallID = tblCallStart.CallID

WHERE tblCallStart.dtTime >= @dtStart AND tblCallStart.dtTime < @dtEnd



END
GO
/****** Object:  StoredProcedure [dbo].[spRpt_GetManHoursUsageOfTimeperiod]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spRpt_GetManHoursUsageOfTimeperiod]
	@dtStart	smalldatetime,
	@dtEnd		smalldatetime
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


SELECT SUM(intDurationSeconds)/60 as ManMinutes, SUM(intDurationSeconds)/60/60 as ManHours
FROM tblCallLegEnd
WHERE dtTime >= @dtStart AND dtTime < @dtEnd


END
GO
/****** Object:  StoredProcedure [dbo].[spRpt_GetMeetingDetail]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[spRpt_GetMeetingDetail]
	@CallID uniqueidentifier

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Meeting Summary table:
SELECT tblCallEnd.CallID as 'Call ID', 
		tblCallStart.dtTime as 'Begin Date/Time', 
		tblCallEnd.dtTime AS 'End Date/Time',
		tblCallStart.vcName AS 'Room', 
		tblCallEnd.intCallLegsMaxActive AS 'Peak Connections', 
		tblCallEnd.intDurationSeconds/60 AS 'Duration (m)'
FROM   tblCallEnd INNER JOIN
             tblCallStart ON tblCallEnd.CallID = tblCallStart.CallID
WHERE tblCallStart.CallID = @CallID

---------------------

-- Call leg (participants) table:
SELECT DISTINCT 
	DENSE_RANK() OVER (ORDER BY tblCallLegStart.dtTime) AS '#',
	tblCallLegStart.dtTime as 'Begin Date/Time',
	tblCallLegEnd.dtTime as 'End Date/Time',
	COALESCE(tblCallLegStart.vcDisplayName,tblCallLegUpdate.vcDisplayName) as 'Display Name',
	ISNULL(COALESCE(tblCallLegStart.vcRemoteAddress,tblCallLegUpdate.vcRemoteAddress),'-web-') as 'Remote Address',
	tblCallLegEnd.intDurationSeconds/60 as 'Duration (m)'
	

FROM tblCallLegStart
INNER JOIN tblCallLegEnd ON tblCallLegStart.CallLegID = tblCallLegEnd.CallLegID
INNER JOIN tblCallLegUpdate ON tblCallLegUpdate.CallLegID = tblCallLegEnd.CallLegID

-- The CallID is not registered in tblCallLegStart when audio endpoints initially connect, so we need to also pull from tblCallLegUpdate:
WHERE tblCallLegStart.CallLegID IN (
	SELECT CallLegID
	FROM tblCallLegUpdate
	WHERE CallID = @callid
	UNION ALL
	SELECT CallLegID
	FROM tblCallLegStart
	WHERE CallID = @callid
)

END
GO
/****** Object:  StoredProcedure [dbo].[spRpt_GetMonthlyManHoursUsageOfYear]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spRpt_GetMonthlyManHoursUsageOfYear]
	@intYear int NULL
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF @intYear IS NULL set @intYear = DATEPART(year,GETDATE())
SELECT SUM(intDurationSeconds)/60 as 'Man Minutes', SUM(intDurationSeconds)/60/60 as 'Man Hours', COUNT(CallLegId) AS 'Connections', intYYYYMM as 'YYYYMM'
FROM tblCallLegEnd
WHERE dtTime >= DATEFROMPARTS(@intYear,01,01) AND dtTime < DATEFROMPARTS(@intYear +1,01,01)
GROUP BY intYYYYMM
ORDER BY intYYYYMM

END
GO
/****** Object:  StoredProcedure [dbo].[spRpt_GetMonthlySystemUsageOfYear]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spRpt_GetMonthlySystemUsageOfYear]
	@intYear int NULL
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF @intYear IS NULL set @intYear = DATEPART(year,GETDATE())

SELECT SUM(intDurationSeconds)/60 as 'Room Minutes', SUM(intDurationSeconds)/60/60 as 'Room Hours', COUNT(CallID) as 'Meeting Count', intYYYYMM as YYYYMM
FROM tblCallEnd
WHERE dtTime >= DATEFROMPARTS(@intYear,01,01) AND dtTime < DATEFROMPARTS(@intYear +1,01,01)
GROUP BY intYYYYMM
ORDER BY intYYYYMM

END
GO
/****** Object:  StoredProcedure [dbo].[spRpt_GetRecentMeetings]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[spRpt_GetRecentMeetings]
	@intDays int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



SELECT tblCallEnd.CallID as 'Call ID', 
		tblCallStart.dtTime as 'Begin Date/Time', 
		tblCallEnd.dtTime AS 'End Date/Time',
		tblCallStart.vcName AS 'Room', 
		tblCallEnd.intCallLegsMaxActive AS 'Peak Connections', 
		tblCallEnd.intDurationSeconds/60 AS 'Duration (m)'
FROM   tblCallEnd INNER JOIN
             tblCallStart ON tblCallEnd.CallID = tblCallStart.CallID
WHERE  DATEDIFF(D,tblCallStart.dtTime,SYSDATETIME()) < @intDays
ORDER BY tblCallStart.dtTime DESC

END
GO
/****** Object:  StoredProcedure [dbo].[spRpt_GetRoomUsage]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spRpt_GetRoomUsage]
	@intRoom int,
	@dtStart	datetime2,
	@dtEnd		datetime2

AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

--DECLARE @vcSearch varchar(64)
--SET @vcSearch = cast(@intRoom as varchar(64))+'%'

SELECT tblCallStart.dtTime as 'Begin Date/Time', 
		tblCallEnd.dtTime as 'End Date/Time',
		tblCallEnd.intDurationSeconds/60 as 'Duration (m)',
		tblCallEnd.intCallLegsMaxActive as 'Peak Connections',
		tblCallEnd.CallID as 'Call ID'
FROM   tblCallStart INNER JOIN
             tblCallEnd ON tblCallEnd.CallID = tblCallStart.CallID
where tblCallStart.vcName like cast(@intRoom as varchar(64))+'%'
AND tblcallstart.dtTime >= @dtStart AND tblcallstart.dtTime < @dtEnd


END
GO
/****** Object:  StoredProcedure [dbo].[spRpt_GetRoomUsageDetail]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spRpt_GetRoomUsageDetail]
	@intRoom int,
	@dtStart	datetime2,
	@dtEnd		datetime2

AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

--DECLARE @vcSearch varchar(64)
--SET @vcSearch = cast(@intRoom as varchar(64))+'%'

SELECT tblCallStart.dtTime as 'Begin Date/Time', 
		tblCallEnd.dtTime as 'End Date/Time',
		tblCallEnd.intDurationSeconds/60 as 'Duration (m)',
		tblCallEnd.intCallLegsMaxActive as 'Peak Connections',
		tblCallEnd.CallID as 'Call ID'
FROM   tblCallStart INNER JOIN
             tblCallEnd ON tblCallEnd.CallID = tblCallStart.CallID
where tblCallStart.vcName like cast(@intRoom as varchar(64))+'%'
AND tblcallstart.dtTime >= @dtStart AND tblcallstart.dtTime < @dtEnd


END
GO
/****** Object:  StoredProcedure [dbo].[spRpt_GetRoomUsageTotalOfTimeperiod]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[spRpt_GetRoomUsageTotalOfTimeperiod]
	@dtStart	smalldatetime,
	@dtEnd		smalldatetime
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


SELECT SUM(intDurationSeconds)/60 as RoomMinutes, SUM(intDurationSeconds)/60/60 as RoomHours
FROM tblCallEnd
WHERE dtTime >= @dtStart AND dtTime < @dtEnd


END
GO
/****** Object:  StoredProcedure [dbo].[spRpt_GetTopEndpointsOfTimeperiod]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spRpt_GetTopEndpointsOfTimeperiod]


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT TOP 10 vcDisplayName as 'Endpoint Name', count(vcDisplayName) as 'Connections'
FROM tblCallLegStart
WHERE NOT vcDisplayName	= 'Unknown Party'
GROUP BY vcDisplayName
ORDER BY Connections DESC

END
GO
/****** Object:  StoredProcedure [dbo].[spRpt_GetTopRoomsOfTimeperiod]    Script Date: 08-Jul-21 14:42:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spRpt_GetTopRoomsOfTimeperiod]
	@dtStart	smalldatetime,
	@dtEnd		smalldatetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT TOP 10 vcName, COUNT(vcName) AS Meetings
FROM tblCallStart
WHERE dtTime >= @dtStart AND dtTime < @dtEnd
GROUP BY vcName
ORDER BY Meetings DESC

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
         Begin Table = "t1"
            Begin Extent = 
               Top = 63
               Left = 464
               Bottom = 437
               Right = 740
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblCallStart"
            Begin Extent = 
               Top = 55
               Left = 70
               Bottom = 460
               Right = 316
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t2"
            Begin Extent = 
               Top = 62
               Left = 900
               Bottom = 414
               Right = 1176
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_1'
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
         Begin Table = "tblRawRecords"
            Begin Extent = 
               Top = 9
               Left = 57
               Bottom = 683
               Right = 618
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vuRecentRawRecords'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vuRecentRawRecords'
GO
USE [master]
GO
ALTER DATABASE [CMS_CDR] SET  READ_WRITE 
GO
USE [msdb]
GO




/****** Object:  Job [CMS_CDR_Process_All_Records]    Script Date: 04-Aug-21 11:29:09 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Data Collector]    Script Date: 04-Aug-21 11:29:09 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Data Collector' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Data Collector'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'CMS_CDR_Process_All_Records', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [step01]    Script Date: 04-Aug-21 11:29:10 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'step01', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbo.spProcessAll', 
		@database_name=N'CMS_CDR', 
		@database_user_name=N'cmscdr', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every_15m', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20210514, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'77827144-e286-424d-9c58-95d3ffacdcd4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
