[getViolationsPerTicket]
SELECT
v.*,
vte.*
FROM ovs_violation_ticket_entry vte 
INNER JOIN ovs_violation v ON vte.violationid = v.objid
WHERE vte.parentid = $P{objid}


[getViolationTicketsByPaymentRefid]
select distinct 
	vt.objid, vt.ticketno, 
	vt.apprehensionofficer_name as officername  
from ovs_payment op 
	inner join ovs_payment_item opi on opi.parentid=op.objid 
	inner join ovs_violation_ticket_entry vte on vte.objid=opi.refid 
	inner join ovs_violation_ticket vt on vt.objid=vte.parentid 
where op.refid=$P{refid} 
order by vt.ticketno 
