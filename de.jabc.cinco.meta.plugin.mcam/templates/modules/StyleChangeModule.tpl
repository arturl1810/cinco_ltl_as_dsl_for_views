package ${Package};

import info.scce.mcam.framework.modules.ChangeModule;
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

import ${GraphPackage}.${ModelElementName};

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class ${ClassName} extends ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> {

	@Override
	public String toString() {
		return "Style changed!";
	}

	@Override
	public void execute(${GraphModelName}Adapter model) {
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
			
			if (styleHasChanged(sourceElement, targetElement)) {
				${ClassName} change = new ${ClassName}();
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
	public boolean hasConflictWith(ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change) {
		if (change instanceof ${ClassName}) {
			if (((${ClassName}) change).id.equals(id)) {
				return true;
			}
		}
		return false;
	}

	private boolean styleHasChanged(${ModelElementName} sourceElement, ${ModelElementName} targetElement) {
		if (sourceElement.getX() != targetElement.getX())
			return true;
		if (sourceElement.getY() != targetElement.getY())
			return true;
		if (sourceElement.getHeight() != targetElement.getHeight())
			return true;
		if (sourceElement.getWidth() != targetElement.getWidth())
			return true;
		return false;
	}

}
