package comis.actions;

import com.rameses.rules.common.*;
import com.rameses.util.*;
import comis.facts.*;

public class ComputeLeaseDuration implements RuleActionHandler {
	def request;
	
	public void execute(def params, def drools) {
		def app = params.application;
		app.leaseduration = params.expr.intValue
	}
}