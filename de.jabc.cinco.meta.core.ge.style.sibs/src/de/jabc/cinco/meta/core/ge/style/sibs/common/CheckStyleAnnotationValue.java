package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/CheckStyleAnnotationValue")
public class CheckStyleAnnotationValue extends AbstractSIB {

	public static final String[] BRANCHES = { "NodeAttribute", "PrimeRef", Branches.DEFAULT, Branches.ERROR, Branches.EMPTY_STRING };
	
	public ContextKey modelElement = new ContextKey("modelElement", ContextKey.Scope.LOCAL, true);
	public ContextKey value = new ContextKey("value", ContextKey.Scope.LOCAL, true);
	public ContextKey attributeName = new ContextKey("attributeName", ContextKey.Scope.LOCAL, true);
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.checkStyleAnnotationValue(env, modelElement.asFoundation(), value.asFoundation(), attributeName.asFoundation());
	}
	
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), 
				"checkStyleAnnotationValue",
				"modelElement",
				"value",
				"attributeName");
	}
}
