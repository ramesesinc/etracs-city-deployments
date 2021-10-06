[findSurchargeAccount]
select * 
from zview_cto_accounts 
where acctcode = 599 
	and bcode = 2
	and ccode = 1
	and dcode = 0 


[findInterestAccount]
select * 
from zview_cto_accounts 
where acctcode = 599 
	and bcode = 2
	and ccode = 2
	and dcode = 0 


[findAccount]
select * 
from zview_cto_accounts 
where acctcode = $P{acctcode} 
	and bcode = $P{bcode} 
	and ccode = $P{ccode} 
	and dcode = $P{dcode} 
