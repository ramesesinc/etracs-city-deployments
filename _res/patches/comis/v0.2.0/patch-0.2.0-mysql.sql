alter table lgu add name varchar(50)
;

alter table lgu add islocal int default 0
;

update lgu set 
	name = objid,
	islocal = case when name like '%LIGAO%' then 1 else 0 end 
;

alter table cemetery add isoutsidelgu int default 0
;
alter table cemetery add lgu_objid varchar(50)
;
update cemetery c, lgu l set 
  c.lgu_objid = l.objid 
where l.islocal = 1
;



alter table deceased change column lgu lgu_objid varchar(50)
;
alter table deceased change column placeofdeath placeofdeath_objid varchar(50)
;
alter table deceased change column placeofburial placeofburial_objid varchar(50)
;

create index ix_lgu on deceased(lgu_objid)
;
create index ix_placeofdeath on deceased(placeofdeath_objid)
;
create index ix_placeofdburial on deceased(placeofburial_objid)
;


alter table deceased 
	add constraint fk_deceased_placeofdeath foreign key (placeofdeath_objid)
	references lgu (objid)
;


alter table deceased 
	add constraint fk_deceased_placeofburial foreign key (placeofburial_objid)
	references lgu (objid)
;



alter table deceased add cemetery_name nvarchar(100)
;

alter table deceased add cemetery_address nvarchar(100)
;




/* ALLOWMULTIPLE SUPPORT */

alter table resource add allowmultiple int default 0
;

update resource set allowmultiple = case when name = 'OSSUARY' then 1 else 0 end 
;


DROP VIEW IF EXISTS vw_cemetery_resource 
;

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
;

