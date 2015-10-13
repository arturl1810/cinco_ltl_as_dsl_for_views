package de.jabc.cinco.meta.core.ge.style.sibs.common;

import java.util.LinkedHashMap;
import java.util.Map;

import de.jabc.adapter.common.basic.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.ExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironmentAdapter;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.framework.sib.parameter.ContextKey.Scope;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/PutDynamicLinkedMap")
public class PutDynamicLinkedMap extends AbstractSIB {

	public static final String[] BRANCHES = {Branches.DEFAULT, Branches.ERROR};
	
    public Map<Object, String> elements = new LinkedHashMap<Object, String>();
    public ContextKey variable = new ContextKey("variable", Scope.LOCAL, true);
    

	@Override
	public String trace(ExecutionEnvironment ee) {
		return execute(new LightweightExecutionEnvironmentAdapter(ee));
	}
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.putDynamicLinkedMap(env, variable.asFoundation(), this.elements);
	}

	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), 
				"putDynamicLinkedMap",
				"variable",
				"elements");
	}

}
