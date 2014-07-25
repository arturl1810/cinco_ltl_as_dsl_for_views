package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.cinco.meta.core.ge.style.sibs.adapter.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;


@SIBClass("ge-util-sibs/CollectInlineAppearances")

public class CollectInlineAppearances extends AbstractSIB {
	public static final String[] BRANCHES = { Branches.DEFAULT, Branches.ERROR };

	public ContextKey styles = new ContextKey("styles", ContextKey.Scope.LOCAL, true);
	public ContextKey inlineAppearances = new ContextKey("inlineAppearances", ContextKey.Scope.LOCAL, true);

	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.collectInlineAppearances(env,
				styles.asFoundation(),
				inlineAppearances.asFoundation());
	}

	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(),
				"collectInlineAppearances", 
				"styles",
				"inlineAppearances");
	}
}
