package comis.facts;

import java.util.*;

public class PrevBurialPermitApplication {
	String objid;
	String state;
	String apptype;
	Date dtapproved;
	Date dtexpiry;
	String applicantid;
	String deceasedid;
	int leaseduration;
	boolean renewable;
	public PrevBurialPermitApplication() {}

	public PrevBurialPermitApplication(def app) {
		this.objid = app.objid;
		this.apptype = app.apptype;
		this.dtapproved = app.dtapproved;
		this.dtexpiry = app.dtexpiry;
		this.applicantid = app.applicant.objid;
		this.deceasedid = app.deceased.objid;
		this.renewable = app.renewable;
		this.leaseduration = app.leaseduration;
	}
}


