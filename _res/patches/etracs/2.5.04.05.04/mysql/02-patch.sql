/* ABSTRACT RPT COLLECTION: change remittance to controldate */

DROP VIEW IF EXISTS `vw_landtax_abstract_of_collection_detail`
;

CREATE VIEW `vw_landtax_abstract_of_collection_detail` AS 
select 
`liq`.`objid` AS `liquidationid`,
`liq`.`controldate` AS `liquidationdate`,
`rem`.`objid` AS `remittanceid`,
`rem`.`controldate` AS `remittancedate`,
`cr`.`objid` AS `receiptid`,
`cr`.`receiptdate` AS `ordate`,
`cr`.`receiptno` AS `orno`,
`cr`.`collector_objid` AS `collectorid`,
`rl`.`objid` AS `rptledgerid`,
`rl`.`fullpin` AS `fullpin`,
`rl`.`titleno` AS `titleno`,
`rl`.`cadastrallotno` AS `cadastrallotno`,
`rl`.`rputype` AS `rputype`,
`rl`.`totalmv` AS `totalmv`,
`b`.`name` AS `barangay`,
`rp`.`fromqtr` AS `fromqtr`,
`rp`.`toqtr` AS `toqtr`,
`rpi`.`year` AS `year`,
`rpi`.`qtr` AS `qtr`,
`rpi`.`revtype` AS `revtype`,
(case when isnull(`cv`.`objid`) then `rl`.`owner_name` else '*** voided ***' end) AS `taxpayername`,
(case when isnull(`cv`.`objid`) then `rl`.`tdno` else '' end) AS `tdno`,
(case when isnull(`m`.`name`) then `c`.`name` else `m`.`name` end) AS `municityname`,
(case when isnull(`cv`.`objid`) then `rl`.`classcode` else '' end) AS `classification`,
(case when isnull(`cv`.`objid`) then `rl`.`totalav` else 0.0 end) AS `assessvalue`,
(case when isnull(`cv`.`objid`) then `rl`.`totalav` else 0.0 end) AS `assessedvalue`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'basic') and (`rpi`.`revperiod` in ('current','advance'))) then `rpi`.`amount` else 0.0 end) AS `basiccurrentyear`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'basic') and (`rpi`.`revperiod` in ('previous','prior'))) then `rpi`.`amount` else 0.0 end) AS `basicpreviousyear`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'basic')) then `rpi`.`discount` else 0.0 end) AS `basicdiscount`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'basic') and (`rpi`.`revperiod` in ('current','advance'))) then `rpi`.`interest` else 0.0 end) AS `basicpenaltycurrent`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'basic') and (`rpi`.`revperiod` in ('previous','prior'))) then `rpi`.`interest` else 0.0 end) AS `basicpenaltyprevious`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'sef') and (`rpi`.`revperiod` in ('current','advance'))) then `rpi`.`amount` else 0.0 end) AS `sefcurrentyear`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'sef') and (`rpi`.`revperiod` in ('previous','prior'))) then `rpi`.`amount` else 0.0 end) AS `sefpreviousyear`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'sef')) then `rpi`.`discount` else 0.0 end) AS `sefdiscount`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'sef') and (`rpi`.`revperiod` in ('current','advance'))) then `rpi`.`interest` else 0.0 end) AS `sefpenaltycurrent`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'sef') and (`rpi`.`revperiod` in ('previous','prior'))) then `rpi`.`interest` else 0.0 end) AS `sefpenaltyprevious`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'basicidle') and (`rpi`.`revperiod` in ('current','advance'))) then `rpi`.`amount` else 0.0 end) AS `basicidlecurrent`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'basicidle') and (`rpi`.`revperiod` in ('previous','prior'))) then `rpi`.`amount` else 0.0 end) AS `basicidleprevious`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'basicidle')) then `rpi`.`amount` else 0.0 end) AS `basicidlediscount`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'basicidle') and (`rpi`.`revperiod` in ('current','advance'))) then `rpi`.`interest` else 0.0 end) AS `basicidlecurrentpenalty`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'basicidle') and (`rpi`.`revperiod` in ('previous','prior'))) then `rpi`.`interest` else 0.0 end) AS `basicidlepreviouspenalty`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'sh') and (`rpi`.`revperiod` in ('current','advance'))) then `rpi`.`amount` else 0.0 end) AS `shcurrent`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'sh') and (`rpi`.`revperiod` in ('previous','prior'))) then `rpi`.`amount` else 0.0 end) AS `shprevious`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'sh')) then `rpi`.`discount` else 0.0 end) AS `shdiscount`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'sh') and (`rpi`.`revperiod` in ('current','advance'))) then `rpi`.`interest` else 0.0 end) AS `shcurrentpenalty`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'sh') and (`rpi`.`revperiod` in ('previous','prior'))) then `rpi`.`interest` else 0.0 end) AS `shpreviouspenalty`,
(case when (isnull(`cv`.`objid`) and (`rpi`.`revtype` = 'firecode')) then `rpi`.`amount` else 0.0 end) AS `firecode`,
(case when isnull(`cv`.`objid`) then ((`rpi`.`amount` - `rpi`.`discount`) + `rpi`.`interest`) else 0.0 end) AS `total`,
(case when isnull(`cv`.`objid`) then `rpi`.`partialled` else 0 end) AS `partialled` 
from  `collectionvoucher` `liq` 
join `remittance` `rem` on `rem`.`collectionvoucherid` = `liq`.`objid`  
join `cashreceipt` `cr` on `rem`.`objid` = `cr`.`remittanceid`  left 
join `cashreceipt_void` `cv` on `cr`.`objid` = `cv`.`receiptid`  
join `rptpayment` `rp` on `rp`.`receiptid` = `cr`.`objid`  
join `rptpayment_item` `rpi` on `rpi`.`parentid` = `rp`.`objid`  
join `rptledger` `rl` on `rl`.`objid` = `rp`.`refid`  
join `barangay` `b` on `b`.`objid` = `rl`.`barangayid`  left 
join `district` `d` on `b`.`parentid` = `d`.`objid`  left 
join `city` `c` on `d`.`parentid` = `c`.`objid`  left 
join `municipality` `m` on `b`.`parentid` = `m`.`objid` 
;


