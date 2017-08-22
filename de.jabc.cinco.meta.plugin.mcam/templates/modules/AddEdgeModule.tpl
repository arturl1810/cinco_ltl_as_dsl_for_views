package ${ChangeModulePackage};

import info.scce.mcam.framework.modules.ChangeModule;
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

import ${GraphModelPackage}.${GraphModelName?lower_case}.${ModelElementName};

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import graphmodel.Node;

public class ${ClassName} extends ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> {

	public ${ModelElementName} element = null;
	public ${GraphModelName}Id sourceId = null;
	public ${GraphModelName}Id targetId = null;

	@Override
	public String toString() {
		return "${ModelElementName} added!";
	}

	@Override
	public void execute(${GraphModelName}Adapter model) {

		Object source = model.getElementById(sourceId);		
		Object target = model.getElementById(targetId);
		
		if (source instanceof Node && target instanceof Node)
			element.clone((Node) source, (Node) target);
	}

	@Override
	public boolean canExecute(${GraphModelName}Adapter model) {
		Object element_target = model.getElementById(id);
		if (element_target != null)
			return false;

		Object source = model.getElementById(sourceId);
		if (source == null)
			return false;
		
		Object target = model.getElementById(targetId);
		if (target == null)
			return false;

		if (source instanceof Node && target instanceof Node)
			if (!element.canClone((Node) source, (Node) target))
				return false;
		
		return true;
	}

	@Override
	public boolean canUndoExecute(${GraphModelName}Adapter model) {
		${ModelElementName} element_target = (${ModelElementName}) model.getElementById(id);
		if (element_target == null)
			return false;
		/*
		if (!element_target.canDelete())
			return false;
		*/

		return true;
	}

	@Override
	public void undoExecute(${GraphModelName}Adapter model) {
		${ModelElementName} element_target = (${ModelElementName}) model.getElementById(id);
		element_target.delete();
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
			
			${ModelElementName} element = (${ModelElementName}) targetModel.getElementById(id);
			
			${ClassName} change = new ${ClassName}();
			change.id = id;
			change.element = element;
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
