-- ## 2020-12-22
alter table online_business_application add 
	contact_name varchar(255) not null, 
	contact_address varchar(255) not null, 
	contact_email varchar(255) not null, 
	contact_mobileno varchar(15) null 
go 




-- ## 2020-12-23
alter table business_recurringfee add txntype_objid varchar(50) null 
go 

create index ix_txntype_objid on business_recurringfee  (txntype_objid)
go 

alter table business_recurringfee add constraint fk_business_recurringfee_txntype_objid 
  foreign key (txntype_objid) references business_billitem_txntype (objid)
go 




-- ## 2020-12-24

select 'BPLS' as domain, 'OBO' as role, t1.*, 
	(select title from itemaccount where objid = t1.acctid) as title, 
	(
		select top 1 r.taxfeetype 
		from business_receivable r, business_application a 
		where r.account_objid = t1.acctid 
			and a.objid = r.applicationid 
		order by a.txndate desc 
	) as feetype 
into ztmp_fix_business_billitem_txntype 
from ( select distinct account_objid as acctid from business_recurringfee )t1 
where t1.acctid not in ( 
	select acctid from business_billitem_txntype where acctid = t1.acctid 
) 
go 

insert into business_billitem_txntype (
	objid, title, acctid, feetype, domain, role
) 
select 
	acctid, title, acctid, feetype, domain, role
from ztmp_fix_business_billitem_txntype
go 

update aa set 
	aa.txntype_objid = (
		select top 1 objid 
		from business_billitem_txntype 
		where acctid = aa.account_objid 
	) 
from business_recurringfee aa 
where aa.txntype_objid is null 
go 

drop table ztmp_fix_business_billitem_txntype
go 



alter table online_business_application add partnername varchar(50) not null 
go




-- ## 2021-01-05
if object_id('dbo.vw_collectionvoucher_cashreceiptitem', 'V') IS NOT NULL
	drop view vw_collectionvoucher_cashreceiptitem; 
go 
if object_id('dbo.vw_remittance_cashreceiptitem', 'V') IS NOT NULL
    drop view vw_remittance_cashreceiptitem
go 

create view vw_remittance_cashreceiptitem AS 
select 
  c.remittanceid AS remittanceid, 
  r.controldate AS remittance_controldate, 
  r.controlno AS remittance_controlno, 
  r.collectionvoucherid AS collectionvoucherid, 
  c.collectiontype_objid AS collectiontype_objid, 
  c.collectiontype_name AS collectiontype_name, 
  c.org_objid AS org_objid, 
  c.org_name AS org_name, 
  c.formtype AS formtype, 
  c.formno AS formno, 
  cri.receiptid AS receiptid, 
  c.receiptdate AS receiptdate, 
  c.receiptno AS receiptno, 
  c.controlid as controlid, 
  c.series as series, 
  c.stub as stubno, 
  c.paidby AS paidby, 
  c.paidbyaddress AS paidbyaddress, 
  c.collector_objid AS collectorid, 
  c.collector_name AS collectorname, 
  c.collector_title AS collectortitle, 
  cri.item_fund_objid AS fundid, 
  cri.item_objid AS acctid, 
  cri.item_code AS acctcode, 
  cri.item_title AS acctname, 
  cri.remarks AS remarks, 
  (case when v.objid is null then cri.amount else 0.0 end) AS amount, 
  (case when v.objid is null then 0 else 1 end) AS voided, 
  (case when v.objid is null then 0.0 else cri.amount end) AS voidamount,   
  (case when (c.formtype = 'serial') then 0 else 1 end) AS formtypeindex
from remittance r 
  inner join cashreceipt c on c.remittanceid = r.objid 
  inner join cashreceiptitem cri on cri.receiptid = c.objid 
  left join cashreceipt_void v on v.receiptid = c.objid 
go 

create view vw_collectionvoucher_cashreceiptitem AS 
select 
  cv.controldate AS collectionvoucher_controldate, 
  cv.controlno AS collectionvoucher_controlno, 
  v.*  
from collectionvoucher cv 
  inner join vw_remittance_cashreceiptitem v on v.collectionvoucherid = cv.objid 