/* ADD TAXABLE */
DROP  VIEW IF EXISTS  `vw_report_subdividedland`
;

CREATE  VIEW `vw_report_subdividedland` AS 
select 
  `sl`.`objid` AS `objid`,
  `s`.`objid` AS `subdivisionid`,
  `s`.`txnno` AS `txnno`,
  `b`.`name` AS `barangay`,
  `o`.`name` AS `lguname`,
  `pc`.`code` AS `classcode`,
  `f`.`tdno` AS `tdno`,
  `f`.`owner_name` AS `owner_name`,
  `f`.`administrator_name` AS `administrator_name`,
  `f`.`titleno` AS `titleno`,
  `f`.`lguid` AS `lguid`,
  `f`.`titledate` AS `titledate`,
  `f`.`fullpin` AS `fullpin`,
  `rp`.`cadastrallotno` AS `cadastrallotno`,
  `rp`.`blockno` AS `blockno`,
  `rp`.`surveyno` AS `surveyno`,
  `r`.`totalareaha` AS `totalareaha`,
  `r`.`rputype` AS `rputype`,
  `r`.`totalareasqm` AS `totalareasqm`,
  `r`.`totalmv` AS `totalmv`,
  `r`.`totalav` AS `totalav`,
  `r`.`taxable` as `taxable`,
  `f`.`txntype_objid` AS `txntype_objid`,
  `ft`.`displaycode` AS `txntype_code`,
  `e`.`name` AS `taxpayer_name` 
  from  `subdividedland` `sl` 
  join `subdivision` `s` on `sl`.`subdivisionid` = `s`.`objid` 
  join `faas` `f` on `sl`.`newfaasid` = `f`.`objid` 
  join `rpu` `r` on `f`.`rpuid` = `r`.`objid` 
  join `realproperty` `rp` on `f`.`realpropertyid` = `rp`.`objid` 
  join `barangay` `b` on `rp`.`barangayid` = `b`.`objid` 
  join `sys_org` `o` on `f`.`lguid` = `o`.`objid` 
  join `faas_txntype` `ft` on `f`.`txntype_objid` = `ft`.`objid` 
  join `entity` `e` on `f`.`taxpayer_objid` = `e`.`objid` 
  join `propertyclassification` `pc` on `r`.`classification_objid` = `pc`.`objid`
;

DROP  VIEW IF EXISTS  `vw_report_consolidated_land`
;

CREATE VIEW `vw_report_consolidated_land` AS 
select 
  `cl`.`consolidationid` AS `consolidationid`,
  `f`.`tdno` AS `tdno`,
  `f`.`owner_name` AS `owner_name`,
  `b`.`name` AS `barangay`,
  `o`.`name` AS `lguname`,
  `f`.`titleno` AS `titleno`,
  `f`.`fullpin` AS `fullpin`,
  `rp`.`cadastrallotno` AS `cadastrallotno`,
  `rp`.`blockno` AS `blockno`,
  `rp`.`surveyno` AS `surveyno`,
  `r`.`totalareaha` AS `totalareaha`,
  `r`.`totalareasqm` AS `totalareasqm`,
  `r`.`rputype` AS `rputype`,
  `r`.`totalmv` AS `totalmv`,
  `r`.`totalav` AS `totalav`,
  `r`.`taxable` as `taxable`,
  `f`.`administrator_name` AS `administrator_name`,
  `f`.`txntype_objid` AS `txntype_objid`,
  `pc`.`code` AS `classcode`,
  `ft`.`displaycode` AS `txntype_code`,
  `e`.`name` AS `taxpayer_name` 
from  `consolidatedland` `cl` 
join `faas` `f` on `cl`.`landfaasid` = `f`.`objid` 
join `rpu` `r` on `f`.`rpuid` = `r`.`objid` 
join `realproperty` `rp` on `f`.`realpropertyid` = `rp`.`objid` 
join `barangay` `b` on `rp`.`barangayid` = `b`.`objid` 
join `sys_org` `o` on `f`.`lguid` = `o`.`objid` 
join `propertyclassification` `pc` on `r`.`classification_objid` = `pc`.`objid` 
join `faas_txntype` `ft` on `f`.`txntype_objid` = `ft`.`objid` 
join `entity` `e` on `f`.`taxpayer_objid` = `e`.`objid`
;

