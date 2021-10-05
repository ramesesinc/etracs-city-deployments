use etracs25_zamboanga
go


-- ## 2020-04-21

if object_id('dbo.vw_cashbook_cashreceipt', 'V') IS NOT NULL 
  drop view dbo.vw_cashbook_cashreceipt; 
go 
CREATE VIEW vw_cashbook_cashreceipt AS 
select  
  c.objid AS objid, 
  c.txndate AS txndate,
  cast(c.receiptdate as date) AS refdate, 
  c.objid AS refid, 
  c.receiptno AS refno,
  'cashreceipt' AS reftype, 
  (ct.name +' ('+ c.paidby +')') AS particulars, 
  ci.item_fund_objid AS fundid, 
  c.collector_objid AS collectorid, 
  ci.amount AS dr, 0.0 AS cr, 
  c.formno AS formno, 
  c.formtype AS formtype, 
  c.series AS series, 
  c.controlid AS controlid, 
  c.txndate AS sortdate, 
  c.receiptdate AS receiptdate, 
  c.objid AS receiptid, 
  c.remittanceid, 
	r.controldate as remittancedate, 
	r.dtposted as remittancedtposted
from cashreceipt c 
  inner join collectiontype ct on ct.objid = c.collectiontype_objid
  inner join cashreceiptitem ci on ci.receiptid = c.objid
	left join remittance r on r.objid = c.remittanceid 
go 


if object_id('dbo.vw_cashbook_cashreceipt_share', 'V') IS NOT NULL 
  drop view dbo.vw_cashbook_cashreceipt_share; 
go 
CREATE VIEW vw_cashbook_cashreceipt_share AS 
select  
  c.objid AS objid, 
  c.txndate AS txndate,
  cast(c.receiptdate as date) AS refdate, 
  c.objid AS refid, 
  c.receiptno AS refno, 
  'cashreceipt' AS reftype, 
  (ct.name +' ('+ c.paidby +')') AS particulars, 
  ia.fund_objid AS fundid, 
  c.collector_objid AS collectorid, 
  cs.amount AS dr, 0.0 AS cr, 
  c.formno AS formno, 
  c.formtype AS formtype, 
  c.series AS series, 
  c.controlid AS controlid, 
  c.txndate AS sortdate, 
  c.receiptdate AS receiptdate, 
  c.objid AS receiptid, 
  cs.refitem_objid AS refitemid, 
  c.remittanceid, 
  r.controldate as remittancedate, 
  r.dtposted as remittancedtposted   
from cashreceipt c 
  inner join collectiontype ct on ct.objid = c.collectiontype_objid 
  inner join cashreceipt_share cs on cs.receiptid = c.objid 
  inner join itemaccount ia on ia.objid = cs.refitem_objid 
  left join remittance r on r.objid = c.remittanceid 
go 


if object_id('dbo.vw_cashbook_cashreceipt_share_payable', 'V') IS NOT NULL 
  drop view dbo.vw_cashbook_cashreceipt_share_payable; 
go 
CREATE VIEW vw_cashbook_cashreceipt_share_payable AS 
select  
  c.objid AS objid, 
  c.txndate AS txndate,
  cast(c.receiptdate as date) AS refdate, 
  c.objid AS refid, 
  c.receiptno AS refno, 
  'cashreceipt' AS reftype, 
  (ct.name +' ('+ c.paidby +')') AS particulars, 
  ia.fund_objid AS fundid, 
  c.collector_objid AS collectorid, 
  cs.amount AS dr, 0.0 AS cr, 
  c.formno AS formno, 
  c.formtype AS formtype, 
  c.series AS series, 
  c.controlid AS controlid, 
  c.txndate AS sortdate, 
  c.receiptdate AS receiptdate, 
  c.objid AS receiptid, 
  cs.payableitem_objid AS payableitemid, 
  c.remittanceid, 
  r.controldate as remittancedate, 
  r.dtposted as remittancedtposted   
from cashreceipt c 
  inner join collectiontype ct on ct.objid = c.collectiontype_objid 
  inner join cashreceipt_share cs on cs.receiptid = c.objid 
  inner join itemaccount ia on ia.objid = cs.payableitem_objid  
  left join remittance r on r.objid = c.remittanceid 
go 


if object_id('dbo.vw_cashbook_remittance', 'V') IS NOT NULL 
  drop view dbo.vw_cashbook_remittance; 
go 
CREATE VIEW vw_cashbook_remittance AS 
select  
  r.objid AS objid, 
  r.dtposted AS txndate, 
  r.controldate AS refdate, 
  r.objid AS refid, 
  r.controlno AS refno, 
  'remittance' AS reftype, 
  'REMITTANCE' AS particulars, 
  ci.item_fund_objid AS fundid, 
  r.collector_objid AS collectorid, 
  0.0 AS dr, ci.amount as cr, 
  'remittance' AS formno,
  'remittance' AS formtype,
  NULL AS series, 
  NULL AS controlid, 
  r.dtposted AS sortdate, 
  r.liquidatingofficer_objid, 
  r.liquidatingofficer_name, 
  v.objid as voidid, 
  v.txndate as voiddate 
