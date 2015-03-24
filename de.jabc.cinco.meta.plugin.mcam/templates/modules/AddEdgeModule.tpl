package ${ChangeModulePackage};

import info.scce.mcam.framework.modules.ChangeModule;
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

import ${GraphModelPackage}.${ModelElementName};

<#list PossibleEdgeSources as source>
<#if source.getName() != ModelElementName>
import ${GraphModelPackage}.${source.getName()};
</#if>
</#list>

<#list PossibleEdgeTargets as target>
<#if target.getName() != ModelElementName>
import ${GraphModelPackage}.${target.getName()};
</#if>
</#list>

import ${BasePackage}.api.c${GraphModelName?lower_case}.C${ModelElementName};
import ${BasePackage}.api.c${GraphModelName?lower_case}.C${GraphModelName};

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class ${ClassName} extends ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> {

	public C${ModelElementName} cElement = null;
	public ${GraphModelName}Id sourceId = null;
	public ${GraphModelName}Id targetId = null;

	@Override
	public String toString() {
		return "${ModelElementName} added!";
	}

	@Override
	public void execute(${GraphModelName}Adapter model) {
		C${GraphModelName} cModel = model.getModelWrapper();

		Object source = model.getElementById(sourceId);		
		Object target = model.getElementById(targetId);

		<#list PossibleEdgeSources as source>
		<#list PossibleEdgeTargets as target>
		if (source instanceof ${source.getName()} && target instanceof ${target.getName()})
			cElement.clone(cModel.findC${source.getName()}((${source.getName()}) source), cModel.findC${target.getName()}((${target.getName()}) target));
		</#list>
		</#list>
	}

	@Override
	public boolean canExecute(${GraphModelName}Adapter model) {
		Object element = model.getElementById(id);
		if (element != null)
			return false;

		Object source = model.getElementById(sourceId);
		if (source == null)
			return false;
		
		Object target = model.getElementById(targetId);
		if (target == null)
			return false;
		
		return true;
	}

	@Override
	public boolean canUndoExecute(${GraphModelName}Adapter model) {
		${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
		if (element == null)
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
			${ModelElementName} element = (${ModelElementName}) targetModel.getElementById(id);
			
			${ClassName} change = new ${ClassName}();
			change.id = id;
			change.cElement = targetWrapper.findC${ModelElementName}(element);
			change.sourceId = targetModel.getIdByString(element.getSourceElement().getId());
			change.targetId = targetModel.getIdByString(element.getTargetElement().getId());
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
