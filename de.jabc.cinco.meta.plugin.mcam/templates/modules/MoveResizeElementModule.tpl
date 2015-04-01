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
	
		cElement.resize(newWidth, newHeight);
	}

	@Override
	public boolean canExecute(${GraphModelName}Adapter model) {
		C${GraphModelName} cModel = model.getModelWrapper();

		Object container = model.getElementById(newContainerId);
		if (container == null)
			return false;

		${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
		if (element == null)
			return false;

		C${ModelElementName} cElement = cModel.findC${ModelElementName}(element);
		if (cElement == null)
			return false;

		<#list PossibleContainer as container>
		if (container instanceof ${container.getName()})
			if (!cElement.canMoveTo(cModel.findC${container.getName()}((${container.getName()}) container)))
				return false;
		</#list>
		if (container instanceof ${GraphModelName})
			if (!cElement.canMoveTo(cModel))
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

		cElement.resize(oldWidth, oldHeight);
	}

	@Override
	public boolean canUndoExecute(${GraphModelName}Adapter model) {
		C${GraphModelName} cModel = model.getModelWrapper();

		Object container = model.getElementById(oldContainerId);
		if (container == null)
			return false;

		${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
		if (element == null)
			return false;
		
		C${ModelElementName} cElement = cModel.findC${ModelElementName}(element);
		if (cElement == null)
			return false;

		<#list PossibleContainer as container>
		if (container instanceof ${container.getName()})
			if (!cElement.canMoveTo(cModel.findC${container.getName()}((${container.getName()}) container)))
				return false;
		</#list>
		if (container instanceof ${GraphModelName})
			if (!cElement.canMoveTo(cModel))
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

			C${ModelElementName} sourceCElement = sourceModel.getModelWrapper().findC${ModelElementName}(sourceElement);
			C${ModelElementName} targetCElement = targetModel.getModelWrapper().findC${ModelElementName}(targetElement);

			${ClassName} change = new ${ClassName}();

			change.id = id;
			
			change.oldContainerId = sourceModel.getIdByString(sourceElement.getContainer().getId());
			change.newContainerId = targetModel.getIdByString(targetElement.getContainer().getId());

			change.oldX = sourceCElement.getX();
			change.newX = targetCElement.getX();
			
			change.oldY = sourceCElement.getY();
			change.newY = targetCElement.getY();
			
			change.oldWidth = sourceCElement.getWidth();
			change.newWidth = targetCElement.getWidth();
			
			change.oldHeight = sourceCElement.getHeight();
			change.newHeight = targetCElement.getHeight();

			if (isMoved(sourceCElement, targetCElement) || isResized(sourceCElement, targetCElement)) {
				change.id = id;
				changes.add(change);
			}
		}
		for (ChangeModule<FlowGraphId, FlowGraphAdapter> change : changes) {
			ids.remove(change.id);
		}
		return changes;
	}

	private boolean isMoved(C${ModelElementName} sourceElement, C${ModelElementName} targetElement) {
		if (sourceElement.getX() != targetElement.getX())
			return true;
		if (sourceElement.getY() != targetElement.getY())
			return true;
		return false;
	}
	
	private boolean isResized(C${ModelElementName} sourceElement, C${ModelElementName} targetElement) {
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


