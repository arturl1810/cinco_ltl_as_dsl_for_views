package de.jabc.cinco.meta.core.ge.style.sibs.common;

import de.jabc.adapter.common.basic.Branches;
import de.jabc.cinco.meta.core.ge.style.sibs.adapter.ServiceAdapter;
import de.metaframe.jabc.framework.execution.ExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironmentAdapter;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContextAdapter;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("ge-util-sibs/WritePluginXMLContent")
public class WritePluginXMLContent extends AbstractSIB {
	
	public static final String[] BRANCHES = new String[] {Branches.ERROR, Branches.DEFAULT}; 
	
	public ContextKey pluginXMLPath = new ContextKey("pluginXMLPath", ContextKey.Scope.LOCAL, true);
	public ContextKey pluginXMLContent = new ContextKey("pluginXMLContent", ContextKey.Scope.LOCAL, true);
	public ContextKey projectName = new ContextKey("projectName", ContextKey.Scope.LOCAL, true);
	
	@Override
	public String trace(ExecutionEnvironment ee) {
		return execute(new LightweightExecutionEnvironmentAdapter(ee));
	}
	
	public String execute(LightweightExecutionEnvironment env) {
		return ServiceAdapter.writePluginXMLContent(env, pluginXMLPath.asFoundation(), pluginXMLContent.asFoundation(), projectName.asFoundation());
	}
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new ServiceAdapterDescriptor(ServiceAdapter.class.getName(), "writePluginXMLContent",
				"pluginXMLPath", "pluginXMLContent", "projectName");
	}
	
}
