package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class AbstractContextTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».extension;
	
	import java.util.HashMap;
	import java.util.Map.Entry;
	
	import org.eclipse.swt.widgets.Shell;
	
	/**
	 * Extension point class to define an execution context.
	 * The context itself is described as a key value map
	 * @author zweihoff
	 *
	 */
	public abstract class AbstractContext {
		
		/**
		 * The context as a key -> value map
		 */
		private HashMap<String, Object> map;
		
		/**
		 * Creates the context
		 */
		public AbstractContext()
		{
			map = new HashMap<String, Object>();
		}
		
		/**
		 * Initializes the context with user input
		 * @param shell Enables the creation of dialogs
		 * @return boolean True, if the context initialized correctly, else false
		 */
		public abstract boolean initialize(Shell shell);
		
		/**
		 * Returns the context value to a given key
		 * @param key
		 * @return Object
		 */
		public final Object getContextEntry(String key)
		{
			return map.get(key);
		}
		
		/**
		 * Adds an object to a given key
		 * @param object
		 */
		public final void setContext(String key,Object object)
		{
			map.put(key, object);
		}
		
		/**
		 * The display entry method has to be implemented to vidualize
		 * the entries of the context. It will be called for every value
		 * present in the context map.
		 * @param ob The value of the map
		 * @return
		 */
		public abstract String displayEntry(Object ob);
		
		/**
		 * Summarizes the entire current context.
		 * Uses the display entry method to visualize
		 * every entry of the context.
		 */
		public final String toString()
		{
			String s = "";
			for(Entry<String, Object> e :map.entrySet())
			{
				s+=displayEntry(e.getValue())+"\n";
			}
			return s;
		}
	}
	
	'''
	
	override fileName() {
		return "AbstractContext.java"
	}
	
}