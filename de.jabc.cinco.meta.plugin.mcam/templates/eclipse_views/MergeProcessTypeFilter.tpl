package ${ViewPackage}.util;

import java.util.Set;

import ${AdapterPackage}.${GraphModelName}Adapter;
import ${AdapterPackage}.${GraphModelName}Id;
import info.scce.mcam.framework.modules.ChangeModule;
import info.scce.mcam.framework.processes.MergeInformation.MergeType;
import info.scce.mcam.framework.processes.MergeProcess;

import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerFilter;

public class MergeProcessTypeFilter extends ViewerFilter{
	
	MergeType type = MergeType.UNCHANGED;
	

	public MergeProcessTypeFilter(MergeType type) {
		super();
		this.type = type;
	}

	@SuppressWarnings("unchecked")
	@Override
	public boolean select(Viewer viewer, Object parentElement, Object element) {
		if (element instanceof Set<?> || element instanceof ChangeModule<?, ?>)
			return true;
		if (element instanceof ${GraphModelName}Id) {
			${GraphModelName}Id id = (${GraphModelName}Id) element;
			Object input = viewer.getInput();
			if (input instanceof MergeProcess<?, ?>) {
				MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> mp = (MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter>) input;
				return mp.getMergeInformationMap().get(id).getType().equals(type);
			}
		}
		return false;
	}

}
