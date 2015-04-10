package ${ViewPackage}.util;

import ${AdapterPackage}.${GraphModelName}Adapter;
import ${AdapterPackage}.${GraphModelName}Id;
import info.scce.mcam.framework.modules.CheckModule;
import info.scce.mcam.framework.processes.CheckProcess;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.collections.keyvalue.DefaultKeyValue;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.Viewer;

public class CheckProcessContentProvider implements ITreeContentProvider {

private static Object[] EMPTY_ARRAY = new Object[0];
	
	private CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> cp = null;

	@Override
	public void dispose() {}

	@SuppressWarnings("unchecked")
	@Override
	public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {
		this.cp = (CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter>) newInput;
	}

	@SuppressWarnings("unchecked")
	@Override
	public Object[] getChildren(Object parentElement) {
		List<Object> elements = new ArrayList<>();
		if(parentElement instanceof CheckModule) {
			CheckModule<${GraphModelName}Id, ${GraphModelName}Adapter> module = (CheckModule<${GraphModelName}Id, ${GraphModelName}Adapter>) parentElement;
			for (${GraphModelName}Id id : module.resultList.keySet()) {
				DefaultKeyValue pair = new DefaultKeyValue(id, module.resultList.get(id));
				elements.add(pair);
			}
			return elements.toArray();
		}
		return EMPTY_ARRAY;
	}
	
	@Override
	public Object[] getElements(Object inputElement) {
		if (inputElement instanceof CheckProcess<?,?>) {
			List<CheckModule<${GraphModelName}Id, ${GraphModelName}Adapter>> checkModules = new ArrayList<>();
			for (CheckModule<${GraphModelName}Id, ${GraphModelName}Adapter> module : cp.getResults()) {
				checkModules.add(module);
			}
			return checkModules.toArray();
		}
		return EMPTY_ARRAY;
	}

	@Override
	public Object getParent(Object element) {
		if (element instanceof CheckModule<?,?>) {
			return cp;
		}
		if (element instanceof DefaultKeyValue) {
			for (CheckModule<${GraphModelName}Id, ${GraphModelName}Adapter> module : cp.getResults()) {
				for (${GraphModelName}Id id : module.resultList.keySet()) {
					DefaultKeyValue pair = new DefaultKeyValue(id, module.resultList.get(id));
					if (pair.equals(element))
						return module;
				}
			}
		}
		return null;
	}

	@Override
	public boolean hasChildren(Object element) {
		return getChildren(element).length > 0;
	}

}

