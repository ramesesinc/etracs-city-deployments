INSERT INTO sys_var ([name], [value], [description], [datatype], [category]) 
VALUES ('bldg_rpu_allow_edit_ry_appraisal', '2012', 'Allow manual editing of appraisal for the specified comma separated revision years', NULL, 'ASSESSOR')
go 


alter table rptledger_item  add fromqtr int
go 
alter table rptledger_item  add toqtr int
go 

CREATE TABLE batch_rpttaxcredit (
  objid varchar(50) NOT NULL,
  state varchar(25) NOT NULL,
  txndate date NOT NULL,
  txnno varchar(25) NOT NULL,
  rate decimal(10,2) NOT NULL,
  paymentfrom date DEFAULT NULL,
  paymentto varchar(255) DEFAULT NULL,
  creditedyear int NOT NULL,
  reason varchar(255) NOT NULL,
  validity date NULL,
  PRIMARY KEY (objid)
) 
go

create index ix_state on batch_rpttaxcredit(state)
go
create index ix_txnno on batch_rpttaxcredit(txnno)
go

CREATE TABLE batch_rpttaxcredit_ledger (
  objid varchar(50) NOT NULL,
  parentid varchar(50) NOT NULL,
  state varchar(25) NOT NULL,
  error varchar(255) NULL,
	barangayid varchar(50) not null, 
  PRIMARY KEY (objid)
) 
go


create index ix_parentid on batch_rpttaxcredit_ledger (parentid)
go
create index ix_state on batch_rpttaxcredit_ledger (state)
go
create index ix_barangayid on batch_rpttaxcredit_ledger (barangayid)
go

alter table batch_rpttaxcredit_ledger 
add constraint fk_rpttaxcredit_rptledger_parent foreign key(parentid) references batch_rpttaxcredit(objid)
go

alter table batch_rpttaxcredit_ledger 
add constraint fk_rpttaxcredit_rptledger_rptledger foreign key(objid) references rptledger(objid)
go




CREATE TABLE batch_rpttaxcredit_ledger_posted (
  objid varchar(50) NOT NULL,
  parentid varchar(50) NOT NULL,
  barangayid varchar(50) NOT NULL,
  PRIMARY KEY (objid)
)
go

create index ix_parentid on batch_rpttaxcredit_ledger_posted(parentid)
go
create index ix_barangayid on batch_rpttaxcredit_ledger_posted(barangayid)
go

alter table batch_rpttaxcredit_ledger_posted 
add constraint fk_rpttaxcredit_rptledger_posted_parent foreign key(parentid) references batch_rpttaxcredit(objid)
go

alter table batch_rpttaxcredit_ledger_posted 
add constraint fk_rpttaxcredit_rptledger_posted_rptledger foreign key(objid) references rptledger(objid)
go

create view vw_batch_rpttaxcredit_error
as 
select br.*, rl.tdno
from batch_rpttaxcredit_ledger br 
inner join rptledger rl on br.objid = rl.objid 
where br.state = 'ERROR'
go

alter table rpttaxcredit add info text
go


alter table rpttaxcredit add discapplied decimal(16,2) not null
go

update rpttaxcredit set discapplied = 0 where discapplied is null 
go


CREATE TABLE rpt_syncdata_forsync (
  [objid] varchar(50) NOT NULL,
  [reftype] varchar(50) NOT NULL,
  [refno] varchar(50) NOT NULL,
  [action] varchar(50) NOT NULL,
  [orgid] varchar(50) NOT NULL,
  [dtfiled] datetime NOT NULL,
  [createdby_objid] varchar(50) DEFAULT NULL,
  [createdby_name] varchar(255) DEFAULT NULL,
  [createdby_title] varchar(50) DEFAULT NULL,
  PRIMARY KEY (objid)
)
go 
create index ix_refno on rpt_syncdata_forsync (refno)
go
create index ix_orgid on rpt_syncdata_forsync (orgid)
go

CREATE TABLE rpt_syncdata (
  [objid] varchar(50) NOT NULL,
  [state] varchar(25) NOT NULL,
  [refid] varchar(50) NOT NULL,
  [reftype] varchar(50) NOT NULL,
  [refno] varchar(50) NOT NULL,
  [action] varchar(50) NOT NULL,
  [dtfiled] datetime NOT NULL,
  [orgid] varchar(50) NOT NULL,
  [remote_orgid] varchar(50) DEFAULT NULL,
  [remote_orgcode] varchar(5) DEFAULT NULL,
  [remote_orgclass] varchar(25) DEFAULT NULL,
  [sender_objid] varchar(50) DEFAULT NULL,
  [sender_name] varchar(255) DEFAULT NULL,
  [sender_title] varchar(80) DEFAULT NULL,
  PRIMARY KEY (objid)
)
go

create index ix_state on rpt_syncdata (state)
go
create index ix_refid on rpt_syncdata (refid)
go
create index ix_refno on rpt_syncdata (refno)
go
create index ix_orgid on rpt_syncdata (orgid)
go

CREATE TABLE rpt_syncdata_item (
  objid varchar(50) NOT NULL,
  parentid varchar(50) NOT NULL,
  state varchar(25) NOT NULL,
  refid varchar(50) NOT NULL,
  reftype varchar(50) NOT NULL,
  refno varchar(50) NOT NULL,
  action varchar(50) NOT NULL,
  idx int NOT NULL,
  info text,
  PRIMARY KEY (objid)
)
go 

create index ix_parentid on rpt_syncdata_item (parentid)
go
create index ix_state on rpt_syncdata_item (state)
go
create index ix_refid on rpt_syncdata_item (refid)
go
create index ix_refno on rpt_syncdata_item (refno)
go


alter table rpt_syncdata_item
  add CONSTRAINT FK_parentid_rpt_syncdata 
  FOREIGN KEY (parentid) REFERENCES rpt_syncdata (objid)
go 

CREATE TABLE rpt_syncdata_error (
  [objid] varchar(50) NOT NULL,
  [filekey] varchar(1000) NOT NULL,
  [error] text,
  [refid] varchar(50) NOT NULL,
  [reftype] varchar(50) NOT NULL,
  [refno] varchar(50) NOT NULL,
  [action] varchar(50) NOT NULL,
  [idx] int NOT NULL,
  [info] text,
  [parent] text,
  [remote_orgid] varchar(50) DEFAULT NULL,
  [remote_orgcode] varchar(5) DEFAULT NULL,
  [remote_orgclass] varchar(50) DEFAULT NULL,
  PRIMARY KEY (objid)
)
go 

