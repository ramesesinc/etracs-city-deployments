[getReceipts]
select 
	c.receiptno, c.receiptdate, c.amount, c.controlid, 
	c.formno, c.formtype, c.stubno, c.series, c.voided, 
	case when c.voided = 0 then 'OK' else 'VOIDED' end as receiptstate
from vw_remittance_cashreceipt c 
where c.remittanceid = $P{remittanceid}
order by c.formno, c.controlid, c.series 
