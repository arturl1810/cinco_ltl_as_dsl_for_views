package de.jabc.cinco.meta.core.mgl.sibs;

import de.jabc.cinco.meta.core.mgl.adapters.LightweightServiceAdapter;
import de.metaframe.jabc.framework.execution.ExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironmentAdapter;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.framework.sib.parameter.ContextKey.Scope;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;


@SIBClass("de/jabc/cinco/meta/core/mgl/sibs/GetAllSubTypes")
public class GetAllSubTypes extends AbstractSIB {
	public ContextKey modelElementKey = new ContextKey("modelElement",Scope.LOCAL,true);
	public ContextKey subTypesKey = new ContextKey("subTypes",Scope.LOCAL,true);
	
public java.lang.String[] BRANCHES = {"default","error"};
	
	
	@Override
	public String trace(ExecutionEnvironment environment) {
		
		return LightweightServiceAdapter.getAllSubTypes(new LightweightExecutionEnvironmentAdapter(environment),modelElementKey.asFoundation(),subTypesKey.asFoundation());
	}
	
	@Override
	public ServiceAdapterDescriptor generate() {
		return new de.metaframe.jabc.sib.ServiceAdapterDescriptor(LightweightServiceAdapter.class
				.getName(), "getAllSubTypes", "modelElementKey","subTypesKey");
		
		
	}
}