create index ix_refid on rpt_syncdata_error (refid)
go
create index ix_refno on rpt_syncdata_error (refno)
go
create index ix_filekey on rpt_syncdata_error (filekey)
go
create index ix_remote_orgid on rpt_syncdata_error (remote_orgid)
go
create index ix_remote_orgcode on rpt_syncdata_error (remote_orgcode)
go

INSERT INTO sys_var ([name], [value], [description], [datatype], [category]) 
VALUES ('assesser_new_sync_lgus', NULL, 'List of LGUs using new sync facility', NULL, 'ASSESSOR')
go 





ALTER TABLE rpt_syncdata_forsync ADD remote_orgid VARCHAR(15)
go 

INSERT INTO sys_var ([name], [value], [description], [datatype], [category]) 
VALUES ('fileserver_upload_task_active', '0', 'Activate / Deactivate upload task', 'boolean', 'SYSTEM')
go 



INSERT INTO sys_var ([name], [value], [description], [datatype], [category]) 
VALUES ('fileserver_download_task_active', '0', 'Activate / Deactivate download task', 'boolean', 'SYSTEM')
go



CREATE TABLE rpt_syncdata_completed (
  [objid] varchar(255) NOT NULL,
  [idx] int DEFAULT NULL,
  [action] varchar(100) DEFAULT NULL,
  [refno] varchar(50) DEFAULT NULL,
  [refid] varchar(50) DEFAULT NULL,
  [reftype] varchar(50) DEFAULT NULL,
  [parent_orgid] varchar(50) DEFAULT NULL,
  [sender_name] varchar(255) DEFAULT NULL,
  [sender_title] varchar(255) DEFAULT NULL,
  [dtcreated] datetime DEFAULT NULL,
  PRIMARY KEY (objid)
)
go 

CREATE INDEX ix_refno ON rpt_syncdata_completed (refno)
go
CREATE INDEX ix_refid ON rpt_syncdata_completed (refid)
go
CREATE INDEX ix_parent_orgid ON rpt_syncdata_completed (parent_orgid)
go

alter table rpt_syncdata_forsync add info text
go
alter table rpt_syncdata add info text
go



if exists(select * from sysobjects where id = OBJECT_ID('batchgr_task'))
begin 
	drop table batchgr_task
end
go 

if exists(select * from sysobjects where id = OBJECT_ID('batchgr_item'))
begin 
	drop table batchgr_item
end
go 

if exists(select * from sysobjects where id = OBJECT_ID('batchgr'))
begin 
	drop table batchgr
end
go 

CREATE TABLE batchgr (
  objid varchar(50) NOT NULL,
  state varchar(25) NOT NULL,
  ry int NOT NULL,
  lgu_objid varchar(50) NOT NULL,
  barangay_objid varchar(50) NOT NULL,
  rputype varchar(15) DEFAULT NULL,
  classification_objid varchar(50) DEFAULT NULL,
  section varchar(10) DEFAULT NULL,
  memoranda varchar(100) DEFAULT NULL,
  txntype_objid varchar(50) DEFAULT NULL,
  txnno varchar(25) DEFAULT NULL,
  txndate datetime DEFAULT NULL,
  effectivityyear int DEFAULT NULL,
  effectivityqtr int DEFAULT NULL,
  originlgu_objid varchar(50) DEFAULT NULL,
  PRIMARY KEY (objid)
)
go

create index ix_barangay_objid on batchgr(barangay_objid)
go 
create index ix_state on batchgr(state)
go 
create index fk_lgu_objid on batchgr(lgu_objid)
go 
create index ix_ry on batchgr(ry)
go 
create index ix_txnno on batchgr(txnno)
go 
create index ix_classificationid on batchgr(classification_objid)
go 
create index ix_section on batchgr(section)
go 
alter table batchgr add CONSTRAINT batchgr_ibfk_1 FOREIGN KEY (barangay_objid) REFERENCES sys_org (objid)
go 
alter table batchgr add CONSTRAINT batchgr_ibfk_2 FOREIGN KEY (classification_objid) REFERENCES propertyclassification (objid)
go 
alter table batchgr add CONSTRAINT batchgr_ibfk_3 FOREIGN KEY (lgu_objid) REFERENCES sys_org (objid)
go 
alter table batchgr add CONSTRAINT fk_batchgr_barangayid FOREIGN KEY (barangay_objid) REFERENCES sys_org (objid)
go 
alter table batchgr add CONSTRAINT fk_batchgr_classificationid FOREIGN KEY (classification_objid) REFERENCES propertyclassification (objid)
go 
alter table batchgr add CONSTRAINT fk_batchgr_lguid FOREIGN KEY (lgu_objid) REFERENCES sys_org (objid)
go 



CREATE TABLE batchgr_task (
  objid varchar(50) NOT NULL,
  refid varchar(50) DEFAULT NULL,
  parentprocessid varchar(50) DEFAULT NULL,
  state varchar(50) DEFAULT NULL,
  startdate datetime DEFAULT NULL,
  enddate datetime DEFAULT NULL,
  assignee_objid varchar(50) DEFAULT NULL,
  assignee_name varchar(100) DEFAULT NULL,
  assignee_title varchar(80) DEFAULT NULL,
  actor_objid varchar(50) DEFAULT NULL,
  actor_name varchar(100) DEFAULT NULL,
  actor_title varchar(80) DEFAULT NULL,
  message varchar(255) DEFAULT NULL,
  signature text,
  returnedby varchar(100) DEFAULT NULL,
  PRIMARY KEY (objid)
) 
go 

create index ix_assignee_objid on batchgr_task(assignee_objid)
go 
create index ix_refid on batchgr_task(refid)
go 
alter table batchgr_task add CONSTRAINT fk_batchgr_task_batchgr FOREIGN KEY (refid) REFERENCES batchgr (objid)
go 


CREATE TABLE batchgr_item (
  objid varchar(50) NOT NULL,
  parent_objid varchar(50) NOT NULL,
  state varchar(50) NOT NULL,
  rputype varchar(15) NOT NULL,
  tdno varchar(50) NOT NULL,
  fullpin varchar(50) NOT NULL,
  pin varchar(50) NOT NULL,
  suffix int NOT NULL,
  newfaasid varchar(50) DEFAULT NULL,
  error text,
  subsuffix int DEFAULT NULL,
  PRIMARY KEY (objid)
)
go 
 
