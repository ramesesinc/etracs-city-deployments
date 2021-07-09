package comis.facts;

import java.util.*;

public class BurialPermitApplication {
	String objid;
	String apptype;
	Date dtapproved;
	Date dtexpiry;
	String applicantid;
	String deceasedid;
	int leaseduration;
	boolean renewable;

	def DEFAULT_LEASE_DURATION = 7;
	def fees = [];

	public BurialPermitApplication() {}

	public BurialPermitApplication(def app) {
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