from remittance r 
  inner join cashreceipt c on c.remittanceid = r.objid 
  inner join cashreceiptitem ci on ci.receiptid = c.objid 
  left join cashreceipt_void v on v.receiptid = c.objid 
go 


if object_id('dbo.vw_cashbook_remittance_share', 'V') IS NOT NULL 
  drop view dbo.vw_cashbook_remittance_share; 
go 
CREATE VIEW vw_cashbook_remittance_share AS 
select  
  r.objid AS objid, 
  r.dtposted AS txndate, 
  r.controldate AS refdate, 
  r.objid AS refid, 
  r.controlno AS refno, 
  'remittance' AS reftype, 
  'REMITTANCE' AS particulars, 
  ia.fund_objid AS fundid, 
  r.collector_objid AS collectorid, 
  0.0 AS dr, cs.amount as cr, 
  'remittance' AS formno,
  'remittance' AS formtype,
  NULL AS series,
  NULL AS controlid, 
  r.dtposted AS sortdate, 
  r.liquidatingofficer_objid, 
  r.liquidatingofficer_name,   
  v.objid as voidid, 
  v.txndate as voiddate 
from remittance r 
  inner join cashreceipt c on c.remittanceid = r.objid 
  inner join cashreceipt_share cs on cs.receiptid = c.objid 
  inner join itemaccount ia on ia.objid = cs.refitem_objid 
  left join cashreceipt_void v on v.receiptid = c.objid 
go 

if object_id('dbo.vw_cashbook_remittance_share_payable', 'V') IS NOT NULL 
  drop view dbo.vw_cashbook_remittance_share_payable; 
go 
CREATE VIEW vw_cashbook_remittance_share_payable AS 
select  
  r.objid AS objid, 
  r.dtposted AS txndate, 
  r.controldate AS refdate, 
  r.objid AS refid, 
  r.controlno AS refno, 
  'remittance' AS reftype, 
  'REMITTANCE' AS particulars, 
  ia.fund_objid AS fundid, 
  r.collector_objid AS collectorid, 
  0.0 AS dr, cs.amount as cr, 
  'remittance' AS formno,
  'remittance' AS formtype,
  NULL AS series,
  NULL AS controlid, 
  r.dtposted AS sortdate, 
  r.liquidatingofficer_objid, 
  r.liquidatingofficer_name,   
  v.objid as voidid, 
  v.txndate as voiddate 
from remittance r 
  inner join cashreceipt c on c.remittanceid = r.objid 
  inner join cashreceipt_share cs on cs.receiptid = c.objid 
  inner join itemaccount ia on ia.objid = cs.payableitem_objid
  left join cashreceipt_void v on v.receiptid = c.objid 
go 


if object_id('dbo.vw_cashbook_cashreceiptvoid', 'V') IS NOT NULL 
  drop view dbo.vw_cashbook_cashreceiptvoid; 
go 
CREATE VIEW vw_cashbook_cashreceiptvoid AS 
select  
  v.objid AS objid, 
  v.txndate AS txndate,
  cast(v.txndate as date) AS refdate, 
  v.objid AS refid, 
  c.receiptno AS refno, 
  'cashreceipt:void' AS reftype,
  ('VOID '+ v.reason) AS particulars, 
  ci.item_fund_objid AS fundid, 
  c.collector_objid AS collectorid, 
  ci.amount as dr, 
  (
    case 
      when r.liquidatingofficer_objid is null then 0.0 
      when v.txndate > r.dtposted then ci.amount 
      else 0.0  
    end
  ) AS cr, 
  c.formno AS formno, 
  c.formtype AS formtype, 
  c.series AS series, 
  c.controlid AS controlid, 
  v.txndate AS sortdate, 
  c.receiptdate, 
  c.remittanceid, 
  r.controldate as remittancedate, 
  r.dtposted as remittancedtposted 
from cashreceipt_void v 
  inner join cashreceipt c on c.objid = v.receiptid 
  inner join cashreceiptitem ci on ci.receiptid = c.objid 
  inner join collectiontype ct on ct.objid = c.collectiontype_objid 
  left join remittance r on r.objid = c.remittanceid 
go 

if object_id('dbo.vw_cashbook_cashreceiptvoid_share', 'V') IS NOT NULL 
  drop view dbo.vw_cashbook_cashreceiptvoid_share; 
go 
CREATE VIEW vw_cashbook_cashreceiptvoid_share AS 
select  
  v.objid AS objid, 
  v.txndate AS txndate,
  cast(v.txndate as date) AS refdate, 
  v.objid AS refid, 
  c.receiptno AS refno, 
  'cashreceipt:void' AS reftype,
  ('VOID '+ v.reason) AS particulars, 
  ia.fund_objid AS fundid, 
  c.collector_objid AS collectorid, 
  cs.amount as dr, 
  (
    case 
      when r.liquidatingofficer_objid is null then 0.0 
      when v.txndate > r.dtposted then cs.amount 
      else 0.0  
    end
  ) AS cr, 
  c.formno AS formno, 
  c.formtype AS formtype, 
  c.series AS series, 
  c.controlid AS controlid, 
  v.txndate AS sortdate, 
  c.receiptdate, 
  c.remittanceid, 
  r.controldate as remittancedate, 
  r.dtposted as remittancedtposted 
