package ${ChangeModulePackage};

import info.scce.mcam.framework.modules.ChangeModule;
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

import ${GraphModelPackage}.${ModelElementName};
import graphmodel.IdentifiableElement;
import graphmodel.ModelElementContainer;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class ${ClassName} extends ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> {

	public FlowGraphId oldContainerId = null;
	public FlowGraphId newContainerId = null;

	public ModelElementContainer oldContainer = null;
	public ModelElementContainer newContainer = null;

	@Override
	public String toString() {
		return "Containment changed from '" + oldContainerId + "' to '" + newContainerId + "'";
	}

	@Override
	public void execute(${GraphModelName}Adapter model) {
		${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
		element.setContainer(newContainer);
	}

	@Override
	public List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> getChanges(${GraphModelName}Adapter sourceModel,
			${GraphModelName}Adapter targetModel, Set<${GraphModelName}Id> ids) {
		
		List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changes = new ArrayList<>();

		for (${GraphModelName}Id id : ids) {
			if (!(sourceModel.getEntityIds().contains(id) && targetModel.getEntityIds()
					.contains(id)))
				continue;

			if (!"${ModelElementName}".equals(id.geteClass().getName()))
				continue;

			${ModelElementName} sourceElement = (${ModelElementName}) sourceModel.getElementById(id);
			${ModelElementName} targetElement = (${ModelElementName}) targetModel.getElementById(id);

			${ClassName} change = new ${ClassName}();
			change.id = id;

			change.oldContainer = sourceElement.getContainer();
			change.newContainer = targetElement.getContainer();

			change.oldContainerId = sourceModel.getIdByString(((IdentifiableElement) change.oldContainer).getId());
			change.newContainerId = targetModel.getIdByString(((IdentifiableElement) change.newContainer).getId());
			
			if (!change.oldContainerId.equals(change.newContainerId)) {
				changes.add(change);
			}
		}
		for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change : changes) {
			ids.remove(change.id);
		}
		return changes;
	}

	@Override
	public boolean hasConflictWith(ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change) {
		if (change instanceof ${ClassName}) {
			if (((${ClassName}) change).id.equals(id)) {
				if (!this.newContainerId.equals(((${ClassName}) change).newContainerId)) {
					return true;
				}
			}
		}
		return false;
	}

}
