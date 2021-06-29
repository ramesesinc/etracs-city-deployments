[findRealPropertyById]
select objid from realproperty where objid = $P{objid}

[findRpuById]
select objid from rpu where objid = $P{objid}

[findFaasById]
select objid from faas where objid = $P{objid}


[findLandRpuById]
select objid from landrpu where objid = $P{objid}

[findLandDetailById]
select objid from landdetail where objid = $P{objid}

[findLandAdjustmentById]
select objid from landadjustment where objid = $P{objid}

[findPlantTreeDetailById]
select objid from planttreedetail where objid = $P{objid}

[findRpuAssessmentById]
select objid from rpu_assessment where objid = $P{objid}

[findSignatoryById]
select objid from faas_task where objid = $P{objid}



[findBldgRpuById]
select objid from bldgrpu where objid = $P{objid}

[findBldgStructureById]
select objid from bldgstructure where objid = $P{objid}

[findBldgStructuralTypeById]
select objid from bldgrpu_structuraltype where objid = $P{objid}

[findBldgUseById]
select objid from bldguse where objid = $P{objid}

[findFloorById]
select objid from bldgfloor where objid = $P{objid}

[findBldgAdditionalItemById]
select objid from bldgflooradditional where objid = $P{objid}

[findBldgAdditionalItemParamById]
select objid from bldgflooradditionalparam where objid = $P{objid}

[findLandFaasById]
select objid, rpuid, realpropertyid  
from faas 
where objid = $P{objid}


[findMachRpuById]
select objid from machrpu where objid = $P{objid}

[findMachUseById]
select objid from machuse where objid = $P{objid}

[findMachDetailById]
select objid from machdetail where objid = $P{objid}


[getLandRpuAssessments]
select distinct 
	min(ld.objid) as objid, 
	ld.landrpuid as rpuid, 
	lal.classification_objid, 
	ld.actualuse_objid, 
	sum(ld.areasqm) as areasqm, 
	sum(ld.areaha) as areaha, 
	sum(ld.marketvalue) as marketvalue, 
	ld.assesslevel, 
	sum(ld.assessedvalue) as assessedvalue, 
	'land' as rputype
from landdetail ld 	
	inner join landassesslevel lal on ld.actualuse_objid = lal.objid 
where ld.landrpuid = $P{objid}	 
group by 
	ld.landrpuid, 
	lal.classification_objid, 
	ld.actualuse_objid,
	ld.assesslevel

[getPlantTreeDetailAssessments]
select distinct 
	min(ld.objid) as objid, 
	ld.landrpuid as rpuid, 
	lal.classification_objid, 
	ld.actualuse_objid, 
	sum(0) as areasqm, 
	sum(0) as areaha, 
	sum(ld.marketvalue) as marketvalue, 
	ld.assesslevel, 
	sum(ld.assessedvalue) as assessedvalue, 
	'planttree' as rputype
from planttreedetail ld 	
	inner join planttreeassesslevel lal on ld.actualuse_objid = lal.objid 
where ld.landrpuid = $P{objid}	 
group by 
	ld.landrpuid, 
	lal.classification_objid, 
	ld.actualuse_objid,
	ld.assesslevel


[insertLandRpuAssessment]
INSERT INTO rpu_assessment (objid, rpuid, classification_objid, actualuse_objid, areasqm, areaha, marketvalue, assesslevel, assessedvalue, rputype) 
values($P{objid}, $P{rpuid}, $P{classification_objid}, $P{actualuse_objid}, $P{areasqm}, $P{areaha}, $P{marketvalue}, $P{assesslevel}, $P{assessedvalue}, $P{rputype})



[insertFaasSignatory]	
insert into faas_task (objid, refid, state, startdate, enddate, assignee_name, assignee_title, actor_name, actor_title)
values($P{objid}, $P{refid}, $P{state}, $P{startdate}, $P{enddate}, $P{assignee_name}, $P{assignee_title}, $P{actor_name}, $P{actor_title})


[findPropertyClassificationByCode]
select objid from propertyclassification where code = $P{code}


[insertBldgRpuAssessment]
INSERT INTO rpu_assessment (objid, rpuid, classification_objid, actualuse_objid, areasqm, areaha, marketvalue, assesslevel, assessedvalue, rputype) 
select
	min(bu.objid) as objid, 
	bu.bldgrpuid as rpuid, 
	au.classification_objid, 
	bu.actualuse_objid as actualuse_objid, 
	sum(bu.area) as areasqm, 
	sum(bu.area / 10000) as areaha, 
	sum(bu.marketvalue) as marketvalue, 
	bu.assesslevel,
	sum(bu.assessedvalue) as assessedvalue, 
	'bldg' as rputype
from bldgrpu r
	inner join bldguse bu on r.objid  = bu.bldgrpuid
	inner join bldgassesslevel au on bu.actualuse_objid = au.objid 
where r.objid = $P{objid}
group by 
	bu.bldgrpuid,
	au.classification_objid, 
	bu.actualuse_objid,
	bu.assesslevel


[findRptParameterById]
select * from rptparameter where objid = $P{objid}

[updateBldgRpuFloorCount]
update bldgrpu set 
	floorcount = (select max(floorcount) from bldgrpu_structuraltype where bldgrpuid = $P{objid})
where objid = $P{objid}

[updateStructuralTypeBaseArea]
update bldgrpu_structuraltype set 
	basefloorarea = isnull((select sum(area) from bldgfloor where  bldgrpuid = $P{objid} and floorno = 1),0)
where bldgrpuid = $P{objid}	


[insertMachRpuAssessment]
INSERT INTO rpu_assessment (objid, rpuid, classification_objid, actualuse_objid, areasqm, areaha, marketvalue, assesslevel, assessedvalue, rputype) 
select
	min(bu.objid) as objid, 
	bu.machrpuid as rpuid, 
	au.classification_objid, 
	bu.actualuse_objid as actualuse_objid, 
	0 as areasqm, 
	0 as areaha, 
	sum(bu.marketvalue) as marketvalue, 
	bu.assesslevel,
	sum(bu.assessedvalue) as assessedvalue, 
	'mach' as rputype
from machrpu r
	inner join machuse bu on r.objid  = bu.machrpuid
	inner join machassesslevel au on bu.actualuse_objid = au.objid 
where r.objid = $P{objid}
group by 
	bu.machrpuid,
	au.classification_objid, 
	bu.actualuse_objid,
	bu.assesslevel



[insertPreviousFaas]
insert into previousfaas (faasid, prevfaasid)
values($P{faasid}, $P{prevfaasid})

[findPreviousFaas]
select * from previousfaas where faasid = $P{faasid} and prevfaasid = $P{prevfaasid}