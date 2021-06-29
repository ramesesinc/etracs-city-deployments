-- ## 2020-11-21
select objid 
into ztmp_delete_paymentorder
from eor_paymentorder
where txndate < '2021-06-01' 
go 

insert into eor_paymentorder_cancelled (
	objid, txndate, txntype, txntypename, payer_objid, payer_name, 
	paidby, paidbyaddress, particulars, amount, expirydate, refid, 
	refno, info, origin, controlno, locationid, items, state, 
	email, mobileno
)
select 
	po.objid, po.txndate, po.txntype, po.txntypename, po.payer_objid, po.payer_name, 
	po.paidby, po.paidbyaddress, po.particulars, po.amount, po.expirydate, po.refid, 
	po.refno, po.info, po.origin, po.controlno, po.locationid, po.items, po.state, 
	po.email, po.mobileno 
from ztmp_delete_paymentorder z 
	inner join eor_paymentorder po on po.objid = z.objid 
	left join eor_paymentorder_cancelled c on c.objid = po.objid 
	left join eor on eor.paymentrefid = po.objid 
where c.objid is null and eor.objid is null 
go 

drop table ztmp_delete_paymentorder
go 

delete from eor_paymentorder where objid in (
	select objid from eor_paymentorder_cancelled 
)
go 




-- ## 2020-12-12
insert into eor_paymentorder_cancelled (
	objid, txndate, txntype, txntypename, payer_objid, payer_name, paidby, paidbyaddress, particulars, 
	amount, expirydate, refid, refno, info, origin, controlno, locationid, items, state, email, mobileno
)
select 
	objid, txndate, txntype, txntypename, payer_objid, payer_name, paidby, paidbyaddress, particulars, 
	amount, expirydate, refid, refno, info, origin, controlno, locationid, items, state, email, mobileno
from eor_paymentorder
where txndate < '2021-06-01' 
order by txndate 
;

delete from eor_paymentorder where objid in (
	select objid from eor_paymentorder_cancelled 
	where objid = eor_paymentorder.objid 
)
;




-- ## 2021-01-14

alter table eor add lockid varchar(50) null 
go 

create index ix_lockid on eor (lockid) 
go 


alter table eor_remittance add lockid varchar(50) null 
go 


alter table eor_share add receiptitemid varchar(50) null 
go



if object_id('dbo.vw_remittance_eor_item', 'V') IS NOT NULL 
	drop view dbo.vw_remittance_eor_item; 
go 
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
go 


if object_id('dbo.vw_remittance_eor_share', 'V') IS NOT NULL 
	drop view dbo.vw_remittance_eor_share; 
go 
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
go 



-- ## 2021-06-29
INSERT INTO paymentpartner (objid, code, name, branch, contact, mobileno, phoneno, email, indexno) 
VALUES ('PAYMAYA', '103', 'PAYMAYA', NULL, NULL, NULL, NULL, NULL, '103');

INSERT INTO paymentpartner (objid, code, name, branch, contact, mobileno, phoneno, email, indexno) 
VALUES ('GCASH', '104', 'GCASH', NULL, NULL, NULL, NULL, NULL, '104');