create index fk_batchgr_item_batchgr on batchgr_item(parent_objid)
go 
create index fk_batchgr_item_newfaasid on batchgr_item(newfaasid)
go 
create index fk_batchgr_item_tdno on batchgr_item(tdno)
go 
create index fk_batchgr_item_pin on batchgr_item(pin)
go 

alter table batchgr_item add CONSTRAINT batchgr_item_ibfk_1 FOREIGN KEY (parent_objid) REFERENCES batchgr (objid)
go

alter table batchgr_item add CONSTRAINT batchgr_item_ibfk_2 FOREIGN KEY (objid) REFERENCES faas (objid)
go

alter table batchgr_item add CONSTRAINT batchgr_item_ibfk_3 FOREIGN KEY (newfaasid) REFERENCES faas (objid)
go

alter table batchgr_item add CONSTRAINT batchgr_item_ibfk_4 FOREIGN KEY (objid) REFERENCES faas (objid)
go

alter table batchgr_item add CONSTRAINT fk_batchgr_item_faas FOREIGN KEY (objid) REFERENCES faas (objid)
go


if exists(select * from sysobjects where id = OBJECT_ID('vw_batchgr'))
begin 
	drop view vw_batchgr
end
go

create view vw_batchgr 
as 
select 
    bg.objid AS objid,
    bg.state AS state,
    bg.ry AS ry,
    bg.lgu_objid AS lgu_objid,
    bg.barangay_objid AS barangay_objid,
    bg.rputype AS rputype,
    bg.classification_objid AS classification_objid,
    bg.section AS section,
    bg.memoranda AS memoranda,
    bg.txntype_objid AS txntype_objid,
    bg.txnno AS txnno,
    bg.txndate AS txndate,
    bg.effectivityyear AS effectivityyear,
    bg.effectivityqtr AS effectivityqtr,
    bg.originlgu_objid AS originlgu_objid,
    l.name AS lgu_name,
    b.name AS barangay_name,
    b.pin AS barangay_pin,
    pc.name AS classification_name,
    t.objid AS taskid,
    t.state AS taskstate,
    t.assignee_objid AS assignee_objid 
from batchgr bg join sys_org l on bg.lgu_objid = l.objid 
    left join barangay b on bg.barangay_objid = b.objid 
    left join propertyclassification pc on bg.classification_objid = pc.objid 
    left join batchgr_task t on bg.objid = t.refid and t.enddate is null 
go


create table cashreceipt_rpt_share_forposting_repost (
  rptpaymentid varchar(50) not null,
  receiptid varchar(50) not null,
  receiptdate date not null,
  rptledgerid varchar(50) not null
)
go 

create unique index ux_receiptid_rptledgerid on cashreceipt_rpt_share_forposting_repost(receiptid,rptledgerid)
go 

create index fk_rptshare_repost_rptledgerid on cashreceipt_rpt_share_forposting_repost(rptledgerid)
go 
create index fk_rptshare_repost_cashreceiptid on cashreceipt_rpt_share_forposting_repost(receiptid)
go 
alter table cashreceipt_rpt_share_forposting_repost 
    add constraint fk_rptshare_repost_cashreceipt foreign key (receiptid) 
    references cashreceipt (objid)
go 
alter table cashreceipt_rpt_share_forposting_repost 
    add constraint fk_rptshare_repost_rptledger foreign key (rptledgerid) 
    references rptledger (objid)
go 



alter table bldgrpu add occpermitno varchar(25) 
go 


if exists(select * from sysobjects where id = OBJECT_ID('rpt_syncdata_item'))
begin 
    drop table rpt_syncdata_item
end
go 
if exists(select * from sysobjects where id = OBJECT_ID('rpt_syncdata_forsync'))
begin 
    drop table rpt_syncdata_forsync
end
go 
if exists(select * from sysobjects where id = OBJECT_ID('rpt_syncdata_error'))
begin 
    drop table rpt_syncdata_error
end
go 
if exists(select * from sysobjects where id = OBJECT_ID('rpt_syncdata_completed'))
begin 
    drop table rpt_syncdata_completed
end
go 
if exists(select * from sysobjects where id = OBJECT_ID('rpt_syncdata'))
begin 
    drop table rpt_syncdata
end
go 

CREATE TABLE rpt_syncdata (
  [objid] varchar(50) NOT NULL,
  [state] varchar(25) NOT NULL,
  [refid] varchar(50) NOT NULL,
  [reftype] varchar(50) NOT NULL,
  [refno] varchar(50) NOT NULL,
  [action] varchar(50) NOT NULL,
  [dtfiled] datetime NOT NULL,
  [orgid] varchar(50) NOT NULL,
  [remote_orgid] varchar(50) DEFAULT NULL,
  [remote_orgcode] varchar(5) DEFAULT NULL,
  [remote_orgclass] varchar(25) DEFAULT NULL,
  [sender_objid] varchar(50) DEFAULT NULL,
  [sender_name] varchar(255) DEFAULT NULL,
  [sender_title] varchar(80) DEFAULT NULL,
  [info] text,
  PRIMARY KEY (objid)
)
go


create index ix_state on rpt_syncdata (state)
go
create index ix_refid on rpt_syncdata (refid)
go
create index ix_refno on rpt_syncdata (refno)
go
create index ix_orgid on rpt_syncdata (orgid)
go

CREATE TABLE rpt_syncdata_item (
  [objid] varchar(50) NOT NULL,
  [parentid] varchar(50) NOT NULL,
  [state] varchar(25) NOT NULL,
  [refid] varchar(50) NOT NULL,
  [reftype] varchar(50) NOT NULL,
  [refno] varchar(50) NOT NULL,
  [action] varchar(50) NOT NULL,
  [idx] int NOT NULL,
  [info] text,
  PRIMARY KEY (objid)
)
go 


create index ix_parentid on rpt_syncdata_item (parentid)
go 
create index ix_state on rpt_syncdata_item (state)
go 
create index ix_refid on rpt_syncdata_item (refid)
go 
create index ix_refno on rpt_syncdata_item (refno)
go 
alter table rpt_syncdata_item add CONSTRAINT FK_parentid_rpt_syncdata FOREIGN KEY (parentid) REFERENCES rpt_syncdata (objid)
go 


