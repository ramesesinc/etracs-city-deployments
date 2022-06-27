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




/* permit */
alter table application drop foreign key application_ibfk_2
;

alter table application drop column permitid
;


drop table if exists permit
;

create table permit (
  objid varchar(50) not null,
  appid varchar(50) not null,
  paymentid varchar(50) default null,
  permitno varchar(25) default null,
  permitdate date default null,
  permittype varchar(25) default null,
  mayor_name varchar(255) default null,
  mayor_title varchar(50) default null,
  ordinanceno varchar(20) default null,
  ordinancedate date default null,
  primary key (objid),
  unique key ux_permitno (permitno),
  key fk_permit_application (appid),
  key fk_permit_payment (paymentid),
  constraint permit_ibfk_1 foreign key (appid) references application (objid),
  constraint permit_ibfk_2 foreign key (paymentid) references payment (objid)
) engine=innodb default charset=utf8
;

/* vw_cemetery_resource: add length and width */

drop view if exists `vw_cemetery_resource` 
;

create view `vw_cemetery_resource` 
as 
select 
  `sri`.`objid` as `objid`,
  `sri`.`parentid` as `parentid`,
  `sr`.`parentid` as `blockid`,
  `sr`.`code` as `code`,
  `sr`.`name` as `name`,
  `sr`.`currentinfoid` as `currentinfoid`,
  `sr`.`currentappid` as `currentappid`,
  `sri`.`state` as `state`,
  `sri`.`areasqm` as `areasqm`,
  `sri`.`resource_objid` as `resource_objid`,
  `sri`.`ui` as `ui`,
	`sri`.length,
	`sri`.width,
  `r`.`name` as `resource_name`,
  `r`.`allowmultiple` as `resource_allowmultiple`,
  `b`.`objid` as `block_objid`,
  `b`.`code` as `block_code`,
  `b`.`name` as `block_name`,
  `s`.`objid` as `section_objid`,
  `s`.`code` as `section_code`,
  `s`.`name` as `section_name`,
  `a`.`appno` as `appno`,
  `a`.`apptype` as `apptype`,
  `a`.`applicant_name` as `applicant_name`,
  `a`.`applicant_address` as `applicant_address`,
  `d`.`name` as `deceased_name`,
  `d`.`nationality` as `deceased_nationality`,
  `d`.`sex` as `deceased_sex`,
  `d`.`age` as `deceased_age`,
  `cd`.`title` as `deceased_causeofdeath`,
  `c`.`objid` as `cemetery_objid`,
  `c`.`code` as `cemetery_code`,
  `c`.`name` as `cemetery_name`,
  `c`.`location` as `cemetery_location`,
  `c`.`isnew` as `cemetery_isnew` 
from  `cemetery_section_block_resource` `sr` 
join `cemetery_section_block_resource_info` `sri` on `sr`.`currentinfoid` = `sri`.`objid` 
join `resource` `r` on `sri`.`resource_objid` = `r`.`objid` 
join `cemetery_section_block` `b` on `sr`.`parentid` = `b`.`objid` 
join `cemetery_section` `s` on `b`.`parentid` = `s`.`objid` 
join `cemetery` `c` on `s`.`parentid` = `c`.`objid`
left join `application` `a` on `sr`.`currentappid` = `a`.`objid`
left join `deceased` `d` on `a`.`deceased_objid` = `d`.`objid`
left join `causeofdeath` `cd` on `d`.`causeofdeath_objid` = `cd`.`objid`
;


INSERT INTO `sys_var` (`name`, `value`, `description`, `datatype`, `category`) VALUES ('COMIS_ORDINANCE_DATE', NULL, NULL, NULL, 'COMIS');
INSERT INTO `sys_var` (`name`, `value`, `description`, `datatype`, `category`) VALUES ('COMIS_ORDINANCE_NO', '<ORDINANCE_NO>', NULL, NULL, 'COMIS');



/* REGISTRATION INFORMATION */
alter table deceased 
	add registryno int,
	add pageno int,
	add bookno int
;

create index ix_registryno on deceased(registryno, bookno, pageno)
;

update sys_wf_transition set caption = 'For Payment' 
where processname = 'application' and parentid = 'for-payment'
;


update sys_wf_transition set 
	properties = '[visibleWhen:"#{false}"]'
where processname = 'application' and parentid in('active', 'expired', 'renewed') and action = 'closed'
;

update sys_wf_transition set 
	properties = '[visibleWhen:"#{false}"]'
where processname = 'application' and parentid in('for-payment') and action = 'post-payment'
;

update sys_wf_transition set 
	properties = '[visibleWhen:"#{false}"]'
where processname = 'application' and parentid in('releaser') and action = 'void-payment'
;

update sys_wf_transition set 
	properties = '[visibleWhen:"#{false}"]'
where processname = 'application' and parentid in('active') and action = 'expired'
;

update sys_wf_transition set 
	properties = '[visibleWhen:"#{false}"]'
where processname = 'application' and parentid in('expired') and action = 'renewed'
;

update sys_wf_node set title = 'For Payment' where processname='application' and name ='for-payment' 
;

