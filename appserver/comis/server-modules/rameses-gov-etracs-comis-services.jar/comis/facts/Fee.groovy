package comis.facts;

import java.util.*;

public class Fee {
	String objid;
	String acctid;
	String surchargeacctid;
	String penaltyacctid;
	Double amount = 0.0;
	Double surcharge = 0.0;
	Double penalty = 0.0;

	public Fee() {}

	public Fee(fee) {
		this.objid = fee.objid;
		this.acctid = fee.acctid;
		this.amount = fee.amount;
	}
}


