INSERT INTO sys_usergroup ([objid], title, domain, userclass, orgclass, [role]) VALUES ('RPT.CERTIFICATION_APPROVER', 'CERTIFICATION_APPROVER', 'RPT', NULL, NULL, 'CERTIFICATION_APPROVER')
GO 
INSERT INTO sys_usergroup ([objid], title, domain, userclass, orgclass, [role]) VALUES ('RPT.CERTIFICATION_ISSUER', 'CERTIFICATION_ISSUER', 'RPT', 'usergroup', NULL, 'CERTIFICATION_ISSUER')
GO 
INSERT INTO sys_usergroup ([objid], title, domain, userclass, orgclass, [role]) VALUES ('RPT.CERTIFICATION_VERIFIER', 'RPT CERTIFICATION_VERIFIER', 'RPT', NULL, NULL, 'CERTIFICATION_VERIFIER')
GO 

delete from sys_wf_transition where processname= 'rptcertification'
go 
delete from sys_wf_node where processname= 'rptcertification'
go 


INSERT INTO sys_wf_node ([name], processname, title, nodetype, idx, salience, [domain], [role], properties, ui, tracktime) VALUES ('start', 'rptcertification', 'Start', 'start', '1', NULL, NULL, NULL, '[:]', '[fillColor:''#00ff00'',size:[32,32],pos:[102,127],type:''start'']', NULL)
go
INSERT INTO sys_wf_node ([name], processname, title, nodetype, idx, salience, [domain], [role], properties, ui, tracktime) VALUES ('receiver', 'rptcertification', 'Receiver', 'state', '2', NULL, 'RPT', 'CERTIFICATION_ISSUER', '[:]', '[fillColor:''#c0c0c0'',size:[114,40],pos:[206,127],type:''state'']', '1')
go
INSERT INTO sys_wf_node ([name], processname, title, nodetype, idx, salience, [domain], [role], properties, ui, tracktime) VALUES ('verifier', 'rptcertification', 'Verifier', 'state', '3', NULL, 'RPT', 'CERTIFICATION_VERIFIER', '[:]', '[fillColor:''#c0c0c0'',size:[129,44],pos:[412,127],type:''state'']', '1')
go
INSERT INTO sys_wf_node ([name], processname, title, nodetype, idx, salience, [domain], [role], properties, ui, tracktime) VALUES ('approver', 'rptcertification', 'Approver', 'state', '4', NULL, 'RPT', 'CERTIFICATION_APPROVER', '[:]', '[fillColor:''#c0c0c0'',size:[118,42],pos:[604,141],type:''state'']', '1')
go
INSERT INTO sys_wf_node ([name], processname, title, nodetype, idx, salience, [domain], [role], properties, ui, tracktime) VALUES ('approved', 'rptcertification', 'Approved', 'end', '5', NULL, NULL, NULL, '[:]', '[fillColor:''#ff0000'',size:[32,32],pos:[797,148],type:''end'']', NULL)
go

