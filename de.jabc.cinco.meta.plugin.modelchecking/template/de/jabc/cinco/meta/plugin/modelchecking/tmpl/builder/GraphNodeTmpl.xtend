package de.jabc.cinco.meta.plugin.modelchecking.tmpl.builder

import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.Attribute
import mgl.ModelElement
import mgl.UserDefinedType
import de.jabc.cinco.meta.plugin.modelchecking.util.ModelCheckingExtension

class GraphNodeTmpl extends FileTemplate {

	override getTargetFileName() '''GraphNode.java'''
	
	override init(){
	}

	override template() '''
		package «package»;
		
		
		public class GraphNode<D extends ModelCheckingAdditionalData> {
		
			private String contentModelID;
			private D additionalData;
		
			public GraphNode(String contentModelID, D config) {
				super();
				this.contentModelID = contentModelID;
				this.additionalData = config;
			}
		
			public String getContentModelID() {
				return contentModelID;
			}
		
			public D getAdditionalData() {
				return additionalData;
			}
			
			@Override
			public int hashCode() {
				return 11 + 17 * additionalData.hashCode() + 17 * contentModelID.hashCode();
			}
		
			@Override
			public boolean equals(Object obj) {
				if (obj instanceof GraphNode) {
					GraphNode o = (GraphNode) obj;
					boolean idequal = contentModelID.equals(o.contentModelID);
					boolean equalMa = additionalData.equals(o.additionalData);
					return idequal && equalMa;
				} else {
					return false;
				}
			}
			
			private boolean equalMaps(ModelCheckingAdditionalData map1, ModelCheckingAdditionalData map2) {
		//		for(String s : map1.keySet()) {
		//			if(map1.get(s).booleanValue() != map2.get(s).booleanValue()) {
		//				return false;
		//			}
		//		}
		//		for(String s : map2.keySet()) {
		//			if(map1.get(s).booleanValue() != map2.get(s).booleanValue()) {
		//				return false;
		//			}
		//		}
				return map1.equals(map2);
			}
		
			@Override
			public String toString() {
				return "ID:" + contentModelID + " config:" + additionalData.toString();
			}
		}

		'''
}