CREATE TABLE rpt_syncdata_forsync (
  [objid] varchar(50) NOT NULL,
  [reftype] varchar(50) NOT NULL,
  [refno] varchar(50) NOT NULL,
  [action] varchar(50) NOT NULL,
  [orgid] varchar(50) NOT NULL,
  [dtfiled] datetime NOT NULL,
  [createdby_objid] varchar(50) DEFAULT NULL,
  [createdby_name] varchar(255) DEFAULT NULL,
  [createdby_title] varchar(50) DEFAULT NULL,
  [remote_orgid] varchar(15) DEFAULT NULL,
  [state] varchar(25) DEFAULT NULL,
  [info] text,
  PRIMARY KEY (objid)
)
go 

create index ix_refno on rpt_syncdata_forsync (refno)
go 
create index ix_orgid on rpt_syncdata_forsync (orgid)
go 
create index ix_state on rpt_syncdata_forsync (state)
go 

CREATE TABLE rpt_syncdata_error (
  [objid] varchar(50) NOT NULL,
  [filekey] varchar(1000) NOT NULL,
  [error] text,
  [refid] varchar(50) NOT NULL,
  [reftype] varchar(50) NOT NULL,
  [refno] varchar(50) NOT NULL,
  [action] varchar(50) NOT NULL,
  [idx] int NOT NULL,
  [info] text,
  [parent] text,
  [remote_orgid] varchar(50) DEFAULT NULL,
  [remote_orgcode] varchar(5) DEFAULT NULL,
  [remote_orgclass] varchar(50) DEFAULT NULL,
  PRIMARY KEY (objid)
)
go 

create index ix_refid on rpt_syncdata_error (refid)
go 
create index ix_refno on rpt_syncdata_error (refno)
go 
create index ix_filekey on rpt_syncdata_error (filekey)
go 
create index ix_remote_orgid on rpt_syncdata_error (remote_orgid)
go 
create index ix_remote_orgcode on rpt_syncdata_error (remote_orgcode)
go 


CREATE TABLE rpt_syncdata_completed (
  [objid] varchar(255) NOT NULL,
  [idx] int DEFAULT NULL,
  [action] varchar(100) DEFAULT NULL,
  [refno] varchar(50) DEFAULT NULL,
  [refid] varchar(50) DEFAULT NULL,
  [reftype] varchar(50) DEFAULT NULL,
  [parent_orgid] varchar(50) DEFAULT NULL,
  [sender_name] varchar(255) DEFAULT NULL,
  [sender_title] varchar(255) DEFAULT NULL,
  [dtcreated] datetime DEFAULT NULL,
  PRIMARY KEY (objid)
)
go 

create index ix_refno on rpt_syncdata_completed(refno)
go 
create index ix_refid on rpt_syncdata_completed(refid)
go 
create index ix_parent_orgid on rpt_syncdata_completed(parent_orgid)
go 


alter table rptacknowledgement_item add faas_objid varchar(50)
go 

alter table rpttracking add msg varchar(1000)
go 

alter table rpu add isonline int 
go 

alter table rpu add stewardparentrpumasterid varchar(50)
go 



if exists(select * from sysobjects where id = OBJECT_ID('vw_faas_lookup'))
begin 
    drop view vw_faas_lookup
end 
go 

if exists(select * from sysobjects where id = OBJECT_ID('vw_batch_rpttaxcredit_error'))
begin 
    drop view vw_batch_rpttaxcredit_error
end 
go 


if exists(select * from sysobjects where id = OBJECT_ID('vw_batchgr'))
begin 
    drop view vw_batchgr
end 
go 


if exists(select * from sysobjects where id = OBJECT_ID('vw_assessment_notice'))
begin 
    drop view vw_assessment_notice
end 
go 

if exists(select * from sysobjects where id = OBJECT_ID('vw_assessment_notice_item'))
begin 
    drop view vw_assessment_notice_item
end 
go 

if exists(select * from sysobjects where id = OBJECT_ID('vw_landtax_lgu_account_mapping'))
begin 
    drop view vw_landtax_lgu_account_mapping
end 
go 

if exists(select * from sysobjects where id = OBJECT_ID('vw_landtax_report_rptdelinquency_detail'))
begin 
    drop view vw_landtax_report_rptdelinquency_detail
end 
go 

if exists(select * from sysobjects where id = OBJECT_ID('vw_landtax_report_rptdelinquency'))
begin 
    drop view vw_landtax_report_rptdelinquency
end 
go 

if exists(select * from sysobjects where id = OBJECT_ID('vw_machine_smv'))
begin 
    drop view vw_machine_smv
end 
go 

if exists(select * from sysobjects where id = OBJECT_ID('vw_rptcertification_item'))
begin 
    drop view vw_rptcertification_item
end 
go 

if exists(select * from sysobjects where id = OBJECT_ID('vw_rptledger_avdifference'))
begin 
    drop view vw_rptledger_avdifference
end 
go 

if exists(select * from sysobjects where id = OBJECT_ID('vw_rptpayment_item_detail'))
begin 
    drop view vw_rptpayment_item_detail
end 
go 

if exists(select * from sysobjects where id = OBJECT_ID('vw_rptpayment_item'))
begin 
    drop view vw_rptpayment_item
end 
go 

if exists(select * from sysobjects where id = OBJECT_ID('vw_rpu_assessment'))
begin 
    drop view vw_rpu_assessment
end 
go 

if exists(select * from sysobjects where id = OBJECT_ID('vw_txn_log'))
begin 
    drop view vw_txn_log
end 
go 



CREATE VIEW vw_assessment_notice AS select a.objid AS objid,a.state AS state,a.txnno AS txnno,a.txndate AS txndate,a.taxpayerid AS taxpayerid,a.taxpayername AS taxpayername,a.taxpayeraddress AS taxpayeraddress,a.dtdelivered AS dtdelivered,a.receivedby AS receivedby,a.remarks AS remarks,a.assessmentyear AS assessmentyear,a.administrator_name AS administrator_name,a.administrator_address AS administrator_address,fl.tdno AS tdno,fl.displaypin AS fullpin,fl.cadastrallotno AS cadastrallotno,fl.titleno AS titleno from ((assessmentnotice a join assessmentnoticeitem i on((a.objid = i.assessmentnoticeid))) join faas_list fl on((i.faasid = fl.objid)))
go

