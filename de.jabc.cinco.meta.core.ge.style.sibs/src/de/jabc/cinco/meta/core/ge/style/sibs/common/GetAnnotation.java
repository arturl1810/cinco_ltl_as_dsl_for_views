package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.ExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironmentAdapter;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.framework.sib.parameter.ContextKey.Scope;
import de.metaframe.jabc.framework.sib.parameter.foundation.ContextKeyFoundation;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/GetAnnotation")
public class GetAnnotation extends AbstractSIB {

	public static final String[] BRANCHES = {Branches.DEFAULT, Branches.ERROR};
	
	public ContextKey attributeKey = new ContextKey("attributeKey", Scope.LOCAL, true);
	public ContextKey annotationNameKey = new ContextKey("annotationNameKey", Scope.LOCAL, true);
	public ContextKey annotationKey = new ContextKey("annotationKey", Scope.LOCAL, true);
	
	
	@Override
	public String trace(ExecutionEnvironment ee) {
		return execute(new LightweightExecutionEnvironmentAdapter(ee));
	}
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.getAnnotation(env, 
				attributeKey.asFoundation(), 
				annotationNameKey.asFoundation(), 
				annotationKey.asFoundation());
	}
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), 
				"getAnnotation",
				"attributeKey",
				"annotationNameKey",
				"annotationKey");
	}
	
}
