package ${ChangeModulePackage};

import graphmodel.Node;

import graphicalgraphmodel.CNode;
import info.scce.mcam.framework.modules.ChangeModule;

import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

import ${BasePackage}.api.c${GraphModelName?lower_case}.C${GraphModelName};
import ${BasePackage}.api.c${GraphModelName?lower_case}.C${ModelElementName};

import ${GraphModelPackage}.${ModelElementName};

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import org.eclipse.emf.common.util.EList;

public class ${ClassName} extends
		ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> {

	${GraphModelName}Id oldSource = null;
	${GraphModelName}Id newSource = null;

	${GraphModelName}Id oldTarget = null;
	${GraphModelName}Id newTarget = null;

	@Override
	public String toString() {
		return "${ModelElementName} reconnected: " + newSource + " --> " + newTarget;
	}

	@Override
	public void execute(${GraphModelName}Adapter model) {
		${ModelElementName} edge = (${ModelElementName}) model.getElementById(id);
		C${GraphModelName} cModel = model.getModelWrapper();
		C${ModelElementName} cEdge = cModel.findC${ModelElementName}(edge);

		CNode cSource = null;
		CNode cTarget = null;

		EList<CNode> cNodes = cModel.getAllCNodes();
		for (CNode cNode : cNodes) {
			${GraphModelName}Id tempId = model.create${GraphModelName}Id(cNode
					.getModelElement());
			if (tempId.equals(newSource))
				cSource = cNode;
			if (tempId.equals(newTarget))
				cTarget = cNode;
		}

		if (cSource != null)
			cEdge.setSourceElement(cSource);
		if (cTarget != null)
			cEdge.setTargetElement(cTarget);
	}

	@Override
	public boolean canExecute(${GraphModelName}Adapter model) {
		boolean allPreconditionsOk = true;
		
		${ModelElementName} element = (${ModelElementName}) model.getElementById(id);
		if (element == null)
			allPreconditionsOk = false;
		
			Node sourceNode = element.getSourceElement();
			${GraphModelName}Id sourceId = model.getIdByString(sourceNode.getId());
			if (sourceId == null)
				allPreconditionsOk = false;
			
			Node targetNode = element.getTargetElement();
			${GraphModelName}Id targetId = model.getIdByString(targetNode.getId());
			if (targetId == null)
				allPreconditionsOk = false;
		
		return allPreconditionsOk;
	}
	
	@Override
	public void undoExecute(${GraphModelName}Adapter model) {
		${ModelElementName} edge = (${ModelElementName}) model.getElementById(id);
		C${GraphModelName} cModel = model.getModelWrapper();
		C${ModelElementName} cEdge = cModel.findC${ModelElementName}(edge);

		CNode cSource = null;
		CNode cTarget = null;

		EList<CNode> cNodes = cModel.getAllCNodes();
		for (CNode cNode : cNodes) {
			${GraphModelName}Id tempId = model.create${GraphModelName}Id(cNode
					.getModelElement());
			if (tempId.equals(oldSource))
				cSource = cNode;
			if (tempId.equals(oldTarget))
				cTarget = cNode;
		}

		if (cSource != null)
			cEdge.setSourceElement(cSource);
		if (cTarget != null)
			cEdge.setTargetElement(cTarget);
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

			change.oldSource = sourceModel.create${GraphModelName}Id(sourceTransition
					.getSourceElement());
			change.newSource = targetModel.create${GraphModelName}Id(targetTransition
					.getSourceElement());

			change.oldTarget = sourceModel.create${GraphModelName}Id(sourceTransition
					.getTargetElement());
			change.newTarget = targetModel.create${GraphModelName}Id(targetTransition
					.getTargetElement());

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

