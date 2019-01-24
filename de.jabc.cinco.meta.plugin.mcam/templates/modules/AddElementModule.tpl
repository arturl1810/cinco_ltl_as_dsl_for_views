package ${ChangeModulePackage};

import info.scce.mcam.framework.modules.ChangeModule;
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

import ${GraphModelPackage}.${GraphModelName?lower_case}.${ModelElementName};
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName};

<#list PossibleContainer as container>
<#if container.getName() != ModelElementName>
import ${GraphModelPackage}.${GraphModelName?lower_case}.${container.getName()};
</#if>
</#list>

import graphmodel.Container;
import graphmodel.ModelElementContainer;


import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class ${ClassName} extends ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> {

	public ${ModelElementName} element = null;
	public ${GraphModelName}Id containerId = null;

	@Override
	public String toString() {
		return "${ModelElementName} added!";
	}

	@Override
	public void execute(${GraphModelName}Adapter modelAdapter) {
		Object container = modelAdapter.searchElementById(containerId);
		if (container instanceof ModelElementContainer)
			element.clone((ModelElementContainer) container);
	}

	@Override
	public boolean canExecute(${GraphModelName}Adapter modelAdapter) {
		Object container = modelAdapter.searchElementById(containerId);
		if (container == null)
			return false;

		Object element2 = modelAdapter.searchElementById(id);
		if (element2 != null)
			return false;
		
		if (container instanceof ModelElementContainer)
			if (!element.canClone((ModelElementContainer) container))
				return false;

		return true;
	}

	@Override
	public boolean canUndoExecute(${GraphModelName}Adapter model) {
		${ModelElementName} element_new = (${ModelElementName}) model.searchElementById(id);
		if (element_new == null)
			return false;
		/*
		if (!element_new.canDelete())
			return false;
		*/

		if (element_new instanceof Container)
			if (((Container)element).getModelElements().size() > 0)
				return false;
		
		if (element_new.getIncoming().size() > 0)
			return false;
		
		if (element_new.getOutgoing().size() > 0)
			return false;

		return true;
	}

	@Override
	public void undoExecute(${GraphModelName}Adapter model) {
		${ModelElementName} element_new = (${ModelElementName}) model.searchElementById(id);
		element_new.delete();
	}

	@Override
	public List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> getChanges(${GraphModelName}Adapter sourceModel,
			${GraphModelName}Adapter targetModel, Set<${GraphModelName}Id> ids) {
		
		List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changes = new ArrayList<>();

		for (${GraphModelName}Id id : ids) {
			if (!(!sourceModel.getEntityIds().contains(id) && targetModel.getEntityIds()
					.contains(id)))
				continue;

			if (!"${ModelElementName}".equals(id.geteClass().getName()))
				continue;
			
			${ClassName} change = new ${ClassName}();
			change.id = id;
			change.element = (${ModelElementName}) targetModel.searchElementById(id);
			change.containerId = targetModel.getIdByString(change.element.getContainer().getId());
			changes.add(change);
		}
		for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change : changes) {
			ids.remove(change.id);
		}
		return changes;
	}

	@Override
	public boolean hasConflictWith(ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change) {
		if (change.id.equals(id)) {
			return true;
		}
		return false;
	}

}
