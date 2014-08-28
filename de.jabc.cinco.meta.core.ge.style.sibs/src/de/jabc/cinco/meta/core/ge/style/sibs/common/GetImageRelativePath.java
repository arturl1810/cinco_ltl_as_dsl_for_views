package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/GetImageRelativePath")
public class GetImageRelativePath extends AbstractSIB {

	public static final String[] BRANCHES = {Branches.DEFAULT, Branches.ERROR};
	
	public ContextKey imagePath = new ContextKey("imagePath", ContextKey.Scope.LOCAL, true);
	public ContextKey relativePath = new ContextKey("relativePath", ContextKey.Scope.LOCAL, true);

	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.getImageRelativePath(env, imagePath.asFoundation(), relativePath.asFoundation());
	}
	
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), 
				"getImageRelativePath",
				"imagePath",
				"relativePath");
	}
}
