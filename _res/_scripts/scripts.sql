/*================================================
*
* GIS VIEW 
*
================================================*/
if exists(select * from sysobjects where id = object_id('ZC_GISView_Land'))
begin 
	drop view ZC_GISView_Land
end
go 

create view ZC_GISView_Land
as 
select 
	fl.objid,
	fl.ry as Series,
	fl.tdno as aTDN,
	fl.pin as PIN,
	fl.owner_name as ARPOwnerName,
	b.objid as BrgyId,
	b.indexno as BrgyNo,
	b.pin as BrgyPIN,
	b.name as BrgyName,
	fl.titleno as TCTNo,
	fl.cadastrallotno as LotNo,
	fl.blockno as BlockNo,
	'LAND' as PKindDesc,
	lspc.name as ActualUse,
	case 
		when ld.areatype = 'HA' then ld.areaha
		else ld.areasqm
	end as Area, 
	ld.areaha as AreaHa,
	ld.areasqm as AreaSqm,
	ld.marketvalue as MarketValue,
	ld.assessedvalue as AssessedValue
from faas_list fl 
inner join propertyclassification pc on fl.classification_objid = pc.objid 
inner join barangay b on fl.barangayid = b.objid 
inner join landdetail ld on fl.rpuid = ld.landrpuid 
inner join landspecificclass lspc on ld.landspecificclass_objid = lspc.objid 
go 





