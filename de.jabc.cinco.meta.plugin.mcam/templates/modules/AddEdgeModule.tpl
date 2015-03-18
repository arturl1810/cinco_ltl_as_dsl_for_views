package ${ChangeModulePackage};

import graphmodel.Edge;
import graphmodel.ModelElement;
import graphicalgraphmodel.CNode;
import graphicalgraphmodel.CEdge;

import info.scce.mcam.framework.modules.ChangeModule;
import ${AdapterPackage}.${GraphModelName}Id;
import ${AdapterPackage}.${GraphModelName}Adapter;

import ${GraphModelPackage}.${ModelElementName};
import ${GraphModelPackage}.${GraphModelName};

<#list ContainerTypes as container>
<#if container != ModelElementName>
import ${GraphModelPackage}.${container};
</#if>
</#list>

<#list NodeTypes as node>
<#if node != ModelElementName>
import ${GraphModelPackage}.${node};
</#if>
</#list>

import ${BasePackage}.api.c${GraphModelName?lower_case}.C${ModelElementName};
import ${BasePackage}.api.c${GraphModelName?lower_case}.C${GraphModelName};

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class ${ClassName} extends ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> {

	C${ModelElementName} cElement = null;
	${GraphModelName}Id containerId = null;

	@Override
	public String toString() {
		return "${ModelElementName?capitalize} added!";
	}

	@Override
	public void execute(${GraphModelName}Adapter model) {
		C${GraphModelName} cModel = model.getModelWrapper();
		ModelElement source = cElement.getSourceElement().getModelElement();
		ModelElement target = cElement.getTargetElement().getModelElement();

		ModelElement source = cElement.getSourceElement().getModelElement();
		ModelElement target = cElement.getTargetElement().getModelElement();
		
		String pkg = "info.scce.cinco.product.flowgraph.flowgraph";
		
		    String sourceType = pkg + "." + source.getClass().getSimpleName().substring(0, source.getClass().getSimpleName().length()-4);
		    String targetType = pkg + "." + target.getClass().getSimpleName().substring(0, target.getClass().getSimpleName().length()-4);
		    try {
				Class<?> sourceClass = Class.forName(sourceType);
				Class<?> targetClass = Class.forName(targetType);
			
			} catch (ClassNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	//	    Object obj = theClass.cast(something);
	}

	@Override
	public boolean canExecute(${GraphModelName}Adapter model) {
		boolean allPreconditionsOk = true;
		Object containerNode = model.getElementById(containerId);
		if (containerNode == null)
			allPreconditionsOk = false;
		
		CNode cSource = ((CEdge) cElement).getSourceElement();
		${GraphModelName}Id sourceId = model.getIdByString(cSource.getModelElement().getId());
		if (sourceId == null)
			allPreconditionsOk = false;
		
		CNode cTarget = ((CEdge) cElement).getTargetElement();
		${GraphModelName}Id targetId = model.getIdByString(cTarget.getModelElement().getId());
		if (targetId == null)
			allPreconditionsOk = false;
		
		return allPreconditionsOk;
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
			
			${ClassName} change = new ${ClassName}();
			change.id = id;
			change.cElement = targetWrapper.findC${ModelElementName}((${ModelElementName}) targetModel.getElementById(id));
			change.containerId = targetModel.getIdByString(change.cElement.getModelElement().getContainer().getId());
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