from cashreceipt_void v 
  inner join cashreceipt c on c.objid = v.receiptid 
  inner join cashreceipt_share cs on cs.receiptid = c.objid 
  inner join itemaccount ia on ia.objid = cs.refitem_objid 
  inner join collectiontype ct on ct.objid = c.collectiontype_objid 
  left join remittance r on r.objid = c.remittanceid 
go

if object_id('dbo.vw_cashbook_cashreceiptvoid_share_payable', 'V') IS NOT NULL 
  drop view dbo.vw_cashbook_cashreceiptvoid_share_payable; 
go 
CREATE VIEW vw_cashbook_cashreceiptvoid_share_payable AS 
select  
  v.objid AS objid, 
  v.txndate AS txndate,
  cast(v.txndate as date) AS refdate, 
  v.objid AS refid, 
  c.receiptno AS refno, 
  'cashreceipt:void' AS reftype,
  ('VOID '+ v.reason) AS particulars, 
  ia.fund_objid AS fundid, 
  c.collector_objid AS collectorid, 
  cs.amount as dr, 
  (
    case 
      when r.liquidatingofficer_objid is null then 0.0 
      when v.txndate > r.dtposted then cs.amount 
      else 0.0  
    end
  ) AS cr, 
  c.formno AS formno, 
  c.formtype AS formtype, 
  c.series AS series, 
  c.controlid AS controlid, 
  v.txndate AS sortdate, 
  c.receiptdate, 
  c.remittanceid, 
  r.controldate as remittancedate, 
  r.dtposted as remittancedtposted 
from cashreceipt_void v 
  inner join cashreceipt c on c.objid = v.receiptid 
  inner join cashreceipt_share cs on cs.receiptid = c.objid 
  inner join itemaccount ia on ia.objid = cs.payableitem_objid 
  inner join collectiontype ct on ct.objid = c.collectiontype_objid 
  left join remittance r on r.objid = c.remittanceid 
go 




-- ## 2020-04-29

update aa set 
	aa.receivedstartseries = bb.issuedstartseries, aa.receivedendseries = bb.issuedendseries, aa.qtyreceived = bb.qtyissued, 
	aa.issuedstartseries = null, aa.issuedendseries = null, aa.qtyissued = 0 
from af_control_detail aa, ( 
		select objid, issuedstartseries, issuedendseries, qtyissued 
		from af_control_detail d 
		where d.reftype = 'ISSUE' and d.txntype = 'COLLECTION' 
			and d.qtyreceived = 0 
	)bb 
where aa.objid = bb.objid 
; 

update af_control_detail set receivedstartseries = null where receivedstartseries = 0 ; 
update af_control_detail set receivedendseries = null where receivedendseries  = 0 ; 
update af_control_detail set beginstartseries = null where beginstartseries = 0 ; 
update af_control_detail set beginendseries = null where beginendseries = 0 ; 
update af_control_detail set issuedstartseries = null where issuedstartseries = 0 ; 
update af_control_detail set issuedendseries = null where issuedendseries = 0 ; 
update af_control_detail set endingstartseries = null where endingstartseries = 0 ; 
update af_control_detail set endingendseries = null where endingendseries = 0 ; 


update aa set 
	aa.remarks = 'COLLECTION' 
from af_control_detail aa, ( 
		select d.objid 
		from af_control_detail d 
			inner join af_control a on a.objid = d.controlid 
		where d.reftype = 'ISSUE' and d.txntype = 'COLLECTION' 
			and d.remarks = 'SALE' 
	)bb 
where aa.objid = bb.objid 
;

update aa set 
	aa.beginstartseries = bb.receivedstartseries, aa.beginendseries = bb.receivedendseries, aa.qtybegin = bb.qtyreceived, 
	aa.receivedstartseries = null, aa.receivedendseries = null, aa.qtyreceived = 0 
from af_control_detail aa, ( 
		select rd.objid, rd.receivedstartseries, rd.receivedendseries, rd.qtyreceived 
		from ( 
			select tt.*, (
					select top 1 objid from af_control_detail 
					where controlid = tt.controlid and reftype in ('ISSUE','MANUAL_ISSUE') 
					order by refdate, txndate, indexno 
				) as pdetailid, (
					select top 1 objid from af_control_detail 
					where controlid = tt.controlid and refdate = tt.refdate 
						and reftype = tt.reftype and txntype = tt.txntype and qtyreceived > 0 
					order by refdate, txndate, indexno 
				) as cdetailid 
			from ( 
				select d.controlid, d.reftype, d.txntype, min(d.refdate) as refdate  
				from af_control_detail d 
				where d.reftype = 'remittance' and d.txntype = 'remittance' 
				group by d.controlid, d.reftype, d.txntype 
			)tt 
		)tt 
			inner join af_control_detail rd on rd.objid = tt.cdetailid 
			inner join af_control_detail pd on pd.objid = tt.pdetailid 
		where pd.refdate <> rd.refdate 
	)bb 
