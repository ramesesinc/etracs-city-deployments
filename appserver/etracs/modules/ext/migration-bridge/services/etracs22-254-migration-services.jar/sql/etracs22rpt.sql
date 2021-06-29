[getBarangayIds]
select indexno from lgu where lgutype = 'barangay' order by indexno


[getFaasesForMigration]
SELECT TOP ${count} * FROM faaslist 
WHERE rputype=$P{rputype} 
AND objid NOT IN (SELECT objid FROM etracs25_migrate_faas) 
AND objid NOT IN (SELECT objid FROM etracs25_migrate_log) 

[getPrevFaasesForMigration]
SELECT TOP ${count} * FROM faaslist 
where objid NOT IN (SELECT objid FROM etracs25_migrate_prevfaas) 
AND objid NOT IN (SELECT objid FROM etracs25_migrate_prevfaas_log) 

[findFaasByid]
select * from faas where objid = $P{objid}

[findFaasLogById]
select * from etracs25_migrate_faas where objid = $P{objid}

[findFaasPrevInfoById]
select objid, previousfaases from faas where objid = $P{objid}

[logError]
INSERT INTO etracs25_migrate_log (objid,log) VALUES ($P{objid},$P{log})

[logPrevFaasError]
INSERT INTO etracs25_migrate_prevfaas_log (objid,log) VALUES ($P{objid},$P{log})

[logMigratedFaas]
INSERT INTO etracs25_migrate_faas (objid) VALUES ($P{objid})

[logMigratedPreviousFaas]
INSERT INTO etracs25_migrate_prevfaas (objid) VALUES ($P{objid})

[findFaasListById]
select * from faaslist where objid =$P{objid}


[findLandFaasById]
select landfaasid as objid from faaslist where objid =$P{objid}





[getStructures]
SELECT * FROM structures;

[getLandAdjustment]
SELECT * FROM landadjustment;

[getBldgAssessLevel]
SELECT * FROM bldgassesslevel;

[getBldgTypeDepreciation]
SELECT * FROM bldgtype;

[getPlantTreeAssessLevel]
SELECT * FROM planttreerysetting;

[getMiscAssessLevel]
SELECT * FROM miscassesslevel;

[getFaasList]
SELECT 
	objid, docstate, ry, tdno, fullpin, rputype, txntype, 
	taxpayerid, taxpayername, taxpayeraddress, ownername, owneraddress, 
	cadastrallotno, surveyno, effectivityyear, effectivityqtr, classcode, taxable, 
	totalareasqm, totalmv, totalav, barangay, totalareasqm, totalareaha, munidistrict, annotated 
FROM faaslist i 
WHERE i.docstate IN ('CURRENT', 'CANCELLED')
${filter} 
ORDER BY i.tdno, i.fullpin 



[deleteLogById]
delete from etracs25_migrate_log where objid = $P{objid}