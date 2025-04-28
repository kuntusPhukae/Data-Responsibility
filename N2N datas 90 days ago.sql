declare @Stratdate datetime
set @Stratdate = dateadd(day,-90,GETDATE())

	SELECT
	CoW.serial_no,
	CoW.date_time,
	Null AS date_time_checkout,
	IIF(DATEDIFF(DAY,CoW.date_time,getdate())<4,'Y','N') AS DATE_Filter,
	IIF(DATEDIFF(WEEK,CoW.date_time,getdate())<4,'Y','N') AS WEEK_Filter,
	IIF(DATEDIFF(MONTH,CoW.date_time,getdate())<3,'Y','N') AS MONTH_Filter,
	CoW.date_time AS DATE,
	CoW.operation,
	CoW.description as OPN_Map,
	(SELECT Top 1 S.operation FROM [dbAcacia_VW].[dbo].[vw_SMTUnitHistoryTracking] S WHERE S.serial_no = CoW.serial_no Order by S.trans_seq desc) AS last_opn,
	(SELECT Top 1 S.description FROM [dbAcacia_VW].[dbo].[vw_SMTUnitHistoryTracking] S WHERE S.serial_no = CoW.serial_no Order by S.trans_seq desc) as Last_Map,
	CoW.part_no,
	CoW.workorder,
	'Cow' AS model,
	IIF(CoW.RESULT not in ('FAIL'),1,CAST(CAST((SELECT Top 1 a.attribute_value FROM [dbSMT_Acacia].[dbo].[vw_UnitAttributeTracking_ACACIA] a WHERE a.serial_no = CoW.serial_no AND a.operation = CoW.operation AND a.trans_seq = CoW.trans_seq AND a.attribute_code = '111028') AS Decimal(7,2))/CAST((SELECT Top 1 a.attribute_value FROM [dbSMT_Acacia].[dbo].[vw_UnitAttributeTracking_ACACIA] a WHERE a.serial_no = CoW.serial_no AND a.operation = CoW.operation AND a.trans_seq = CoW.trans_seq AND a.attribute_code = '111027') AS Decimal(7,2)) AS Decimal(7,2))) as First_Yield,
	IIF(CoW.RESULT not in ('FAIL'),1,CAST(CAST((SELECT Top 1 a.attribute_value FROM [dbSMT_Acacia].[dbo].[vw_UnitAttributeTracking_ACACIA] a WHERE a.serial_no = CoW.serial_no AND a.operation = CoW.operation AND a.trans_seq = CoW.trans_seq AND a.attribute_code = '111028') AS Decimal(7,2))/CAST((SELECT Top 1 a.attribute_value FROM [dbSMT_Acacia].[dbo].[vw_UnitAttributeTracking_ACACIA] a WHERE a.serial_no = CoW.serial_no AND a.operation = CoW.operation AND a.trans_seq = CoW.trans_seq AND a.attribute_code = '111027') AS Decimal(7,2)) AS Decimal(7,2))) AS Retest_Yield,
	IIF(CoW.RESULT not in ('FAIL'),1,CAST(CAST((SELECT Top 1 a.attribute_value FROM [dbSMT_Acacia].[dbo].[vw_UnitAttributeTracking_ACACIA] a WHERE a.serial_no = CoW.serial_no AND a.operation = CoW.operation AND a.trans_seq = CoW.trans_seq AND a.attribute_code = '111028') AS Decimal(7,2))/CAST((SELECT Top 1 a.attribute_value FROM [dbSMT_Acacia].[dbo].[vw_UnitAttributeTracking_ACACIA] a WHERE a.serial_no = CoW.serial_no AND a.operation = CoW.operation AND a.trans_seq = CoW.trans_seq AND a.attribute_code = '111027') AS Decimal(7,2)) AS Decimal(7,2))) AS Final_Yield,
	IIF(CoW.RESULT = 'FAIL',ae.attribute_value,'PASS') AS Defects,
	--IIF(CoW.RESULT = 'FAIL',(SELECT Top 1 SS.attribute_value FROM [dbAcacia_VW].[dbo].[vw_SMTUnitAttributeTracking_ACACIA_WITH_Description] SS WHERE SS.serial_no = CoW.serial_no AND SS.operation = CoW.operation AND SS.trans_seq = CoW.trans_seq AND (SS.attribute_value like ('G%') OR SS.attribute_value like ('B%') OR SS.attribute_value like ('T%') OR SS.attribute_value like ('U%') OR SS.attribute_value like ('W%'))),'PASS') AS Defects,
	CoW.RESULT AS Result,
	--IIF(CoW.RESULT = 'FAIL',(SELECT Top 1 SS.description FROM [dbAcacia_VW].[dbo].[vw_SMTUnitAttributeTracking_ACACIA_WITH_Description] SS WHERE SS.serial_no = CoW.serial_no AND SS.operation = CoW.operation AND SS.trans_seq = CoW.trans_seq AND SS.attribute_code = ae.attribute_code AND (SS.attribute_value like ('G%') OR SS.attribute_value like ('B%') OR SS.attribute_value like ('T%') OR SS.attribute_value like ('U%') OR SS.attribute_value like ('W%'))),NULL) AS FailLocation,
	(SELECT Top 1 a.attribute_value FROM [dbSMT_Acacia].[dbo].[vw_UnitAttributeTracking_ACACIA] a WHERE a.serial_no = CoW.serial_no AND a.operation = CoW.operation AND a.trans_seq = CoW.trans_seq AND a.attribute_code in ('111027','111026')) AS Qty,
	IIF(ae.attribute_code = (SELECT Top 1 e.attribute_code FROM [dbSMT_Acacia].[dbo].[vw_UnitAttributeTracking_ACACIA] e WHERE e.serial_no = ae.serial_no AND e.operation = ae.operation AND e.trans_seq = ae.trans_seq AND (e.attribute_value like ('G%') OR e.attribute_value like ('B%') OR e.attribute_value like ('T%') OR e.attribute_value like ('U%') OR e.attribute_value like ('W%')) Order by e.attribute_code ),'Y','N') AS TopD

	FROM [dbAcacia_VW].[dbo].[vw_SMTUnitHistoryTracking] CoW

	LEFT JOIN [dbSMT_Acacia].[dbo].[vw_UnitAttributeTracking_ACACIA] ae
	ON ae.serial_no = CoW.serial_no
	AND ae.operation = CoW.operation
	AND ae.trans_seq = CoW.trans_seq
	AND ae.attribute_value like ('%:%')
	AND (ae.attribute_value like ('G%') OR ae.attribute_value like ('B%') OR ae.attribute_value like ('T%') OR ae.attribute_value like ('U%') OR ae.attribute_value like ('W%'))

	WHERE
	CoW.part_no like ('492%')
	--AND CoW.RESULT = 'FAIL'
	AND CoW.serial_no not like ('%test%')
	AND CoW.operation like ('CW%')
	--AND CoW.serial_no = '5AIY1402-20'
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
	AND CoW.date_time >@Stratdate