where aa.objid = bb.objid 
;




-- ## 2020-05-01


INSERT INTO sys_var (name, value, description, datatype, category) 
VALUES ('liquidation_report_show_accountable_forms', '0', 'Show Accoutable Forms in RCD Liquidation Report ', NULL, 'TC')
;



-- ## 2020-05-04



update aa set 
	aa.refdate = bb.receiptdate 
from af_control_detail aa, (
		select t2.*, (select min(receiptdate) from cashreceipt where controlid = t2.controlid) as receiptdate 
		from ( 
			select t1.* 
			from ( 
				select d.controlid, d.refdate, d.reftype, d.refid, d.objid as cdetailid, (
					select top 1 objid from af_control_detail 
						where controlid = d.controlid 
							order by refdate, txndate, indexno 
					) as firstdetailid 
				from aftxn aft 
					inner join aftxnitem afi on afi.parentid = aft.objid 
					inner join af_control_detail d on d.aftxnitemid = afi.objid 
				where aft.txntype = 'FORWARD' 
			)t1, af_control_detail d 
			where d.objid = t1.firstdetailid 
				and d.objid <> t1.cdetailid 
		)t2 
	)bb 
where aa.objid = bb.cdetailid 
	and bb.receiptdate is not null 
; 



-- ## 2020-05-05


EXEC sp_rename N'[dbo].[creditmemo].[payername]', N'_payername', 'COLUMN'
go 
-- alter table creditmemo add payer_name varchar(255) null
-- go 
update creditmemo set payer_name = _payername where payer_name is null
go 
alter table creditmemo alter column payer_name varchar(255) not null
go 
create index ix_payer_name on creditmemo (payer_name)
go 


-- alter table creditmemo add payer_address_objid varchar(50) not null
-- go 
create index ix_payer_address_objid on creditmemo (payer_address_objid)
go 


EXEC sp_rename N'[dbo].[creditmemo].[payeraddress]', N'_payeraddress', 'COLUMN'
go 
-- alter table creditmemo add payer_address_text varchar(255) null 
-- go 
update creditmemo set payer_address_text = _payeraddress where payer_address_text is null 
go 




-- ## 2020-05-15

if object_id('dbo.vw_remittance_cashreceiptitem', 'V') IS NOT NULL 
  drop view dbo.vw_remittance_cashreceiptitem; 
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
  (case when (c.formtype = 'serial') then 0 else 1 end) AS formtypeindex, 
  cri.receiptid AS receiptid, 
  c.receiptdate AS receiptdate, 
  c.receiptno AS receiptno, 
  c.controlid as controlid, 
  c.series as series, 
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
  (case when v.objid is null then 0.0 else cri.amount end) AS voidamount  
from remittance r 
  inner join cashreceipt c on c.remittanceid = r.objid 
  inner join cashreceiptitem cri on cri.receiptid = c.objid 
  left join cashreceipt_void v on v.receiptid = c.objid 
go 


if object_id('dbo.vw_collectionvoucher_cashreceiptitem', 'V') IS NOT NULL 
  drop view dbo.vw_collectionvoucher_cashreceiptitem; 
go 
create view vw_collectionvoucher_cashreceiptitem AS 
select 
  cv.controldate AS collectionvoucher_controldate, 
  cv.controlno AS collectionvoucher_controlno, 
  v.remittanceid AS remittanceid, 
  v.remittance_controldate AS remittance_controldate, 
  v.remittance_controlno AS remittance_controlno, 
  v.collectionvoucherid AS collectionvoucherid, 
  v.collectiontype_objid AS collectiontype_objid, 
  v.collectiontype_name AS collectiontype_name, 
  v.org_objid AS org_objid, 
  v.org_name AS org_name, 
  v.formtype AS formtype, 
  v.formno AS formno, 
  v.formtypeindex AS formtypeindex, 
  v.receiptid AS receiptid, 
  v.receiptdate AS receiptdate, 
  v.receiptno AS receiptno, 
  v.controlid as controlid,
  v.series as series,
  v.paidby AS paidby, 
  v.paidbyaddress AS paidbyaddress, 
  v.collectorid AS collectorid, 
  v.collectorname AS collectorname, 
  v.collectortitle AS collectortitle, 
  v.fundid AS fundid, 
  v.acctid AS acctid, 
  v.acctcode AS acctcode, 
  v.acctname AS acctname, 
  v.amount AS amount, 
  v.voided AS voided, 
  v.voidamount AS voidamount, 
  v.remarks as remarks 
from collectionvoucher cv 
  inner join vw_remittance_cashreceiptitem v on v.collectionvoucherid = cv.objid 
go 



-- ## 2020-06-06


alter table aftxn add lockid varchar(50) null 
go 

alter table af_control add constraint fk_af_control_afid 
	foreign key (afid) references af (objid) 
go 

alter table af_control add constraint fk_af_control_allocid 
	foreign key (allocid) references af_allocation (objid) 
go 

if object_id('dbo.vw_af_inventory_summary', 'V') IS NOT NULL 
  drop view dbo.vw_af_inventory_summary; 
