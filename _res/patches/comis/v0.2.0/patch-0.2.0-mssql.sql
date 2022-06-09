alter table lgu add name nvarchar(50)
go

alter table lgu add islocal int default 0
go 

update lgu set 
	name = objid,
	islocal = case when name like '%LIGAO%' then 1 else 0 end 
go


alter table cemetery add isoutsidelgu int default 0
go
alter table cemetery add lgu_objid varchar(50)
go
update cemetery set lgu_objid = (select objid from lgu where islocal = 1) where lgu_objid is null
go 



exec sp_rename 'dbo.deceased.lgu', 'lgu_objid', 'COLUMN'
go 
exec sp_rename 'dbo.deceased.placeofdeath', 'placeofdeath_objid', 'COLUMN'
go 
exec sp_rename 'dbo.deceased.placeofburial', 'placeofburial_objid', 'COLUMN'
go 

drop index deceased.ix_lgu
go 
drop index deceased.ix_placeofdeath
go 
drop index deceased.ix_placeofdburial
go 

alter table deceased alter column lgu_objid nvarchar(50)
go 
alter table deceased alter column placeofdeath_objid nvarchar(50)
go 
alter table deceased alter column placeofburial_objid nvarchar(50)
go 

create index ix_lgu on deceased(lgu_objid)
go 
create index ix_placeofdeath on deceased(placeofdeath_objid)
go 
create index ix_placeofdburial on deceased(placeofburial_objid)
go 


alter table deceased 
	add constraint fk_deceased_placeofdeath foreign key (placeofdeath_objid)
	references lgu (objid)
go 


alter table deceased 
	add constraint fk_deceased_placeofburial foreign key (placeofburial_objid)
	references lgu (objid)
go 



alter table deceased add cemetery_name nvarchar(100)
go 

alter table deceased add cemetery_address nvarchar(100)
go 




/* ALLOWMULTIPLE SUPPORT */

alter table resource add allowmultiple int default 0
go 

update resource set allowmultiple = case when name = 'OSSUARY' then 1 else 0 end 
go 


if exists(select * from sysobjects where id = object_id('vw_cemetery_resource'))
begin 
	DROP VIEW vw_cemetery_resource 
end
go

CREATE VIEW vw_cemetery_resource 
AS 
select 
  sri.objid AS objid,
  sri.parentid AS parentid,
  sr.parentid AS blockid,
  sr.code AS code,
  sr.name AS name,
  sr.currentinfoid AS currentinfoid,
  sr.currentappid AS currentappid,
  sri.state AS state,
  sri.areasqm AS areasqm,
  sri.resource_objid AS resource_objid,
  sri.ui AS ui,
  r.name AS resource_name,
  r.allowmultiple as resource_allowmultiple,
  b.objid AS block_objid,
  b.code AS block_code,
  b.name AS block_name,
  s.objid AS section_objid,
  s.code AS section_code,
  s.name AS section_name,
  a.appno AS appno,
  a.apptype AS apptype,
  a.applicant_name AS applicant_name,
  a.applicant_address AS applicant_address,
  d.name AS deceased_name,
  d.nationality AS deceased_nationality,
  d.sex AS deceased_sex,
  d.age AS deceased_age,
  cd.title AS deceased_causeofdeath,
  c.objid AS cemetery_objid,
  c.code AS cemetery_code,
  c.name AS cemetery_name,
  c.location AS cemetery_location,
  c.isnew AS cemetery_isnew 
from  cemetery_section_block_resource sr 
join cemetery_section_block_resource_info sri on sr.currentinfoid = sri.objid  
join resource r on sri.resource_objid = r.objid  
join cemetery_section_block b on sr.parentid = b.objid  
join cemetery_section s on b.parentid = s.objid  
join cemetery c on s.parentid = c.objid  left 
join application a on sr.currentappid = a.objid  left 
join deceased d on a.deceased_objid = d.objid  left 
join causeofdeath cd on d.causeofdeath_objid = cd.objid 
go 

