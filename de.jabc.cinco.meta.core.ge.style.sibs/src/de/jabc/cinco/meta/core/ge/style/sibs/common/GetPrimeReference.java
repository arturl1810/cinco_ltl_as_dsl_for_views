package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/GetPrimeReference")
public class GetPrimeReference extends AbstractSIB {

	public static final String[] BRANCHES = { Branches.DEFAULT, Branches.ERROR };
	
	public ContextKey nodeKey = new ContextKey("nodeKey", ContextKey.Scope.DECLARED, true);
	public ContextKey nodeprimeReferenceKey = new ContextKey("nodeprimeReferenceKey", ContextKey.Scope.LOCAL, true);
	
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.getPrimeReference(env,
				nodeKey.asFoundation(),
				nodeprimeReferenceKey.asFoundation());
	}

	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(),
				"getPrimeReference", 
				"nodeKey",
				"nodeprimeReferenceKey");
	}
}
