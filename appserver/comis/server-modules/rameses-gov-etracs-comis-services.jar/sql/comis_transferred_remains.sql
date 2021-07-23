[getList]
select * 
from vw_transferred_list
where state not in ('DRAFT', 'CLOSED', 'RENEWED')
${filter}