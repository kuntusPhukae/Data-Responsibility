declare @Stratdate datetime
declare @now datetime
set @now = getdate()
set @Stratdate = dateadd(day,-270,@now)

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
	CONCAT(year(vwevent.date_time),DATEPART(week,vwevent.date_time)) as Ck,
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
	1 as Input,
	vwevent.status as Output,
	IIF(vwevent.status = 0,1,0 ) as Reject,
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
	AND vwevent.serial_no not in ('2443C1320','2443C1415','2443C1459')
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
