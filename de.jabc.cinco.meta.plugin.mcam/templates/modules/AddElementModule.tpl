package ${ChangeModulePackage};

import info.scce.mcam.framework.modules.ChangeModule;
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

import ${GraphModelPackage}.${ModelElementName};
import ${GraphModelPackage}.${GraphModelName};

<#list PossibleContainer as container>
<#if container.getName() != ModelElementName>
import ${GraphModelPackage}.${container.getName()};
</#if>
</#list>

import ${BasePackage}.api.c${GraphModelName?lower_case}.C${ModelElementName};
import ${BasePackage}.api.c${GraphModelName?lower_case}.C${GraphModelName};

import graphmodel.Container;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class ${ClassName} extends ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> {

	public C${ModelElementName} cElement = null;
	public ${GraphModelName}Id containerId = null;

	@Override
	public String toString() {
		return "${ModelElementName} added!";
	}

	@Override
	public void execute(${GraphModelName}Adapter model) {
		C${GraphModelName} cModel = model.getModelWrapper();
		Object container = model.getElementById(containerId);
		<#list PossibleContainer as container>
		if (container instanceof ${container.getName()})
			cElement.clone(cModel.findC${container.getName()}((${container.getName()}) container));
		</#list>
		if (container instanceof ${GraphModelName})
			cElement.clone(cModel);
	}

	@Override
	public boolean canExecute(${GraphModelName}Adapter model) {
		Object container = model.getElementById(containerId);
		if (container == null)
			return false;

		Object element = model.getElementById(id);
		if (element != null)
			return false;
		
		return true;
	}

	@Override
	public boolean canUndoExecute(${GraphModelName}Adapter model) {
		${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
		if (element == null)
			return false;

		if (element instanceof Container)
			if (((Container)element).getModelElements().size() > 0)
				return false;
		
		if (element.getIncoming().size() > 0)
			return false;
		
		if (element.getOutgoing().size() > 0)
			return false;

		return true;
	}

	@Override
	public void undoExecute(${GraphModelName}Adapter model) {
		${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
		C${GraphModelName} cModel = model.getModelWrapper();
		C${ModelElementName} cElement = cModel.findC${ModelElementName}(element);
		cElement.delete();
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
			
			C${GraphModelName} targetWrapper = targetModel.getModelWrapper();
			
			${ClassName} change = new ${ClassName}();
			change.id = id;
			change.cElement = targetWrapper.findC${ModelElementName}((${ModelElementName}) targetModel.getElementById(id));
			change.containerId = targetModel.getIdByString(change.cElement.getModelElement().getContainer().getId());
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
