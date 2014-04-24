package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;


@SIBClass("ge-util-sibs/GetImportsPackageName")
public class GetImportsPackageName extends AbstractSIB {

	public static final String[] BRANCHES = { Branches.DEFAULT, Branches.ERROR };

	public ContextKey graphModelImports = new ContextKey("graphModelImportsKey", ContextKey.Scope.LOCAL, true);
	public ContextKey imports = new ContextKey("importsKey", ContextKey.Scope.GLOBAL, true);
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.getImportsPackageName(env,
				graphModelImports.asFoundation(),
				imports.asFoundation());
	}
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(),
				"getImportsPackageName", 
				"graphModelImports",
				"imports");
	}
	
}