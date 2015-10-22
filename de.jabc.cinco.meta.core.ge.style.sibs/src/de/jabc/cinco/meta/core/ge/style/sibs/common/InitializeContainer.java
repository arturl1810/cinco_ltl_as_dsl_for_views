package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.adapter.common.basic.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.ExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironmentAdapter;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/InitializeContainer")
public class InitializeContainer extends AbstractSIB {

	public static final String[] BRANCHES = new String[] {Branches.ERROR, Branches.DEFAULT}
	;
	public ContextKey graphModel = new ContextKey("graphModel", ContextKey.Scope.GLOBAL, true);

	@Override
	public String trace(ExecutionEnvironment ee) {
		return execute(new LightweightExecutionEnvironmentAdapter(ee));
	}
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.initializeContainer(env, graphModel.asFoundation());
	}
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), "InitializeContainer",
				"graphModel");
	}
	
}