go 

create view vw_af_inventory_summary as 
select top 100 percent 
	af.objid, af.title, u.unit, af.formtype, 
	(case when af.formtype='serial' then 0 else 1 end) as formtypeindex, 
	(select count(0) from af_control where afid = af.objid and state = 'OPEN') AS countopen, 
	(select count(0) from af_control where afid = af.objid and state = 'ISSUED') AS countissued, 
	(select count(0) from af_control where afid = af.objid and state = 'ISSUED' and currentseries > endseries) AS countclosed, 
	(select count(0) from af_control where afid = af.objid and state = 'SOLD') AS countsold, 
	(select count(0) from af_control where afid = af.objid and state = 'PROCESSING') AS countprocessing, 
	(select count(0) from af_control where afid = af.objid and state = 'HOLD') AS counthold
from af, afunit u 
where af.objid = u.itemid
order by (case when af.formtype='serial' then 0 else 1 end), af.objid 
go 

alter table af_control add salecost decimal(16,2) not null default '0.0'
go 

-- update af_control set salecost = cost where state = 'SOLD' and cost > 0 and salecost = 0 
-- go  


insert into sys_usergroup (
	objid, title, domain, role, userclass
) values (
	'TREASURY.AFO_ADMIN', 'TREASURY AFO ADMIN', 'TREASURY', 'AFO_ADMIN', 'usergroup' 
)
go  

insert into sys_usergroup_permission (
	objid, usergroup_objid, object, permission, title 
) values ( 
	'TREASURY-AFO-ADMIN-aftxn-changetxntype', 'TREASURY.AFO_ADMIN', 'aftxn', 'changeTxnType', 'Change Txn Type'
); 




-- ## 2020-06-09


insert into sys_usergroup (
	objid, title, domain, role, userclass
) values (
	'TREASURY.COLLECTOR_ADMIN', 'TREASURY COLLECTOR ADMIN', 'TREASURY', 'COLLECTOR_ADMIN', 'usergroup' 
); 

insert into sys_usergroup_permission (
	objid, usergroup_objid, object, permission, title 
) values ( 
	'TREASURY-COLLECTOR-ADMIN-aftxn-changetxntype', 'TREASURY.COLLECTOR_ADMIN', 'remittance', 'rebuildFund', 'Rebuild Remittance Fund'
); 




-- ## 2020-06-10

update af_control_detail set reftype = 'ISSUE' where txntype='SALE' and reftype <> 'ISSUE' 
; 

update aa set 
	aa.issuedstartseries = bb.endingstartseries, aa.issuedendseries = bb.endingendseries, aa.qtyissued = bb.qtyending, 
	aa.endingstartseries = null, aa.endingendseries = null, aa.qtyending = 0 
from af_control_detail aa, ( 
		select 
			(select count(*) from cashreceipt where controlid = d.controlid) as receiptcount, 
			d.objid, d.controlid, d.endingstartseries, d.endingendseries, d.qtyending 
		from af_control_detail d 
		where d.txntype='SALE' 
			and d.qtyending > 0
	)bb 
where aa.objid = bb.objid 
	and bb.receiptcount = 0 
;

update aa set 
	aa.reftype = 'ISSUE', aa.txntype = 'COLLECTION', aa.remarks = 'COLLECTION' 
from af_control_detail aa, ( 
		select 
			(select count(*) from cashreceipt where controlid = d.controlid) as receiptcount, 
			d.objid, d.controlid, d.endingstartseries, d.endingendseries, d.qtyending 
		from af_control_detail d 
		where d.txntype='SALE' 
			and d.qtyending > 0
	)bb 
where aa.objid = bb.objid 
	and bb.receiptcount > 0 
;


insert into sys_usergroup_permission (
	objid, usergroup_objid, object, permission, title 
) values ( 
	'TREASURY-COLLECTOR-ADMIN-remittance-modifyCashBreakdown', 'TREASURY.COLLECTOR_ADMIN', 'remittance', 'modifyCashBreakdown', 'Modify Remittance Cash Breakdown'
); 



-- ## 2020-06-11


update aa set 
	aa.receivedstartseries = bb.issuedstartseries, aa.receivedendseries = bb.issuedendseries, aa.qtyreceived = bb.qtyissued, 
	aa.beginstartseries = null, aa.beginendseries = null, aa.qtybegin = 0 
from af_control_detail aa, ( 
		select objid, issuedstartseries, issuedendseries, qtyissued 
		from af_control_detail 
		where txntype='sale' 
			and qtyissued > 0 
	) bb  
where aa.objid = bb.objid 
; 

update aa set 
	aa.currentdetailid = null, aa.currentindexno = 0 
from af_control aa, ( 
		select a.objid 
		from af_control a 
		where a.objid not in (
			select distinct controlid from af_control_detail where controlid = a.objid
		) 
	)bb 
where aa.objid = bb.objid 
; 


update aa set 
	aa.currentseries = aa.endseries+1 
from  af_control aa, ( 
		select d.controlid 
		from af_control_detail d, af_control a 
		where d.txntype = 'SALE' 
			and d.controlid = a.objid 
			and a.currentseries <= a.endseries 
	)bb 
