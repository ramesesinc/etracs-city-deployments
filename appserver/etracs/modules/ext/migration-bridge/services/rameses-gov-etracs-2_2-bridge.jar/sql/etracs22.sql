[getList]
SELECT i.* FROM (
   SELECT
      b.objid,
      b.tradename AS businessname,
      b.tradename,
      b.businessaddress AS address,
      ba.objid AS applicationid,       
      ba.iyear AS activeyear,
      e.entityname,
      e.objid AS ownerid,
      e.entityname AS ownername,
      e.entityaddress AS owneraddress
   FROM business b 
      INNER JOIN entity e ON b.taxpayerid = e.objid 
      INNER JOIN bpapplication ba ON b.applicationid = ba.objid 
   WHERE 1=1 ${filter} 
      AND NOT EXISTS (SELECT 1 FROM etracs25_capture_business WHERE oldbusinessid=b.objid) 
      AND ba.txntype IN ('NEW','RENEW') 
)i 
ORDER BY i.activeyear DESC, i.tradename   


[findInfo]
SELECT
   ba.objid AS objid,
   b.objid AS oldbusinessid,
   b.tradename AS business_businessname,
   b.tradename AS business_tradename,
   b.businessaddress AS business_address_text,
   CASE ba.txntype
      WHEN 'RENEWAL' THEN 'RENEW'
      ELSE ba.txntype
   END as apptype,
   ba.objid AS applicationid, 
   ba.iyear AS activeyear,
   b.yearstarted AS yearstarted,
   e.entityname as business_owner_name,
   e.objid as business_owner_oldid,
   e.entityno as business_owner_entityno,
   e.entityaddress as business_owner_address_text,
   e.info, 
   ba.iyear as appyear,
   CASE b.organization 
      WHEN 'SINGLE PROPRIETORSHIP' THEN 'SING'
      WHEN 'CORPORATION' THEN 'CORP'
      WHEN 'COOPERATIVE' THEN 'COOP'
      WHEN 'ASSOCIATION' THEN 'ASSO'
      WHEN 'PROPRIETORSHIP' THEN 'PART'   
      WHEN 'FOUNDATION' THEN 'FOUND'   
      WHEN 'GOVERNMENT' THEN 'GOV'  
      WHEN 'RELIGIOUS' THEN 'REL'
      ELSE 'NA'   
   END AS business_orgtype 
FROM business b 
   INNER JOIN bpapplication ba ON b.applicationid = ba.objid 
   INNER JOIN entity e ON b.taxpayerid = e.objid 
WHERE b.objid = $P{objid} 


[getLobs]
SELECT
   lob.objid as oldlobid, lob.name as oldname,
   bpapplication.txntype as assessmenttype,
   c.lob_objid as lobid, c.lob_name as name 
FROM bpapplication  
   INNER JOIN business ON bpapplication.businessid = business.objid 
   INNER JOIN bploblisting ON bpapplication.objid = bploblisting.applicationid 
   INNER JOIN lob ON bploblisting.lobid  = lob.objid 
   LEFT JOIN etracs25_capture_lob c ON lob.objid = c.oldlob_objid 
WHERE bpapplication.objid = $P{applicationid} 
   AND bpapplication.txntype IN ('NEW','RENEW') 


[findApplication]
SELECT objid, txntype, taxfees, receivables, credits 
FROM bpapplication 
WHERE objid=$P{objid} 

[findAccount]
SELECT account_objid, account_title 
FROM etracs25_capture_account 
WHERE oldaccount_objid=$P{oldacctid}

[getReceivables]
select 
   CASE xx.applicationtype  
      WHEN 'RENEWAL' THEN 'RENEW'
      ELSE xx.applicationtype 
   END AS assessmenttype, 
   b.objid AS businessid,  
   CASE ia.systype  
     WHEN 'CHARGE' THEN 'OTHERCHARGE' 
     WHEN 'REG_FEE' THEN 'REGFEE' 
     WHEN 'OTHER_FEE' THEN 'OTHERCHARGE' 
     WHEN 'BUSINESS_TAX' THEN 'TAX' 
     WHEN 'TAX' THEN 'TAX' 
   END AS taxfeetype,
   xx.iyear as yearapplied, 
   lob.objid AS oldlob_objid, lob.name AS oldlob_name,
   clob.lob_objid, clob.lob_name, 
   ia.objid AS oldaccount_objid, ia.accttitle AS oldaccount_title, 
   ca.account_objid, ca.account_title,
   xx.amount, xx.amtpaid, 0.0 as surcharge, 0.0 as interest, 0.0 as discount, 
   xx.iyear as year, null as lastreceiptid
from ( 
   select  
      br.applicationid, br.applicationtype, br.businessid, br.iyear, br.lobid, br.acctid, 
      SUM(br.amount) as amount, SUM(br.amtpaid) as amtpaid
   from bpreceivable br 
   where br.applicationid=$P{applicationid} 
      and br.amount != br.amtpaid 
   group by br.applicationid, br.applicationtype, 
      br.businessid, br.iyear, br.lobid, br.acctid 
)xx 
   INNER JOIN business b ON xx.businessid=b.objid 
   INNER JOIN incomeaccount ia ON xx.acctid=ia.objid 
   INNER JOIN lob lob ON xx.lobid=lob.objid 
   LEFT JOIN etracs25_capture_lob clob ON clob.oldlob_objid=lob.objid 
   LEFT JOIN etracs25_capture_account ca ON ia.objid=ca.oldaccount_objid
