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
alter table cemetery add lgu_objid nvarchar(50)
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


INSERT INTO sys_var (name, value, description, datatype, category) VALUES ('COMIS_LESSOR_CTC_DTISSUED', '<<DATE ISSUED>>', NULL, NULL, 'COMIS')
go
INSERT INTO sys_var (name, value, description, datatype, category) VALUES ('COMIS_LESSOR_CTC_NO', '<<CTCNO>>', NULL, NULL, 'COMIS')
go 


/* INTERMENT ORDER */

CREATE TABLE intermentorder (
  objid nvarchar(50) NOT NULL,
  state nvarchar(25) NOT NULL,
  appid nvarchar(50) NOT NULL,
  orderno nvarchar(25) NOT NULL,
  orderdate datetime NOT NULL,
  intermentdate date NULL,
  intermenttime nvarchar(10) NULL,
  timehour int,
  timemin int,
  timeperiod nvarchar(2),
  regofficer_name nvarchar(150) NULL,
  regofficer_title nvarchar(50) NULL,
  undertaker_name nvarchar(150) NULL,
  undertaker_title nvarchar(50) NULL,
  taskid nvarchar(50),
  PRIMARY KEY (objid)
) 
go 

create unique index ux_appid on intermentorder (appid)
go 
create index ix_taskid on intermentorder (taskid)
go 
create index ix_state on intermentorder (state)
go 
create index ix_orderno on intermentorder (orderno)
go 

alter table intermentorder 
  add CONSTRAINT fk_intermentorder_application FOREIGN KEY (appid) REFERENCES application (objid)
go 

CREATE TABLE intermentorder_task (
  taskid nvarchar(50) NOT NULL,
  refid nvarchar(50) DEFAULT NULL,
  parentprocessid nvarchar(50) DEFAULT NULL,
  state nvarchar(50) DEFAULT NULL,
  startdate datetime DEFAULT NULL,
  enddate datetime DEFAULT NULL,
  assignee_objid nvarchar(50) DEFAULT NULL,
  assignee_name nvarchar(100) DEFAULT NULL,
  assignee_title nvarchar(80) DEFAULT NULL,
  actor_objid nvarchar(50) DEFAULT NULL,
  actor_name nvarchar(100) DEFAULT NULL,
  actor_title nvarchar(80) DEFAULT NULL,
  message nvarchar(255) DEFAULT NULL,
  signature text,
  returnedby nvarchar(100) DEFAULT NULL,
  dtcreated datetime DEFAULT NULL,
  prevtaskid nvarchar(100) DEFAULT NULL,
  PRIMARY KEY (taskid)
) 
go

create index ix_assignee_objid on intermentorder_task (assignee_objid)
go
create index ix_refid on intermentorder_task (refid)
go
alter table intermentorder_task add CONSTRAINT fk_intermentordertask_intermentorder 
  FOREIGN KEY (refid) REFERENCES intermentorder (objid)
go 

if exists(select * from sysobjects where id = object_id('vw_intermentorder') )
begin 
  drop view vw_intermentorder 
end 
go 

create view vw_intermentorder 
as 
select 
	o.*,
	a.appno,
	a.dtapplied,
	a.dtapproved,
	a.applicant_objid,
	a.applicant_name,
	a.applicant_address,
	a.deceased_objid,
	d.name as deceased_name,
	t.taskid as task_objid,
	t.state as task_state,
	t.enddate as task_enddate,
	t.assignee_objid as task_assignee_objid,
	t.actor_objid as task_actor_objid,
	t.prevtaskid as task_prevtaskid
from intermentorder o 
inner join application a on o.appid = a.objid 
inner join intermentorder_task t on o.objid = t.refid 
inner join deceased d on a.deceased_objid = d.objid 
go


insert into sys_var (name, value, category)
values('COMIS_REGISTRATION_OFFICER_NAME', '<COMIS_REGISTRATION_OFFICER_NAME>', 'COMIS')
go 
insert into sys_var (name, value, category)
values('COMIS_REGISTRATION_OFFICER_TITLE', '<COMIS_REGISTRATION_OFFICER_TITLE>', 'COMIS')
go 

insert into sys_var (name, value, category)
values('COMIS_UNDERTAKER_NAME', '<COMIS_UNDERTAKER_NAME>', 'COMIS')
go 
insert into sys_var (name, value, category)
values('COMIS_UNDERTAKER_TITLE', '<COMIS_UNDERTAKER_TITLE>', 'COMIS')
go 




/* vw_application: add relation */
if exists(select * from sysobjects where id = object_id('vw_application'))
begin
  drop view vw_application 
