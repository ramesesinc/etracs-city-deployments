package comis.actions;

import com.rameses.rules.common.*;
import com.rameses.util.*;
import comis.facts.*;

public class CalcPenalty implements RuleActionHandler {
	def request;
	
	public void execute(def params, def drools) {
		def fee = params.fee;
		def penaltyacct = params.itemaccount;
		fee.penaltyacctid = penaltyacct.key;
		fee.penalty = params.expr.decimalValue;
	}
}