package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.ExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironmentAdapter;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/GenerateAppearanceDefaultValues")
public class GenerateAppearanceDefaultValues extends AbstractSIB{
	public static final String[] BRANCHES = { Branches.DEFAULT, Branches.ERROR };

	public ContextKey appearance = new ContextKey("appearance", ContextKey.Scope.LOCAL, true);

	@Override
	public String trace(ExecutionEnvironment ee) {
		return execute(new LightweightExecutionEnvironmentAdapter(ee));
	}
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.generateAppearanceDefaultValues(env,
				appearance.asFoundation());
		}

	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(),
				"generateAppearance",
				"appearance");
	}
}