union all

	/****** Script for SelectTopNRows command from SSMS  ******/
	SELECT
	vwevent.serial_no,
	--vwevent.sn_attr_code,
	vwevent.date_time,
	vwevent.date_time_checkout,
	IIF(DATEDIFF(DAY,IIF(vwevent.date_time_checkout is not null,vwevent.date_time_checkout,vwevent.date_time),getdate())<4,'Y','N') AS DATE_Filter,
	IIF(DATEDIFF(WEEK,IIF(vwevent.date_time_checkout is not null,vwevent.date_time_checkout,vwevent.date_time),getdate())<4,'Y','N') AS WEEK_Filter,
	IIF(DATEDIFF(MONTH,IIF(vwevent.date_time_checkout is not null,vwevent.date_time_checkout,vwevent.date_time),getdate())<3,'Y','N') AS MONTH_Filter,
	IIF(vwevent.date_time_checkout is not null,vwevent.date_time_checkout,vwevent.date_time) AS DATE,
	--CONCAT(RIGHT(LEFT(IIF(vwevent.date_time_checkout is null,vwevent.date_time,vwevent.date_time_checkout),11),4),DATEPART(WEEK,IIF(vwevent.date_time_checkout is not null,vwevent.date_time_checkout,vwevent.date_time))) AS WEEK,
	--LEFT(LEFT(IIF(vwevent.date_time_checkout is null,vwevent.date_time,vwevent.date_time_checkout),11),3) AS MONTH,
	--RIGHT(LEFT(IIF(vwevent.date_time_checkout is null,vwevent.date_time,vwevent.date_time_checkout),11),4) AS YEAR,
	--IIF(IIF(vwevent.date_time_checkout is not null,vwevent.date_time_checkout,vwevent.date_time) < '2024-08-01','FY24 Q4','FY25 Q1') AS Quarter,
	vwevent.operation,
	OPN_Map.description as OPN_Map,
	Last_OPN.last_opn,
	Last_Map.description as Last_Map,
	--vwevent.disp_code,
	vwevent.part_no,
	vwevent.workorder,
	IIF(vwevent.sn_attr_code = '710001','ODB',IIF(vwevent.sn_attr_code = '61001','TOSA',vwevent.model)) AS model,
	CONVERT(INT,vwevent.status) as First_Yield,
	IIF(vwevent.status = '1',1,IIF((SELECT Top 1 eve.status FROM [dbAcacia_VW].[dbo].[vw_event] eve WITH(NOLOCK) WHERE eve.serial_no = vwevent.serial_no AND eve.sn_attr_code = vwevent.sn_attr_code AND eve.operation = vwevent.operation AND eve.trans_seq > vwevent.trans_seq Order by eve.trans_seq)=1,1,0)) AS Retest_Yield,
	IIF(vwevent.status = '1',1,IIF(IIF(vwevent.status = '1',1,IIF((SELECT Top 1 eve.status FROM [dbAcacia_VW].[dbo].[vw_event] eve WITH(NOLOCK) WHERE eve.serial_no = vwevent.serial_no AND eve.sn_attr_code = vwevent.sn_attr_code AND eve.operation = vwevent.operation AND eve.trans_seq > vwevent.trans_seq Order by eve.trans_seq)=1,1,0))=1,1,(SELECT Top 1 eve.status FROM [dbAcacia_VW].[dbo].[vw_event] eve WITH(NOLOCK) WHERE eve.serial_no = vwevent.serial_no AND eve.sn_attr_code = vwevent.sn_attr_code AND eve.operation = vwevent.operation Order by eve.trans_seq desc))) AS Final_Yield,
	IIF(IIF(vwevent.status = '1','PASS',[dbAcacia_VW].[dbo].[fn_DecodeDispCode]((SELECT attr.attribute_value FROM [dbAcacia_VW].[dbo].[vw_attribute] attr WITH(NOLOCK) WHERE attr.serial_no = vwevent.serial_no AND attr.sn_attr_code = vwevent.sn_attr_code AND attr.operation = vwevent.operation AND attr.attribute_code = '11009' AND attr.trans_seq = vwevent.trans_seq),'11009',vwevent.operation,Last_OPN.model_type,'1')) = 'FAIL',IIF(vwevent.status = '1','PASS',[dbAcacia_VW].[dbo].[fn_DecodeDispCode]((SELECT attr.attribute_value FROM [dbAcacia_VW].[dbo].[vw_attribute] attr WITH(NOLOCK) WHERE attr.serial_no = vwevent.serial_no AND attr.sn_attr_code = vwevent.sn_attr_code AND attr.operation = vwevent.operation AND attr.attribute_code = '100101' AND attr.trans_seq = vwevent.trans_seq),'100101',vwevent.operation,Last_OPN.model_type,'1')),IIF(vwevent.status = '1','PASS',[dbAcacia_VW].[dbo].[fn_DecodeDispCode]((SELECT attr.attribute_value FROM [dbAcacia_VW].[dbo].[vw_attribute] attr WITH(NOLOCK) WHERE attr.serial_no = vwevent.serial_no AND attr.sn_attr_code = vwevent.sn_attr_code AND attr.operation = vwevent.operation AND attr.attribute_code = '11009' AND attr.trans_seq = vwevent.trans_seq),'11009',vwevent.operation,Last_OPN.model_type,'1'))) AS Defects,
	--IIF(vwevent.operation in ('1900','2952') AND vwevent.status = '0',(SELECT Top 1 atr.attribute_value FROM [dbAcacia_VW].[dbo].[vw_attribute] atr WITH(NOLOCK) WHERE atr.serial_no = vwevent.serial_no AND atr.sn_attr_code = vwevent.sn_attr_code AND atr.operation in ('6550','6551') AND atr.trans_seq = vwevent.trans_seq+1 AND atr.attribute_code = '1203'),NULL) AS Process_Remark,
	--(SELECT attr.attribute_value FROM [dbAcacia_VW].[dbo].[vw_attribute] attr WITH(NOLOCK) WHERE attr.serial_no = vwevent.serial_no AND attr.sn_attr_code = vwevent.sn_attr_code AND attr.operation = vwevent.operation AND attr.attribute_code = '198711' AND attr.trans_seq = vwevent.trans_seq) AS Total_Defect,
	(SELECT attr.attribute_value FROM [dbAcacia_VW].[dbo].[vw_attribute] attr WITH(NOLOCK) WHERE attr.serial_no = vwevent.serial_no AND attr.sn_attr_code = vwevent.sn_attr_code AND attr.operation = vwevent.operation AND attr.attribute_code = '1101' AND attr.trans_seq = vwevent.trans_seq) AS Result,
	--null as FailLocation,
	1 AS Qty,
	null AS TopD

	FROM [dbAcacia_VW].[dbo].[vw_event] vwevent WITH(NOLOCK)
	LEFT JOIN [dbAcacia_VW].[dbo].[vw_event_master] Last_OPN WITH(NOLOCK)
	ON Last_OPN.serial_no = vwevent.serial_no
	AND Last_OPN.sn_attr_code = vwevent.sn_attr_code

	LEFT JOIN [dbAcacia_VW].[dbo].[vw_operation_map] OPN_Map WITH(NOLOCK)
	ON OPN_Map.operation = vwevent.operation
	AND OPN_Map.model_type = Last_OPN.model_type

	LEFT JOIN [dbAcacia_VW].[dbo].[vw_operation_map] Last_Map WITH(NOLOCK)
	ON Last_Map.operation = Last_OPN.last_opn
	AND Last_Map.model_type = Last_OPN.model_type

	WHERE
	vwevent.sn_attr_code in ('359100')
	--AND vwevent.sn_attr_code in ('410001')
	AND (vwevent.part_no like ('526%') OR vwevent.part_no like ('527%'))
	AND vwevent.serial_no like ('2%')
	AND vwevent.status in ('1','0')
	AND vwevent.operation in ('100',
	'150L',
	'110',
	'110A',
	'111',
	'910',
	'120',
	'130',
	'920',
	'140',
	'140A',
	'141',
	'150',
	'155',
	'160',
	'165',
	'166',
	'925',
	'169',
	'170',
	'180',
	'200',
	'930',
	'SHIP')
	AND vwevent.trans_seq = (SELECT Top 1 eve.trans_seq FROM [dbAcacia_VW].[dbo].[vw_event] eve WITH(NOLOCK) WHERE eve.serial_no = vwevent.serial_no AND eve.sn_attr_code = vwevent.sn_attr_code AND eve.operation = vwevent.operation Order by eve.trans_seq)
	--AND vwevent.model in ('QSFP Bright','Tunable Laser','QSFP-2A','OSFP','CFP2 Zephyr','CFP2-Krypton')
	AND IIF(vwevent.date_time_checkout is not null,vwevent.date_time_checkout,vwevent.date_time) > @Stratdate

