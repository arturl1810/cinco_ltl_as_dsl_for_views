package ${CheckModulePackage};


import de.jabc.cinco.meta.core.mgl.model.constraints.ConnectionConstraint
import graphmodel.Node
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName}

class ${ClassName} extends ${GraphModelName}Check {

	override getName() { "OutgoingCheck" }
	
	override check(${GraphModelName} model) {
		adapter.entityIds.map[element].filter(Node).forEach[check]
	}

	def check(Node node) {
		for (it : node.outgoingConstraints) {
			if (!checkLowerBound(node))
				node.addError("at least " + lowerBound + " of OUTGOING [" + edgeTypes.map[simpleName].join(', ') + "] required")
			if (!checkUpperBound(node))
				node.addError("maximum of " + upperBound + " [" + edgeTypes.map[simpleName].join(', ') + "] allowed")
		}
	}

	def print(ConnectionConstraint it) {
		println("(" + edgeTypes + " [" + lowerBound + "," + upperBound + "]" + ")");
	}

}
