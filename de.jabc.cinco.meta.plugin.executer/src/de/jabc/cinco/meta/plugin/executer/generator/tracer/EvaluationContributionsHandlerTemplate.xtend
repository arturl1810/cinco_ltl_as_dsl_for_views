package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class EvaluationContributionsHandlerTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "EvaluateContributionsHandler.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».handler;
	
	import java.util.LinkedList;
	import java.util.List;
	
	import org.eclipse.core.runtime.CoreException;
	import org.eclipse.core.runtime.IConfigurationElement;
	import org.eclipse.core.runtime.IExtension;
	import org.eclipse.core.runtime.IExtensionPoint;
	import org.eclipse.core.runtime.IExtensionRegistry;
	import org.eclipse.e4.core.di.annotations.Execute;
	
	import «graphmodel.tracerPackage».extension.AbstractContext;
	import «graphmodel.tracerPackage».extension.AbstractRunner;
	import «graphmodel.tracerPackage».extension.AbstractSemantic;
	
	/**
	 * Evaluates the extension point defined by this plug in.
	 * @author zweihoff
	 *
	 */
	public class EvaluateContributionsHandler {
		
		private List<ExecutionTupel> tupels;
		private List<AbstractRunner> runner;
		
		public EvaluateContributionsHandler()
		{
			tupels = new LinkedList<ExecutionTupel>();
			runner = new LinkedList<AbstractRunner>();
		}
		
		/**
		 * Extension point for the tracer.
		 * Includes an abstract semantic and an abstract context
		 */
	    private static final String EXECUTION_ID =
	                    "«graphmodel.tracerPackage»";
	    
	    /**
	     * Extension point for a Runner.
	     * Includes an abstract runner.
	     */
	    private static final String RUNNER_ID =
	            "«graphmodel.runnerPackage»";
	    
	    /**
	     * Collects the extension point implementations
	     * for both extension ids
	     * @param registry
	     */
	    @Execute
	    public void execute(IExtensionRegistry registry) {
	    		IExtensionPoint pointTracer = registry.getExtensionPoint(EXECUTION_ID);
	            
	               for (IExtension e : pointTracer.getExtensions()) {
				    		try {
								readExtension(e);
							} catch (CoreException e1) {
								e1.printStackTrace();
							}
	               }
	               
	               IExtensionPoint pointRunner = registry.getExtensionPoint(RUNNER_ID);
	               
	               for (IExtension e : pointRunner.getExtensions()) {
				    		try {
								readExtension(e);
							} catch (CoreException e1) {
								e1.printStackTrace();
							}
	               }
	               
	    }
	    
	    /**
	     * Read the single implementations for the semantic, context and runner.
	     * Combine the semantic and context by execution tupel.
	     * @param extension
	     * @throws CoreException
	     */
	    private void readExtension(IExtension extension) throws CoreException
	    {
			for (IConfigurationElement elem : extension
					.getConfigurationElements()) {
				if (elem.getName().equals("executionsemantic")) {
					ExecutionTupel et = new ExecutionTupel();
					
	
					final Object c = elem.createExecutableExtension("context");
		            if (c instanceof AbstractContext) {
		                    et.setContext((AbstractContext) c);
		            }
		            
		            final Object o = elem.createExecutableExtension("semantic");
		            if (o instanceof AbstractSemantic) {
		                    et.setSemantic((AbstractSemantic) o);
		            }
		            if(et.getContext() != null && et.getSemantic() != null){
		            		tupels.add(et);		            	
		            }
				
				}
				if (elem.getName().equals("executionrunner")) {
					final Object c = elem.createExecutableExtension("runner");
		            if (c instanceof AbstractRunner) {
		                    runner.add((AbstractRunner) c);
		            }
		            
				
				}
			}
			
	    }
	
		public List<ExecutionTupel> getTupels() {
			return tupels;
		}
	
		public void setTupels(List<ExecutionTupel> tupels) {
			this.tupels = tupels;
		}
	
		public List<AbstractRunner> getRunner() {
			return runner;
		}
	
		public void setRunner(List<AbstractRunner> runner) {
			this.runner = runner;
		}
	    
	    
	
	}
	
	'''
	
}