where aa.objid = bb.controlid 
; 


update af_control set 
	currentindexno = (select indexno from af_control_detail where objid = af_control.currentdetailid)
where currentdetailid is not null 
; 


insert into sys_usergroup_permission (
	objid, usergroup_objid, object, permission, title 
) values ( 
	'TREASURY-COLLECTOR-ADMIN-remittance-voidReceipt', 'TREASURY.COLLECTOR_ADMIN', 'remittance', 'voidReceipt', 'Void Receipt'
); 




-- ## 2020-06-12


insert into sys_usergroup (
	objid, title, domain, role, userclass
) values (
	'TREASURY.LIQ_OFFICER_ADMIN', 'TREASURY LIQ. OFFICER ADMIN', 
	'TREASURY', 'LIQ_OFFICER_ADMIN', 'usergroup' 
); 

insert into sys_usergroup_permission (
	objid, usergroup_objid, object, permission, title 
) values ( 
	'UGP-d2bb69a6769517e0c8e672fec41f5fd7', 'TREASURY.LIQ_OFFICER_ADMIN', 
	'collectionvoucher', 'changeLiqOfficer', 'Change Liquidating Officer'
); 

insert into sys_usergroup_permission (
	objid, usergroup_objid, object, permission, title 
) values ( 
	'UGP-3219ec222220f68d1f69d4d1d76021e0', 'TREASURY.LIQ_OFFICER_ADMIN', 
	'collectionvoucher', 'modifyCashBreakdown', 'Modify Cash Breakdown'
); 

insert into sys_usergroup_permission (
	objid, usergroup_objid, object, permission, title 
) values ( 
	'UGP-4e508bdd04888894926f677bbc0be374', 'TREASURY.LIQ_OFFICER_ADMIN', 
	'collectionvoucher', 'rebuildFund', 'Rebuild Fund Summary'
); 

insert into sys_usergroup_permission (
	objid, usergroup_objid, object, permission, title 
) values ( 
	'UGP-cf543fabc2aca483c6e5d3d48c39c4cc', 'TREASURY.LIQ_OFFICER_ADMIN', 
	'incomesummary', 'rebuild', 'Rebuild Income Summary'
); 




-- ## 2020-08-18

if object_id('dbo.paymentorder_type', 'U') IS NOT NULL 
  drop table dbo.paymentorder_type; 
go 
CREATE TABLE paymentorder_type (
  objid varchar(50) NOT NULL,
  title varchar(150) NULL,
  collectiontype_objid varchar(50) NULL,
  queuesection varchar(50) NULL,
  system int NULL
) 
go 
ALTER TABLE paymentorder_type ADD constraint pk_paymentorder_type PRIMARY KEY (objid)
go 
create index ix_collectiontype_objid on paymentorder_type (collectiontype_objid)
go 
ALTER TABLE paymentorder_type ADD constraint fk_paymentorder_type_collectiontype_objid 
  foreign key (collectiontype_objid) references collectiontype (objid) 
go 


if object_id('dbo.paymentorder', 'U') IS NOT NULL 
  drop table dbo.paymentorder; 
go 
CREATE TABLE paymentorder (
  objid varchar(50) NOT NULL,
  txndate datetime NULL,
  payer_objid varchar(50) NULL,
  payer_name text,
  paidby text,
  paidbyaddress varchar(150) NULL,
  particulars text,
  amount decimal(16,2) NULL,
  expirydate date NULL,
  refid varchar(50) NULL,
  refno varchar(50) NULL,
  info text,
  locationid varchar(50) NULL,
  origin varchar(50) NULL,
  issuedby_objid varchar(50) NULL,
  issuedby_name varchar(150) NULL,
  org_objid varchar(50) NULL,
  org_name varchar(255) NULL,
  items text,
  queueid varchar(50) NULL,
  paymentordertype_objid varchar(50) NULL,
  controlno varchar(50) NULL
) 
go 
ALTER TABLE paymentorder ADD constraint pk_paymentorder PRIMARY KEY (objid)
go 
create index ix_txndate on paymentorder (txndate) 
go 
create index ix_issuedby_name on paymentorder (issuedby_name) 
go 
create index ix_issuedby_objid on paymentorder (issuedby_objid) 
go 
create index ix_locationid on paymentorder (locationid) 
go 
create index ix_org_name on paymentorder (org_name) 
go 
create index ix_org_objid on paymentorder (org_objid) 
go 
create index ix_paymentordertype_objid on paymentorder (paymentordertype_objid) 
go 
alter table paymentorder add CONSTRAINT fk_paymentorder_paymentordertype_objid 
  FOREIGN KEY (paymentordertype_objid) REFERENCES paymentorder_type (objid) 
go 


if object_id('dbo.paymentorder_paid', 'U') IS NOT NULL 
  drop table dbo.paymentorder_paid; 
