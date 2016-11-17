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
				if (me instanceof Container)
					checkContainer(me);
		}
	}

	override String getName() {
		return "ContainmentCheck";
	}

	def void checkContainer(Container container) {
		//println(container);
		for (ContainmentConstraint cc : container.containmentConstraints) {
			if (!cc.checkLowerBound(container))
				container.addError("at least " + cc.lowerBound + " of [" + cc.types.map[t | t.simpleName].join(', ') + "] required")
			if (!cc.checkUpperBound(container))
				container.addError("maximum of " + cc.upperBound + " [" + cc.types.map[t | t.simpleName].join(', ') + "] allowed")
		}
	}

	def void printContainmentConstraint(ContainmentConstraint cc) {
		println("(" + cc.types + " [" + cc.lowerBound + "," + cc.upperBound + "]" + ")");
	}

}
