package ${ChangeModulePackage};

import info.scce.mcam.framework.modules.ChangeModule;
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

import ${GraphModelPackage}.${ModelElementName};

import ${BasePackage}.api.c${GraphModelName?lower_case}.C${ModelElementName};

<#if ModelElementName != GraphModelName>
import ${BasePackage}.api.c${GraphModelName?lower_case}.C${GraphModelName};
</#if>

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class ${ClassName} extends ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> {

	public String attributeName = "${AttributeName}";
	public ${AttributeType} oldValue = null;
	public ${AttributeType} newValue = null;
	<#if AttributeCategory == "ModelElement">
	public ${GraphModelName}Id oldValueId = null;
	public ${GraphModelName}Id newValueId = null;
	</#if>

	@Override
	public String toString() {
		<#if AttributeCategory == "ModelElement">
		return "${AttributeName?cap_first} changed from '" + oldValueId + "' to '" + newValueId + "'";
		<#else>
		return "${AttributeName?cap_first} changed from '" + oldValue + "' to '" + newValue + "'";
		</#if>
	}

	@Override
	public void execute(${GraphModelName}Adapter model) {
		C${GraphModelName} cModel = model.getModelWrapper();
		<#if ModelElementName == GraphModelName>
		cModel.set${AttributeName?cap_first}(newValue);
		<#else>
		${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
		C${ModelElementName} cElement = cModel.findC${ModelElementName}(element);
		cElement.set${AttributeName?cap_first}(newValue);
		</#if>
	}

	@Override
	public boolean canExecute(${GraphModelName}Adapter model) {
		${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
		if (element == null)
			return false;
		
		return true;
	}

	@Override
	public void undoExecute(${GraphModelName}Adapter model) {
		C${GraphModelName} cModel = model.getModelWrapper();
		<#if ModelElementName == GraphModelName>
		cModel.set${AttributeName?cap_first}(oldValue);
		<#else>
		${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
		C${ModelElementName} cElement = cModel.findC${ModelElementName}(element);
		cElement.set${AttributeName?cap_first}(oldValue);
		</#if>
	}

	@Override
	public boolean canUndoExecute(${GraphModelName}Adapter model) {
		${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
		if (element == null)
			return false;
		
		return true;
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

			boolean changed = false;

			if (sourceElement.get${AttributeName?cap_first}() == null && targetElement.get${AttributeName?cap_first}() != null) {
				changed = true;
			} else if (sourceElement.get${AttributeName?cap_first}() != null && targetElement.get${AttributeName?cap_first}() == null) {
				changed = true;
			} else if (sourceElement.get${AttributeName?cap_first}() != null && targetElement.get${AttributeName?cap_first}() != null) {
				<#if AttributeCategory == "ModelElement">
				if (!sourceElement.get${AttributeName?cap_first}().getId().equals(targetElement.get${AttributeName?cap_first}().getId())) {
					changed = true;				
				}
				<#else>
				if (!sourceElement.get${AttributeName?cap_first}().equals(targetElement.get${AttributeName?cap_first}())) {
					changed = true;				
				}
				</#if>
			}
				
			if (changed) {			
				${ClassName} change = new ${ClassName}();
				change.id = id;
				change.oldValue = sourceElement.get${AttributeName?cap_first}();
				change.newValue = targetElement.get${AttributeName?cap_first}();
				<#if AttributeCategory == "ModelElement">
				change.oldValueId = sourceModel.getIdByString(sourceElement.getMyNode().getId());
				change.newValueId = targetModel.getIdByString(targetElement.getMyNode().getId());
				</#if>
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
				if (!this.newValue.equals(((${ClassName}) change).newValue)) {
					return true;
				}
			}
		}
		return false;
	}

}