CREATE VIEW vw_assessment_notice_item AS select ni.objid AS objid,ni.assessmentnoticeid AS assessmentnoticeid,f.objid AS faasid,f.effectivityyear AS effectivityyear,f.effectivityqtr AS effectivityqtr,f.tdno AS tdno,f.taxpayer_objid AS taxpayer_objid,e.name AS taxpayer_name,e.address_text AS taxpayer_address,f.owner_name AS owner_name,f.owner_address AS owner_address,f.administrator_name AS administrator_name,f.administrator_address AS administrator_address,f.rpuid AS rpuid,f.lguid AS lguid,f.txntype_objid AS txntype_objid,ft.displaycode AS txntype_code,rpu.rputype AS rputype,rpu.ry AS ry,rpu.fullpin AS fullpin,rpu.taxable AS taxable,rpu.totalareaha AS totalareaha,rpu.totalareasqm AS totalareasqm,rpu.totalbmv AS totalbmv,rpu.totalmv AS totalmv,rpu.totalav AS totalav,rp.section AS section,rp.parcel AS parcel,rp.surveyno AS surveyno,rp.cadastrallotno AS cadastrallotno,rp.blockno AS blockno,rp.claimno AS claimno,rp.street AS street,o.name AS lguname,b.name AS barangay,pc.code AS classcode,pc.name AS classification from (((((((((assessmentnoticeitem ni join faas f on((ni.faasid = f.objid))) left join txnsignatory ts on(((ts.refid = f.objid) and (ts.type = 'APPROVER')))) join rpu on((f.rpuid = rpu.objid))) join propertyclassification pc on((rpu.classification_objid = pc.objid))) join realproperty rp on((f.realpropertyid = rp.objid))) join barangay b on((rp.barangayid = b.objid))) join sys_org o on((f.lguid = o.objid))) join entity e on((f.taxpayer_objid = e.objid))) join faas_txntype ft on((f.txntype_objid = ft.objid)))
go

CREATE VIEW vw_batch_rpttaxcredit_error AS select br.objid AS objid,br.parentid AS parentid,br.state AS state,br.error AS error,br.barangayid AS barangayid,rl.tdno AS tdno from (batch_rpttaxcredit_ledger br join rptledger rl on((br.objid = rl.objid))) where (br.state = 'ERROR')
go

CREATE VIEW vw_batchgr AS select bg.objid AS objid,bg.state AS state,bg.ry AS ry,bg.lgu_objid AS lgu_objid,bg.barangay_objid AS barangay_objid,bg.rputype AS rputype,bg.classification_objid AS classification_objid,bg.section AS section,bg.memoranda AS memoranda,bg.txntype_objid AS txntype_objid,bg.txnno AS txnno,bg.txndate AS txndate,bg.effectivityyear AS effectivityyear,bg.effectivityqtr AS effectivityqtr,bg.originlgu_objid AS originlgu_objid,l.name AS lgu_name,b.name AS barangay_name,b.pin AS barangay_pin,pc.name AS classification_name,t.objid AS taskid,t.state AS taskstate,t.assignee_objid AS assignee_objid from ((((batchgr bg join sys_org l on((bg.lgu_objid = l.objid))) left join barangay b on((bg.barangay_objid = b.objid))) left join propertyclassification pc on((bg.classification_objid = pc.objid))) left join batchgr_task t on(((bg.objid = t.refid) and t.enddate is null)))
go

CREATE VIEW vw_faas_lookup AS select fl.objid AS objid,fl.state AS state,fl.rpuid AS rpuid,fl.utdno AS utdno,fl.tdno AS tdno,fl.txntype_objid AS txntype_objid,fl.effectivityyear AS effectivityyear,fl.effectivityqtr AS effectivityqtr,fl.taxpayer_objid AS taxpayer_objid,fl.owner_name AS owner_name,fl.owner_address AS owner_address,fl.prevtdno AS prevtdno,fl.cancelreason AS cancelreason,fl.cancelledbytdnos AS cancelledbytdnos,fl.lguid AS lguid,fl.realpropertyid AS realpropertyid,fl.displaypin AS fullpin,fl.originlguid AS originlguid,e.name AS taxpayer_name,e.address_text AS taxpayer_address,pc.code AS classification_code,pc.code AS classcode,pc.name AS classification_name,pc.name AS classname,fl.ry AS ry,fl.rputype AS rputype,fl.totalmv AS totalmv,fl.totalav AS totalav,fl.totalareasqm AS totalareasqm,fl.totalareaha AS totalareaha,fl.barangayid AS barangayid,fl.cadastrallotno AS cadastrallotno,fl.blockno AS blockno,fl.surveyno AS surveyno,fl.pin AS pin,fl.barangay AS barangay_name,fl.trackingno AS trackingno from ((faas_list fl left join propertyclassification pc on((fl.classification_objid = pc.objid))) left join entity e on((fl.taxpayer_objid = e.objid)))
go

CREATE VIEW vw_landtax_lgu_account_mapping AS select ia.org_objid AS org_objid,ia.org_name AS org_name,o.orgclass AS org_class,p.objid AS parent_objid,p.code AS parent_code,p.title AS parent_title,ia.objid AS item_objid,ia.code AS item_code,ia.title AS item_title,ia.fund_objid AS item_fund_objid,ia.fund_code AS item_fund_code,ia.fund_title AS item_fund_title,ia.type AS item_type,pt.tag AS item_tag from (((itemaccount ia join itemaccount p on((ia.parentid = p.objid))) join itemaccount_tag pt on((p.objid = pt.acctid))) join sys_org o on((ia.org_objid = o.objid))) where (p.state = 'ACTIVE')
go

