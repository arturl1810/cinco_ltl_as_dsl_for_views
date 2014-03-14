package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.exceptions.ContextException;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextExpression;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/GenerateUniqueShapeName")
public class GenerateUniqueShapeName extends AbstractSIB {

	public static final String[] BRANCHES = { Branches.DEFAULT, Branches.ERROR };

	public ContextKey shapeName = new ContextKey("shapeName", ContextKey.Scope.LOCAL, true);
	public ContextKey uniqueShapeName = new ContextKey("uniqueShapeName", ContextKey.Scope.LOCAL, true);
	public ContextExpression clearCache = new ContextExpression("clearCache", Boolean.class);

	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.generateUniqueShapeName(env,
				shapeName.asFoundation(),
				uniqueShapeName.asFoundation(),
				clearCache.asFoundation());
	}

	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(),
				"generateUniqueShapeName", 
				"shapeName",
				"uniqueShapeName",
				"clearCache");
	}

}
