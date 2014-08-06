package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.framework.sib.parameter.ContextKey.Scope;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/GetEdgeTargetElementConnections")
public class GetEdgeTargetElementConnections extends AbstractSIB {

	public static final String[] BRANCHES = {Branches.DEFAULT, Branches.ERROR};

	public ContextKey edge = new ContextKey("edge", Scope.LOCAL, true);
	public ContextKey graphicalModelElements = new ContextKey("graphicalModelElements", Scope.GLOBAL, true);
	public ContextKey edgeTargetElementConnectionMap = new ContextKey("edgeTargetElementConnectionMap", Scope.LOCAL, true);
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.getEdgeTargetElementConnections(env, edge.asFoundation(), graphicalModelElements.asFoundation(), edgeTargetElementConnectionMap.asFoundation());
	}
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), 
				"getEdgeTargetElementConnections",
				"edge",
				"graphicalModelElements",
				"edgeTargetElementConnectionMap");
	}
	
}