go 
CREATE TABLE paymentorder_paid (
  objid varchar(50) NOT NULL,
  txndate datetime NULL,
  payer_objid varchar(50) NULL,
  payer_name text,
  paidby text,
  paidbyaddress varchar(150) NULL,
  particulars text,
  amount decimal(16,2) NULL,
  refid varchar(50) NULL,
  refno varchar(50) NULL,
  info text,
  locationid varchar(50) NULL,
  origin varchar(50) NULL,
  issuedby_objid varchar(50) NULL,
  issuedby_name varchar(150) NULL,
  org_objid varchar(50) NULL,
  org_name varchar(255) NULL,
  items text,
  paymentordertype_objid varchar(50) NULL,
  controlno varchar(50) NULL
) 
go 
ALTER TABLE paymentorder_paid ADD constraint pk_paymentorder_paid PRIMARY KEY (objid)
go 
create index ix_txndate on paymentorder_paid (txndate) 
go 
create index ix_issuedby_name on paymentorder_paid (issuedby_name) 
go 
create index ix_issuedby_objid on paymentorder_paid (issuedby_objid) 
go 
create index ix_locationid on paymentorder_paid (locationid) 
go 
create index ix_org_name on paymentorder_paid (org_name) 
go 
create index ix_org_objid on paymentorder_paid (org_objid) 
go 
create index ix_paymentordertype_objid on paymentorder_paid (paymentordertype_objid) 
go 
alter table paymentorder_paid add CONSTRAINT fk_paymentorder_paid_paymentordertype_objid 
  FOREIGN KEY (paymentordertype_objid) REFERENCES paymentorder_type (objid) 
go 



-- ## 2020-10-13


update cashreceipt_plugin set connection = objid where connection is null 
go 



-- ## 2020-10-27


-- ## 2020-11-06

CREATE TABLE [sys_email_queue] (
  [objid] varchar(50) NOT NULL,
  [refid] varchar(50) NOT NULL,
  [state] int NOT NULL,
  [reportid] varchar(50) NULL,
  [dtsent] datetime NOT NULL,
  [to] varchar(255) NOT NULL,
  [subject] varchar(255) NOT NULL,
  [message] text NOT NULL,
  [errmsg] varchar(MAX) NULL,
  constraint pk_sys_email_queue PRIMARY KEY (objid)
) 
go 
create index ix_refid on [sys_email_queue] (refid)
go
create index ix_state on [sys_email_queue] (state)
go
create index ix_reportid on [sys_email_queue] (reportid)
go
create index ix_dtsent on [sys_email_queue] (dtsent)
go


alter table [sys_email_queue] add [connection] varchar(50) NULL
go


CREATE TABLE [online_business_application] (
  [objid] varchar(50) NOT NULL,
  [state] varchar(20) NOT NULL,
  [dtcreated] datetime NOT NULL,
  [createdby_objid] varchar(50) NOT NULL,
  [createdby_name] varchar(100) NOT NULL,
  [controlno] varchar(25) NOT NULL,
  [prevapplicationid] varchar(50) NOT NULL,
  [business_objid] varchar(50) NOT NULL,
  [appyear] int NOT NULL,
  [apptype] varchar(20) NOT NULL,
  [appdate] date NOT NULL,
  [lobs] text NOT NULL,
  [infos] varchar(MAX) NOT NULL,
  [requirements] varchar(MAX) NOT NULL,
  [step] int NOT NULL DEFAULT '0',
  [dtapproved] datetime DEFAULT NULL,
  [approvedby_objid] varchar(50) DEFAULT NULL,
  [approvedby_name] varchar(150) DEFAULT NULL,
  [approvedappno] varchar(25) DEFAULT NULL,
  constraint pk_online_business_application PRIMARY KEY ([objid])
) 
go
create index [ix_state] on online_business_application ([state])
go
create index [ix_dtcreated] on online_business_application ([dtcreated])
go
create index [ix_controlno] on online_business_application ([controlno])
go
create index [ix_prevapplicationid] on online_business_application ([prevapplicationid])
go
create index [ix_business_objid] on online_business_application ([business_objid])
go
create index [ix_appyear] on online_business_application ([appyear])
go
create index [ix_appdate] on online_business_application ([appdate])
go
create index [ix_dtapproved] on online_business_application ([dtapproved])
go
create index [ix_approvedby_objid] on online_business_application ([approvedby_objid])
go
create index [ix_approvedby_name] on online_business_application ([approvedby_name])
go
alter table online_business_application add CONSTRAINT [fk_online_business_application_business_objid] 
  FOREIGN KEY ([business_objid]) REFERENCES [business] ([objid])
go
alter table online_business_application add CONSTRAINT [fk_online_business_application_prevapplicationid] 
  FOREIGN KEY ([prevapplicationid]) REFERENCES [business_application] ([objid])
go



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


CREATE TABLE sys_domain (
  name varchar(50) NOT NULL,
  connection varchar(50) NOT NULL,
  constraint pk_sys_domain PRIMARY KEY (name)
) 
go 



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



-- ## 2021-09-15


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
  c.series as series,
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




-- ## 2021-09-24

INSERT INTO sys_var (name, value, description, datatype, category) 
VALUES ('CASHBOOK_CERTIFIED_BY_NAME', NULL, 'Cashbook Report Certified By Name', 'text', 'REPORT');

