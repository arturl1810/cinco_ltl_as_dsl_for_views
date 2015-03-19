package ${ChangeModulePackage};

import info.scce.mcam.framework.modules.ChangeModule;
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

import ${GraphModelPackage}.${ModelElementName};
import ${GraphModelPackage}.${GraphModelName};

import ${BasePackage}.api.c${GraphModelName?lower_case}.C${ModelElementName};
import ${BasePackage}.api.c${GraphModelName?lower_case}.C${GraphModelName};

import java.util.ArrayList;
import java.util.List;
import java.util.Set;


public class ${ModelElementName}MoveChange extends
		ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> {

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
		${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
		C${GraphModelName} cModel = model.getModelWrapper();
		C${ModelElementName} cElement = cModel.findC${ModelElementName}(element);

		cElement.setX(newX);
		cElement.setY(newY);
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
		${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
		C${GraphModelName} cModel = model.getModelWrapper();
		C${ModelElementName} cElement = cModel.findC${ModelElementName}(element);

		cElement.setX(oldX);
		cElement.setY(oldY);
	}

	@Override
	public boolean canUndoExecute(${GraphModelName}Adapter model) {
		${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
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


