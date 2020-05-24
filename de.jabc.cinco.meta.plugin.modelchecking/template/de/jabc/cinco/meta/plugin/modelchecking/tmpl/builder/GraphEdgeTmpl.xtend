package de.jabc.cinco.meta.plugin.modelchecking.tmpl.builder

import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.Attribute
import mgl.ModelElement
import mgl.UserDefinedType
import de.jabc.cinco.meta.plugin.modelchecking.util.ModelCheckingExtension

class GraphEdgeTmpl extends FileTemplate {

	override getTargetFileName() '''GraphEdge.java'''
	
	override init(){
	}

	override template() '''
		package «package»;
		
		public class GraphEdge {
		
			private GraphNode start, end;
			private String label;
		
			public GraphEdge(GraphNode start, GraphNode end, String label) {
				super();
				this.start = start;
				this.end = end;
				this.label = label;
			}
		
			public GraphNode getStart() {
				return start;
			}
		
			public GraphNode getEnd() {
				return end;
			}
		
			public String getLabel() {
				return label;
			}
		
			@Override
			public int hashCode() {
				return 7 + 31 * start.hashCode() + 31 * end.hashCode() + 19 * label.hashCode();
			}
		
			@Override
			public boolean equals(Object obj) {
				if (obj instanceof GraphEdge) {
					GraphEdge other = (GraphEdge) obj;
					return start.equals(other.start) && end.equals(other.end) && label.equals(other.label);
				} else {
					return false;
				}
			}
		
			@Override
			public String toString() {
				return "start:" + start + " end:" + end + " label:" + label;
			}
		}
		'''
}
