package comis.facts;

import java.util.*;

public class CemeteryResource {
	String objid;
	String resourceid;
	String cemeteryid;
	String sectionid;
	String blockid;
	double areasqm;
	
	public CemeteryResource() {}

	public CemeteryResource(info) {
		this.objid = info.objid;
		this.resourceid = info.resource.objid;
		this.cemeteryid = info.cemetery.objid;
		this.sectionid = info.section.objid;
		this.blockid = info.block.objid;
		this.areasqm = info.areasqm;
	}

}


