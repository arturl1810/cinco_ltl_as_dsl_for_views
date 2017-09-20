package ${CheckModulePackage};


import de.jabc.cinco.meta.core.mgl.model.constraints.ContainmentConstraint
import graphmodel.Container
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName}

class ${ClassName} extends ${GraphModelName}Check {

	override getName() { "ContainmentCheck" }
	
	override check(${GraphModelName} model) {
		adapter.entityIds.map[element].filter(Container).forEach[check]
	}

	def check(Container container) {
		for (it : container.internalContainerElement.containmentConstraints) {
			if (!checkLowerBound(container))
				container.addError("at least " + lowerBound + " of [" + types.map[simpleName].join(', ') + "] required")
			if (!checkUpperBound(container))
				container.addError("maximum of " + upperBound + " [" + types.map[simpleName].join(', ') + "] allowed")
		}
	}

	def print(ContainmentConstraint it) {
		println("(" + types + " [" + lowerBound + "," + upperBound + "]" + ")");
	}

}