CREATE VIEW vw_landtax_report_rptdelinquency_detail AS select ri.objid AS objid,ri.rptledgerid AS rptledgerid,ri.barangayid AS barangayid,ri.year AS year,ri.qtr AS qtr,r.dtgenerated AS dtgenerated,r.dtcomputed AS dtcomputed,r.generatedby_name AS generatedby_name,r.generatedby_title AS generatedby_title,(case when (ri.revtype = 'basic') then ri.amount else 0 end) AS basic,(case when (ri.revtype = 'basic') then ri.interest else 0 end) AS basicint,(case when (ri.revtype = 'basic') then ri.discount else 0 end) AS basicdisc,(case when (ri.revtype = 'basic') then (ri.interest - ri.discount) else 0 end) AS basicdp,(case when (ri.revtype = 'basic') then ((ri.amount + ri.interest) - ri.discount) else 0 end) AS basicnet,(case when (ri.revtype = 'basicidle') then ri.amount else 0 end) AS basicidle,(case when (ri.revtype = 'basicidle') then ri.interest else 0 end) AS basicidleint,(case when (ri.revtype = 'basicidle') then ri.discount else 0 end) AS basicidledisc,(case when (ri.revtype = 'basicidle') then (ri.interest - ri.discount) else 0 end) AS basicidledp,(case when (ri.revtype = 'basicidle') then ((ri.amount + ri.interest) - ri.discount) else 0 end) AS basicidlenet,(case when (ri.revtype = 'sef') then ri.amount else 0 end) AS sef,(case when (ri.revtype = 'sef') then ri.interest else 0 end) AS sefint,(case when (ri.revtype = 'sef') then ri.discount else 0 end) AS sefdisc,(case when (ri.revtype = 'sef') then (ri.interest - ri.discount) else 0 end) AS sefdp,(case when (ri.revtype = 'sef') then ((ri.amount + ri.interest) - ri.discount) else 0 end) AS sefnet,(case when (ri.revtype = 'firecode') then ri.amount else 0 end) AS firecode,(case when (ri.revtype = 'firecode') then ri.interest else 0 end) AS firecodeint,(case when (ri.revtype = 'firecode') then ri.discount else 0 end) AS firecodedisc,(case when (ri.revtype = 'firecode') then (ri.interest - ri.discount) else 0 end) AS firecodedp,(case when (ri.revtype = 'firecode') then ((ri.amount + ri.interest) - ri.discount) else 0 end) AS firecodenet,(case when (ri.revtype = 'sh') then ri.amount else 0 end) AS sh,(case when (ri.revtype = 'sh') then ri.interest else 0 end) AS shint,(case when (ri.revtype = 'sh') then ri.discount else 0 end) AS shdisc,(case when (ri.revtype = 'sh') then (ri.interest - ri.discount) else 0 end) AS shdp,(case when (ri.revtype = 'sh') then ((ri.amount + ri.interest) - ri.discount) else 0 end) AS shnet,((ri.amount + ri.interest) - ri.discount) AS total from (report_rptdelinquency_item ri join report_rptdelinquency r on((ri.parentid = r.objid)))
go

CREATE VIEW vw_landtax_report_rptdelinquency AS select ri.objid AS objid,ri.rptledgerid AS rptledgerid,ri.barangayid AS barangayid,ri.year AS year,ri.qtr AS qtr,r.dtgenerated AS dtgenerated,r.dtcomputed AS dtcomputed,r.generatedby_name AS generatedby_name,r.generatedby_title AS generatedby_title,(case when (ri.revtype = 'basic') then ri.amount else 0 end) AS basic,(case when (ri.revtype = 'basic') then ri.interest else 0 end) AS basicint,(case when (ri.revtype = 'basic') then ri.discount else 0 end) AS basicdisc,(case when (ri.revtype = 'basic') then (ri.interest - ri.discount) else 0 end) AS basicdp,(case when (ri.revtype = 'basic') then ((ri.amount + ri.interest) - ri.discount) else 0 end) AS basicnet,(case when (ri.revtype = 'basicidle') then ri.amount else 0 end) AS basicidle,(case when (ri.revtype = 'basicidle') then ri.interest else 0 end) AS basicidleint,(case when (ri.revtype = 'basicidle') then ri.discount else 0 end) AS basicidledisc,(case when (ri.revtype = 'basicidle') then (ri.interest - ri.discount) else 0 end) AS basicidledp,(case when (ri.revtype = 'basicidle') then ((ri.amount + ri.interest) - ri.discount) else 0 end) AS basicidlenet,(case when (ri.revtype = 'sef') then ri.amount else 0 end) AS sef,(case when (ri.revtype = 'sef') then ri.interest else 0 end) AS sefint,(case when (ri.revtype = 'sef') then ri.discount else 0 end) AS sefdisc,(case when (ri.revtype = 'sef') then (ri.interest - ri.discount) else 0 end) AS sefdp,(case when (ri.revtype = 'sef') then ((ri.amount + ri.interest) - ri.discount) else 0 end) AS sefnet,(case when (ri.revtype = 'firecode') then ri.amount else 0 end) AS firecode,(case when (ri.revtype = 'firecode') then ri.interest else 0 end) AS firecodeint,(case when (ri.revtype = 'firecode') then ri.discount else 0 end) AS firecodedisc,(case when (ri.revtype = 'firecode') then (ri.interest - ri.discount) else 0 end) AS firecodedp,(case when (ri.revtype = 'firecode') then ((ri.amount + ri.interest) - ri.discount) else 0 end) AS firecodenet,(case when (ri.revtype = 'sh') then ri.amount else 0 end) AS sh,(case when (ri.revtype = 'sh') then ri.interest else 0 end) AS shint,(case when (ri.revtype = 'sh') then ri.discount else 0 end) AS shdisc,(case when (ri.revtype = 'sh') then (ri.interest - ri.discount) else 0 end) AS shdp,(case when (ri.revtype = 'sh') then ((ri.amount + ri.interest) - ri.discount) else 0 end) AS shnet,((ri.amount + ri.interest) - ri.discount) AS total from (report_rptdelinquency_item ri join report_rptdelinquency r on((ri.parentid = r.objid)))
go

CREATE VIEW vw_machine_smv AS select ms.objid AS objid,ms.parent_objid AS parent_objid,ms.machine_objid AS machine_objid,ms.expr AS expr,ms.previd AS previd,m.code AS code,m.name AS name from (machine_smv ms join machine m on((ms.machine_objid = m.objid)))
go

CREATE VIEW vw_rptcertification_item AS select rci.rptcertificationid AS rptcertificationid,f.objid AS faasid,f.fullpin AS fullpin,f.tdno AS tdno,e.objid AS taxpayerid,e.name AS taxpayer_name,f.owner_name AS owner_name,f.administrator_name AS administrator_name,f.titleno AS titleno,f.rpuid AS rpuid,pc.code AS classcode,pc.name AS classname,so.name AS lguname,b.name AS barangay,r.rputype AS rputype,r.suffix AS suffix,r.totalareaha AS totalareaha,r.totalareasqm AS totalareasqm,r.totalav AS totalav,r.totalmv AS totalmv,rp.street AS street,rp.blockno AS blockno,rp.cadastrallotno AS cadastrallotno,rp.surveyno AS surveyno,r.taxable AS taxable,f.effectivityyear AS effectivityyear,f.effectivityqtr AS effectivityqtr from (((((((rptcertificationitem rci join faas f on((rci.refid = f.objid))) join rpu r on((f.rpuid = r.objid))) join propertyclassification pc on((r.classification_objid = pc.objid))) join realproperty rp on((f.realpropertyid = rp.objid))) join barangay b on((rp.barangayid = b.objid))) join sys_org so on((f.lguid = so.objid))) join entity e on((f.taxpayer_objid = e.objid)))
go

