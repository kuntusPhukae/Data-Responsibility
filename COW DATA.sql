declare @Stratdate datetime
declare @now datetime
set @now = getdate()
set @Stratdate = dateadd(day,-180,@now)

SELECT
	CoW.serial_no,
	CoW.date_time,
	CONCAT(year(CoW.date_time),DATEPART(week,CoW.date_time)) as Ck,
	CoW.operation,
	CoW.description as OPN_Map,
	(SELECT Top 1 S.operation FROM [dbAcacia_VW].[dbo].[vw_SMTUnitHistoryTracking] S WHERE S.serial_no = CoW.serial_no Order by S.trans_seq desc) AS last_opn,
	(SELECT Top 1 S.description FROM [dbAcacia_VW].[dbo].[vw_SMTUnitHistoryTracking] S WHERE S.serial_no = CoW.serial_no Order by S.trans_seq desc) as Last_Map,
	CoW.part_no,
	CoW.workorder,
	'Cow' AS model,
	NULLIF((SELECT TOP(1) a.attribute_value FROM [dbSMT_Acacia].[dbo].[vw_UnitAttributeTracking_ACACIA] a WHERE a.serial_no = CoW.serial_no and a.operation = CoW.operation and a.attribute_code in ('111027','111026')),0) as Input,
	NULLIF(ISNULL((SELECT TOP(1) a.attribute_value FROM [dbSMT_Acacia].[dbo].[vw_UnitAttributeTracking_ACACIA] a WHERE a.serial_no = CoW.serial_no and a.operation = CoW.operation and a.attribute_code in ('111028')),(SELECT TOP(1) a.attribute_value FROM [dbSMT_Acacia].[dbo].[vw_UnitAttributeTracking_ACACIA] a WHERE a.serial_no = CoW.serial_no and a.operation = CoW.operation and a.attribute_code in ('111027','111026'))),0)as Output,
	ISNULL((SELECT TOP(1) a.attribute_value FROM [dbSMT_Acacia].[dbo].[vw_UnitAttributeTracking_ACACIA] a WHERE a.serial_no = CoW.serial_no and a.operation = CoW.operation and a.attribute_code in ('111029')),0)as Reject,
	CAST(NULLIF(CAST((SELECT TOP(1) a.attribute_value FROM [dbSMT_Acacia].[dbo].[vw_UnitAttributeTracking_ACACIA] a WHERE a.serial_no = CoW.serial_no and a.operation = CoW.operation and a.attribute_code in ('111028','111026'))AS decimal),0)/NULLIF(CAST((SELECT TOP(1)a.attribute_value FROM [dbSMT_Acacia].[dbo].[vw_UnitAttributeTracking_ACACIA] a WHERE a.serial_no = CoW.serial_no and a.operation = CoW.operation and a.attribute_code in ('111026','111027'))AS decimal),0) AS decimal(4,3)) as First_Yield,
	--CAST('0' AS decimal(4,3) ) AS Retest_Yield,
	CAST(NULLIF(CAST((SELECT TOP(1) a.attribute_value FROM [dbSMT_Acacia].[dbo].[vw_UnitAttributeTracking_ACACIA] a WHERE a.serial_no = CoW.serial_no and a.operation = CoW.operation and a.attribute_code in ('111028','111026'))AS decimal),0)/NULLIF(CAST((SELECT TOP(1)a.attribute_value FROM [dbSMT_Acacia].[dbo].[vw_UnitAttributeTracking_ACACIA] a WHERE a.serial_no = CoW.serial_no and a.operation = CoW.operation and a.attribute_code in ('111026','111027'))AS decimal),0) AS decimal(4,3)) as Final_Yield
	
	
	FROM [dbAcacia_VW].[dbo].[vw_SMTUnitHistoryTracking] CoW

	WHERE
	CoW.part_no like ('492%')
	--AND CoW.RESULT = 'FAIL'
	AND CoW.serial_no not like ('%test%')
	AND CoW.operation like ('CW%')
	--AND CoW.serial_no = '5AIA2901-02'
	AND CoW.operation in ('WF110',
	'WF200',
	'WF300',
	'WF400',
	'WF500',
	'WF210',
	'CW110',
	'CW125',
	'CW135',
	'CW300',
	'CW150',
	'CW310',
	'CW320',
	'CW160',
	'CW165',
	'CW180',
	'CW3781')
	AND CoW.trans_seq = (SELECT Top 1 S.trans_seq FROM [dbAcacia_VW].[dbo].[vw_SMTUnitHistoryTracking] S WHERE S.serial_no = CoW.serial_no AND S.operation = CoW.operation Order by S.trans_seq desc)
	AND CoW.date_time >@Stratdate;
