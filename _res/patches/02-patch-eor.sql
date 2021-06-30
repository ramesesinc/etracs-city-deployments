-- ## 2021-01-14

alter table eor add lockid varchar(50) null 
; 

create index ix_lockid on eor (lockid) 
;


alter table eor_remittance add lockid varchar(50) null 
; 


alter table eor_share add receiptitemid varchar(50) null 
; 



drop view if exists vw_remittance_eor_item
; 
CREATE VIEW vw_remittance_eor_item AS 
select 
	c.remittanceid AS remittanceid,
	r.controldate AS remittance_controldate,
	r.controlno AS remittance_controlno,
	cri.parentid AS receiptid,
	c.receiptdate AS receiptdate,
	c.receiptno AS receiptno,
	c.paidby AS paidby,
	c.paidbyaddress AS paidbyaddress,
	cri.item_fund_objid AS fundid,
	cri.item_objid AS acctid,
	cri.item_code AS acctcode,
	cri.item_title AS acctname,
	cri.remarks AS remarks,
	cri.amount AS amount,
	c.txntype 
from eor_remittance r 
	inner join eor c on c.remittanceid = r.objid 
	inner join eor_item cri on cri.parentid = c.objid
;


drop view if exists vw_remittance_eor_share
; 
CREATE VIEW vw_remittance_eor_share AS 
select 
	c.remittanceid AS remittanceid,
	r.controldate AS remittance_controldate,
	r.controlno AS remittance_controlno,
	cri.parentid AS receiptid,
	c.receiptdate AS receiptdate,
	c.receiptno AS receiptno,
	c.paidby AS paidby,
	c.paidbyaddress AS paidbyaddress,
	cri.refitem_objid AS refacctid,
	cri.refitem_code AS refacctcode,
	cri.refitem_title AS refaccttitle,
	cri.payableitem_objid AS acctid,
	cri.payableitem_code AS acctcode,
	cri.payableitem_title AS acctname,
	cri.share AS amount,
	c.txntype  
from eor_remittance r 
	inner join eor c on c.remittanceid = r.objid 
	inner join eor_share cri on cri.parentid = c.objid
;



-- ## 2021-06-29
INSERT INTO paymentpartner (objid, code, name, branch, contact, mobileno, phoneno, email, indexno) 
VALUES ('PAYMAYA', '103', 'PAYMAYA', NULL, NULL, NULL, NULL, NULL, '103');

INSERT INTO paymentpartner (objid, code, name, branch, contact, mobileno, phoneno, email, indexno) 
VALUES ('GCASH', '104', 'GCASH', NULL, NULL, NULL, NULL, NULL, '104');