INSERT INTO sys_wf_transition (parentid, processname, [action], [to], idx, eval, properties, permission, caption, ui) VALUES ('start', 'rptcertification', 'assign', 'receiver', '1', NULL, '[:]', NULL, 'Assign', '[size:[72,0],pos:[134,142],type:''arrow'',points:[134,142,206,142]]')
go
INSERT INTO sys_wf_transition (parentid, processname, [action], [to], idx, eval, properties, permission, caption, ui) VALUES ('receiver', 'rptcertification', 'cancelissuance', 'end', '5', NULL, '[caption:''Cancel Issuance'', confirm:''Cancel issuance?'',closeonend:true]', NULL, 'Cancel Issuance', '[size:[559,116],pos:[258,32],type:''arrow'',points:[262,127,258,32,817,40,813,148]]')
go
INSERT INTO sys_wf_transition (parentid, processname, [action], [to], idx, eval, properties, permission, caption, ui) VALUES ('receiver', 'rptcertification', 'submit', 'verifier', '6', NULL, '[caption:''Submit to Verifier'', confirm:''Submit to verifier?'', messagehandler:''rptmessage:info'',targetrole:''RPT.CERTIFICATION_VERIFIER'']', NULL, 'Submit to Verifier', '[size:[92,0],pos:[320,146],type:''arrow'',points:[320,146,412,146]]')
go
INSERT INTO sys_wf_transition (parentid, processname, [action], [to], idx, eval, properties, permission, caption, ui) VALUES ('verifier', 'rptcertification', 'return_receiver', 'receiver', '10', NULL, '[caption:''Return to Issuer'', confirm:''Return to issuer?'', messagehandler:''default'']', NULL, 'Return to Receiver', '[size:[160,63],pos:[292,64],type:''arrow'',points:[452,127,385,64,292,127]]')
go
INSERT INTO sys_wf_transition (parentid, processname, [action], [to], idx, eval, properties, permission, caption, ui) VALUES ('verifier', 'rptcertification', 'submit', 'approver', '11', NULL, '[caption:''Submit for Approval'', confirm:''Submit for approval?'', messagehandler:''rptmessage:sign'',targetrole:''RPT.CERTIFICATION_APPROVER'']', NULL, 'Submit to Approver', '[size:[63,4],pos:[541,152],type:''arrow'',points:[541,152,604,156]]')
go
INSERT INTO sys_wf_transition (parentid, processname, [action], [to], idx, eval, properties, permission, caption, ui) VALUES ('approver', 'rptcertification', 'return_receiver', 'receiver', '15', NULL, '[caption:''Return to Issuer'', confirm:''Return to issuer?'', messagehandler:''default'']', NULL, 'Return to Receiver', '[size:[333,113],pos:[285,167],type:''arrow'',points:[618,183,414,280,285,167]]')
go
INSERT INTO sys_wf_transition (parentid, processname, [action], [to], idx, eval, properties, permission, caption, ui) VALUES ('approver', 'rptcertification', 'submit', 'approved', '16', NULL, '[caption:''Approve'', confirm:''Approve?'', messagehandler:''rptmessage:sign'']', NULL, 'Approve', '[size:[75,0],pos:[722,162],type:''arrow'',points:[722,162,797,162]]')
go



CREATE TABLE rptcertification_task (
  objid varchar(50) NOT NULL DEFAULT '',
  refid varchar(50) DEFAULT NULL,
  parentprocessid varchar(50) DEFAULT NULL,
  [state] varchar(50) DEFAULT NULL,
  startdate datetime DEFAULT NULL,
  enddate datetime DEFAULT NULL,
  assignee_objid varchar(50) DEFAULT NULL,
  assignee_name varchar(100) DEFAULT NULL,
  assignee_title varchar(80) DEFAULT NULL,
  actor_objid varchar(50) DEFAULT NULL,
  actor_name varchar(100) DEFAULT NULL,
  actor_title varchar(80) DEFAULT NULL,
  [message] varchar(255) DEFAULT NULL,
  [signature] text,
  returnedby varchar(100) DEFAULT NULL,
  PRIMARY KEY (objid)
  
) 
go 

create index ix_refid on rptcertification_task (refid)
go 
create index ix_assignee_objid on rptcertification_task (assignee_objid)
go 
alter table rptcertification_task add CONSTRAINT fk_rptcertification_task FOREIGN KEY (refid) REFERENCES rptcertification (objid)
go



alter table rptcertification add taskid varchar(50)
go 


if exists(select * from sysobjects where id = OBJECT_ID('vw_online_rptcertification')) 
begin
  drop view vw_online_rptcertification
end 
go 

create view vw_online_rptcertification
as 
select
	c.objid,
	c.txnno,
	c.txndate,
	c.opener,
	c.taxpayer_objid,
	c.taxpayer_name,
	c.taxpayer_address,
	c.requestedby,
	c.requestedbyaddress,
	c.certifiedby,
	c.certifiedbytitle,
	c.official,
	c.purpose,
	c.orno,
	c.ordate,
	c.oramount,
	c.taskid,
	t.state as task_state,
	t.startdate as task_startdate,
	t.enddate as task_enddate,
	t.assignee_objid as task_assignee_objid,
	t.assignee_name as task_assignee_name,
	t.actor_objid as task_actor_objid,
	t.actor_name as task_actor_name
from rptcertification c
inner join rptcertification_task t on c.taskid = t.objid
go 


