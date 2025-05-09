SELECT (select top 1 ea.attribute_value from [dbAcacia_VW].[dbo].[vw_attribute]ea where ea.serial_no = em.serial_no and ea.trans_seq = ev.trans_seq and ea.operation = ev.operation and ea.attribute_code ='5107') as [Date/Time]
	, em.serial_no as [Searial Number]
	--,ev.trans_seq
	,(select top 1 ea.attribute_value from [dbAcacia_VW].[dbo].[vw_attribute]ea where ea.serial_no = em.serial_no and ea.trans_seq = ev.trans_seq and ea.operation = ev.operation and ea.attribute_code ='10112') as [Part Number]
	,(select top 1 ea.attribute_value from [dbAcacia_VW].[dbo].[vw_attribute]ea where ea.serial_no = em.serial_no and ea.trans_seq = ev.trans_seq and ea.operation = ev.operation and ea.attribute_code ='877662') as [Missing Ball]
	,(select top 1 ea.attribute_value from [dbAcacia_VW].[dbo].[vw_attribute]ea where ea.serial_no = em.serial_no and ea.trans_seq = ev.trans_seq and ea.operation = ev.operation and ea.attribute_code ='29395') as [Final Result]
	,(select top 1 ea.attribute_value from [dbAcacia_VW].[dbo].[vw_attribute]ea where ea.serial_no = em.serial_no and ea.trans_seq = ev.trans_seq and ea.operation = ev.operation and ea.attribute_code ='5106') as [Station ID]
	,(select top 1 ea.attribute_value from [dbAcacia_VW].[dbo].[vw_attribute]ea where ea.serial_no = em.serial_no and ea.trans_seq = ev.trans_seq and ea.operation = ev.operation and ea.attribute_code ='19001') as [EN]
	,(select top 1 ea.attribute_value from [dbAcacia_VW].[dbo].[vw_attribute]ea where ea.serial_no = em.serial_no and ea.trans_seq = ev.trans_seq and ea.operation = ev.operation and ea.attribute_code ='3017') as [Link Photo]

  FROM [dbAcacia_VW].[dbo].[vw_event_master]em
  inner join [dbAcacia_VW].[dbo].[vw_event]ev
			 on	ev.serial_no =em.serial_no and ev.operation='250'
			 and ev.sn_attr_code=em.sn_attr_code
			 and ev.trans_seq = (select max(ev2.trans_seq) from [dbAcacia_VW].[dbo].[vw_event]ev2 where ev2.serial_no =em.serial_no and ev2.operation='250'and ev2.sn_attr_code=em.sn_attr_code)

  where em.last_opn in ('250')
  and em.sn_attr_code ='94001'
  and em.serial_no in ('250280204',
'250280504',
'250282223',
'250282221',
'250280510',
'250282219',
'250280512',
'250280515',
'250282213',
'250282212',
'250282211',
'250280521',
'250282208',
'250282176',
'250280567',
'250282175',
'250280574',
'250280575',
'250280576',
'250280583',
'250280584',
'250282167',
'250280966',
'250282165',
'250280969',
'250280971',
'250282164',
'250280976',
'250281W50',
'250280978',
'250280981',
'250280982',
'250280A02',
'250280A32',
'250280A51',
'250280A52',
'250280A53',
'250280A54',
'250281V16',
'250281V15',
'250280A59',
'250280A61',
'250281V07',
'250280A66',
'250280A69',
'250280A70',
'250280C14',
'250281V06',
'250280C16',
'250280C18',
'250280C19',
'250280C21',
'250280C22',
'250281U98',
'250280C24',
'250281U97',
'250281U96',
'250280C27',
'250280C29',
'250280C30',
'250280C31',
'250280C33',
'250281U74',
'250280C39',
'250280C40',
'250280C47',
'250280C53',
'250280D00',
'250281U72',
'250280D22',
'250280D24',
'250281U71',
'250280D26',
'250281U69',
'250281U64',
'250281U62',
'250280D33',
'250280D34',
'250281U60',
'250281U58',
'250280D37',
'250280D38',
'250281U55',
'250281U54',
'250281U50',
'250280U79',
'250280U95',
'250280V08',
'250280V15',
'250281U43',
'250281790',
'250280V22',
'250280V37',
'250280V38',
'250281677',
'250281667',
'250280V41',
'250280V42',
'250280V43',
'250280V47',
'250281660',
'250280V58',
'250280V59',
'250280V60',
'250280V64',
'250280V65',
'250281656',
'250280V67',
'250280V69',
'250280V71',
'250281118',
'250281122',
'250281125',
'250281655',
'250281129',
'250281130',
'250281654',
'250281132',
'250281133',
'250281134',
'250281135',
'250281137',
'250281138',
'250281140',
'250281649',
'250281142',
'250281143',
'250281144',
'250281145',
'250281629',
'250281147',
'250281625',
'250281149',
'250281151',
'250281152',
'250281153',
'250281611',
'250281599',
'250281162',
'250281316',
'250281558',
'250281598',
'250281574',
'250281566',
'250281567',
'250281569',
'250281570',
'250281571',
'250281572')