declare @Stratdate datetime
declare @now datetime
set @now = getdate()
set @Stratdate = dateadd(day,-270,@now)

	SELECT
	SMT.serial_no,
	SMT.date_time,
	null AS date_time_checkout,
	IIF(DATEDIFF(DAY,SMT.date_time,getdate())<4,'Y','N') AS DATE_Filter,
	IIF(DATEDIFF(WEEK,SMT.date_time,getdate())<4,'Y','N') AS WEEK_Filter,
	IIF(DATEDIFF(MONTH,SMT.date_time,getdate())<3,'Y','N') AS MONTH_Filter,
	SMT.date_time AS DATE,
	CONCAT(year(SMT.date_time),DATEPART(week,SMT.date_time)) as Ck,
	SMT.operation,
	SMT.description as OPN_Map,
	(SELECT Top 1 S.operation FROM [dbAcacia_VW].[dbo].[vw_SMTUnitHistoryTracking] S WITH(NOLOCK) WHERE S.serial_no = SMT.serial_no Order by S.trans_seq desc) AS last_opn,
	(SELECT Top 1 S.description FROM [dbAcacia_VW].[dbo].[vw_SMTUnitHistoryTracking] S WITH(NOLOCK) WHERE S.serial_no = SMT.serial_no Order by S.trans_seq desc) as Last_Map,
	SMT.part_no,
	SMT.workorder,
	'PCBA' AS model,
	1 as Input,
	IIF(SMT.RESULT = 'FAIL',0,1) as Output,
	IIF(SMT.RESULT = 'FAIL',1,0) as Reject,
	IIF(SMT.RESULT = 'FAIL',0,1) as First_Yield,
	IIF(SMT.RESULT not in ('FAIL'),1,IIF((SELECT Top 1 eve.RESULT FROM [dbAcacia_VW].[dbo].[vw_SMTUnitHistoryTracking] eve WITH(NOLOCK) WHERE eve.serial_no = SMT.serial_no AND eve.operation = SMT.operation AND eve.trans_seq > SMT.trans_seq Order by eve.trans_seq) NOT IN ('FAIL'),1,0)) AS Retest_Yield,
	IIF(SMT.RESULT not in ('FAIL'),1,IIF((SELECT Top 1 eve.RESULT FROM [dbAcacia_VW].[dbo].[vw_SMTUnitHistoryTracking] eve WITH(NOLOCK) WHERE eve.serial_no = SMT.serial_no AND eve.operation = SMT.operation AND eve.trans_seq > SMT.trans_seq Order by eve.trans_seq) not in ('FAIL'),1,IIF((SELECT Top 1 eve.RESULT FROM [dbAcacia_VW].[dbo].[vw_SMTUnitHistoryTracking] eve WITH(NOLOCK) WHERE eve.serial_no = SMT.serial_no AND eve.operation = SMT.operation AND eve.trans_seq > SMT.trans_seq Order by eve.trans_seq desc) not in ('FAIL'),1,0))) AS Final_Yield,
	IIF(SMT.RESULT = 'FAIL',(SELECT Top 1 SS.attribute_value FROM [dbAcacia_VW].[dbo].[vw_SMTUnitAttributeTracking_ACACIA_WITH_Description] SS WHERE SS.serial_no = SMT.serial_no AND SS.operation = SMT.operation AND SS.trans_seq = SMT.trans_seq AND (SS.attribute_value like ('G%') OR SS.attribute_value like ('B%') OR SS.attribute_value like ('T%') OR SS.attribute_value like ('U%'))),'PASS') AS Defects,
	'' AS Result,
	--(SELECT Top 1 SS.description FROM [dbAcacia_VW].[dbo].[vw_SMTUnitAttributeTracking_ACACIA_WITH_Description] SS WHERE SS.serial_no = SMT.serial_no AND SS.operation = SMT.operation AND SS.trans_seq = SMT.trans_seq AND (SS.attribute_value like ('G%') OR SS.attribute_value like ('B%') OR SS.attribute_value like ('T%') OR SS.attribute_value like ('U%'))) AS FailLocation,
	1 AS Qty,
	null AS TopD

	FROM [dbAcacia_VW].[dbo].[vw_SMTUnitHistoryTracking] SMT

	WHERE
	SMT.part_no like ('550-02%')
	--AND SMT.RESULT = 'FAIL'
	AND SMT.operation in ('111',
	'310B',
	'116',
	'115',
	'125',
	'126',
	'145M',
	'345',
	'345B',
	'150',
	'324',
	'344B',
	'344',
	'311',
	'135B',
	'1362',
	'325',
	'3781',
	'382')
	AND SMT.trans_seq = (SELECT Top 1 S.trans_seq FROM [dbAcacia_VW].[dbo].[vw_SMTUnitHistoryTracking] S WITH(NOLOCK) WHERE S.serial_no = SMT.serial_no AND S.operation = SMT.operation Order by S.trans_seq)
	AND SMT.date_time >@Stratdate