end
go

create view vw_application 
as 
select 
  a.objid as objid,
  a.state as state,
  a.online as online,
  a.apptype as apptype,
  a.appno as appno,
  a.dtapplied as dtapplied,
  a.dtapproved as dtapproved,
  a.appyear as appyear,
  a.applicant_name as applicant_name,
  a.applicant_address as applicant_address,
	rel.title as applicant_relation,
  a.dtexpiry as dtexpiry,
  a.amount as amount,
  a.amtpaid as amtpaid,
  a.renewable as renewable,
  d.name as deceased_name,
  d.nationality as deceased_nationality,
  d.age as deceased_age,
  d.agetype as deceased_agetype,
  d.sex as deceased_sex,
  d.dtdied as deceased_dtdied,
  d.permissiontype as deceased_permissiontype,
  cd.title as deceased_causeofdeath,
  sbri.objid as resourceinfo_objid,
  sbri.code as resourceinfo_code,
  sbri.name as resourceinfo_name,
  sbri.areasqm as resource_areasqm,
  sbri.length as resource_length,
  sbri.width as resource_width,
  sb.objid as block_objid,
  sb.code as block_code,
  sb.name as block_name,
  r.objid as resource_objid,
  r.name as resource_type,
  s.objid as section_objid,
  s.code as section_code,
  s.name as section_name,
  c.objid as cemetery_objid,
  c.code as cemetery_code,
  c.name as cemetery_name,
  t.taskid as task_objid,
  t.state as task_state,
  t.enddate as task_enddate,
  t.assignee_objid as task_assignee_objid,
  t.actor_objid as task_actor_objid,
  t.prevtaskid as task_prevtaskid 
  from  application a 
  left join cemetery_section_block_resource_info sbri on a.resourceinfo_objid = sbri.objid  
  left join cemetery_section_block_resource sbr on sbri.parentid = sbr.objid  
  left join cemetery_section_block sb on sbr.parentid = sb.objid  
  left join cemetery_section s on sb.parentid = s.objid  
  left join cemetery c on s.parentid = c.objid  
  left join resource r on sbri.resource_objid = r.objid  
  left join deceased d on a.deceased_objid = d.objid  
  left join causeofdeath cd on d.causeofdeath_objid = cd.objid  
  left join application_task t on a.taskid = t.taskid 
	left join relation rel on a.relation_objid = rel.objid 
go




/* permit */
alter table application drop constraint FK__applicati__permi__4B7734FF
go

drop index application.fk_application_permit
go 

alter table application drop column permitid 
go

if exists(select * from sysobjects where id = object_id('permit'))
begin 
  drop table permit
end 
go

create table permit (
  objid nvarchar(50) not null,
  appid nvarchar(50) not null,
  paymentid nvarchar(50) default null,
  permitno nvarchar(25) default null,
  permitdate date default null,
  permittype nvarchar(25) default null,
  mayor_name nvarchar(255) default null,
  mayor_title nvarchar(50) default null,
  ordinanceno nvarchar(20) default null,
  ordinancedate date default null,
  primary key (objid)
) 
go

create unique index ux_permitno on permit (permitno)
go
create index fk_permit_application on permit (appid)
go
create index fk_permit_payment on permit (paymentid)
go
alter table permit add constraint permit_ibfk_1 foreign key (appid) references application (objid)
go 
alter table permit add constraint permit_ibfk_2 foreign key (paymentid) references payment (objid)
go 


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



INSERT INTO sys_var (name, value, description, datatype, category) VALUES ('COMIS_ORDINANCE_DATE', NULL, NULL, NULL, 'COMIS')
go
INSERT INTO sys_var (name, value, description, datatype, category) VALUES ('COMIS_ORDINANCE_NO', '<ORDINANCE_NO>', NULL, NULL, 'COMIS')
go


/* REGISTRATION INFORMATION */
alter table deceased add registryno int
go 
alter table deceased add pageno int
go
alter table deceased add bookno int
go 

create index ix_registryno on deceased(registryno, bookno, pageno)
go 


update sys_wf_transition set caption = 'For Payment' 
where processname = 'application' and parentid = 'for-payment'
go 



update sys_wf_transition set 
	properties = '[visibleWhen:"#{false}"]'
where processname = 'application' and parentid in('active', 'expired', 'renewed') and action = 'closed'
go

update sys_wf_transition set 
	properties = '[visibleWhen:"#{false}"]'
where processname = 'application' and parentid in('for-payment') and action = 'post-payment'
go

update sys_wf_transition set 
	properties = '[visibleWhen:"#{false}"]'