CREATE VIEW vw_rptledger_avdifference AS select rlf.objid AS objid,'APPROVED' AS state,d.parent_objid AS rptledgerid,rl.faasid AS faasid,rl.tdno AS tdno,rlf.txntype_objid AS txntype_objid,rlf.classification_objid AS classification_objid,rlf.actualuse_objid AS actualuse_objid,rlf.taxable AS taxable,rlf.backtax AS backtax,d.year AS fromyear,1 AS fromqtr,d.year AS toyear,4 AS toqtr,d.av AS assessedvalue,1 AS systemcreated,rlf.reclassed AS reclassed,rlf.idleland AS idleland,1 AS taxdifference from ((rptledger_avdifference d join rptledgerfaas rlf on((d.rptledgerfaas_objid = rlf.objid))) join rptledger rl on((d.parent_objid = rl.objid)))
go

CREATE VIEW vw_rptpayment_item_detail AS select rpi.objid AS objid,rpi.parentid AS parentid,rpi.rptledgerfaasid AS rptledgerfaasid,rpi.year AS year,rpi.qtr AS qtr,rpi.revperiod AS revperiod,(case when (rpi.revtype = 'basic') then rpi.amount else 0 end) AS basic,(case when (rpi.revtype = 'basic') then rpi.interest else 0 end) AS basicint,(case when (rpi.revtype = 'basic') then rpi.discount else 0 end) AS basicdisc,(case when (rpi.revtype = 'basic') then (rpi.interest - rpi.discount) else 0 end) AS basicdp,(case when (rpi.revtype = 'basic') then ((rpi.amount + rpi.interest) - rpi.discount) else 0 end) AS basicnet,(case when (rpi.revtype = 'basicidle') then ((rpi.amount + rpi.interest) - rpi.discount) else 0 end) AS basicidle,(case when (rpi.revtype = 'basicidle') then rpi.interest else 0 end) AS basicidleint,(case when (rpi.revtype = 'basicidle') then rpi.discount else 0 end) AS basicidledisc,(case when (rpi.revtype = 'basicidle') then (rpi.interest - rpi.discount) else 0 end) AS basicidledp,(case when (rpi.revtype = 'sef') then rpi.amount else 0 end) AS sef,(case when (rpi.revtype = 'sef') then rpi.interest else 0 end) AS sefint,(case when (rpi.revtype = 'sef') then rpi.discount else 0 end) AS sefdisc,(case when (rpi.revtype = 'sef') then (rpi.interest - rpi.discount) else 0 end) AS sefdp,(case when (rpi.revtype = 'sef') then ((rpi.amount + rpi.interest) - rpi.discount) else 0 end) AS sefnet,(case when (rpi.revtype = 'firecode') then ((rpi.amount + rpi.interest) - rpi.discount) else 0 end) AS firecode,(case when (rpi.revtype = 'sh') then ((rpi.amount + rpi.interest) - rpi.discount) else 0 end) AS sh,(case when (rpi.revtype = 'sh') then rpi.interest else 0 end) AS shint,(case when (rpi.revtype = 'sh') then rpi.discount else 0 end) AS shdisc,(case when (rpi.revtype = 'sh') then (rpi.interest - rpi.discount) else 0 end) AS shdp,(case when (rpi.revtype = 'sh') then ((rpi.amount + rpi.interest) - rpi.discount) else 0 end) AS shnet,((rpi.amount + rpi.interest) - rpi.discount) AS amount,rpi.partialled AS partialled from rptpayment_item rpi
go

CREATE VIEW vw_rptpayment_item AS select x.parentid AS parentid,x.rptledgerfaasid AS rptledgerfaasid,x.year AS year,x.qtr AS qtr,x.revperiod AS revperiod,sum(x.basic) AS basic,sum(x.basicint) AS basicint,sum(x.basicdisc) AS basicdisc,sum(x.basicdp) AS basicdp,sum(x.basicnet) AS basicnet,sum(x.basicidle) AS basicidle,sum(x.basicidleint) AS basicidleint,sum(x.basicidledisc) AS basicidledisc,sum(x.basicidledp) AS basicidledp,sum(x.sef) AS sef,sum(x.sefint) AS sefint,sum(x.sefdisc) AS sefdisc,sum(x.sefdp) AS sefdp,sum(x.sefnet) AS sefnet,sum(x.firecode) AS firecode,sum(x.sh) AS sh,sum(x.shint) AS shint,sum(x.shdisc) AS shdisc,sum(x.shdp) AS shdp,sum(x.amount) AS amount,max(x.partialled) AS partialled from vw_rptpayment_item_detail x group by x.parentid,x.rptledgerfaasid,x.year,x.qtr,x.revperiod
go

