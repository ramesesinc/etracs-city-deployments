[getNodes]
select n.name, n.title as caption
from sys_wf_node n
where n.processname = 'faas'
and n.name not like 'assign%'
and n.name <> 'start'
and exists(select * from sys_wf_transition where processname='faas' and parentid = n.name)
order by n.idx


[insertFaasList]
insert into faas_list(
	objid,
	state,
	datacapture,
	rpuid,
	realpropertyid,
	ry,
	txntype_objid,
	tdno,
	utdno,
	prevtdno,
	displaypin,
	pin,
	taxpayer_objid,
	owner_name,
	owner_address,
	administrator_name,
	administrator_address,
	rputype,
	barangayid,
	barangay,
	classification_objid,
	classcode,
	cadastrallotno,
	blockno,
	surveyno,
	titleno,
	totalareaha,
	totalareasqm,
	totalmv,
	totalav,
	effectivityyear,
	effectivityqtr,
	cancelreason,
	cancelledbytdnos,
	lguid,
	originlguid,
	yearissued,
	taskid,
	taskstate,
	assignee_objid,
	trackingno
)
select 
	f.objid,
	f.state,
	f.datacapture,
	f.rpuid,
	f.realpropertyid,
	r.ry,
	f.txntype_objid,
	f.tdno,
	f.utdno,
	f.prevtdno,
	f.fullpin as displaypin,
	case when r.rputype = 'land' then rp.pin else rp.pin + '-' + convert(varchar(4),r.suffix) end as pin,
	f.taxpayer_objid,
	f.owner_name,
	f.owner_address,
	f.administrator_name,
	f.administrator_address,
	r.rputype,
	rp.barangayid,
	(select name from barangay where objid = rp.barangayid) as barangay,
	r.classification_objid,
	pc.code as classcode,
	rp.cadastrallotno,
	rp.blockno,
	rp.surveyno,
	f.titleno,
	r.totalareaha,
	r.totalareasqm,
	r.totalmv,
	r.totalav,
	f.effectivityyear,
	f.effectivityqtr,
	f.cancelreason,
	f.cancelledbytdnos,
	f.lguid,
	f.originlguid,
	f.year as yearissued,
	(select objid from faas_task where refid = f.objid and enddate is null) as taskid,
	(select state from faas_task where refid = f.objid and enddate is null) as taskstate,
	(select assignee_objid from faas_task where refid = f.objid and enddate is null) as assignee_objid,
	(select trackingno from rpttracking where objid = f.objid) as trackingno
from faas f 
	inner join rpu r on f.rpuid = r.objid 
	inner join realproperty rp on f.realpropertyid = rp.objid 
	left join propertyclassification pc on r.classification_objid = pc.objid 
where f.objid = $P{objid}	


[updateFaasList]
update flx set 
	flx.realpropertyid = f.realpropertyid,
	flx.state = f.state,
	flx.datacapture = f.datacapture,
	flx.tdno = f.tdno,
	flx.utdno = f.utdno,
	flx.displaypin = f.fullpin,
	flx.pin = case when r.rputype = 'land' then rp.pin else rp.pin + '-' + convert(varchar(4),r.suffix) end,
	flx.prevtdno = f.prevtdno,
	flx.taxpayer_objid = f.taxpayer_objid,
	flx.owner_name = f.owner_name,
	flx.owner_address = f.owner_address,
	flx.administrator_name = f.administrator_name,
	flx.administrator_address = f.administrator_address,
	flx.classification_objid = r.classification_objid,
	flx.classcode = pc.code,
	flx.cadastrallotno = rp.cadastrallotno,
	flx.blockno = rp.blockno,
	flx.surveyno = rp.surveyno,
	flx.titleno = f.titleno,
	flx.totalareaha = r.totalareaha,
	flx.totalareasqm = r.totalareasqm,
	flx.totalmv = r.totalmv,
	flx.totalav = r.totalav,
	flx.effectivityyear = f.effectivityyear,
	flx.effectivityqtr = f.effectivityqtr,
	flx.cancelreason = f.cancelreason,
	flx.cancelledbytdnos = f.cancelledbytdnos,
	flx.yearissued = f.year,
	flx.taskid = (select top 1 objid from faas_task where refid = f.objid and enddate is null),
	flx.taskstate = (select top 1 state from faas_task where refid = f.objid and enddate is null),
	flx.assignee_objid = (select top 1 assignee_objid from faas_task where refid = f.objid and enddate is null) 
from faas_list flx 
	inner join faas f on flx.objid = f.objid 
	inner join rpu r on flx.rpuid = r.objid 
	inner join realproperty rp on flx.realpropertyid = rp.objid 
	left join propertyclassification pc on r.classification_objid = pc.objid 
where flx.objid = $P{objid}     



[deleteFaasList]
delete from faas_list where objid = $P{objid}


[findById]
select * from faas_list where objid  = $P{objid}


[updateTaskId]
update faas_list set taskid = $P{objid} where objid = $P{refid}
