/* vw_cemetery_resource: add length and width */

if exists(select * from sysobjects where id = object_id('vw_cemetery_resource'))
begin 
  drop view vw_cemetery_resource 
end 
go

create view vw_cemetery_resource 
as 
select 
  sri.objid as objid,
  sri.parentid as parentid,
  sr.parentid as blockid,
  sr.code as code,
  sr.name as name,
  sr.currentinfoid as currentinfoid,
  sr.currentappid as currentappid,
  sri.state as state,
  sri.areasqm as areasqm,
  sri.resource_objid as resource_objid,
  sri.ui as ui,
	sri.length,
	sri.width,
  r.name as resource_name,
  r.allowmultiple as resource_allowmultiple,
  b.objid as block_objid,
  b.code as block_code,
  b.name as block_name,
  s.objid as section_objid,
  s.code as section_code,
  s.name as section_name,
  a.appno as appno,
  a.apptype as apptype,
  a.applicant_name as applicant_name,
  a.applicant_address as applicant_address,
  d.name as deceased_name,
  d.nationality as deceased_nationality,
  d.sex as deceased_sex,
  d.age as deceased_age,
  cd.title as deceased_causeofdeath,
  c.objid as cemetery_objid,
  c.code as cemetery_code,
  c.name as cemetery_name,
  c.location as cemetery_location,
  c.isnew as cemetery_isnew 
from  cemetery_section_block_resource sr 
join cemetery_section_block_resource_info sri on sr.currentinfoid = sri.objid 
join resource r on sri.resource_objid = r.objid 
join cemetery_section_block b on sr.parentid = b.objid 
join cemetery_section s on b.parentid = s.objid 
join cemetery c on s.parentid = c.objid
left join application a on sr.currentappid = a.objid
left join deceased d on a.deceased_objid = d.objid
left join causeofdeath cd on d.causeofdeath_objid = cd.objid
go

