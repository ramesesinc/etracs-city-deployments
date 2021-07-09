package comis.actions;

import com.rameses.rules.common.*;
import com.rameses.util.*;
import comis.facts.*;

public class CalcSurcharge implements RuleActionHandler {
	def request;
	
	public void execute(def params, def drools) {
		def fee = params.fee;
		def surchargeacct = params.itemaccount;
		fee.surchargeacctid = surchargeacct.key;
		fee.surcharge = params.expr.decimalValue;
	}
}