union all

	SELECT
	SMT.serial_no,
	SMT.date_time,
	null AS date_time_checkout,
	IIF(DATEDIFF(DAY,SMT.date_time,getdate())<4,'Y','N') AS DATE_Filter,
	IIF(DATEDIFF(WEEK,SMT.date_time,getdate())<4,'Y','N') AS WEEK_Filter,
	IIF(DATEDIFF(MONTH,SMT.date_time,getdate())<3,'Y','N') AS MONTH_Filter,
	SMT.date_time AS DATE,
	SMT.operation,
	SMT.description as OPN_Map,
	(SELECT Top 1 S.operation FROM [dbAcacia_VW].[dbo].[vw_SMTUnitHistoryTracking] S WHERE S.serial_no = SMT.serial_no Order by S.trans_seq desc) AS last_opn,
	(SELECT Top 1 S.description FROM [dbAcacia_VW].[dbo].[vw_SMTUnitHistoryTracking] S WHERE S.serial_no = SMT.serial_no Order by S.trans_seq desc) as Last_Map,

	SMT.part_no,
	SMT.workorder,
	'PCBA' AS model,
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
	SMT.part_no like ('550-0230%')
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
	AND SMT.trans_seq = (SELECT Top 1 S.trans_seq FROM [dbAcacia_VW].[dbo].[vw_SMTUnitHistoryTracking] S WHERE S.serial_no = SMT.serial_no AND S.operation = SMT.operation Order by S.trans_seq)
	AND SMT.date_time >@Stratdate