go 



if object_id('dbo.vw_collectionvoucher_cashreceiptshare', 'V') IS NOT NULL
	drop view vw_collectionvoucher_cashreceiptshare
go 

if object_id('dbo.vw_remittance_cashreceiptshare', 'V') IS NOT NULL
	drop view vw_remittance_cashreceiptshare
go 

create view vw_remittance_cashreceiptshare AS 
select 
	c.remittanceid AS remittanceid, 
	r.controldate AS remittance_controldate, 
	r.controlno AS remittance_controlno, 
	r.collectionvoucherid AS collectionvoucherid, 
	c.formno AS formno, 
	c.formtype AS formtype, 
  c.controlid as controlid, 
	cs.receiptid AS receiptid, 
	c.receiptdate AS receiptdate, 
	c.receiptno AS receiptno, 
	c.paidby AS paidby, 
	c.paidbyaddress AS paidbyaddress, 
	c.org_objid AS org_objid, 
	c.org_name AS org_name, 
	c.collectiontype_objid AS collectiontype_objid, 
	c.collectiontype_name AS collectiontype_name, 
	c.collector_objid AS collectorid, 
	c.collector_name AS collectorname, 
	c.collector_title AS collectortitle, 
	cs.refitem_objid AS refacctid, 
	ia.fund_objid AS fundid, 
	ia.objid AS acctid, 
	ia.code AS acctcode, 
	ia.title AS acctname, 
	(case when v.objid is null then cs.amount else 0.0 end) AS amount, 
	(case when v.objid is null then 0 else 1 end) AS voided, 
	(case when v.objid is null then 0.0 else cs.amount end) AS voidamount, 
	(case when (c.formtype = 'serial') then 0 else 1 end) AS formtypeindex  
from remittance r 
	inner join cashreceipt c on c.remittanceid = r.objid 
	inner join cashreceipt_share cs on cs.receiptid = c.objid 
	inner join itemaccount ia on ia.objid = cs.payableitem_objid 
	left join cashreceipt_void v on v.receiptid = c.objid 
go 

create view vw_collectionvoucher_cashreceiptshare AS 
select 
  cv.controldate AS collectionvoucher_controldate, 
  cv.controlno AS collectionvoucher_controlno, 
  v.* 
from collectionvoucher cv 
  inner join vw_remittance_cashreceiptshare v on v.collectionvoucherid = cv.objid 
go 




if object_id('dbo.vw_remittance_cashreceiptpayment_noncash', 'V') IS NOT NULL
  drop view vw_remittance_cashreceiptpayment_noncash
go 

create view vw_remittance_cashreceiptpayment_noncash AS 
select 
  nc.objid AS objid, 
  nc.receiptid AS receiptid, 
  nc.refno AS refno, 
  nc.refdate AS refdate, 
  nc.reftype AS reftype, 
  nc.particulars AS particulars, 
  nc.fund_objid as fundid, 
  nc.refid AS refid, 
  nc.amount AS amount, 
  (case when v.objid is null then 0 else 1 end) AS voided, 
  (case when v.objid is null then 0.0 else nc.amount end) AS voidamount, 
  cp.bankid AS bankid, 
  cp.bank_name AS bank_name, 
  c.remittanceid AS remittanceid, 
  r.collectionvoucherid AS collectionvoucherid  
from remittance r 
  inner join cashreceipt c on c.remittanceid = r.objid 
  inner join cashreceiptpayment_noncash nc on (nc.receiptid = c.objid and nc.reftype = 'CHECK') 
  inner join checkpayment cp on cp.objid = nc.refid 
  left join cashreceipt_void v on v.receiptid = c.objid 
union all 
select 
  nc.objid AS objid, 
  nc.receiptid AS receiptid, 
  nc.refno AS refno, 
  nc.refdate AS refdate, 
  'EFT' AS reftype, 
  nc.particulars AS particulars, 
  nc.fund_objid as fundid, 
  nc.refid AS refid, 
  nc.amount AS amount, 
  (case when v.objid is null then 0 else 1 end) AS voided, 
  (case when v.objid is null then 0.0 else nc.amount end) AS voidamount, 
  ba.bank_objid AS bankid, 
  ba.bank_name AS bank_name, 
  c.remittanceid AS remittanceid, 
  r.collectionvoucherid AS collectionvoucherid  
