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


INSERT INTO sys_var (name, value, description, datatype, category) VALUES ('COMIS_LESSOR_CTC_DTISSUED', '<<DATE ISSUED>>', NULL, NULL, 'COMIS');
INSERT INTO sys_var (name, value, description, datatype, category) VALUES ('COMIS_LESSOR_CTC_NO', '<<CTCNO>>', NULL, NULL, 'COMIS');


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



/* INTERMENT ORDER */
CREATE TABLE `intermentorder` (
  `objid` varchar(50) NOT NULL,
  `state` varchar(25) NOT NULL,
  `appid` varchar(50) NOT NULL,
  `orderno` varchar(25) NOT NULL,
  `orderdate` datetime NOT NULL,
  `intermentdate` date NULL,
  `intermenttime` varchar(10) NULL,
  `timehour` int NULL,
  `timemin` int NULL,
  `timeperiod` varchar(2) NULL,
  `regofficer_name` varchar(150) NULL,
  `regofficer_title` varchar(50) NULL,
  `undertaker_name` varchar(150) NULL,
  `undertaker_title` varchar(50) NULL,
  `taskid` varchar(50),
  PRIMARY KEY (`objid`),
  UNIQUE KEY `ux_appid` (`appid`),
  KEY `ix_state` (`state`),
  KEY `ix_taskid` (`taskid`),
  KEY `ix_orderno` (`orderno`),
  CONSTRAINT `fk_intermentorder_application` FOREIGN KEY (`appid`) REFERENCES `application` (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

CREATE TABLE `intermentorder_task` (
  `taskid` varchar(50) NOT NULL,
  `refid` varchar(50) DEFAULT NULL,
  `parentprocessid` varchar(50) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `startdate` datetime DEFAULT NULL,
  `enddate` datetime DEFAULT NULL,
  `assignee_objid` varchar(50) DEFAULT NULL,
  `assignee_name` varchar(100) DEFAULT NULL,
  `assignee_title` varchar(80) DEFAULT NULL,
  `actor_objid` varchar(50) DEFAULT NULL,
  `actor_name` varchar(100) DEFAULT NULL,
  `actor_title` varchar(80) DEFAULT NULL,
  `message` varchar(255) DEFAULT NULL,
  `signature` longtext,
  `returnedby` varchar(100) DEFAULT NULL,
  `dtcreated` datetime DEFAULT NULL,
  `prevtaskid` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`taskid`),
  KEY `ix_assignee_objid` (`assignee_objid`),
  KEY `ix_refid` (`refid`),
  CONSTRAINT `fk_intermentordertask_intermentorder` FOREIGN KEY (`refid`) REFERENCES `intermentorder` (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

drop view if exists vw_intermentorder 
;

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
	d.`name` as deceased_name,
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
;



insert into sys_var (name, value, category)
values('COMIS_REGISTRATION_OFFICER_NAME', '<COMIS_REGISTRATION_OFFICER_NAME>', 'COMIS')
;
insert into sys_var (name, value, category)
values('COMIS_REGISTRATION_OFFICER_TITLE', '<COMIS_REGISTRATION_OFFICER_TITLE>', 'COMIS')
;
insert into sys_var (name, value, category)
values('COMIS_UNDERTAKER_NAME', '<COMIS_UNDERTAKER_NAME>', 'COMIS')
;
insert into sys_var (name, value, category)
values('COMIS_UNDERTAKER_TITLE', '<COMIS_UNDERTAKER_TITLE>', 'COMIS')
;


/* vw_application: add relation */
DROP VIEW IF EXISTS `vw_application` 
;

CREATE VIEW `vw_application` 
AS 
select 
  `a`.`objid` AS `objid`,
  `a`.`state` AS `state`,
  `a`.`online` AS `online`,
  `a`.`apptype` AS `apptype`,
  `a`.`appno` AS `appno`,
  `a`.`dtapplied` AS `dtapplied`,
  `a`.`dtapproved` AS `dtapproved`,
  `a`.`appyear` AS `appyear`,
  `a`.`applicant_name` AS `applicant_name`,
  `a`.`applicant_address` AS `applicant_address`,
	rel.title as applicant_relation,
  `a`.`dtexpiry` AS `dtexpiry`,
  `a`.`amount` AS `amount`,
  `a`.`amtpaid` AS `amtpaid`,
  `a`.`renewable` AS `renewable`,
  `d`.`name` AS `deceased_name`,
	`d`.`nationality` AS `deceased_nationality`,
  `d`.`age` AS `deceased_age`,
  `d`.`agetype` AS `deceased_agetype`,
  `d`.`sex` AS `deceased_sex`,
  `d`.`dtdied` AS `deceased_dtdied`,
  `d`.`permissiontype` AS `deceased_permissiontype`,
  `cd`.`title` AS `deceased_causeofdeath`,
  `sbri`.`objid` AS `resourceinfo_objid`,
  `sbri`.`code` AS `resourceinfo_code`,
  `sbri`.`name` AS `resourceinfo_name`,
  `sbri`.`areasqm` AS `resource_areasqm`,
  `sbri`.`length` AS `resource_length`,
  `sbri`.`width` AS `resource_width`,
  `sb`.`objid` AS `block_objid`,
  `sb`.`code` AS `block_code`,
  `sb`.`name` AS `block_name`,
  `r`.`objid` AS `resource_objid`,
  `r`.`name` AS `resource_type`,
  `s`.`objid` AS `section_objid`,
  `s`.`code` AS `section_code`,
  `s`.`name` AS `section_name`,
  `c`.`objid` AS `cemetery_objid`,
  `c`.`code` AS `cemetery_code`,
  `c`.`name` AS `cemetery_name`,
  `t`.`taskid` AS `task_objid`,
  `t`.`state` AS `task_state`,
  `t`.`enddate` AS `task_enddate`,
  `t`.`assignee_objid` AS `task_assignee_objid`,
  `t`.`actor_objid` AS `task_actor_objid`,
  `t`.`prevtaskid` AS `task_prevtaskid` 
  from  `application` `a` 
  left join `cemetery_section_block_resource_info` `sbri` on `a`.`resourceinfo_objid` = `sbri`.`objid`  
  left join `cemetery_section_block_resource` `sbr` on `sbri`.`parentid` = `sbr`.`objid`  
  left join `cemetery_section_block` `sb` on `sbr`.`parentid` = `sb`.`objid`  
  left join `cemetery_section` `s` on `sb`.`parentid` = `s`.`objid`  
  left join `cemetery` `c` on `s`.`parentid` = `c`.`objid`  
  left join `resource` `r` on `sbri`.`resource_objid` = `r`.`objid`  
  left join `deceased` `d` on `a`.`deceased_objid` = `d`.`objid`  
  left join `causeofdeath` `cd` on `d`.`causeofdeath_objid` = `cd`.`objid`  
  left join `application_task` `t` on `a`.`taskid` = `t`.`taskid` 
	left join relation rel on a.relation_objid = rel.objid 
;




