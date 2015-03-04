package de.jabc.cinco.meta.core.ge.style.sibs.common;

import java.util.LinkedHashMap;
import java.util.Map;

import de.jabc.adapter.common.basic.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.framework.sib.parameter.ContextKey.Scope;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/PutLinkedMap")
public class PutLinkedMap extends AbstractSIB {

	public static final String[] BRANCHES = {Branches.DEFAULT, Branches.ERROR};
	
    public Map<Object, Object> elements = new LinkedHashMap<Object, Object>();
    public ContextKey variable = new ContextKey("variable", Scope.LOCAL, true);
    
    
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.putLinkedMap(env, variable.asFoundation(), this.elements);
	}

	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), 
				"putLinkedMap",
				"variable",
				"elements");
	}

}
