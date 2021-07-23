package comis.actions;

import com.rameses.rules.common.*;
import com.rameses.util.*;
import comis.facts.*;

public class AddFee implements RuleActionHandler {
	def request;

	public void execute(def params, def drools) {
		def app = params.application;
		def itemaccount = params.itemaccount;

		def fee = app.fees.find{it.acctid == itemaccount.key};
		if (!fee) {
			fee = [:];
			fee.objid = 'CF' + new java.rmi.server.UID();
			fee.acctid = itemaccount.key;
			fee.amount = params.expr.decimalValue;

			def factFee = new Fee(fee);
			app.fees << factFee;
			request.facts << factFee;
			drools.insert(factFee);
		}
	}
}