from remittance r 
  inner join cashreceipt c on c.remittanceid = r.objid 
  inner join cashreceiptpayment_noncash nc on (nc.receiptid = c.objid and nc.reftype = 'EFT') 
  inner join eftpayment eft on eft.objid = nc.refid 
  inner join bankaccount ba on ba.objid = eft.bankacctid 
  left join cashreceipt_void v on v.receiptid = c.objid 
go 




-- ## 2021-01-08
INSERT INTO sys_ruleset (name, title, packagename, domain, role, permission) 
VALUES ('firebpassessment', 'Fire Assessment Rules', NULL, 'bpls', 'DATAMGMT', NULL);

INSERT INTO sys_rulegroup (name, ruleset, title, sortorder) 
VALUES ('firefee', 'firebpassessment', 'Fire Fee Computation', '0');

INSERT INTO sys_rulegroup (name, ruleset, title, sortorder) 
VALUES ('postfirefee', 'firebpassessment', 'Post Fire Fee Computation', '1');

insert into sys_ruleset_actiondef (
	ruleset, actiondef 
) 
select t1.* 
from ( 
	select 'firebpassessment' as ruleset, actiondef 
	from sys_ruleset_actiondef 
	where ruleset='bpassessment'
)t1 
	left join sys_ruleset_actiondef a on (a.ruleset = t1.ruleset and a.actiondef = t1.actiondef) 
where a.ruleset is null 
; 

insert into sys_ruleset_fact (
	ruleset, rulefact  
) 
select t1.* 
from ( 
	select 'firebpassessment' as ruleset, rulefact  
	from sys_ruleset_fact 
	where ruleset='bpassessment'
)t1 
	left join sys_ruleset_fact a on (a.ruleset = t1.ruleset and a.rulefact = t1.rulefact) 
where a.ruleset is null 
; 




CREATE TABLE sys_domain (
  name varchar(50) NOT NULL,
  connection varchar(50) NOT NULL,
  constraint pk_sys_domain PRIMARY KEY (name)
) 
go 




-- ## 2021-01-11
alter table business add lockid varchar(50) null 
go 




-- ## 2021-01-16

INSERT INTO sys_usergroup (objid, title, domain, userclass, orgclass, role) 
VALUES ('BPLS.ONLINE_DATA_APPROVER', 'BPLS - ONLINE DATA APPROVER', 'BPLS', 'usergroup', NULL, 'ONLINE_DATA_APPROVER')
go 


if object_id('dbo.vw_online_business_application', 'V') IS NOT NULL 
	drop view dbo.vw_online_business_application; 
go 
CREATE VIEW vw_online_business_application AS 
select 
  oa.objid AS objid, 
  oa.state AS state, 
  oa.dtcreated AS dtcreated, 
  oa.createdby_objid AS createdby_objid, 
  oa.createdby_name AS createdby_name, 
  oa.controlno AS controlno, 
  oa.apptype AS apptype, 
  oa.appyear AS appyear, 
  oa.appdate AS appdate, 
  oa.prevapplicationid AS prevapplicationid, 
  oa.business_objid AS business_objid, 
  b.bin AS bin, 
  b.tradename AS tradename, 
  b.businessname AS businessname, 
  b.address_text AS address_text, 
  b.address_objid AS address_objid, 
  b.owner_name AS owner_name, 
  b.owner_address_text AS owner_address_text, 
  b.owner_address_objid AS owner_address_objid, 
  b.yearstarted AS yearstarted, 
  b.orgtype AS orgtype, 
  b.permittype AS permittype, 
  b.officetype AS officetype, 
  oa.step AS step 
from online_business_application oa 
  inner join business_application a on a.objid = oa.prevapplicationid 
  inner join business b on b.objid = a.business_objid
go 




-- ## 2021-01-31

alter table cashreceipt_share add receiptitemid varchar(50) null 
go

create index ix_receiptitemid on cashreceipt_share (receiptitemid) 
go

