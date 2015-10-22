package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.ExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironmentAdapter;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/ComputePosition")
public class ComputePosition extends AbstractSIB {
	public static final String[] BRANCHES = { Branches.DEFAULT, Branches.ERROR };

	public ContextKey relativePosition = new ContextKey("relativePosition", ContextKey.Scope.LOCAL, true);
	public ContextKey size = new ContextKey("size", ContextKey.Scope.LOCAL, true);
	public ContextKey newPosition = new ContextKey("newPosition", ContextKey.Scope.LOCAL, true);

	@Override
	public String trace(ExecutionEnvironment ee) {
		return execute(new LightweightExecutionEnvironmentAdapter(ee));
	}
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.computePosition(env,
				relativePosition.asFoundation(),
				size.asFoundation(),
				newPosition.asFoundation());
	}

	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(),
				"computePosition", 
				"relativePostition",
				"size",
				"newPosition");
	}
}
