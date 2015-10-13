package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.adapter.common.basic.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.ExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironmentAdapter;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/CreateDummyStyles")
public class CreateDummyStyles extends AbstractSIB {

	public static final String[] BRANCHES = {Branches.DEFAULT, Branches.ERROR};

	@Override
	public String trace(ExecutionEnvironment ee) {
		return execute(new LightweightExecutionEnvironmentAdapter(ee));
	}

	public String execute(LightweightExecutionEnvironmentAdapter env) {
		return new ServiceAdapter().createDummyStyles(env);
	}
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), "createDummyStyles");
	}
}
