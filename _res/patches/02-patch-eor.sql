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
