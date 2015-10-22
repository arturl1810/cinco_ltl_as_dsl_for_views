package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.ExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironmentAdapter;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.framework.sib.parameter.ContextKey.Scope;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/GenerateEdgeSourceCode")
public class GenerateEdgeSourceCode extends AbstractSIB {

	public static final String[] BRANCHES = {Branches.DEFAULT, Branches.ERROR};

	public ContextKey mapEntry = new ContextKey("mapEntry", Scope.LOCAL, true);
	public ContextKey code = new ContextKey("code", Scope.GLOBAL, true);
	

	@Override
	public String trace(ExecutionEnvironment ee) {
		return execute(new LightweightExecutionEnvironmentAdapter(ee));
	}
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.generateEdgeSourceCode(env, mapEntry.asFoundation(), code.asFoundation());
	}
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), 
				"generateEdgeSourceCode",
				"mapEntry",
				"code");
	}
	
}
