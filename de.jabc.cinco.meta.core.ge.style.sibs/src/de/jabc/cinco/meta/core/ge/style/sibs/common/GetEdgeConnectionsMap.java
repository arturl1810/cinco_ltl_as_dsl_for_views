package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/GetEdgeConnectionsMap")
public class GetEdgeConnectionsMap extends AbstractSIB {

public static final String[] BRANCHES = { Branches.DEFAULT, Branches.ERROR};
	
	public ContextKey edgeKey = new ContextKey("edgeKey", ContextKey.Scope.LOCAL, true);
	public ContextKey mapKey = new ContextKey("mapKey", ContextKey.Scope.LOCAL, true);
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.getEdgeConnectionsMap(env, edgeKey.asFoundation(), mapKey.asFoundation());
	}
	
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), "getEdgeConnectionsMap",
				"edgeKey",
				"mapKey");
	}
	
}
