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

import java.util.ArrayList;
import java.util.List;
import java.util.Set;


public class ${ModelElementName}MoveChange extends
		ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> {
	
	${GraphModelName}Id oldContainerId = null;
	${GraphModelName}Id newContainerId = null;

	int oldX = 0;
	int newX = 0;

	int oldY = 0;
	int newY = 0;

	@Override
	public String toString() {
		return "${ModelElementName} moved";
	}

	@Override
	public void execute(${GraphModelName}Adapter model) {
		C${GraphModelName} cModel = model.getModelWrapper();
		Object container = model.getElementById(newContainerId);

		${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
		C${ModelElementName} cElement = cModel.findC${ModelElementName}(element);

		<#list PossibleContainer as container>
		if (container instanceof ${container.getName()})
			cElement.moveTo(cModel.findC${container.getName()}((${container.getName()}) container), newX, newY);
		</#list>
		if (container instanceof ${GraphModelName})
			cElement.moveTo(cModel, newX, newY);
	}

	@Override
	public boolean canExecute(${GraphModelName}Adapter model) {
		Object container = model.getElementById(newContainerId);
		if (container == null)
			return false;

		Object element = model.getElementById(id);
		if (element == null)
			return false;
		
		return true;
	}
	
	@Override
	public void undoExecute(${GraphModelName}Adapter model) {
		C${GraphModelName} cModel = model.getModelWrapper();
		Object container = model.getElementById(oldContainerId);

		${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
		C${ModelElementName} cElement = cModel.findC${ModelElementName}(element);

		<#list PossibleContainer as container>
		if (container instanceof ${container.getName()})
			cElement.moveTo(cModel.findC${container.getName()}((${container.getName()}) container), oldX, oldY);
		</#list>
		if (container instanceof ${GraphModelName})
			cElement.moveTo(cModel, oldX, oldY);
	}

	@Override
	public boolean canUndoExecute(${GraphModelName}Adapter model) {
		Object container = model.getElementById(oldContainerId);
		if (container == null)
			return false;

		Object element = model.getElementById(id);
		if (element == null)
			return false;
		
		return true;
	}

	@Override
	public List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> getChanges(
			${GraphModelName}Adapter sourceModel, ${GraphModelName}Adapter targetModel,
			Set<${GraphModelName}Id> ids) {

		List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changes = new ArrayList<>();

		for (${GraphModelName}Id id : ids) {
			if (!(sourceModel.getEntityIds().contains(id) && targetModel
					.getEntityIds().contains(id)))
				continue;

			if (!"${ModelElementName}".equals(id.geteClass().getName()))
				continue;
			
			${ModelElementName} sourceElement = (${ModelElementName}) sourceModel
					.getElementById(id);
			${ModelElementName} targetElement = (${ModelElementName}) targetModel
					.getElementById(id);

			${ModelElementName}MoveChange change = new ${ModelElementName}MoveChange();

			change.id = id;

			change.oldX = sourceModel.getModelWrapper().findC${ModelElementName}(sourceElement).getX();
			change.newX = targetModel.getModelWrapper().findC${ModelElementName}(targetElement).getX();
			
			change.oldY = sourceModel.getModelWrapper().findC${ModelElementName}(sourceElement).getY();
			change.newY = targetModel.getModelWrapper().findC${ModelElementName}(targetElement).getY();
			
			change.oldContainerId = sourceModel.getIdByString(sourceElement.getContainer().getId());
			change.newContainerId = targetModel.getIdByString(targetElement.getContainer().getId());

			if (change.oldX != change.newX || change.oldY != change.newY) {
				change.id = id;
				changes.add(change);
			}
		}
		for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change : changes) {
			ids.remove(change.id);
		}
		return changes;
	}

	@Override
	public boolean hasConflictWith(
			ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change) {
		if (change instanceof ${ModelElementName}MoveChange) {
			if (((${ModelElementName}MoveChange) change).id.equals(id)) {
				if (newX != ((${ModelElementName}MoveChange) change).newX)
					return true;
				if (newY != ((${ModelElementName}MoveChange) change).newY)
					return true;
			}
		}
		return false;
	}

}


