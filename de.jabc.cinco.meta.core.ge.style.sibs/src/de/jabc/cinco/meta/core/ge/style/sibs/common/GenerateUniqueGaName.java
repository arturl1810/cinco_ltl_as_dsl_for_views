package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.ExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironmentAdapter;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextExpression;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/GenerateUniqueGaName")
public class GenerateUniqueGaName extends AbstractSIB {
	public static final String[] BRANCHES = { Branches.DEFAULT, Branches.ERROR };

	public ContextExpression graphicsAlgorithmName = new ContextExpression("graphicsAlgorithmName", String.class);
	public ContextKey uniqueGaName = new ContextKey("uniqueGaName", ContextKey.Scope.LOCAL, true);
	public ContextExpression clearCache = new ContextExpression("clearCache", Boolean.class);

	@Override
	public String trace(ExecutionEnvironment ee) {
		return execute(new LightweightExecutionEnvironmentAdapter(ee));
	}
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.generateUniqueGaName(env,
				graphicsAlgorithmName.asFoundation(),
				uniqueGaName.asFoundation(),
				clearCache.asFoundation());
	}

	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(),
				"generateUniqueGaName", 
				"graphicsAlgorithmName",
				"uniqueGaName",
				"clearCache");
	}
}
