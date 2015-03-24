package ${ChangeModulePackage};

import info.scce.mcam.framework.modules.ChangeModule;
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

import ${GraphModelPackage}.${ModelElementName};

import ${BasePackage}.api.c${GraphModelName?lower_case}.C${ModelElementName};
import ${BasePackage}.api.c${GraphModelName?lower_case}.C${GraphModelName};

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class ${ModelElementName}DeleteChange extends ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> {

	public C${ModelElementName} cElement = null;
	public ${GraphModelName}Id sourceId = null;
	public ${GraphModelName}Id targetId = null;

	@Override
	public String toString() {
		return "${ModelElementName} deleted!";
	}
	
	private ${ModelElementName}AddChange getOppositeChange() {
		${ModelElementName}AddChange addChange = new ${ModelElementName}AddChange();
		addChange.id = id;
		addChange.showOutput = showOutput;
		addChange.cElement = cElement;
		addChange.sourceId = sourceId;
		addChange.targetId = targetId;
		return addChange;
	}

	@Override
	public boolean canExecute(${GraphModelName}Adapter model) {
		return getOppositeChange().canUndoExecute(model);
	}

	@Override
	public void execute(${GraphModelName}Adapter model) {
		getOppositeChange().undoExecute(model);
	}

	@Override
	public void undoExecute(${GraphModelName}Adapter model) {
		getOppositeChange().execute(model);
	}

	@Override
	public boolean canUndoExecute(${GraphModelName}Adapter model) {
		return getOppositeChange().canExecute(model);
	}

	@Override
	public List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> getChanges(${GraphModelName}Adapter sourceModel,
			${GraphModelName}Adapter targetModel, Set<${GraphModelName}Id> ids) {
		
		List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changes = new ArrayList<>();

		for (${GraphModelName}Id id : ids) {
			if (!(sourceModel.getEntityIds().contains(id) && !targetModel.getEntityIds()
					.contains(id)))
				continue;

			if (!"${ModelElementName}".equals(id.geteClass().getName()))
				continue;
			
			C${GraphModelName} sourceWrapper = sourceModel.getModelWrapper();
			${ModelElementName} element = (${ModelElementName}) sourceModel.getElementById(id);
			
			${ClassName} change = new ${ClassName}();
			change.id = id;
			change.cElement = sourceWrapper.findC${ModelElementName}(element);
			change.sourceId = sourceModel.getIdByString(element.getSourceElement().getId());
			change.targetId = sourceModel.getIdByString(element.getTargetElement().getId());
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
			if (!(change instanceof ${ClassName})) {
				return true;
			}
		}
		return false;
	}

}
