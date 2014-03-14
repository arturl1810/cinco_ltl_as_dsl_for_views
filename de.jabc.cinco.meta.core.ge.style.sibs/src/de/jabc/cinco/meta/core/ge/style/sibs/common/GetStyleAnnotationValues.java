package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;


@SIBClass("ge-util-sibs/GetStyleAnnotationValues")
public class GetStyleAnnotationValues extends AbstractSIB {

public static final String[] BRANCHES = { Branches.DEFAULT, Branches.ERROR };
	
	public ContextKey annotation = new ContextKey("annotation", ContextKey.Scope.LOCAL, true);
	public ContextKey values = new ContextKey("values", ContextKey.Scope.LOCAL, true);
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.getStyleAnnotationValues(env, annotation.asFoundation(), values.asFoundation());
	}
	
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), "getStyleAnnotationValues",
				"annotation", "values");
	}
	
}
