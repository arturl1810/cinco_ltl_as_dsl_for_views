package ${ChangeModulePackage};

import graphmodel.Edge;
import graphmodel.Node;

import info.scce.mcam.framework.modules.ChangeModule;
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

import ${GraphModelPackage}.${ModelElementName};

import ${BasePackage}.api.c${GraphModelName?lower_case}.C${ModelElementName};
import ${BasePackage}.api.c${GraphModelName?lower_case}.C${GraphModelName};

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import org.eclipse.emf.common.util.EList;

public class ${ClassName} extends ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> {

	@Override
	public String toString() {
		return "${ModelElementName?capitalize} deleted!";
	}

	@Override
	public void execute(${GraphModelName}Adapter model) {
		//${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
		//C${GraphModelName} cModel = model.getModelWrapper();
		//C${ModelElementName} cElement = cModel.findC${ModelElementName}(element);
		//cModel.deleteModelElement(cElement);
	}

	@Override
	public boolean canExecute(${GraphModelName}Adapter model) {
		boolean allPreconditionsOk = true;
		${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
		if (element == null)
			allPreconditionsOk = false;
		
		if (element instanceof Node) {
			EList<Edge> incEdges = ((Node) element).getIncoming();
			if (incEdges.size() > 0)
				allPreconditionsOk = false;
			
			EList<Edge> outEdges = ((Node) element).getOutgoing();
			if (outEdges.size() > 0)
				allPreconditionsOk = false;
		}
		
		return allPreconditionsOk;
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
			
			if (true) {
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
		if (change.id.equals(id)) {
			if (!(change instanceof ${ClassName})) {
				return true;
			}
		}
		return false;
	}

}
