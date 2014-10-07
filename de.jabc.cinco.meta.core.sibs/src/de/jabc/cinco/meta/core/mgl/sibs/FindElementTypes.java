package de.jabc.cinco.meta.core.mgl.sibs;


import de.jabc.cinco.meta.core.mgl.adapters.LightweightServiceAdapter;
import de.metaframe.jabc.framework.execution.ExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironmentAdapter;
import de.metaframe.jabc.framework.sib.annotation.SIBClass;
import de.metaframe.jabc.framework.sib.parameter.ContextKey;
import de.metaframe.jabc.framework.sib.parameter.ContextKey.Scope;
import de.metaframe.jabc.framework.sib.parameter.ListBox;
import de.metaframe.jabc.sib.ServiceAdapterDescriptor;

@SIBClass("de/jabc/cinco/meta/core/mgl/sibs/FindElementTypes")
public class FindElementTypes extends AbstractSIB {

	public  ContextKey graphModel = new ContextKey("graphModel", Scope.GLOBAL,true);
	public  ContextKey elementTypes = new ContextKey("elementTypes", Scope.GLOBAL,true);
	private static String[] inout = {"INCOMING","OUTGOING"};
	public  ListBox direction = new ListBox(inout, 0);
	public java.lang.String[] BRANCHES = {"default","error"};
	
	
	@Override
	public String trace(ExecutionEnvironment environment) {
		
		return LightweightServiceAdapter.findElementTypes(new LightweightExecutionEnvironmentAdapter(environment),graphModel.asFoundation(),elementTypes.asFoundation(),direction.asFoundation());
	}
	
	@Override
	public ServiceAdapterDescriptor generate() {
		System.out.println("Calling Generate for "+this.getClass().getName());
		return new de.metaframe.jabc.sib.ServiceAdapterDescriptor(LightweightServiceAdapter.class
				.getName(), "findElementTypes", "graphModel","elementTypes","direction");
		
		
	}

}
