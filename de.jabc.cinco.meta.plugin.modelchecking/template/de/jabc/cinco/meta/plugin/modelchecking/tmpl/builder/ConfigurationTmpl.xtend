package de.jabc.cinco.meta.plugin.modelchecking.tmpl.builder

import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.Attribute
import mgl.ModelElement
import mgl.UserDefinedType
import de.jabc.cinco.meta.plugin.modelchecking.util.ModelCheckingExtension

class ConfigurationTmpl extends FileTemplate {

	override getTargetFileName() '''Configuration.java'''
	
	override init(){
	}

	override template() '''
		package «package»;
		
		import java.util.HashMap;
		
		public class Configuration extends HashMap<String, Boolean> implements ModelCheckingAdditionalData {
		
			@Override
			public boolean isDataEqual(Object o) {
				if (!(o instanceof Configuration))
					return false;
				
				Configuration map2 = (Configuration) o;
		
				for (String s : keySet()) {
					if (get(s).booleanValue() != map2.get(s).booleanValue()) {
						return false;
					}
				}
				for (String s : map2.keySet()) {
					if (get(s).booleanValue() != map2.get(s).booleanValue()) {
						return false;
					}
				}
				return true;
			}
			
			@Override
			public Boolean get(Object arg0) {
				if(super.containsKey(arg0)) 
					return super.get(arg0);
				else 
					return false;			
			}
		}

		
		'''
}
