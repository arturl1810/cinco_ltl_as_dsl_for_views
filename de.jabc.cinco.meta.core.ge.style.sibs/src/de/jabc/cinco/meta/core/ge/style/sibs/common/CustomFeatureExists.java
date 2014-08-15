package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/CustomFeatureExists")
public class CustomFeatureExists extends AbstractSIB {
	
	public static final String[] BRANCHES = { Branches.TRUE, Branches.FALSE, Branches.ERROR};
	
	public ContextKey annotation = new ContextKey("annotation", ContextKey.Scope.LOCAL, true);
	public ContextKey className = new ContextKey("className", ContextKey.Scope.LOCAL, true);
	public ContextKey packageName = new ContextKey("packageName", ContextKey.Scope.LOCAL, true);
	public ContextKey baseDir = new ContextKey("baseDir", ContextKey.Scope.LOCAL, true);
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.customFeatureExists(env, annotation.asFoundation(), className.asFoundation(),
				packageName.asFoundation(),	baseDir.asFoundation());
	}
	
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), "customFeatureExists",
				"annotation",
				"className",
				"packageName",
				"baseDir");
	}

}
