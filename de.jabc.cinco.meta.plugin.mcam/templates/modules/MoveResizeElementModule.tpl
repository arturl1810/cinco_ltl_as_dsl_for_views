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

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import graphmodel.ModelElementContainer;

public class ${ClassName} extends
		ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> {
	
	public ${GraphModelName}Id oldContainerId = null;
	public ${GraphModelName}Id newContainerId = null;

	public int oldX = 0;
	public int newX = 0;

	public int oldY = 0;
	public int newY = 0;

	public int oldWidth = 0;
	public int newWidth = 0;

	public int oldHeight = 0;
	public int newHeight = 0;

	@Override
	public String toString() {
		return "${ModelElementName} moved and resized";
	}

	@Override
	public void execute(${GraphModelName}Adapter model) {
		Object container = model.searchElementById(newContainerId);
		${ModelElementName} element_target = (${ModelElementName}) model.searchElementById(id);

		if (container instanceof ModelElementContainer) {
			element_target.moveTo((ModelElementContainer) container, newX, newY);
			element_target.resize(newWidth, newHeight);
		}
	}

	@Override
	public boolean canExecute(${GraphModelName}Adapter model) {

		Object container = model.searchElementById(newContainerId);
		if (container == null)
			return false;

		${ModelElementName} element_target = (${ModelElementName}) model.searchElementById(id);
		if (element_target == null)
			return false;

		if (container instanceof ModelElementContainer) {
			if (!element_target.canMoveTo((ModelElementContainer) container))
					return false;
		}

		return true;
	}
	
	@Override
	public void undoExecute(${GraphModelName}Adapter model) {
		Object container = model.searchElementById(oldContainerId);

		${ModelElementName} element_target = (${ModelElementName}) model.searchElementById(id);

		if (container instanceof ModelElementContainer) {
			element_target.moveTo((ModelElementContainer) container, oldX, oldY);
			element_target.resize(oldWidth, oldHeight);
		}
	}

	@Override
	public boolean canUndoExecute(${GraphModelName}Adapter model) {
		Object container = model.searchElementById(oldContainerId);
		if (container == null)
			return false;

		${ModelElementName} element_target = (${ModelElementName}) model.searchElementById(id);
		if (element_target == null)
			return false;
		
		if (container instanceof ModelElementContainer) {
			if (!element_target.canMoveTo((ModelElementContainer) container))
					return false;
		}

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
					.searchElementById(id);
			${ModelElementName} targetElement = (${ModelElementName}) targetModel
					.searchElementById(id);

			${ClassName} change = new ${ClassName}();

			change.id = id;
			
			change.oldContainerId = sourceModel.getIdByString(sourceElement.getContainer().getId());
			change.newContainerId = targetModel.getIdByString(targetElement.getContainer().getId());

			change.oldX = sourceElement.getX();
			change.newX = targetElement.getX();
			
			change.oldY = sourceElement.getY();
			change.newY = targetElement.getY();
			
			change.oldWidth = sourceElement.getWidth();
			change.newWidth = targetElement.getWidth();
			
			change.oldHeight = sourceElement.getHeight();
			change.newHeight = targetElement.getHeight();

			if (isMoved(sourceElement, targetElement) || isResized(sourceElement, targetElement)) {
				change.id = id;
				changes.add(change);
			}
		}
		for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change : changes) {
			ids.remove(change.id);
		}
		return changes;
	}

	private boolean isMoved(${ModelElementName} sourceElement, ${ModelElementName} targetElement) {
		if (sourceElement.getX() != targetElement.getX())
			return true;
		if (sourceElement.getY() != targetElement.getY())
			return true;
		return false;
	}
	
	private boolean isResized(${ModelElementName} sourceElement, ${ModelElementName} targetElement) {
		if (sourceElement.getHeight() != targetElement.getHeight())
			return true;
		if (sourceElement.getWidth() != targetElement.getWidth())
			return true;
		return false;
	}

	@Override
	public boolean hasConflictWith(
			ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change) {
		if (change instanceof ${ClassName}) {
			if (!oldContainerId.equals(((${ClassName}) change).newContainerId))
					return true;
				if (newX != ((${ClassName}) change).newX)
					return true;
				if (newY != ((${ClassName}) change).newY)
					return true;
				if (newHeight != ((${ClassName}) change).newHeight)
					return true;
				if (newWidth != ((${ClassName}) change).newWidth)
					return true;
		}
		return false;
	}

}


