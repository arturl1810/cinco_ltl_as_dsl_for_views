package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.framework.sib.parameter.ContextKey.Scope;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/GetEdgeSourceElementConnections")
public class GetEdgeSourceElementConnections extends AbstractSIB {

	public static final String[] BRANCHES = {Branches.DEFAULT, Branches.ERROR};

	public ContextKey edge = new ContextKey("edge", Scope.LOCAL, true);
	public ContextKey nodes = new ContextKey("nodes", Scope.GLOBAL, true);
	public ContextKey edgeSourceElementConnectionMap = new ContextKey("edgeSourceElementConnectionMap", Scope.LOCAL, true);
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.getEdgeSourceElementConnections(env, edge.asFoundation(), nodes.asFoundation(), edgeSourceElementConnectionMap.asFoundation());
	}
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), 
				"getEdgeSourceElementConnections",
				"edge",
				"nodes",
				"edgeSourceElementConnectionMap");
	}
	
}