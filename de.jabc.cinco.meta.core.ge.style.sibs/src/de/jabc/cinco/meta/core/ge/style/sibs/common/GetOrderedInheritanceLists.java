package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.ExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironmentAdapter;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/GetOrderedInheritanceLists")
public class GetOrderedInheritanceLists extends AbstractSIB {

	public static final String[] BRANCHES = { Branches.DEFAULT, Branches.ERROR };
	
	public ContextKey graphModel = new ContextKey("graphModel", ContextKey.Scope.LOCAL, true);
	public ContextKey nodeInheritanceOrder = new ContextKey("nodeInheritanceOrder", ContextKey.Scope.LOCAL, true);
	public ContextKey edgeInheritanceOrder = new ContextKey("nodeInheritanceOrder", ContextKey.Scope.LOCAL, true);

	@Override
	public String trace(ExecutionEnvironment ee) {
		return execute(new LightweightExecutionEnvironmentAdapter(ee));
	}
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.getOrderedInheritanceLists(env,
				graphModel.asFoundation(),
				nodeInheritanceOrder.asFoundation(),
				edgeInheritanceOrder.asFoundation());
	}

	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(),
				"getOrderedInheritanceLists", 
				"graphModel",
				"nodeInheritanceOrder",
				"edgeInheritanceOrder");
	}
	
}
