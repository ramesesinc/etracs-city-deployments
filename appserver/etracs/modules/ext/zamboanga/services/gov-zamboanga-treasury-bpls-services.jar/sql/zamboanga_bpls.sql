[getBusinessProfiles]
select 
	b.businessid as bin, b.businessname, b.tradename, b.owner as ownername, o.org as org_name, 
	b.busbldgno as address_bldgno, b.busbldgname as address_bldgname, b.busunitno as address_unitno, 
	b.busstreet as address_street, b.bussubdivision as address_subdivision, b.busbarangay as address_barangay_code, 
	b.busmuni_city as address_municity, b.busprovince as address_province 
from (
	select distinct top 100 
		a.businessid 
	from application a 
		inner join businessprofile b on b.businessid = a.businessid 
	where ${filters} 
		and a.applstatus in (1,3,4,5) 
		and isnull(a.special,0) = 0 
		and (len(ltrim(b.businessname)) > 0 OR len(ltrim(b.tradename)) > 0)
)t1 
	inner join businessprofile b on b.businessid = t1.businessid 
	inner join organization o on o.orgid = b.orgid 
order by b.businessid 


[findBusinessProfile]
select 
	b.businessid as bin, b.tradename, b.businessname, b.owner as ownername, b.organization as org_name, 

	b.busbldgno as address_bldgno, b.busbldgname as address_bldgname, b.busunitno as address_unitno, 
	b.busstreet as address_street, b.bussubdivision as address_subdivision, b.busbarangay as address_barangay_code, 
	b.busmuni_city as address_municity, b.busprovince as address_province, 

	b.ownerbldgno as owneraddress_bldgno, b.ownerbldgname as owneraddress_bldgname, 
	b.ownerunitno as owneraddress_unitno, b.ownerstreet as owneraddress_street, 
	b.ownersubdivision as owneraddress_subdivision, b.ownerbarangay as owneraddress_barangay, 
	b.ownercity as owneraddress_municity, b.ownerprovince as owneraddress_province 
from businessprofile b 
where b.businessid = $P{bin}


[findApplication]
select * from application where applpermitnr = $P{appno} 


[getLedgers]
select t3.*, 
	case when t3.taxdesc is null then t3.regdesc else t3.taxdesc end particulars 
from ( 
	select t2.*, 
		(
			select top 1 particulars from VIEW_ETRACS_TAXES 
			where applpermitnr = t2.applpermitnr and acctcode = t2.acctcode 
				and bclass = t2.bclass and sclass = t2.sclass and xclass = t2.xclass 
			order by cyear desc 
		) as taxdesc, 
		(
			select top 1 particulars from VIEW_ETRACS_REGULATORIES 
			where applpermitnr = t2.applpermitnr and acctcode = t2.acctcode 
				and bclass = t2.bclass and sclass = t2.sclass and xclass = t2.xclass 
			order by cyear desc 
		) as regdesc, 
		case 
			when t2.acctcode = 582 and t2.bclass > 0 then 0 
			when t2.acctcode = 605 and t2.bclass = 3 then 1
			else 2 
		end as groupindex  
	from ( 

		select 
			applpermitnr, cyear, acctcode, bclass, sclass, xclass, 
			sum(amount) as amount, sum(amtpaid) as amtpaid, sum(amount)-sum(amtpaid) as balance, 
			max(qtrly) as qtrly, sum(q1) as q1, sum(q2) as q2, sum(q3) as q3, sum(q4) as q4 
		from ( 
			select 
				applpermitnr, cyear, acctcode, bclass, sclass, xclass, 
				balance as amount, 0.0 as amtpaid, 1 as qtrly, q1, q2, q3, q4  
			from zview_etracs_qtrtax  
			where businessid = $P{bin} 
				and cyear = $P{currentyear} 
				and yearqtr <= $P{yearqtr} 
				and quarterly = 1 

			union all 

			select 
				applpermitnr, cyear, acctcode, bclass, sclass, xclass, 
				balance as amount, 0.0 as amtpaid, 1 as qtrly, q1, q2, q3, q4  
			from zview_etracs_qtrtax  
			where businessid = $P{bin} 
				and cyear < $P{year} 
				and quarterly = 1 

			union all 

			select 
				applpermitnr, cyear, acctcode, bclass, sclass, xclass, 
				balance as amount, 0.0 as amtpaid, 0 as qtrly, 
				0.0 as q1, 0.0 as q2, 0.0 as q3, 0.0 as q4
			from zview_etracs_qtrtax  
			where businessid = $P{bin}
				and cyear <= $P{year} 
				and quarterly = 0 

			union all 

			select 
				applpermitnr, cyear, acctcode, bclass, sclass, xclass, 
				amount, 0.0 as amtpaid, 0 as qtrly, 
				0.0 as q1, 0.0 as q2, 0.0 as q3, 0.0 as q4 
			from VIEW_ETRACS_REGULATORIES
			where applpermitnr in (select distinct applpermitnr from application where businessid = $P{bin}) 
				and cyear <= $P{year} 
				and cyear = $P{currentyear} 

			union all 

			select 
				a.applpermitnr, a.cyear, a.acctcode, a.bclass, a.sclass, a.xclass, 
				0.0 as amount, a.amount as amtpaid, 0 as qtrly, 
				0.0 as q1, 0.0 as q2, 0.0 as q3, 0.0 as q4 
			from VIEW_ETRACS_AF51ext a 
			where a.businessid = $P{bin}
				and a.cyear <= $P{year}
		)t1 
		group by applpermitnr, cyear, acctcode, bclass, sclass, xclass 
		having sum(amount)-sum(amtpaid) > 0 

	)t2
		left join zview_account_all a on (a.acctcode = t2.acctcode and a.bclass = t2.bclass and a.sclass = t2.sclass and a.xclass = t2.xclass)
	where t2.balance > 0 
)t3 
order by cyear, groupindex, case when t3.taxdesc is null then t3.regdesc else t3.taxdesc end


[findAccount]
select * 
from zview_account_all 
where acctcode = $P{acctcode} and bclass = $P{bclass} 
	and sclass = $P{sclass} and xclass = $P{xclass} 
