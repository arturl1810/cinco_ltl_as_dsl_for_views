package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/GetStyleAnnotation")
public class GetStyleAnnotation extends AbstractSIB {

public static final String[] BRANCHES = { Branches.DEFAULT, Branches.ERROR };
	
	public ContextKey annotations = new ContextKey("annotations", ContextKey.Scope.LOCAL, true);
	public ContextKey annotation = new ContextKey("annotation", ContextKey.Scope.LOCAL, true);
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.getStyleAnnotation(env, annotations.asFoundation(), annotation.asFoundation());
	}
	
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), "getStyleAnnotation",
				"annotations", "annotation");
	}
	
}
