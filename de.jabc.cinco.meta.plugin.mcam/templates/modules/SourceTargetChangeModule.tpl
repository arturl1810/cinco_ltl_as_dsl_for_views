package ${ChangeModulePackage};

import info.scce.mcam.framework.modules.ChangeModule;

import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

import ${GraphModelPackage}.${GraphModelName?lower_case}.${ModelElementName};

<#list PossibleEdgeSources as source>
<#if source.getName() != ModelElementName>
import ${GraphModelPackage}.${GraphModelName?lower_case}.${source.getName()};
</#if>
</#list>

<#list PossibleEdgeTargets as target>
<#if target.getName() != ModelElementName>
import ${GraphModelPackage}.${GraphModelName?lower_case}.${target.getName()};
</#if>
</#list>

import java.util.ArrayList;
import java.util.List;
import java.util.Set;


public class ${ClassName} extends
		ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> {

	public ${GraphModelName}Id oldSource = null;
	public ${GraphModelName}Id newSource = null;

	public ${GraphModelName}Id oldTarget = null;
	public ${GraphModelName}Id newTarget = null;

	@Override
	public String toString() {
		return "${ModelElementName} reconnected: " + newSource + " --> " + newTarget;
	}

	@Override
	public void execute(${GraphModelName}Adapter model) {
		${ModelElementName} edge = (${ModelElementName}) model.getElementById(id);

		Object source = model.getElementById(newSource);
		Object target = model.getElementById(newTarget);

		<#list PossibleEdgeSources as source>
		if (source instanceof ${source.getName()})
			edge.reconnectSource((${source.getName()}) source);
		</#list>

		<#list PossibleEdgeTargets as target>
		if (target instanceof ${target.getName()})
			edge.reconnectTarget((${target.getName()}) target);
		</#list>
	}

	@Override
	public boolean canExecute(${GraphModelName}Adapter model) {
		${ModelElementName} element_target = (${ModelElementName}) model.getElementById(id);
		if (element_target == null)
			return false;
		
		Object source = model.getElementById(newSource);
		if (source == null)
			return false;

		Object target = model.getElementById(newTarget);
		if (target == null)
			return false;

		<#list PossibleEdgeSources as source>
		if (source instanceof ${source.getName()})
			if(!element_target.canReconnectSource((${source.getName()}) source))
				return false;
		</#list>

		<#list PossibleEdgeTargets as target>
		if (target instanceof ${target.getName()})
			if (!element_target.canReconnectTarget((${target.getName()}) target))
				return false;
		</#list>
		
		return true;
	}
	
	@Override
	public void undoExecute(${GraphModelName}Adapter model) {
		${ModelElementName} edge = (${ModelElementName}) model.getElementById(id);

		Object source = model.getElementById(oldSource);
		Object target = model.getElementById(oldTarget);

		<#list PossibleEdgeSources as source>
		if (source instanceof ${source.getName()})
			edge.reconnectSource((${source.getName()}) source);
		</#list>

		<#list PossibleEdgeTargets as target>
		if (target instanceof ${target.getName()})
			edge.reconnectTarget((${target.getName()}) target);
		</#list>
	}

	@Override
	public boolean canUndoExecute(${GraphModelName}Adapter model) {
		${ModelElementName} element_new = (${ModelElementName}) model.getElementById(id);
		if (element_new == null)
			return false;
		
		Object source = model.getElementById(oldSource);
		if (source == null)
			return false;

		Object target = model.getElementById(oldTarget);
		if (target == null)
			return false;

		<#list PossibleEdgeSources as source>
		if (source instanceof ${source.getName()})
			if(!element_new.canReconnectSource((${source.getName()}) source))
				return false;
		</#list>

		<#list PossibleEdgeTargets as target>
		if (target instanceof ${target.getName()})
			if (!element_new.canReconnectTarget((${target.getName()}) target))
				return false;
		</#list>
		
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
			${ModelElementName} sourceTransition = (${ModelElementName}) sourceModel
					.getElementById(id);
			${ModelElementName} targetTransition = (${ModelElementName}) targetModel
					.getElementById(id);

			${ClassName} change = new ${ClassName}();

			change.id = id;

			change.oldSource = sourceModel.getIdByString(sourceTransition
					.getSourceElement().getId());
			change.newSource = targetModel.getIdByString(targetTransition
					.getSourceElement().getId());

			change.oldTarget = sourceModel.getIdByString(sourceTransition
					.getTargetElement().getId());
			change.newTarget = targetModel.getIdByString(targetTransition
					.getTargetElement().getId());

			if (!change.oldSource.equals(change.newSource) || !change.oldTarget.equals(change.newTarget)) {
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
		if (change instanceof ${ClassName}) {
			if (((${ClassName}) change).id.equals(id)) {
				if (!newSource.equals(((${ClassName}) change).newSource))
					return true;
				if (!newTarget.equals(((${ClassName}) change).newTarget))
					return true;
			}
		}
		return false;
	}

}