INSERT INTO sys_var (name, value, description, datatype, category) 
VALUES ('CASHBOOK_CERTIFIED_BY_TITLE', NULL, 'Cashbook Report Certified By Title', 'text', 'REPORT');



-- ## 2021-09-27


if object_id('dbo.report_bpdelinquency_item', 'U') IS NOT NULL 
  drop table dbo.report_bpdelinquency_item; 
go 
if object_id('dbo.report_bpdelinquency', 'U') IS NOT NULL 
  drop table dbo.report_bpdelinquency; 
go 


CREATE TABLE report_bpdelinquency (
  objid varchar(50) NOT NULL,
  state varchar(25) NULL,
  dtfiled datetime NULL,
  userid varchar(50) NULL,
  username varchar(160) NULL,
  totalcount int NULL,
  processedcount int NULL,
  billdate date NULL,
  duedate date NULL,
  lockid varchar(50) NULL,
  constraint pk_report_bpdelinquency PRIMARY KEY (objid)
) 
go 
CREATE INDEX ix_state ON report_bpdelinquency (state)
go
CREATE INDEX ix_dtfiled ON report_bpdelinquency (dtfiled)
go
CREATE INDEX ix_userid ON report_bpdelinquency (userid)
go
CREATE INDEX ix_billdate ON report_bpdelinquency (billdate)
go
CREATE INDEX ix_duedate ON report_bpdelinquency (duedate)
go


CREATE TABLE report_bpdelinquency_item (
  objid varchar(50) NOT NULL,
  parentid varchar(50) NOT NULL,
  applicationid varchar(50) NOT NULL,
  tax decimal(16,2) NOT NULL DEFAULT 0.0,
  regfee decimal(16,2) NOT NULL DEFAULT 0.0,
  othercharge decimal(16,2) NOT NULL DEFAULT 0.0,
  surcharge decimal(16,2) NOT NULL DEFAULT 0.0,
  interest decimal(16,2) NOT NULL DEFAULT 0.0,
  total decimal(16,2) NOT NULL DEFAULT 0.0,
  duedate date NULL,
  year int NOT NULL,
  qtr int NOT NULL,
  constraint pk_report_bpdelinquency_item PRIMARY KEY (objid)
) 
go
CREATE INDEX ix_parentid ON report_bpdelinquency_item (parentid);
go
CREATE INDEX ix_applicationid ON report_bpdelinquency_item (applicationid);
go
CREATE INDEX ix_year ON report_bpdelinquency_item (year);
go
CREATE INDEX ix_qtr ON report_bpdelinquency_item (qtr);
go
ALTER TABLE report_bpdelinquency_item ADD CONSTRAINT fk_report_bpdelinquency_item_parentid
  FOREIGN KEY (parentid) REFERENCES report_bpdelinquency (objid) 
go

CREATE TABLE report_bpdelinquency_app (
  objid varchar(50) NOT NULL,
  parentid varchar(50) NOT NULL,
  applicationid varchar(50) NOT NULL,
  appdate date not null,
  appyear int not null,
  lockid varchar(50) NULL,
  constraint pk_report_bpdelinquency_app PRIMARY KEY (objid)
) 
go 
create unique index uix_parentid_applicationid on report_bpdelinquency_app (parentid, applicationid)
go 
CREATE INDEX ix_parentid ON report_bpdelinquency_app (parentid);
go
CREATE INDEX ix_applicationid ON report_bpdelinquency_app (applicationid);
go
CREATE INDEX ix_appdate ON report_bpdelinquency_app (appdate);
go
CREATE INDEX ix_appyear ON report_bpdelinquency_app (appyear);
go
CREATE INDEX ix_lockid ON report_bpdelinquency_app (lockid);
go
ALTER TABLE report_bpdelinquency_app ADD CONSTRAINT fk_report_bpdelinquency_app_parentid
  FOREIGN KEY (parentid) REFERENCES report_bpdelinquency (objid) 
go 



-- ## 2021-10-01

-- INSERT INTO sys_var (name, value, description, datatype, category) 
-- VALUES ('cashbook_report_allow_multiple_fund_selection', '0', 'Cashbook Report: Allow Multiple Fund Selection', 'checkbox', 'TC');

-- INSERT INTO sys_var (name, value, description, datatype, category) 
-- VALUES ('liquidate_remittance_as_of_date', '1', 'Liquidate Remittances as of Date', 'checkbox', 'TC');

-- INSERT INTO sys_var (name, value, description, datatype, category) 
-- VALUES ('cashreceipt_reprint_requires_approval', 'false', 'CashReceipt Reprinting Requires Approval', 'checkbox', 'TC');

-- INSERT INTO sys_var (name, value, description, datatype, category) 
-- VALUES ('cashreceipt_void_requires_approval', 'true', 'CashReceipt Void Requires Approval', 'checkbox', 'TC');

-- INSERT INTO sys_var (name, value, description, datatype, category) 
-- VALUES ('deposit_collection_by_bank_account', '0', 'Deposit collection by bank account instead of by fund', 'checkbox', 'TC');
