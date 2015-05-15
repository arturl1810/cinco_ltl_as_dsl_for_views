package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.framework.sib.parameter.ContextKey.Scope;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/IsCreateDisabled")
public class IsCreateDisabled extends AbstractSIB {
	public static final String[] BRANCHES = {Branches.TRUE, Branches.FALSE, Branches.ERROR};
		
		public ContextKey modelElement = new ContextKey("modelElement", Scope.LOCAL, true);
		
		public String execute(LightweightExecutionEnvironment env) {
			return ServiceAdapter.isCreateDisabled(env, modelElement.asFoundation());
		}
		
		@Override
		public ServiceAdapterDescriptor generate() {
			return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), 
					"isCreateDisabled",	"modelElement");
		}
}