CREATE VIEW vw_rpu_assessment AS select r.objid AS objid,r.rputype AS rputype,dpc.objid AS dominantclass_objid,dpc.code AS dominantclass_code,dpc.name AS dominantclass_name,dpc.orderno AS dominantclass_orderno,ra.areasqm AS areasqm,ra.areaha AS areaha,ra.marketvalue AS marketvalue,ra.assesslevel AS assesslevel,ra.assessedvalue AS assessedvalue,ra.taxable AS taxable,au.code AS actualuse_code,au.name AS actualuse_name,auc.objid AS actualuse_objid,auc.code AS actualuse_classcode,auc.name AS actualuse_classname,auc.orderno AS actualuse_orderno from ((((rpu r join propertyclassification dpc on((r.classification_objid = dpc.objid))) join rpu_assessment ra on((r.objid = ra.rpuid))) join landassesslevel au on((ra.actualuse_objid = au.objid))) left join propertyclassification auc on((au.classification_objid = auc.objid))) union select r.objid AS objid,r.rputype AS rputype,dpc.objid AS dominantclass_objid,dpc.code AS dominantclass_code,dpc.name AS dominantclass_name,dpc.orderno AS dominantclass_orderno,ra.areasqm AS areasqm,ra.areaha AS areaha,ra.marketvalue AS marketvalue,ra.assesslevel AS assesslevel,ra.assessedvalue AS assessedvalue,ra.taxable AS taxable,au.code AS actualuse_code,au.name AS actualuse_name,auc.objid AS actualuse_objid,auc.code AS actualuse_classcode,auc.name AS actualuse_classname,auc.orderno AS actualuse_orderno from ((((rpu r join propertyclassification dpc on((r.classification_objid = dpc.objid))) join rpu_assessment ra on((r.objid = ra.rpuid))) join bldgassesslevel au on((ra.actualuse_objid = au.objid))) left join propertyclassification auc on((au.classification_objid = auc.objid))) union select r.objid AS objid,r.rputype AS rputype,dpc.objid AS dominantclass_objid,dpc.code AS dominantclass_code,dpc.name AS dominantclass_name,dpc.orderno AS dominantclass_orderno,ra.areasqm AS areasqm,ra.areaha AS areaha,ra.marketvalue AS marketvalue,ra.assesslevel AS assesslevel,ra.assessedvalue AS assessedvalue,ra.taxable AS taxable,au.code AS actualuse_code,au.name AS actualuse_name,auc.objid AS actualuse_objid,auc.code AS actualuse_classcode,auc.name AS actualuse_classname,auc.orderno AS actualuse_orderno from ((((rpu r join propertyclassification dpc on((r.classification_objid = dpc.objid))) join rpu_assessment ra on((r.objid = ra.rpuid))) join machassesslevel au on((ra.actualuse_objid = au.objid))) left join propertyclassification auc on((au.classification_objid = auc.objid))) union select r.objid AS objid,r.rputype AS rputype,dpc.objid AS dominantclass_objid,dpc.code AS dominantclass_code,dpc.name AS dominantclass_name,dpc.orderno AS dominantclass_orderno,ra.areasqm AS areasqm,ra.areaha AS areaha,ra.marketvalue AS marketvalue,ra.assesslevel AS assesslevel,ra.assessedvalue AS assessedvalue,ra.taxable AS taxable,au.code AS actualuse_code,au.name AS actualuse_name,auc.objid AS actualuse_objid,auc.code AS actualuse_classcode,auc.name AS actualuse_classname,auc.orderno AS actualuse_orderno from ((((rpu r join propertyclassification dpc on((r.classification_objid = dpc.objid))) join rpu_assessment ra on((r.objid = ra.rpuid))) join planttreeassesslevel au on((ra.actualuse_objid = au.objid))) left join propertyclassification auc on((au.classification_objid = auc.objid))) union select r.objid AS objid,r.rputype AS rputype,dpc.objid AS dominantclass_objid,dpc.code AS dominantclass_code,dpc.name AS dominantclass_name,dpc.orderno AS dominantclass_orderno,ra.areasqm AS areasqm,ra.areaha AS areaha,ra.marketvalue AS marketvalue,ra.assesslevel AS assesslevel,ra.assessedvalue AS assessedvalue,ra.taxable AS taxable,au.code AS actualuse_code,au.name AS actualuse_name,auc.objid AS actualuse_objid,auc.code AS actualuse_classcode,auc.name AS actualuse_classname,auc.orderno AS actualuse_orderno from ((((rpu r join propertyclassification dpc on((r.classification_objid = dpc.objid))) join rpu_assessment ra on((r.objid = ra.rpuid))) join miscassesslevel au on((ra.actualuse_objid = au.objid))) left join propertyclassification auc on((au.classification_objid = auc.objid)))
go

CREATE VIEW vw_txn_log AS select distinct u.objid AS userid,u.name AS username,t.txndate AS txndate,t.ref AS ref,t.action AS action,1 AS cnt from (txnlog t join sys_user u on((t.userid = u.objid))) union select u.objid AS userid,u.name AS username,t.enddate AS txndate,'faas' AS ref,(case when (t.state like '%receiver%') then 'receive' when (t.state like '%examiner%') then 'examine' when (t.state like '%taxmapper_chief%') then 'approve taxmap' when (t.state like '%taxmapper%') then 'taxmap' when (t.state like '%appraiser%') then 'appraise' when (t.state like '%appraiser_chief%') then 'approve appraisal' when (t.state like '%recommender%') then 'recommend' when (t.state like '%approver%') then 'approve' else t.state end) AS action,1 AS cnt from (faas_task t join sys_user u on((t.actor_objid = u.objid))) where (not((t.state like '%assign%'))) union select u.objid AS userid,u.name AS username,t.enddate AS txndate,'subdivision' AS ref,(case when (t.state like '%receiver%') then 'receive' when (t.state like '%examiner%') then 'examine' when (t.state like '%taxmapper_chief%') then 'approve taxmap' when (t.state like '%taxmapper%') then 'taxmap' when (t.state like '%appraiser%') then 'appraise' when (t.state like '%appraiser_chief%') then 'approve appraisal' when (t.state like '%recommender%') then 'recommend' when (t.state like '%approver%') then 'approve' else t.state end) AS action,1 AS cnt from (subdivision_task t join sys_user u on((t.actor_objid = u.objid))) where (not((t.state like '%assign%'))) union select u.objid AS userid,u.name AS username,t.enddate AS txndate,'consolidation' AS ref,(case when (t.state like '%receiver%') then 'receive' when (t.state like '%examiner%') then 'examine' when (t.state like '%taxmapper_chief%') then 'approve taxmap' when (t.state like '%taxmapper%') then 'taxmap' when (t.state like '%appraiser%') then 'appraise' when (t.state like '%appraiser_chief%') then 'approve appraisal' when (t.state like '%recommender%') then 'recommend' when (t.state like '%approver%') then 'approve' else t.state end) AS action,1 AS cnt from (subdivision_task t join sys_user u on((t.actor_objid = u.objid))) where (not((t.state like '%consolidation%'))) union select u.objid AS userid,u.name AS username,t.enddate AS txndate,'cancelledfaas' AS ref,(case when (t.state like '%receiver%') then 'receive' when (t.state like '%examiner%') then 'examine' when (t.state like '%taxmapper_chief%') then 'approve taxmap' when (t.state like '%taxmapper%') then 'taxmap' when (t.state like '%appraiser%') then 'appraise' when (t.state like '%appraiser_chief%') then 'approve appraisal' when (t.state like '%recommender%') then 'recommend' when (t.state like '%approver%') then 'approve' else t.state end) AS action,1 AS cnt from (subdivision_task t join sys_user u on((t.actor_objid = u.objid))) where (not((t.state like '%cancelledfaas%')))
go



