package ${CheckModulePackage};


import de.jabc.cinco.meta.core.mgl.model.constraints.ConnectionConstraint
import de.jabc.cinco.meta.core.mgl.model.constraints.ContainmentConstraint
import graphmodel.Container
import graphmodel.Node
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName};
import ${AdapterPackage}.${GraphModelName}Id;
import graphmodel.ModelElement

class ${ClassName} extends ${GraphModelName}Check {

	override check(${GraphModelName} model) {
		for (${GraphModelName}Id id : adapter.entityIds) {
			var me = adapter.getElementById(id);
				if (me instanceof Node)
					checkNode(me);
		}
	}

	override String getName() {
		return "OutgoingCheck";
	}

	def void checkNode(Node node) {
		//println(node);
		for (ConnectionConstraint cc : node.outgoingConstraints) {
			if (!cc.checkLowerBound(node))
				node.addError("at least " + cc.lowerBound + " of OUTGOING [" + cc.edgeTypes.map[t | t.simpleName].join(', ') + "] required")
			if (!cc.checkUpperBound(node))
				node.addError("maximum of " + cc.upperBound + " [" + cc.edgeTypes.map[t | t.simpleName].join(', ') + "] allowed")
		}
	}

	def void printConnectionContraint(ConnectionConstraint cc) {
		println("(" + cc.edgeTypes + " [" + cc.lowerBound + "," + cc.upperBound + "]" + ")");
	}

}
