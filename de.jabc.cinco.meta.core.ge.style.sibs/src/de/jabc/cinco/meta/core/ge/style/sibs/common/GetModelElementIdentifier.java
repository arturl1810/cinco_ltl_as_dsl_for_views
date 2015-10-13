package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.ExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironmentAdapter;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/GetModelElementIdentifier")
public class GetModelElementIdentifier extends AbstractSIB {

	public static final String[] BRANCHES = { Branches.DEFAULT, Branches.ERROR };
	
	public ContextKey modelElementName = new ContextKey("modelElementName", ContextKey.Scope.LOCAL, true);
	public ContextKey meIdentifier = new ContextKey("meIdentifier", ContextKey.Scope.LOCAL, true);

	@Override
	public String trace(ExecutionEnvironment ee) {
		return execute(new LightweightExecutionEnvironmentAdapter(ee));
	}
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.getModelElementIdentifier(env,
				modelElementName.asFoundation(),
				meIdentifier.asFoundation());
	}

	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(),
				"getModelElementIdentifier", 
				"modelElementName",
				"meIdentifier");
	}
	
}
