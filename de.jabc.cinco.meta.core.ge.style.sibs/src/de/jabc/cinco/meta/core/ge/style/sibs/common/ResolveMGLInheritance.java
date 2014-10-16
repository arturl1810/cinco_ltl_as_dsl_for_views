package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.adapter.common.basic.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/ResolveMGLInheritance")
public class ResolveMGLInheritance extends AbstractSIB {
	
	public static final String[] BRANCHES = new String[] {Branches.ERROR, Branches.DEFAULT}; 
	
	public ContextKey graphModel = new ContextKey("graphModelKey", ContextKey.Scope.GLOBAL, true);
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.resolveMGLInheritance(env, graphModel.asFoundation());
	}
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), "resolveMGLInheritance",
				"graphModel");
	}
}
