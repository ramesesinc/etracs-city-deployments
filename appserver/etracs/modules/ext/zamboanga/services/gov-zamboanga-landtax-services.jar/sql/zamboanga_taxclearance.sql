[getAssessments]
SELECT pc.code 
FROM rpu_assessment a 
INNER JOIN bldgassesslevel au on a.actualuse_objid = au.objid
INNER JOIN propertyclassification pc on au.classification_objid = pc.objid 
WHERE a.rpuid = $P{rpuid}

