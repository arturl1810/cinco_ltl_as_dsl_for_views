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


@SIBClass("ge-util-sibs/IsEdgeUsed")
public class IsEdgeUsed extends AbstractSIB {

public static final String[] BRANCHES = {Branches.TRUE, Branches.FALSE, Branches.ERROR};
	
	public ContextKey edge = new ContextKey("edge", Scope.LOCAL, true);
	public ContextKey graphicalModelElements = new ContextKey("graphicalModelElements", Scope.GLOBAL, true);

	@Override
	public String trace(ExecutionEnvironment ee) {
		return execute(new LightweightExecutionEnvironmentAdapter(ee));
	}
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.isEdgeUsed(env, edge.asFoundation(), graphicalModelElements.asFoundation());
	}
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), 
				"isEdgeUsed",
				"edge",
				"graphicalModelElements");
	}
	
}