where processname = 'application' and parentid in('releaser') and action = 'void-payment'
go

update sys_wf_transition set 
	properties = '[visibleWhen:"#{false}"]'
where processname = 'application' and parentid in('active') and action = 'expired'
go

update sys_wf_transition set 
	properties = '[visibleWhen:"#{false}"]'
where processname = 'application' and parentid in('expired') and action = 'renewed'
go

update sys_wf_node set title = 'For Payment' where processname='application' and name ='for-payment' 
go

update sys_wf_node set title = 'For Release' where processname='application' and name ='releaser'
go

CREATE TABLE txnlog (
  objid varchar(50) NOT NULL,
  ref varchar(100) NOT NULL,
  refid varchar(255) NOT NULL,
  txndate datetime NOT NULL,
  action varchar(50) NOT NULL,
  userid varchar(50) NOT NULL,
  remarks text,
  info text,
  username varchar(150) DEFAULT NULL,
  PRIMARY KEY (objid)
)
go

create index ix_txndate on txnlog (txndate)
go 
create index ix_txnlog_ref on txnlog (ref)
go 
create index ix_txnlog_userid on txnlog (userid)
go 
create index ix_refid on txnlog (refid)
go 




/* CERTIFICATION */
CREATE TABLE certification (
  objid varchar(50) NOT NULL,
  state varchar(25) NOT NULL,
  txnno varchar(25) NOT NULL,
  txndate datetime NOT NULL,
  requestedby_name varchar(255) NOT NULL,
  requestedby_address varchar(255) NOT NULL,
  purpose varchar(255) NOT NULL,
  refid varchar(50) NOT NULL,
  reftype varchar(255) NOT NULL,
  handler varchar(25) NOT NULL,
  receipt_objid varchar(50) DEFAULT NULL,
  receipt_no varchar(15) DEFAULT NULL,
  receipt_date date DEFAULT NULL,
  receipt_amount decimal(16,2) DEFAULT NULL,
  report_name varchar(50) NOT NULL,
  taskid varchar(50) DEFAULT NULL,
  PRIMARY KEY (objid)
) 
go 

create UNIQUE index ix_txnno on certification (txnno)
go 
create index ix_state on certification (state)
go
create index ix_requestedby on certification (requestedby_name)
go
create index ix_refid on certification (refid)
go
create index ix_receiptid on certification (receipt_objid)
go
create index ix_receiptno on certification (receipt_no)
go
create index ix_taskid on certification (taskid)
go


if exists(select * from sysobjects where id = object_id('certification_task'))
begin 
	DROP TABLE certification_task 
end
go

CREATE TABLE certification_task (
  taskid varchar(50) NOT NULL,
  refid varchar(50) DEFAULT NULL,
  parentprocessid varchar(50) DEFAULT NULL,
  state varchar(50) DEFAULT NULL,
  startdate datetime2 DEFAULT NULL,
  enddate datetime2 DEFAULT NULL,
  assignee_objid varchar(50) DEFAULT NULL,
  assignee_name varchar(100) DEFAULT NULL,
  assignee_title varchar(80) DEFAULT NULL,
  actor_objid varchar(50) DEFAULT NULL,
  actor_name varchar(100) DEFAULT NULL,
  actor_title varchar(80) DEFAULT NULL,
  message varchar(255) DEFAULT NULL,
  signature text,
  returnedby varchar(100) DEFAULT NULL,
  dtcreated datetime DEFAULT NULL,
  prevtaskid varchar(100) DEFAULT NULL,
  PRIMARY KEY (taskid)
)
go 

create index ix_assignee_objid on certification_task (assignee_objid)
go
create index ix_refid on certification_task (refid)
go
alter  table certification_task 
add CONSTRAINT fk_certification_task_certification 
FOREIGN KEY (refid) REFERENCES certification (objid)
go 



insert into sys_role (name, title, system)
values('CERTIFICATION_VERIFIER', 'CERTIFICATION VERIFIER', 1)
go

insert into sys_role (name, title, system)
values('CERTIFICATION_APPROVER', 'CERTIFICATION APPROVER', 1)
go

insert into sys_role (name, title, system)
values('CERTIFICATION_RELEASER', 'CERTIFICATION RELEASER', 1)
go



delete from sys_wf_transition where processname ='certification'
go
delete from sys_wf_node where processname ='certification';
go
delete from sys_wf where name ='certification';
go


