package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import mgl.GraphModel
import de.jabc.cinco.meta.core.ge.style.generator.runtime.editor.LazyDiagram

class DiagramTmpl extends GeneratorUtils {
	
	def generateDiagram(GraphModel gm) '''	
		package «gm.packageName»;
		
		public class «gm.fuName»Diagram extends «LazyDiagram.name» {
			
			public «gm.fuName»Diagram() {
				super("«gm.fuName»", "«gm.dtpId»");
			}
		}
	'''
}
