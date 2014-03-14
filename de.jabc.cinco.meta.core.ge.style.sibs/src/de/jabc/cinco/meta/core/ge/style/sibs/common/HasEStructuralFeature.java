package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextExpression;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/HasEStructuralFeature")
public class HasEStructuralFeature extends AbstractSIB {
	
	public static final String[] BRANCHES = {Branches.TRUE, Branches.FALSE, Branches.ERROR};
	
	public ContextKey eClass = new ContextKey("eClass", ContextKey.Scope.LOCAL, true);
	public ContextExpression featureName = new ContextExpression("featureName", String.class);
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.hasEStructuralFeature(env, eClass.asFoundation(), featureName.asFoundation());
	}
	
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), 
				"hasEStructuralFeature",
				"eClass",
				"featureName");
	}
	
}