INSERT INTO sys_wf (name, title, domain) VALUES ('certification', 'Certification', 'COMIS')
go
INSERT INTO sys_wf_node (name, processname, title, nodetype, idx, salience, domain, [role], ui, properties, tracktime) VALUES ('start', 'certification', 'Start', 'start', '1', NULL, NULL, NULL, '[type:''start'',fillColor:''#00ff00'',pos:[81,110],size:[32,32]]', '[:]', NULL)
go
INSERT INTO sys_wf_node (name, processname, title, nodetype, idx, salience, domain, [role], ui, properties, tracktime) VALUES ('verification', 'certification', 'Verification', 'state', '2', NULL, 'COMIS', 'CERTIFICATION_VERIFIER', '[type:''state'',fillColor:''#c0c0c0'',pos:[200,112],size:[100,43]]', '[:]', '1')
go
INSERT INTO sys_wf_node (name, processname, title, nodetype, idx, salience, domain, [role], ui, properties, tracktime) VALUES ('approval', 'certification', 'For Approval', 'state', '3', NULL, 'COMIS', 'CERTIFICATION_APPROVER', '[type:''state'',fillColor:''#c0c0c0'',pos:[372,108],size:[124,45]]', '[:]', '1')
go
INSERT INTO sys_wf_node (name, processname, title, nodetype, idx, salience, domain, [role], ui, properties, tracktime) VALUES ('for-release', 'certification', 'For Release', 'state', '4', NULL, 'COMIS', 'CERTIFICATION_RELEASER', '[type:''state'',fillColor:''#c0c0c0'',pos:[563,111],size:[147,49]]', '[:]', '1')
go
INSERT INTO sys_wf_node (name, processname, title, nodetype, idx, salience, domain, [role], ui, properties, tracktime) VALUES ('end', 'certification', 'Released', 'end', '5', NULL, NULL, NULL, '[type:''end'',fillColor:''#ff0000'',pos:[790,114],size:[32,32]]', '[:]', NULL)
go

INSERT INTO sys_wf_transition (parentid, processname, [action], [to], [idx], eval, properties, permission, caption, ui) VALUES ('start', 'certification', 'init', 'verification', '1', NULL, '[:]', NULL, 'Init', '[points:[113,126,200,130],type:''arrow'',pos:[113,126],size:[87,4]]')
go
INSERT INTO sys_wf_transition (parentid, processname, [action], [to], [idx], eval, properties, permission, caption, ui) VALUES ('verification', 'certification', 'submit', 'approval', '2', NULL, '[showConfirm:true,confirmMessage:''Submit for approval?'']', NULL, 'Submit', '[points:[300,131,372,130],type:''arrow'',pos:[300,130],size:[72,1]]')
go
INSERT INTO sys_wf_transition (parentid, processname, [action], [to], [idx], eval, properties, permission, caption, ui) VALUES ('approval', 'certification', 'approve', 'for-release', '3', NULL, '[showConfirm:true,confirmMessage:''Approve certification?'']', NULL, 'Approve', '[points:[496,131,563,133],type:''arrow'',pos:[496,131],size:[67,2]]')
go
INSERT INTO sys_wf_transition (parentid, processname, [action], [to], [idx], eval, properties, permission, caption, ui) VALUES ('for-release', 'certification', 'release', 'end', '4', NULL, '[showConfirm:true,confirmMessage:''Release certification?'']', NULL, 'Release', '[points:[710,133,790,131],type:''arrow'',pos:[710,131],size:[80,2]]')
go



if exists(select * from sysobjects where id = object_id('vw_certification'))
begin 
	DROP VIEW vw_certification 
end
go

create view vw_certification 
as 
select 
	c.*, 
	t.taskid as task_objid,
	t.state as task_state,
	t.enddate as task_enddate,
	t.assignee_objid as task_assignee_objid,
	t.actor_objid as task_actor_objid,
	t.prevtaskid as task_prevtaskid
from certification c 
inner join certification_task t on c.taskid = t.taskid
go 



CREATE TABLE civilstatus (
  objid nvarchar(50) NOT NULL,
  PRIMARY KEY (objid)
) 
go

INSERT INTO civilstatus (objid) VALUES ('SINGLE')
go
INSERT INTO civilstatus (objid) VALUES ('MARRIED')
go
INSERT INTO civilstatus (objid) VALUES ('WIDOWED')
go
INSERT INTO civilstatus (objid) VALUES ('DIVORCED')
go
INSERT INTO civilstatus (objid) VALUES ('ANNULLED')
go


alter table deceased add civilstatus nvarchar(50)
go


alter table deceased add dtregistered date
go 



alter table certification add deceased_name varchar(255)
go

create index ix_deceased_name on certification(deceased_name)
go

alter table deceased 
	add constraint fk_deceased_civilstatus foreign key(civilstatus)
	references civilstatus(objid)
go 