update sys_wf_node set title = 'For Release' where processname='application' and name ='releaser' 
;

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
  PRIMARY KEY (objid),
  KEY ix_txndate (txndate),
  KEY ix_txnlog_action (action),
  KEY ix_txnlog_ref (ref),
  KEY ix_txnlog_userid (userid),
  KEY ix_txnlog_useridaction (userid,action),
  KEY ix_refid (refid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;




/* CERTIFICATION */

CREATE TABLE `certification` (
  `objid` varchar(50) NOT NULL,
  `state` varchar(25) NOT NULL,
  `txnno` varchar(25) NOT NULL,
  `txndate` datetime NOT NULL,
  `requestedby_name` varchar(255) NOT NULL,
  `requestedby_address` varchar(255) NOT NULL,
  `purpose` varchar(255) NOT NULL,
  `refid` varchar(50) NOT NULL,
  `reftype` varchar(255) NOT NULL,
  `handler` varchar(25) NOT NULL,
  `receipt_objid` varchar(50) DEFAULT NULL,
  `receipt_no` varchar(15) DEFAULT NULL,
  `receipt_date` date DEFAULT NULL,
  `receipt_amount` decimal(16,2) DEFAULT NULL,
  `report_name` varchar(50) NOT NULL,
  `taskid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`objid`),
  UNIQUE KEY `ix_txnno` (`txnno`),
  KEY `ix_state` (`state`) USING BTREE,
  KEY `ix_requestedby` (`requestedby_name`),
  KEY `ix_refid` (`refid`),
  KEY `ix_receiptid` (`receipt_objid`),
  KEY `ix_receiptno` (`receipt_no`),
  KEY `ix_taskid` (`taskid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;
drop table if exists certification_task;

CREATE TABLE `certification_task` (
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
  CONSTRAINT `fk_certification_task_certification` FOREIGN KEY (`refid`) REFERENCES `certification` (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;



insert into sys_role (name, title, system)
values('CERTIFICATION_VERIFIER', 'CERTIFICATION VERIFIER', 1)
;

insert into sys_role (name, title, system)
values('CERTIFICATION_APPROVER', 'CERTIFICATION APPROVER', 1)
;

insert into sys_role (name, title, system)
values('CERTIFICATION_RELEASER', 'CERTIFICATION RELEASER', 1)
;


delete from sys_wf_transition where processname ='certification';
delete from sys_wf_node where processname ='certification';
delete from sys_wf where name ='certification';

INSERT INTO `sys_wf` (`name`, `title`, `domain`) VALUES ('certification', 'Certification', 'COMIS');

INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('start', 'certification', 'Start', 'start', '1', NULL, NULL, NULL, '[type:\"start\",fillColor:\"#00ff00\",pos:[81,110],size:[32,32]]', '[:]', NULL);
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('verification', 'certification', 'Verification', 'state', '2', NULL, 'COMIS', 'CERTIFICATION_VERIFIER', '[type:\"state\",fillColor:\"#c0c0c0\",pos:[200,112],size:[100,43]]', '[:]', '1');
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('approval', 'certification', 'For Approval', 'state', '3', NULL, 'COMIS', 'CERTIFICATION_APPROVER', '[type:\"state\",fillColor:\"#c0c0c0\",pos:[372,108],size:[124,45]]', '[:]', '1');
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('for-release', 'certification', 'For Release', 'state', '4', NULL, 'COMIS', 'CERTIFICATION_RELEASER', '[type:\"state\",fillColor:\"#c0c0c0\",pos:[563,111],size:[147,49]]', '[:]', '1');
INSERT INTO `sys_wf_node` (`name`, `processname`, `title`, `nodetype`, `idx`, `salience`, `domain`, `role`, `ui`, `properties`, `tracktime`) VALUES ('end', 'certification', 'Released', 'end', '5', NULL, NULL, NULL, '[type:\"end\",fillColor:\"#ff0000\",pos:[790,114],size:[32,32]]', '[:]', NULL);

INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('start', 'certification', 'init', 'verification', '1', NULL, '[:]', NULL, 'Init', '[points:[113,126,200,130],type:\"arrow\",pos:[113,126],size:[87,4]]');
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('verification', 'certification', 'submit', 'approval', '2', NULL, '[showConfirm:true,confirmMessage:\"Submit for approval?\"]', NULL, 'Submit', '[points:[300,131,372,130],type:\"arrow\",pos:[300,130],size:[72,1]]');
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('approval', 'certification', 'approve', 'for-release', '3', NULL, '[showConfirm:true,confirmMessage:\"Approve certification?\"]', NULL, 'Approve', '[points:[496,131,563,133],type:\"arrow\",pos:[496,131],size:[67,2]]');
INSERT INTO `sys_wf_transition` (`parentid`, `processname`, `action`, `to`, `idx`, `eval`, `properties`, `permission`, `caption`, `ui`) VALUES ('for-release', 'certification', 'release', 'end', '4', NULL, '[showConfirm:true,confirmMessage:\"Release certification?\"]', NULL, 'Release', '[points:[710,133,790,131],type:\"arrow\",pos:[710,131],size:[80,2]]');

drop view if exists vw_certification 
;

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
;


CREATE TABLE `civilstatus` (
  `objid` varchar(50) NOT NULL,
  PRIMARY KEY (`objid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

INSERT INTO `civilstatus` (`objid`) VALUES ('SINGLE');
INSERT INTO `civilstatus` (`objid`) VALUES ('MARRIED');
INSERT INTO `civilstatus` (`objid`) VALUES ('WIDOWED');
INSERT INTO `civilstatus` (`objid`) VALUES ('DIVORCED');
INSERT INTO `civilstatus` (`objid`) VALUES ('ANNULLED');


alter table deceased add civilstatus varchar(50);

alter table deceased add dtregistered date;

alter table certification add deceased_name varchar(255)
;

create index ix_deceased_name on certification(deceased_name)
;


alter table deceased 
	add constraint fk_deceased_civilstatus foreign key(civilstatus)
	references civilstatus(objid)
;

